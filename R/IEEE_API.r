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
install.packages('XML')names
library('XML')

#place xml doc into R dataframe datadoc
doc <- xmlTreeParse("C:/Users/Icarus/Documents/GitHub/IEEER/R/search-result.xml", useInternal = TRUE)

#PARSE XML DOC

#print search results and searched articles
top = xmlRoot(doc)
names(top)

#get abstract
xmlValue(doc[["//abstract"]])

#get author
xmlValue(doc[["//authors"]])

#get pubtitle title
xmlValue(doc[["//pubtitle"]])

#get pubtitle
xmlValue(doc[["//pubtype"]])

#get publisher
xmlValue(doc[["//publisher"]])

#get volue
xmlValue(doc[["//volume"]])

#get page
xmlValue(doc[["//py"]])

#get DOI
xmlValue(doc[["//doi"]])

#get affliations
xmlValue(doc[["//affiliations"]])

#get publication title
xmlvalue(doc[["Publication Title"]])

#get isbn
xmlValue(doc[["//isbn"]])

# get issn
xmlValue(doc[["//issn"]])

# get url address
xmlvalue(doc[["//mdurl"]])

# get pdf location
xmlvalue(doc[["//pdf"]])

	