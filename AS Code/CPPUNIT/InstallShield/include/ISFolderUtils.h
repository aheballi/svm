// ISFolderUtils.h: interface for the ISFolderUtils class.
//
//////////////////////////////////////////////////////////////////////

#pragma once

enum EnumIsProjectType
{
	eBasicMsi = 0,
};

enum EnumFolderId
{
	eRootSupport = 0,
	eLocalizedSupport = 1
};

class CISFolderUtils  
{
public:

	static stringx GetFolderPath(EnumFolderId eFolderId);
	static stringx GetRootInstallFolder();

	static void CopyTemplateToFolder(EnumIsProjectType eIsProjectType, const stringx& sTarget);
	static stringx GetTemplateFileName(EnumIsProjectType eIsProjectType);
};

