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

    def test_name(self):
        file = os.chdir(r'/root/PycharmProjects/pytest/src/UI_Map_Properties/')
        tree = ET.parse('LoginWebElements.xml')
        root = tree.getroot()
        user = root.findall('Field')
        username_field = user[0].text
        print(username_field)
        config = ConfigParser()
        config.read(r'/root/PycharmProjects/pytest/src/Config File/pathFile.properties')
        config.sections()
        details_dict = dict(config.items('dev'))
        print (details_dict.get('url'))