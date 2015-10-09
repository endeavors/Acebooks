import io
import json

oldFile = open('./../Results/filledisbnData.json')
oldIsbnData = json.load(oldFile)

nFile = open('./../ImgFilter Results/largeImgFiltered.json')
filteredIsbn = json.load(nFile)


counter = 0

print 'Total items:', len(filteredIsbn)

for key, value in filteredIsbn.iteritems():
	print key
	oldIsbnData[key] = value
	print counter
	counter += 1

with open('./../ImgFilter Results/allIsbn.json', 'w') as f:
	json.dump(oldIsbnData, f, sort_keys = True, indent = 4)
