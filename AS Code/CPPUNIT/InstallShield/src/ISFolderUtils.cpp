// ISFolderUtils.cpp: implementation of the ISFolderUtils class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ISFolderUtils.h"

EXTERN_C IMAGE_DOS_HEADER __ImageBase;
#define HINST_THISCOMPONENT ((HINSTANCE)&__ImageBase)


// src\inc
#include "GlobalConstants.h"

stringx CISFolderUtils::GetFolderPath(EnumFolderId eFolderId)
{
	stringx sFolder = GetRootInstallFolder();

	switch(eFolderId) 
	{
	case eRootSupport:
		sFolder.path_append(L"Support");
		break;

	case eLocalizedSupport:
		sFolder.path_append(L"Support\\0409");
		break;
	}

	return sFolder;
}

// Assumes the unit test is runing from within a binary in the system folder. We
// don't use appservices here so that we don't have to call into ISAppServices, which
// may not be built yet...
stringx CISFolderUtils::GetRootInstallFolder()
{
	stringx sInstallFolder;

	stringx sFilename;
	if (GetModuleFileName(HINST_THISCOMPONENT,
		sFilename.get_buffer(MAX_PATH), MAX_PATH))
	{
		sInstallFolder = sFilename.path_dir();
		sInstallFolder = sInstallFolder.path_dir();
	}
	else
	{
		//ATLASSERT(false);	
	}

	return sInstallFolder;
}

void CISFolderUtils::CopyTemplateToFolder(EnumIsProjectType eIsProjectType, const stringx& sTarget)
{
	stringx sSourceFile = GetFolderPath(eLocalizedSupport);
	sSourceFile.path_append(GetTemplateFileName(eIsProjectType));
	//ATLASSERT(PathFileExists(sSourceFile));

	BOOL bResult = ::CopyFile(sSourceFile, sTarget, FALSE);
	//ATLASSERT(bResult);
}

stringx CISFolderUtils::GetTemplateFileName(EnumIsProjectType eIsProjectType)
{
	stringx sTemplateName;

	switch(eIsProjectType) 
	{
	case eBasicMsi:
		sTemplateName = ISMSI_PROJECT_BLANKTEMPLATE;
		break;
	}

	return sTemplateName;

}
