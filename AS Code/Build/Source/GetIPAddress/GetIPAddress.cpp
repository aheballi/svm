// GetIPAddress.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include <stdlib.h>
#include "msiquery.h"
#include "stdio.h"
#include "winsock2.h" 
#include "winbase.h"


BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    return TRUE;
}


UINT __stdcall GetMachineIPAddress(MSIHANDLE hModule)
{

	TCHAR hostname[MAX_PATH] = "\0";
	TCHAR szIPAddress[MAX_PATH] = "\0";
	WORD wVer = 0;
	WSADATA wData;

	PHOSTENT pHostinfo =  NULL;
	wVer = MAKEWORD(2, 0);

	/**********************************
	** Get computer name 
	***********************************/
	ULONG nTmp = 0;
	TCHAR szNewServerName[MAX_PATH] = "\0";

	// Fill the edit control with something
	nTmp = 254;
	if(GetComputerName(&szNewServerName[2], &nTmp))
	{
	szNewServerName[0] = szNewServerName[1] = '\\';
	}


	// Get IP Address 
	if ( WSAStartup( wVer, &wData ) == 0 )
	{

		if( gethostname ( hostname, sizeof(hostname)) == 0)
		{
			if((pHostinfo = gethostbyname(hostname)) != NULL)
			{
				_tcscpy(szIPAddress, inet_ntoa (*(struct in_addr *)*pHostinfo->h_addr_list));
			}
		}
		
		MsiSetProperty(hModule, "MACHINEIP", szIPAddress);
		WSACleanup( );
	} 
	return ERROR_SUCCESS;
}
