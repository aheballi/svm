// CheckFileExists.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include <TCHAR.h>

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    return TRUE;
}


UINT __stdcall CheckRepackagerPath (MSIHANDLE hInstall)
{
	TCHAR szRepackagerPath[1024] = {0};
	DWORD dwSize = 1024;
	MsiGetProperty(hInstall, _T("REPACKAGERDIR"), szRepackagerPath, &dwSize);
	
	TCHAR szRepackagerFile[1024] = {0};
	_tcscpy(szRepackagerFile, szRepackagerPath);

/*    LPTSTR lpszLast = szRepackagerFile;

    // Walk to the end of the path.    
    while (*lpszLast)
        lpszLast = CharNext( lpszLast );

    // Check if already has \ .
    lpszLast = CharPrev( szRepackagerFile, lpszLast );

	// Last character is not a slash. Hence add one
    if (*lpszLast != '\\')      
		_tcscat(szRepackagerFile, _T("\\"));	
*/
	_tcscat(szRepackagerFile, _T("islc.exe"));

#ifdef _DEBUG
		MessageBox(NULL, szRepackagerFile, _T("Debug"), MB_OK);
#endif

	DWORD dwAttr = ::GetFileAttributes(szRepackagerFile);
	if (0xFFFFFFFF != dwAttr)
	{

#ifdef _DEBUG
		MessageBox(NULL, _T("ISLC exists"), _T("Debug"), MB_OK);
#endif
		MsiSetProperty(hInstall, _T("ISLCEXISTS"), _T("TRUE"));
	
	}
//	else
//	{
//
//	}

	return ERROR_SUCCESS;
}


UINT __stdcall CheckASSharedPath (MSIHANDLE hInstall)
{
	 
	TCHAR szRepackagerPath[1024] = {0};
	DWORD dwSize = 1024;
	MsiGetProperty(hInstall, _T("ASSHAREDLOC"), szRepackagerPath, &dwSize);
	
	TCHAR szRepackagerFile[1024] = {0};
	_tcscpy(szRepackagerFile, szRepackagerPath);

	_tcscat(szRepackagerFile, _T("Shared AdminStudio.ini"));

#ifdef _DEBUG
		MessageBox(NULL, szRepackagerFile, _T("Debug"), MB_OK);
#endif
	
	DWORD dwAttr = ::GetFileAttributes(szRepackagerFile);
	if (0xFFFFFFFF != dwAttr)
	{

#ifdef _DEBUG
		MessageBox(NULL, _T("ISLC exists"), _T("Debug"), MB_OK);
#endif
		MsiSetProperty(hInstall, _T("ASSHAREDEXIST"), _T("TRUE"));
		
	}

	return ERROR_SUCCESS;
}