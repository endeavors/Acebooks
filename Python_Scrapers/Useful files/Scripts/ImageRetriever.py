import json
import urllib2
import mechanize
import time
import sys
import io
from PIL import Image
from PIL import ImageChops
import urllib, cStringIO
from random import randint

baseImg = Image.open('/Users/gurkiratsingh/Projects/Acebooks/Raw Images/unavail.png')

def isEqual(im1, im2):
  try:
    return ImageChops.difference(im1, im2).getbbox() is None
  except Exception, e:
    return False

def isIllegalLargeImage(lgUrl):
  imgFile = cStringIO.StringIO(urllib.urlopen(lgUrl).read())
  largeImg = Image.open(imgFile)
  resultVal = False

  if (largeImg.size[1] < largeImg.size[0]): #height is less than width
    resultVal = True

  imgCompResult = isEqual(baseImg, largeImg)
  if (imgCompResult): #image is not available 
    resultVal = True

  return resultVal

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

def getTitleAndAuthor(data):
  try:
    items = data['items']
    for item in items:
      returnArray = []
      item = item['volumeInfo']
      title = item['title']
      returnArray.append(title)

      authorArray = item['authors']
      author = authorArray[0]
      authorSplitted = author.split(' ')
      author = authorSplitted[-1]
      returnArray.append(author)
      return returnArray
  except:
    return 0

def getImageforISBN(isbn):
  
  opener = None

  browser = mechanize.Browser()

  browser.set_handle_redirect(True)
  browser.set_handle_referer(True)
  browser.set_handle_robots(False)

  browser.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)
  browser.addheaders = [('User-agent', \
                    'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/\
                  3.0.1-1.fc9 Firefox/3.0.1')]

  randomSelect = randint(1,2);
  '''if (randomSelect == 1):
    opener = browser.open('http://proxyfly.info')
    
  elif (randomSelect == 2):
    opener = browser.open('http://proxyfly.info')
      
  elif (randomSelect == 3):
    #opener = browser.open('http://hiproxy.xyz')
    opener = browser.open('http://unblocksites.xyz')
      
  elif (randomSelect == 4):
    opener = browser.open('http://proxyname.info')
  
  elif (randomSelect == 5):
    opener = browser.open('http://free-proxyserver.in')'''

  if (randomSelect == 1):
    opener = browser.open('http://unblocksites.xyz')
  else:
    opener = browser.open('http://free-proxyserver.in')

  
  print "Browser forms", browser.forms()
  browser.form = list(browser.forms())[0] 
  prefix = 'https://www.googleapis.com/books/v1/volumes?q=isbn:'
  suffix = '&fields=items(volumeInfo(authors%2CimageLinks%2CindustryIdentifiers%2Ctitle))'
  browser['u'] = prefix + isbn + suffix
  imgDict = {}

  try:
    browser.submit()
    jsonData = browser.response().get_data()
    #print jsonData

    try:
      jsonData = json.loads(jsonData)
    except:
      browser.back()
      browser.form = list(browser.forms())[0] 
      browser['u'] = prefix + isbn + suffix
      browser.submit()
      jsonData = browser.response().get_data()
      jsonData = json.loads(jsonData)

    imgUrl = getImageUrl(jsonData) #change zoom 1 to 0
    #bookTitle = getTitleAndAuthor(jsonData)

    if (imgUrl != 0):
      try:
        #open bigger image url and if it works, then it means
        #a smaller image must exist
        urllib2.urlopen(imgUrl)
        illegalImg = isIllegalLargeImage(imgUrl)
        if not illegalImg:
          imgDict['large'] = imgUrl
        imgUrl = imgUrl.replace("zoom=0", "zoom=1")
      except:
        imgUrl = imgUrl.replace("zoom=0", "zoom=1")

      imgDict['small'] = imgUrl

      '''if (bookTitle != 0):
        imgDict['title'] = bookTitle[0]
        imgDict['author'] = bookTitle[1]'''

  except:
    e = sys.exc_info()[0]
    print sys.exc_traceback.tb_lineno 
    print "Error retrieving 0 url for ISBN: %s (CODE: %s | %s)" % (isbn, opener.code, e)
    time.sleep(1.5)
    return 0;

  time.sleep(1.5)
  print "ImgDict: ",imgDict
  return imgDict
  
    

