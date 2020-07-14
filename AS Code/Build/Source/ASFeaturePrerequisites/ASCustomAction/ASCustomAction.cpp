// ASFeatureMaintenance.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include <windows.h>
#include "msi.h"
#include "msiquery.h"
#include <tchar.h>
#include <shellapi.h>
#include <iostream>
#include <string>
#include <stdlib.h>
#include <list>

#ifdef _MANAGED
#pragma managed(push, off)
#endif

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
    return TRUE;
}

#ifdef _MANAGED
#pragma managed(pop)
#endif

#define PRODUCTCODEBUFFERLENGTH 39

struct featureMSIMapping {
	TCHAR featureName[100];
	TCHAR productCode[PRODUCTCODEBUFFERLENGTH];
};
typedef std::basic_string<TCHAR> TString;


BOOL __stdcall IsMSIBeingUninstalled(MSIHANDLE hMsi);
UINT __stdcall PopulateFeaturePrerequisiteList(MSIHANDLE hMsi, std::list<featureMSIMapping> *prerequisiteList);
UINT __stdcall LaunchAppAndWait(MSIHANDLE hMsi, LPCTSTR exePath, LPCTSTR cmdLine);
LPCTSTR __stdcall GetASMaintenanceEXEPath(MSIHANDLE hMsi);
UINT __stdcall LogMessage(MSIHANDLE hMsi, LPCTSTR functionName, LPCTSTR message);
UINT __stdcall FeaturePrerequisiteAbort(MSIHANDLE hMsi, LPCTSTR finalDialogName);

//Goal is to create a list of msi productcodes that need to be reinstalled or uninstalled based on user
//selection of feature states from the maintenance ui sequence.  Then launch an installed EXE with this
//information on the command line to have it actual do the reinstalling or uninstalling.  RunAs is used
//when running on Vista to get only one UAC prompt for this operation
UINT __stdcall FeaturePrerequisiteMaintenanceMode(MSIHANDLE hMsi)
{
	
	std::list<featureMSIMapping> prerequisiteList;
	PopulateFeaturePrerequisiteList(hMsi, &prerequisiteList);

	std::list<featureMSIMapping>::iterator iter1;

	TCHAR IsMaintenanceProperty[100];

	DWORD bufLen;
	bufLen = _countof(IsMaintenanceProperty);
	MsiGetProperty(hMsi, _T("_IsMaintenance"), IsMaintenanceProperty, &bufLen);
	
	TString maintenanceProperty = IsMaintenanceProperty;
	TString cmdLine = _T("");		

	if (maintenanceProperty == _T("Reinstall"))
	{
		cmdLine += _T("-Reinstall ");
		for(iter1 = prerequisiteList.begin(); iter1 != prerequisiteList.end(); iter1++)
		{
			INSTALLSTATE pstate,paction; 
			MsiGetFeatureState(hMsi, iter1->featureName, &pstate, &paction);
			if(pstate == INSTALLSTATE_LOCAL && MsiQueryProductState(iter1->productCode) == INSTALLSTATE_DEFAULT)
			{
				cmdLine += iter1->productCode;
				cmdLine += _T(",");
			}
		}
	}
	else if (maintenanceProperty == _T("Remove"))
	{
		cmdLine += _T("-Uninstall ");
		for(iter1 = prerequisiteList.begin(); iter1 != prerequisiteList.end(); iter1++)
		{
			INSTALLSTATE pstate,paction; 
			MsiGetFeatureState(hMsi, iter1->featureName, &pstate, &paction);
			if(pstate == INSTALLSTATE_LOCAL && MsiQueryProductState(iter1->productCode) == INSTALLSTATE_DEFAULT)
			{
				cmdLine += iter1->productCode;
				cmdLine += _T(",");
			}
		}
	}
	else if (maintenanceProperty == _T("Change"))
	{
		cmdLine += _T("-Uninstall ");
		for(iter1 = prerequisiteList.begin(); iter1 != prerequisiteList.end(); iter1++)
		{
			INSTALLSTATE pstate,paction; 
			MsiGetFeatureState(hMsi, iter1->featureName, &pstate, &paction);
			if(pstate == INSTALLSTATE_LOCAL && paction == INSTALLSTATE_ABSENT && MsiQueryProductState(iter1->productCode) == INSTALLSTATE_DEFAULT)
			{
				cmdLine += iter1->productCode;
				cmdLine += _T(",");
			}
		}
	}
	else
	{
		LogMessage(hMsi, _T("FeaturePrerequisiteMaintenanceMode"), _T("About to return -1 because _IsMaintenance is not defined"));
		return -1;
	}

	if (cmdLine.length() < PRODUCTCODEBUFFERLENGTH)
	{
		LogMessage(hMsi, _T("FeaturePrerequisiteMaintenanceMode"), _T("command line does not include any productcodes - hence nothing to be done"));
		return ERROR_SUCCESS;
	}
	
	TString finalCmdLine = cmdLine.substr(0, cmdLine.length() - 1);

	TCHAR ASMaintenanceEXEPath[300];
	bufLen = _countof(ASMaintenanceEXEPath);
	MsiGetProperty(hMsi, _T("SUPPORTDIR"), ASMaintenanceEXEPath, &bufLen);
	
	TString ASMaintenanceEXE = ASMaintenanceEXEPath;
	ASMaintenanceEXE += _T("\\ASMaintenance.exe");
		
	TString asmaintenanceLogInfo = _T("AS feature prerequisite handle rollback command line = ");
	asmaintenanceLogInfo += ASMaintenanceEXE;
	asmaintenanceLogInfo += _T(" ");
	asmaintenanceLogInfo += finalCmdLine;
	LogMessage(hMsi, _T("FeaturePrerequisiteMaintenanceMode"), asmaintenanceLogInfo.c_str());
	
	LaunchAppAndWait(hMsi, ASMaintenanceEXE.c_str(), finalCmdLine.c_str());

	return ERROR_SUCCESS;	
}

//Correct feature state in execute sequence if the associated MSI does not match the feature state
//Should be used in the execute sequence
//Does not work correctly if more than one associated MSI exists for a given feature
UINT __stdcall FeaturePrerequisiteSynchronizeState(MSIHANDLE hMsi)
{
	LPCTSTR functionName = _T("FeaturePrerequisiteSynchronizeState");
	LogMessage(hMsi, functionName, _T("This custom action corrects certain feature states in the execute sequence if the associated MSI does not match the feature state."));

	if (IsMSIBeingUninstalled(hMsi) == true)
	{
		LogMessage(hMsi, functionName, _T("Doing nothing because the main product is being removed"));
		return ERROR_SUCCESS;
	}

	std::list<featureMSIMapping> prerequisiteList;
	PopulateFeaturePrerequisiteList(hMsi, &prerequisiteList);

	std::list<featureMSIMapping>::iterator iter1;

	for(iter1 = prerequisiteList.begin(); iter1 != prerequisiteList.end(); iter1++)
	{
		INSTALLSTATE featureState, featureAction; 
		MsiGetFeatureState(hMsi, iter1->featureName, &featureState, &featureAction);
		TString logMessage = _T("Feature: ");

		if (featureState != INSTALLSTATE_LOCAL)
		{
			if ((featureAction == INSTALLSTATE_LOCAL) && (MsiQueryProductState(iter1->productCode) != INSTALLSTATE_DEFAULT))
			{
				logMessage += iter1->featureName;
				logMessage += _T("; ");
				logMessage += _T("Installed: Not Local;   Request: Local;   Action: Null - Associated MSI is not installed");
				LogMessage(hMsi, functionName, logMessage.c_str());
				
				MsiSetFeatureState(hMsi, iter1->featureName, INSTALLSTATE_ABSENT);
			} 
			else if ((featureAction != INSTALLSTATE_LOCAL) && MsiQueryProductState(iter1->productCode) == INSTALLSTATE_DEFAULT)
			{
				logMessage += iter1->featureName;
				logMessage += _T("; ");
				logMessage += _T("Installed: Not Local;   Request: Not Local;   Action: Local - Associated MSI is installed");
				LogMessage(hMsi, functionName, logMessage.c_str());
				
				MsiSetFeatureState(hMsi, iter1->featureName, INSTALLSTATE_LOCAL);
			}
		}
		else
		{
			if ((featureAction == INSTALLSTATE_ABSENT) && (MsiQueryProductState(iter1->productCode) == INSTALLSTATE_DEFAULT))
			{
				logMessage += iter1->featureName;
				logMessage += _T("; ");
				logMessage += _T("Installed: Local;   Request: Absent;   Action: Null - Associated MSI is not absent");
				LogMessage(hMsi, functionName, logMessage.c_str());

				MsiSetFeatureState(hMsi, iter1->featureName, INSTALLSTATE_LOCAL);
			} 
			else if ((featureAction != INSTALLSTATE_ABSENT) && MsiQueryProductState(iter1->productCode) != INSTALLSTATE_DEFAULT)
			{
				logMessage += iter1->featureName;
				logMessage += _T("; ");
				logMessage += _T("Installed: Local;   Request: Not Absent;   Action: Absent - Associated MSI is absent");
				LogMessage(hMsi, functionName, logMessage.c_str());

				MsiSetFeatureState(hMsi, iter1->featureName, INSTALLSTATE_ABSENT);
			}
		}
		
	}
	
	LogMessage(hMsi, functionName, _T("All done"));
	return ERROR_SUCCESS;
}

BOOL __stdcall IsMSIBeingUninstalled(MSIHANDLE hMsi)
{
	//check the REMOVE property and also check ASREMOVE property to see if either is equal to ALL
	//ASREMOVE is a custom property being set from the MaintenanceType dialog ControlEvent
	TCHAR removeValue[10];
	TCHAR asremoveValue[10];
	DWORD bufLen;

	bufLen = 10;
	MsiGetProperty(hMsi, _T("REMOVE"), removeValue, &bufLen);

	bufLen = 10;
	MsiGetProperty(hMsi, _T("ASREMOVE"), asremoveValue, &bufLen);
	
	TString removeProperty = removeValue;
	TString asremoveProperty = asremoveValue;
	
	if (removeProperty == _T("ALL"))
		return true;

	if (asremoveProperty == _T("ALL"))
		return true;

	return false;
}


UINT __stdcall FeaturePrerequisiteUserCancel(MSIHANDLE hMsi)
{
	return FeaturePrerequisiteAbort(hMsi, _T("SetupInterrupted"));
}

UINT __stdcall FeaturePrerequisiteInstallAbort(MSIHANDLE hMsi)
{
	return FeaturePrerequisiteAbort(hMsi, _T("SetupCompleteError"));
}

//This is called after ExecuteAction in the UI sequence to uninstall all of the installed feature
//prerequisites in the event of the main AS client install aborting or rolling back.
UINT __stdcall FeaturePrerequisiteAbort(MSIHANDLE hMsi, LPCTSTR finalDialogName)
{
	//Pass all feature prerequisite productcodes that are installed on uninstall command line
	//to feature maintenance EXE.
	//EXE location may need to be changed to support files because it will not have been installed.

	std::list<featureMSIMapping> prerequisiteList;
	PopulateFeaturePrerequisiteList(hMsi, &prerequisiteList);

	std::list<featureMSIMapping>::iterator iter1;

	//TString msiInstallList = _T("-Install ");
	TString msiUninstallList = _T("-Uninstall ");

	
	for(iter1 = prerequisiteList.begin(); iter1 != prerequisiteList.end(); iter1++)
	{
		INSTALLSTATE pstate, paction; 
		MsiGetFeatureState(hMsi, iter1->featureName, &pstate, &paction);
		if ((pstate != INSTALLSTATE_LOCAL) && (MsiQueryProductState(iter1->productCode) == INSTALLSTATE_DEFAULT))
		{
			msiUninstallList += iter1->productCode;
			msiUninstallList += _T(",");
		}
	/*	else if ((pstate == INSTALLSTATE_LOCAL) && (MsiQueryProductState(iter1->productCode) != INSTALLSTATE_DEFAULT))
		{
			//need to install MSIs associated with features that were not successfully uninstalled
			//need to maybe check prerequisite condition and command line
			msiInstallList += iter1->productCode;
			msiInstallList += _T(",");
		}
		*/
	}
	
	TString fullCommandLine = _T("");
	/*
	if (msiInstallList.length() > PRODUCTCODEBUFFERLENGTH)
	{
		fullCommandLine += msiInstallList.substr(0, msiInstallList.length() - 1);
		fullCommandLine += _T(" ");
	}
	*/

	if (msiUninstallList.length() > PRODUCTCODEBUFFERLENGTH)
	{
		fullCommandLine += msiUninstallList.substr(0, msiUninstallList.length() - 1);
	}
		
	LogMessage(hMsi,_T("FeaturePrerequisiteAbort"),fullCommandLine.c_str());
		
	
	if (fullCommandLine.length() > PRODUCTCODEBUFFERLENGTH)
	{
	
		TCHAR ASMaintenanceEXEPath[300];
		DWORD bufLen = _countof(ASMaintenanceEXEPath);
		MsiGetProperty(hMsi, _T("SUPPORTDIR"), ASMaintenanceEXEPath, &bufLen);
		
		TString ASMaintenanceEXE = ASMaintenanceEXEPath;
		ASMaintenanceEXE += _T("\\ASMaintenance.exe");
			
		TString asmaintenanceLogInfo = _T("AS feature prerequisite handle rollback command line = ");
		asmaintenanceLogInfo += ASMaintenanceEXE;
		asmaintenanceLogInfo += _T(" ");
		asmaintenanceLogInfo += fullCommandLine;
		LogMessage(hMsi, _T("FeaturePrerequisiteAbort"), asmaintenanceLogInfo.c_str());
		
		LaunchAppAndWait(hMsi, ASMaintenanceEXE.c_str(), fullCommandLine.c_str());
	}
	else
	{
		LogMessage(hMsi, _T("FeaturePrerequisiteAbort"), _T("None of the feature prerequisites need to be uninstalled because they are not currently installed."));
	}
	
	MsiDoAction(hMsi,finalDialogName);
	return ERROR_SUCCESS;
}

//This method queries a custom table called ASFeaturePrerequisites that lists all of the feature prerequisite
//to associated msi productcode mappings
UINT __stdcall PopulateFeaturePrerequisiteList(MSIHANDLE hMsi, std::list<featureMSIMapping> *prerequisiteList)
{
	MSIHANDLE hViewlist;
	MSIHANDLE hwnd = MsiGetActiveDatabase(hMsi);
	MsiDatabaseOpenView(hwnd,_T("Select * from `ASFeaturePrerequisites`"),&hViewlist);
	MsiViewExecute(hViewlist, 0);

	PMSIHANDLE hresult;
	DWORD bufLen;
	
	while (MsiViewFetch(hViewlist,&hresult) == ERROR_SUCCESS)
	{
		featureMSIMapping prerequisite;

		bufLen = _countof(prerequisite.featureName);
		MsiRecordGetString(hresult, 1, prerequisite.featureName, &bufLen);

		bufLen = _countof(prerequisite.productCode);
		MsiRecordGetString(hresult, 2, prerequisite.productCode, &bufLen);

		TString featureInfo = _T("Feature - ");
		featureInfo += prerequisite.featureName;
		featureInfo += _T("; MSI ProductCode - ");
		featureInfo += prerequisite.productCode;
		LogMessage(hMsi, _T("PopulateFeaturePrerequisiteList"), featureInfo.c_str());

		prerequisiteList->push_back(prerequisite);
	}

	MsiViewClose(hViewlist);
	MsiCloseHandle(hViewlist);
	MsiCloseHandle(hwnd);
	return ERROR_SUCCESS;
}

//Uses ShellExecuteEx api because it allows for waiting for the process to finish and using RunAs verb
//for UAC elevation on Vista
UINT __stdcall LaunchAppAndWait(MSIHANDLE hMsi, LPCTSTR exePath, LPCTSTR cmdLine)
{
	TString laawLogInfo = _T("LaunchAppAndWait helper function will launch following command line = ");
	laawLogInfo += exePath;
	laawLogInfo += _T(" ");
	laawLogInfo += cmdLine;
	LogMessage(hMsi, _T("LaunchAppAndWait"), laawLogInfo.c_str());

	HWND msiWindowHandle = FindWindow(_T("MsiDialogCloseClass"), NULL);
	if (msiWindowHandle == NULL)
	{
		LogMessage(hMsi, _T("LaunchAppAndWait"), _T("Could not find the MSI window handle with FindWindow"));
		msiWindowHandle = 0;
	} 
	else
	{
		LogMessage(hMsi, _T("LaunchAppAndWait"), _T("Found the MSI window handle with FindWindow"));
	}


	SHELLEXECUTEINFO ExecInfo = { sizeof(ExecInfo) };
	ExecInfo.fMask = SEE_MASK_FLAG_DDEWAIT | SEE_MASK_NOCLOSEPROCESS;
	ExecInfo.hwnd = msiWindowHandle;
	ExecInfo.lpVerb = _T("open");
	ExecInfo.lpFile = exePath;
	ExecInfo.lpParameters = cmdLine;
	ExecInfo.nShow = SW_SHOW;

	TCHAR versionNTProperty[4];
	DWORD bufLen = _countof(versionNTProperty);
	MsiGetProperty(hMsi, _T("VersionNT"), versionNTProperty, &bufLen);
	
	//TString osProperty = versionNTProperty;
	int osPropertyInt = _ttoi(versionNTProperty);
	//Setting lpVerb to runas causes an UAC prompt to occur on Vista - should this be a greater than style comparison?
	if (osPropertyInt >= 600)
	{
		LogMessage(hMsi, _T("LaunchAppAndWait"), _T("Vista detected, will use Runas verb to run msiexec for UAC elevation prompt"));
		ExecInfo.lpVerb = _T("runas");
	}

	ShellExecuteEx(&ExecInfo);

	WaitForSingleObject(ExecInfo.hProcess, INFINITE);
	CloseHandle(ExecInfo.hProcess);

	return ERROR_SUCCESS;
}

UINT __stdcall LogMessage(MSIHANDLE hMsi, LPCTSTR functionName, LPCTSTR message)
{

	PMSIHANDLE hRec = MsiCreateRecord(2);
	MsiRecordSetString(hRec, 0, _T("AdminStudio [Time]: [1] - [2]"));
	MsiRecordSetString(hRec, 1, functionName);
	MsiRecordSetString(hRec, 2, message);
	MsiProcessMessage(hMsi, INSTALLMESSAGE_INFO, hRec);

	return ERROR_SUCCESS;
}