import pytest

from configure_test.conftest import SeleniumWebdriver



#contents of test_class

class Test_first():

    @pytest.mark.incremental
    def func(self,x):
        return x+1


    def test_zanswer(self):
        print ("hello 1")



    def test_new(self):
        print("hello 2")
        assert 1

    def test_browser(self):
        driver = SeleniumWebdriver.driver
        driver.get("https://uat.app.flexerasoftware.com/login/")
        assert 1
        print ("hello 3")

if __name__ == '__main__':
    Test_first().test_zanswer()

