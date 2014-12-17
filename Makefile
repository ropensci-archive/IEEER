all: doc data vignettes
.PHONY: doc data vignettes

doc:
	R -e 'library(devtools);document()'

vignettes: inst/doc/IEEER.html

inst/doc/IEEER.html: vignettes/IEEER.Rmd
	cp $< $(@D)
	cd $(@D);R -e 'library(knitr);knit2html("$(<F)")'

data: data/query_param.RData

data/query_param.RData: inst/scripts/grab_api_table.R
	cd $(<D);R CMD BATCH $(<F)
