function Write-Message ($Message)
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' [Auto Installer] ' + $Message + "`n"
    Write-Host $Header
    #$Header | Out-File -Encoding Ascii $LogFile -Append
    Add-Content -Value $Header -Path $LogFile
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
    #write-host $BuildLocation Access Status
    $CommandLineUser = "/user:" + $DomainUsername
    $ThrowOutResult = net use $BuildShare $CommandLineUser $password 
    #Translate the build location access result to readable format.

    Write-Message "Accessing Build Location:" + $BuildLocation + "is"  + $ThrowOutResult
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


#Temp function to return the license key. Remove this code once license server is back 
<#function ReturnLicense($ActivationCode)
{
    #$sActivationExe = "C:\Program Files (x86)\AdminStudio\2019\Common\TpsConfig.exe"
    return (Start-Process -FilePath $sActivationExe -ArgumentList "-return -silent" -Wait -PassThru).ExitCode
}
#>

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
            #Returning the license key. Remove this code once license server is back 
            <#Write-Message ("Returning the license key before uninstalling the build")
            $results= ReturnLicense($ActivationCode)
            if($results -eq 0)
            {
                Write-Message ("License returned successfully")
            }
            else 
            {
                Write-Message ("License return Failed")
            }
            #>

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

function RunTests ()
{
    [int] $ReturnCode = 0
    #$ReturnCode = Del $LogFile -ErrorAction SilentlyContinue
    C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -File "C:\TestSetDev\test.ps1" "$ASVersion" "$global:GreatestBuildNo"
    return $ReturnCode
}

function EmailResults ($TestResult, $Message, $Attachment)
{
    if ($TestResult -eq 0)
    {
        $Subject = $Message + " :Succeeded"
    }
    else
    {
        $Subject = $Message + " Failed Error: " + $TestResult
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

function MountBuildSharedDrive($Path)
{
$TestPathStatus=Test-Path $Path
if(!$TestPathStatus)
{
$net = new-object -ComObject WScript.Network
$net.MapNetworkDrive("u:", $Path, $false, $DomainUsername, $password)
Write-Message ("Shared Drive U: Mounted Successfully")
}
else
{
Write-Message ("Shared Drive U: already Mounted")
}

}