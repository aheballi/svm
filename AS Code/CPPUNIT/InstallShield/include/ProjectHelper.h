#pragma once

#include "ISFolderUtils.h"
#include "globalconstants.h"
#include "iscocreateinproc.h"
#include "iscomutils.h"
#include "singleton.h"
#include "ismautowrapper.h"

#ifndef __IsMsiEntity_h__
namespace IsMsiEntity
{
	#include "ismsientity.h"
}
#define IsmAutoProject IsMsiEntity::IsmAutoProject
#define IRecord IsMsiEntity::IRecord
#endif


const stringx DEFAULT_PROJECPATH = L"CppUnitProjects";

class CProjectHolder;

///////////////////////////////////////////////////////////////////////////////////
//	USING_PROJECT_SINGLETON(Name,Base,Project)
//	Helper macro for creating custom project singleton classes that derive
//	from the basic project type singleton classes
//
//	Name:	The name of the project singleton toye that you want to create and will 
//			then use from code
//	Base:	The base class that you want your custom class to derive from
//	Project:The name that you want to give to your project file.
///////////////////////////////////////////////////////////////////////////////////
#define USING_PROJECT_SINGLETON(Name,Base,Project) \
class C##Name : public C##Base \
{ \
public: \
stringx GetProjectName(){return Project;} \
}; \
typedef CSingleton<C##Name > ##Name; \
##Name* ##Name::_instance=0;

///////////////////////////////////////////////////////////////////////////////////
//	DEFINE_PROJECT_SINGLETON(Name,Project,Path,Template)
//	Helper macro for creating project singleton class for specific project types
//
//	Name:	The name of the project singleton toye that you want to create and will 
//			then use from code
//	Project:The name that you want to give to your project file.
//	Path:	The relative path to store the project file in
//	Template: The project file template to use	
///////////////////////////////////////////////////////////////////////////////////
#define DEFINE_PROJECT_SINGLETON(Name,Project,Path,Template) \
class C##Name : public CProjectHolder\
{ \
public: \
C##Name() \
{ \
CreateAndOpenProject(); \
} \
virtual stringx GetProjectName(){return Project;} \
virtual stringx GetProjectPath(){return Path;}\
virtual stringx GetTemplateName(){return Template;}\
}; \
typedef CSingleton<C##Name > ##Name; 

///////////////////////////////////////////////////////////////////////////////////
//	CProjectHolder
//	Virtual class containing base functionality for opening and maintaining project pointers
///////////////////////////////////////////////////////////////////////////////////
class CProjectHolder
{
public:
	IsmAuto::IProject* GetProject()
	{
		return m_spProject;
	}

	IsmAuto::IProjectRoot* GetProjectRoot()
	{
		return m_spProjectRoot;
	}

	void CleanProject(bool bFast = false)
	{
		CloseProject();
		if(!bFast)
		{
			CreateNewProject();
		}
		OpenProject();
	}
	CProjectHolder()
	{
	}

protected:
	void CreateAndOpenProject()
	{
		CreateNewProject();
		OpenProject();
	}
	
	void CreateNewProject()
	{
		stringx sTemplateFile = GetTemplateFilePath();
		m_sProjectPath = GetProjectsDir();
		CreateDirectory(m_sProjectPath,NULL);
		m_sProjectPath.path_append(GetProjectName());
		CopyFile(sTemplateFile,m_sProjectPath,FALSE);
	}

	void OpenProject()
	{
		hrx hr = ISCoCreateInstance(ISMSIENTITY_DLL,__uuidof(IsmAutoProject),&m_spProject);
		hr = m_spProject->Open(m_sProjectPath,VARIANT_FALSE,&m_spProjectRoot);
	}

	void CloseProject()
	{
		hrx hr = m_spProject->Close();
		m_spProject.Release();
		m_spProjectRoot.Release();
	}

	stringx GetTemplateFilePath()
	{
		stringx sResult = CISFolderUtils::GetFolderPath(eLocalizedSupport);
		sResult.path_append(GetTemplateName());
		return sResult;
	}

	stringx GetProjectsDir()
	{
		TCHAR szPathCurrent[MAX_PATH] = {0};
		::GetCurrentDirectory(MAX_PATH, szPathCurrent);
		
		stringx sResult(szPathCurrent);
		sResult = sResult.path_dir();
		sResult.path_append(GetProjectPath());
		return sResult;
	}
	virtual stringx GetProjectName()=0;
	virtual stringx GetProjectPath()=0;
	virtual stringx GetTemplateName()=0;
	
private:
	stringx m_sProjectPath;
	CComPtr<IsmAuto::IProject> m_spProject;
	CComPtr<IsmAuto::IProjectRoot> m_spProjectRoot;
};

///////////////////////////////////////////////////////////////////////////////////
//	CProjectInstallScript
//	Class that contains information for loading an InstallScript project
//	Designed to be used with CProjectHolder
///////////////////////////////////////////////////////////////////////////////////
const stringx INSTALLSCRIPT_PROJECTNAME = L"CppUnitInstallScript.ism";
const stringx INSTALLSCRIPT_PROJECPATH = DEFAULT_PROJECPATH;
DEFINE_PROJECT_SINGLETON(INSTALLSCRIPT_PROJECT,INSTALLSCRIPT_PROJECTNAME,INSTALLSCRIPT_PROJECPATH,ISMSI_PROJECT_SCRIPT_PRO_TEMPLATE);

///////////////////////////////////////////////////////////////////////////////////
//	CProjectInstallScriptMsi
//	Class that contains information for loading an InstallScript MSI project
//	Designed to be used with CProjectHolder
///////////////////////////////////////////////////////////////////////////////////
const stringx INSTALLSCRIPT_MSI_PROJECTNAME = L"CppUnitInstallScriptMsi.ism";
const stringx INSTALLSCRIPT_MSI_PROJECPATH = DEFAULT_PROJECPATH;
DEFINE_PROJECT_SINGLETON(INSTALLSCRIPT_MSI_PROJECT,INSTALLSCRIPT_MSI_PROJECTNAME,INSTALLSCRIPT_MSI_PROJECPATH,ISMSI_PROJECT_SCRIPT);

///////////////////////////////////////////////////////////////////////////////////
//	CProjectBasicMsi
//	Class that contains information for loading a Basic MSI project
//	Designed to be used with CProjectHolder
///////////////////////////////////////////////////////////////////////////////////

const stringx BASIC_MSI_PROJECTNAME = L"CppUnitBasicMsi.ism";
const stringx BASIC_MSI_PROJECPATH = DEFAULT_PROJECPATH;
DEFINE_PROJECT_SINGLETON(BASIC_MSI_PROJECT,BASIC_MSI_PROJECTNAME,BASIC_MSI_PROJECPATH,ISMSI_PROJECT_BLANKTEMPLATE);
