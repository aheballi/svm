
import  time
from util.login import login1
from util.conf import selenium_webdriver
from util.conf import element_value_features
from util.conf import Dashboard
from selenium_elements.selenum_fetchelement import Element
from stat import *
import os,sys

class Login():

    def feature_DashboardClick(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelement(new_driver, Dashboard.ctrl_Dashboard).click()

    def feature_VulnerabilityClick(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelementbypartiallinktext(new_driver, element_value_features.ctrlvulnerability).click()

    def feature_settingsclick(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelement(new_driver, element_value_features.ctrlSettings).click()

    def click_onassessmentinside_settings(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelement(new_driver, element_value_features.ctrlAssessment).click()

    def click_on_downloads(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelementbyxpath(new_driver, element_value_features.ctrlDownloads).click()

    def click_on_svmscan(self):
        test = '/home/preeti-automation-ubuntu/django-fundamentals-course/Downloads/*'
        os.system('rm ' + test)
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelementbyxpath(new_driver, element_value_features.ctrlsvmscan).click()
        mode = os.stat('/home/preeti-automation-ubuntu/django-fundamentals-course/Downloads')[ST_MODE]
        file1 = os.stat('/home/preeti-automation-ubuntu/django-fundamentals-course/Downloads/SVMScan.exe')[ST_MODE]
        if S_ISDIR(mode):
            print("/home/preeti-automation-ubuntu/django-fundamentals-course/Downloads a directory")
            if (S_ISREG(file1)):
                print("SVMScan.exe is present")
                print("Last modified : %s" % time.ctime(os.path.getmtime(
                    '/home/preeti-automation-ubuntu/django-fundamentals-course/Downloads/SVMScan.exe')))
                print("Created: %s" % time.ctime(os.path.getctime(
                    '/home/preeti-automation-ubuntu/django-fundamentals-course/Downloads/SVMScan.exe')))
                size = os.stat('/home/preeti-automation-ubuntu/django-fundamentals-course/Downloads/SVMScan.exe')[
                    ST_SIZE]
                if size > 0:
                    print(size, "KB")
                    permission = oct(file1)[-3:]
                    print("permission are ", permission)
            else:
                print("SVMScan.exe doesnot exits\n")
                sys.exit()
        elif S_ISREG(mode):
            print("Its a file\n")
        else:
            print("unknown file\n")

if __name__ == "__main__":
    Login().feature_DashboardClick()
    Login().feature_VulnerabilityClick()
    Login().feature_settingsclick()
    Login().click_onassessmentinside_settings()
    Login().click_on_downloads()
    Login().click_on_svmscan()
    