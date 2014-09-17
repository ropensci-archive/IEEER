# INSERT API DOC here
	call_function{
	}
	
	search(number, title,{
	
		return abstract
	}

# return XML document


# parse xml document into R dataframe
	
#load XML package
load.package('XML')
library('XML')

#place xml doc into R dataframe datadoc
doc <- xmlParse("search-result.xml")
datadoc <- xmlToDataFrame(doc)


#print xml doc
print(datadoc) 

	