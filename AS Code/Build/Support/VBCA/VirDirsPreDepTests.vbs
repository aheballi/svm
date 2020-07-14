option explicit
const ERROR_SUCCESS = 0
const ERROR_INSTALL_FAILURE = 1603
const ERROR_FUNCTION_FAILED = 1627
const MSICONDITION_TRUE = 1
const MSICONDITION_FALSE = 0
const msiMessageTypeInfo = &H04000000

const IDOK = 1
const IDCANCEL = 2
const IDABORT = 3

function VirDirsPreDepTests()
	On Error Resume Next

	Dim Root
	Dim PreDepTestRprtDir, PreDepTestSvcDir
	Dim VirDirPath

	Set Root = GetObject("IIS://LocalHost/W3SVC/1/ROOT")
	if (Err.Number <> 0) then
		LogMessage "VirDirsPreDepTests", "ERROR: Call to GetObject(""IIS://LocalHost/W3SVC/1/ROOT"") FAILED"
		
		VirDirsPreDepTests = ERROR_SUCCESS
		exit function
	end if

	VirDirPath = Session.Property("CustomActionData")

	'PreDeployTestReport Vir dir
	Set PreDepTestRprtDir = Root.Create("IIsWebVirtualDir", "PreDeployTestReports")
	PreDepTestRprtDir.Path = VirDirPath & "PreDeployTest\Reports\"
	PreDepTestRprtDir.AccessRead = True
	PreDepTestRprtDir.AccessWrite = True
	PreDepTestRprtDir.EnableDirBrowsing = False
	PreDepTestRprtDir.AppCreate True
	PreDepTestRprtDir.AccessScript= True
	PreDepTestRprtDir.SetInfo

	'PreDeployTestService vir dir
	Set PreDepTestSvcDir = Root.Create("IIsWebVirtualDir", "PreDeployTestService")
	PreDepTestSvcDir.Path = VirDirPath & "PreDeployTest\Service\"
	PreDepTestSvcDir.AccessRead = True
	PreDepTestSvcDir.AccessWrite = True
	PreDepTestSvcDir.EnableDirBrowsing = False
	PreDepTestSvcDir.AppCreate True
	PreDepTestSvcDir.AccessScript= True
	PreDepTestSvcDir.SetInfo
	
	if (0 = Err.Number) then
		LogMessage "VirDirsPreDepTests", "Virtual directories for Predeployment web console created successfully"
	end if	

	Set PreDepTestRprtDir = Nothing
	Set PreDepTestSvcDir = Nothing
	Set Root = Nothing
	
	VirDirsPreDepTests = ERROR_SUCCESS
end function



function VirtualDirectories_Delete_PredeployTest()

On Error Resume Next
LogMessage "VirtualDirectories_Delete_PredeployTest", "This method will delete the two predeployment test virtual directories if they exists"

dim Root
Set Root = GetObject("IIS://LocalHost/W3SVC/1/ROOT")

if (Err.Number <> 0) then
    LogMessage "VirtualDirectories_Delete_PredeployTest", "Error number = " & Err.Number & " Error Description = " & Err.Description
    VirtualDirectories_Delete_PredeployTest = IDOK
    exit function
end if

'Delete PreDeployTestReport virtual directory
Root.Delete "IIsWebVirtualDir", "PreDeployTestReports"
Root.SetInfo

'Delete PreDeployTestService virtual directory
Root.Delete "IIsWebVirtualDir", "PreDeployTestService"
Root.SetInfo

set Root = nothing

LogMessage "VirtualDirectories_Delete_PredeployTest", "Finished"
VirtualDirectories_Delete_PredeployTest = IDOK
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
