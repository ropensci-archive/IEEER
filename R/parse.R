
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

# convert XML for a single record to a named vector of character strings
record2vector <-
function(record, sep="|")
{
    nam <- names(record)
    nfield <- length(nam)
    len_field <- sapply(record[1:nfield], XML::xmlSize)

    res <- rep("", nfield)
    names(res) <- nam
    res[len_field==1] <- sapply(record[len_field==1], XML::xmlValue)
    for(i in which(len_field > 1))
        res[i] <- paste(sapply(record[[i]][1:len_field[i]], XML::xmlValue), collapse=sep)
    res
}

# expected columns in output
#   results will contain all of these
expected_columns <-
function()
{
  c("rank", "title", "authors", "thesaurusterms", "pubtitle", "punumber",
    "pubtype", "publisher", "py", "spage", "epage", "abstract", "isbn",
    "htmlFlag", "arnumber", "doi", "publicationId", "mdurl", "pdf",
    "affiliations", "controlledterms", "volume", "issn", "issue")
}

# data frame for an empty result
empty_result <-
function(columns)
{
    result <- lapply(columns, function(a) character(0))
    names(result) <- columns
    as.data.frame(result)
}

# convert list of results (from result2list) into data.frame
#   test for this in tests/testthat/test-clean.R
listresult2df <-
function(listresult)
{
    n_result <- length(listresult)

    if(n_result==0)
        return(empty_result(expected_columns()))

    columns <- expected_columns()

    # names of all fields in input
    allcol <- unique(unlist(lapply(listresult, names)))
    m <- match(allcol, columns)
    # add any unexpected ones to the vector of columns
    if(any(is.na(m)))
        columns <- c(columns, allcol[is.na(match(allcol, columns))])

    # empty data frame to contain result
    result <- matrix("", nrow=n_result, ncol=length(columns))
    dimnames(result) <- list(1:n_result, columns)
    result <- as.data.frame(result, stringsAsFactors=FALSE)

    # grab info for one column at a time
    #     missing values made empty character strings
    for(i in columns)
        result[,i] <- sapply(listresult, function(a) ifelse(i %in% names(a), a[i], ""))

    # copy over the attributes
    for(s in c("totalfound", "totalsearched"))
        attr(result, s) <- attr(listresult, s)

    result
}
