# from src.Features.Dashboard.Dashboard_Functionality import DashboardFunctionality
import sys
sys.path.insert(0, r'/home/anusha/Pycharm_pytest/PycharmProjects/pytest/')
from src.Features.Dashboard.Dashboard import Dashboard
import pytest
from src.Features.Login.test_login_page import LoginPage
from src.Features.Login.login_functionality import login


class TestDashboard():

    @pytest.mark.incremental
    def test_login_new(self):
        LoginPage().launch_url()
        login().valid_user_password()

    # def test_dashboard_menu(self):
    #     object_for_dashboard_menu = DashboardFunctionality()
    #     object_for_dashboard_menu.dashboard_menu_click()

    @pytest.fixture()
    def add_button(self):
        global dashboard
        dashboard = Dashboard()
        dashboard.add_dropdown()

    @pytest.mark.usefixtures("add_button")
    def test_add_widget(self):
        # dashboard = Dashboard()
        dashboard.add_widget("Devices status - System score")

    def test_remove_gadgets(self):
        dashboard.remove_widget("Devices status - System score")

    def test_add_all_widgets(self):
        dashboard = Dashboard()
        dashboard.add_all_widgets()

    def test_remove_all_widgets(self):
        dashboard.remove_all_widgets()