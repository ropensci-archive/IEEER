#' Check for connection to IEEE API
#'
#' Check for connection to IEEE API
#'
#' @param max_time Maximum wait time in seconds
#'
#' @export
#'
#' @return Returns TRUE if connection is established and FALSE
#' otherwise.
#'
#' @examples
#' \donttest{
#' can_IEEE_connect(2)
#' }
# check for connection to IEEE API
can_IEEE_connect <-
    function(max_time=5) # maximum wait time in seconds
{
    query_url <- "http://ieeexplore.ieee.org/gateway/ipsSearch.jsp"

    result <- tryCatch(z <- httr::POST(query_url, body=list(au="Rabiner", hc=0),
                                       httr::timeout(max_time)),
                       error=function(e) paste("Failure to connect in IEEE_check"))

    # check for error in httr::POST
    if(!is.null(result) && length(result)==1 &&
       result == "Failure to connect in IEEE_check") {
        warning("Failed to connect to ", query_url, " in ", max_time, " sec")
        return(FALSE)
    }

    # check for general http error
    status <- httr::http_status(z)
    if(status$category != "success") {
        httr::warn_for_status(z)
        return(FALSE)
    }

    # seems okay...return TRUE
    TRUE
}
