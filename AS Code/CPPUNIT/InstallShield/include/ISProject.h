// ISProject.h: interface for the CISProject class.
//
//////////////////////////////////////////////////////////////////////

#pragma once

#include "ISProjectBase.h"
#include "ISFolderUtils.h"

class CISProject : public CISProjectBase  
{
public:
	CISProject();
	virtual ~CISProject();

	virtual MSIHANDLE GetMsiHandle();
	virtual void OpenProject();
	virtual void CloseProject();

	operator MSIHANDLE()
	{
		return GetMsiHandle();
	}

	CComPtr<IsmAuto::IProjectL> GetProject();
	CComPtr<IsmAuto::IProjectRootL> GetProjectRoot();
	CComPtr<IsmAuto::IProductL> GetProduct();

	stringx GetProjTemplatePath();


private:
	
	CComPtr<IsmAuto::IProjectL> m_spProject;
	CComPtr<IsmAuto::IProjectRootL> m_spProjectRoot;
	CComPtr<IsmAuto::IProductL> m_spProduct;

	EnumIsProjectType m_eISProjType;

};


