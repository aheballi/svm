from src.utils.SeleniumWebdriver import SeleniumWebdriver

class Element:

    def fetch_element_by_id(driver, element):
        return SeleniumWebdriver.driver.find_element_by_id(element)

    def fetch_element_by_class(driver, element):
        return SeleniumWebdriver.driver.find_element_by_class_name(element)

    def fetch_element_by_css(driver, element):
        return SeleniumWebdriver.driver.find_element_by_css_selector(element)

    def fetch_element_by_linktext(driver, element):
        return SeleniumWebdriver.driver.find_element_by_link_text(element)

    def fetch_element_by_name(driver, element):
        return SeleniumWebdriver.driver.find_element_by_name(element)

    def fetch_element_by_partial_linktext(driver, element):
        return SeleniumWebdriver.driver.find_element_by_partial_link_text(element)

    def fetch_element_by_tagname(driver, element):
        return SeleniumWebdriver.driver.find_element_by_tag_name(element)

    def fetch_element_by_xpath(driver, element):
        return SeleniumWebdriver.driver.find_element_by_xpath(element)

    def fetch_elements_by_classname(driver, element):
        return SeleniumWebdriver.driver.find_elements_by_class_name(element)

    def fetch_elements_by_xpath(driver, element):
        return  SeleniumWebdriver.driver.find_elements_by_xpath(element)

