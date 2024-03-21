# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

# -*- coding: utf-8 -*-
"""
Created on Thu May 24 13:34:26 2018
@author: Shuai
"""

# pip install chromedriver-py

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver import ActionChains
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.firefox.options import Options

from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup as soup
from bs4 import SoupStrainer
from lxml import html
import numpy as np
from tqdm import tqdm
import time
import csv
import polars as pl
#import win32com.client as win32
from chromedriver_py import binary_path # this will get you the path variable
import re
from datetime import date
import numpy.random as random
import pdb

import pandas as pd

            
import os

# get path of current file
path = os.path.dirname(os.getcwd())
dir_data = os.path.join(path, "data", "spend", "data", "in")

# --- it runs without project and saves in `output.csv` ---



def get_awn(login_url, user, pw, years_to_get, col_codes):
    """ Logs in to FAME, retrieves saved company set for which we want to download
    data, selects columns and years to download and iteratively calls "export_orbis" for 
    range of companies that can exported at once
    
    login_url -- BvD url
    user -- username for fame
    pw -- password for fame
    years_to_get -- list of years for which to get data
    col_codes -- list of variable codes to get !! make sure to put a time-dependent variable first
    
    """
            
    # grab chrome browser
    
    options = webdriver.ChromeOptions() 
    prefs = {"download.default_directory" : "/Users/davidvandijcke/Downloads/data_axle/"}
    options.add_experimental_option("prefs",prefs)
    browser = webdriver.Chrome(ChromeDriverManager().install(), options = options)
    browser.implicitly_wait(10) # seconds
    
    ## log in to world access news database  
    login_url = "https://search.lib.umich.edu/databases/record/9111?query=data+axle"
    browser.get(login_url)
    button_db = browser.find_element("xpath", ".//*[contains(text(), 'Go to database')]") # unselect latest year (added by default)
    button_db.click()
    

    
    # close popup
    button = browser.find_element("css selector", '#closeRebrandingModal')
    button.click()
    
    # click on US businesses
    button = browser.find_element("xpath", '//*[@id="dbSelector"]/div/ul/li[1]')
    button.click()
    
    

    # input search
    spend = pd.read_csv(os.path.join(dir_data, "spend_retail.csv"))
    spend = spend.drop_duplicates(['location_name', 'city'])
    spend.loc[spend.location_name == "Casey's General Stores", 'location_name'] = "Casey's"
    
    name = "Casey's"
    city = "Blair"
    
    for name, city in zip(spend['location_name'], spend['city']):
        
        print(name, city)
        
        try: 
            # enter search fields
            name_field = browser.find_element("id", "businessName")
            name_field.clear()
            name_field.send_keys(name)
            
            city_field = browser.find_element("id", "city")
            city_field.clear()
            city_field.send_keys(city)
            
            # view results
            button = browser.find_element("class name", "action-view-results")
            button.click()
            
            time.sleep(random.rand())


            # select all results
            button = browser.find_element("id", "checkboxCol")
            button.click()

            time.sleep(random.rand())

            
            # download result
            button = browser.find_element("class name", "action-download")
            button.click()

            
            # random wait
            time.sleep(random.rand())
            
            
            # select detailed result
            button = browser.find_element("id", "detailDetail")
            button.click()
            
            time.sleep(random.rand())

            # download result
            button = browser.find_element("class name", "action-download")
            button.click()
            
            # new search
            button = browser.find_element("class name", "newSearchButton")
            button.click()
            
            # random wait
            time.sleep(random.rand()*5)

        except:
            button = browser.find_element("css selector", "body > div.ui-dialog.ui-widget.ui-widget-content.ui-corner-all.ui-draggable > div.ui-dialog-buttonpane.ui-widget-content.ui-helper-clearfix > a")
            button.click()
            
            

  

    # 1: text
    val_search = browser.find_element_by_id('edit-val-base-0')
    val_search.send_keys('("election" OR "voter" OR "votes" OR "vote" OR "voted" OR "voting" OR "electoral" OR "voters" OR "ballot" OR "ballots") AND ("stolen" OR "steal" OR "stealing" OR "fraud" OR "rigged" OR "fraudulent")')
    field_search = browser.find_element_by_id('edit-fld-base-0')
    field_search_opt = field_search.find_element_by_xpath(".//*[contains(text(), 'All Text')]")
    field_search_opt.click()
    
    # 2: dates
    val_search = browser.find_element_by_id('edit-val-base-1')
    val_search.send_keys('after 12/01/2020')

    # 3: dates
    button_plus = browser.find_element_by_id('addTriplet')
    button_plus.click()
    val_search = browser.find_element_by_id('edit-val-base-2')
    val_search.send_keys('before 01/07/2021')
    field_search = browser.find_element_by_id('edit-fld-base-2')
    field_search_opt = field_search.find_element_by_xpath(".//*[contains(text(), 'Date(s)')]")
    field_search_opt.click()

    # restrict region
    button_us = browser.find_element_by_id('presearch-map__list-check-7')
    button_us.click()

    # search
    button_sub = browser.find_element_by_id('edit-submit')
    button_sub.click()

    # adjust source type to newspaper and online news
    button = browser.find_element_by_id('source-type-modal-open')
    button.click()
    time.sleep(1)
    button = browser.find_element_by_id('nbcore-react-browse-table-pane-source-type-filter-modal-check-6') # newspaper
    button.click()
    button = browser.find_element_by_id('nbcore-react-browse-table-pane-source-type-filter-modal-check-10') # web-only source
    button.click()
    button = browser.find_elements_by_css_selector('#nbcore-react-browse-table-pane-source-type-filter-modal-selected-list > button') # apply
    button[0].click() #apply

    # narrow down location
    button = browser.find_element_by_xpath(".//*[contains(text(), 'Source location')]") # unselect latest year (added by default)
    button.click()
    button = browser.find_elements_by_css_selector('ul > li.navigator__item.navigator__item--usa > a')
    button[0].click()

    total_hits = browser.find_element_by_class_name('search-hits__meta').text
    total_hits = total_hits.replace(' Results', '')
    total_hits = int(re.sub(",", "", total_hits))

    # with open('large2.csv', 'w') as f1:
    #     writer=csv.writer(f1, delimiter='\t',lineterminator='\n',)
    #     writer.writerow(['date', 'source', 'location', 'headline', 'href', 'type'])

    for i in tqdm(range(1, total_hits, 20)):

        try:
            # parse html of page

            html = browser.page_source
            html = soup(html, 'html.parser')
            mydivs = html.find_all("article")
            for j in range(0,len(mydivs)-1):
                article = mydivs[j]
                
                # date
                myli = article.find('li', {"class" : "search-hits__hit__meta__item search-hits__hit__meta__item--display-date"})
                date = myli.text.replace('\n', '').strip()

                # source and location
                myli = article.find('li', {"class" : "search-hits__hit__meta__item search-hits__hit__meta__item--source"})
                paper = myli.text.replace('\n', '').strip()
                location = paper[paper.find("(")+1:paper.find(")")]
                source = paper[0:paper.find("(")].strip()

                # href
                href = article.find('a', href = True)['href']

                # headline
                title = article.find('input')['data-title']

                # type
                type = article.find('div', {"class" : "search-hits__hit--type"})['class'][1]
                if 'web-only-source' in type: 
                    type = 'W'
                else:
                    type = 'N'
                
                with open('large.csv', 'a') as f1:
                    writer=csv.writer(f1, delimiter='\t',lineterminator='\n',)
                    writer.writerow([date, source, location, title, href, type])

            # move to next page
            button = browser.find_elements_by_css_selector('li.pager__item.pager__item--next')

            button[0].click()

            time.sleep(max(0,random.normal(1,0.2))) # sleep for random length to avoid detection

            if (abs(random.normal(0,1)) > 1.90): # sleep longer every now and then
                time.sleep(max(random.normal(5,2),0))
        except TimeoutException:
            print("Loading took too much time")
            time.sleep(max(random.normal(5,2),0))
            browser.refresh()
            pass
        except:
            print("Some exception")
            browser.refresh()
            time.sleep(max(random.normal(5,2),0))
            pass

                






