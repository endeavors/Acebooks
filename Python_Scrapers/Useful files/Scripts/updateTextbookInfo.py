import json
import io

isbnFile = open('./../ImgFilter Results/largeImgFiltered.json', 'r')
isbnData = json.load(isbnFile)

baseFile = open('./../Results/textbookInfo.json','r')
jsonBaseFile = json.load(baseFile)

tempDict = jsonBaseFile
counter = 0

for key, value in jsonBaseFile.iteritems():
	for profKey, profValue in value.iteritems():
		if ('textbooks' in profValue):
			txtbookArray = profValue['textbooks']
			if (len(txtbookArray) != 0):
				for eachBook in txtbookArray:
					if ('image_url' in eachBook):
						imgDict = eachBook['image_url']
						if ('large' in imgDict):
							if (eachBook['isbn'] in isbnData): 
								#it means the large image is not valid if it is in isbnData
								print 'ISBN:', eachBook['isbn']
								print 'BEFORE:', imgDict
								del imgDict['large']
								print 'AFTER:', imgDict
								print 'TEXTBOOK:', eachBook
	print counter
	counter += 1

with open('./../fixedTextbookInfo.json', 'w') as f:
	json.dump(jsonBaseFile, f, sort_keys = True, indent = 4)

print 'END'
