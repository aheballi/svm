option explicit
const ERROR_SUCCESS = 0
const ERROR_INSTALL_FAILURE = 1603
const ERROR_FUNCTION_FAILED = 1627
const MSICONDITION_TRUE = 1
const MSICONDITION_FALSE = 0
const msiMessageTypeInfo = &H04000000

function VerifyWebToolsRequirement()
    on error resume next
    dim iisWebService
    dim iisMessage
    
    Property("WEBTOOLS_REQUIREMENT_VERIFIED") = ""

    'Check if this is SMS, Novell or Client tools
    if (MSICONDITION_TRUE = EvaluateCondition("_IsSetupTypeMin=""Client"" OR EDITION=""SMS"" OR EDITION=""NOVELL""")) then
    	Property("WEBTOOLS_REQUIREMENT_VERIFIED") = "1"
    	VerifyWebToolsRequirement = ERROR_SUCCESS
    	
    	LogMessage("Condition [_IsSetupTypeMin=""Client"" OR EDITION=""SMS"" OR EDITION=""NOVELL""] evaluated to TRUE. Exiting")
    	exit function
    end if

	'Check if the WebTools feature is selected for installation
    if (MSICONDITION_FALSE = EvaluateCondition("&PreDeployment_Web = 3 OR &SMSDistributor_Web = 3 OR SETUPTYPE_LANDESK=""Complete""")) then
    	Property("WEBTOOLS_REQUIREMENT_VERIFIED") = "1"
    	VerifyWebToolsRequirement = ERROR_SUCCESS

		LogMessage("Condition [&PreDeployment_Web = 3 OR &SMSDistributor_Web = 3] evaluated to FALSE. Exiting")    	
    	exit function
    end if  
  
    if (Property("VersionNT") < 600) then
        if (Property("IIS_MAJOR_VERSION")<>"") then
            Property("WEBTOOLS_REQUIREMENT_VERIFIED") = "1"
            LogMessage("IIS is installed and OS is older than Vista. Exiting")    	
        else
            iisMessage = Property("AS_IIS_NOT_INSTALLED")
            LogMessage(iisMessage)
            MsgBox iisMessage, 48, "Windows Installer"	    
        end if  

        VerifyWebToolsRequirement = ERROR_SUCCESS
        exit function
    end if
  
  
    if (Property("IIS_MAJOR_VERSION")<>"" AND Property("IIS_METABASE_COMPATIBILITY")<>"" AND Property("IIS_ADSI_COMPATIBILITY")<>"") then
	    LogMessage("IIS is installed and metabase compatibility is enabled. Web Tools will be installed")
	    Property("WEBTOOLS_REQUIREMENT_VERIFIED") = "1"
    else   
		'Give a custom message for Vista		    	                         
   		iisMessage = Property("AS_IIS_60_COMPATIBILITY_NOT_INSTALLED")
        LogMessage(iisMessage)
        MsgBox iisMessage, 48, "Windows Installer"	    
    end if

    set iisWebService = nothing
    VerifyWebToolsRequirement = ERROR_SUCCESS
end function

function LogMessage(strMessage)
	dim objRecord
	
	set objRecord = Installer.CreateRecord(1)	
	objRecord.StringData(1) = "VerifyWebToolsRequirement: '" + strMessage + "'"
	Message msiMessageTypeInfo, objRecord
	
	set objRecord = nothing
end function
