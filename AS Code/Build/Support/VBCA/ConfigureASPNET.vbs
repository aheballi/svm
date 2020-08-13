Option Explicit

const IDOK = 1
const IDCANCEL = 2
const IDABORT = 3
const msiMessageTypeInfo = &H04000000


'**********************************************************************************
function ConfigureASPNET()
On Error Resume Next
ConfigureASPNET = IDOK

LogMessage "ConfigureASPNET", "Entered ConfigureASPNET function - goal is to install asp.net and update scripts for ASPNET 2.0 websites and enable ASPNET 2.0 web extension on IIS 6.0 and up machines.  Also the AS virtual directories will be assigned ASPNET 2.0 version."
    
dim oShell
dim ret
Set oShell = CreateObject ("Wscript.Shell")

dim PropArray
PropArray = Split(Property("CustomActionData"), ";") 

dim versionnt
dim windowsFolder

versionnt = PropArray(0)
windowsFolder = PropArray(1)

if (Cint(versionnt) >= 502) then
	LogMessage "ConfigureASPNET", "About to run following command: " & windowsFolder & "Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe -iru -enable"

	'Goal is to install IIS and only update scripts for version 2.0 sites.  Also to enable ASPNET 2.0 web extension
	'0 = hidden UI
	'true = wait for completion
	'Assume that aspnet_regiis.exe exists because .NET must be installed by this point
	'ret = oShell.Run("C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe -iru -enable", 0, true)
	ret = oShell.Run(windowsFolder & "Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe -iru -enable", 0, true)
	if err.number <> 0 then
        LogMessage "ConfigureASPNET", "Error occurred - Return value = " & Cstr(ret)
        LogMessage "ConfigureASPNET", "Error occurred - " & err.number & " " & err.description
    end if
else
	LogMessage "ConfigureASPNET", "About to run following command: " & windowsFolder & "Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe -iru"
	'OS should be Win 2000 Server - thus no need for -enable option
	ret = oShell.Run(windowsFolder & "Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe -iru", 0, true)
	if err.number <> 0 then
        LogMessage "ConfigureASPNET", "Error occurred - Return value = " & Cstr(ret)
        LogMessage "ConfigureASPNET", "Error occurred - " & err.number & " " & err.description
    end if
end if

LogMessage "ConfigureASPNET", "About to set the ASP.NET version for the three AS virtual directories to be .NET 2.0"

ret = oShell.Run(windowsFolder & "Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe -sn W3SVC/1/ROOT/PreDeployTestReports", 0, true)
if err.number <> 0 then
    LogMessage "ConfigureASPNET", "Error occurred - Return value = " & Cstr(ret)
    LogMessage "ConfigureASPNET", "Error occurred - " & err.number & " " & err.description
end if
    
ret = oShell.Run(windowsFolder & "Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe -sn W3SVC/1/ROOT/PreDeployTestService", 0, true)
if err.number <> 0 then
    LogMessage "ConfigureASPNET", "Error occurred - Return value = " & Cstr(ret)
    LogMessage "ConfigureASPNET", "Error occurred - " & err.number & " " & err.description
end if

ret = oShell.Run(windowsFolder & "Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe -sn W3SVC/1/ROOT/ASDistribution", 0, true)
if err.number <> 0 then
    LogMessage "ConfigureASPNET", "Error occurred - Return value = " & Cstr(ret)
    LogMessage "ConfigureASPNET", "Error occurred - " & err.number & " " & err.description
end if

Set oShell = Nothing

LogMessage "ConfigureASPNET", "About to exit ConfigureASPNET function - Always returning success because not succeeding should not be catastrophic"

end function


'**********************************************************************************
function LogMessage(strFunctionName, strMessage)
	dim objRecord
 	Set objRecord = Installer.CreateRecord(2)
 	objRecord.StringData(0) = "AdminStudio [Time]: [1] - [2]"
 	objRecord.StringData(1) = strFunctionName
 	objRecord.StringData(2) = strMessage
 	Message msiMessageTypeInfo, objRecord
	set objRecord = nothing
end function
