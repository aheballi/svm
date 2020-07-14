// ISProject.cpp: implementation of the CISProject class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ISProject.h"

#ifndef __IsMsiEntity_h__
namespace IsMsiEntity
{
	#include "ismsientity.h"
}
#define IsmAutoProject IsMsiEntity::IsmAutoProject
#define IMsiDatabase IsMsiEntity::IMsiDatabase
#endif



CISProject::CISProject() :
	m_eISProjType(eBasicMsi)
{

}

CISProject::~CISProject()
{
	CloseProject();
}

MSIHANDLE CISProject::GetMsiHandle()
{
	MSIHANDLE hMsi;

	CComPtr<IMsiDatabase> spIsMsiDB = is_com_cast<IMsiDatabase>(m_spProject);
	hrx hr = spIsMsiDB->get_Handle(&hMsi);
	
	return hMsi;
}

void CISProject::OpenProject()
{
	hrx hr = ISCoCreateInstance(ISMSIENTITY_DLL,__uuidof(IsmAutoProject),&m_spProject);

	CComPtr<IsmAuto::IProjectRoot> spPrjRoot;
	CISFolderUtils::CopyTemplateToFolder(eBasicMsi, GetProjectPath());
	hr = m_spProject->Open(GetProjectPath(), VARIANT_FALSE, &spPrjRoot);
	hr = spPrjRoot.QueryInterface(&m_spProjectRoot);
}

void CISProject::CloseProject()
{
	if(m_spProject)
	{
		hrx hr = m_spProject->Close();
		m_spProduct.Release();
		m_spProjectRoot.Release();
		m_spProject.Release();
	}
}

CComPtr<IsmAuto::IProjectL> CISProject::GetProject()
{
	return m_spProject;
}

CComPtr<IsmAuto::IProjectRootL> CISProject::GetProjectRoot()
{
	return m_spProjectRoot;
}

CComPtr<IsmAuto::IProductL> CISProject::GetProduct()
{
	if(!m_spProduct)
	{
		CComPtr<IsmAuto::IProduct> spProduct;
		hrx hr = GetProjectRoot()->get_ActiveProduct(&spProduct);
		hr = spProduct.QueryInterface(&m_spProduct);
	}

	return m_spProduct;
}



