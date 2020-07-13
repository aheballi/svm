. C:\InstallAuto_PSLibrary.ps1
 
#########################################################################################
#Initial Con figuration before start running the scripts in 'Tests' Folder
$FunctionalityName   = "AAC"
$ProductName         = "AdminStudio 2018R2"
$TestSetName         = $FunctionalityName + " Test Scripts"
$ASVersion           = "16.0"
$BuildShare          = "\\itareleases.acresso.com"
$BuildLocation       = $BuildShare + "\Builds\AdminStudio\16.1 (IsingR2)"
$BuildSubPath        = "Full\Suite\Compressed"
$InstallerExeName    = "AdminStudio2018R2.exe"
$sUninstallKey       = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{D6AB22DC-F133-4605-A75B-87A6BF3AE858}"
$Test                = "C:\TestSetDev\Test.bat"
$testfolders         = @( "C:\TestSetDev\*" )
$Installfolders      = @( "C:\Program Files\AdminStudio\*" )
$username            = "releaseengineer"
$DomainUsername      = "acresso\" + $username 
$password            = "Narlokwilt647"
$p4Workspace		 = "yojanayarradoddi_AUTOW2012R201"
$Pusername           = "yojanayarradoddi"
$Ppassword           = "yojanayarradoddi"
$cred                = New-Object System.Management.Automation.PSCredential -ArgumentList @($DomainUsername,(ConvertTo-SecureString -String $password -AsPlainText -Force))
$ProcessesToKill     = @( "AdminStudioHost", "Iscmide", "aacx" )
$ProductCodesToRemove= @( "{360CAC0D-9116-435F-89F2-F42AB99018CE}", 
                          "{77928086-8EFD-47A2-BFD8-CFD29D503C01}", 
                          "{DB71583C-2262-4542-ACD9-0B7C82FA79E1}", 
                          "{DC66D25F-1B94-4230-B8AE-A5D86F40488C}")

############################################################################################
########################################################################################
# Settings that do not usually change
$connectionstring    = "Data Source=10.80.150.73;User ID=AR\Administrator;Integrated Security=SSPI;"
$DBName              = "DailyDB"
$sCurrentLoc         = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$LogFile             = "C:\" + "$FunctionalityName" + "_Tests_log.txt"
#$Attachments        =@($LogFile , "C:\Program Files (x86)\AdminStudio\2018\Common\AdminStudioHost.log" , "C:\Program Files (x86)\AdminStudio\2018\Common\AdminStudio.log" , "C:\Program Files (x86)\AdminStudio\2018\Common\ISCMIDE.log")
$Attachments        = $LogFile
$MsiExec             = "C:\Windows\System32\Msiexec.exe"
$IISReset            = "C:\Windows\System32\IISreset.exe"
$global:GreatestBuildNo =  "0"
$P4Folders           = @( "//AdminStudio/AdminStudio/Current/TestQA/TestSetDev/..." )
$P4Exe               = "C:\Program Files\Perforce\P4.exe"
$InstallSilentSwitch = '-silent -debuglog"c:\Installer.log"'
########################################################################################  

########################################################################################
# Email Settings
$From                = "ReleaseEngineer@flexerasoftware.com"
$To                 = @(“VMishra@flexera.com” , “rajanchellappan@flexera.com” , “SGouri@Flexera.com” , “ssahoo@Flexera.com”  , "TTejas@flexerasoftware.com" , "SRawat@flexerasoftware.com" , "SShivaraj@flexerasoftware.com", "CMaddenapally@flexerasoftware.com" , "ssahu@flexerasoftware.com" , "SharvaniHiremath@FlexeraSoftware.com")
#$To                 = "Cmaddenapally@flexerasoftware.com"
#$To                  = @("Cmaddenapally@flexerasoftware.com", "SSahu@Flexera.com", "SharvaniHiremath@Flexera.com", "SShivaraj@Flexera.com")
#$Cc                  = "niranjanmancham@flexera.com"
#$Cc                 = "Cmaddenapally@flexerasoftware.com"
$Cc                 = @("pshashtry@flexera.com" , "niranjanmancham@flexera.com")
$Subject             = ""
$Body                = "Insert body text here"
$SMTPServer          = "smtp.acresso.com"

#########################################################################################


#########################################################################################

#Starting Script Execution
Write-Message ($TestSetName + " Execution Started....")

Write-Message("Performing Initial Configurations.....")

#Removing earlier log file if any exists
Write-Message("Removing earlier log file(if any exists).....")
Remove-Item $LogFile -force -erroraction 'silentlycontinue'
Remove-Item "C:\AS_Automation\*" -force -erroraction 'silentlycontinue' -Recurse
#Clean TestSetDev folder to Sync the latest files from perforce
#CleanTestData
<#[int] $ReturnCode = GetTestDataP4
if ($ReturnCode -ne 0)
{ 
    EmailResults 1 ("Copying " + $Functionality +  "Test Scripts Failed on  " + $env:computername)  $LogFile
    Exit
}#>

#Mounting the build location path as shared drive
#Write-Message ("Mounting the build location path as shared drive....")
#MountBuildSharedDrive $BuildLocation


#Getting the latest Build Number from build location
Write-Message("Getting the latest Build Number from Build location...." + $BuildLocation)
#$global:GreatestBuildNo = GetLatestBuild $BuildLocation
$global:GreatestBuildNo = "2424_RTM" 
$TestSetName            = $FunctionalityName + " Test Scripts for " + $ProductName + " - Build# " + $global:GreatestBuildNo

#Install the Latest Version
Write-Message ("Installing the Build#" +$global:GreatestBuildNo +  " .....")
#$ReturnCode = UninstallInstall
$ReturnCode = 0

#Running Tests in Tests Folder
if ($ReturnCode -eq 0)
{ 
    Write-Message ("Installed the " + $ProductName +" Build# " +$global:GreatestBuildNo +  " Successfully")
    Set-itemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio\16.0" -name "LSProductID" -Value "Eval"
	Set-itemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio\16.0" -name "LicenseServer" -Value "@10.80.150.149"
    Set-ItemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio" -name "DebugLogLevel" -Value "5"
    Write-Message ("Running Test Scripts in Tests folder Started..... ")
    $ReturnCode = RunTests $LogFile 
    EmailResults $ReturnCode ($TestSetName + " Execution on "+ $env:computername) $Attachments
    Write-Message ("Running Test Scripts in Tests folder Completed.....An Email has been sent with the results to the team ")
}
else
{
    Write-Message (" Installation of the " + $ProductName +" Build#" +$global:GreatestBuildNo +  " Failed")
    EmailResults $ReturnCode ($TestSetName + " Execution on  "+ $env:computername) $LogFile
    Write-Message ("No Test Scripts run due to Installation failed.....An Email has been sent with the results to the team ")
}

#End of Script Execution

cd $sCurrentLoc
#Get-Process AdminStudioHost | Stop-Process
#Get-Process msiexec | Stop-Process
Write-Message ($TestSetName + " Execution Ended")