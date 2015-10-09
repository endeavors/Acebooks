from PIL import Image
from PIL import ImageChops
import urllib, cStringIO
import json
import io

def isEqual(im1, im2):
	try:
		return ImageChops.difference(im1, im2).getbbox() is None
	except Exception, e:
		return False
    
isbnFile = open('/Users/tablakirat10/Acebooks/Python Acebooks/Useful files/Results/filledisbnData.json','r')
isbnData = json.load(isbnFile)

baseImg = Image.open('/Users/tablakirat10/Acebooks/Raw Images/unavail.png')
globalDict = {}
itemCounter = 0

print 'Total items:', len(isbnData)

for key, value in isbnData.iteritems():
	if ('large' in value):
		imgFile = cStringIO.StringIO(urllib.urlopen(value['large']).read())
		largeImg = Image.open(imgFile)

		if (largeImg.size[1] < largeImg.size[0]): #height is less than width
			del value['large']
			print 'Height < Width: ISBN: %s', key
			globalDict[key] = value

		imgCompResult = isEqual(baseImg, largeImg)
		if (imgCompResult): #image is not available 
			del value['large']
			print 'Img not avail: ISBN: %s', key
			globalDict[key] = value

	print itemCounter
	itemCounter += 1

with open('/Users/tablakirat10/Acebooks/Python Acebooks/Useful files/ImgFilter Results/largeImgFiltered.json', 'w') as f:
	json.dump(globalDict, f, sort_keys = True, indent = 4)
		
print 'END'