## IEEER: R interface to the IEEE Xplore Gateway

IEEE stands for the Institute of Electrical and Electronic Engineers. It publishes well over 100 peer-reviewed journals from IEEE Antennas and Propagation to IEEE Nuclear to IEEE Ultrasonics, Ferroelectrics & Frequency Control Society. 

The IEEER package is an R interface to the IEEE Xplore Search.

### Installation

The package is not currently available on
[CRAN](http://cran.r-project.org). To install, use
`devtools:install_github()`, as follows:

```r
install.packages("devtools")
library(devtools)
install_github("ropensci/aRxiv")
```

### Basic usage

The main function is `IEEE_search()`. Here's an example of its use:

```r
library(IEEE_search)
z <- IEEE_search(query = 'au:"Saul Wiggin", limit=20)
str(z)
```

### Links

* [IEEE Xplore Gateway](http://ieeexplore.ieee.org/gateway/)

### License

Licensed under the [MIT license](http://cran.r-project.org/web/licenses/MIT). ([More information here](http://en.wikipedia.org/wiki/MIT_License).)
