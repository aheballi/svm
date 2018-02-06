#from django.test import TestCase

# Create your tests here.
#import os
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

#os.environ["PATH"] += "/home/anusha/SVM/geckodriver/geckodriver"
driver = webdriver.Firefox(executable_path=r'/home/preeti-automation-ubuntu/django-fundamentals-course/svm_automation/django-first-sample/svm_automation/geckodriver')
driver.get("https://uat.app.flexerasoftware.com/login/")
elem = driver.find_element_by_id("inputEmail")
elem.send_keys("PDhillon")
elem = driver.find_element_by_id("inputPassword")
elem.send_keys("Ricky@23")
elem = driver.find_element_by_id("submit-btn").click()

    
