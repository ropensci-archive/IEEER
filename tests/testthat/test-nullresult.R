context("null results")

test_that("IEEE_count gives 0 when no search result", {

    # shorter delay to speed tests
    old_delay <- getOption("IEEER_delay")
    on.exit(options(IEEER_delay=old_delay))
    options(IEEER_delay=0.5)

    expect_equal(omit_attr(IEEE_count()), 0)
    expect_equal(omit_attr(IEEE_search()), empty_result())

    expect_equal(omit_attr(IEEE_count("")), 0)
    expect_equal(omit_attr(IEEE_search("")), empty_result())

    query <- '"an owl in pink tights"'
    expect_equal(omit_attr(IEEE_count(query)), 0)
    expect_equal(omit_attr(IEEE_search(query)), empty_result())

})
