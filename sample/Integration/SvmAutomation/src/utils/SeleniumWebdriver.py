from selenium import webdriver

class SeleniumWebdriver:
    fp = webdriver.FirefoxProfile()
    fp.set_preference("browser.download.folderList", 2)
    fp.set_preference("browser.helperApps.neverAsk.saveToDisk", 'application/octet-stream')
    downloadPath = "/home/anusha/csi7_automation/Downloads/"
    fp.set_preference("browser.download.dir", downloadPath)
    driver = webdriver.Firefox(executable_path=r'/home/anusha/django-first-sample/svm_automation/geckodriver/geckodriver',firefox_profile=fp)