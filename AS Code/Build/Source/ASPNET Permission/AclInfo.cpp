//////////////////////////////////////////////////////////////////////////////
//   File               : AclInfo.cpp
//                        ^^^^^^^^^^^^
//   Author             : Saugata Chatterjee
//
//   Created            : Thursday, August 12, 2004
//
//   Purpose            : Add ASPNET user in Forlder/File
//
//   Feature            : SMS Web Console / Predeployment / Any other .NET project
//
//   Release            : AdminStudio
//
//   SourceSafe Location: 
//
//         
//   Change Log:
//      Date      Change
//      ----      ------
//
//////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ACLInfo.h"
#include <stdlib.h>

static const TCHAR* const lpszASPNET = _T("ASPNET");
static const TCHAR* const lpszNetService = _T("NETWORK SERVICE");
#define MSIVERSIONNT_2003 502

// Constructor
CACLInfo::CACLInfo(MSIHANDLE hInstall)
{
	m_hLogRecord = MsiCreateRecord(MSI_LOG_RECORD_FIELD_COUNT);
	m_hInstall = hInstall;
}


// Destructor
CACLInfo::~CACLInfo(void)
{
	//No need to close m_hInstall, it is passed by MSI to us
	if(m_hLogRecord)
		::MsiCloseHandle(m_hLogRecord);
}


HRESULT CACLInfo::SetSecurityPermission(_bstr_t m_bstrPath, _bstr_t m_bstrVersionNT)
{
	EXPLICIT_ACCESS ea;
	DWORD dwRes = 0;
	PACL pOldDACL=NULL, pNewDACL = NULL;
	PSECURITY_DESCRIPTOR pSD = NULL;
	HRESULT hr = E_FAIL;
	TCHAR lpszLogMessage[EIGHT_KB];

	if(m_hLogRecord != NULL && m_hInstall!=NULL)
	{
		sprintf(lpszLogMessage, _T("Enterd SetSecurityPermission():to set %s permissions"), (const char*) m_bstrPath);
		this->WriteToMSILog(lpszLogMessage);
	}

	if (m_bstrPath.length == 0) 
	{
		hr = ERROR_INVALID_PARAMETER;
#ifdef _DEBUG
		::MessageBox(NULL, _T("ERROR_INVALID_PARAMETER error"), _T("error ERROR_INVALID_PARAMETER "), MB_OK);
#endif
		return hr;
	}
	
	try
	{
		// Get a pointer to the existing DACL.

		dwRes = GetNamedSecurityInfo(m_bstrPath, SE_FILE_OBJECT, 
			  DACL_SECURITY_INFORMATION, NULL, NULL, &pOldDACL, NULL, &pSD);

		if (ERROR_SUCCESS != dwRes) 
		{
#ifdef _DEBUG
			::MessageBox(NULL, _T("SetSecurityPermission error"), _T("error SetSecurityPermission "), MB_OK);
#endif
			if (m_hLogRecord != NULL && m_hInstall!=NULL)
			{
			
				sprintf(lpszLogMessage, _T("SetSecurityPermission():GetNamedSecurityInfo Error %u"), dwRes);
				this->WriteToMSILog(lpszLogMessage);
			}
		}  
		else
		{
			// Initialize an EXPLICIT_ACCESS structure for the new ACE.
			ZeroMemory(&ea, sizeof(EXPLICIT_ACCESS));
			ea.grfAccessPermissions = GENERIC_ALL;
			ea.grfAccessMode = SET_ACCESS ;
			ea.grfInheritance= OBJECT_INHERIT_ACE | CONTAINER_INHERIT_ACE;
			ea.Trustee.TrusteeForm = TRUSTEE_IS_NAME;
#ifdef _DEBUG
			::MessageBox(NULL, _T("passed step 1"), _T("passed step 1 "), MB_OK);
#endif
			if (GetPermissionType(m_bstrVersionNT) == NETWORKSERVICE)
			{
				ea.Trustee.ptstrName = (TCHAR*)lpszNetService;
			}
			else
			{
				ea.Trustee.ptstrName = (TCHAR*)lpszASPNET;
			}
			
			// Create a new ACL that merges the new ACE
			// into the existing DACL.
#ifdef _DEBUG
			::MessageBox(NULL, _T("passed step 2"), _T("passed step 2 "), MB_OK);
#endif
			dwRes = SetEntriesInAcl(1, &ea, pOldDACL, &pNewDACL);
			if (ERROR_SUCCESS != dwRes)  
			{
#ifdef _DEBUG
				::MessageBox(NULL, _T("SetEntriesInAcl Error"), _T("Error in SetEntriesInAcl "), MB_OK);
#endif

				if(m_hLogRecord != NULL && m_hInstall!=NULL)
				{
					sprintf(lpszLogMessage, _T("SetAspNetPermission():SetEntriesInAcl Error %u\n"), dwRes);
					this->WriteToMSILog(lpszLogMessage);
				}

			}  
			else
			{
				// Attach the new ACL as the object's DACL.
#ifdef _DEBUG
				::MessageBox(NULL, _T("Attach the new ACL as the object's DACL func"), _T("Attach the new ACL as the object's DACL func "), MB_OK);
#endif

				dwRes = SetNamedSecurityInfo(m_bstrPath, SE_FILE_OBJECT, 
											DACL_SECURITY_INFORMATION, NULL, NULL, pNewDACL, NULL);
				if (ERROR_SUCCESS != dwRes)  
				{
#ifdef _DEBUG
					::MessageBox(NULL, _T("SetAspNetPermission Error"), _T("Error in SetAspNetPermission "), MB_OK);
#endif
					if (m_hLogRecord != NULL && m_hInstall != NULL)
					{
						sprintf(lpszLogMessage, _T("SetAspNetPermission():SetNamedSecurityInfo Error %u"), dwRes);
						this->WriteToMSILog(lpszLogMessage);
					}
				} 
				else
				{
#ifdef _DEBUG
					::MessageBox(NULL, _T("SetAspNetPermission passed"), _T("passed SetAspNetPermission "), MB_OK);
#endif
					hr = S_OK;
				}
			}	
		}
	}
	catch(...)
	{
#ifdef _DEBUG
		::MessageBox(NULL, _T("exception Error"), _T("exception "), MB_OK);
#endif
		hr = S_FALSE;
	}

	//cleanup
	if (pSD != NULL) 
		LocalFree((HLOCAL) pSD); 
	if (pNewDACL != NULL) 
		LocalFree((HLOCAL) pNewDACL);

	return hr;
}


EPermType CACLInfo::GetPermissionType(const _bstr_t& bstrVersionNT)
{
#ifdef _DEBUG
	MessageBox(0, "Entered GetPermissionType()", "c", MB_OK);
#endif

	EPermType permRetVal = UNKNOWN;
	
	TCHAR lpszLogMessage[MAX_PATH]={0};
	DWORD dwBuf = MAX_PATH;
	
#ifdef _DEBUG    
	::MessageBox(NULL, _T("GetPermissionType()"), bstrVersionNT , MB_OK);
#endif
	sprintf(lpszLogMessage, _T("VersionNT Property= %s\n"), (const char*) bstrVersionNT);
	WriteToMSILog(lpszLogMessage);

	int nVer = atoi(bstrVersionNT);
	
	if (nVer >=  MSIVERSIONNT_2003)
		permRetVal = NETWORKSERVICE;
	else
		permRetVal = ASPNET;
    
#ifdef _DEBUG
	MessageBox(0, "Returning from GetPermissionType()", "c", MB_OK);
#endif

    return permRetVal;
}


bool CACLInfo::WriteToMSILog(LPCSTR lpszMessage)
{
	bool bRetVal = false;
	TCHAR* lpszLogPrefixString	= _T("ISASSETUP:: ");

	long lMsgLength = _tcslen(lpszMessage);
	lMsgLength += _tcslen(lpszLogPrefixString);

	TCHAR lpszMsgWithPrefix[MAX_PATH] = {0};
	// INSTALLMESSAGE
	try
	{
		if(m_hLogRecord)
		{
			_tcscpy(lpszMsgWithPrefix, lpszMsgWithPrefix);
			_tcscat(lpszMsgWithPrefix, lpszMessage);
			UINT uiResult = MsiRecordSetString(m_hLogRecord, 0, lpszMsgWithPrefix);
		
			int iResult = MsiProcessMessage(m_hInstall, (INSTALLMESSAGE)INSTALLMESSAGE_INFO, m_hLogRecord);
			if(IDOK == iResult)
				bRetVal = true;
		}
	}
	catch(...)
	{
	}

	return bRetVal;
}


