from unittest import TestCase
from svm_automation.test import TestCase1
from svm_automation.test import TestCase2
import time
#import unittest

class TestExecutionRun(TestCase):
#Download and check the size of svmscan
    def test_case1(self):
        obj1 = TestCase1()
        obj1.test_Login()
        obj1.test_featureclick()
        obj1.test_featureVulnerabilityClickExecution()
        obj1.test_featureSettingsClick()
        obj1.test_clickOnAssessmentInSideSettings()
        obj1.test_clickOnDownloadsExecution()
        obj1.test_clickOnSvmSCanExecution()
        obj1.test_LogOut()

#Check the Advisory Reader Role Accessiblity
    def test_case2(self):
        obj1 = TestCase2()
        obj2 = TestCase1()
        obj1.test_executeLogin()
        obj1.test_featueclick()
        obj1.test_featurenotificationcenter()
        obj1.test_researchExecution()
        obj1.test_productdatabase()
        obj1.test_moduledisabled()
        obj1.test_userprofile()
        obj2.test_LogOut()



if __name__ == '__main__':
    TestExecutionRun.test_case1(None)
    TestExecutionRun.test_case2(None)
