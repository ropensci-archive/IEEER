#' Count number of results for a given search
#'
#' Count the number of results for a given search. Useful to check
#' before attempting to pull down a very large number of records.
#'
#' @param query Search pattern as a string; a vector of such strings
#' are combined with \code{AND}
#'
#' @export
#'
#' @return Number of results (integer). An attribute
#' \code{"search_info"} contains information about the search
#' parameters and the time at which it was performed.
#'
#' @examples
#' \dontshow{old_delay <- getOption("IEEE_delay")
#'           options(IEEE_delay=1)}
#' # count papers in category stat.AP (applied statistics)
#' IEEE_count(query = "cat:stat.AP")
#'
#' # count papers by Peter Hall in any stat category
#' \donttest{IEEE_count(query = 'au:"Peter Hall" AND cat:stat*')}
#'
#' # count papers for a range of dates
#' #    here, everything in 2013
#' \donttest{IEEE_count("submittedDate:[2013 TO 2014]")}
#' \dontshow{options(IEEE_delay=old_delay)}
IEEE_count <-
function(query=NULL)
{
    query_url <- "http://ieeexplore.ieee.org/gateway/ipsSearch.jsp"

    query <- paste_query(query)

    # do search
    delay_if_necessary()
    search_result <- httr::GET(query_url, list(querytext=query, hc=0))
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

    # return totalResults
    result <- as.integer(listresult$totalResults)

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
    attr(x, "total_results") <- NULL

    if("IEEE_count" %in% class(x))
        x <- unclass(x)

    x
}
