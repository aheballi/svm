// ASSuiteIISCheck.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "..\..\..\Include\AdminStudio_RegLocations.h"


HRESULT __stdcall ASCheckIISRequirements(IDispatch *pUIExtension)
{
	if(pUIExtension == NULL)
		return E_POINTER;

	CComQIPtr<ISuiteUIExtension> spSuiteUIExt = pUIExtension;
	if(spSuiteUIExt == NULL)
		return E_NOINTERFACE;

	//
	// No need to continue if the features that require IIS are not being
	// installed.
	//
	CComBSTR bstrPredeploy, bstrConfigManager;
	spSuiteUIExt->get_Property(CComBSTR(L"FEATURE[Predeploy_Web].actionState"), &bstrPredeploy);
	spSuiteUIExt->get_Property(CComBSTR(L"FEATURE[ConfigManager_Web].actionState"), &bstrConfigManager);

	if(bstrPredeploy != L"install" && bstrConfigManager != L"install")
	{
		spSuiteUIExt->LogInfo(CComBSTR(L"ASCheckIISRequirements: Predeploy_Web and ConfigManager_Web are not being installed, skipping IIS checks"));
		spSuiteUIExt->put_Property(CComBSTR(L"AS_IIS_REQUIREMENTS_MET"), CComBSTR(L"1"));

		return S_OK;
	}

	bool bAllReqsPresent = false;

	OSVERSIONINFOEX osInfo;
	ZeroMemory(&osInfo, sizeof(OSVERSIONINFOEX));

	osInfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
	GetVersionEx((LPOSVERSIONINFO)&osInfo);

	DWORD dwMajorOSVersion = osInfo.dwMajorVersion;

	//
	// Is IIS installed?
	//
	// Reg keys:
	// HKLM\Software\Microsoft\InetStp
	// HKLM\System\CurrentControlSet\Services\W3SVC\Parameters
	// Value: "MajorVersion"
	//
	CRegKey iisReg;
	LONG lReturn = iisReg.Open(HKEY_LOCAL_MACHINE, _T("Software\\Microsoft\\InetStp"), KEY_READ);
	if(lReturn == ERROR_SUCCESS)
	{
		DWORD dwMajorVersion = 0;
		lReturn = iisReg.QueryDWORDValue(_T("MajorVersion"), dwMajorVersion);

		if(lReturn == ERROR_SUCCESS)
		{
			bAllReqsPresent = true;
			spSuiteUIExt->LogInfo(CComBSTR(L"ASCheckIISRequirements: InetStp key and MajorVersion are present"));
		}
	}

	if(bAllReqsPresent == false)
	{
		spSuiteUIExt->LogInfo(CComBSTR(L"ASCheckIISRequirements: InetStp/MajorVersion do not appear to be present, checking service key"));

		lReturn = iisReg.Open(HKEY_LOCAL_MACHINE, _T("System\\CurrentControlSet\\Services\\W3SVC\\Parameters"), KEY_READ);
		if(lReturn == ERROR_SUCCESS)
		{
			DWORD dwMajorVersion = 0;
			lReturn = iisReg.QueryDWORDValue(_T("MajorVersion"), dwMajorVersion);
			if(lReturn == ERROR_SUCCESS)
			{
				bAllReqsPresent = true;
				spSuiteUIExt->LogInfo(CComBSTR(L"ASCheckIISRequirements: W3SVC\\Parameters and MajorVersion are present"));
			}
		}
	}

	if(dwMajorOSVersion >= 6)
	{
		spSuiteUIExt->LogInfo(CComBSTR(L"ASCheckIISRequirements: OS appears to be Vista or newer, checking for metabase and ADSI compat"));

		//
		// Vista and newer:
		// Is IIS metabase compat installed?
		//
		// Reg keys:
		// HKLM\SOFTWARE\Microsoft\InetStp\Components
		// Value: "Metabase"
		//

		//
		// Is IIS ADSI compat installed?
		//
		// Reg keys:
		// HKLM\SOFTWARE\Microsoft\InetStp\Components
		// Value: "ADSICompatibility"
		//
		lReturn = iisReg.Open(HKEY_LOCAL_MACHINE, _T("Software\\Microsoft\\InetStp\\Components"), KEY_READ);
		if(lReturn == ERROR_SUCCESS)
		{
			DWORD dwMetabaseCompat = 0, dwADSICompat = 0;
			iisReg.QueryDWORDValue(_T("Metabase"), dwMetabaseCompat);
			iisReg.QueryDWORDValue(_T("ADSICompatibility"), dwADSICompat);

			bAllReqsPresent = dwMetabaseCompat && dwADSICompat;

			if(dwMetabaseCompat)
				spSuiteUIExt->LogInfo(CComBSTR(L"ASCheckIISRequirements: metabase compat is installed"));
			if(dwADSICompat)
				spSuiteUIExt->LogInfo(CComBSTR(L"ASCheckIISRequirements: ADSI compat is installed"));
		}
		else
		{
			//
			// The required components can't be present if the key they are indicated
			// from is not present.
			//
			bAllReqsPresent = false;
			spSuiteUIExt->LogInfo(CComBSTR(L"ASCheckIISRequirements: no Components key in InetStp..."));
		}
	}

	if(bAllReqsPresent == false)
	{
		CComBSTR bstrErrorId;

		//
		// Are we running on NT 5.2 or earlier?
		//
		if(dwMajorOSVersion < 6)
			bstrErrorId = L"AS_IIS_NOT_INSTALLED";
		else
			bstrErrorId = L"AS_IIS_60_COMPATIBILITY_NOT_INSTALLED";

		CComBSTR bstrErrorResolved;
		spSuiteUIExt->ResolveString(bstrErrorId, &bstrErrorResolved);

		long lResult = 0;
		spSuiteUIExt->MessageBox(bstrErrorResolved, CComBSTR(), MB_OK | MB_ICONWARNING, &lResult);
	}
	else
	{
		spSuiteUIExt->put_Property(CComBSTR(L"AS_IIS_REQUIREMENTS_MET"), CComBSTR(L"1"));
	}

	return S_OK;
}

HRESULT __stdcall GetAS11ProductLocation_Validate(IDispatch *pDispatch)
{
	return pDispatch ? S_OK : E_POINTER;
	return S_OK;
}

HRESULT __stdcall GetAS11ProductLocation_Evaluate(IDispatch *pDispatch)
{
	if (!pDispatch)
		return E_POINTER;

	CComQIPtr<ISuiteExtension> spExtension(pDispatch);
	if (!spExtension)
		return E_NOINTERFACE;

	HRESULT hr = E_FAIL;
	HKEY hKey;
	if (ERROR_SUCCESS == ::RegOpenKeyEx(HKEY_LOCAL_MACHINE, AdmRegLocations::g_lpszHKLMMainSettingsKey, 0, KEY_READ, &hKey) ||
		ERROR_SUCCESS == ::RegOpenKeyEx(HKEY_LOCAL_MACHINE, AdmRegLocations::g_lpszHKLMProdVer95Key, 0, KEY_READ, &hKey) ||
		ERROR_SUCCESS == ::RegOpenKeyEx(HKEY_LOCAL_MACHINE, AdmRegLocations::g_lpszHKLMProdVer10Key, 0, KEY_READ, &hKey) ||
		ERROR_SUCCESS == ::RegOpenKeyEx(HKEY_LOCAL_MACHINE, AdmRegLocations::g_lpszHKLMProdVer105Key, 0, KEY_READ, &hKey) ||
		ERROR_SUCCESS == ::RegOpenKeyEx(HKEY_LOCAL_MACHINE, AdmRegLocations::g_lpszHKLMProdVer11Key, 0, KEY_READ, &hKey) ||
		ERROR_SUCCESS == ::RegOpenKeyEx(HKEY_LOCAL_MACHINE, AdmRegLocations::g_lpszHKLMProdVer115Key, 0, KEY_READ, &hKey))
	{
		DWORD nType = REG_NONE;
		TCHAR szInstallDir[MAX_PATH + 1] = {0};
		DWORD cbInstallDir = sizeof(szInstallDir) - 1;
		if (ERROR_SUCCESS == ::RegQueryValueEx(hKey, TEXT("Product Location"), NULL, &nType, (LPBYTE)szInstallDir, &cbInstallDir))
		{
			hr = S_OK;
			spExtension->put_Property(CComBSTR(L"ASINSTALLDIR"), CComBSTR(szInstallDir));
			spExtension->put_Property(CComBSTR(L"ASINSTALLED"), CComBSTR(L"Found"));
		}
		else
		{
			spExtension->LogInfo(CComBSTR(L"GetAS11ProductLocation: Value [HKLM\\SOFTWARE\\InstallShield\\AdminStudio\\<productVersion>] Product Location could not be read"));
		}
		::RegCloseKey(hKey);
	}
	else
	{
		spExtension->LogInfo(CComBSTR(L"GetAS11ProductLocation: Key HKLM\\SOFTWARE\\InstallShield\\AdminStudio\\<productVersion> could not be opened"));
	}

	return S_OK;
}