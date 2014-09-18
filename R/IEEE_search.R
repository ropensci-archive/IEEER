#' The main search function for IEEE
#'
#' Allows for progammatic searching of the IEEE pre-print repository.
#'
#' @param query Character string (for a simple search), or a named
#' list of search strings, with the names corresponding to IEEE search
#' parameters (see \code{\link{query_param}} or
#' \url{http://ieeexplore.ieee.org/gateway})
#' @param start An offset for the start of search
#' @param limit Maximum number of records to return
#' @param sort_by How to sort the results
#' @param ascending If TRUE, sort in ascending order; else descending
#' @param batchsize Maximum number of records to request at one time
#' @param output_format Indicates whether output should be a data frame or a list
#' @param sep String to use to separate multiple entries in
#' multiple-entry fields (e.g., \code{controlledterms}), in the case
#' that \code{output_format="data.frame"}.
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
#'  [,1] \tab rank             \tab numeric rank in search \cr
#'  [,2] \tab title            \tab document title \cr
#'  [,3] \tab authors          \tab authors \cr
#'  [,4] \tab thesaurusterms   \tab thesaurus terms \cr
#'  [,5] \tab pubtitle         \tab journal title \cr
#'  [,6] \tab punumber         \tab publication number \cr
#'  [,7] \tab pubtype          \tab publication type \cr
#'  [,8] \tab publisher        \tab publisher \cr
#'  [,9] \tab py               \tab publication year \cr
#' [,10] \tab spage            \tab start page \cr
#' [,11] \tab epage            \tab end page \cr
#' [,12] \tab abstract         \tab abstract \cr
#' [,13] \tab isbn             \tab ISBN number \cr
#' [,14] \tab htmlFlag         \tab html flag (\code{"1"} or \code{""}) \cr
#' [,15] \tab arnumber         \tab article number \cr
#' [,16] \tab doi              \tab DOI \cr
#' [,17] \tab publicationId    \tab publication ID \cr
#' [,18] \tab mdurl            \tab document URL \cr
#' [,19] \tab pdf              \tab URL for PDF \cr
#' [,20] \tab affiliations     \tab authors' affiliations \cr
#' [,21] \tab controlledterms  \tab controlled terms (keywords) \cr
#' [,22] \tab volume           \tab volumn number \cr
#' [,23] \tab issn             \tab ISSN number \cr
#' [,24] \tab issue            \tab issue number \cr
#' }
#'
#' The contents are all strings; missing values are empty strings (\code{""}).
#'
#' Some columns (e.g., \code{thesaurusterms} and
#' \code{controlledterms}) may have multiple entries separated by
#' \code{sep} (by default, \code{"|"}).
#'
#' The result includes an attribute \code{"search_info"} that includes
#' information about the details of the search parameters, including
#' the time at which it was completed. Additional attributes include
#' \code{"totalfound"}, the total number of records that match the
#' query, and \code{totalsearched}, the total number of records
#' searched.
#'
#' @examples
#' \dontshow{old_delay <- getOption("IEEER_delay")
#'           options(IEEER_delay=1)}
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
#' \dontshow{options(IEEER_delay=old_delay)}
IEEE_search <-
function(query=NULL, start=0, limit=10,
         sort_by=c("year", "author", "title", "affilitation", "journal", "articlenumber"),
         ascending=TRUE, batchsize=100,
         output_format=c("data.frame", "list"), sep="|")
{
    query_url <- "http://ieeexplore.ieee.org/gateway/ipsSearch.jsp"

    # ensure query is a list and check some parameters
    query <- clean_query(query)

    sort_by <- match.arg(sort_by)
    sort_order <- ifelse(ascending, "asc", "desc")
    output_format <- match.arg(output_format)

    if(is.null(start)) start <- 0
    if(is.null(limit)) limit <- IEEE_count(query)

    stopifnot(start >= 1)
    stopifnot(limit >= 0)
    stopifnot(batchsize >= 1)
    if(batchsize > 1000)
        stop("batchsize can't be > 1000")

    if(limit > batchsize) { # use batches
        return(IEEE_search_inbatches(query=query,
                                      start=start, limit=limit,
                                      sort_by=sort_by, ascending=ascending,
                                      batchsize=batchsize,
                                      output_format=output_format, sep=sep))
    }

    # add limits and sorting param to query
    query_to_send <- query
    query_to_send$hc <- limit
    query_to_send$rs <- start
    query_to_send$sortorder <- sort_order
    query_to_send$sortfield <- recode_sortby(sort_by)

    # do search
    delay_if_necessary()

    search_result <- httr::POST(query_url, query=query_to_send)
    set_IEEER_time() # set time for last call to IEEE

    # check for http error
    httr::stop_for_status(search_result)

    # convert XML results to a list
    results <- result2list(search_result)

    # convert to data frame
    if(output_format=="data.frame")
        results <- listresult2df(results)

    attr(results, "search_info") <-
        search_attributes(query, start, limit,
                          sort_by, ascending)

    results
}


# search in batches
IEEE_search_inbatches <-
function(query=NULL, start=0, limit=10,
         sort_by=c("year", "author", "title", "affilitation", "journal", "articlenumber"),
         ascending=TRUE, batchsize=500,
         output_format=c("data.frame", "list"), sep="|")
{
    sort_by <- match.arg(sort_by)
    sort_order <- ifelse(ascending, "asc", "des")
    output_format <- match.arg(output_format)

    nbatch <- (limit %/% batchsize) + ifelse(limit %% batchsize, 1, 0) # integer arithmetic, to be safe
    results <- NULL

    starts <- seq(start, start+limit-1, by=batchsize)

    for(i in seq(along=starts)) {

        these_results <- IEEE_search(query=query,
                                     start=starts[i], limit=batchsize,
                                     sort_by=sort_by, ascending=ascending,
                                     batchsize=batchsize,
                                     output_format="list", sep=sep)

        message("retrieved batch ", i)

        # grab totalfound and totalsearched attributes
        totalfound <- attr(these_results, "totalfound")
        totalsearched <- attr(these_results, "totalsearched")

        # if no more results? then return
        if(length(these_results) == 0) break

        results <- c(results, these_results)
    }

    if(output_format=="data.frame")
        results <- listresult2df(results)

    attr(results, "search_info") <-
        search_attributes(query, start, limit,
                          sort_by, ascending)

    attr(results, "totalfound") <- totalfound
    attr(results, "totalsearched") <- totalsearched

    results
}


# convert query to a list
clean_query <-
function(query)
{
    if(is.list(query)) { # named list: check some arguments
        # check publisher
        check_query_param(query, "pu", c("IEEE", "AIP", "IET", "AVS", "IBM"))
        # check content type
        check_query_param(query, "ctype", c("Conferences", "Journals", "Books",
                                            "Early Access", "Standards",
                                            "Educational Courses"))
        check_query_param(query, "oa", c("0", "1"))
    }
    else {
        if(length(query) > 1)
            query <- paste(query, collapse=" AND ")
        query <- list(querytext=query)
    }
    query
}


# check some of the query parameters, if present
#     as in http://ieeexplore.ieee.org/gateway
check_query_param <-
function(query, field, allowed)
{
    if(field %in% names(query)) {
        if(!(query[field] %in% allowed))
            stop("query parameter ", field, " must be one of ",
                 paste(allowed, collapse="/"),
                 "; value ", query[field], " not allowed.")
    }
    TRUE
}

# re-code the sort_by argument using IEEE Xplore codes
recode_sortby <-
function(sort_by=c("year", "author", "title", "affilitation", "journal", "articlenumber"))
{
    sort_by <- match.arg(sort_by)
    switch(sort_by,
           year="py",
           author="au",
           title="ti",
           affiliation="cs",
           journal="jn",
           articlenumber="an")
}


# an attribute to add to the result
search_attributes <-
function(query, start, limit, sort_by,
         ascending)
{
    list(query=query, start=start, limit=limit, sort_by=sort_by,
         ascending=ascending, time=paste(Sys.time(), Sys.timezone()))
}
