<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{IEEER tutorial}
-->

# IEEER tutorial

[IEEE](http://www.ieee.org/index.html) stands for the Institute of
Electrical and Electronic Engineers. It publishes well over 100
peer-reviewed journals from
[IEEE Antennas and Propagation](http://ieeexplore.ieee.org/xpl/RecentIssue.jsp?punumber=8)
to
[IEEE Nuclear](http://ieeexplore.ieee.org/xpl/RecentIssue.jsp?punumber=23)
to
[IEEE Ultrasonics, Ferroelectrics & Frequency Control Society](http://www.ieee-uffc.org/).

The [IEEER package](https://github.com/ropensci/IEEER) is an
[R](http://www.r-project.org) interface to the
[IEEE Xplore Search Gateway](http://ieeexplore.ieee.org/gateway/).





## Installation

The [IEEER package](https://github.com/ropensci/IEEER) is not
currently available on [CRAN](http://cran.r-project.org). To install the
package from [GitHub](http://github.com), use
`devtools::install_github()`, as follows:


```r
install.packages("devtools")
library(devtools)
install_github("ropensci/IEEER")
```

## Basic use

Use `IEEE_search()` to search the
[IEEE Xplore Search Gateway](http://ieeexplore.ieee.org/gateway/) and
`IEEE_count()` to get a simple count of articles matching a query.

Suppose we wanted to identify all IEEE manuscripts with
&ldquo;`Rabiner, L.`&rdquo; as an author.  It is best to first get a
count, so that we have a sense of how many records the search will
return. We first use `library()` to load the IEEER package and then
`IEEE_count()` to get the count.


```r
library(IEEER)
IEEE_count(list(au="Rabiner, L"))
```

```
## [1] 239
```

The search query could be single character string as free text,
`"Rabiner, L"`, but in that case it will be a general search and not
specific to the author field. To search just for an author, we use a
list with names corresponding to the possible query parameters; `au`
for author, `ti` for title, etc. The package includes a dataset
`query_param` with the parameter abbreviations, taken from a table at
the [IEEE Xplore Search page](http://ieeexplore.ieee.org/gateway/).

To get a count of the number of records with `Rabiner, L` as author
and `Markov` in the title, we would use:


```r
IEEE_count(list(au="Rabiner, L", ti="Markov"))
```

```
## [1] 21
```

To obtain the actual records matching the query, use `IEEE_search()`.


```r
rec <- IEEE_search(list(au="Rabiner, L", ti="Markov"))
nrow(rec)
```

```
## [1] 10
```

The default is to grab no more than 10 records; this limit can be
changed with the `limit` argument. But note that you should avoid
downloading a _large_ number of records; more on this below.

Also note that the result of `IEEE_search()` has an attribute
`"totalfound"` containing the total count of search results; this
is the same as what `IEEE_count()` provides.


```r
attr(rec, "totalfound")
```

```
## [1] 21
```

The following will get us all
21
records.


```r
rec <- IEEE_search(list(au="Rabiner, L", ti="Markov"), limit=50)
nrow(rec)
```

```
## [1] 21
```

`IEEE_search()` returns a data frame with each row being a single
manuscript. The columns are the different fields (e.g., `authors`, `title`,
`abstract`, etc.).


## Forming queries

The query argument to `IEEE_count()` and `IEEE_search()`
can be a single
character string, for a general text search, but more often it will be
a named list of character strings, with the names corresponding to the
possible query parameters.

### Query parameters

The IEEER package includes a dataset `query_param` that
lists the terms (like `au`) that you can use. Here is the first five


```r
query_param[1:5,]
```

```
##   term                           description boolean_query_field
## 1   an                        Article number      Article Number
## 2   au         Terms to search for in Author              Author
## 3   ti Terms to search for in Document Title      Document Title
## 4   ab       Terms to search for in Abstract            Abstract
## 5  doi            Terms to search for in DOI                 DOI
##                                            type
## 1           Parameter specifying single article
## 2 Parameters specifying search fields and terms
## 3 Parameters specifying search fields and terms
## 4 Parameters specifying search fields and terms
## 5 Parameters specifying search fields and terms
```

These are taken from a table at
the [IEEE Xplore Search page](http://ieeexplore.ieee.org/gateway/).


## Search results

The output of `IEEE_search()` is a data frame with the following
columns.


```r
res <- IEEE_search(list(au="Rabiner, L"), limit=1)
names(res)
```

```
##  [1] "rank"              "title"             "authors"          
##  [4] "affiliations"      "pubtitle"          "punumber"         
##  [7] "py"                "volume"            "issue"            
## [10] "part"              "spage"             "epage"            
## [13] "arnumber"          "abstract"          "doi"              
## [16] "mdurl"             "pdf"               "pubtype"          
## [19] "publisher"         "isbn"              "issn"             
## [22] "publicationId"     "thesaurusterms"    "controlledterms"  
## [25] "uncontrolledterms" "htmlFlag"
```

The columns are described in the help file for `IEEE_search()`. Try
`?IEEE_search`.

## Sorting results

The `IEEE_search()` function has two arguments for sorting the results,
`sort_by` (taking values like `"year"`, `"author"`, and
`"title`) and `ascending` (`TRUE` or `FALSE`).

Here's an example, to sort the results by title, in descending order.


```r
res <- IEEE_search(list(au="Rabiner, L", title="Markov"),
                   sort_by="title", ascending=FALSE)
res$title
```

```
##  [1] "Word recognition using whole word and subword models"                                             
##  [2] "Wiring telephone apparatus from computer-generated speech"                                        
##  [3] "Voiced-unvoiced-silence detection using the Itakura LPC distance measure"                         
##  [4] "Unbiased spectral estimation and system identification using short-time spectral analysis methods"
##  [5] "Training set design for connected speech recognition"                                             
##  [6] "Tone detection for automatic control of audio tape drives"                                        
##  [7] "There Is No Data like More Data"                                                                  
##  [8] "Theory of roundoff noise in cascade realizations of finite impulse response digital filters"      
##  [9] "Theory and Application of Digital Signal Processing"                                              
## [10] "The Speech Pioneers"
```


## Technical details

### Metadata limitations

The IEEE metadata has a number of
limitations.

Authors' names may vary between records (e.g., Rabiner,
L. vs. Rabiner, L.R. vs. Rabiner, Lawrence R.)
Further, IEEE provides no ability to
distinguish multiple individuals with the same name (c.f.,
[ORCID](http://orcid.org)).


### Limit time between search requests

Care should be taken to avoid multiple requests to the IEEE Xplore
Search Gateway in a
short period of time.

The IEEER package institutes a delay between requests, with the time
period for the delay configurable with the R option
`"IEEER_delay"` (in seconds). The default is 3 seconds.

To reduce the delay to 1 second, use:


```r
options(IEEER_delay=1)
```

**Don't** do searches in parallel (e.g., via the parallel
package). You may be locked out from the IEEE Xplore Search.


### Limit number of items returned

The IEEE Xplore Search Gateway returns only complete records (including the entire
abstracts); searches returning large numbers of records can be very
slow.

It's best to use `IEEE_count()` before `IEEE_search()`, so that you have
a sense of how many records you will receive. If the count is large,
you may wish to refine your query.

The `limit` argument to `IEEE_search()` (with default `limit=10`)
limits the number of records to be returned. If you wish to receive
more than 10 records, you must specify a larger limit (e.g., `limit=100`).

### Make requests in batches

Even for searches that return a moderate number of records (say
2,000), it may be best to make the requests in batches: Use a smaller
value for the `limit` argument (say 100), and make multiple requests
with different offsets, indicated with the `start` argument, for the
initial record to return.

This is done automatically with the `batchsize` argument to
`IEEE_search()`.  A search is split into multiple calls, with no more
than `batchsize` records to be returned by each, and then the results
are combined.


## License and bugs

- License:
  [MIT](https://github.com/ropensci/IEEER/blob/master/LICENSE)
- Report bugs or suggestions improvements by [submitting an issue](https://github.com/reopensci/IEEER/issues) to
  [the GitHub repository for IEEER](https://github.com/ropensci/IEEER).

<!-- the following to make it look nicer -->
<link href="http://kbroman.org/qtlcharts/assets/vignettes/vignette.css" rel="stylesheet"></link>
