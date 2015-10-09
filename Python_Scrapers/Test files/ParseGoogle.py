import json
from pprint import pprint

data = {
 "items": [
  {
   "volumeInfo": {
    "title": "Human Reproductive Biology",
    "authors": [
     "Richard E. Jones",
     "Kristin H. Lopez"
    ],
    "industryIdentifiers": [
     {
      "type": "ISBN_10",
      "identifier": "0123821843"
     },
     {
      "type": "ISBN_13",
      "identifier": "9780123821843"
     }
    ],
    "imageLinks": {
     "smallThumbnail": "http://books.google.com/books/content?id=KPszmwEACAAJ&printsec=frontcover&img=1&zoom=5&source=gbs_api",
     "thumbnail": "http://books.google.com/books/content?id=KPszmwEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api"
    }
   }
  }
 ]
}



rlist = []
if ('items' in data):
  items = data['items']

  for item in items:
    if ('volumeInfo' in item):
      item = item['volumeInfo']
      
      rdict = {}
      if ('title' in item):
        rdict['title'] = item['title']

      if('authors' in item):
        rdict['authors'] = item['authors']

      if ('imageLinks' in item):
        image = item['imageLinks']
        image = image['thumbnail']
        image = image.replace("zoom=1", "zoom=0")
        rdict['imageLinks'] = image
      
      if ('industryIdentifiers' in item):
        identifiers = item['industryIdentifiers']

        for i in range(0, len(identifiers)):
          exDict = identifiers[i]
          if (exDict['type'] == 'ISBN_13'):
            rdict['isbn'] = exDict['identifier']

    rlist.append(rdict)

  pprint (rlist)
  