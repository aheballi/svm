from src.Features.Patching.Patching_page import PatchingPage
import time
import datetime


class PatchLibrary(PatchingPage):
    def __init__(self):
        super().__init__()
        # self.driver = SeleniumWebdriver.driver
        self.patching_element = PatchingPage()
        self.patching_element.patching_app().click()
        # config = ConfigParser()
        # config.read(r'/home/anusha/Pycharm_pytest/'
        #             r'PycharmProjects/pytest/src/Config File/pathFile.properties')
        # config.sections()
        # self.details_dict = dict(config.items('dev'))
        # file = self.details_dict.get('patching')
        # os.chdir(file)
        # tree = ET.parse('patching_elements.xml')
        # root = tree.getroot()
        # self.field = root.findall('Field')


    # def login_new(self):
    #     LoginPage().launch_url()
    #     login().valid_user_password()

    def search(self,search_string):
        url = self.driver.current_url
        print(url)

        if url == "https://uat.app.flexerasoftware.com/#/patching/profiles/":
            self.patching_element.templates_filter_button().click()
            time.sleep(2)
            self.patching_element.templates_search().send_keys(search_string)
            time.sleep(2)
            self.patching_element.templates_apply_button().click()

        elif url == "https://uat.app.flexerasoftware.com/#/patching/grouped-products/":
            time.sleep(3)
            self.patching_element.patching_filter_button_method().click()
            time.sleep(2)
            self.patching_element.reset_button().click()
            time.sleep(3)
            self.patching_element.product_search().send_keys(search_string)
            self.patching_element.apply_button().click()
            # print("no element")

        elif url == "https://uat.app.flexerasoftware.com/#/patching/packages/":
            self.patching_element.patching_filter_button_method().click()
            time.sleep(2)
            self.patching_element.packages_search().send_keys(search_string)
            time.sleep(2)
            self.patching_element.packages_apply_button().click()

        elif url ==  "https://uat.app.flexerasoftware.com/#/patching/deployment/":
            self.patching_element.deployment_filter_button().click()
            self.patching_element.deployment_search_element().send_keys(search_string)
            self.patching_element.deployment_apply().click()

        else:
            print("None of the patching page urls are matching")

    def create_template(self):
        time_stamp = str(datetime.datetime.now())
        print(type(time_stamp))
        print(time_stamp)
        self.patching_element.search_result().click()
        time.sleep(2)
        self.patching_element.create_template_button().click()
        time.sleep(2)
        # global template_name
        template = self.patching_element.name_for_template()
        template.send_keys("_Automation" + " " + time_stamp)
        template_name = template.get_attribute('value')
        time.sleep(2)
        self.patching_element.save_button_template().click()
        return template_name

    def build_packages(self,search_string,template_name):
        self.patching_element.reset_button().click()
        time.sleep(3)
        self.patching_element.product_search().send_keys(search_string)
        self.patching_element.apply_button().click()
        time.sleep(3)
        self.patching_element.search_result().click()
        time.sleep(2)
        self.patching_element.build_packages_button().click()
        time.sleep(5)
        self.patching_element.build_packages_name().send_keys(template_name)
        time.sleep(5)
        self.patching_element.select_template_build_package().click()
        time.sleep(5)
        self.patching_element.templates_to_be_selected(template_name).click()
        time.sleep(5)
        self.patching_element.templates_deselect().click()
        time.sleep(5)
        self.patching_element.templates_build_button().click()

    def filter(self,filter_name):
        time_stamp = str(datetime.datetime.now())
        print(type(time_stamp))
        print(time_stamp)
        self.patching_element.filter_save().click()
        time.sleep(5)
        self.patching_element.filter_name().send_keys(filter_name + " " + time_stamp)
        time.sleep(3)
        self.patching_element.filter_save_button().click()
































































if __name__ == '__main__':
    PythonTest().login_new()