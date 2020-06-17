from src.Features.Login.test_login_page import LoginPage
from src.utils.SeleniumWebdriver import SeleniumWebdriver
import pytest
from src.Features.Login.login_functionality import login
from src.Features.logout.logout import logout
import time


class TestLoginPage:

    @pytest.mark.incremental
    def test_variable(self):
        global obj1
        obj1 = LoginPage()
        # global obj2
        # obj2 = login()

    def test_url(self):
        obj1.launch_url()
        driver = SeleniumWebdriver.driver
        print(driver.session_id)
        assert driver.session_id != 0

    def test_valid_login(self):

        obj2 = login()
        obj2.valid_user_password()

    @pytest.fixture()
    def logout(self):
        logout().logout_method()

    @pytest.mark.usefixtures("logout")
    def test_invalid_login(self):
        time.sleep(10)
        obj2 = login()
        obj3 = obj2.invalid_username_password()
        assert obj3 == "Invalid credentials"