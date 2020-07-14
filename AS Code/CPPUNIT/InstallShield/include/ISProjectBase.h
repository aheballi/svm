// ISProjectBase.h: interface for the CISProjectBase class.
//
//////////////////////////////////////////////////////////////////////

#pragma once


class CISProjectBase  
{
public:
	CISProjectBase(bool bIsTemp = true);
	CISProjectBase(const stringx& sProjectPath, bool bIsTemp = true);
	virtual ~CISProjectBase();


	virtual MSIHANDLE GetMsiHandle() = 0;
	virtual void OpenProject() = 0;
	virtual void CloseProject() = 0;

	stringx GetProjectPath();

protected:

	stringx m_sProjectFilePath;
	
	bool m_bIsTemp;
};


