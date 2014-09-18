#' Count number of results for a given search
#'
#' Count the number of results for a given search. Useful to check
#' before attempting to pull down a very large number of records.
#'
#' @param query Character string (for a simple search), or a named
#' list of search strings, with the names corresponding to IEEE search
#' parameters (see \code{\link{query_param}} or
#' \url{http://ieeexplore.ieee.org/gateway})
#'
#' @export
#'
#' @return Number of results (integer). An attribute
#' \code{"search_info"} contains information about the search
#' parameters and the time at which it was performed.
#'
#' @examples
#' # count papers in year 1970
#' IEEE_count(list(pys=1970, pye=1970))
#'
#' # count papers by author Rabiner
#' \donttest{IEEE_count(list(au="Rabiner"))}
#'
#' # count papers by author Rabiner, L
#' \donttest{IEEE_count(list(au="Rabiner, L"))}
IEEE_count <-
function(query=NULL)
{
    query_url <- "http://ieeexplore.ieee.org/gateway/ipsSearch.jsp"

    # ensure query is a list and check some parameters
    query <- clean_query(query)

    # add limit param to query
    query_to_send <- query
    query_to_send$hc <- 0

    # do search
    delay_if_necessary()
    search_result <- httr::POST(query_url, query=query_to_send)
    set_IEEER_time() # set time for last call to IEEE

    # check for http error
    httr::stop_for_status(search_result)

    # convert XML results to a list
    listresult <- result2list(search_result)

    # return totalResults
    result <- attr(listresult, "totalfound")

    attr(result, "search_info") <-
        search_attributes(query, NULL, NULL, NULL, NULL)

    # assign class to avoid printing attributes
    class(result) <- c("IEEE_count", "integer")
    result
}

# to avoid printing attributes
#' @export
print.IEEE_count <-
function(x, ...)
{
    print(as.vector(x), ...)
}

# omit search_info attribute
#    also, if IEEE_count, unclass
omit_attr <-
function(x)
{
    attr(x, "search_info") <- NULL
    attr(x, "totalfound") <- NULL
    attr(x, "totalsearched") <- NULL

    if("IEEE_count" %in% class(x))
        x <- unclass(x)

    x
}
