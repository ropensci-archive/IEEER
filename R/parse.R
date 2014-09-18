
# convert XML result from arxiv_search to a list format
result2list <-
function(searchresult, sep="|")
{
    root <- XML::xmlRoot(XML::xmlParse(httr::content(searchresult, "text"), asText=TRUE))
    totalfound <- as.numeric(XML::xmlValue(root[["totalfound"]]))
    totalsearched <- as.numeric(XML::xmlValue(root[["totalsearched"]]))

    result <- lapply(root["document"], record2vector, sep=sep)
    attr(result, "totalfound") <- totalfound
    attr(result, "totalsearched") <- totalsearched

    result
}

record2vector <-
function(record, sep="|")
{
    nam <- names(record)
    nfield <- length(nam)
    len_field <- sapply(record[1:nfield], xmlSize)

    res <- rep("", nfield)
    names(res) <- nam
    res[len_field==1] <- sapply(record[len_field==1], xmlValue)
    for(i in which(len_field > 1))
        res[i] <- paste(sapply(record[[i]][1:len_field[i]], xmlValue), collapse=sep)
    res
}

# convert list of results (from result2list) into data.frame
#   test for this in tests/testthat/test-clean.R
listresult2df <-
function(listresult)
{
    expectedfields <- c("rank", "title", "authors", "thesaurusterms", "pubtitle", "punumber",
                        "pubtype", "publisher", "py", "spage", "epage", "abstract", "isbn",
                        "htmlFlag", "arnumber", "doi", "publicationId", "mdurl", "pdf",
                        "affiliations", "controlledterms", "volume", "issn", "issue")

    if(length(listresult)==0)
        return(empty_result())

    mat <- vapply(listresult, clean_record, sep=sep,
                  clean_record(listresult[[1]], sep=sep))

    # strip off a bunch of "entry" values
    colnames(mat) <- 1:ncol(mat)

    as.data.frame(t(mat), stringsAsFactors=FALSE)

}
