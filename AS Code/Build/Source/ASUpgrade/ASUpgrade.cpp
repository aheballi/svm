// ASUpgrade.cpp : Defines the initialization routines for the DLL.
//

#include "stdafx.h"
#include "ASUpgrade.h"
#include "pathx.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define MAX_BUFFER_LENGTH 1024

//
//	Note!
//
//		If this DLL is dynamically linked against the MFC
//		DLLs, any functions exported from this DLL which
//		call into MFC must have the AFX_MANAGE_STATE macro
//		added at the very beginning of the function.
//
//		For example:
//
//		extern "C" BOOL PASCAL EXPORT ExportedFunction()
//		{
//			AFX_MANAGE_STATE(AfxGetStaticModuleState());
//			// normal function body here
//		}
//
//		It is very important that this macro appear in each
//		function, prior to any calls into MFC.  This means that
//		it must appear as the first statement within the 
//		function, even before any object variable declarations
//		as their constructors may generate calls into the MFC
//		DLL.
//
//		Please see MFC Technical Notes 33 and 58 for additional
//		details.
//

/////////////////////////////////////////////////////////////////////////////
// CASUpgradeApp

BEGIN_MESSAGE_MAP(CASUpgradeApp, CWinApp)
	//{{AFX_MSG_MAP(CASUpgradeApp)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CASUpgradeApp construction

CASUpgradeApp::CASUpgradeApp()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CASUpgradeApp object

CASUpgradeApp theApp;

MSIHANDLE g_hInstall = NULL;

void LogInfo(LPCTSTR lpszLogInfo)
{
    //	Write to the Msi log file
	PMSIHANDLE hRec = MsiCreateRecord(1);
	MsiRecordSetString(hRec, 0, _T("AdminStudio [Time]: [1] - [2]"));
    MsiRecordSetString(hRec, 1, lpszLogInfo);
	MsiProcessMessage(g_hInstall, INSTALLMESSAGE_INFO, hRec);
}

void MsiMessageBox(LPCTSTR lpszLogInfo, INSTALLMESSAGE msiMessageType)
{
    //	Write to the Msi log file and display messagebox
	PMSIHANDLE hRec = MsiCreateRecord(1);
	MsiRecordSetString(hRec, 0, lpszLogInfo);
	MsiProcessMessage(g_hInstall, msiMessageType, hRec);
}

bool CopyFile(const CString& strSrcFile, const CString& strDestFolder)
{    
	bool bSuccess = false;

	CString strFileName = strSrcFile;
	LPTSTR lpszDestFileName = ::PathFindFileName(strFileName.GetBuffer(2048));

	//	Determine the destination file path. If the DestFolder is empty use the 
	//	root folder.
	CString strDestFile = strDestFolder;
	::PathAppend(strDestFile.GetBuffer(2048), lpszDestFileName);
	strDestFile.ReleaseBuffer();

	is::pathx pthDestFile = (LPCTSTR)strDestFile;
	pthDestFile = pthDestFile.dir();
	pthDestFile.create();
    
	if(::CopyFile(strSrcFile, strDestFile, FALSE ))
	{
        LogInfo(strSrcFile);
/*		// Remove the READ-ONLY Attribute of the file
		if (PathFileExists(strDestFile))
		{
			DWORD dwFileAttribute = GetFileAttributes(strDestFile);
			dwFileAttribute &= ~FILE_ATTRIBUTE_READONLY;
			SetFileAttributes(strDestFile, dwFileAttribute);
		}
*/
		bSuccess = true;
	}
	return bSuccess;
}

bool CopyAllFiles(const CString& strRootFolder, const CString& strDestFolder)
{
	CString sCurrentFolder = strRootFolder;
	::PathAppend(sCurrentFolder.GetBuffer(2048), _T("*.*"));
	sCurrentFolder.ReleaseBuffer();

	WIN32_FIND_DATA findFileData;
	HANDLE hFind = FindFirstFile(sCurrentFolder, &findFileData);

	BOOL bMore = (hFind != INVALID_HANDLE_VALUE);

	while(bMore)
	{
        if (_tcscmp(findFileData.cFileName, _T(".")) && 
			_tcscmp(findFileData.cFileName, _T("..")))
		{
			if (! (findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
			{
				CString sSrcPath = strRootFolder;
				::PathAppend(sSrcPath.GetBuffer(2048), findFileData.cFileName);
				sSrcPath.ReleaseBuffer();

				if (! CopyFile(sSrcPath, strDestFolder))
					return false;
			}
		}
		bMore = FindNextFile(hFind, &findFileData);
	}
	FindClose(hFind);
	return true;
}


bool CreateDestDirectory(const CString& sRootFolder)
{
	bool bSuccess = true;
	try
	{
		using namespace is;
		pathx pthDestFolder = (LPCTSTR)sRootFolder;

		//	Invalid path. Inform the user
		if (! pthDestFolder.is_valid())
			return false;
		
		//	If the folder does not exist, then try to create it.
		if (! pthDestFolder.exists(pathx::eptDir))
		{
			HRESULT hr = pthDestFolder.create();
			if (FAILED(hr))
				return false;
		}
	}
	catch(...)
	{
		bSuccess = false;
	}

	return bSuccess;
}


bool CopyFolder(const CString& strSrcFolder, const CString& strDestFolder, bool bRecursive)
{
    CString sLog;
    sLog.Format(_T("Copying %s to %s"), strSrcFolder, strDestFolder);
    LogInfo(sLog);
    
	if (! CreateDestDirectory(strDestFolder))
    {
        LogInfo(_T("Failed to Create Destination Dir"));
        return false;
    }
		
	// Copy All the files in this folder
	if (! CopyAllFiles(strSrcFolder, strDestFolder))
    {
        LogInfo(_T("Failed to Copy All Files"));
        return false;
    }
	
	CString sCurrentFolder = strSrcFolder;
	::PathAppend(sCurrentFolder.GetBuffer(2048), _T("*"));
	sCurrentFolder.ReleaseBuffer();

    // read all folder entries
	WIN32_FIND_DATA findFileData;
	HANDLE hFind = FindFirstFile(sCurrentFolder, &findFileData);

	BOOL bMore = (hFind != INVALID_HANDLE_VALUE);
	
	while(bMore)
	{
        if (_tcscmp(findFileData.cFileName, _T(".")) && 
			_tcscmp(findFileData.cFileName, _T("..")))
		{
			CString sFullPath = strSrcFolder;
			::PathAppend(sFullPath.GetBuffer(2048), findFileData.cFileName);
			sFullPath.ReleaseBuffer();

			if (findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
			{
				CString sCurrentPath = strDestFolder;
				::PathAppend(sCurrentPath.GetBuffer(2048), findFileData.cFileName);
				sCurrentPath.ReleaseBuffer();

				// Copy the contents of this folder
				if (bRecursive)
				{
					if (! CopyFolder(sFullPath, sCurrentPath, bRecursive))
						return false;
				}
			}
		}
		bMore = FindNextFile(hFind, &findFileData);
	}

	FindClose(hFind);
	return true;
}

/*
bool StartProcess(LPSTR lpCommand)
{
    // create the startup info
    STARTUPINFO startupInfo = { sizeof startupInfo, 0, 0 };
    startupInfo.dwFlags = STARTF_USESHOWWINDOW;
    startupInfo.wShowWindow = SW_HIDE;	

    // create the process
	PROCESS_INFORMATION pi;
	// Inherits handles
	BOOL bProcessCreated = ::CreateProcess(NULL, lpCommand,
    	  								   NULL, NULL, TRUE, 
    									   CREATE_NEW_CONSOLE|NORMAL_PRIORITY_CLASS,
										   NULL, NULL, &startupInfo, &pi);

    // return Win32 error if process not created
	if (!bProcessCreated) 
    {
        DWORD dwWin32ErrNum = ::GetLastError();
        LPVOID lpMsgBuf;
        int nLen = ::FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER  |
                                    FORMAT_MESSAGE_FROM_SYSTEM |
                                    FORMAT_MESSAGE_IGNORE_INSERTS,
                                    NULL, dwWin32ErrNum, 0, (LPTSTR)&lpMsgBuf, 0, NULL);
        CString sVerbose;
    
        if (nLen)
        {
            sVerbose = (LPTSTR)lpMsgBuf;
            LocalFree(lpMsgBuf);
        }
        else
            sVerbose = _T("CreateProcess failed");

        LogInfo(sVerbose);

        return false;
    }

     // block until the process ends
    if (bProcessCreated && pi.hProcess != INVALID_HANDLE_VALUE) 
    { 
        WaitForSingleObject(pi.hProcess, 30000);
        DWORD dwExitCode;
        if (::GetExitCodeProcess(pi.hProcess, &dwExitCode))
        {
            CString sExitCode;
            sExitCode.Format(_T("Exit code: %d"), dwExitCode); 
            LogInfo(sExitCode);
        }

           
        CloseHandle(pi.hProcess); 
    } 

   if (pi.hThread != INVALID_HANDLE_VALUE)
        CloseHandle(pi.hThread); 
   
   return true;
}

/// @brief  The Uprade70To71 function
/// 
/// Called 1st thing after Progress dialog before uninstalling 7.0 when Upgrading 7.0 to 7.1
/// Copies 2 shared files to temp and then 
///     stops flexnet service
///     Makes a backup copy of the flexnet db
///     Restarts flexnet service
/// 
/// @param  hInstall a parameter of type MSIHANDLE
/// @return UINT
/// 
UINT __stdcall Uprade70To71(MSIHANDLE hInstall)
{
    g_hInstall = hInstall;
    LogInfo("Uprade70To71 -- Start");

	PMSIHANDLE hView;
	long lResult;    

	PMSIHANDLE hDatabase = MsiGetActiveDatabase(hInstall);	

	if (hDatabase == NULL)
	{
        LogInfo("MsiGetActiveDatabase failed");
        return -1;
    }

    CString sLog;
	TCHAR szSharedLoc [MAX_PATH] = {0};
	DWORD nBuffer = MAX_PATH;
	lResult = MsiGetProperty(hInstall, "AS70SHAREDLOC", szSharedLoc, &nBuffer);
    
	if(lstrlen(szSharedLoc) > 0 && lResult == ERROR_SUCCESS)
	{		
        LogInfo("Backing up Shared Files...");
        sLog.Format(_T("AS70SHAREDLOC: %s"), szSharedLoc);
        LogInfo(sLog);

        using namespace is;
        //Make a copy of Shared AdminStudio.ini & EA_Default.xml
    	CString strTempFolderLocation;
	    DWORD dwSize = 2048;
        ::GetTempPath(dwSize, strTempFolderLocation.GetBuffer(dwSize));
	    strTempFolderLocation.ReleaseBuffer(); 
        sLog.Format(_T("Temp Folder: %s"), strTempFolderLocation);
        LogInfo(sLog);
       
        pathx pthTempIni = (LPCTSTR)strTempFolderLocation;
	    pthTempIni.path_append(_T("70 Shared AdminStudio.ini"));

        pathx pthSharedIni = szSharedLoc;
        pthSharedIni.path_append(_T("Shared AdminStudio.ini"));

        if (pthSharedIni.exists(pathx::eptFile))
            ::CopyFile(pthSharedIni, pthTempIni, FALSE );
        else
        {
            sLog.Format(_T("File Not Found: %s"), CString(pthSharedIni));
            LogInfo(sLog);
        }

        pathx pthTempEA = (LPCTSTR)strTempFolderLocation;
	    pthTempEA.path_append(_T("70 EA_Default.xml"));

        pathx pthSharedEA = szSharedLoc;
        pthSharedEA.path_append(_T("EA_Default.xml"));

        if (pthSharedEA.exists(pathx::eptFile))
            ::CopyFile(pthSharedEA, pthTempEA, FALSE );   
        else
        {
            sLog.Format(_T("File Not Found: %s"), CString(pthSharedEA));
            LogInfo(sLog);
        }
    }
    else           
        LogInfo(_T("AS70SHAREDLOC not set"));


	TCHAR szAESInstallState [MAX_PATH] = {0};
	nBuffer = MAX_PATH;
	lResult = MsiGetProperty(hInstall, "AS70AES", szAESInstallState, &nBuffer);
    
	if(lstrlen(szAESInstallState) > 0 && lResult == ERROR_SUCCESS)
	{			
        CString sAESInstall = szAESInstallState;
        sAESInstall.MakeLower();
        if (sAESInstall == _T("install"))
            LogInfo("AES 7.0 Installed");
        else
        {
            LogInfo("AES 7.0 Not Installed");
            return ERROR_SUCCESS;
        }  
	}
    else
    {
        LogInfo("AES 7.0 Not Installed");
        return ERROR_SUCCESS;
    }   

    CString sAES;
	TCHAR sz70Dir [MAX_PATH] = {0};
	nBuffer = MAX_PATH;
	lResult = MsiGetProperty(hInstall, "AS70PRDLOC", sz70Dir, &nBuffer);
    
	if(lstrlen(sz70Dir) > 0 && lResult == ERROR_SUCCESS)
	{	
        is::pathx sDir = sz70Dir;
        sDir.path_append(_T("AES\\"));
        sAES = (LPCTSTR) sDir;
        sLog.Format(_T("AES 7.0 Dir: %s"), sAES);
        LogInfo(sLog);
	}
    else
    {
        LogInfo("AS70PRDLOC Not set");
        return -2;
    }   

    LogInfo(_T("Stopping FLEXnet Service..."));

    //CString sAES = "C:\\Program Files\\InstallShield\\AdminStudio\\7.0\\AES\\";     
    CString sBat = sAES + _T("flexnet.bat");
    CString sArgs = _T("Service stop");  //very touchy..& case sensitive from here!

    CString sCommand;
    sCommand.Format(_T("\"%s\" %s"), sBat, sArgs);
    LogInfo(sCommand);

    if (!StartProcess(sCommand.GetBuffer(0)))
        return -2;
    sCommand.ReleaseBuffer();

    LogInfo(_T("Backing Up FLEXnet Database..."));

    //CString sSourceDb = "C:\\Program Files\\InstallShield\\AdminStudio\\7.0\\AES\\Db";     
    //CString sTargetDb = "C:\\Program Files\\InstallShield\\AdminStudio\\7.0\\AES\\DbBackup";

    CString sSourceDb = sAES + _T("Db");
    CString sTargetDb = sAES + _T("DbBackup");

    CopyFolder(sSourceDb, sTargetDb, true);

    LogInfo(_T("Restarting Service..."));

    sArgs = _T("Service start");
    sCommand.Format(_T("\"%s\" %s"), sBat, sArgs);
    LogInfo(sCommand);

    if (!StartProcess(sCommand.GetBuffer(0)))
        return -3;

    LogInfo("Uprade70To71 -- End");

    return ERROR_SUCCESS;
}

/// @brief  The MigrateSharedFiles function
/// 
/// Called from CA after Uprade70To71 above is called and all files are transfered to 
/// move ini & xml files from temp to the AS shared folder
/// 
/// @param  hInstall a parameter of type MSIHANDLE
/// @return UINT
/// 

UINT __stdcall MigrateSharedFiles(MSIHANDLE hInstall)
{
    g_hInstall = hInstall;
    LogInfo("MigrateSharedFiles -- Start");
  	TCHAR szSharedLoc [MAX_PATH] = {0};
	DWORD nBuffer = MAX_PATH;
	long lResult = MsiGetProperty(hInstall, "INSTALLDIR_SHARED", szSharedLoc, &nBuffer);
	if(lstrlen(szSharedLoc) > 0 && lResult == ERROR_SUCCESS)
	{	
        CString sLog;
        sLog.Format(_T("INSTALLDIR_SHARED: %s"), szSharedLoc);
        LogInfo(sLog);

        using namespace is;
        //Restore 7.0 Shared AdminStudio.ini & EA_Default.xml
    	CString strTempFolderLocation;
	    DWORD dwSize = 2048;
        ::GetTempPath(dwSize, strTempFolderLocation.GetBuffer(dwSize));
	    strTempFolderLocation.ReleaseBuffer(); 
        sLog.Format(_T("Temp Folder: %s"), strTempFolderLocation);
        LogInfo(sLog);
        
        pathx pthTempIni = (LPCTSTR)strTempFolderLocation;
	    pthTempIni.path_append(_T("70 Shared AdminStudio.ini"));

        pathx pthSharedIni = szSharedLoc;
        pthSharedIni.path_append(_T("Shared AdminStudio.ini"));
        
        if (pthTempIni.exists(pathx::eptFile))
        {
            sLog.Format(_T("Restoring %s to %s"), CString(pthTempIni), CString(pthSharedIni));
            LogInfo(sLog);
            ::CopyFile(pthTempIni, pthSharedIni, FALSE );
            if (!::DeleteFile(pthTempIni))
                LogInfo("Failed to Delete Temporary File: 70 Shared AdminStudio.ini");
        }            
        else
        {
            sLog.Format(_T("File Not Found: %s"), CString(pthTempIni));
            LogInfo(sLog);
        }
            

        pathx pthTempEA = (LPCTSTR)strTempFolderLocation;
	    pthTempEA.path_append(_T("70 EA_Default.xml"));

        pathx pthSharedEA = szSharedLoc;
        pthSharedEA.path_append(_T("EA_Default.xml"));

        if (pthTempEA.exists(pathx::eptFile))
        {
            sLog.Format(_T("Restoring %s to %s"), CString(pthTempEA), CString(pthSharedEA));
            LogInfo(sLog);
            ::CopyFile(pthTempEA, pthSharedEA, FALSE );
            if (!::DeleteFile(pthTempEA))
                LogInfo("Failed to Delete Temporary File: 70 EA_Default.xml");
        }            
        else
        {
            sLog.Format(_T("File Not Found: %s"), CString(pthTempEA));
            LogInfo(sLog);
        }
    }
    else
        LogInfo(_T("INSTALLDIR_SHARED not set"));

    LogInfo("MigrateSharedFiles -- End");

    return ERROR_SUCCESS;

}
*/

BOOL FileExists(TCHAR* strFile)
{
	WIN32_FIND_DATA fdFindData;
	HANDLE hFile = NULL;
	BOOL bFileFound = TRUE;

	hFile = FindFirstFile(strFile, &fdFindData);

	if (hFile == INVALID_HANDLE_VALUE)
	{
		bFileFound = FALSE;
	}
	else
	{
		bFileFound = TRUE;
		FindClose(hFile);
	}

	return bFileFound;
}

BOOL __stdcall OracleMRUCatalogCheck(MSIHANDLE hInstall)
{
	g_hInstall = hInstall;
	LogInfo(_T("Entered OracleMRUCatalogCheck function.  This will determine if AS recently connected to an Oracle database catalog.  If so, it will show a warning message to the user indicating that Oracle is no longer supported."));

	CRegKey m_RecentKey;
	DWORD dwErrorCode = m_RecentKey.Open(HKEY_CURRENT_USER, g_szASRecentDatabaseKey, KEY_QUERY_VALUE);
	if (ERROR_SUCCESS != dwErrorCode)
	{
		LogInfo(_T("Was not able to access the MRU list for AS catalogs.  Most likely the key does not exist. Exiting function ..."));
		return ERROR_SUCCESS;
	}

	CString szValueName;

	TCHAR szValue[MAX_BUFFER_LENGTH] = {0};
	LPBYTE lpData = reinterpret_cast<LPBYTE>(&szValue);

	DWORD retVal = ERROR_SUCCESS;
	DWORD dwIndex = 0;
	DWORD dwValueSize;
	DWORD dwDataSize;
	DWORD dwSize;

	CString recentDBConnectionString;

	while (retVal == ERROR_SUCCESS)
	{
		dwDataSize = MAX_BUFFER_LENGTH;
		dwValueSize = MAX_BUFFER_LENGTH;
	
		retVal = ::RegEnumValue(m_RecentKey, dwIndex, szValueName.GetBuffer(MAX_BUFFER_LENGTH), &dwValueSize, 0, NULL, lpData, &dwDataSize);
		szValueName.ReleaseBuffer();

		if (ERROR_SUCCESS == retVal && szValueName.GetLength() > 0)
		{
			recentDBConnectionString = CString(reinterpret_cast<TCHAR*>(lpData));
			recentDBConnectionString.MakeUpper();
			
			if (recentDBConnectionString.Find(_T("PROVIDER=ORAOLEDB.ORACLE.1")) != -1)
			{
				//MsiMessageBox(_T("[AS_ORACLENOTSUPPORTED_RECENTLYUSED]"), INSTALLMESSAGE(INSTALLMESSAGE_WARNING|MB_ICONWARNING));
				MsiSetProperty(hInstall, _T("AS_ORACLENOTSUPPORTED_MESSAGE"), _T("AS_ORACLENOTSUPPORTED_RECENTLYUSED"));
				return true;
			}
		}

		dwIndex++;
	}

	LogInfo(_T("Exiting OracleMRUCatalogCheck function."));
	return false;
}

BOOL __stdcall OracleDefaultCatalogCheck(MSIHANDLE hInstall)
{
	g_hInstall = hInstall;
	LogInfo(_T("Entered OracleDefaultCatalogCheck function.  This will determine if AS's default catalog is an Oracle database.  If so, it will show a warning message to the user indicating that Oracle is no longer supported."));

	DWORD dwSize = MAX_BUFFER_LENGTH;

	CString strASSharedFolderPath;
	dwSize = MAX_BUFFER_LENGTH;
	MsiGetProperty(hInstall, _T("INSTALLDIR_SHARED"), strASSharedFolderPath.GetBuffer(MAX_BUFFER_LENGTH), &dwSize);
	strASSharedFolderPath.ReleaseBuffer();

	if(strASSharedFolderPath.IsEmpty())
	{
		LogInfo(_T("AdminStudio Shared Folder length returned 0. Skipping Oracle default catalog check."));
		return false;
	}

	strASSharedFolderPath += _T("Shared AdminStudio.ini");

	CString strDbConnectionString;
	::GetPrivateProfileString(g_lpszASDatabaseSection, g_lpszASDefaultDatabaseKey, NULL, strDbConnectionString.GetBuffer(MAX_BUFFER_LENGTH), MAX_BUFFER_LENGTH, strASSharedFolderPath);
	strDbConnectionString.ReleaseBuffer();

	strDbConnectionString.MakeUpper();
	if (strDbConnectionString.Find(_T("PROVIDER=ORAOLEDB.ORACLE.1")) != -1)
	{
		//MsiMessageBox(_T("[AS_ORACLENOTSUPPORTED_DEFAULTCATALOG]"), INSTALLMESSAGE(INSTALLMESSAGE_WARNING|MB_ICONWARNING));
		MsiSetProperty(hInstall, _T("AS_ORACLENOTSUPPORTED_MESSAGE"), _T("AS_ORACLENOTSUPPORTED_DEFAULTCATALOG"));
		return true;
	}

	LogInfo(_T("Exiting OracleDefaultCatalogCheck function."));
	return false;
}

//Displays warning msg during AS client install if previous default catalog or one of previous recently used catalogs is Oracle based
UINT __stdcall OraclePreviousCatalogCheck(MSIHANDLE hInstall)
{
	if (OracleDefaultCatalogCheck(hInstall) == false)
	{
		OracleMRUCatalogCheck(hInstall);
	}
	return ERROR_SUCCESS;
}

UINT __stdcall BackupSharedFiles(MSIHANDLE hInstall)
{
	g_hInstall = hInstall;

	TCHAR szTempFolder[MAX_PATH] = {0};
	TCHAR szSharedFolder[MAX_PATH] = {0};
	TCHAR szMessage[MAX_BUFFER_LENGTH] = {0};

	DWORD dwSize = MAX_PATH;

	MsiGetProperty(hInstall, TEXT("TempFolder"), szTempFolder, &dwSize);

	dwSize = MAX_PATH;
	MsiGetProperty(hInstall, TEXT("INSTALLDIR_SHARED"), szSharedFolder, &dwSize);

	if (_tcslen(szTempFolder) <= 0 || _tcslen(szSharedFolder) <= 0)
	{
		LogInfo(TEXT("TempFolder or AdminStudio Shared Folder length returned 0. Skipping file backup"));
		return ERROR_SUCCESS;
	}

	TCHAR szSharedIni[MAX_PATH] = {0};
	TCHAR szTempSharedIni[MAX_PATH] = {0};

	_tcscpy(szSharedIni, szSharedFolder);
	_tcscat(szSharedIni, TEXT("Shared AdminStudio.ini"));

	if (TRUE == FileExists(szSharedIni))
	{
		_stprintf(szMessage, TEXT("AdminStudio Shared ini file '%s' exists. Taking backup"), szSharedIni);
		LogInfo(szMessage);
		_tcscpy(szTempSharedIni, szTempFolder);
		_tcscat(szTempSharedIni, TEXT("Shared AdminStudio.ini"));

		if (TRUE == FileExists(szTempSharedIni))
		{
			_stprintf(szMessage, TEXT("AdminStudio Shared ini file '%s' exists in TempFolder. Deleting existing file"), szTempSharedIni);
			LogInfo(szMessage);

			SetFileAttributes(szTempSharedIni, FILE_ATTRIBUTE_NORMAL);
			DeleteFile(szTempSharedIni);
		}

		if (TRUE == CopyFile(szSharedIni, szTempSharedIni, false))
		{
			_stprintf(szMessage, TEXT("AdminStudio Shared ini file successfullly backed up"));
			LogInfo(szMessage);
		}
		else
		{
			_stprintf(szMessage, TEXT("AdminStudio Shared ini file backed up FAILED"));
			LogInfo(szMessage);
		}
	}
	else
	{
		_stprintf(szMessage, TEXT("AdminStudio Shared ini file '%s' DOES NOT exist. Skipping backup"), szSharedIni);
		LogInfo(szMessage);		
	}

	TCHAR szEaXml[MAX_PATH] = {0};
	TCHAR szTempEaXml[MAX_PATH] = {0};

	_tcscpy(szEaXml, szSharedFolder);
	_tcscat(szEaXml, TEXT("EA_Default.xml"));

	if (TRUE == FileExists(szEaXml))
	{
		_stprintf(szMessage, TEXT("EA_Default.xml file '%s' exists. Taking backup"), szEaXml);
		LogInfo(szMessage);

		_tcscpy(szTempEaXml, szTempFolder);
		_tcscat(szTempEaXml, TEXT("EA_Default.xml"));

		if (TRUE == FileExists(szTempEaXml))
		{
			_stprintf(szMessage, TEXT("EA_Default.xml file '%s' exists in TempFolder. Deleting existing file"), szTempEaXml);
			LogInfo(szMessage);

			SetFileAttributes(szTempEaXml, FILE_ATTRIBUTE_NORMAL);
			DeleteFile(szTempEaXml);
		}

		if (TRUE == CopyFile(szEaXml, szTempEaXml, false))
		{
			_stprintf(szMessage, TEXT("EA_Default.xml file successfullly backed up"));
			LogInfo(szMessage);
		}
		else
		{
			_stprintf(szMessage, TEXT("EA_Default.xml file backed up FAILED"));
			LogInfo(szMessage);
		}
	}

	TCHAR szCustomActionData[MAX_PATH];
	_stprintf(szCustomActionData, TEXT("%s|%s"), szTempFolder, szSharedFolder);
	_stprintf(szMessage, TEXT("Setting CustomActionData: %s for restoration"), szCustomActionData);
	LogInfo(szMessage);

	MsiSetProperty(hInstall, TEXT("ASSharedFiles_Restore"), szCustomActionData);

	return ERROR_SUCCESS;
}

UINT __stdcall RestoreSharedFiles(MSIHANDLE hInstall)
{
	g_hInstall = hInstall;

	TCHAR szCustomActionData[MAX_BUFFER_LENGTH] = {0};
	TCHAR szTempFolder[MAX_PATH] = {0};
	TCHAR szSharedFolder[MAX_PATH] = {0};
	TCHAR szMessage[MAX_BUFFER_LENGTH] = {0};

	DWORD dwSize = MAX_PATH;
	MsiGetProperty(hInstall, TEXT("CustomActionData"), szCustomActionData, &dwSize);
	_stprintf(szMessage, TEXT("CustomActionData: %s received for restoration"), szCustomActionData);
	LogInfo(szMessage);

	TCHAR* pToken = _tcstok(szCustomActionData, TEXT("|"));
	if (pToken == NULL)
	{
		return ERROR_SUCCESS;
	}

	_tcscpy(szTempFolder, pToken);

	pToken = _tcstok(NULL, TEXT("|"));
	if (pToken == NULL)
	{
		return ERROR_SUCCESS;
	}

	_tcscpy(szSharedFolder, pToken);
	if (_tcslen(szTempFolder) <= 0 || _tcslen(szSharedFolder) <= 0)
	{
		_stprintf(szMessage, TEXT("Either TempFolder '%s' or Shared Folder '%s' returned zero length. Skipping restoration"), szTempFolder, szSharedFolder);
		LogInfo(szMessage);
		return ERROR_SUCCESS;
	}

	TCHAR szSharedIni[MAX_PATH] = {0};
	TCHAR szTempSharedIni[MAX_PATH] = {0};

	_tcscpy(szSharedIni, szSharedFolder);
	_tcscat(szSharedIni, TEXT("Shared AdminStudio.ini"));

	_tcscpy(szTempSharedIni, szTempFolder);
	_tcscat(szTempSharedIni, TEXT("Shared AdminStudio.ini"));

	if (TRUE == FileExists(szTempSharedIni))
	{
		_stprintf(szMessage, TEXT("AdminStudio Shared ini file '%s' exists. Restoring backup"), szTempSharedIni);
		LogInfo(szMessage);

		if (TRUE == FileExists(szSharedIni))
		{
			_stprintf(szMessage, TEXT("AdminStudio Shared ini file '%s' exists in Shared Folder. Deleting existing file"), szSharedIni);
			LogInfo(szMessage);

			SetFileAttributes(szSharedIni, FILE_ATTRIBUTE_NORMAL);
			DeleteFile(szSharedIni);
		}

		if (TRUE == CopyFile(szTempSharedIni, szSharedIni, false))
		{
			_stprintf(szMessage, TEXT("AdminStudio Shared ini file successfullly restored"));
			LogInfo(szMessage);
		}
		else
		{
			_stprintf(szMessage, TEXT("AdminStudio Shared ini file restoration FAILED"));
			LogInfo(szMessage);
		}

		SetFileAttributes(szTempSharedIni, FILE_ATTRIBUTE_NORMAL);
		DeleteFile(szTempSharedIni);
	}

	TCHAR szEaXml[MAX_PATH] = {0};
	TCHAR szTempEaXml[MAX_PATH] = {0};

	_tcscpy(szEaXml, szSharedFolder);
	_tcscat(szEaXml, TEXT("EA_Default.xml"));

	_tcscpy(szTempEaXml, szTempFolder);
	_tcscat(szTempEaXml, TEXT("EA_Default.xml"));


	if (TRUE == FileExists(szTempEaXml))
	{
		_stprintf(szMessage, TEXT("EA_Default.xml file '%s' exists. Restoring backup"), szTempEaXml);
		LogInfo(szMessage);

		if (TRUE == FileExists(szEaXml))
		{
			_stprintf(szMessage, TEXT("EA_Default.xml ini file '%s' exists in Shared Folder. Deleting existing file"), szEaXml);
			LogInfo(szMessage);

			SetFileAttributes(szEaXml, FILE_ATTRIBUTE_NORMAL);
			DeleteFile(szEaXml);
		}

		if (TRUE == CopyFile(szTempEaXml, szEaXml, false))
		{
			_stprintf(szMessage, TEXT("EA_Default.xml file successfullly restored"));
			LogInfo(szMessage);		
		}
		else
		{
			_stprintf(szMessage, TEXT("EA_Default.xml file restoration FAILED"));
			LogInfo(szMessage);
		}

		SetFileAttributes(szTempEaXml, FILE_ATTRIBUTE_NORMAL);
		DeleteFile(szTempEaXml);
	}

	return ERROR_SUCCESS;
}

