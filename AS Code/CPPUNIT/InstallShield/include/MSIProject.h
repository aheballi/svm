// MSIProject.h: interface for the CMSIProject class.
//
//////////////////////////////////////////////////////////////////////

#pragma once

#include "ISProjectBase.h"

class CMSIProject : public CISProjectBase  
{
public:

	CMSIProject();
	CMSIProject(bool bIsTemp);
	CMSIProject(const stringx& sPath, bool bIsTemp = true);
	virtual ~CMSIProject(){};

	virtual MSIHANDLE GetMsiHandle();
	virtual void OpenProject();
	virtual void CloseProject();

	operator MSIHANDLE()
	{
		return GetMsiHandle();
	}

private:
	PMSIHANDLE m_hMsi;

};


