import io
import os
import json
from ImageRetriever import getImageforISBN

ImgUrlJsonFile = open('./SP15/isbnData.json', 'r')
ImgUrlData = json.load(ImgUrlJsonFile)

filledJsonFile = open('./Results/filledisbnData.json', 'r')
filledData = json.load(filledJsonFile)

globalDict = {}
print 'ImgUrlData: ', len(ImgUrlData)
print 'filledData: ', len(filledData)
counter = 0
for key, value in ImgUrlData.items():

	if (key not in filledData):
		if ('title' not in value):
			imgDict = getImageforISBN(key)
			if (imgDict != 0):
				globalDict[key] = imgDict
		else:
			globalDict[key] = value
	counter += 1
	print counter


curr_dir = os.getcwd()
curr_dir = curr_dir + '/Results'
with open(curr_dir + '/diffisbnData.json', 'w') as ofile:
    json.dump(globalDict, ofile, sort_keys = True, indent = 4)
