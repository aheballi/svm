"""This file contains the code for login page """
from configparser import ConfigParser
import os
import xml.etree.ElementTree as ET
from src.utils.SeleniumWebdriver import SeleniumWebdriver
from src.utils.Selenium_fetch_elements import Element


class LoginPage(object):
    """This class has all the elements present on the login page"""
    def __init__(self):
        self.driver = SeleniumWebdriver.driver
        config = ConfigParser()
        config.read(r'/home/qa-master/SVM/Integration/SvmAutomation/src/Config File/pathFile.properties')
        config.sections()
        self.details_dict = dict(config.items('dev'))
        file = self.details_dict.get('file')
        os.chdir(file)
        tree = ET.parse('LoginWebElements.xml')
        root = tree.getroot()
        self.field = root.findall('Field')


    def launch_url(self):
        """This def is to launch u which is passed from file pathfile.properties"""
        url = self.details_dict.get('url')
        print(url)
        self.driver.get(url)

    def flexera_logo(self):
        """This def is to check if "Flexera" logo is present on the login page"""
        logo_field = self.field[0].text
        logo = Element.fetch_element_by_xpath(self.driver, logo_field).get_attribute('class')
        print(logo)
        return logo

    def login_text(self):
        """This def is used to find if the text "login" is present on the page"""
        login_text_file = self.field[1].text
        login_text = Element.fetch_element_by_xpath(self.driver, login_text_file).text
        print(login_text)
        return login_text

    def username_field(self):
        """This def is to check if the "username" field is present on the login page"""
        username_field_file = self.field[2].text
        # global username_field
        username_field = Element.fetch_element_by_id(self.driver, username_field_file)
        # global username_field_value
        username_field_value = username_field.get_attribute('name')
        print(username_field_value)
        return username_field

    def password_field(self):
        password_field_file = self.field[3].text
        password_field = Element.fetch_element_by_id(self.driver, password_field_file)
        password_field_value = password_field.get_attribute('name')
        print(password_field_value)
        return password_field

    def login_button(self):
        login_button_file = self.field[4].text
        login_field = Element.fetch_element_by_id(self.driver, login_button_file)
        login_field_value = login_field.text
        print(login_field_value)
        return login_field

    def error_message(self):
        error_from_file = self.field[7].text
        error_message = Element.fetch_element_by_xpath(self.driver, error_from_file).text
        return error_message





if __name__ == '__main__':
    LoginPage().launch_url()
