// ASMaintenance.cpp : Reinstalls or Uninstalls MSI packages whose productcodes are passed in on the
// command line.  This logic is in an EXE rather than directly in a MSI DLL in order to have one 
// UAC prompt occur for the totality of the serviced MSIs in this manner on Windows Vista.
//

#include "stdafx.h"
#include "ASMaintenance.h"
#include <windows.h>
#include "msi.h"
#include "msiquery.h"
#include <tchar.h>
#include <shellapi.h>
#include <string>
#include <stdlib.h>
#include <list>

typedef std::basic_string<TCHAR> TString;

void ReinstallMsi(LPCTSTR productCode);
void UninstallMsi(LPCTSTR productCode);
void SetMsiLogging(LPCTSTR productCode);

int APIENTRY _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow)
{
	//::MessageBox(0,	lpCmdLine, _T("Command Line"), 0);
	//cmdline format: -reinstall {productCode1},{productCode2},... -uninstall {productCode1},{productCode2},...
	TCHAR* productCodeToken;
	TCHAR* nextToken = lpCmdLine + _tcslen(_T("-Reinstall "));

	if (_tcsnccmp(lpCmdLine, _T("-Reinstall"), _tcslen(_T("-Reinstall"))) == 0)
	{
		while (productCodeToken = _tcstok_s(NULL , _T(","), &nextToken))
			ReinstallMsi(productCodeToken);

		return ERROR_SUCCESS;
	}
	else if(_tcsnccmp(lpCmdLine, _T("-Uninstall"), _tcslen(_T("-Uninstall"))) == 0)
	{
		while (productCodeToken = _tcstok_s(NULL , _T(","), &nextToken))
			UninstallMsi(productCodeToken);

		return ERROR_SUCCESS;
	}
	else
	{
		return -1;
	}
}

void ReinstallMsi(LPCTSTR productCode)
{
	SetMsiLogging(productCode);
	HWND msiWindowHandle = FindWindow(_T("MsiDialogCloseClass"), NULL);
	if (msiWindowHandle == NULL)
	{
		msiWindowHandle = 0;
	} 

	MsiSetInternalUI(INSTALLUILEVEL (INSTALLUILEVEL_BASIC), &msiWindowHandle);
	MsiReinstallProduct(productCode, REINSTALLMODE_FILEOLDERVERSION | REINSTALLMODE_FILEVERIFY | 
		REINSTALLMODE_MACHINEDATA | REINSTALLMODE_USERDATA | REINSTALLMODE_SHORTCUT);
}

void UninstallMsi(LPCTSTR productCode)
{
	SetMsiLogging(productCode);
	HWND msiWindowHandle = FindWindow(_T("MsiDialogCloseClass"), NULL);
	if (msiWindowHandle == NULL)
	{
		msiWindowHandle = 0;
	} 

	MsiSetInternalUI(INSTALLUILEVEL (INSTALLUILEVEL_BASIC), &msiWindowHandle);
	MsiConfigureProduct(productCode, INSTALLLEVEL_DEFAULT, INSTALLSTATE (INSTALLSTATE_ABSENT));
}

void SetMsiLogging(LPCTSTR productCode)
{
	DWORD dwRetVal;
	TCHAR szTempFilePath[512];
	DWORD dwBufLen = _countof(szTempFilePath);
	dwRetVal = GetTempPath(dwBufLen, szTempFilePath);

	if ((dwRetVal > 0) || dwRetVal <= dwBufLen)
	{
		TString tempPath = szTempFilePath;
		TString::iterator str_Iter;
		str_Iter = tempPath.end( );
		str_Iter--;
		if (*str_Iter == '\\')
		{
			tempPath += _T("AdminStudio_");
			tempPath += productCode;
			tempPath += _T(".log");
		}
		else
		{
			tempPath += _T("\\AdminStudio_");
			tempPath += productCode;
			tempPath += _T(".log");
		}
			
		//::MessageBox(0,tempPath.c_str(), _T("temp directory"), 0);
		MsiEnableLog(INSTALLLOGMODE_FATALEXIT | INSTALLLOGMODE_ERROR | INSTALLLOGMODE_WARNING | INSTALLLOGMODE_USER |
		INSTALLLOGMODE_INFO | INSTALLLOGMODE_RESOLVESOURCE | INSTALLLOGMODE_OUTOFDISKSPACE | INSTALLLOGMODE_ACTIONSTART |
		INSTALLLOGMODE_ACTIONDATA | INSTALLLOGMODE_COMMONDATA | INSTALLLOGMODE_PROPERTYDUMP | INSTALLLOGMODE_VERBOSE, tempPath.c_str(), 0);
	}

}