import sys
sys.path.insert(0, r'/home/anusha/Pycharm_pytest/PycharmProjects/pytest/')
import pytest
from src.Features.Patching.Templates import Templates
from src.Features.Login.test_login_page import LoginPage
from src.Features.Login.login_functionality import login
import time
from src.Features.Patching.PatchLibrary import PatchLibrary
from src.Features.Patching.Packages import Packages
from src.Features.Patching.Deployment import Deployment


class TestPatching():


    @pytest.mark.incremental

    def test_login(self):
        "this method is to login into the uat with valid credentials"
        LoginPage().launch_url()
        login().valid_user_password()

    # def test_patch_library(self):
    #     """method is for creating a template and check if the template is actually created"""
    #     patch_library = PatchLibrary()
    #     time.sleep(5)
    #     patch_library.search("Mozilla Thunderbird")
    #     time.sleep(2)
    #     global template_name
    #     template_name = patch_library.create_template()
    #     time.sleep(5)
    #     #Assert starts from here
    #     templates = Templates()
    #     time.sleep(5)
    #     patch_library.search(template_name)
    #     time.sleep(2)
    #     result_text = templates.search()
    #     assert result_text == template_name


    # def test_build_packages(self):
    #     """methos is for creating a build package for the template created in previous method"""
    #     time.sleep(2)
    #     patch_library = PatchLibrary()
    #     time.sleep(5)
    #     patch_library.build_packages("Mozilla Thunderbird",template_name)
    #
    # # Assert starts from here
    #     time.sleep(5)
    #     packages = Packages()
    #     time.sleep(5)
    #     patch_library.search(template_name)
    #     result_text = packages.search()
    #     assert result_text == template_name


    # def test_deploy_packages(self):
    #     """deploy the build packages created in previous method"""
    #     patch_library = PatchLibrary()
    #     packages = Packages()
    #     time.sleep(3)
    #     patch_library.search(template_name)
    #     time.sleep(5)
    #     packages.create_deployment()
    #
    # def test_deployment(self):
    #     """methos is to check if the package is deployed"""
    #     time.sleep(2),.abcfmtx
    #     patch_library = PatchLibrary()
    #     time.sleep(3)
    #     deployment = Deployment()
    #     time.sleep(3)
    #     patch_library.search(template_name)
    #     time.sleep(5)
    #     deployment.search()

    def test_save_filter(self):
        time.sleep(2)
        patch_library = PatchLibrary()
        time.sleep(2)
        patch_library.search("Mozilla Thunderbird")
        patch_library.filter("demo1_mozilla")

    # Assert starts from here
    # This is to check the created filter appears in the filter drop down


