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

#print search results and searched articles
top = xmlRoot(doc)
names(top)

#print xml doc
print(datadoc) 

	