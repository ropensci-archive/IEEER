context("basic searches")

test_that("IEEE_count and IEEE_search work in a simple case", {

    # shorter delay to speed tests
    old_delay <- getOption("IEEER_delay")
    on.exit(options(IEEER_delay=old_delay))
    options(IEEER_delay=0.5)

    query <- list(au="Rabiner, L",
                  pys=1970, pye=1970)
    count <- IEEE_count(query)
    expect_equal(omit_attr(count), 4)

    result <- IEEE_search(query)
    expect_equal(nrow(result), 4)
    expect_equal(attr(result, "totalfound"), 4)

    titles <- c("A fast method of generating digital random numbers",
                "The design of wide-band recursive and nonrecursive digital differentiators",
                "An approach to the approximation problem for nonrecursive digital filters",
                "Synthetic voices for computers")
    authors <- c("Rader, C.M.;  Rabiner, L.R.;  Schafer, R.W.",
                 "Rabiner, L.;  Steiglitz, K.",
                 "Rabiner, L.;  Gold, B.;  McGonegal, C.",
                 "Flanagan, J.L.;  Coker, C.;  Rabiner, L.;  Schafer, R.W.;  Umeda, N.")
    pubtitle <- c("Bell System Technical Journal, The",
                   "Audio and Electroacoustics, IEEE Transactions on",
                   "Audio and Electroacoustics, IEEE Transactions on",
                   "Spectrum, IEEE")

    expect_equal(result$title, titles)
    expect_equal(result$authors, authors)
    expect_equal(result$pubtitle, pubtitle)
    expect_equal(result$punumber, c("6731005", "8337", "8337", "6"))
    expect_equal(result$py, rep("1970", 4))
    expect_equal(result$volume, c("49", "18", "18", "7"))
    expect_equal(result$issue, c("9", "2", "2", "10"))
    expect_equal(result$part, rep("", 4))
    expect_equal(result$spage, c("2303", "204", "83", "22"))
    expect_equal(result$epage, c("2310", "209", "106", "45"))
    arnum <- c("6772779", "1162090", "1162092", "5212992")
    expect_equal(result$arnumber, arnum)
    expect_equal(result$publicationId, arnum)
    expect_equal(result$pubtype, rep("Journals & Magazines", 4))
    expect_equal(result$publisher, c("Alcatel-Lucent", "IEEE", "IEEE", "IEEE"))
    expect_equal(result$issn, c("0005-8580", "0018-9278", "0018-9278", "0018-9235"))
    expect_equal(result$thesaurusterms, c("",
                                          paste0("Delay|Digital filters|Digital simulation|Frequency response|",
                                                 "Gold|Laboratories|Poles and zeros|Sampling methods|Telephony|",
                                                 "Wideband"),
                                          paste0("Band pass filters|Chebyshev approximation|Digital filters|",
                                                 "Filtering theory|Frequency|IIR filters|Laboratories|",
                                                 "Low pass filters|Poles and zeros|Telephony"),
                                          paste0("Computer displays|Frequency|Humans|Information rates|",
                                                 "Natural languages|Resonance|Speech analysis|",
                                                 "Speech synthesis|Telephony|Vocabulary")))

})
