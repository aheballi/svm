from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By


#user having administrator role
class credentials:
    url = "https://uat.app.flexerasoftware.com/login"
    user_name = "PDhillon"
    password = "Ricky@23"


# user having advisory reader role

class credentials_role:
    url = "https://uat.app.flexerasoftware.com/login"
    user_name = "Preeti011"
    password = "Ricky@01"


# launching the Browser
class selenium_webdriver:
    fp = webdriver.FirefoxProfile()
    fp.set_preference("browser.download.folderList", 2)
    fp.set_preference("browser.helperApps.neverAsk.saveToDisk", 'application/octet-stream')
    fp.set_preference("browser.download.dir", '/home/anusha/svm_automationproject/django-project/Downloads/')
    driver = webdriver.Firefox(executable_path=r'/home/anusha/svm_automationproject/django-project/svm_automation/geckodriver',firefox_profile=fp)

#class explict_wait():
#    new_driver1= selenium_webdriver.driver
#    wait = WebDriverWait(new_driver1,10)
#   element = wait.until(EC.presence_of_all_elements_located((By.CLASS_NAME,"myDynamicClass")))
#    element1= wait.until(EC.presence_of_all_elements_located((By.ID,"myDynamicID")))
#    element2 = wait.until(EC.presence_of_all_elements_located((By.CSS_SELECTOR,"myCssSelector")))
#    element3 = wait.until(EC.presence_of_all_elements_located((By.LINK_TEXT,"myLinktEXT")))
#   element4 = wait.until(EC.presence_of_all_elements_located((By.NAME,"byName")))
#    element5 = wait.until(EC.presence_of_all_elements_located((By.PARTIAL_LINK_TEXT,"MyPartialLinkText")))
#   element6 = wait.until(EC.presence_of_all_elements_located((By.TAG_NAME,"MyTagName")))
#    element7 = wait.until(EC.presence_of_all_elements_located((By.XPATH,"MyXpath")))


# element to login to UI with administrator credentilas
class UiLogin:
    ctrlLogin = "inputEmail"
    ctrlPassword = "inputPassword"
    btnSubmit = "submit-btn"

class UserProfileandSignOut:
    btnUserProfileandSignout = ".//*[@id='power']"
    ctrlsignout = "Sign Out"

class Dashboard:
    ctrl_classname = "glyphicon-remove"
    ctrl_save_button = "//div[1]/button/span[text()='Save']"
    ctrl_Dashboard = "link_notifications"


class AddDashboard:
    ctrl_add_class = "glyphicons-plus"
    ctrl_advisories = "//div/div/ul/li[1]/a[text()='Advisories realsed last year']"
    ctrl_devices = "Devices Overview"
    ctrl_device_status = "Devices staus -time since last scan"
    ctrl_device_status_time = "Devices status - Time since last scan"
    ctrl_latest_advisories_affecting_your_security = "Latest advisories affecting your security"
    ctrl_latest_advisories = "Latest advisories"
    ctrl_latest_advisories_per_watch_list = "Latest advisories per watch list"
    ctrl_latest_available_patches = "Latest available patches"
    ctrl_most_critical_advisories = "Most critical advisories affecting your security"
    ctrl_most_prevalent_EOL_software_installations = "Most prevlant EOL software installations"
    ctrl_most_prevalent_insecure_software_installations = "Most prevlant insecure software installations"
    ctrl_opened_tickets_pattern = "Opened tickets pattern"
    ctrl_open_tickets_split = "Open tickets split by advisory criticality"
    ctrl_open_tickets_split_by_status = "Tickets split by status"
    ctrl_your_latest_assigned_tickets = "Your latest assigned tickets"


# element to login to UI with advisory reader role credentilas

class UiLoginBasedOnRole():
    ctrlLogin_role = "inputEmail"
    ctrlPassword_role = "inputPassword"
    btnSubmit_role = "submit-btn"
    ctrlDeletewidgets = "text-danger pull-right btnNOBg"
    ctrlFilter = ".//*[@id='content]/div/div[1]/div[2]/div/button"


class NotificationCenter():
    ctrlnotificationcenter = "Notification Center"
    ctrlFilter = ".//*[@id='content']/div/div[1]/div[2]/div/button"
    ctrlfilterclick = "collapse in"
    ctrlCrticality = ".//*[@id='content']/div/div[2]/div/div/div/div[1]"
    ctrlFrom = ".//*[@id='content']/div/div[2]/div/div/div/div[2]/div/div/div/div[1]/input"
    ctrlTo = ".//*[@id='content']/div/div[2]/div/div/div/div[3]/div/div/div/div[1]/input"
    ctrlType = ".//*[@id='content']/div/div[2]/div/div/div/div[4]"
    ctrlStatus = ".//*[@id='content']/div/div[2]/div/div/div/div[5]"
    ctrlSearchByKeyword = ".//*[@id='content']/div/div[2]/div/div/div/div[8]"
    ctrlFilterButton = ".btn-block.btn.btn-sm.btn-primary"
    ctrlReset = ".btn-block.btn.btn-sm.btn-default"
    ctrl_filter_displayed = ".//*[@id='content']/div/div[2]/div/div"
    ctrl_delete_button = ".btnNoBg.notif-icon"
    ctrl_mailunread = ".btnNoBg.notif-icon-unread"
    ctrl_mailread = ".btnNoBg.notif-icon"
    ctrl_select_all_checkbox = ".anohref"
    ctrl_Actions = "#notif_actions"
    ctrl_MarkAsRead = "Mark as Read"
    ctrl_MarkAsUnread = "Mark as Unread"
    ctrl_Delete = "Delete"
    ctrl_information = ".//*[@id='content']/div/div[1]/div[1]"


class VulnerabilityManager():
    ctrlvulnerability = "Vulnerability Manager"


class Settings():
    ctrlSettings = "link_settings"
    ctrlAssessment = "navdd_settings:env"
    ctrlDownloads = ".//*[@id='header']/div/ul/li[5]/ul/li[3]/a"
    ctrlsvmscan = "//*[@id='content']/div/div[1]/div[2]/a"

class Patching():
    ctrlPatching = "Patching"

class Assessment():
    ctrl_assessment ="Assessment"

class PolicyManager():
    ctrl_policymanager = "Policy Manager"

class Analytics():
    ctrl_analytics = "Analytics"

class Auditor():
    ctrl_auditor = "Auditor"

class Research():
    ctrl_research = "Research"
    ctrl_advisorydatabase = "navdd_vt:advisory-database"
    ctrl_advisories= ".//*[@id='header']/div/ul/li[1]/ul/li/a"
    ctrl_said = ".//*[@id='content']/div/div[2]/div/div/form/div[1]/div[1]/div/div/input"
    ctrl_from = ".//*[@id='content']/div/div[2]/div/div/form/div[1]/div[2]/div/div/div/div[1]/input"
    ctrl_from_calendar = ".//*[@id='content']/div/div[2]/div/div/form/div[1]/div[2]/div/div/div/div[1]/span"
    ctrl_to_calender = ".//*[@id='content']/div/div[2]/div/div/form/div[1]/div[3]/div/div/div/div[1]/span/span"
    ctrl_to = "//*[@id='content']/div/div[2]/div/div/form/div[1]/div[3]/div/div/div/div[1]/input"
    ctrl_criticality = ".//*[@id='content']/div/div[2]/div/div/form/div[1]/div[4]"
    ctrl_zeroday = ".//*[@id='content']/div/div[2]/div/div/form/div[1]/div[5]"
    ctrl_solutionstatus = ".//*[@id='content']/div/div[2]/div/div/form/div[1]/div[6]"
    ctrl_where =".//*[@id='content']/div/div[2]/div/div/form/div[1]/div[7]"
    ctrl_cvss_score_min = ".//*[@id='content']/div/div[2]/div/div/form/div[2]/div[1]/div/div/input"
    ctrl_cvss_score_max = ".//*[@id='content']/div/div[2]/div/div/form/div[2]/div[2]/div/div/input"
    ctrl_advisory_type = ".//*[@id='content']/div/div[2]/div/div/form/div[2]/div[3]"
    ctrl_impact = ".//*[@id='content']/div/div[2]/div/div/form/div[2]/div[4]"
    ctrl_cve = ".//*[@id='content']/div/div[2]/div/div/form/div[2]/div[5]/div/div/input"
    ctrl_filter = ".btn.btn-primary.btn-sm.btn-block"
    ctrl_reset = ".btn-block.btn.btn-sm.btn-default"
    ctrl_search_by_keyword = ".form-control.hasclear.input-sm"
    ctrl_cancel = ".clearer.form-control-feedback.glyphicon.glyphicon-remove"
    ctrl_title = ".//*[@id='content']/div/div[3]/table/tbody/tr[1]/td[4]"
    ctrl_view_advisory = "//li/div/a[text()='View Advisory']"
    ctrl_close_advisory = "html/body/div[2]/div/div[2]/div/div/div[1]/button"
    ctrl_filter_button = "//div/div[1]/div[2]/button/span"
    ctrl_filter_options_are_hidden = "//div/div[2]/div/div"
    ctrl_product_database = "navdd_vt:products-database"

class UserProfile():
    ctrl_usr_profile = "link_profile"
    ctrl_change_password = "Change Password"
    ctrl_change_email = "Change Email"
    ctrl_partiallink_cancel = "/html/body/div[2]/div/div[2]/div/div/div[3]/button[1]"
    ctrl_verify_mobile_number = "Verify phone number"
    ctrl_edit_button_down = "//div/div[7]/button[text()='Edit']"
    ctrl_cancel_option_in_bottom = "//div/div[7]/button[1][text()='Cancel']"
    ctrl_save_option_in_bottom = "//div/div[7]/button[2][text()='Save']"
    ctrl_edit_option_on_top = "//div/div[1]/div/button[text()='Edit']"
    ctrl_cancel_option_on_top = "//div/div[1]/div/button[1][text()='Cancel']"
    ctrl_save_button_on_top ="//div/div[1]/div/button[2][text()='Save']"
    ctrl_title = "not_used"
    ctrl_first_name_textbox = "//div/div[3]/div[3]/div/input"
    ctrl_last_name_textbox = "//div/div[3]/div[4]/div/input"
    ctrl_phone_number = "//div/div[3]/div[6]/div/input"
