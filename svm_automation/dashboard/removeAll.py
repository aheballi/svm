from selenium import webdriver
from util.conf import selenium_webdriver
from util.login import element_value_login
from util.conf import Dashboard
from selenium_elements.selenum_fetchelement import Element
import time
# import js2py (js2py is used to import or write the code in javascript format

class removeAllDashboard:
        #this function removes all the available widgets from dashbord page
        def test_remove(self):
                launch_driver = selenium_webdriver.driver
                time.sleep(10)
                element1 = Element.fetch_elements_by_classname(launch_driver, Dashboard.ctrl_classname)
                print (len(element1))
                for x in range(0, len(element1)):
                        if element1[x].is_displayed():
                                element1[x].click()
                time.sleep(10)
                Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()






