Option Explicit

Const IDOK = 1
Const IDCANCEL = 2
Const IDABORT = 3

Const ERROR_SUCCESS = 0
Const ERROR_INSTALL_FAILURE = 1603
Const ERROR_FUNCTION_FAILED = 1627

Const msiEvaluateConditionTrue = 1
Const msiEvaluateConditionFalse = 0
Const msiMessageTypeInfo = &H04000000

Const CRITICAL_ICON = 16
Const WARNING_ICON = 48
Const INFORMATION_ICON = 64

Const msiInstallStateDefault = 5
Const msiInstallStateAbsent = 2
Const msiInstallStateLocal = 3 

Const msiReinstallModeFileOlderVersion = 4
Const msiReinstallModeMachineData = 128
Const msiReinstallModeUserData = 256
Const msiReinstallModeShortcut = 512

'Const msiUninstallCommandLine = "REMOVE=ALL"



function MaintainFeaturePrerequisites()
LogMessage "MaintainFeaturePrerequisites", "Entered MaintainFeaturePrerequisites function - goal is to repair all feature prerequisites if main product is being repaired.  Otherwise, goal is to uninstall any feature prerequisites associated with a feature that will be uninstalled"

dim view
dim rec
dim featurePrerequisitesDict

' open and execute the view
Set view = Database.OpenView("SELECT * FROM `ASFeaturePrerequisites`")
view.Execute

Set rec = view.Fetch

Set featurePrerequisitesDict = CreateObject("Scripting.Dictionary")

'Make a dictionary containing all of the feature to prerequisite msi association
While Not (rec Is Nothing)
    ' ASFeaturePrerequisites record fields are Feature and Productcode
	featurePrerequisitesDict.Add rec.StringData(1), rec.StringData(2)

    ' fetch the next Property record
    Set rec = view.Fetch
Wend

' clean up
view.Close


dim arrayFeatures
dim i

arrayFeatures = featurePrerequisitesDict.Keys
for i = 0 to featurePrerequisitesDict.Count - 1
     LogMessage "MaintainFeaturePrerequisites", "Feature = " & arrayFeatures(i) & " Associated ProductCode = " & featurePrerequisitesDict.Item(arrayFeatures(i))
next

dim ASMaintenanceCommandLine

if (Property("_IsMaintenance") = "Reinstall") then
'Main product is being repaired
	ASMaintenanceCommandLine = "-Reinstall "
	for i = 0 to featurePrerequisitesDict.Count - 1
		'MsgBox "Key = " & arrayFeatures(i) & " Item = " & featurePrerequisitesDict.Item(arrayFeatures(i))
		if (FeatureCurrentState(arrayFeatures(i)) = msiInstallStateLocal) then
		'Use MSI API to reinstall the associated msi
			'ReinstallMSI featurePrerequisitesDict.Item(arrayFeatures(i))
			ASMaintenanceCommandLine = ASMaintenanceCommandLine & featurePrerequisitesDict.Item(arrayFeatures(i)) & ","
		end if
	next
	

elseif (Property("_IsMaintenance") = "Remove") then
'Main product is being removed
	ASMaintenanceCommandLine = "-Uninstall "
	for i = 0 to featurePrerequisitesDict.Count - 1
		'MsgBox "Key = " & arrayFeatures(i) & " Item = " & featurePrerequisitesDict.Item(arrayFeatures(i))
		if (FeatureCurrentState(arrayFeatures(i)) = msiInstallStateLocal) then
		'Use MSI API to uninstall the associated msi
			'UninstallMSI featurePrerequisitesDict.Item(arrayFeatures(i))
			ASMaintenanceCommandLine = ASMaintenanceCommandLine & featurePrerequisitesDict.Item(arrayFeatures(i)) & ","
		end if
	next

elseif (Property("_IsMaintenance") = "Change") then
'Main product features are being modified
	ASMaintenanceCommandLine = "-Uninstall "
	for i = 0 to featurePrerequisitesDict.Count - 1
		'MsgBox "Key = " & arrayFeatures(i) & " Item = " & featurePrerequisitesDict.Item(arrayFeatures(i))
		if (FeatureCurrentState(arrayFeatures(i)) = msiInstallStateLocal AND FeatureRequestState(arrayFeatures(i)) = msiInstallStateAbsent) then
		'Use MSI API to uninstall the associated msi
			'UninstallMSI featurePrerequisitesDict.Item(arrayFeatures(i))
			ASMaintenanceCommandLine = ASMaintenanceCommandLine & featurePrerequisitesDict.Item(arrayFeatures(i)) & ","
		end if
	next
end if

ASMaintenanceCommandLine = Left(ASMaintenanceCommandLine, Len(ASMaintenanceCommandLine) - 1)
'MsgBox ASMaintenanceCommandLine

'Only run maintenance EXE if there is at least one productCode in the command line
if (Len(ASMaintenanceCommandLine) > 38) then
	dim oShell
	dim ret
	set oShell = CreateObject ("Wscript.Shell")
	'MsgBox Property("INSTALLDIR") & "Support\ASMaintenance.exe " & ASMaintenanceCommandLine
	LogMessage "MaintainFeaturePrerequisites", Property("INSTALLDIR") & "Support\ASMaintenance.exe " & ASMaintenanceCommandLine
	ret = oShell.Run("""" & Property("INSTALLDIR") & "Support\ASMaintenance.exe"" " & ASMaintenanceCommandLine, 1, true)
end if

set featurePrerequisitesDict = Nothing

MaintainFeaturePrerequisites = IDOK
end function



function ReinstallMSI(strProductCode)

dim msi
set msi = CreateObject("WindowsInstaller.Installer")

dim ret
dim oShell
set oShell = CreateObject ("Wscript.Shell")

if (msi.ProductState(strProductCode) = msiInstallStateDefault) then
	LogMessage "ReinstallMSI", "Product - " & strProductCode & " is already installed and can be reinstalled"
	'msi.ReinstallProduct strProductCode, msiReinstallModeFileOlderVersion OR msiReinstallModeMachineData OR msiReinstallModeUserData OR msiReinstallModeShortcut
	ret = oShell.Run(Property("SystemFolder") & "msiexec.exe /qb! /focmusv " & strProductCode, 1, true)
else
	LogMessage "ReinstallMSI", "Product - " & strProductCode & " is not installed and so can't reinstalled"  
end if

set msi = Nothing
end function





function UninstallMSI(strProductCode)

dim msi
set msi = CreateObject("WindowsInstaller.Installer")

dim ret
dim oShell
set oShell = CreateObject ("Wscript.Shell")

if (msi.ProductState(strProductCode) = msiInstallStateDefault) then
	LogMessage "UninstallMSI", "Product - " & strProductCode & " is already installed and thus can be removed"
	'msi.ConfigureProduct strProductCode, 0, msiInstallStateAbsent
	'msi.InstallProduct strProductCode, msiUninstallCommandLine
	ret = oShell.Run(Property("SystemFolder") & "msiexec.exe /qb! /x " & strProductCode, 1, true)
else
	LogMessage "UninstallMSI", "Product - " & strProductCode & " is not installed and so can't be uninstalled"  
end if

set msi = Nothing
end function


'Log to the MSI log file
function LogMessage(strFunctionName, strMessage)
	dim objRecord
 	Set objRecord = Installer.CreateRecord(2)
 	objRecord.StringData(0) = "AdminStudio [Time]: [1] - [2]"
 	objRecord.StringData(1) = strFunctionName
 	objRecord.StringData(2) = strMessage
 	Message msiMessageTypeInfo, objRecord
	set objRecord = nothing
end function
