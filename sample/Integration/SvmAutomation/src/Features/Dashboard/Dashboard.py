from src.Features.Dashboard.dashboard_page import DashboardPage
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from src.utils.Selenium_fetch_elements import Element
import time

class Dashboard(DashboardPage):
    def __init__(self):
        super().__init__()
        self.dashboard = DashboardPage()
        # self.dashboard.dashboard_app().click()

    def add_dropdown(self):
        self.dashboard.add_button().click()

    def add_widget(self,partial_link_text):
        # global widget
        widget = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT, partial_link_text)))
        widget.click()
        save_button = self.dashboard.save_button().click()

    def remove_widget(self, partial_link_text):
        # widget = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT, partial_link_text)))
        # widget.click()
        self.dashboard.remove_gadgets().click()


    def add_all_widgets(self):
        widgets = ["Devices status - System score","Latest available patches"]

        for widget in widgets:
            print(widget)
            time.sleep(5)
            self.dashboard.add_button().click()
            time.sleep(5)
            element = self.wait.until(EC.presence_of_element_located((By.PARTIAL_LINK_TEXT, widget)))
            element.click()
            time.sleep(5)
            self.dashboard.save_button().click()


    def remove_all_widgets(self):
        remove_gadgets_file = self.field[1].text
        element1 = Element.fetch_elements_by_classname(self.driver,remove_gadgets_file)
        print(len(element1))
        time.sleep(2)
        for x in range(0, len(element1)):
            if element1[x].is_displayed():
                element1[x].click()
        time.sleep(10)
        self.dashboard.save_button().click()
        # self.dashboard.remove_gadgets().click()