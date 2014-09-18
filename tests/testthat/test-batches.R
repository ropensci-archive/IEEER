
context("IEEER_search in batches")

test_that("batch search gives same result as all together", {

    # shorter delay to speed tests
    old_delay <- getOption("IEEER_delay")
    on.exit(options(IEEER_delay=old_delay))
    options(IEEER_delay=0.5)

    # all together
    query <- list(au="Rabiner, L", ti="Markov")
    z <- IEEE_search(query)
    z_time <- attr(z, "search_info")["time"]

    # in batches of 5
    zBatch <- IEEE_search(query, batchsize=5)

    # fix time
    at <- attr(zBatch, "search_info")
    at["time"] <- z_time
    attr(zBatch, "search_info") <- at

    expect_equal(z, zBatch)

    # in batches of 3
    zBatch <- IEEE_search(query, batchsize=3)

    # fix time
    at <- attr(zBatch, "search_info")
    at["time"] <- z_time
    attr(zBatch, "search_info") <- at

    expect_equal(z, zBatch)

})
