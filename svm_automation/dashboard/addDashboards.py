from util.conf import selenium_webdriver
from util.login import element_value_login
from selenium_elements.selenum_fetchelement import Element
from util.conf import AddDashboard
from util.conf import Dashboard
import time
from selenium.common.exceptions import NoSuchElementException

#each widget in the dashbord is written as def function so wheneven any function is called particular widget will be created

class adddashboard:

    def test_add_advisories(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_xpath(launch_driver, AddDashboard.ctrl_advisories).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element advisories not found")


    def test_add_devices(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_devices).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element devices not found")

    def test_add_device_status(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_device_status).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element device status not found")

    def test_add_devices_status_time(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_devices_status_time).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element device status time not found")

    def test_add_latest_advisories_affecting_your_security(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_latest_advisories_affecting_your_security).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element latest advisories affecting your security not found")

    def test_add_latest_advisories(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_latest_advisories).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element latest advisories not found")

    def test_add_latest_advisories_per_watch_list(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_latest_advisories_per_watchList).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element latest advisories per watch not found")

    def test_add_latest_available_patches(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_latest_available_patches).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element latest available patches not found")

    def test_add_most_critical_advisories(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_most_critical_advisories).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element critical advisories not found")

    def test_add_most_prevalent_EOL_software_installations(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_most_prevalent_EOL_software_Installations).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element most prevalent EOL software installationsnot found")

    def test_add_most_prevalent_insecure_software_installtions(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_most_prevalent_insecure_software_installtions).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element not found")

    def test_add_opened_tickets_pattern(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_opened_tickets_pattern).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element not found")

    def test_add_open_tickets_split(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_open_tickets_split).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element not found")

    def test_add_tickets_split_by_status(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_tickets_split_by_status).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element not found")

    def test_add_your_latest_assigned_tickets(self):
        launch_driver = selenium_webdriver.driver
        time.sleep(10)
        try:
            Element.fetch_element_by_class(launch_driver, AddDashboard.ctrl_add_class).click()
            Element.fetch_element_by_partial_linktext(launch_driver, AddDashboard.ctrl_your_latest_assigned_tickets).click()
            Element.fetch_element_by_xpath(launch_driver, Dashboard.ctrl_save_button).click()
        except NoSuchElementException:
            print("element not found")





