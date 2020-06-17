from src.Features.Patching.Patching_page import PatchingPage

class Templates(PatchingPage):
    def __init__(self):
        super().__init__()
        self.templates_page = PatchingPage()
        templates = self.templates_page.templates_menu_page().click()

    def search(self):
        search = self.templates_page.templates_search_result()
        search_result_text = search.text
        return search_result_text
