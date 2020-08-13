option explicit

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
const INFORMATION_ICON   = 64

function EnableWebServiceExtensions()
    on error resume next
	dim iisWebService
	dim customActionData
	dim majorVersionText
	dim majorVersion
	
	customActionData = Property("CustomActionData")                  
    LogMessage "EnableWebServiceExtensions", "CustomActionData is: " & customActionData
    
    if (Left(customActionData, 1) = "#") then
	    majorVersionText = Mid(customActionData, 2, Len(customActionData) - 1)

	    if (Left(majorVersionText, 1) = "+" OR Left(majorVersionText, 1) = "-") then
            majorVersionText = Mid(majorVersionText, 2, Len(majorVersionText) - 1)
	    end if

	    majorVersion = CInt(majorVersionText)
	    
	    if (majorVersion >= 6) then
          Err.Clear
	        set iisWebService = GetObject("IIS://localhost/W3SVC")
	        LogMessage "EnableWebServiceExtensions", "IIS greater then 6. Enabling ASP.NET 4.0 and ASP WebService extensions"
	        iisWebService.EnableWebServiceExtension "ASP.NET v4.0.30319 (32-bit)"
	        if (Err.Number <> 0) then
	            LogMessage "EnableWebServiceExtensions", "Could not enable webservice extension ASP.NET v4.0.30319 in IIS"    
	        end if
	        
	        Err.Clear
	        iisWebService.SetInfo
	        if (Err.Number <> 0) then
	            LogMessage "EnableWebServiceExtensions", "Could NOT enable webservice extension in IIS"    
	        else
	            LogMessage "EnableWebServiceExtensions", "Webservice extension successfully enabled in IIS"    
	        end if
	
	        set iisWebService = Nothing	   
	    else
	        LogMessage "EnableWebServiceExtensions", "IIS less then 6. SKIPPING Enabling ASP.NET 4.0 and ASP WebService extensions"
	    end if
	else
	    LogMessage "EnableWebServiceExtensions", "Invalid first character. Expected to see #"   
    end if    

	EnableWebServiceExtensions = ERROR_SUCCESS
end function

function LogMessage(strFunctionName, strMessage)
    dim objNow
    dim strTimeStamp
    
    objNow = Now
    strTimeStamp = Year(objNow) & "-" & Month(objNow) & "-" & Day(objNow) & " " & Hour(objNow) & ":" & Minute(objNow) & ":" & Second(objNow)
    
	dim objRecord

 	set objRecord = Installer.CreateRecord(1)
 	objRecord.StringData(1) = "AdminStudioLogging: (" & strFunctionName & ")" & Chr(9) & strTimeStamp & Chr(9) & "INFO" & Chr(9) & strMessage
 	Message msiMessageTypeInfo, objRecord
	'MsgBox "AdminStudioLogging (" & strFunctionName & ")" & Chr(9) & strTimeStamp & Chr(9) & "INFO" & Chr(9) & strMessage
	
	set objRecord = nothing
end function
