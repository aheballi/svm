// WebReg.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include <Shellapi.h.>
#include <stdlib.h>
#include <tchar.h>
#include <msi.h>

#define ISREGPAGE  _T("http://www.installshield.com/proddirect/process.asp?action=register&serial=%s&co=%s&usr=%s")
#define MAX_NAME 256

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
	if (!lpCmdLine) return 0;
	if (!lstrlen(lpCmdLine)) return 0;

	// command line is supposed to be the product code	

	TCHAR szSerial[MAX_NAME] ={0};
	TCHAR szCompany[MAX_NAME] ={0};
	TCHAR szUser[MAX_NAME] ={0};

	DWORD dwUser = MAX_NAME;
	DWORD dwCompany = MAX_NAME - 1;
	DWORD dwSerial = MAX_NAME - 1;
	::MsiGetUserInfo(lpCmdLine,szUser,&dwUser,szCompany,&dwCompany,szSerial,&dwSerial);
	
	SHELLEXECUTEINFO  execInfo;
	ZeroMemory(&execInfo, sizeof(execInfo));
	
	TCHAR szFile[1024];
	wsprintf(szFile,ISREGPAGE,szSerial,szCompany,szUser);
	
	execInfo.cbSize = sizeof(execInfo);
	execInfo.lpFile = szFile;
	execInfo.lpVerb = _T("open");
	execInfo.fMask = SEE_MASK_FLAG_DDEWAIT;
	execInfo.nShow = SW_SHOWNORMAL;
	
	BOOL bRet = ShellExecuteEx(&execInfo);
	
	return 0;
}



