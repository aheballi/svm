[string]$sMajorVersionNo    = "18.0"

If ( (Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit" )
    {
        $shive              = 'HKLM:\SOFTWARE\Wow6432Node\InstallShield\AdminStudio\' + $sMajorVersionNo  +'\'
        $slocation          = "Product Location"
        $sAsLoc             = (Get-ItemProperty $shive $slocation).$slocation
        $sAsLoc             = @{$true=$sAsLoc;$false=$sAsLoc +'\'}[$sAsLoc.EndsWith("\")]
        $sAsLoc             = Join-Path $sAsLoc "Common"
        $ASsharelocation          = "Shared Location"
        $AdminStudioSharedLocation = (Get-ItemProperty $shive $ASsharelocation).$ASsharelocation
    }
else
    {
        $shive              = 'HKLM:\SOFTWARE\InstallShield\AdminStudio\' + $sMajorVersionNo  +'\'
        $slocation          = "Product Location"
        $sAsLoc             = (Get-ItemProperty $shive $slocation).$slocation
        $sAsLoc             = @{$true=$sAsLoc;$false=$sAsLoc +'\'}[$sAsLoc.EndsWith("\")]
        $sAsLoc             = Join-Path $sAsLoc "Common"
        $ASsharelocation          = "Shared Location"
        $AdminStudioSharedLocation = (Get-ItemProperty $shive $ASsharelocation).$ASsharelocation
    } 

$UserName="AR\Administrator"
$Password="AS@dmin1"
#$SCCMServerName='AS201604CM1710.ar.flexdev.com'
#$PublishLoc= '\\'+'AS201604CM1710'+'\Publish'
#$SCCMServerName='10.80.150.163'
#$SCCMServerName='10.80.150.95'
$SCCMServerName='10.80.149.109'
#$PublishLoc = "\\10.80.150.163\Publish"
$PublishLoc = "\\10.80.149.109\Publish"
#$SCCMSiteCode= 'AS1'
#$SCCMSiteCode= 'IND'
$SCCMSiteCode= 'CMB'
#$SCCMDB = 'CM_AS1'
#$SCCMDB = 'CM_IND'
$SCCMDB = 'CM_CMB'
$SCCMTargetGroup= 'Applications\Automation'
$SCCMDPGroup= 'Distribution Point Group'
#$SQLServer= 'ASWIN2016SQL14.ar.flexdev.com'
$SQLServer= 'ASW2016SQL1701'
$SCCMScopeid = "ScopeId_f7931bc0-6ad5-4689-a544-aee08e9d5f90"
$TestDataSource = '\\10.80.150.184\Automation_TestData'
$sCurrentLoc    = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$ParentFolder="C:\AS_Automation"
$Provider = "SQLNCLI11" #use for Ising R2 builds and above.
#$Provider = "SQLOLEDB.1" #use for Ising builds and below.
#$WrapType='Exe'
$WrapType='Ps1'