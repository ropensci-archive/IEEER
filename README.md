[![Project Status: Abandoned – Initial development has started, but there has not yet been a stable, usable release; the project has been abandoned and the author(s) do not intend on continuing development.](https://www.repostatus.org/badges/latest/abandoned.svg)](https://www.repostatus.org/#abandoned)


## IEEER: R interface to the IEEE Xplore Gateway

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

### Installation

The package is not currently available on
[CRAN](http://cran.r-project.org). To install, use
`install_github()` in the
[devtools](https://github.com/hadley/devtools) package. (With
`build_vignettes=TRUE`, the vignettes will be built and installed.)

```r
install.packages("devtools")
library(devtools)
install_github("ropensci/IEEER", build_vignettes=TRUE)
```

### Basic usage

The main function is `IEEE_search()`. Here's an example of its use:

```r
library(IEEER)
z <- IEEE_search(query = list(au="Rabiner, L"), limit=20)
nrow(z)
z[,c("authors", "title")]
```

### Links

* [IEEE Xplore Gateway](http://ieeexplore.ieee.org/gateway/)

### License

Licensed under the [MIT license](http://cran.r-project.org/web/licenses/MIT). ([More information here](http://en.wikipedia.org/wiki/MIT_License).)

[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
