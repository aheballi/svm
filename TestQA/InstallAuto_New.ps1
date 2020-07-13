$TestName            = "Ising Latest Build QA Tests for AdminStudio"
$ASVersion           = "16.0"
$BuildShare          = "\\itareleases.acresso.com"
$BuildLocation       = $BuildShare + "\Builds\AdminStudio\16.0 (Ising)"
#$BuildLocation       = $BuildShare + "\Builds\AdminStudio\15.1 (GalileoSP1)"
#$BuildLocation       = $BuildShare + "\Builds\AdminStudio\15.0 (Galileo)"
$BuildSubPath        = "Full\Suite\Compressed"
$InstallerExeName    = "AdminStudio2018.exe"
$sUninstallKey       = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{D6AB22DC-F133-4605-A75B-87A6BF3AE858}"
$Test                = "c:\TestSetDev\Test.bat"
$testfolders         = @( "C:\TestSetDev\*" )
$Installfolders      = @( "C:\Program Files\AdminStudio\*" )
$username            = "releaseengineer"
$DomainUsername      = "acresso\" + $username 
$p4Workspace		 = "yojanayarradoddi_AUTOW2012R201"
$password            = "Narlokwilt647"
$Pusername           ="yojanayarradoddi"
$Ppassword           ="yojanayarradoddi"
$cred                = New-Object System.Management.Automation.PSCredential -ArgumentList @($DomainUsername,(ConvertTo-SecureString -String $password -AsPlainText -Force))
$ProcessesToKill     = @( "AdminStudioHost", "Iscmide", "aacx" )
$ProductCodesToRemove= @( "{360CAC0D-9116-435F-89F2-F42AB99018CE}", 
                          "{77928086-8EFD-47A2-BFD8-CFD29D503C01}", 
                          "{DB71583C-2262-4542-ACD9-0B7C82FA79E1}", 
                          "{DC66D25F-1B94-4230-B8AE-A5D86F40488C}")

########################################################################################
# Email Settings
$From                = "ReleaseEngineer@flexerasoftware.com"
#$To                  = @( "TTejas@flexerasoftware.com" , "SRawat@flexerasoftware.com" , "SShivaraj@flexerasoftware.com", "CMaddenapally@flexerasoftware.com" , "ssahu@flexerasoftware.com" , "SharvaniHiremath@FlexeraSoftware.com")
$To                  = "Cmaddenapally@flexerasoftware.com"
$Cc                  = "Cmaddenapally@flexerasoftware.com"
#$Cc                 = "pshashtry@flexerasoftware.com"
$Subject             = "Ising Latest Build QA Test Results"
$Body                = "Insert body text here"
$SMTPServer          = "smtp.acresso.com"

########################################################################################
# Settings that do not usually change
$connectionstring    = "Data Source=10.80.150.73;User ID=as01test\kiran;Integrated Security=SSPI;"
$DBName              = "DailyDB"
$sCurrentLoc         = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$LogFile             = "c:\log.txt"
$MsiExec             = "C:\Windows\System32\Msiexec.exe"
$IISReset            = "C:\Windows\System32\IISreset.exe"
$global:GreatestBuildNo =  "0"
$P4Folders           = @( "//AdminStudio/AdminStudio/Current/TestQA/TestSetDev/..." )
$P4Exe               = "C:\Program Files\Perforce\P4.exe"
$InstallSilentSwitch = '-silent -debuglog"c:\Installer.log"'
   
function Write-Message ($Message)
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' [Auto Installer] ' + $Message
    Write-Host $Header
    $Header | Out-File $LogFile -Append
}

function ExecuteSql ($sql, $connectInfo)
{
    $connection = new-object system.data.SqlClient.SQLConnection($connectInfo)
    $command = $connection.CreateCommand()
    $command.CommandText = $sql 
    $connection.Open()
    if ($command.ExecuteNonQuery() -ne -1)
    {
        Write-Message ("Query Failed:" + $sql)
    }
    $connection.Close()
 }

function DropDatabase ($table, $connection)
{
    try
    {
        $sql = "ALTER DATABASE [$table] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
        ExecuteSql $sql $connection
        $sql = "DROP DATABASE [$table]"
        ExecuteSql $sql $connection
        #Write-Message ("Deleted DB: " + $table)
    }
    catch
    {
        Write-Message ("Failed to Delete DB: " + $table)
    }
}

function IsPathDirectory ($file)
{
    $FileAttributes = [System.IO.File]::GetAttributes($file)
    $IsDirectory = ($FileAttributes -band [System.IO.FileAttributes]::Directory)
    if ($IsDirectory)
    {
        return $true
    }
    else
    {
        return $false
    }
}

function GetLatestBuild ($Machine)
{
#write-host $BuildLocation
    $CommandLineUser = "/user:" + $DomainUsername
    $ThrowOutResult = net use $BuildShare $CommandLineUser $password 
    Write-Message $ThrowOutResult
    $Array = New-Object System.Collections.ArrayList
    foreach ($Item in Get-Childitem $BuildLocation) 
    {
        if ((IsPathDirectory $Item.FullName))
        {
            ##Write-host $Item.Name -ForegroundColor White
            $Object = $Array.Add([string] $Item.Name)
        }
    }
    
    #write-host  $array
    $Array.Sort()
    #write-host $Array.Sort()
    return $Array[($Array.Count -1)]
}

function StartProcess ([string]$FileToRun, [string]$ArgumentList)
{
    if ($ArgumentList)
    {
        $WaitProcessObject = Start-Process -FilePath $FileToRun -ArgumentList $ArgumentList -Wait -PassThru
    }
    else
    {
        $WaitProcessObject = Start-Process -FilePath $FileToRun -Wait -PassThru
    }
    return $WaitProcessObject.ExitCode
}

function RunExe ([string]$FileToRun, [string]$ArgumentList)
{
    [int] $ReturnCode = 0
	try
	{
        If (Test-Path $FileToRun)
        {
		    Write-Message ("Running " + $FileToRun + " " + $ArgumentList)
            [string] $WDir = Split-Path -Path $FileToRun -Parent
            if ($WDir)
            {
                cd $WDir
                $ReturnCode = StartProcess $FileToRun $ArgumentList
                cd $sCurrentLoc
            }
            else
            {
                $ReturnCode = StartProcess $FileToRun $ArgumentList
            }
        	#Write-Message ("Return Code " + $ReturnCode)
        }
        else
        {
            Write-Message ("File Does not exist: " + $FileToRun)
        }
	}
	catch
	{
       	Write-Message ("Error: " +  $ReturnCode + " Executing:" + $FileToRun) 
	}
	return $ReturnCode
}

function Uninstall ([string]$RegKey)
{
    [int] $ReturnCode = 0
    try
    {
        $RegItem = Get-ItemProperty $RegKey -ErrorAction SilentlyContinue
        if ($RegItem -ne $null)
        {
            foreach ($process in $ProcessesToKill)
            {
                Stop-Process -ProcessName $process -Force -erroraction 'silentlycontinue'
            }

            $sUninstLoc = $RegItem.UninstallString
            $ParamArray = New-Object System.Collections.ArrayList
            $ParamArray  = $sUninstLoc.Split('"')
            [string] $EXE = $ParamArray[1]
            [string] $Parameters =$ParamArray[2] + " " + $InstallSilentSwitch
            $ReturnCode = RunExe $EXE $Parameters
        }
        else
        {
           Write-Message ("No Suite to Uninstall")
        }

        foreach ($ProductCode in $ProductCodesToRemove)
        {
           $CommandLine = "-X" + $ProductCode + " -qn"
           $ReturnCode = RunExe $MsiExec $CommandLine
        }
   }
   catch
   {
       Write-Message ("Uninstall Fail")
   }
   return $ReturnCode
}

function UninstallInstall ()
{
    [int] $ReturnCode = 1
    try
    {
        $InstallLoc= Join-Path $BuildLocation $global:GreatestBuildNo
        $InstallLoc= Join-Path $InstallLoc $BuildSubPath
        $InstallLoc= Join-Path $InstallLoc $InstallerExeName

        if (Test-Path $InstallLoc)
        {

            # Better way to clean temp folder.  Handles long file names.
            cmd /c "del %temp%\*.* /Q /S"
            $ReturnCode = Uninstall $sUninstallKey
            try
            {
                Remove-Item $Installfolders -force -recurse -erroraction 'silentlycontinue'
            }
            catch {}
            Write-Message $ReturnCode
            $Dest = Join-Path $env:TEMP  $InstallerExeName
            Write-Message ("Copying " + $InstallLoc + "To " + $Dest)
            Copy-Item $InstallLoc $Dest
	        $ReturnCode = RunExe $Dest $InstallSilentSwitch
        }
        else
        {
            Write-Message ("Failed to locate Installer " + $InstallLoc)
            $ReturnCode = 2
        }
    }
    catch
    { 
        Write-Message ("Install Fail")
        $ReturnCode = 1
    }
    return $ReturnCode
}

function CleanTestData ()
{
    Remove-Item $testfolders -force -recurse -erroraction 'silentlycontinue'
}

function GetTestDataP4 ()
{
    [int] $ReturnCode = 0
    foreach ($Loc in $P4Folders)
    {
        $ReturnCode = RunExe $P4Exe "-u $Pusername -P $Ppassword -c $p4Workspace sync -f $P4Folders"
        if ($ReturnCode -ne 0)
        {
            return $ReturnCode
        }
    }
    return $ReturnCode
}

function RunTests ($LogFile)
{
    [int] $ReturnCode = 0
    $ReturnCode = Del $LogFile -ErrorAction SilentlyContinue
    $ReturnCode = (Start-Process -FilePath $Test -ArgumentList "$LogFile $ASVersion $global:GreatestBuildNo" -Wait -PassThru).ExitCode
    return $ReturnCode
}

function EmailResults ($TestResult, $Message, $Attachment)
{
    if ($TestResult -eq 0)
    {
        $Subject = $TestName + " " + $global:GreatestBuildNo +  " " + $Message + " Succeeded"
    }
    else
    {
        $Subject = $TestName + " " + $global:GreatestBuildNo +  " " + $Message + " Failed Error: " + $TestResult
    }

    $Body = $Subject + " " + (Get-Date)

    if ($Attachment)
    {
        Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Credential $cred -Attachments $Attachment
    }
    else
    {
        Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Credential $cred 
    }
}

Remove-Item $LogFile -force -erroraction 'silentlycontinue'
Write-Message (Get-Date)
<#CleanTestData
[int] $ReturnCode = GetTestDataP4
if ($ReturnCode -ne 0)
{
    EmailResults 1 ("Configuration of Machine " + $env:computername)  $LogFile
    Exit
}#>
$global:GreatestBuildNo = GetLatestBuild $BuildLocation
#$global:GreatestBuildNo = "2156"
$global:GreatestBuildNo | out-file "C:\TestSetDev\PropertiesFiles\Latestbuild.txt"
$LastBuildNo=Get-Content "C:\TestSetDev\PropertiesFiles\Lastbuild.txt"
#Install Latest Version
if ($LastBuildNo -ne $global:GreatestBuildNo)
{
$Returncode_old = UninstallInstall
}
#$ReturnCode = Test-Path "C:\Program Files\AdminStudio\2018\Common\AdminStudio.exe"
$ReturnCode = Test-Path "C:\Program Files (x86)\AdminStudio\2018\Common\AdminStudio.exe"
#Run Tests
if ($ReturnCode -eq 1)
{
    #DropDatabase "Daily_BDS" $connectionstring 
    Set-itemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio\16.0" -name "LSProductID" -Value "Eval"
	Set-itemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio\16.0" -name "LicenseServer" -Value "@10.20.151.68"

    $ReturnCode = RunTests $LogFile 
    EmailResults $ReturnCode ("Test Execution on "+ $env:computername) $LogFile
}
else
{
    EmailResults $ReturnCode ("Configuration of Machine "+ $env:computername) $LogFile
}

$global:GreatestBuildNo | out-file "C:\TestSetDev\PropertiesFiles\Lastbuild.txt"
Write-Message (Get-Date)
cd $sCurrentLoc 