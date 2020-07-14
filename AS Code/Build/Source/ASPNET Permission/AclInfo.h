//////////////////////////////////////////////////////////////////////////////
//   File               : AclInfo.h
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

#pragma once

#ifndef _ACL_INFO_CLASS_H
#define _ACL_INFO_CLASS_H

#include <iostream>
#include <comdef.h>
#include <windows.h>
#include <aclapi.h>
#include "msi.h"

#define MSI_LOG_RECORD_FIELD_COUNT		1
#define EIGHT_KB						8096			

typedef enum ePermType
{
	UNKNOWN =0,
	ASPNET,
	NETWORKSERVICE,
}
EPermType;

class CACLInfo
{
public:
	// construction / destruction

	// constructs a new CACLInfo object
	// bstrPath - path of the folder / file
	CACLInfo(MSIHANDLE hInstall);
	virtual ~CACLInfo(void);

	// Adds ASPNET user to a file/directory
	HRESULT SetSecurityPermission(_bstr_t bstrPath, _bstr_t m_bstrVersionNT);
	EPermType GetPermissionType(const _bstr_t& bstrVersionNT);

	//Writing log information in MSI
	bool WriteToMSILog(LPCTSTR lpszMessage);

private:
	MSIHANDLE	m_hLogRecord;	// MSI Handle for logging 
	MSIHANDLE	m_hInstall;		 


};

#endif // _ACL_INFO_CLASS_H