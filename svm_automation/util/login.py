# import pickle
# from selenium import webdriver
# from selenium.webdriver.common.keys import Keys
# import time

from util.conf import credentials
from util.conf import selenium_webdriver
from util.conf import UiLogin
from selenium_elements.selenum_fetchelement import Element

class login1():
    launch_driver = selenium_webdriver.driver
    launch_driver.get(credentials.url)
    Element.fetchelement(launch_driver, UiLogin.ctrlLogin).send_keys(credentials.user_name)
    Element.fetchelement(launch_driver, UiLogin.ctrlPassword).send_keys(credentials.password)
    Element.fetchelement(launch_driver, UiLogin.btnSubmit).click()





