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

function VirDirASDists()
	On Error Resume Next
	Dim iRoot
	Dim ASDistDir
	Dim InstDir
	
	Set iRoot = GetObject("IIS://LocalHost/W3SVC/1/ROOT")
	if (Err.Number <> 0) then
		LogMessage "VirDirASDists", "ERROR: Call to GetObject(""IIS://LocalHost/W3SVC/1/ROOT"") FAILED"
		
		VirDirASDists = ERROR_SUCCESS
		exit function
	end if

	InstDir = Session.Property("CustomActionData")


	'ASDistribution vir dir
	Set ASDistDir = iRoot.Create("IIsWebVirtualDir", "ASDistribution")
	ASDistDir.Path = InstDir & "ASDistribution\"
	ASDistDir.AccessRead = True
	ASDistDir.AccessWrite = True
	ASDistDir.EnableDirBrowsing = False
	ASDistDir.AppCreate True
	ASDistDir.AccessScript= True
	ASDistDir.SetInfo
	
	if (0 = Err.Number) then
		LogMessage "VirDirASDists", "Virtual directories for SMS web console created successfully"
	end if

	Set ASDistDir = Nothing
	Set iRoot = Nothing
	
	VirDirASDists = ERROR_SUCCESS
end function


function VirtualDirectories_Delete_ASDistribution()

On Error Resume Next
LogMessage "VirtualDirectories_Delete_ASDistribution", "This method will delete the ASDistribution virtual directory if it exists"

dim Root
Set Root = GetObject("IIS://LocalHost/W3SVC/1/ROOT")

if (Err.Number <> 0) then
    LogMessage "VirtualDirectories_Delete_ASDistribution", "Error number = " & Err.Number & " Error Description = " & Err.Description
    VirtualDirectories_Delete_ASDistribution = IDOK
    exit function
end if

'Delete ASDistribution virtual directory
Root.Delete "IIsWebVirtualDir", "ASDistribution"
Root.SetInfo

set Root = nothing

LogMessage "VirtualDirectories_Delete_ASDistribution", "Finished"
VirtualDirectories_Delete_ASDistribution = IDOK
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
