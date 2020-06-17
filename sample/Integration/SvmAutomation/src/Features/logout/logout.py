from configparser import ConfigParser
import os
import xml.etree.ElementTree as ET
from src.utils.SeleniumWebdriver import SeleniumWebdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

class logout:
    def logout_method(self):
        config = ConfigParser()
        config.read(r'/home/qa-master/SVM/Integration/SvmAutomation/src/Config File/pathFile.properties')
        config.sections()
        details_dict = dict(config.items('dev'))
        file = details_dict.get('file')
        os.chdir(file)
        tree = ET.parse('LoginWebElements.xml')
        root = tree.getroot()
        field = root.findall('Field')
        sign_out_button = field[5].text
        sign_out = field[6].text
        driver = SeleniumWebdriver.driver
        wait = WebDriverWait(driver, 50)
        element_sign_out_button = wait.until(EC.element_to_be_clickable((By.CLASS_NAME,sign_out_button)))
        element_sign_out_button.click()
        element_sign_out = wait.until(EC.element_to_be_clickable((By.XPATH,sign_out)))
        element_sign_out.click()


#
# if __name__ == '__main__':
#     LoginPage().launch_url()
#     login().valid_user_password()
#     logout().logout_method()