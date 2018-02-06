import  time
#from util.login import login1
from util.conf import selenium_webdriver
from util.conf import VulnerabilityManager
from util.conf import Settings

import os,sys
from util.conf import Dashboard
from selenium_elements.selenum_fetchelement import Element
from stat import *
from util.conf import UserProfileandSignOut

class TestFeatures():

    def testlogin(self):
        from util.login import login1
        obj1 = login1()

    def testfeatureDashboardClick(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelement(new_driver, Dashboard.ctrl_Dashboard).click()

    def testfeatureVulnerabilityClick(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelementbypartiallinktext(new_driver, VulnerabilityManager.ctrlvulnerability).click()

    def testfeatureSettingsClick(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelement(new_driver, Settings.ctrlSettings).click()

    def testClickOnAssessmentInSideSettings(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelement(new_driver, Settings.ctrlAssessment).click()

    def testClickOnDownloads(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelementbyxpath(new_driver, Settings.ctrlDownloads).click()

    def testClickOnSvmScan(self):
        test = '/home/preeti-automation-ubuntu/django-project/Downloads/*'
        os.system('rm ' + test)
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelementbyxpath(new_driver, Settings.ctrlsvmscan).click()
        mode = os.stat('/home/preeti-automation-ubuntu/django-project/Downloads')[ST_MODE]
        file1 = os.stat('/home/preeti-automation-ubuntu/django-project/Downloads/SVMScan.exe')[ST_MODE]
        if S_ISDIR(mode):
            print("/home/preeti-automation-ubuntu/django-project/Downloads a directory")
            if (S_ISREG(file1)):
                print("SVMScan.exe is present")
                print("Last modified : %s" % time.ctime(os.path.getmtime(
                    '/home/preeti-automation-ubuntu/django-project/Downloads/SVMScan.exe')))
                print("Created: %s" % time.ctime(os.path.getctime(
                    '/home/preeti-automation-ubuntu/django-project/Downloads/SVMScan.exe')))
                size = os.stat('/home/preeti-automation-ubuntu/django-project/Downloads/SVMScan.exe')[
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

    def testlogout(self):
        new_driver =selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelementbyxpath(new_driver, UserProfileandSignOut.btnUserProfileandSignout).click()
        Element.fetchelementbypartiallinktext(new_driver, UserProfileandSignOut.ctrlsignout).click()

#if __name__ == "__main__":
#     TestFeatures().testlogin()
#     TestFeatures().testlogout()
#    Login().feature_DashboardClick()
#    Login().feature_VulnerabilityClick()
#    Login().feature_settingsclick()
#    Login().click_onassessmentinside_settings()
#    Login().click_on_downloads()
#    Login().click_on_svmscan()
    