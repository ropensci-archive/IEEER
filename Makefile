all: data
#all: doc data vignettes
.PHONY: doc data vignettes

inst/ToDo.html: inst/ToDo.md
	R -e 'library(markdown);markdownToHTML("$<", "$@")'

doc:
	R -e 'library(devtools);document()'

vignettes: inst/doc/IEEER.html

inst/doc/IEEER.html: vignettes/IEEER.Rmd
	cd $(@D);R -e 'library(knitr);knit2html("../../$<")'

data: data/query_terms.RData

data/query_terms.RData: inst/scripts/grab_api_table.R
	cd $(<D);R CMD BATCH $(<F)
