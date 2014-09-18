# grab query parameters from table at ieeexplore.ieee.org/gateway

url <- "http://ieeexplore.ieee.org/gateway"
tab <- XML::readHTMLTable(httr::content(httr::GET(url)), stringsAsFactors=FALSE)[[1]]

# rows with headings: make them a 4th column
headings <- which(is.na(tab[,2]))
names(headings) <- tab[headings,1]
headings <- c(headings, nrow(tab)+1)
tab <- cbind(tab, type=rep("", nrow(tab)), stringsAsFactors=FALSE)
for(i in 1:(length(headings)-1))
    tab[headings[i]:(headings[i+1]-1), "type"] <- names(headings)[i]


query_terms <- tab[-headings,]
query_terms[is.na(query_terms)] <- ""
query_terms <- apply(query_terms, 2, function(a) gsub('[\r\n\t"]', "", a))
query_terms <- as.data.frame(query_terms, stringsAsFactors=FALSE)
colnames(query_terms) <- c("term", "description", "boolean_query_field", "type")

## save as data sets within package
save(query_terms, file="../../data/query_terms.RData")
