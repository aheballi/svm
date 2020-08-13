// MSIProject.cpp: implementation of the CMSIProject class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "MSIProject.h"

CMSIProject::CMSIProject() :
	CISProjectBase(true)
{
	OpenProject();
}

CMSIProject::CMSIProject(bool bIsTemp) :
	CISProjectBase(bIsTemp)
{

}

CMSIProject::CMSIProject(const stringx& sPath, bool bIsTemp) :
	CISProjectBase(m_sProjectFilePath, bIsTemp)
{

}

void CMSIProject::OpenProject()
{
	ismsi::MsiOpenDatabase(GetProjectPath(), MSIDBOPEN_CREATEDIRECT, &m_hMsi);
}

void CMSIProject::CloseProject()
{
	ismsi::MsiCloseHandle(m_hMsi);
}

MSIHANDLE CMSIProject::GetMsiHandle()
{
	return m_hMsi;
}