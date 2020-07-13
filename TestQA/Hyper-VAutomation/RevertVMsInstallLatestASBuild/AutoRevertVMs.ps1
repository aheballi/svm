. 'C:\Hyper-VAutomation\RevertVMsInstallLatestASBuild\AutoRevertVMs_Powershell_Library.ps1'


#Hyper-V Automation Main Script

######################################################################################
#Script Configurations
$AdminStudioVersion="Hawking"

$LogFile =$ConfigParent+"\"+"RevertVMs_InstallLatestASBuild_Status.log"
$DetLogFile =$ConfigParent+"\"+"RevertVMs_InstallLatestASBuild_Detailed.log"
$LastLatestBuildNo=$ConfigParent+"\"+"LatestASBuildNo.txt"

#Hyper-V Configurations

$HyperV = "BLR-HYPV-N03"
$DomainName = "flexera.com"
$HyperVFQDName = $HyperV+ "." +$DomainName
$DomainUsername = "acresso\releaseengineer"
$Password = "Narlokwilt647"
$HypVCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList @($DomainUsername,(ConvertTo-SecureString -String $Password -AsPlainText -Force))


#TargetVM Configurations
$TargetHostUserName ="Administrator"                                                                  
$TargetPassword="AS@dmin1"
$TargetVMCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList @($TargetHostUserName,(ConvertTo-SecureString -String $TargetPassword -AsPlainText -Force))

#Details of the TargetVMs to be reverted on dailybasis automatically and installed with latest AS build
$TargetVMsCSV =$ConfigParent+"\"+"TargetVMDetails.csv"



# Email Configurations
$EmailUsername = "acresso\releaseengineer"
$EmailPassword = "Narlokwilt647"
$EmailCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList @($EmailUsername,(ConvertTo-SecureString -String $EmailPassword -AsPlainText -Force))
$From                 = "ReleaseEngineer@flexerasoftware.com"
#$To                   = "SRawat@flexera.com"
$To                   = @(“VMishra@flexera.com” , "aheballi@flexera.com" , “rajanchellappan@flexera.com” , “SGouri@Flexera.com” , “ssahoo@Flexera.com”  , "TTejas@flexerasoftware.com" , "SRawat@flexera.com" , "SShivaraj@flexerasoftware.com", "CMaddenapally@flexerasoftware.com" , "ssahu@flexerasoftware.com" , "SharvaniHiremath@FlexeraSoftware.com")
#$To                  = "Cmaddenapally@flexerasoftware.com"
#$To                  = @("Cmaddenapally@flexerasoftware.com", "SSahu@Flexera.com", "SharvaniHiremath@Flexera.com", "SShivaraj@Flexera.com")
#$Cc                  = "niranjanmancham@flexera.com"
#$Cc                  = "Cmaddenapally@flexerasoftware.com"
$Cc                   = @("pshashtry@flexera.com" , "niranjanmancham@flexera.com")
$Subject              = ""
$Body                 = "Insert body text here"
$Attachments          = @($LogFile,$DetLogFile)
$SMTPServer           = "smtp.acresso.com"

#Latest AS Build Configurations
$BuildShare          = "\\itareleases.acresso.com"
$BuildLocation       = $BuildShare + "\Builds\AdminStudio\17.0 (Hawking)"
$BuildSubPath        = "Full\Suite\Compressed"
$global:GreatestBuildNo =  "0"
$SharedBuildLocwithBuildNo=$SharedBuildLoc+"\"+$global:GreatestBuildNo
$InstallerExeName    = "AdminStudio2019.exe"



#########################################################################################
#Remove earlier log files
Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $DetLogFile -Force -ErrorAction SilentlyContinue

#Starting the Script Execution
Write-Message ("Started Executing $Global:ScriptName script ...") $LogFile
Write-Message ("Started Executing $Global:ScriptName script ...") $DetLogFile
#Define return code to validate Overall Script run Status
$ReturnCode=0

#Copy Latest Build to Sharedlocation to speed up the copying process to the target VMs
$LastBuildNo=Get-Content $LastLatestBuildNo
$global:GreatestBuildNo = GetLatestBuild $BuildLocation
$Global:ScriptName="Revert VMs and Install Latest $AdminStudioVersion Build #$global:GreatestBuildNo "
if($LastBuildNo -ne $global:GreatestBuildNo )
  {
    $BuildRetVal=GetLatestBuildCopyToSharedLocation $BuildLocation $SharedBuildLoc
    $global:GreatestBuildNo | out-file $LastLatestBuildNo
    $BuildRetVal
    if($BuildRetVal -eq 0)
      {
        Write-Message ("Copying Latest $AdminStudioVersion Build to Shared Location: Passed") $LogFile
        Write-Message ("Reverting VMs and Installing Latest Builds Initiated.....") $LogFile
        $RevertRetVal=RevertAndInstallLatestBuild $TargetVMsCSV $Global:ScriptName
        if($RevertRetVal -eq 0)
          {
           Write-Message ("Reverting VMs specified in $TargetVMsCSV :Passed") $LogFile
          }
        else
          {
           Write-Message ("Reverting VMs specified in $TargetVMsCSV :Failed") $LogFile
          }
      }
    else
      {
        Write-Message ("Copying Latest $AdminStudioVersion Build to Shared Location: Failed") $LogFile
        Write-Message ("Reverting VMs not Necessary..as the Lastest Build is not copied...") $LogFile
        Write-Message ("Copying Latest $AdminStudioVersion Build to Shared Location: Failed") $DetLogFile
        Write-Message ("Reverting VMs not Necessary..as the Lastest Build is not copied...") $DetLogFile
       }
    
   }

else
{
  Write-Message ("The $AdminStudioVersion build# $LastBuildNo installed prior and Last Latest build# $global:GreatestBuildNo are same ") $LogFile
  Write-Message ("The $AdminStudioVersion build# $LastBuildNo installed prior and Last Latest build# $global:GreatestBuildNo are same ") $DetLogFile
}



if(Select-String -Pattern "Failed" -InputObject $(Get-Content $LogFile))
 {
   $ReturnCode=-1
 }

   Write-Message ("Ended Executing $Global:ScriptName script ...") $LogFile
   Write-Message ("Ended Executing $Global:ScriptName script ...") $DetLogFile

#Sending Email to the Team
if ($ReturnCode -eq 0)
  { 
    
    EmailResults $ReturnCode ($Global:ScriptName + " Script Execution on "+ $env:computername) $Attachments
    
  }
else
  {
   
    EmailResults $ReturnCode ($Global:ScriptName + " Script Execution on  "+ $env:computername) $Attachments
    
  }

