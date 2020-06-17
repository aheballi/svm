from src.Features.Login.test_login_page import LoginPage
import os
import xml.etree.ElementTree as ET

class login(LoginPage):
    def __init__(self):
        super().__init__()
        self.object_for_login_page = LoginPage()
        self.object_for_username_field = self.object_for_login_page.username_field()
        self.object_for_password_field = self.object_for_login_page.password_field()
        self.object_for_login_button_field = self.object_for_login_page.login_button()
        file = self.details_dict.get('login')
        os.chdir(file)
        tree = ET.parse('username_passwords')
        self.root = tree.getroot()


    def valid_user_password(self):
        username_from_file = self.root[0].text
        password_from_file = self.root[1].text
        self.object_for_username_field.send_keys(username_from_file)
        self.object_for_password_field.send_keys(password_from_file)
        self.object_for_login_button_field.click()

    def invalid_username_password(self):
        username_from_file = self.root[2].text
        password_from_file = self.root[3].text
        self.object_for_username_field.send_keys(username_from_file)
        self.object_for_password_field.send_keys(password_from_file)
        self.object_for_login_button_field.click()
        obj4 = LoginPage().error_message()
        print(obj4)
        return obj4


if  __name__ == "__main__":
    LoginPage().launch_url()
    login().invalid_username_password()