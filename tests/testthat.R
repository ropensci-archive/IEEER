library(testthat)
library(IEEER)

if(can_IEEE_connect()) {
    # run only if can connect to IEEE
    test_check("IEEER")
} else {
    # if can't connect and not CRAN, throw an error
    if (identical(Sys.getenv("NOT_CRAN"), "true"))
        error("Can't connect to IEEE")
}
