all: doc data vignettes
.PHONY: doc data vignettes

doc:
	R -e 'devtools::document()'

vignettes: inst/doc/IEEER.html

inst/doc/IEEER.html: vignettes/IEEER.Rmd
	cd $(<D); \
	R -e "rmarkdown::render('$(<F)', output_dir='../$(@D)')"

data: data/query_param.RData

data/query_param.RData: inst/scripts/grab_api_table.R
	cd $(<D);R CMD BATCH $(<F)
