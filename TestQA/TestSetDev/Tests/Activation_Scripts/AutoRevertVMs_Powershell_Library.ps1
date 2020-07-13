#Shared locations Configurations
##########################################################################################

$ConfigParent="\\10.80.150.177\Hyper-VAutomation\RevertVMsInstallLatestASBuild"
$SharedBuildLoc = "\\10.80.150.177\Hyper-VAutomation\LastLatestASBuild"

##########################################################################################

Function Write-Message ($Message,$TLogFile)
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' ['+$ScriptName +'] ' + $Message + "`n"
    Write-Host $Header
    #$Header | Out-File -Encoding Ascii $LogFile -Append
    Add-Content -Value $Header -Path $TLogFile
}

Function IsPathDirectory ($file)
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


Function GetLatestBuild ($Machine)
{
    #write-host $BuildLocation Access Status
    $CommandLineUser = "/user:" + $DomainUsername
    $ThrowOutResult = net use $BuildShare $CommandLineUser $password 
    #Translate the build location access result to readable format.
    Write-Message ("Accessing the Build Location..." ) $DetLogFile 
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

Function GetLatestBuildCopyToSharedLocation($BuildLocation, $SharedBuildLoc)
{
$RetVal=-1
$BuildSubPath        = "Full\Suite\Compressed"
Write-Message ("Getting Last Latest $AdminStudioVersion Build from: " + $BuildLocation) $DetLogFile
$global:GreatestBuildNo = GetLatestBuild $BuildLocation
$FullBuildPath =  $BuildLocation +"\" +$global:GreatestBuildNo + "\"+ $BuildSubPath+"\"+$InstallerExeName


  if(($Global:GreatestBuildNo -ne "0") -and ($FullBuildPath))
    {
      Write-Message ("Copying Last Latest $AdminStudioVersion Build # $global:GreatestBuildNo From  " + $BuildLocation + " To " + $SharedBuildLoc) $DetLogFile
      Remove-Item $SharedBuildLoc+"\*" -Force -ErrorAction SilentlyContinue
      Copy-Item $FullBuildPath -Destination $SharedBuildLoc
       if(Test-Path $SharedBuildLoc+"\"+$InstallerExeName)
      {
      Write-Message ("Copied Last Latest $AdminStudioVersion Build # $global:GreatestBuildNo From  " + $BuildLocation + " To " + $SharedBuildLoc + " Successfully") $DetLogFile
      $Retval=0
      }
      else
      {
      Write-Message ("Copying Last Latest $AdminStudioVersion Build # $global:GreatestBuildNo From  " + $BuildLocation + " To " + $SharedBuildLoc + " Failed") $DetLogFile
      $Retval=-1
      }
    }
   else
    {
      Write-Message ("Copying Latest $AdminStudioVersion Build # $global:GreatestBuildNo Failed, Because it is NOT Available at the specified Location : " + $FullBuildPath) $DetLogFile
      $Retval=-1
    }
return $RetVal
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
        Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Credential $EmailCredentials -Attachments $Attachment
    }
    else
    {
        Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Credential $EmailCredentials 
    }
}


#Function to Revert and Install latest build
Function RevertAndInstallLatestBuild ($TargetVMsCSV,$Global:ScriptName)
{
   $RetVal=0

   #Configuring Powershell remoting on the current machine
   Write-Message "Configuring the PowerShell remoting on $env:computername" $DetLogFile
   $EnablePSRemoting=Enable-PSRemoting -Force
   $SetFireWallStatus=netsh advfirewall set allprofiles state off
   $WinRmQUickConfig=winrm quickconfig
   $TrustedHosts=winrm s winrm/config/client '@{TrustedHosts="*"}'
   

   

   #Start Processing CSV

     

     if($TargetVMsCSV)
     {
        $CSVContent=Import-Csv $TargetVMsCSV
        $CSVContent |
            ForEach-Object {
            $TargetVMName=$_.ActualVMName
            $TargetCPName=$_.CheckPointName
            $ToRevert=$_.ToRevert
            $ToInstallLatestBuild=$_.ToInstallLatestBuild
            $VMHostName=$_.VMHostName
            $VMBuildFolder="\\"+$VMHostName+"\Build"
              if($ToRevert -eq 1)
               {
                #Connecting to Hyper V using a powershell session
                $HypVSession = New-PSSession -ComputerName $HyperVFQDName -Credential $HypVCredentials
                Write-Message "Connected to the Hyper-V Server $HyperV with Session Id: $HypVSession" $DetLogFile
                #Getting TargetVM Details and Reverting to a specified snapshot

                Invoke-Command -Session $HypVSession -ScriptBlock {Param($HyperV, $TargetVMName, $TargetCPName, $LogFile, $ConfigParent, $Global:ScriptName, $DetLogFile)
                                                                                                                                       
                                                                    Function Write-Message ($Message, $TLogFile)
                                                                            {
                                                                              $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' ['+$Global:ScriptName+'] ' + $Message + "`n"
                                                                              Write-Host $Header
                                                                              $DomainUsername="flexerasoftware\Administrator"
                                                                              $password="AS@dmin1"
                                                                              $CommandLineUser = "/user:" + $DomainUsername
                                                                              $ThrowOutResult = net use $ConfigParent $CommandLineUser $password
                                                                              Add-Content -Value $Header -Path $TLogFile
                                                                            }
                                                                    Write-Message "Getting VM Status Details:$TargetVMName"  $DetLogFile  
                                                                    $TargetVMObj=Get-VM -Name $TargetVMName
                                                                    $VMFound=-1

                                                                    # Checking the existence of the VM on the Hyper-V
                                                                    if($TargetVMObj.Name -eq $TargetVMName)
                                                                    {
                                                                     Write-Message "Target VM: $TargetVMName present on the Hyper-V server: $HyperV  " $LogFile
                                                                     Write-Message "Target VM: $TargetVMName present on the Hyper-V server: $HyperV  " $DetLogFile

                                                                    $VMFound=0
                                                                    }
                                                                    else
                                                                    {
                                                                    Write-Message "Target VM: $TargetVMName not present on the Hyper-V server: $HyperV" $LogFile
                                                                    Write-Message "Failed to Revert Target VM: $TargetVMName " $LogFile
                                                                    Write-Message "Target VM: $TargetVMName not present on the Hyper-V server: $HyperV" $DetLogFile
                                                                    Write-Message "Failed to Revert Target VM: $TargetVMName " $DetLogFile
                                                                    }

                                                                    #Reverting the VM if it is found on the Hyper-V

                                                                    if(($TargetVMObj.State -ne "Off") -and ($VMFound -eq 0))
                                                                    {
                                                                    Write-Message "Shutting down the VM: $TargetVMName" $DetLogFile
                                                                    $StopVM=Stop-VM -Name $TargetVMName -Force
                                                                    Write-Message "Shutdown the VM: $TargetVMName Successfully" $DetLogFile
                                                                    Write-Message "Reverting VM $TargetVMName to Checkpoint $TargetCPName" $DetLogFile
                                                                    $SnapshotApplied = Get-VMSnapshot -Name $TargetCPName -VMName $TargetVMName | RESTORE-VMSnapshot –confirm:$False

                                                                    
                                                                    Write-Message "Reverted the Target VM: $TargetVMName  to Checkpoint $TargetCPName Successfully" $DetLogFile
                                                                    Write-Message "Reverted the Target VM: $TargetVMName  to Checkpoint $TargetCPName Successfully" $LogFile
                                                                    Write-Message "Starting the Target VM: $TargetVMName" $DetLogFile
                                                                    $VMStarted = Start-VM -Name $TargetVMName
                                                                    Start-Sleep 120
                                                                    Write-Message "Started the Target VM: $TargetVMName Successfully" $DetLogFile
                                                                    Write-Message "Target VM:$TargetVMName Now ready to be installed with latest AS Build" $LogFile
                                                                    Write-Message "Target VM:$TargetVMName Now ready to be installed with latest AS Build" $DetLogFile
                                                                                                                                     
                                                                    }

                                                                    elseif(($TargetVMObj.State -eq "Off") -and ($VMFound -eq 0))
                                                                    {
                                                                    Write-Message "The Target VM: $TargetVMName is already turned off" $DetLogFile
                                                                    Write-Message "Reverting VM $TargetVMName to Checkpoint $TargetCPName" $DetLogFile
                                                                    $SnapshotApplied = Get-VMSnapshot -Name $TargetCPName -VMName $TargetVMName | RESTORE-VMSnapshot –confirm:$False

                                                                    Write-Message "Reverted the Target VM: $TargetVMName  to Checkpoint $TargetCPName Successfully" $DetLogFile
                                                                    Write-Message "Reverted the Target VM: $TargetVMName  to Checkpoint $TargetCPName Successfully" $LogFile
                                                                    Write-Message "Starting the Target VM: $TargetVMName" $DetLogFile
                                                                    $VMStarted = Start-VM -Name $TargetVMName 
                                                                    Start-Sleep 300
                                                                    Write-Message "Started the Target VM: $TargetVMName Successfully" $DetLogFile
                                                                    Write-Message "Target VM: $TargetVMName Now ready to be installed with latest AS Build" $LogFile
                                                                    Write-Message "Target VM: $TargetVMName Now ready to be installed with latest AS Build" $DetLogFile
                                                                    
                                                                    }
                                                                    else
                                                                    {
                                                                     Write-Message "Target VM: $TargetVMName status is unknown on  : $HyperV  " $LogFile
                                                                     Write-Message "Target VM: $TargetVMName status is unknown on  : $HyperV  " $DetLogFile
                                                                    }
                                                                   
                                                                    } -ArgumentList $HyperV,$TargetVMName,$TargetCPName,$LogFile,$ConfigParent,$Global:ScriptName,$DetLogFile

                                                                    #Remove Hyper-V Sessions
                                                                    if($HypVSession -ne $null)
                                                                    {
                                                                    $HypVSessions = Get-PSSession
                                                                    Write-Message "Active Hyper-V Sessions: $HypVSessions " $DetLogFile
                                                                    Remove-PSSession -Session $HypVSessions
                                                                    Write-Message "Removed Active Sessions" $DetLogFile
                                                                    }
               
               }
              else
               {
               
               Write-Message "Skipped Reverting the Target VM $TargetVMName, to Checkpoint $TargetCPName as it is not set to be reverted in Configuration file.. " $LogFile
               Write-Message "Skipped Reverting the Target VM $TargetVMName, to Checkpoint $TargetCPName as it is not set to be reverted in Configuration file.. " $DetLogFile
               }

               #Verify the vm configuration in csv whether latest build need to be installed
                                                                   
               if($ToInstallLatestBuild -eq 1)
               {

                #Connecting to TargetVM Details and Installing the latest build
                #Preconfiguration
                Write-Message "Configuring the PowerShell remoting on $env:computername" $DetLogFile
                $EnablePSRemoting=Enable-PSRemoting -Force
                $SetFireWallStatus=netsh advfirewall set allprofiles state off
                $WinRmQUickConfig=winrm quickconfig
                $TrustedHosts=winrm s winrm/config/client '@{TrustedHosts="*"}'

                $TargetHostName=$VMHostName 
                $TargetHostDomain="flexerasoftware.com"
                $TargetHostFQDName= $TargetHostName +"."+$TargetHostDomain
                #$TargetHostFQDName= $TargetHostName
                $TargetVMSession= New-PSSession -ComputerName $TargetHostFQDName -Credential $TargetVMCredentials
                Write-Message ("Target VM Connected with Session Id: $TargetVMSession") $DetLogFile
                $InstallerEXE = $SharedBuildLoc+"\"+$InstallerExeName

                Invoke-Command -Session $TargetVMSession -ScriptBlock {Param($SharedBuildLoc, $InstallerEXE, $VMBuildFolder, $LogFile, $Global:ScriptName, $global:GreatestBuildNo,$AdminStudioVersion, $TargetVMName, $InstallerExeName, $DetLogFile)

                                                              Function Write-Message ($Message,$TLogFile)
                                                                            {
                                                                              $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' ['+$Global:ScriptName+'] ' + $Message + "`n"
                                                                              Write-Host $Header
                                                                              $DomainUsername="flexerasoftware\Administrator"
                                                                              $password="AS@dmin1"
                                                                              $CommandLineUser = "/user:" + $DomainUsername
                                                                              $ThrowOutResult = net use $ConfigParent $CommandLineUser $password
                                                                              Add-Content -Value $Header -Path $TLogFile
                                                                            }
                                                              $DomainUsername1="flexerasoftware\Administrator"
                                                              $password1="AS@dmin1"
                                                              $CommandLineUser1 = "/user:" + $DomainUsername1
                                                              $ThrowOutResult = net use $SharedBuildLoc $CommandLineUser1 $password1
                                                              Write-Message "Accessed Source Network location... "  $DetLogFile
                                                              $ThrowOutResult1 = net use $VMBuildFolder $CommandLineUser $password
                                                              Write-Message "Accessed Destination Network location.... " $DetLogFile
                                                              Remove-Item -Path $VMBuildFolder+"\*" -force -ErrorAction SilentlyContinue
                                                              Copy-Item $InstallerEXE -Destination $VMBuildFolder 
                                                              Write-Message "Copied the insteller $InstallerEXE to Destination folder $VMBuildFolder Successfully"$DetLogFile
                                                              Write-Message "Installing $InstallerExeName from folder $VMBuildFolder" $LogFile
                                                              Write-Message "Installing $InstallerExeName from folder $VMBuildFolder" $DetLogFile
                                                              $Command = "C:\Build\" + $InstallerExeName + " /silent /debuglog"
                                                              Invoke-Expression -Command $Command
                                                              Start-Sleep 1200 
                                                              Write-Message "Installing Latest $AdminStudioVersion Build #$global:GreatestBuildNo  on VM $TargetVMName is Successful" $LogFile
                                                              Write-Message "Installing Latest $AdminStudioVersion Build #$global:GreatestBuildNo  on VM $TargetVMName is Successful" $DetLogFile
                                                              $Command = "C:\RunActivationScripts.bat"
                                                              Invoke-Expression -Command $Command
                                                              Start-Sleep 1800

                                                         }-ArgumentList $SharedBuildLoc,$InstallerEXE,$VMBuildFolder,$LogFile,$Global:ScriptName,$global:GreatestBuildNo,$AdminStudioVersion, $TargetVMName, $InstallerExeName, $DetLogFile

                                                         if($TargetVMSession -ne $null)
                                                         {
                                                         $TargetVMSessions = Get-PSSession
                                                         Write-Message "Active Sessions: $TargetVMSessions " $DetLogFile
                                                         Remove-PSSession -Session $TargetVMSessions
                                                         Write-Message "Removed Active Sessions" $DetLogFile
                                                         }


               }
               else
               {
               Write-Message "Skipped Installing Latest $AdminStudioVersion Build #$global:GreatestBuildNo  on VM $TargetVMName, as it is not set to be installed in the configuration file.. " $LogFile
               Write-Message "Skipped Installing Latest $AdminStudioVersion Build #$global:GreatestBuildNo  on VM $TargetVMName, as it is not set to be installed in the configuration file.. " $DetLogFile
               }
                                                                   

                 
            }

            
       #$CSVcontent |Export-Csv -Path $TargetVMsCSV -Force -NoTypeInformation
               

      
     }
     else
     {
     Write-Message "Configuration file not found at location: $TargetVMsCSV ..Failed to Revert VMs and Install Latest Build" $LogFile
     Write-Message "Configuration file not found at location: $TargetVMsCSV ..Failed to Revert VMs and Install Latest Build" $DetLogFile
     }

    #End of Processing CSV Here
     
if(Select-String -Pattern "Failed to " -InputObject $(Get-Content $LogFile))
{
$RetVal=-1
return $RetVal
}

return $RetVal
}
