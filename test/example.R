#' A function for differential expression analysis
#' 
#' This function takes a matrix of gene expression data
#' (genes in rows, samples in columns) and a factor variable
#' with two levels and performs differential expression analysis
#'
#' @param data A gene expression data matrix with genes in rows and samples in columns
#' @param grp A two-level factor variable with two levels
#'
#' @return pValues The p-values from the differential expression test.
#'
#' @keywords differential expression
#'
#' @export
#' 
#' @examples
#' R code here showing how your function works

deFunction <- function(dat, grp){
  if(!is.factor(grp)){stop("grp variable must be a factor")}
  if(length(unique(grp))!=2){stop("grp variable must have exactly two levels")} 
  if(any(genefilter::rowSds(dat)==0)){stop("some genes have zero variance")} 
  result = genefilter::rowttests(dat,grp)$p.value
  return(result)
}
