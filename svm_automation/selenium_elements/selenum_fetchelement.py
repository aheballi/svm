from selenium import webdriver
from selenium.webdriver.common.keys import Keys

from util.conf import selenium_webdriver

class Element:

    def fetchelement(driver, element):
        return selenium_webdriver.driver.find_element_by_id(element)

    def fetchelementbyclass(driver, element):
        return selenium_webdriver.driver.find_element_by_class_name(element)

    def fetchelementbycss(driver, element):
        return selenium_webdriver.driver.find_element_by_css_selector(element)

    def fetchelementblinktext(driver, element):
        return selenium_webdriver.driver.find_element_by_link_text(element)

    def fetchelementbyname(driver, element):
        return selenium_webdriver.driver.find_element_by_name(element)

    def fetchelementbypartiallinktext(driver, element):
        return selenium_webdriver.driver.find_element_by_partial_link_text(element)

    def fetchelementbytagname(driver, element):
        return selenium_webdriver.driver.find_element_by_tag_name(element)

    def fetchelementbyxpath(driver, element):
        return selenium_webdriver.driver.find_element_by_xpath(element)



