from src.Features.Patching.Patching_page import PatchingPage
import time


class Packages(PatchingPage):
    def __init__(self):
        super().__init__()
        self.patching_page = PatchingPage()
        self.patching_page.packages_select().click()

    def search(self):
        search_result = self.patching_page.packages_search_result_element()
        search_result_text = search_result.text
        return search_result_text

    def create_deployment(self):
        time.sleep(2)
        self.patching_page.packages_search_result_element().click()
        time.sleep(2)
        self.patching_page.create_deployment_button().click()
        time.sleep(2)
        self.patching_page.select_server().click()
        time.sleep(2)
        self.patching_page.ok_button().click()