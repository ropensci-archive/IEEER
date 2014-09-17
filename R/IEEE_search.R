#' The main search function for IEEE
#'
#' Allows for progammatic searching of the IEEE pre-print repository.
#'
#' @param query Search pattern as a string; a vector of such strings
#' are combined with \code{AND}
#' @param start An offset for the start of search
#' @param limit Maximum number of records to return.
#' @param sort_by How to sort the results
#' @param ascending If TRUE, sort in ascending order; else descending
#' @param batchsize Maximum number of records to request at one time
#' @param output_format Indicates whether output should be a data frame or a list.
#' @param sep String to use to separate multiple authors,
#' affiliations, links, and categories, in the case that
#' \code{output_format="data.frame"}.
#'
#' @export
#'
#' @return If \code{output_format="data.frame"}, the result is a data
#' frame with each row being a manuscript and columns being the
#' various fields.
#'
#' If \code{output_format="list"}, the result is a list parsed from
#' the XML output of the search, closer to the raw output from IEEE.
#'
#' The data frame format has the following columns.
#' \tabular{rll}{
#'  [,1] \tab id               \tab IEEE ID \cr
#'  [,3] \tab submitted        \tab date first submitted \cr
#'  [,2] \tab updated          \tab date last updated \cr
#'  [,4] \tab title            \tab manuscript title \cr
#'  [,5] \tab summary          \tab abstract \cr
#'  [,6] \tab authors          \tab author names \cr
#'  [,7] \tab affiliations     \tab author affiliations \cr
#'  [,8] \tab link_abstract    \tab hyperlink to abstract \cr
#'  [,9] \tab link_pdf         \tab hyperlink to pdf \cr
#' [,10] \tab link_doi         \tab hyperlink to DOI \cr
#' [,11] \tab comment          \tab authors' comment \cr
#' [,12] \tab journal_ref      \tab journal reference \cr
#' [,13] \tab doi              \tab published DOI \cr
#' [,14] \tab primary_category \tab primary category \cr
#' [,14] \tab categories       \tab all categories \cr
#' }
#'
#' The contents are all strings; missing values are empty strings (\code{""}).
#'
#' The columns \code{authors}, \code{affiliations}, \code{link_doi},
#' and \code{categories} may have multiple entries separated by
#' \code{sep} (by default, \code{"|"}).
#'
#' The result includes an attribute \code{"search_info"} that includes
#' information about the details of the search parameters, including
#' the time at which it was completed. Another attribute
#' \code{"total_results"} is the total number of records that match
#' the query.
#'
#' @examples
#' \dontshow{old_delay <- getOption("IEEE_delay")
#'           options(IEEE_delay=1)}
#' # search for author Peter Hall with deconvolution in title
#' z <- IEEE_search(query = 'au:"Peter Hall" AND ti:deconvolution', limit=2)
#' attr(z, "total_results") # total no. records matching query
#' z$title
#'
#' # search for a set of documents by IEEE identifiers
#' \donttest{z <- IEEE_search(id_list = c("0710.3491v1", "0804.0713v1", "1003.0315v1"))}
#' # can also use a comma-separated string
#' \donttest{z <- IEEE_search(id_list = "0710.3491v1,0804.0713v1,1003.0315v1")}
#' # Journal references, if available
#' z$journal_ref
#'
#' # search for a range of dates (in this case, one day)
#' \donttest{z <- IEEE_search("submittedDate:[199701010000 TO 199701012400]", limit=2)}
#' \dontshow{options(IEEE_delay=old_delay)}
IEEE_search <-
function(query=NULL, id_list=NULL, start=0, limit=10,
         sort_by=c("submitted", "updated", "relevance"),
         ascending=TRUE, batchsize=100, force=FALSE,
         output_format=c("data.frame", "list"), sep="|")
{
    query_url <- "http://ieeexplore.ieee.org/gateway/ipsSearch.jsp"

    query <- paste_query(query)
    id_list <- paste_id_list(id_list)

    sort_by <- match.arg(sort_by)
    sort_order <- ifelse(ascending, "ascending", "descending")
    output_format <- match.arg(output_format)

    if(is.null(start)) start <- 0
    if(is.null(limit)) limit <- IEEE_count(query, list)

    stopifnot(start >= 0)
    stopifnot(limit >= 0)
    stopifnot(batchsize >= 1)

    # if force=FALSE, check that we aren't asking for too much
    if(!force) {
        too_many_res <- is_too_many(query, id_list, start, limit)
        if(too_many_res)
            stop("Expecting ", too_many_res, " results; refine your search")
        if(too_many_res > batchsize && batchsize > 1000)
            stop("Expecting ", too_many_res, " and batchsize is ",
                 batchsize, " which looks too large.\n",
                 "Refine your search or reduce batchsize.")
    }

    if(limit > batchsize) { # use batches
        return(IEEE_search_inbatches(query=query, id_list=id_list,
                                      start=start, limit=limit,
                                      sort_by=sort_by, ascending=ascending,
                                      batchsize=batchsize, force=force,
                                      output_format=output_format, sep=sep))
    }

    # do search
    delay_if_necessary()
    search_result <- httr::POST(query_url,
                                body=list(search_query=query, id_list=id_list,
                                          start=start, max_results=limit,
                                          sortBy=recode_sortby(sort_by), sortOrder=sort_order))
    set_IEEE_time() # set time for last call to IEEE

    # convert XML results to a list
    listresult <- result2list(search_result)

    # check for IEEE error
    error_message <- IEEE_error_message(listresult)
    if(!is.null(error_message)) {
        stop("IEEE error: ", error_message)
    }

    # check for general http error
    httr::stop_for_status(search_result)

    # total no. records matching query
    total_results <- as.integer(listresult$totalResults)

    # pull out just the entries
    results <- get_entries(listresult)

    # convert to data frame
    if(output_format=="data.frame")
        results <- listresult2df(results, sep=sep)

    attr(results, "search_info") <-
        search_attributes(query, id_list, start, limit,
                          sort_by, sort_order)

    attr(results, "total_results") <- total_results

    results
}


# search in batches
IEEE_search_inbatches <-
function(query=NULL, id_list=NULL, start=0, limit=10,
         sort_by=c("submitted", "updated", "relevance"),
         ascending=TRUE, batchsize=500, force=FALSE,
         output_format=c("data.frame", "list"), sep="|")
{
    sort_by <- match.arg(sort_by)
    sort_order <- ifelse(ascending, "ascending", "descending")
    output_format <- match.arg(output_format)

    nbatch <- (limit %/% batchsize) + ifelse(limit %% batchsize, 1, 0) # integer arithmetic, to be safe
    results <- NULL

    starts <- seq(start, start+limit-1, by=batchsize)

    for(i in seq(along=starts)) {

        these_results <- IEEE_search(query=query,
                                     start=starts[i], limit=batchsize,
                                     sort_by=sort_by, ascending=ascending,
                                     batchsize=batchsize, force=force,
                                     output_format="list", sep=sep)

        message("retrieved batch ", i)

        # grab total_results attribute (total no. records matching query)
        total_results <- attr(these_results, "total_results")

        # if no more results? then return
        if(count_entries(these_results) == 0) break

        results <- c(results, these_results)
    }

    if(output_format=="data.frame")
        results <- listresult2df(results, sep=sep)

    attr(results, "search_info") <-
        search_attributes(query, id_list, start, limit,
                          sort_by, sort_order)

    attr(results, "total_results") <- total_results

    results
}


recode_sortby <-
function(sort_by=c("submitted", "updated", "relevance"))
{
    sort_by <- match.arg(sort_by)
    switch(sort_by,
           submitted="submittedDate",
           updated="lastUpdatedDate",
           relevance="relevance")
}


# an attribute to add to the result
search_attributes <-
function(query, id_list, start, limit, sort_by,
         sort_order)
{
    c(query=ifelse(is.null(query), "", query),
      id_list=ifelse(is.null(id_list), "", id_list),
      start=start, limit=limit, sort_by=sort_by,
      sort_order=sort_order, time=paste(Sys.time(), Sys.timezone()))
}