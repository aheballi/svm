

Function SCCMDeleteAllApplicationsInAFolder($SCCMServerName,$UserName,$Password,$Sitecode,$TargetFolder)
{
   
   $EnablePSRemoting=Enable-PSRemoting -Force
   $SetFireWallStatus=netsh advfirewall set allprofiles state off
   $WinRmQUickConfig=winrm quickconfig
   $TrustedHosts=winrm s winrm/config/client '@{TrustedHosts="*"}'
   $SessionID=Create_RemotePSSession $SCCMServerName $UserName $Password
   Invoke-Command -Session $SessionID -ScriptBlock {Param($SCCMServerName,$Sitecode,$TargetFolder)

                      $SitecodeDrive=$Sitecode+":"
                      Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'  
                      Set-Location $SitecodeDrive
                      $Folders=gwmi -Namespace root\sms\site_AR3 -Class SMS_ObjectContainerNode
                      Write-Host 'Folders present under Application Node in SCCM:' $SCCMServerName are $Folders.Name

                      if($Folders.Name -contains $TargetFolder)
                      {
                      foreach($Name in $Folders)
                            {

                              if($Name.Name -eq $TargetFolder)
                                {
                                 Write-Host 'Target Folder name:'$Name.Name
                                 $ContainerNodeId=$Name.ContainerNodeID
                                 
                                 Write-Host 'Getting Applications in the folder:'$Name.Name
                                
                                 $Instancekeys = (Get-WmiObject -ComputerName $SCCMServerName -Namespace “ROOT\SMS\Site_$Sitecode” -query “select InstanceKey from SMS_ObjectContainerItem where ObjectType='6000' and ContainerNodeID='$ContainerNodeId'”).instanceKey
                                  
                                 if($Instancekeys -ne $null)
                                    {
                                
                                         foreach ($key in $Instancekeys)
                                                {
     
                                                 $AppName=(Get-WmiObject -ComputerName $SCCMServerName -Namespace “ROOT\SMS\Site_$Sitecode” -Query “select * from SMS_Applicationlatest where ModelName = '$key'”).LocalizedDisplayName
                                                 $App=(Get-WmiObject -ComputerName $SCCMServerName -Namespace “ROOT\SMS\Site_$Sitecode” -Query “select * from SMS_Applicationlatest where ModelName = '$key'”).ModelName
                                                 Write-Host 'Removing Application:'$AppName
                                                 Remove-CMApplication -ModelName $App -Force
                                                 Write-Host 'Application:'$AppName' Successfully removed from Folder:' $Name.Name
                                                }
                                   }

                                  else
                                    {
                                     Write-Host 'No Applications present to remove in the Folder:' $Name.Name
                                    }
  
                               }
                              

                            }
   
                      }
                      else
                      {
                       Write-Host 'Specified folder:' $TargetFolder 'is not present on the SCCM:'$SCCMServerName
                      }
                     
   
    }-ArgumentList $SCCMServerName,$Sitecode,$TargetFolder

    Remove-PSSession $SessionID
    

}




Function Create_RemotePSSession($HostName,$UserName,$Password)
{
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
    $Session=New-PSSession -ComputerName $HostName -Credential $cred 
    $session     
}









$SCCMServerName='AS201604CM1710'
$UserName="AR\Administrator"
$Password="AS@dmin1"
$Sitecode = “AR3”
$TargetFolder='Automation'
SCCMDeleteAllApplicationsInAFolder $SCCMServerName $UserName $Password $Sitecode $TargetFolder
 
   