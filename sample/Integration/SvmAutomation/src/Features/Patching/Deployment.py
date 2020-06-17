from src.Features.Patching.Patching_page import PatchingPage


class Deployment(PatchingPage):
    def __init__(self):
        super().__init__()
        self.deployment = PatchingPage()
        self.deployment.deployment_menu().click()

    def search(self):
        status_text = self.deployment.deployment_status()
        status = status_text.text
        print(status)
        return status