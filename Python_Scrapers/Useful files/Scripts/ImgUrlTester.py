import io
import json

fil = open("./ImgUrl.json", "r")
data = json.load(fil)
print len(data)

jfile =  open('./isbnInfo.json', 'r')
rawisbn = json.load(jfile)
print len(rawisbn)

isbn_list = []
for isbn in rawisbn:
	if isbn not in data:
		print isbn
		isbn_list.append(isbn)