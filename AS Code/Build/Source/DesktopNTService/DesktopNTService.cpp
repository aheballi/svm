// DesktopNTService.cpp : Defines the entry point for the application.
//

#include "stdafx.h"

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
 	// TODO: Place code here.
	SC_HANDLE hServiceManager = OpenSCManager(NULL,NULL,SC_MANAGER_ALL_ACCESS);
	SC_HANDLE hService = OpenService(hServiceManager,"FLEXnet AdminStudio Enterprise Server",SC_MANAGER_ALL_ACCESS);
	if(hService)
	{
		BOOL bSuccess = ChangeServiceConfig(hService,SERVICE_WIN32_OWN_PROCESS | SERVICE_INTERACTIVE_PROCESS,
			SERVICE_NO_CHANGE,SERVICE_NO_CHANGE,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
		bSuccess = StartService(hService,0,NULL);
		Sleep(30000);
	}
	return 0;
}



