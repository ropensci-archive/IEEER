#' The main search function for IEEE
#'
#' Allows for progammatic searching of the IEEE pre-print repository.
#'
#' @param query Character string (for a simple search), or a named
#' list of search strings, with the names corresponding to IEEE search
#' parameters (see \code{\link{query_param}} or
#' \url{http://ieeexplore.ieee.org/gateway})
#' @param start An offset for the start of search (\code{>= 1})
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
#'  [,1] \tab rank              \tab numeric rank in search \cr
#'  [,2] \tab title             \tab article title \cr
#'  [,3] \tab authors           \tab semicolon delimited list of author names \cr
#'  [,4] \tab affiliations      \tab authors' affiliations \cr
#'  [,5] \tab pubtitle          \tab publication in which article appears \cr
#'  [,6] \tab punumber          \tab IEEE identifier for publication \cr
#'  [,7] \tab py                \tab publication year \cr
#'  [,8] \tab volume            \tab volume number \cr
#'  [,9] \tab issue             \tab issue number \cr
#' [,10] \tab part              \tab part \cr
#' [,11] \tab spage             \tab start page \cr
#' [,12] \tab epage             \tab end page \cr
#' [,13] \tab arnumber          \tab unique article number \cr
#' [,14] \tab abstract          \tab first 250 words of the abstract \cr
#' [,15] \tab doi               \tab digital object identifier \cr
#' [,16] \tab mdurl             \tab document URL \cr
#' [,17] \tab pdf               \tab URL for PDF \cr
#' [,18] \tab pubtype           \tab publication type (Journal, Conference, or Standard)\cr
#' [,19] \tab publisher         \tab publisher \cr
#' [,20] \tab isbn              \tab ISBN number \cr
#' [,21] \tab issn              \tab ISSN number \cr
#' [,22] \tab publicationId     \tab publication ID \cr
#' [,23] \tab thesaurusterms    \tab terms from IEEE thesaurus \cr
#' [,24] \tab controlledterms   \tab terms from INSPEC controlled thesaurus \cr
#' [,25] \tab uncontrolledterms \tab terms not from INSPEC thesaurus \cr
#' [,26] \tab htmlFlag          \tab html flag (\code{"1"} or \code{""}) \cr
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
#' # search for author Rabiner with Markov in title
#' z <- IEEE_search(list(au="Rabiner", ti="Markov"), limit=2)
#' attr(z, "totalfound") # total no. records matching query
#' z$title
#'
#' # search for author Rabiner in years 1960-1970
#' \donttest{z <- IEEE_search(list(au="Rabiner", pys=1960, pye=1970))}
IEEE_search <-
function(query=NULL, start=1, limit=10,
         sort_by=c("year", "author", "title", "affiliation", "journal"),
         ascending=TRUE, batchsize=100,
         output_format=c("data.frame", "list"), sep="|")
{
    query_url <- "http://ieeexplore.ieee.org/gateway/ipsSearch.jsp"

    # ensure query is a list and check some parameters
    query <- clean_query(query)

    sort_by <- match.arg(sort_by)
    sort_order <- ifelse(ascending, "asc", "desc")
    output_format <- match.arg(output_format)

    if(is.null(start)) start <- 1
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
         sort_by=c("year", "author", "title", "affiliation", "journal"),
         ascending=TRUE, batchsize=500,
         output_format=c("data.frame", "list"), sep="|")
{
    sort_by <- match.arg(sort_by)
    sort_order <- ifelse(ascending, "asc", "des")
    output_format <- match.arg(output_format)

    nbatch <- (limit %/% batchsize) + ifelse(limit %% batchsize, 1, 0) # integer arithmetic, to be safe
    results <- NULL

    starts <- seq(start, start+limit-1, by=batchsize)

    # maximum record to return
    max_record <- start + limit - 1

    for(i in seq(along=starts)) {

        # avoid returning more than a total of limit records
        this_limit <- ifelse(max_record - starts[i] + 1 < batchsize,
                             max_record - starts[i] + 1,
                             batchsize)
        if(this_limit == 0) break

        these_results <- IEEE_search(query=query,
                                     start=starts[i], limit=this_limit,
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
function(sort_by=c("year", "author", "title", "affiliation", "journal"))
{
    sort_by <- match.arg(sort_by)
    switch(sort_by,
           year="py",
           author="au",
           title="ti",
           affiliation="cs",
           journal="jn")
}


# an attribute to add to the result
search_attributes <-
function(query, start, limit, sort_by,
         ascending)
{
    list(query=query, start=start, limit=limit, sort_by=sort_by,
         ascending=ascending, time=paste(Sys.time(), Sys.timezone()))
}
