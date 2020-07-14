Option Explicit
On Error Resume Next

Const IDOK = 1
Const IDCANCEL = 2
Const IDABORT = 3
Const msiMessageTypeInfo = &H04000000


'Goal is to obtain the localized name of the Authenticated Users group on the local machine

Function GetAuthenticatedUsersLocalizedName()
LogMessage "GetAuthenticatedUsersLocalizedName","Sets LOCALIZEDAUTHENTICATEDUSERS property to the value of the localized name of the Authenticated Users group which is obtained through a WMI call"

Dim strComputer
Dim objWMIService
Dim objAccount

strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

if Err.number <> 0 then
    LogMessage "GetAuthenticatedUsersLocalizedName", "Error - not able to create wmi service object. " & "Description: " & Err.Description
    LogMessage "GetAuthenticatedUsersLocalizedName", "Default value of Authenticated Users will be used"
    GetAuthenticatedUsersLocalizedName = IDOK
    Exit Function
end if

'S-1-5-11 is the well known SID for the Authenticated Users group (always the same SID)
Set objAccount = objWMIService.Get _
    ("Win32_SID.SID='S-1-5-11'")

if Err.number <> 0 then
    LogMessage "GetAuthenticatedUsersLocalizedName", "Error - not able to obtain account object for Authenticated Users. " & "Description: " & Err.Description
    LogMessage "GetAuthenticatedUsersLocalizedName", "Default value of Authenticated Users will be used"
    GetAuthenticatedUsersLocalizedName = IDOK
    Exit Function
end if

'The default value for this property in the project is Authenticated Users
Property("LOCALIZEDAUTHENTICATEDUSERS") = objAccount.AccountName

Set objAccount = nothing
Set objWMIService = nothing

LogMessage "GetAuthenticatedUsersLocalizedName","Finished setting the LOCALIZEDAUTHENTICATEDUSERS property"
GetAuthenticatedUsersLocalizedName = IDOK
End Function


Function LogMessage(strFunctionName, strMessage)
	dim objRecord
 	Set objRecord = Installer.CreateRecord(2)
 	objRecord.StringData(0) = "AdminStudio [Time]: [1] - [2]"
 	objRecord.StringData(1) = strFunctionName
 	objRecord.StringData(2) = strMessage
 	Message msiMessageTypeInfo, objRecord
	set objRecord = nothing
End function
