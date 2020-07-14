// ISProjectBase.cpp: implementation of the CISProjectBase class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ISProjectBase.h"

#include "iscppunit.h"		//Brings in the supporting code for registering and running test cases
#include "iscppunitutils.h"

CISProjectBase::CISProjectBase(bool bIsTemp) :
	m_bIsTemp(bIsTemp)
{

}

CISProjectBase::~CISProjectBase()
{
	if(m_bIsTemp)
	{
		BOOL bResult = ::DeleteFile(m_sProjectFilePath);
		CPPUNIT_ASSERT(TRUE == bResult);
	}
}

CISProjectBase::CISProjectBase(const stringx& sProjectPath, bool bIsTemp) :
	m_bIsTemp(bIsTemp),
	m_sProjectFilePath(sProjectPath)
{

}

stringx CISProjectBase::GetProjectPath()
{
	if(m_sProjectFilePath.empty())
	{
		pathx sTempDir(is::pathx::special_folder(is::pathx::temporary));

		pathx sProjectFile;
		sProjectFile.make_temp(sTempDir);

		m_sProjectFilePath = sProjectFile.c_str();
	}

	return m_sProjectFilePath;
}
