// CAPermAdd.cpp : Defines the entry point for the DLL application to set ASPNET Permission.
//

#include "stdafx.h"
#include "CAPermAdd.h"
#include "AclInfo.h"

#define MAX_BUFFER_LENGTH 1024
#define NO_RECORDS_FOUND 100


BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
    }
    return TRUE;
}

//	----------------------------------------------------------------
UINT __stdcall ASSetPermission(MSIHANDLE hInstall)
{
	TCHAR* lpszCustomActionData = new TCHAR[0];
	DWORD dwLen = 0;

	//Call with 0 length to get the required buffer length
	UINT uResult = ::MsiGetProperty(hInstall, _T("CustomActionData"), lpszCustomActionData, &dwLen);

	//allocate the buffer to the correct size
	delete[] lpszCustomActionData;
	lpszCustomActionData = new TCHAR[dwLen];
	
	if((ERROR_SUCCESS == ::MsiGetProperty(hInstall, _T("CustomActionData"), lpszCustomActionData, &dwLen))
		&& _tcslen(lpszCustomActionData) > 0)
	{
		CACLInfo aclInfoObject(hInstall);

		TCHAR* lpszVersionNT = NULL;
		lpszVersionNT = _tcstok(lpszCustomActionData,"|");

		TCHAR* lpszPathArray = NULL;
		lpszPathArray = _tcstok(NULL, "|");

		TCHAR* lpszPath = NULL;
		lpszPath = _tcstok(lpszPathArray, ";");		
		while (lpszPath != NULL)
		{
			aclInfoObject.SetSecurityPermission(lpszPath, lpszVersionNT);
			lpszPath = _tcstok(NULL, ";");
		}
	}
	delete[] lpszCustomActionData;
 
	return 0;
}

void LogMessage(MSIHANDLE hInstall, const TCHAR* szMessage)
{
	PMSIHANDLE hRecord = MsiCreateRecord(1);
	TCHAR szLogMessage[MAX_BUFFER_LENGTH * 2] = {0};
	_tcscpy(szLogMessage, TEXT("ISASSETUP:: "));
	_tcscat(szLogMessage, szMessage);

	MsiRecordSetString(hRecord, 0, szLogMessage);
	MsiProcessMessage(hInstall, INSTALLMESSAGE(INSTALLMESSAGE_INFO), hRecord);
}

UINT ExtractFileFromBinaryTable(MSIHANDLE hInstall,
							    TCHAR* szBinaryEntry,
								TCHAR* szBinaryFile)
{
	TCHAR szQuery[1024] = {0};

	PMSIHANDLE hView = NULL;
	PMSIHANDLE hRecord = NULL;
	UINT unResult = ERROR_SUCCESS;

	PMSIHANDLE hDatabase = MsiGetActiveDatabase(hInstall);

	if (0 == hDatabase)
	{
		LogMessage(hInstall, TEXT("MsiGetActiveDatabase FAILED"));
		return ERROR_INSTALL_FAILURE;
	}

	HANDLE hFile = NULL;

	hFile = CreateFile(szBinaryFile, 
					   GENERIC_WRITE,
					   FILE_SHARE_READ, 
					   NULL,
					   CREATE_ALWAYS,
					   FILE_ATTRIBUTE_NORMAL, 
					   NULL);

	if (hFile == INVALID_HANDLE_VALUE)
	{
		LogMessage(hInstall, TEXT("CreateFile FAILED"));
		unResult = (UINT) INVALID_HANDLE_VALUE;
		return unResult;
	}

	_stprintf(szQuery,
			  TEXT("SELECT `Data` "
				   "FROM `Binary` "
				   "WHERE Name = '%s'"), 
			  szBinaryEntry);

	if (ERROR_SUCCESS != (unResult = MsiDatabaseOpenView(hDatabase, 
														 szQuery, 
														 &hView)))
	{
		LogMessage(hInstall, TEXT("MsiDatabaseOpenView FAILED"));
		return unResult;
	}

	if (ERROR_SUCCESS != (unResult = MsiViewExecute(hView, 0)))
	{
		LogMessage(hInstall, TEXT("MsiViewExecute FAILED"));
		return unResult;
	}

	if (ERROR_SUCCESS == MsiViewFetch(hView, &hRecord))
	{
		char szStreamData[MAX_BUFFER_LENGTH] = {0};

		DWORD dwRead = MAX_BUFFER_LENGTH;
		DWORD dwWritten = 0;
		do 
		{
			if (ERROR_SUCCESS != (unResult = MsiRecordReadStream(hRecord, 
																 1, 
																 szStreamData,
																 &dwRead)))
			{
				break;		
			}
			else
			{
				WriteFile(hFile, szStreamData, dwRead, &dwWritten, NULL);
			}
		}
		while (dwRead == MAX_BUFFER_LENGTH);
	}
	else
	{
		LogMessage(hInstall, TEXT("MsiViewFetch returned NO RECORDS"));
		unResult = NO_RECORDS_FOUND;	
	}

	CloseHandle(hFile);
	MsiViewClose(hView);

	return unResult;
}

BOOL AreStringsIdentical(const TCHAR* lpszString1,
						 const TCHAR* lpszString2)
{
	if (CSTR_EQUAL == CompareString(LOCALE_SYSTEM_DEFAULT,
									NORM_IGNORECASE,
									lpszString1,
									_tcslen(lpszString1),
									lpszString2,
									_tcslen(lpszString2)))
	{
		return TRUE;
	}

	return FALSE;
}

UINT __stdcall ExtractBinaryFile(MSIHANDLE hInstall)
{
	TCHAR szBinFile[MAX_BUFFER_LENGTH] = {0};
	TCHAR szBinFolder[MAX_BUFFER_LENGTH] = {0};
	TCHAR szMessage[MAX_BUFFER_LENGTH] = {0};

	DWORD dwSize = MAX_BUFFER_LENGTH;
	MsiGetProperty(hInstall, TEXT("BINENTRY"), szBinFile, &dwSize);

	dwSize = MAX_BUFFER_LENGTH;
	MsiGetProperty(hInstall, TEXT("BINFILE"), szBinFolder, &dwSize);

	if (_tcslen(szBinFolder) > 0 && _tcslen(szBinFolder) > 0)
	{
		
		if (ERROR_SUCCESS != ExtractFileFromBinaryTable(hInstall, szBinFile, szBinFolder))
		{
			_stprintf(szMessage, TEXT("Could not extract binary entry '%s' to file '%s'"), szBinFile, szBinFolder);
		}
		else
		{
			_stprintf(szMessage, TEXT("SUCCESSFULLY extracted binary entry '%s' to file '%s'"), szBinFile, szBinFolder);
		}

		LogMessage(hInstall, szMessage);
	}
	else
	{
		LogMessage(hInstall, TEXT("BINFOLDER and BINFILE property is not defined"));
	}

	return ERROR_SUCCESS;
}

UINT __stdcall UpdateSettingsXML(MSIHANDLE hInstall)
{
	TCHAR szINSTALLDIR[MAX_BUFFER_LENGTH] = {0};
	DWORD dwSize = MAX_BUFFER_LENGTH;
	MsiGetProperty(hInstall, TEXT("INSTALLDIR"), szINSTALLDIR, &dwSize);

	TCHAR szMessage[MAX_BUFFER_LENGTH] = {0};
	_stprintf(szMessage, TEXT("INSTALLDIR property returned '%s'"), szINSTALLDIR);
	LogMessage(hInstall, szMessage);

	if (_tcslen(szINSTALLDIR) > 0)
	{	
		TCHAR szSettingsXML[1024] = {0};
		_tcscpy(szSettingsXML, szINSTALLDIR);

		TCHAR szProductName[MAX_BUFFER_LENGTH] = {0};
		

		dwSize = MAX_BUFFER_LENGTH;
		MsiGetProperty(hInstall, TEXT("ProductName"), szProductName, &dwSize);

		if (_tcslen(szProductName) > 0)
		{
			if (TRUE == AreStringsIdentical(szProductName, TEXT("Repackager")))
			{				
				_tcscat(szSettingsXML, TEXT("Settings.xml"));		
				_stprintf(szMessage, TEXT("Found repackager, adjusting the settings.xml location to '%s'"), szSettingsXML);
			}
			else
			{
				_tcscat(szSettingsXML, TEXT("Repackager\\Settings.xml"));
				_stprintf(szMessage, TEXT("Found AdminStudio, adjusting the settings.xml location to '%s'"), szSettingsXML);
			}

			LogMessage(hInstall, szMessage);
		}
		else
		{
			return ERROR_SUCCESS;
		}

		if (ERROR_SUCCESS != ExtractFileFromBinaryTable(hInstall, TEXT("settings.xml"), szSettingsXML))
		{
			_stprintf(szMessage, TEXT("Could not extract binary entry 'settings.xml' to file '%s'"), szSettingsXML);			
		}
		else
		{
			_stprintf(szMessage, TEXT("SUCCESSFULLY extracted binary entry settings.xml to file '%s'"), szSettingsXML);
		}

		LogMessage(hInstall, szMessage);
	}
	else
	{
		LogMessage(hInstall, TEXT("Could not read INSTALLDIR. Exiting"));
	}


	return ERROR_SUCCESS;
}
