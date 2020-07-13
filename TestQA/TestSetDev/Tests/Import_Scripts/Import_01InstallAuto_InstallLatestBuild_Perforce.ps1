. C:\TestSetDev\Tests\InstallAuto_PSLibrary.ps1
 
#########################################################################################
#Initial Con figuration before start running the scripts in 'Tests' Folder
$FunctionalityName   = "Install_Latest_AS_Build"
$ProductName         = "AdminStudio2020"
$TestSetName         = $FunctionalityName + " Test Script"
$ASVersion           = "19"
$BuildShare          = "\\itareleases.acresso.com"
$BuildLocation       = $BuildShare + "\Builds\AdminStudio\19.0 (Jehangir R1)"
$BuildSubPath        = "Full\Suite\Compressed"
$InstallerExeName    = "AdminStudio2020.exe"
$sUninstallKey       = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{D6AB22DC-F133-4605-A75B-87A6BF3AE858}"
$Installfolders      = @( "C:\Program Files\AdminStudio\*" )
$username            = "releaseengineer"
$DomainUsername      = "acresso\" + $username 
$password            = "Narlokwilt647"
$cred                = New-Object System.Management.Automation.PSCredential -ArgumentList @($DomainUsername,(ConvertTo-SecureString -String $password -AsPlainText -Force))
$ProcessesToKill     = @( "AdminStudioHost", "Iscmide", "aacx" )
$ProductCodesToRemove= @( "{360CAC0D-9116-435F-89F2-F42AB99018CE}", 
                          "{77928086-8EFD-47A2-BFD8-CFD29D503C01}", 
                          "{DB71583C-2262-4542-ACD9-0B7C82FA79E1}", 
                          "{DC66D25F-1B94-4230-B8AE-A5D86F40488C}")

############################################################################################
########################################################################################
# Settings that do not usually change
$sCurrentLoc         = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$LogFile             = "C:\" + "$FunctionalityName" + "_Tests_log.txt"
$MsiExec             = "C:\Windows\System32\Msiexec.exe"
$IISReset            = "C:\Windows\System32\IISreset.exe"
$global:GreatestBuildNo =  "0"
$InstallSilentSwitch = '-silent -debuglog"c:\Installer.log"'
########################################################################################  


#Setting up variables to activate the AdminStudio with activation code and return the license before installaing the new build instead of using the license server
#$sActivationExe = "C:\Program Files (x86)\AdminStudio\2019\Common\TpsConfig.exe"
##$ActivationCode = "1C47-68A3-F59D-09EC"

#########################################################################################

#Starting Script Execution
Write-Message ($TestSetName + " Execution Started....")

Write-Message("Performing Initial Configurations.....")

#Removing earlier log file if any exists
Write-Message("Removing earlier log file(if any exists).....")
Remove-Item $LogFile -force -erroraction 'silentlycontinue'
Remove-Item "C:\AS_Automation\*" -force -erroraction 'silentlycontinue' -Recurse

#Getting the latest Build Number from build location
Write-Message("Getting the latest Build Number from Build location...." + $BuildLocation)
$global:GreatestBuildNo =  GetLatestBuild $BuildLocation
#$global:GreatestBuildNo = "5059" 
$TestSetName            = $FunctionalityName + " Test Script for " + $ProductName + " - Build# " + $global:GreatestBuildNo

#Install the Latest Version
Write-Message ("Installing the Build#" +$global:GreatestBuildNo +  " .....")
$ReturnCode = UninstallInstall
$ReturnCode = 0


#Temp activation with key Remove this code once license server is back 

 function Activate ($ActivationCode)
{
    return (Start-Process -FilePath $sActivationExe -ArgumentList "-serial_number$ActivationCode -silent" -Wait -PassThru).ExitCode
} 
$results= Activate($ActivationCode)
if($results -eq 0)
{
    Write-Message ("License activated successfully")
}
else 
{
    Write-Message ("License activation Failed")
}

 
#Revert this code once licence server is up and running

#Running Tests in Tests Folder

if ($ReturnCode -eq 0)
{ 
    Write-Message ("Installed the " + $ProductName +" Build# " +$global:GreatestBuildNo +  " Successfully")
    Set-itemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio\18.0" -name "LSProductID" -Value "Eval"
	Set-itemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio\18.0" -name "LicenseServer" -Value "@10.20.151.68"
    Set-ItemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio" -name "DebugLogLevel" -Value "5"
	exit 0
    
}
else
{
    Write-Message (" Installation of the " + $ProductName +" Build#" +$global:GreatestBuildNo +  " Failed")
	exit 1
    
}


#End of Script Execution
#cd $sCurrentLoc
#Start-Process AdminStudioHost
#Get-Process AdminStudioHost | Stop-Process
#Get-Process msiexec | Stop-Process
#Remove-Item "C:\AS_Automation\*" -force -erroraction 'silentlycontinue' -Recurse
