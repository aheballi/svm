#from selenium.webdriver.common.keys import Keys
import  time
from util.conf import Dashboard
#from util.conf import selenium_webdriver
from util.conf import NotificationCenter
#from selenium_elements.selenum_fetchelement import Element
#from stat import *
#import os,sys
from util.conf import Auditor
from util.conf import Settings
from util.conf import Assessment
from util.conf import Patching
from util.conf import PolicyManager
from util.conf import Analytics
from util.conf import VulnerabilityManager
from util.conf import Research
from util.conf import selenium_webdriver
from util.conf import credentials_role
from util.conf import UiLoginBasedOnRole
from util.conf import UserProfile
from selenium_elements.selenum_fetchelement import Element


#launch the UI and login with a user having advisory reader role

class TestAdvisoryRole:


    def test_Login(self):
        launch_driver = selenium_webdriver.driver
        launch_driver.get(credentials_role.url)
        Element.fetchelement(launch_driver, UiLoginBasedOnRole.ctrlLogin_role).send_keys(credentials_role.user_name)
        Element.fetchelement(launch_driver, UiLoginBasedOnRole.ctrlPassword_role).send_keys(credentials_role.password)
        Element.fetchelement(launch_driver, UiLoginBasedOnRole.btnSubmit_role).click()

    def test_featureClick(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelement(new_driver, Dashboard.ctrl_Dashboard).click()
        # Element.fetchelementbydef(new_driver,element_value_login_role.ctrldeletewidgets).click()

    def test_featurenotificationcenter(self):
        new_driver = selenium_webdriver.driver
        Element.fetchelementbypartiallinktext(new_driver, NotificationCenter.ctrlnotificationcenter).click()
        time.sleep(5)
        var = Element.fetchelementbyxpath(new_driver, NotificationCenter.ctrl_information).is_displayed()
        print (var)
        if((Element.fetchelementbyxpath(new_driver,NotificationCenter.ctrl_information).is_displayed()) == True):
            print("no notications are present so to exit the page")
            return
        else:
            Element.fetchelementbyxpath(new_driver, NotificationCenter.ctrlFilter).click()
            if (Element.fetchelementbyxpath(new_driver, NotificationCenter.ctrl_filter_displayed).is_displayed()):
                print("Filter is visible")
                try:
                    Element.fetchelementbyxpath(new_driver, NotificationCenter.ctrlCrticality).click()
                    print("Criticality dropbox is found")
                except:
                    print("Criticality dropbox not found")
                try:
                    Element.fetchelementbyxpath(new_driver, NotificationCenter.ctrlFrom).click()
                    print("From Dropbox is found")
                except:
                    print("From Dropbox not found")
                try:
                    Element.fetchelementbyxpath(new_driver, NotificationCenter.ctrlTo).click()
                    print("TO Dropbox is found")
                except:
                    print("TO Dropbox not found")
                try:
                    Element.fetchelementbyxpath(new_driver, NotificationCenter.ctrlType).click()
                    print("Type groupbox is found")
                except:
                    print("Type groupbox not found")
                try:
                    Element.fetchelementbyxpath(new_driver, NotificationCenter.ctrlStatus).click()
                    print("Status Dropbox is found")
                except:
                    print("Status Dropbox not found")
                try:
                    Element.fetchelementbyxpath(new_driver, NotificationCenter.ctrlSearchByKeyword).click()
                    print("Search by Keyboard textbox is found")
                except:
                    print("Search by Keyboard textbox not found")
                try:
                    Element.fetchelementbycss(new_driver, NotificationCenter.ctrlFilterButton).click()
                    print("Filter button is found")
                except:
                    print("Filter button not found")
                try:
                    Element.fetchelementbycss(new_driver, NotificationCenter.ctrlReset).click()
                    print("Reset button is found")
                except:
                    print("Reset button not found")
            else:
                print("Filter is disabled")
        Element.fetchelementbycss(new_driver, NotificationCenter.ctrl_delete_button).click()
        if (Element.fetchelementbycss(new_driver, NotificationCenter.ctrl_mailunread)).click():
            print("mail is not yet read")
        else:
            print("email is read")
        Element.fetchelementbycss(new_driver, NotificationCenter.ctrl_select_all_checkbox).click()
        if (Element.fetchelementbycss(new_driver, NotificationCenter.ctrl_Actions).is_displayed()):
            print("Action button is present")
            Element.fetchelement(new_driver, NotificationCenter.ctrl_Actions).click()
            Element.fetchelementblinktext(new_driver, NotificationCenter.ctrl_MarkAsRead).click()
            print("All the notications as read by user")
            Element.fetchelementblinktext(new_driver, NotificationCenter.ctrl_MarkAsUnread).click()
            print("All the notifcations are unread by user")
            Element.fetchelementblinktext(new_driver, NotificationCenter.ctrl_Delete).click()
            print("All the notifications are deleted")
        else:
            print("Action button is not available")


    def test_researchmodule(self):
        new_driver = selenium_webdriver.driver
        #wait = WebDriverWait(new_driver, 10)
        #self.element1 = None
        #self.element = None
        #self.element = wait.until(EC.presence_of_all_elements_located((By.ID,"myDynamicID")))
        #self.element1 = wait.until(EC.presence_of_all_elements_located(By.PARTIAL_LINK_TEXT,"MyPartialLinkText"))
        time.sleep(10)
        Element.fetchelementbypartiallinktext(new_driver, Research.ctrl_research).click()
        time.sleep(5)
        Element.fetchelement(new_driver , Research.ctrl_advisorydatabase).click()
        Element.fetchelementbyxpath(new_driver, Research.ctrl_advisories).click()
        Element.fetchelementbyxpath(new_driver, Research.ctrl_filter_button).click()
        if(Element.fetchelementbyxpath(new_driver , Research.ctrl_filter_options_are_hidden).is_displayed()):
            print("filter options are hidden")
            Element.fetchelementbyxpath(new_driver, Research.ctrl_filter_button).click()
        else:
            print("Filter options are available")
            Element.fetchelementbyxpath(new_driver, Research.ctrl_filter_button).click()
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_said).send_keys("SA81430")
            print("SAID filter option is working")
        except:
            print("SAID filter optio is not working")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_from).send_keys("2018-01-01")
            print("From date is working")
        except:
            print("From date is not working as expected")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_to).send_keys("2018-12-31")
            print("To date is working")
        except:
            print("To date is not working as expected")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_criticality).click()
            print("From date is working")
        except:
            print("Criticality option is not working as expected")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_zeroday).click()
            print("Zero Day option is working")
        except:
            print("ZeroDay option is not working as expected")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_solutionstatus).click()
            print("Solutuion status filter option is working")
        except:
            print("Solutionstatus filter option is not working as expected")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_where).click()
            print("Where filter option is working")
        except:
            print("Where filter option is not working as expected")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_cvss_score_min).send_keys(1)
            print("CVSS Score min filter option is working")
        except:
            print("CVSS Score min filter option is not working as expected")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_cvss_score_max).send_keys(10)
            print("CVSS_score Max filter option is working")
        except:
            print("CVSS score max option is not working as expected")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_advisory_type).click()
            print("advisory filter option is working")
        except:
            print("advisory filter option is not working as expected")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_impact).click()
            print("Zimpact filter option is working")
        except:
            print("impact filter option is not working as expected")
        try:
            Element.fetchelementbyxpath(new_driver, Research.ctrl_cve).send_keys("CVE-2018-1000005")
            print("CVE filter option is working")
        except:
            print("CVE filter option is not working as expected")
        try:
            Element.fetchelementbycss(new_driver, Research.ctrl_filter).click()
            print("Filter option is working")
        except:
            print("Filter option is not working as expected")
        try:
            Element.fetchelementbycss(new_driver, Research.ctrl_reset).click()
        except:
            print("Reset filter option is not working properly")

        time.sleep(10)
        try:
            Element.fetchelementbycss(new_driver,Research.ctrl_search_by_keyword).send_keys("Ubuntu")
            print("Search by keyword button is working")
        except:
            print("Search by Keyword textbox is not working")
        time.sleep(10)
        Element.fetchelementbycss(new_driver,Research.ctrl_cancel).click()
        time.sleep(10)
        Element.fetchelementbyxpath(new_driver,Research.ctrl_title).click()
        time.sleep(5)
        Element.fetchelementbyxpath(new_driver,Research.ctrl_view_advisory).click()
        time.sleep(5)
        Element.fetchelementbyxpath(new_driver,Research.ctrl_close_advisory).click()

    def test_productbatabase(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        if(Element.fetchelement(new_driver , Research.ctrl_product_database).click()):
            print("Prodcuts should not be clickable issue raised SVM-453:failed")
        else:
            print("Product database is disabled cannot be clicked on:success")

    def test_modulearedisabled(self):
         new_driver = selenium_webdriver.driver
         time.sleep(10)
         if(Element.fetchelementbypartiallinktext(new_driver , VulnerabilityManager.ctrlvulnerability).click()):
             print("Vulnerabity Manager is enabled so script failed")
         else:
             print("Vulnerablity Manager is disabled:Success")
         if (Element.fetchelementbypartiallinktext(new_driver, Assessment.ctrl_assessment).click()):
             print("Assessment is enabled so script failed")
         else:
             print("Assessment is disabled:Success")
         if (Element.fetchelementbypartiallinktext(new_driver, Patching.ctrlPatching).click()):
             print("Patching is enabled so script failed")
         else:
             print("Patching is disabled:Success")
         if (Element.fetchelementbypartiallinktext(new_driver, Analytics.ctrl_analytics).click()):
             print("Analytics is enabled so script failed")
         else:
             print("Analytics is disabled:Success")
         if(Element.fetchelementbypartiallinktext(new_driver , Auditor.ctrl_auditor).click()):
             print("Auditor is enabled so script failed")
         else:
             print("Auditor is disabled:Success")
         if(Element.fetchelementbypartiallinktext(new_driver , PolicyManager.ctrl_policymanager).click()):
             print("Policy Manager is enabled so script failed")
         else:
             print("Policy Manager is disabled:Success")
         if(Element.fetchelement(new_driver , Settings.ctrlSettings).click()):
             print("Settings is enabled so script failed")
         else:
             print("Settings is disabled:Success")

    def test_userprofile(self):
        new_driver = selenium_webdriver.driver
        time.sleep(10)
        Element.fetchelement(new_driver,UserProfile.ctrl_usr_profile).click()
        time.sleep(5)
        Element.fetchelementbypartiallinktext(new_driver,UserProfile.ctrl_change_password).click()
        time.sleep(5)
        Element.fetchelementbyxpath(new_driver, UserProfile.ctrl_partiallink_cancel).click()
        time.sleep(5)
        Element.fetchelementbypartiallinktext(new_driver,UserProfile.ctrl_change_email).click()
        time.sleep(5)
        Element.fetchelementbyxpath(new_driver, UserProfile.ctrl_partiallink_cancel).click()
        time.sleep(5)
        Element.fetchelementbypartiallinktext(new_driver,UserProfile.ctrl_verify_mobile_number).click()
        time.sleep(5)
        Element.fetchelementbyxpath(new_driver, UserProfile.ctrl_partiallink_cancel).click()
        time.sleep(5)
        Element.fetchelementbyxpath(new_driver, UserProfile.ctrl_edit_option_on_top).click()
        Element.fetchelementbyxpath(new_driver,UserProfile.ctrl_cancel_option_on_top).click()
        Element.fetchelementbyxpath(new_driver, UserProfile.ctrl_edit_option_on_top).click()
        Element.fetchelementbyxpath(new_driver, UserProfile.ctrl_save_button_on_top).click()
        time.sleep(10)
        #Element.fetchelementbyxpath(new_driver,UserProfile.ctrl_edit_button_down).click()
        #Element.fetchelementbyxpath(new_driver, UserProfile.ctrl_cancel_option_in_bottom).click()
        #Element.fetchelementbyxpath(new_driver, UserProfile.ctrl_edit_button_down).click()
        #Element.fetchelementbyxpath(new_driver, UserProfile.ctrl_save_option_in_bottom).click()


# if __name__ == '__main__':
#       AdvisoryRole().test_login()
#       AdvisoryRole().test_featureClick()
#     AdvisoryRole().feature_notificationcenter()
#     AdvisoryRole().Research_module()
#     AdvisoryRole().ProductDatabase()
#     AdvisoryRole().module_are_disabled()
#     AdvisoryRole().User_Profile()