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

# omit the headings and remove extraneous characters from the rest
query_param <- tab[-headings,]
query_param[is.na(query_param)] <- ""
query_param <- apply(query_param, 2, function(a) gsub('\t', ' ', a))
query_param <- apply(query_param, 2, function(a) gsub('[\r\n"]', "", a))
query_param <- apply(query_param, 2, function(a) gsub('  ', ' ', a))

# make data frame; change column names
query_param <- as.data.frame(query_param, stringsAsFactors=FALSE)
colnames(query_param) <- c("term", "description", "boolean_query_field", "type")

# remove the sorting/paging/faceting rows
query_param <- query_param[query_param$type != "Sorting parameters" &
                           query_param$type != "Paging parameters" &
                           query_param$type != "Open Facets parameters" &
                           query_param$type != "Open Facets Possible Values",]

rownames(query_param) <- 1:nrow(query_param)

## save as data sets within package
save(query_param, file="../../data/query_param.RData")
