$TestName            = "QA Tests for AdminStudio"
$ASVersion           = "17.0"
$BuildShare          = "\\itareleases.acresso.com"
$BuildLocation       = $BuildShare + "\Builds\AdminStudio\17.0 (Hawking)"
$BuildSubPath        = "Full\Suite\Compressed"
$InstallerExeName    = "AdminStudio2019.exe"
$sUninstallKey       = "HKLM:SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{D6AB22DC-F133-4605-A75B-87A6BF3AE858}"
$Test                = "c:\TestSetDev\Test.bat"
$testfolders         = @( "C:\TestSetDev\*" )
$Installfolders      = @( "C:\Program Files (x86)\AdminStudio\*" )
$username            = "releaseengineer"
$DomainUsername      = "acresso\" + $username 
$p4Workspace		 = "releaseengineer_AdminStudioMarino_5432"
$password            = "Narlokwilt647"
$cred                = New-Object System.Management.Automation.PSCredential -ArgumentList @($DomainUsername,(ConvertTo-SecureString -String $password -AsPlainText -Force))
$ProcessesToKill     = @( "AdminStudioHost", "Iscmide", "aacx" )
$ProductCodesToRemove= @( "{08AB5C19-923F-4C96-BA2C-F56B083E1B52}", 
                          "{1DFEF869-1444-41AE-9393-2A090069950F}", 
                          "{3A251032-561F-40CC-9E1B-C9339CCBB961}", 
                          "{589BE9E8-7B95-4E84-A034-DE5CA9262E30}",
                          "{6CBBA804-F6DA-4A7C-B377-62E10FE79C85}",
                          "{C1F25CAF-5506-44EF-8E08-5B18D2E8A712}",
                          "{E2F537D1-2C29-436B-9C0F-82C01C16DBED}")
########################################################################################
# Email Settings
$From                = "ReleaseEngineer@flexerasoftware.com"
$To                  = @( "MichaelMarino@flexerasoftware.com")
$Cc                  = "MichaelMarino@flexerasoftware.com"
$Subject             = "Test Results"
$Body                = "Insert body text here"
$SMTPServer          = "relay.flexera.com"

########################################################################################
# Settings that do not usually change
$connectionstring    = "Data Source=localhost;User ID=adminstudiomari\mmarino;Integrated Security=SSPI;"
$DBName              = "DailyDB"
$sCurrentLoc         = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$LogFile             = "c:\log.txt"
$ShortLogFile        = "c:\logShort.txt"
$MsiExec             = "C:\Windows\System32\Msiexec.exe"
$IISReset            = "C:\Windows\System32\IISreset.exe"
$global:GreatestBuildNo =  "0"
$P4Folders           = @( "//AdminStudio/AdminStudio/Current/TestQA/TestSetDev/..." ,"//AdminStudio/AdminStudio/Current/Test/..." )
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
        Write-Message ("Deleted DB: " + $table)
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
    $Array.Sort()
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
                cd $WDir  >$null 2>&1
                $ReturnCode = StartProcess $FileToRun $ArgumentList
                cd $sCurrentLoc  >$null 2>&1
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
            cmd /c "del %temp%\*.* /Q /S" >$null 2>&1
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
        $ReturnCode = RunExe $P4Exe "-u $username -P $password -c $p4Workspace sync -f $P4Folders"
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
    $ReturnCode = StartProcess $Test "$LogFile $ASVersion $global:GreatestBuildNo"
    return $ReturnCode
}

function EmailResults ($TestResult, $Message,  $Body, $Attachment)
{
    if ($TestResult -eq 0)
    {
        $Subject = $TestName + " " + $global:GreatestBuildNo +  " " + $Message + " Succeeded"
    }
    else
    {
        $Subject = $TestName + " " + $global:GreatestBuildNo +  " " + $Message + " Failed Error: " + $TestResult
    }


    if ($Attachment)
    {
        Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -BodyAsHtml ($Subject + "<br>" + (Get-Date) + $Body) -SmtpServer $SMTPServer -Credential $cred -Attachments $Attachment
    }
    else
    {
        Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -BodyAsHtml ($Subject + "<br>" + (Get-Date) + $Body) -SmtpServer $SMTPServer -Credential $cred 
    }
}

  
$Body = "<br>" +  "RDP to: " +  (Get-NetIPAddress -AddressFamily IPv4)[0].IPAddress +  "<br>" + "User Name: " + ($env:computername + "\mmarino") +  "<br>" + "Password: " +  "Flexera!"


$Install = $True
$ReturnCode  = 0
if ($Install -eq $True)
{
    Remove-Item $LogFile -force -erroraction 'silentlycontinue' 
    Remove-Item $ShortLogFile -force -erroraction 'silentlycontinue'

    Write-Message (Get-Date)
    
    Write-Message ("RDP to: " + (Get-NetIPAddress -AddressFamily IPv4)[0].IPAddress)
    Write-Message ("User Name: " + ($env:computername + "\mmarino"))
    Write-Message ("Password: " + "Flexera!")


    CleanTestData
    #[int] $ReturnCode = GetTestDataP4
    if ($ReturnCode -ne 0)
    {
        EmailResults 1 ("Configuration of Machine " + $env:computername)  $Body $LogFile 
    }
    $global:GreatestBuildNo = GetLatestBuild $BuildLocation
    #Install Latest Version
    $ReturnCode = [int] (UninstallInstall)
}

#Run Tests
if ($ReturnCode -eq 0)
{
    DropDatabase "Daily_BDS" $connectionstring
    $ReturnCode = RunTests $ShortLogFile
    $OutputFromScript  = Get-Content -Path $ShortLogFile 
    $OutputFromScript | Out-File $LogFile -Append
    $OutputFromScript
    EmailResults $ReturnCode ("Text Execution on "+ $env:computername)  $Body $LogFile
}
else
{
    EmailResults $ReturnCode ("Configuration of Machine "+ $env:computername)  $Body $LogFile 
}
#Clean Up DBs
DropDatabase ("UnitTest_Test"+ $global:GreatestBuildNo) $connectionstring
DropDatabase ("UnitTest"+ $global:GreatestBuildNo) $connectionstring
DropDatabase ("UnitTestWS"+ $global:GreatestBuildNo) $connectionstring
Write-Message (Get-Date)
cd $sCurrentLoc