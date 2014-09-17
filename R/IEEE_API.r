# INSERT API DOC here
#	call_function{
#	}
#	
#	search(number, title,{
#	
#		return abstract
#	}
#
# return XML document


# parse xml document into R dataframe
	
#load XML package
install.packages('XML')
library('XML')

#place xml doc into R dataframe datadoc
doc <- xmlTreeParse("C:/Users/Icarus/Documents/GitHub/IEEER/R/search-result.xml", useInternal = TRUE)

#PARSE XML DOC

#print search results and searched articles
top = xmlRoot(doc)
names(top)

#get abstract
abstract <- xmlValue(doc[["//abstract"]])

#get author
author <- xmlValue(doc[["//authors"]])

#get pubtitle title
pubtitle <- xmlValue(doc[["//pubtitle"]])

#get pubtitle
pubtype <- xmlValue(doc[["//pubtype"]])

#get publisher
publisher <- xmlValue(doc[["//publisher"]])

#get volume
volume <- xmlValue(doc[["//volume"]])

#get page
pagenumber <- xmlValue(doc[["//py"]])

#get DOI
DOI <- xmlValue(doc[["//doi"]])

#get affliations
affiliations <- xmlValue(doc[["//affiliations"]])

#get isbn
isbn <- xmlValue(doc[["//isbn"]])

# get url address
url <- xmlValue(doc[["//mdurl"]])

# get pdf location
pdf <- xmlValue(doc[["//pdf"]])

	