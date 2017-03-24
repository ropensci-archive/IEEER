context("basic searches")

test_that("IEEE_count and IEEE_search work in a simple case", {

    if(!interactive()) skip("this test only run locally")

    # shorter delay to speed tests
    old_delay <- getOption("IEEER_delay")
    on.exit(options(IEEER_delay=old_delay))
    options(IEEER_delay=0.5)

    query <- list(au="Rabiner, L",
                  pys=1970, pye=1970)
    count <- IEEE_count(query)
    expect_equal(omit_attr(count), 4)

    result <- IEEE_search(query, sort_by="title")
    expect_equal(nrow(result), 4)
    expect_equal(attr(result, "totalfound"), 4)

    titles <- c("A fast method of generating digital random numbers",
                "An approach to the approximation problem for nonrecursive digital filters",
                "Synthetic voices for computers",
                "The design of wide-band recursive and nonrecursive digital differentiators")
    authors <- c("C. M. Rader;  L. R. Rabiner;  R. W. Schafer",
                 "L. Rabiner;  B. Gold;  C. McGonegal",
                 "J. L. Flanagan;  C. H. Coker;  L. R. Rabiner;  R. W. Schafer;  N. Umeda",
                 "L. Rabiner;  K. Steiglitz")
    pubtitle <- c("The Bell System Technical Journal",
                   "IEEE Transactions on Audio and Electroacoustics",
                   "IEEE Spectrum",
                   "IEEE Transactions on Audio and Electroacoustics")

    expect_equal(result$title, titles)
    expect_equal(result$authors, authors)
    expect_equal(result$pubtitle, pubtitle)
    expect_equal(result$punumber, c("6731005", "8337", "6", "8337"))
    expect_equal(result$py, rep("1970", 4))
    expect_equal(result$volume, c("49", "18", "7", "18"))
    expect_equal(result$issue, c("9", "2", "10", "2"))
    expect_equal(result$part, rep("", 4))
    expect_equal(result$spage, c("2303", "83", "22", "204"))
    expect_equal(result$epage, c("2310", "106", "45", "209"))
    arnum <- c("6772779", "1162092", "5212992", "1162090")
    expect_equal(result$arnumber, arnum)
    expect_equal(result$publicationId, arnum)
    expect_equal(result$pubtype, rep("Journals & Magazines", 4))
    expect_equal(result$publisher, c("Alcatel-Lucent", "IEEE", "IEEE", "IEEE"))
    expect_equal(result$issn, c("0005-8580", "0018-9278", "0018-9235", "0018-9278"))
    expect_equal(result$thesaurusterms, c("",
                                          paste0("Band pass filters|Chebyshev approximation|Digital filters|",
                                                 "Filtering theory|Frequency|IIR filters|Laboratories|",
                                                 "Low pass filters|Poles and zeros|Telephony"),
                                          paste0("Computer displays|Frequency|Humans|Information rates|",
                                                 "Natural languages|Resonance|Speech analysis|",
                                                 "Speech synthesis|Telephony|Vocabulary"),
                                          paste0("Delay|Digital filters|Digital simulation|Frequency response|",
                                                 "Gold|Laboratories|Poles and zeros|Sampling methods|Telephony|",
                                                 "Wideband")))

})
