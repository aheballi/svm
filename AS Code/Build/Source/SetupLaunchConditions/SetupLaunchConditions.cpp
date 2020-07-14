// SetupLaunchConditions.cpp : Defines the entry point for the DLL application.
//
#include "stdafx.h"
#include "SetupLaunchConditions.h"
#include <stdlib.h>
#include <msidefs.h>
#include <assert.h>
#include "..\..\..\source\AdminHelper\AdminEditions.h"

///////////////////////////////////////////////////////////////////////////
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

//This function is nearly identical to ValidateRepackager except that it also accepts SCCM limited edition serial numbers,
//and it does not perform the ZENworks 10 check or IS Premier edition check.
//It is called from the SCCM AdminStudio setup to validate the serial number specified by the user.

//We probably could have avoided duplicating the function and instead checked the EDITION property in ValidateRepackager
//to determine whether to accept the SCCM serial number.
UINT __stdcall ValidateSCCM (MSIHANDLE hInstall)
{
	try
	{
		TCHAR szSerialNumber[MAX_PATH] = {0};

		DWORD cchValue = MAX_PATH;
		MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, NULL);
		MsiGetProperty(hInstall, IPROPNAME_PIDKEY, szSerialNumber, &cchValue);
			
		TCHAR szCopy[23] = {0};
		lstrcpy(szCopy, szSerialNumber);
			
		int nResult = -1;
		
		TCHAR szSupportDirVal[MAX_PATH];
		DWORD cspValue = MAX_PATH;
		MsiGetProperty(hInstall, "SUPPORTDIR", szSupportDirVal, &cspValue);
		
		_tcscat(szSupportDirVal, "\\AdminHelper9.dll");
		
		HINSTANCE hDll = LoadLibrary(szSupportDirVal);
		
		if (!hDll)
			return ERROR_VALIDATION_FAILED;

		typedef int (WINAPI *DLLVALIDATETOKEN)(LPCTSTR); 

		DLLVALIDATETOKEN pfnValidateToken = (DLLVALIDATETOKEN) ::GetProcAddress (hDll, _T("ValidateToken"));
		if (pfnValidateToken)
			nResult = (pfnValidateToken) (szSerialNumber);

		if (nResult == 0)
		{
			typedef int (WINAPI *DLLGETEDITIONFROMSERIAL)(LPCTSTR); 
			DLLGETEDITIONFROMSERIAL pfnGetEditionFromSerial = (DLLGETEDITIONFROMSERIAL) ::GetProcAddress (hDll, _T("GetEditionFromSerial"));
			if (pfnGetEditionFromSerial)
				nResult = (pfnGetEditionFromSerial) (szSerialNumber);

			if ((nResult > 0) && 
				(nResult != PRODUCT_EDITION_SUBLICENSE_LANDESK))
			{
				//Valid Standard or higher and also SCCM - not accepting ZENworks serial
				MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, (LPCTSTR) szCopy);
				FreeLibrary(hDll);
				return ERROR_SUCCESS;
			}
		}
		
		FreeLibrary(hDll);
		return ERROR_VALIDATION_FAILED;
	}
	catch(...)
	{
	}

	return ERROR_VALIDATION_FAILED;
}

//This function is nearly identical to ValidateRepackager except that this function does not do the InstallShield
//premier edition check.  This function is called from the standalone AXT ZENworks converter setup to verify
//the user entered serial number.
UINT __stdcall ValidateZENworks (MSIHANDLE hInstall)
{
	try
	{
		TCHAR szSerialNumber[MAX_PATH] = {0};
		DWORD cchValue = MAX_PATH;
		MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, NULL);
		MsiGetProperty(hInstall, IPROPNAME_PIDKEY, szSerialNumber, &cchValue);
			
		TCHAR szCopy[23] = {0};
		lstrcpy(szCopy, szSerialNumber);
			
		int nResult = -1;
		
		TCHAR szSupportDirVal[MAX_PATH];
		DWORD cspValue = MAX_PATH;
		MsiGetProperty(hInstall, "SUPPORTDIR", szSupportDirVal, &cspValue);
		
		_tcscat(szSupportDirVal, "\\AdminHelper9.dll");
		
		HINSTANCE hDll = LoadLibrary(szSupportDirVal);
		
		if (!hDll)
			return ERROR_VALIDATION_FAILED;
		 
		typedef int (WINAPI *DLLVALIDATESERIAL)(LPCTSTR, int*);
		
		//Check to see if serial number is a ZENworks 10 serial number
		DLLVALIDATESERIAL pfnValidateSerial = (DLLVALIDATESERIAL) ::GetProcAddress (hDll, _T("ValidateSerial"));
		int novellEdition = 0;

		if (pfnValidateSerial)
			nResult = (pfnValidateSerial) (szSerialNumber, &novellEdition);

		if (novellEdition == 10)
		{
			//serial number is a ZENworks 10 serial number
			MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, (LPCTSTR) szCopy);
			FreeLibrary(hDll);
			return ERROR_SUCCESS;
		}

		//Check to see if serial number is AdminStudio Standard edition or higher
		typedef int (WINAPI *DLLVALIDATETOKEN)(LPCTSTR);
		DLLVALIDATETOKEN pfnValidateToken = (DLLVALIDATETOKEN) ::GetProcAddress (hDll, _T("ValidateToken"));

		if (pfnValidateToken)
			nResult = (pfnValidateToken) (szSerialNumber);

		if (nResult == 0)
		{
			typedef int (WINAPI *DLLGETEDITIONFROMSERIAL)(LPCTSTR); 
			DLLGETEDITIONFROMSERIAL pfnGetEditionFromSerial = (DLLGETEDITIONFROMSERIAL) ::GetProcAddress (hDll, _T("GetEditionFromSerial"));
			if (pfnGetEditionFromSerial)
				nResult = (pfnGetEditionFromSerial) (szSerialNumber);

			if ((nResult > 0) && 
				(nResult != PRODUCT_EDITION_SUBLICENSE_LANDESK))
			{
				//Valid Standard edition or higher
				MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, (LPCTSTR) szCopy);
				FreeLibrary(hDll);
				return ERROR_SUCCESS;
			}
		}

		FreeLibrary(hDll);
		return ERROR_VALIDATION_FAILED;
	}
	catch(...)
	{
	}

	return ERROR_VALIDATION_FAILED;
}

//This function is called from the standalone Repackager setup to validate that the user specified serial number
//is Novell ZENworks 10 edition, at least AS Standard Edition, or InstallShield Premier edition
UINT __stdcall ValidateRepackager (MSIHANDLE hInstall)
{
	try
	{
		TCHAR szSerialNumber[MAX_PATH] = {0};

		DWORD cchValue = MAX_PATH;
		MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, NULL);
		MsiGetProperty(hInstall, IPROPNAME_PIDKEY, szSerialNumber, &cchValue);
		
		TCHAR szCopy[23] = {0};
		lstrcpy(szCopy, szSerialNumber);
	
		int nResult = -1;
		
		TCHAR szSupportDirVal[MAX_PATH];
		DWORD cspValue = MAX_PATH;
		MsiGetProperty(hInstall, "SUPPORTDIR", szSupportDirVal, &cspValue);
		_tcscat(szSupportDirVal, "\\AdminHelper9.dll");
		HINSTANCE hDll = LoadLibrary(szSupportDirVal);

		if (!hDll)
			return ERROR_VALIDATION_FAILED;
		 
		typedef void (WINAPI *DLLVALIDATESERIAL)(LPCTSTR, int*);
		
		//Check to see if serial number is a ZENworks serial number
		DLLVALIDATESERIAL pfnValidateSerial = (DLLVALIDATESERIAL) ::GetProcAddress (hDll, _T("ValidateSerial"));
		int novellEdition = 0;

		if (pfnValidateSerial)
			(pfnValidateSerial) (szSerialNumber, &novellEdition);

		if (novellEdition == 10)
		{
			//serial number is a ZENworks 10 serial number
			MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, (LPCTSTR) szCopy);
			FreeLibrary(hDll);
			return ERROR_SUCCESS;
		}

		typedef int (WINAPI *DLLVALIDATETOKEN) (LPCTSTR);
		//Check to see if serial number is AdminStudio Standard edition or higher
		DLLVALIDATETOKEN pfnValidateToken = (DLLVALIDATETOKEN) ::GetProcAddress (hDll, _T("ValidateToken"));

		if (pfnValidateToken)
			nResult = (pfnValidateToken) (szSerialNumber);

		if (nResult == 0)
		{
			typedef int (WINAPI *DLLGETEDITIONFROMSERIAL)(LPCTSTR); 
			DLLGETEDITIONFROMSERIAL pfnGetEditionFromSerial = (DLLGETEDITIONFROMSERIAL) ::GetProcAddress (hDll, _T("GetEditionFromSerial"));
			if (pfnGetEditionFromSerial)
				nResult = (pfnGetEditionFromSerial) (szSerialNumber);

			if ((nResult > 0) && 
				(nResult != PRODUCT_EDITION_SUBLICENSE_SMS)&& 
				(nResult != PRODUCT_EDITION_SUBLICENSE_LANDESK))
			{
				//Valid Standard or higher - not accepting limited edition serials
				MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, (LPCTSTR) szCopy);
				FreeLibrary(hDll);
				return ERROR_SUCCESS;
			}
		}
		
		//Check to see if serial number is InstallShield Premier edition
		TCHAR szSer[23] = {0};
		lstrcpy(szSer, szCopy); //Just in case since for some reason this is done above!

		DLLVALIDATETOKEN pfnValidateToken2 = (DLLVALIDATETOKEN) ::GetProcAddress (hDll, _T("ValidateToken2"));
		if (pfnValidateToken2)
			nResult = (pfnValidateToken2) (szSer);

		if (nResult == 0)
		{
			//Serial number validated
			MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, (LPCTSTR) szCopy);
			MsiSetProperty(hInstall, AS_IS_CUSTOM, _T("1"));
			FreeLibrary(hDll);
			return ERROR_SUCCESS;
		}
		
		FreeLibrary(hDll);
		return ERROR_VALIDATION_FAILED;
	}
	catch(...)
	{
	}

	return ERROR_VALIDATION_FAILED;
}

UINT __stdcall ValidateQM (MSIHANDLE hInstall)
{
	try
	{
		TCHAR szSerialNumber[MAX_PATH] = {0};

		DWORD cchValue = MAX_PATH;
		MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, NULL);
		MsiGetProperty(hInstall, IPROPNAME_PIDKEY, szSerialNumber, &cchValue);
			
		TCHAR szCopy[23] = {0};
		lstrcpy(szCopy, szSerialNumber);
			
		int nResult = -1;
		
		TCHAR szSupportDirVal[MAX_PATH];
		DWORD cspValue = MAX_PATH;
		MsiGetProperty(hInstall, "SUPPORTDIR", szSupportDirVal, &cspValue);
		
		_tcscat(szSupportDirVal, "\\AdminHelper9.dll");
		
		HINSTANCE hDll = LoadLibrary(szSupportDirVal);
		
		 
		if (hDll) 
		{
			//if dll loaded
			typedef int (WINAPI *DLLVALIDATETOKEN)(LPCTSTR); 

			DLLVALIDATETOKEN pfnValidateToken = (DLLVALIDATETOKEN) ::GetProcAddress (hDll, _T("ValidateToken"));
			if (pfnValidateToken)
				nResult = (pfnValidateToken) (szSerialNumber);
		}

		else
		{
			//Can't load dll
			return ERROR_VALIDATION_FAILED;

		}

		if (nResult == 0)
		{
			typedef int (WINAPI *DLLGETEDITIONFROMSERIAL)(LPCTSTR); 
			DLLGETEDITIONFROMSERIAL pfnGetEditionFromSerial = (DLLGETEDITIONFROMSERIAL) ::GetProcAddress (hDll, _T("GetEditionFromSerial"));
			if (pfnGetEditionFromSerial)
				nResult = (pfnGetEditionFromSerial) (szSerialNumber);

			if ((nResult > 0) && 
				(nResult != PRODUCT_EDITION_SUBLICENSE_LANDESK) &&
				(nResult != PRODUCT_EDITION_SUBLICENSE_STD)&&
				(nResult != PRODUCT_EDITION_SUBLICENSE_STD_VIRT)&&
				(nResult != PRODUCT_EDITION_SUBLICENSE_SMS))
			{
				MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, (LPCTSTR) szCopy);
			}
			else
			{
				return ERROR_VALIDATION_FAILED;
			}

		}
		else
		{
			//Serial number can't be validated
			return ERROR_VALIDATION_FAILED;
		}

		FreeLibrary(hDll);
	}
	catch(...)
	{

	}

	return ERROR_SUCCESS;
}

// --------------------------------------------------------------------------
//	Description: ValidateToken2 : 
//
//	Parameters: LPCTSTR sSerialNumber2
//				LPCTSTR sHeader2 
//
//	Returns: 
// --------------------------------------------------------------------------
int ValidateToken2 (LPCTSTR sSerialNumber2, LPCTSTR sHeader2 )
{
	if (_tcslen( sSerialNumber2 ) != 4)  
		return ERROR_VALIDATION_FAILED;

	if (toupper(sSerialNumber2[0]) != sHeader2[0]) 
		return ERROR_VALIDATION_FAILED;

	if (sSerialNumber2[1] != sHeader2[1])
		return ERROR_VALIDATION_FAILED;

	if (sSerialNumber2[2] != sHeader2[2])
		return ERROR_VALIDATION_FAILED;

	if (isdigit(sSerialNumber2[3] == 0))
		return ERROR_VALIDATION_FAILED;

	
	return ERROR_VALIDATION_SUCCESS;
}

// --------------------------------------------------------------------------
//	Description: ValidateToken3 : 
//
//	Parameters: LPCTSTR sSerialNumber
//				int iBase
//				int iIncrement
//				LPCTSTR sHeader 
//
//	Returns: 
// --------------------------------------------------------------------------
int ValidateToken3 (LPCTSTR sSerialNumber, int iBase, int iIncrement, LPCTSTR sHeader )
{
	if (_tcslen( sSerialNumber ) != 10)  
		return ERROR_VALIDATION_FAILED;
	
	if (toupper(sSerialNumber[0]) != sHeader[0]) 
		return ERROR_VALIDATION_FAILED;

	if (sSerialNumber[1] != sHeader[1])
		return ERROR_VALIDATION_FAILED;

	if (sSerialNumber[2] != sHeader[2])
		return ERROR_VALIDATION_FAILED;

	//Need to validate digits 3-10
	TCHAR *sNumToValidate = (LPTSTR)&sSerialNumber[3];

	long lNumToValidate = atoi (sNumToValidate);
	long lResult = (lNumToValidate - iBase) % iIncrement;

	if (lResult != 0) 
		return ERROR_VALIDATION_FAILED;
	else
		return ERROR_VALIDATION_SUCCESS;
}

//	----------------------------------------------------------------------------
int GetSerialNumber(MSIHANDLE hInstall, TCHAR* lpszSerialNumber)
{
	assert(lpszSerialNumber != NULL);

	TCHAR szValue[MAX_PATH];

	long lResult;
	lResult = MsiSetProperty(hInstall, IPROPNAME_PRODUCTID, NULL);

	DWORD cchValue = MAX_PATH;
	MsiGetProperty(hInstall, IPROPNAME_PIDKEY, szValue, &cchValue);
	//MessageBox(NULL, szValue, "Get Serial Number", MB_OK);
	int ch = ' ';

	LPTSTR lpszPtr = _tcsrchr(szValue, ch);

	while (lpszPtr != NULL)
	{
		if (lpszPtr)
			*lpszPtr = '\0';

		lpszPtr = _tcsrchr(szValue, ch);	
	}

	//	Validate length
	if (_tcslen( szValue ) != SERIALNUMBER_LENGTH)
		return ERROR_VALIDATION_FAILED;

	_tcscpy(lpszSerialNumber, szValue);
	//MessageBox(NULL, lpszSerialNumber, "Get Serial Number", MB_OK);
	return ERROR_SUCCESS;
}



