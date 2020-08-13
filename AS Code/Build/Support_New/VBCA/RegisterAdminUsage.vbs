option explicit

Const ERROR_SUCCESS = 0
Const ERROR_INSTALL_FAILURE = 1603
Const ERROR_FUNCTION_FAILED = 1627
const msiMessageTypeInfo = &H04000000

function RegisterAdminUsage()
	dim customActionData
	dim regASMEXE
	dim CommonFolder
	dim arr
	dim fso
	dim shell
	dim returnCode
	dim commandLine
	dim AdminUsageDLL
	dim AdminEncryptDLL

	customActionData = Property("CustomActionData")
	'customActionData = "C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\regasm.exe|C:\AdminStudio\Current\Buildsystem"
	arr = Split(customActionData, "|", -1, 1)
	regASMEXE = arr(0)
	CommonFolder = arr(1)
	
	AdminUsageDLL = CommonFolder & "AdminStudio.Usage.dll"
	AdminEncryptDLL = CommonFolder & "AdminStudio.Encryption.dll"
	
	set fso = CreateObject("Scripting.FileSystemObject")
	if (NOT fso.FileExists(regASMEXE)) then
		MsgBox "RegAsm not found"
		'LogMessage "File '" & CommonFolder & "' does not exist. Aborting interop registration"
		RegisterAdminUsage = ERROR_SUCCESS	
		exit function
	end if
	
	if (NOT fso.FileExists(AdminUsageDLL)) then
		LogMessage "File '" & CommonFolder & "' does not exist. Aborting AdminStudio.Usage.dll interop registration"
		RegisterAdminUsage = ERROR_SUCCESS		
		exit function
	end if
	
	if (NOT fso.FileExists(AdminEncryptDLL)) then
		LogMessage "File '" & CommonFolder & "' does not exist. Aborting AdminStudio.Encryption.dll interop registration"
		RegisterAdminUsage = ERROR_SUCCESS		
		exit function
	end if

	commandLine = """" & regASMEXE & """ """ & AdminEncryptDLL & """ /codebase"	
	LaunchAppAndWait commandLine
	
	commandLine = """" & regASMEXE & """ """ & AdminUsageDLL & """ /codebase"	
	LaunchAppAndWait commandLine

	RegisterAdminUsage = ERROR_SUCCESS	
end function

function LaunchAppAndWait(commandLine)
	dim shell
	dim fso
	dim returnCode
	
	set shell = CreateObject("WScript.Shell")

	LogMessage "Running command " & commandLine
	returnCode = shell.Run(commandLine, 1, true) '1 - Hide Window, true - WAIT for process to complete
	LogMessage "ReturnCode: " & returnCode

	set shell = Nothing
	set fso = Nothing
end function

function UnRegisterAdminUsage()
	dim customActionData
	dim regASMEXE
	dim CommonFolder
	dim arr
	dim fso
	dim shell
	dim returnCode
	dim commandLine
	dim AdminUsageDLL
	dim AdminEncryptDLL

	customActionData = Property("CustomActionData")
	'customActionData = "C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\regasm.exe|C:\AdminStudio\Current\Buildsystem"
	arr = Split(customActionData, "|", -1, 1)
	regASMEXE = arr(0)
	CommonFolder = arr(1)
	
	AdminUsageDLL = CommonFolder & "AdminStudio.Usage.dll"
	AdminEncryptDLL = CommonFolder & "AdminStudio.Encryption.dll"
	
	set fso = CreateObject("Scripting.FileSystemObject")
	if (NOT fso.FileExists(regASMEXE)) then
		MsgBox "RegAsm not found"
		'LogMessage "File '" & CommonFolder & "' does not exist. Aborting interop registration"
		RegisterAdminUsage = ERROR_SUCCESS
		exit function
	end if
	
	if (NOT fso.FileExists(AdminUsageDLL)) then
		LogMessage "File '" & CommonFolder & "' does not exist. Aborting AdminStudio.Usage.dll interop registration"
		RegisterAdminUsage = ERROR_SUCCESS		
		exit function
	end if
	
	if (NOT fso.FileExists(AdminEncryptDLL)) then
		LogMessage "File '" & CommonFolder & "' does not exist. Aborting AdminStudio.Encryption.dll interop registration"
		RegisterAdminUsage = ERROR_SUCCESS		
		exit function
	end if

	commandLine = """" & regASMEXE & """ """ & AdminEncryptDLL & """ /unregister"	
	LaunchAppAndWait commandLine
	
	commandLine = """" & regASMEXE & """ """ & AdminUsageDLL & """ /unregister"	
	LaunchAppAndWait commandLine

	UnRegisterAdminUsage = ERROR_SUCCESS
end function

function LogMessage(strMessage)
    dim objNow
    dim strTimeStamp
    
    objNow = Now
    strTimeStamp = Year(objNow) & "-" & Month(objNow) & "-" & Day(objNow) & " " & Hour(objNow) & ":" & Minute(objNow) & ":" & Second(objNow)
    
	dim objRecord
	
	set objRecord = Installer.CreateRecord(1)
	objRecord.StringData(1) = "ASCA " & Chr(9) & strTimeStamp & Chr(9) & "INFO" & Chr(9) & strMessage
	Message msiMessageTypeInfo, objRecord
	
	set objRecord = nothing
end function
