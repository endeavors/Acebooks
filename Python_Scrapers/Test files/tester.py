import re
import urllib
import json
from bs4 import BeautifulSoup

opener = urllib.FancyURLopener()
html_page = opener.open('http://ucsdbkst.ucsd.edu/wrtx/FullBookList?term=WI15&class=MMafW.14e.82623175').read()
all_soup = BeautifulSoup(html_page)

each_row = all_soup.find('table', attrs={"cellpadding": "2"}).find_all_next("tr")
each_row = list(each_row)
print each_row[1].text

del each_row[:2]

for row_tr in each_row:
    inner_row = row_tr.findAll('td')
    for row_td in inner_row:
        string = row_td.text
