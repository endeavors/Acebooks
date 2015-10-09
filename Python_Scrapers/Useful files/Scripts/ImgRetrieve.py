import json
import urllib2
import mechanize
import time
import sys
import io

def getImageUrl(data):
    try:
        items = data['items']
        for item in items:
            item = item['volumeInfo']
            image = item['imageLinks']
            image = image['thumbnail']
            image = image.replace("zoom=1", "zoom=0")
            return image #image url (bigger image)
    except:
        return 0

def getTitle(data):
  try:
    items = data['items']
    for item in items:
      item = item['volumeInfo']
      title = item['title']
      return title
  except:
    return 0

def writetofile(dicturl):
	outfile = open('ImgUrl.json', 'r')
	jdata = json.load(outfile)
	jdata.update(dicturl)
	with open('ImgUrl.json', 'w') as f:
		json.dump(jdata, f, sort_keys = True, indent = 4) 

jfile =  open('./isbnInfo.json', 'r')
rawisbn = json.load(jfile)
globalDict = {}
gcounter = 0
opener = None
browser = mechanize.Browser()

browser.set_handle_redirect(True)
browser.set_handle_referer(True)
browser.set_handle_robots(False)

browser.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)
browser.addheaders = [('User-agent', \
                    'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/\
                	3.0.1-1.fc9 Firefox/3.0.1')]

for index in range(1304,len(rawisbn)):
	print "index: ", index
 	if gcounter <= 10:
  		opener = browser.open('http://proxyfly.info')
  		gcounter += 1
  	elif (gcounter <= 20):
  		opener = browser.open('http://proxyfly.info')
  		gcounter += 1
  	elif (gcounter <= 30):
  		#opener = browser.open('http://hiproxy.xyz')
  		opener = browser.open('http://unblocksites.xyz')
  		gcounter += 1
	elif (gcounter <= 40):
		opener = browser.open('http://proxyname.info')
		gcounter += 1
	elif (gcounter <= 50):
		opener = browser.open('http://free-proxyserver.in')
		gcounter += 1
       	if (gcounter == 50):
           	gcounter = 0
            
	browser.form = list(browser.forms())[0] 
	prefix = 'https://www.googleapis.com/books/v1/volumes?q=isbn:'
	suffix = '&fields=items(volumeInfo(authors%2CimageLinks%2CindustryIdentifiers%2Ctitle))'
	browser['u'] = prefix + rawisbn[index] + suffix
	imgDict = {}
    
	try:
  		browser.submit()
  		jsonData = browser.response().get_data()
  		print jsonData

  		try:
  			jsonData = json.loads(jsonData)
  		except:
  			browser.back()
  			browser.form = list(browser.forms())[0] 
  			browser['u'] = prefix + rawisbn[index] + suffix
  			browser.submit()
  			jsonData = browser.response().get_data()
  			jsonData = json.loads(jsonData)

  		imgUrl = getImageUrl(jsonData) #change zoom 1 to 0
      bookTitle = getTitle(jsonData)

  		if (imgUrl != 0):
  			try:
  				#open bigger image url and if it works, then it means
  				#a smaller image must exist
  				urllib2.urlopen(imgUrl)
  				imgDict['large'] = imgUrl
  				imgUrl = imgUrl.replace("zoom=0", "zoom=1")
  			except:
  				imgUrl = imgUrl.replace("zoom=0", "zoom=1")

  			imgDict['small'] = imgUrl

      if (bookTitle != 0):
        imgDict['title'] = bookTitle

  	except:
  		e = sys.exc_info()[0]
  		print sys.exc_traceback.tb_lineno 
  		print "Error retrieving image url for ISBN: %s (CODE: %s | %s)" % (rawisbn[index],opener.code, e)
  		writetofile(globalDict)
  		break   
  	browser.back()
  	#if (len(imgDict) != 0):
  	globalDict[rawisbn[index]] = imgDict
  	print len(globalDict)
  	time.sleep(1.5)

writetofile(globalDict)

