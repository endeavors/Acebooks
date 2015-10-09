import re
import urllib
import sys
import urllib2
import mechanize
import cookielib
import json
import io
import os
import time
from bs4 import BeautifulSoup
from ImageRetriever import getImageforISBN

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
        #print sys.exc_traceback.tb_lineno 
        #print sys.exc_info()[0]
        return 0

'''
browser = mechanize.Browser()
browser.set_handle_redirect(True)
browser.set_handle_referer(True)
browser.set_handle_robots(False)

browser.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)
browser.addheaders = [('User-agent', \
                        'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/\
                        3.0.1-1.fc9 Firefox/3.0.1')]
'''

ImgUrlJsonFile = open('../input_files/isbnData.json', 'r')
ImgUrlData = json.load(ImgUrlJsonFile)

html_page = urllib2.urlopen('http://sdacs.ucsd.edu/~icc/findcourseid.php').read()
all_soup = BeautifulSoup(html_page)


row = all_soup.find('table').find_all_next("tr")
row = list(row)
agg_list = []
isbn_list = []
main_dictionary = {}

try:
    for row_element in row:
        inner_row = row_element.findAll("td")
    
        index = 0
        course_name = ""
        course_num = ""
        sec_id = ""
        prof_name = ""
        id_dict = {}
        txtbook_array = []
        prof_dict = {}
    
        for each_td in inner_row:
        
            if (index == 2):
                course_name = each_td.text
            elif (index == 3):
                course_num = each_td.text
            elif (index == 4):
                prof_name =  each_td.text
            elif (index == 5):
                fine_str = each_td.text
                if ("," in fine_str):
                    sec_id = (fine_str).split(",")[0]
                else:
                    sec_id = fine_str
    
            index += 1
        course_title =  course_name + "." + course_num
        input_element = course_title + "." + sec_id
        agg_list.append(input_element) #list of all course title + section ids combined
    
    
        url = 'http://ucsdbkst.ucsd.edu/wrtx/FullBookList?term=SP15&class=' + input_element
        txtbook_pg = urllib2.urlopen(url).read()
        txt_soup = BeautifulSoup(txtbook_pg)
    
        txtbk_info = txt_soup.find('table', attrs={"cellpadding": "2"}).find_all_next("tr")
        each_row = list(txtbk_info)
        perhaps_err = each_row[1].text
        if ('do not have a Book List' in perhaps_err):
            id_dict['Error'] = 'No booklist found'
        del each_row[:2]

        #each_row (array) contains html code per index pertaining author, title,...
        for row_tr in each_row:
            inner_row_elem = row_tr.findAll('td')
            counter = 0
            minPrice = 0
            txtbook_info_dict = {}
        
            #inner_row_elem: author, title (text)
            for row_td in inner_row_elem:
                string = row_td.text
                if (counter == 0):
                    if (len(string) != 0 or string != 'Ntr'):
                        txtbook_info_dict['author'] = string

                elif (counter == 1):
                    if (string == 'No Textbook Required'):
                        txtbook_info_dict.clear()
                        break
                    string = re.sub(r' \(?not Returnable\)?',"",string)
                    string = re.sub(r"\*+[0-9]?\s+|^\*+\s+|[xX]+\s*\*+\s*|^[X0-9]?\s+|\s+\(no [Rr]efund.*\)","",string)
                    isbn_check = re.search(r'[0-9]{6,}', string)

                    #isbn number was found
                    if (isbn_check):
                        split_str =  string.rsplit(',',1)
    
                        ISBN = (split_str[-1]).strip()
                        txtbook_info_dict['isbn'] = ISBN
                        txtbook_info_dict['title'] = split_str[0]

                        isbn_list.append(ISBN)

                        if (ISBN in ImgUrlData):
                            print 'ISBN exists'

                            isbnDict = ImgUrlData[ISBN]
                            print 'isbnDict: ', isbnDict

                            if ('title' in isbnDict):
                                print "IS_TITLE"
                                tempDict = {}
                                tempDict.update(isbnDict)
                                del tempDict['title']
                                del tempDict['author']
                                if (len(tempDict) != 0):
                                    txtbook_info_dict['image_url'] = tempDict
                                print 'ImgUrlData: ', ImgUrlData[ISBN]
                                print 'isbnDict Update title: ', isbnDict
                                print 'tempDict Update title: ', tempDict
                            else:
                                txtbook_info_dict['image_url'] = isbnDict
                                isbnDict['title'] = txtbook_info_dict['title']
                                isbnDict['author'] = txtbook_info_dict['author']
                                ImgUrlData[ISBN] = isbnDict
                                print 'isbnDict Update title: ', isbnDict

                        else:
                            #returns img dict of large/small images
                            imgDict = getImageforISBN(ISBN)
                            if (imgDict != 0):
                            
                                imgUrlDict ={}
                                if (len(imgDict) != 0):
                                    txtbook_info_dict['image_url'] = imgDict
                                    imgUrlDict.update(imgDict)
                            
                                imgUrlDict['title'] = txtbook_info_dict['title']
                                imgUrlDict['author'] = txtbook_info_dict['author']
                                ImgUrlData[ISBN] = imgUrlDict
                            else:
                                #run again
                                imgDict = getImageforISBN(ISBN)
                                imgUrlDict ={}

                                if (imgDict != 0):
                                    txtbook_info_dict['image_url'] = imgDict
                                    imgUrlDict.update(imgDict)
                            
                                imgUrlDict['title'] = txtbook_info_dict['title']
                                imgUrlDict['author'] = txtbook_info_dict['author']
                                ImgUrlData[ISBN] = imgUrlDict
                    
                    else:
                        txtbook_info_dict['title'] = string
                    
                elif (counter != 2):

                    if (len(string) != 0):
                        price = string.rsplit('$',1)[-1]
                        try:
                            deciPrice = float(price)

                            #set a min value first
                            if (deciPrice < minPrice or minPrice == 0):
                                minPrice = deciPrice
                        except:
                            minPrice = price
                        condition = string.split(",",1)[0]
                        txtbook_info_dict['condition'] = condition
                
                counter += 1

            if (len(txtbook_info_dict) != 0):
                txtbook_info_dict['cheapest_price'] = minPrice
                txtbook_array.append(txtbook_info_dict)
            
            else:
                id_dict['NA'] = 'No Textbook Required'
        

        id_dict['secid'] = sec_id

        if ("Error" not in id_dict):
            id_dict['textbooks'] = txtbook_array

        dict_value = main_dictionary.get(course_title)
        #multiple classes with the same course title
        if (dict_value):
            dict_value[prof_name] = id_dict
            main_dictionary[course_title] = dict_value
        else:
            prof_dict[prof_name]= id_dict
            main_dictionary[course_title] = prof_dict

        print len(main_dictionary)
except Exception, e:
    print e
    curr_dir = os.getcwd()
    curr_dir = curr_dir + '/../Results'

    with open(curr_dir + '/textbookInfo.json', 'w') as outfile:
        json.dump(main_dictionary, outfile, sort_keys = True, indent = 4)

    with open(curr_dir + '/courseTitleInfo.json', 'w') as wfile:
        json.dump(agg_list, wfile, sort_keys = True, indent = 4)

    with open(curr_dir + '/isbnListInfo.json', 'w') as ifile:
        json.dump(isbn_list, ifile, sort_keys = True, indent = 4)

    with open(curr_dir + '/isbnData.json', 'w') as ofile:
        json.dump(ImgUrlData, ofile, sort_keys = True, indent = 4)

curr_dir = os.getcwd()
curr_dir = curr_dir + '/../Results'

with open(curr_dir + '/textbookInfo.json', 'w') as outfile:
    json.dump(main_dictionary, outfile, sort_keys = True, indent = 4)

with open(curr_dir + '/courseTitleInfo.json', 'w') as wfile:
    json.dump(agg_list, wfile, sort_keys = True, indent = 4)

with open(curr_dir + '/isbnListInfo.json', 'w') as ifile:
    json.dump(isbn_list, ifile, sort_keys = True, indent = 4)

with open(curr_dir + '/isbnData.json', 'w') as ofile:
    json.dump(ImgUrlData, ofile, sort_keys = True, indent = 4)



print 'END'




