option explicit

Const IDOK = 1
Const IDCANCEL = 2
Const IDABORT = 3

const ERROR_SUCCESS = 0
const ERROR_INSTALL_FAILURE = 1603
const ERROR_FUNCTION_FAILED = 1627

const msiEvaluateConditionTrue = 1
const msiEvaluateConditionFalse = 0
const msiMessageTypeInfo = &H04000000
const msiInstallStateAbsent = 2 
const msiInstallStateLocal = 3 

const CRITICAL_ICON = 16
const WARNING_ICON = 48
const INFORMATION_ICON = 64

const IsIntegrationFeatureName = "Editor"

Const INSTALLSHIELD_MAIN_REG_KEY = "HKEY_LOCAL_MACHINE\SOFTWARE\InstallShield\18.0\Professional\"
Const INSTALLSHIELD_INSTALLLOCATION_REG_VALUE = "Install Location"


'This function obtains the install location of InstallShield so that the AS/IS integration files can be installed to this location
Function GetInstallShieldInstallLocation()
On Error Resume Next
LogMessage "GetInstallShieldInstallLocation", "This custom action obtains the install location of InstallShield so that the AS/IS integration files can be installed to this location"

Dim WSHShell, ISInstallLocation
Set WSHShell = CreateObject("WScript.Shell")

LogMessage "GetInstallShieldInstallLocation", "About to check following reg key to obtain InstallShield install location : " & INSTALLSHIELD_MAIN_REG_KEY & INSTALLSHIELD_INSTALLLOCATION_REG_VALUE
ISInstallLocation = WSHShell.RegRead (INSTALLSHIELD_MAIN_REG_KEY & INSTALLSHIELD_INSTALLLOCATION_REG_VALUE)

If (Err.Number = 0) Then
	LogMessage "GetInstallShieldInstallLocation", "Obtained InstallShield install location from registry - " & ISInstallLocation
	Property("IS_FOUND") = "1"
	Property("IS_INSTALLDIR") = ISInstallLocation
	'Session.TargetPath("IS_INSTALLDIR") = ISInstallLocation
	FeatureRequestState(IsIntegrationFeatureName) = msiInstallStateLocal
Else
	LogMessage "GetInstallShieldInstallLocation", "Did not obtain InstallShield install location from registry.  This is expected when the InstallShield feature was not selected for installation."
	LogMessage "GetInstallShieldInstallLocation", "Error details - Error number " & Err.Number & " of the type '" & Err.Description & "'."
End if

LogMessage "GetInstallShieldInstallLocation", "Finished"
GetInstallShieldInstallLocation = IDOK
End Function


'This function makes the InstallShield Editor feature's state match that of the associated version of InstallShield
function SynchronizeEditorFeatureState()
	LogMessage "SynchronizeEditorFeatureState", "This custom action will make the IS Editor feature in AS correctly match the installation state of InstallShield"
	dim action, current
	
	action = FeatureRequestState(IsIntegrationFeatureName)
	current = FeatureCurrentState(IsIntegrationFeatureName)
		
	'No need to manipulate IS Editor feature state if AS is being uninstalled
	if (Property("REMOVE")="ALL" OR Property("ASREMOVE")="ALL") then
		LogMessage "SynchronizeEditorFeatureState", "No action necessary - AS is being uninstalled"
		SynchronizeEditorFeatureState = IDOK
		exit function
	end if
	
	if (Property("IS_FOUND") = "1") then
		if ((current <> msiInstallStateLocal AND action <> msiInstallStateLocal) OR (current = msiInstallStateLocal AND action = msiInstallStateAbsent) ) then
			LogMessage "SynchronizeEditorFeatureState", "Making Editor feature install locally to match InstallShield product state"
			FeatureRequestState(IsIntegrationFeatureName) = msiInstallStateLocal
		else
			LogMessage "SynchronizeEditorFeatureState", "No action necessary - Editor feature is installed or will be installed and InstallShield is installed"
		end if
	else
		if ((action = msiInstallStateLocal) OR (current = msiInstallStateLocal AND action <> msiInstallStateAbsent)) then
			LogMessage "SynchronizeEditorFeatureState", "Making Editor feature absent to match InstallShield product state"
			FeatureRequestState(IsIntegrationFeatureName) = msiInstallStateAbsent
		else
			LogMessage "SynchronizeEditorFeatureState", "No action necessary - Editor feature is uninstalled or will be uninstalled and InstallShield is not installed"
		end if
	end if
  
	LogMessage "SynchronizeEditorFeatureState", "Finished"
	SynchronizeEditorFeatureState = IDOK
end function


function VerifyInstallShieldIntegration()
  Property("IS_INTEGRATION_VERIFIED") = ""
  if (FeatureRequestState(IsIntegrationFeatureName) = msiInstallStateLocal) then
    if (msiEvaluateConditionFalse = EvaluateCondition("IS_INSTALLDIR")) then
      MsgBox "InstallShield 2008 is not installed on this machine in order for the InstallShield Editor Integration to be configured." + Chr(13) + _
             "Please uncheck the InstallShield Editor Integration feature to continue", WARNING_ICON, "Windows Installer"
    else
      Property("IS_INTEGRATION_VERIFIED") = "True"
    end if
  else
    Property("IS_INTEGRATION_VERIFIED") = "True"
  end if

  VerifyInstallShieldIntegration = IDOK
end function


'This function restores the original IS copy of isdev.exe from the back-up directory if AS is uninstalled before IS.
function RestoreOriginalISDEVExecutable()
	on error resume next
	LogMessage "RestoreOriginalISDEVExecutable", "This function restores the original IS copy of isdev.exe from the back-up directory if AS is uninstalled before IS"
	
	dim isSystemFolder
	dim fso
	dim isdevSource
	dim isdevTarget
	
	isSystemFolder = Property("CustomActionData")
	isdevSource = isSystemFolder & "\Backup\isdev.exe"
	isdevTarget = isSystemFolder & "\isdev.exe" 
	set fso = CreateObject("Scripting.FileSystemObject")

	if (fso.FileExists(isdevSource)) then
		LogMessage "RestoreOriginalISDEVExecutable", "File '" &  isdevSource & "' exists. Restoring the backup"
		if (fso.FileExists(isdevTarget)) then
			LogMessage "RestoreOriginalISDEVExecutable", "Deleting AS version of file '" &  isdevTarget & "'"
			fso.DeleteFile isdevTarget, true
		else
			LogMessage "RestoreOriginalISDEVExecutable", "AS version of file '" &  isdevTarget & " not found. Nothing to delete"  
		end if
	
		if (fso.FolderExists(isSystemFolder)) then
			LogMessage "RestoreOriginalISDEVExecutable", "Restoring IS version of file '" &  isdevSource & "'"
			fso.CopyFile isdevSource, isSystemFolder
		else
			LogMessage "RestoreOriginalISDEVExecutable", "Folder '" &  isSystemFolder & "' not found. Nothing to restore"
		end if
	else
		LogMessage "RestoreOriginalISDEVExecutable", "Backup File '" &  isdevSource & "' Not found. Nothing to restore"
	end if
	
	LogMessage "RestoreOriginalISDEVExecutable", "Finished"
	RestoreOriginalISDEVExecutable = IDOK
end function


'Template logging function that writes to the MSI log file
function LogMessage(strFunctionName, strMessage)
	dim objRecord
 	Set objRecord = Installer.CreateRecord(2)
 	objRecord.StringData(0) = "AdminStudio [Time]: [1] - [2]"
 	objRecord.StringData(1) = strFunctionName
 	objRecord.StringData(2) = strMessage
 	Message msiMessageTypeInfo, objRecord
	set objRecord = nothing
end function
