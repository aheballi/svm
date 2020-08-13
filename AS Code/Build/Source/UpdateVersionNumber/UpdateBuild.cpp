// UpdateBuild.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "iostream.h"
#include <vector>
#include <string>

typedef std::basic_string<TCHAR> tstring;

void UpdateBuild(char* szFileName, char* szBuildNo);

int main(int argc, char* argv[])
{

	CoInitialize(NULL);

	if(argc != 3)
	{
		cout << "Usage:  UpdateBuild <FileName> <Buildno>" ;
	}
	else
	{
		UpdateBuild(argv[1], argv[2]);
	}

	CoUninitialize();
	
	return 0;
}

// --------------------------------------------------------------------------
void UpdateBuild(char* szFileName, char* szBuildNo)
{
	CComPtr<_ISWiProject> spProject;

	HRESULT hr = spProject.CoCreateInstance(OLESTR("ISWiAutomation.ISWiProject"));

	if(SUCCEEDED(hr))
	{
		hr = spProject->OpenProject(szFileName, VARIANT_FALSE);

		if(SUCCEEDED(hr))
		{
			CComBSTR bstrVersion;

			hr = spProject->get_ProductVersion(&bstrVersion);

			USES_CONVERSION;
			tstring strVersion = OLE2T(bstrVersion);

			tstring::size_type nPos = strVersion.find_last_of(_T('.'));
			if (nPos != tstring::npos)
			{
				tstring strMainVersionNumber = strVersion.substr(0, nPos + 1);
				if (strMainVersionNumber.length())
				{
					TCHAR szVersion[MAX_PATH];
					wsprintf(szVersion, _T("%s%03d"), strMainVersionNumber.c_str(), ::atoi(szBuildNo));

					bstrVersion = szVersion;

					hr = spProject->put_ProductVersion(&bstrVersion);
		
					hr = spProject->SaveProject();
				}
			}
			hr = spProject->CloseProject();
		}
	}
}