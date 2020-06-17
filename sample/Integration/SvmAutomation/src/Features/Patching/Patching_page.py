from configparser import ConfigParser
import os
import xml.etree.ElementTree as ET
from src.utils.SeleniumWebdriver import SeleniumWebdriver
from src.utils.Selenium_fetch_elements import Element
import time
from src.Features.Login.test_login_page import LoginPage
from src.Features.Login.login_functionality import login
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.by import By
# from selenium.webdriver.support.ui import Select
# from selenium.common.exceptions import TimeoutException

class PatchingPage():
    def __init__(self):
        self.driver = SeleniumWebdriver.driver
        config = ConfigParser()
        config.read(r'/home/qa-master/SVM/Integration/SvmAutomation/src/Config File/pathFile.properties')
        config.sections()
        self.details_dict = dict(config.items('dev'))
        file = self.details_dict.get('patching')
        os.chdir(file)
        tree = ET.parse('patching_elements.xml')
        root = tree.getroot()
        self.field = root.findall('Field')
        self.delay = 60
        self.wait = WebDriverWait(self.driver,self.delay)

    def patching_app(self):
        patching_app_file = self.field[0].text
        patching_app_ui1 = self.wait.until(EC.presence_of_element_located((By.XPATH,patching_app_file)))
        return patching_app_ui1

    def patching_filter_button_method(self):
        patching_filter_button_from_file = self.field[1].text
        patching_filter_button = self.wait.until(EC.element_to_be_clickable((By.XPATH,patching_filter_button_from_file)))
        return patching_filter_button

    def product_search(self):
        product_search_from_file = self.field[2].text
        product_search_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,product_search_from_file)))
        # product_search_from_ui = Element.fetch_element_by_xpath(self.driver,product_search_from_file)
        return product_search_from_ui

    def apply_button(self):
        apply_button_from_file = self.field[3].text
        apply_button_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,apply_button_from_file)))
        return apply_button_ui

    def search_result(self):
        search_result_field_from_file = self.field[4].text
        search_result_field = self.wait.until(EC.presence_of_element_located((By.XPATH,search_result_field_from_file)))
        return search_result_field

    def create_template_button(self):
        create_template_from_file = self.field[5].text
        create_template_from_ui = self.wait.until(EC.element_to_be_clickable((By.XPATH,create_template_from_file)))
        return create_template_from_ui

    def name_for_template(self):
        name_for_template_from_file = self.field[6].text
        name_for_template_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,name_for_template_from_file)))
        return name_for_template_from_ui

    def save_button_template(self):
        save_button_from_file = self.field[7].text
        save_button_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,save_button_from_file)))
        return save_button_from_ui

    def templates_menu_page(self):
        templates_menu_from_file = self.field[8].text
        menu_text = templates_menu_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,templates_menu_from_file)))
        # print(menu_text)
        return templates_menu_from_ui

    def templates_search(self):
        templates_search_from_file = self.field[9].text
        # templates_search_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,templates_search_from_file)))
        templates_search_from_ui = Element.fetch_element_by_xpath(self.driver,templates_search_from_file)
        return templates_search_from_ui

    def templates_apply_button(self):
        template_apply_button_from_file = self.field[10].text
        templates_apply_button_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,template_apply_button_from_file)))
        return templates_apply_button_from_ui

    def templates_view(self):
        templates_view_button_from_file = self.field[11].text
        templates_view_button_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,templates_view_button_from_file)))
        return templates_view_button_from_ui

    def templates_search_result(self):
        templates_search_result_from_file = self.field[12].text
        templates_search_result_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,templates_search_result_from_file)))
        return templates_search_result_from_ui

    def build_packages_button(self):
        build_packages_from_file = self.field[13].text
        build_packages_from_ui = self.wait.until(EC.element_to_be_clickable((By.XPATH,build_packages_from_file)))
        return build_packages_from_ui

    def reset_button(self):
        reset_button_from_file = self.field[14].text
        reset_button_from_ui = self.wait.until(EC.element_to_be_clickable((By.XPATH,reset_button_from_file)))
        return reset_button_from_ui

    def build_packages_name(self):
        build_packages_name_from_file = self.field[15].text
        build_packages_name_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,build_packages_name_from_file)))
        return build_packages_name_from_ui

    def select_template_build_package(self):
        select_template_from_file = self.field[16].text
        select_templates_from_ui = self.wait.until(EC.element_to_be_clickable((By.XPATH,select_template_from_file)))
        return select_templates_from_ui

    def templates_to_be_selected(self,template_name):
        # templates_to_be_selected_from_file = self.field[17].text
        templates_to_be_selected_from_Ui = self.wait.until(EC.element_to_be_clickable((By.PARTIAL_LINK_TEXT,template_name)))
        return templates_to_be_selected_from_Ui

    def templates_build_button(self):
        templates_build_button_from_file = self.field[18].text
        templates_build_button_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,templates_build_button_from_file)))
        return templates_build_button_from_ui

    def templates_deselect(self):
        templates_deselct_from_file = self.field[17].text
        templates_deselect_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,templates_deselct_from_file)))
        return templates_deselect_from_ui

    def packages_select(self):
        packages_select_from_file = self.field[19].text
        packages_select_from_ui = self.wait.until(EC.element_to_be_clickable((By.XPATH,packages_select_from_file)))
        return packages_select_from_ui

    def packages_search(self):
        packages_search_from_file = self.field[20].text
        packages_search_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,packages_search_from_file)))
        return packages_search_from_ui

    def packages_apply_button(self):
        packages_apply_button_from_file = self.field[21].text
        packages_apply_button_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,packages_apply_button_from_file)))
        return packages_apply_button_from_ui

    def packages_search_result_element(self):
        packages_search_result_from_file = self.field[22].text
        packages_search_result_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,packages_search_result_from_file)))
        return packages_search_result_from_ui

    def create_deployment_button(self):
        create_deploymen_from_file = self.field[23].text
        create_deployment_from_ui = self.wait.until(EC.element_to_be_clickable((By.XPATH,create_deploymen_from_file)))
        return create_deployment_from_ui

    def select_server(self):
        select_server_from_file = self.field[24].text
        select_server_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,select_server_from_file)))
        return select_server_from_ui

    def ok_button(self):
        ok_button_from_file = self.field[25].text
        ok_button_from_ui = self.wait.until(EC.element_to_be_clickable((By.XPATH,ok_button_from_file)))
        return ok_button_from_ui

    def deployment_menu(self):
        deployment_button_from_file = self.field[26].text
        deployment_menu_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,deployment_button_from_file)))
        return deployment_menu_from_ui

    def deployment_search_element(self):
        deployment_search_from_file = self.field[27].text
        deployment_search_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,deployment_search_from_file)))
        return deployment_search_from_ui



    def deployment_apply(self):
        deployment_apply_from_file = self.field[28].text
        deployment_apply_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,deployment_apply_from_file)))
        return deployment_apply_from_ui

    def deployment_filter_button(self):
        deployment_filter_button_from_file = self.field[29].text
        deployment_filter_button_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,deployment_filter_button_from_file)))
        return deployment_filter_button_from_ui

    def deployment_status(self):
        deployment_status_from_file = self.field[30].text
        deployment_status_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,deployment_status_from_file)))
        return deployment_status_from_ui

    def templates_filter_button(self):
        templates_filter_button_from_file = self.field[31].text
        templates_filter_button_from_ui = self.wait.until(EC.element_to_be_clickable((By.XPATH,templates_filter_button_from_file)))
        return templates_filter_button_from_ui

    def filter_drop_down(self):
        filter_drop_down_from_file = self.field[32].text
        filter_drop_down_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,filter_drop_down_from_file)))
        return filter_drop_down_from_ui

    def filter_save(self):
        filter_save_from_file = self.field[33].text
        filter_save_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,filter_save_from_file)))
        return filter_save_from_ui

    def filter_name(self):
        filter_name_from_file = self.field[34].text
        filter_name_from_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,filter_name_from_file)))
        return filter_name_from_ui

    def filter_save_button(self):
        filter_save_button_from_file = self.field[35].text
        filter_save_button_ui = self.wait.until(EC.presence_of_element_located((By.XPATH,filter_save_button_from_file)))
        return filter_save_button_ui
