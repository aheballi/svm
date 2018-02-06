from svm_automation.svm_scan_agent import TestFeatures
from svm_automation.advisory_role import TestAdvisoryRole
import time

class TestCase1:
    def test_Login(self):
        obj1 = TestFeatures.testlogin(None)

    def test_featureclick(self):
        obj1 = TestFeatures.testfeatureDashboardClick(None)

    def test_featureVulnerabilityClickExecution(self):
        obj2 = TestFeatures.testfeatureVulnerabilityClick(None)

    def test_featureSettingsClick(self):
        obj3 = TestFeatures.testfeatureSettingsClick(None)

    def test_clickOnAssessmentInSideSettings(self):
        obj4 = TestFeatures.testClickOnAssessmentInSideSettings(None)

    def test_clickOnDownloadsExecution(self):
        obj5 = TestFeatures.testClickOnDownloads(None)

    def test_clickOnSvmSCanExecution(self):
        obj6 = TestFeatures.testClickOnSvmScan(None)

    def test_LogOut(self):
        obj7 = TestFeatures.testlogout(None)


class TestCase2:
    def test_executeLogin(self):
        obj1 = TestAdvisoryRole.test_Login(None)

    def test_featueclick(self):
        ob2 = TestAdvisoryRole.test_featureClick(None)

    def test_featurenotificationcenter(self):
        obj3 = TestAdvisoryRole.test_featurenotificationcenter(None)

    def test_researchExecution(self):
        obj4 = TestAdvisoryRole.test_researchmodule(None)

    def test_productdatabase(self):
        obj5 = TestAdvisoryRole.test_productbatabase(None)

    def test_moduledisabled(self):
        obj6 = TestAdvisoryRole.test_modulearedisabled(None)

    def test_userprofile(self):
        obj7 = TestAdvisoryRole.test_userprofile(None)

    def test_logout(self):
        obj7 = TestFeatures.testlogout(None)
