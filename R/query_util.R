# paste queries together with AND
paste_query <-
function(query)
{
    if(is.null(query) || length(query)==1) return(query)
    paste(query, collapse=" AND ")
}
