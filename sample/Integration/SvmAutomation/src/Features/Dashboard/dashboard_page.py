from src.utils.SeleniumWebdriver import SeleniumWebdriver
from src.utils.Selenium_fetch_elements import Element
from configparser import ConfigParser
import os
import xml.etree.ElementTree as ET
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By


class DashboardPage():
    def __init__(self):
        self.driver = SeleniumWebdriver.driver
        config = ConfigParser()
        config.read(r'/home/qa-master/SVM/Integration/SvmAutomation/src/Config File/pathFile.properties')
        config.sections()
        self.details_dict = dict(config.items('dev'))
        file = self.details_dict.get('dashboard')
        os.chdir(file)
        tree = ET.parse('dashboard_elements.xml')
        root = tree.getroot()
        self.field = root.findall('Field')
        self.delay = 60
        self.wait = WebDriverWait(self.driver, self.delay)

    def dashboard_app(self):
        dashboard_app_file = self.field[0].text
        dashboard_app = self.wait.until(EC.presence_of_element_located((By.XPATH,dashboard_app_file)))
        return dashboard_app

    def add_button(self):
        add_button_from_file = self.field[3].text
        add_button_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,add_button_from_file)))
        return add_button_ui

    def save_button(self):
        save_button_from_file = self.field[8].text
        save_button_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,save_button_from_file)))
        return save_button_ui

    def remove_gadgets(self):
        remove_gadgets_file = self.field[1].text
        remove_gadget = Element.fetch_element_by_class(self.driver,remove_gadgets_file)
        return remove_gadget

    def get_available_gadgets(self):
        add_gadgets_file = self.field[3].text
        add_gadgets = Element.fetch_element_by_xpath(self.driver,add_gadgets_file)
        return add_gadgets

    def advisories_released_last_year(self):
        advisories_released_last_year_from_file = self.field[6].text
        advisories_released_last_year_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,advisories_released_last_year_from_file)))
        return advisories_released_last_year_ui

    def devices_overview(self):
        devices_overview_from_file =  self.field[7].text
        devices_overview_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,devices_overview_from_file)))
        return devices_overview_ui

    def devices_status_system_score(self):
        devices_status_system_score_from_file = self.field[9].text
        devices_status_system_score_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,devices_status_system_score_from_file)))
        return devices_status_system_score_ui

    def devices_status_time_since_last_scan(self):
        devices_status_time_since_last_scan_from_file = self.field[10].text
        devices_status_time_since_last_scan_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,devices_status_time_since_last_scan_from_file)))
        return devices_status_time_since_last_scan_ui

    def latest_advisories_affecting_your_security(self):
        latest_advisories_affecting_your_security_from_file = self.field[11].text
        latest_advisories_affecting_your_security_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,latest_advisories_affecting_your_security_from_file)))
        return latest_advisories_affecting_your_security_ui

    def latest_advisories(self):
        latest_advisories_from_file = self.field[12].text
        latest_advisories_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,latest_advisories_from_file)))
        return latest_advisories_ui

    def latest_advisories_per_watch_list(self):
        latest_advisories_per_watch_list_from_file = self.field[13].text
        latest_advisories_per_watch_list_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,latest_advisories_per_watch_list_from_file)))
        return latest_advisories_per_watch_list_ui

    def latest_available_patches(self):
        latest_available_patches_from_file = self.field[14].text
        latest_available_patches_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,latest_available_patches_from_file)))
        return latest_available_patches_ui

    def most_critical_advisories_affecting_your_security(self):
        most_critical_advisories_affecting_your_security_from_file = self.field[15].text
        most_critical_advisories_affecting_your_security_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,most_critical_advisories_affecting_your_security_from_file)))
        return most_critical_advisories_affecting_your_security_ui

    def most_prevalent_EOL_software_installtions(self):
        most_prevalent_from_file = self.field[16].text
        most_prevalent_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,most_prevalent_from_file)))
        return most_prevalent_ui

    def most_prevalent_insecure_software_installtions(self):
        most_prevalent_insecure_from_file = self.field[17].text
        most_prevalent_insecure_ui = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT,most_prevalent_insecure_from_file)))
        return most_prevalent_insecure_ui