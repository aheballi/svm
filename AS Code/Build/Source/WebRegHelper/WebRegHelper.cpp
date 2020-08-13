// WebRegHelper.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include <MsiQuery.h>
#include <Msi.h>
#include <Shellapi.h.>
#include <stdlib.h>
#include <tchar.h>


#define PROP_REBOOTPENDING _T("ISREBOOTPENDING")

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
	
    return TRUE;
}

BOOL RebootPending(MSIHANDLE hInstall)
{
	return MsiGetMode(hInstall, MSIRUNMODE_REBOOTATEND);
}

//Set MSI custom property "ISREBOOTPENDING" if a reboot is required at end of setup
long __stdcall CheckRebootStatus(MSIHANDLE hInstall)
{

	if (RebootPending(hInstall))
		MsiSetProperty(hInstall, PROP_REBOOTPENDING, "True");

	return ERROR_SUCCESS;
}

long __stdcall WriteRunOnce4WebReg(MSIHANDLE hMsi)
{
	TCHAR szProductCode[_MAX_PATH] = {0};
	DWORD dwCount = _MAX_PATH;

	if (ERROR_SUCCESS == MsiGetProperty(hMsi, _T("ProductCode"),szProductCode,&dwCount))
	{
		HKEY hKey;
		if (ERROR_SUCCESS == RegOpenKeyEx(HKEY_LOCAL_MACHINE,_T("Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce"),0,KEY_ALL_ACCESS,&hKey))
		{
			TCHAR sCommonDir[_MAX_PATH] = {0};
			dwCount = _MAX_PATH;
			if (ERROR_SUCCESS == MsiGetProperty(hMsi, _T("CommonFilesFolder"),sCommonDir,&dwCount))
			{
				LPTSTR lpPtr = sCommonDir;
				if (lpPtr)
				{
					while(*lpPtr)
						lpPtr++;
					lpPtr--;
					if((*lpPtr) == '\\')
						*lpPtr = NULL;
					
					TCHAR sFile[_MAX_PATH];
					wsprintf(sFile,_T("\"%s\\InstallShield\\Shared\\WebReg\\WebReg.exe\" %s"),sCommonDir, szProductCode);
					RegSetValueEx(hKey,_T("RegISX"), 0, REG_SZ, (BYTE * const)sFile, (lstrlen(sFile)+1)*sizeof(TCHAR));
				}
			}
			
			RegCloseKey(hKey);
		}
	}
	
	return 0;
}