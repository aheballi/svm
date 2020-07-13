﻿. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost 
Start-Sleep 30

#start
$TestName='04MSIPublish_ToSCCM_And_Validate'
#$SCCMServerVersion = '1710'
$ParentFolder = "C:\AS_Automation"
$TestCaseName="04MSIPublish_ToSCCM_And_Validate"
$PackageName = "Firefox.msi"
$Dep1 ="Orca.msi"
$Dep2 ="MsiVal2.msi"
$Sup1="CERAS.msi"
$Sup2="msxml3.msi"
$csvFileName="MSIPublish_ToSCCM_And_Validate"+$SCCMServerVersion+".csv"
$AppId=0

$TestCaseFolder=$ParentFolder+"\"+$TestCaseName
$logFile=$TestCaseFolder + "\"+$TestCaseName+".log"
$CatalogName=$TestCaseName
$SRFlag=0
$csvFilePath=$TestCaseFolder + "\"+ $csvFileName
$PackageLocation=$TestCaseFolder + "\"+$PackageName
$DepPkgLocation1=$TestCaseFolder+"\"+$Dep1
$DepPkgLocation2=$TestCaseFolder+"\"+$Dep2
$SuperPkgLocation1=$TestCaseFolder+"\"+$Sup1
$SuperPkgLocation2=$TestCaseFolder+"\"+$Sup2

$SQLScriptsFolder =$TestCaseFolder + '\SQLScripts'
$SCCM_ConnectionName= "SCCM_MSI"
$PublishLoc= '\\'+$SCCMServerName+'\Publish'

$HostName = hostname
$UNCPath = "\\$HostName\$TestCaseName"

Write-Host (Write-Header $TestName) "Test Started"

If(Test-Path $logFile)
{
    Remove-Item $logFile
}

$strSourcePath="$TestDataSource\Publish\"+$TestCaseName

#Copy test data
$Retval= CopyTestDataLocally $strSourcePath $ParentFolder 0
WriteResultsToFile $logFile "Copy test data from shared folder." $retval 0

#create a new catalog

$retval= CreateNewCatalog $CatalogName $SRFlag
IF ($retval -eq 0){
    WriteResultsToFile $logFile "Create new catalog." $retval 0
}
else
{
    WriteResultsToFile $logFile "Create new catalog." $retval 0
    Exit 1
}

#UnSelecting all rules in Select Tests to Execute Window
$RetVal= SelectAllRules $catalogName 0
WriteResultsToFile $logFile "Unselecting all rules in the catalog $CatalogName" $Retval 0

#connect to new catalog
$Retval=ConnectToCatalog($CatalogName)

CreateDistributionConnection $SCCM_ConnectionName 'SCCM' $SCCMServername $SCCMSitecode $PublishLoc $CatalogName

#Import the package
$depPkgID1=ImportSinglePackage $DepPkgLocation1 $CatalogName
WriteResultsToFile $logFile "Import Dependency Package $Dep1 " ($depPkgID1 -gt 0) $true

$SuperPkgID1=ImportSinglePackage $SuperPkgLocation1 $CatalogName
WriteResultsToFile $logFile "Import Supersedence Package $Sup1 " ($SuperPkgID1 -gt 0) $true

$SuperPkgID2=ImportSinglePackage $SuperPkgLocation2 $CatalogName
WriteResultsToFile $logFile "Import Supersedence Package $Sup2 " ($SuperPkgID2 -gt 0) $true

$PkgID=ImportSinglePackage $PackageLocation $CatalogName
WriteResultsToFile $logFile "Import $PackageName Package to catalog." ($PkgID -gt 0) $true

$SuperAppId1= Get-ASApplicationID -PackageId $SuperPkgID1
WriteResultsToFile $logFile "Fetching Supersedence Applicaiton ID for $Sup1 is: $SuperAppId1" ($SuperAppID1 -gt 0) $true

$SuperAppId2= Get-ASApplicationID -PackageId $SuperPkgID2
WriteResultsToFile $logFile "Fetching Supersedence Applicaiton ID for $Sup2 is: $SuperAppId2" ($SuperAppID2 -gt 0) $true

$Retval = DistributeApplication $SCCM_ConnectionName $SuperAppID1 $SCCMTargetGroup
WriteResultsToFile $logFile "Publishing of supersedence $Sup1 application:" $Retval 0

$Retval = DistributeApplication $SCCM_ConnectionName $SuperAppID2 $SCCMTargetGroup
WriteResultsToFile $logFile "Publishing of supersedence $Sup2 application:" $Retval 0

<#Adding data to Requirements, Dependencies, Supersedence, ReturnCodes tabs
$DRSqlPath= $SQLScriptsFolder +'\DeviceRequirements\Add'
AddDeviceRequirements $DRSqlPath $PkgID $CatalogName

$URSqlPath= $SQLScriptsFolder +'\UserRequirements\Add'
AddUserRequirements $URSqlPath $PkgID $Catalogname

$DMSqlPath= $SQLScriptsFolder +'\DetectionMethod\Add'
AddDetectionMethod $DMSqlPath $PkgID $CatalogName

$DepSqlPath= $SQLScriptsFolder +'\Dependency\Add'
AddDependencies $DepSqlPath $PkgID $depPkgID1 $CatalogName

$SupSqlPath= $SQLScriptsFolder +'\Supersedence\Add'
AddSupersedence $SupSqlPath $PkgId $SuperPkgID1 $CatalogName

$RCSqlPath= $SQLScriptsFolder +'\ReturnCodes\Add'
AddReturnCodes $RCSqlPath $PkgId $CatalogName#>

#Adding Dependency
$Type="Dependency"
$DependencyXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Dependency.xml"
AddAppModelData $Type $DependencyXmlPath $PkgID $depPkgID1

<#Adding UserRequirement
$Type="UserRequirement"
$UserRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\UserRequirement.xml"
AddAppModelData $Type $UserRequirementXmlPath $PkgID
#>

#Adding UserRequirement
$Type="UserRequirement1"
$UserRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\UserRequirement.xml"
AddAppModelData $Type $UserRequirementXmlPath $PkgID

#Adding DeviceRequirement
<#$Type="DeviceRequirement"
$DeviceRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\DeviceRequirement.xml"
AddAppModelData $Type $DeviceRequirementXmlPath $PkgID
#>

#Adding DeviceRequirement1
$Type="DeviceRequirement1"
$DeviceRequirementXmlPath1="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\Requirement1.xml"
AddAppModelData $Type $DeviceRequirementXmlPath1 $PkgID

#Adding DeviceRequirement2
$Type="DeviceRequirement2"
$DeviceRequirementXmlPath2="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\Requirement2.xml"
AddAppModelData $Type $DeviceRequirementXmlPath2 $PkgID

#Adding DeviceRequirement3
$Type="DeviceRequirement3"
$DeviceRequirementXmlPath3="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\Requirement3.xml"
AddAppModelData $Type $DeviceRequirementXmlPath3 $PkgID

#Adding FreeDiskDeviceRequirement
$Type="FreeDiskDeviceRequirement"
$FreeDiskDeviceRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\FreeDiskReq.xml"
AddAppModelData $Type $FreeDiskDeviceRequirementXmlPath $PkgID

#Adding Supercedence
$Type="Supercedence"
$SupersedenceXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Supersedence.xml"
AddAppModelData $Type $SupersedenceXmlPath $PkgID $SuperPkgID1

#Adding ReturnCodes
$Type="ReturnCodes"
$ReturnCodesXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\ReturnCodes.xml"
AddAppModelData $Type $ReturnCodesXmlPath $PkgID

<#
#Adding DetectionMethod
$Type="DetectionMethod"
$DetectionMethodXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\DetectionMethod.xml"
AddAppModelData $Type $DetectionMethodXmlPath $PkgID
#>


#Adding FileDetectionMethod
$Type="FileDetectionMethod"
$FileDetectionMethodXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Detection\file.xml"
AddAppModelData $Type $FileDetectionMethodXmlPath $PkgID

#Adding FolderDetectionMethod
$Type="FolderDetectionMethod"
$FolderDetectionMethodXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Detection\folder.xml"
AddAppModelData $Type $FolderDetectionMethodXmlPath $PkgID


#Ading RegistryDetectionMethod
$Type="RegistryDetectionMethod"
$RegistryDetectionMethodXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Detection\registry.xml"
AddAppModelData $Type $RegistryDetectionMethodXmlPath $PkgID


#Adding InstallerDetectionMethod
$Type="InstallerDetectionMethod"
$InstallerDetectionMethodXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Detection\windowsInstaller.xml"
AddAppModelData $Type $InstallerDetectionMethodXmlPath $PkgID



$AppId= Get-ASApplicationID -PackageId $PkgID
WriteResultsToFile $logFile "Fetching Applicaiton ID for $PackageName : $AppID" ($AppID -gt 0) $true

#Publishing application to SCCM
$Retval = DistributeApplication $SCCM_ConnectionName $AppID $SCCMTargetGroup

IF ($Retval -eq 0){
    WriteResultsToFile $logFile "Publishing of $PackageName application:" $Retval 0
}
else
{
    WriteResultsToFile $logFile "Publishing of $PackageName application:" $Retval 0
    Exit 1
}

$SCCMID1= AS_GetSCCMAppID $CatalogName $PkgID
Add-Content -Path $logFile -Value "publish id: $SCCMID2"

$SessionID = Create_PSSession $SCCMServername $SCCMSitecode
Add-Content -Path $logFile -Value "session id is: $SessionID"


#validating properties of applications published to SCCM
$Retval=Process_SCCMPublish_CSV $csvFilePath $CatalogName $PkgID 'Published' $SessionID

$RetVal=ProcessCSVColumnValue $csvFilePath "PUBLISHSTATUS" "Fail"
WriteResultsToFile $logFile "Validating AppModel properties of the $PackageName package in SCCM with Application Manager after publish in CSV File is:" $retval -1

#Validating Content location in SCCM after first publish as in AM UI the content value will be blank
$GUId= ExecuteSQLQuery "SELECT CustomID FROM ASCMApplicationDeployment WHERE Group_=(select ParentGroupCode from cstblGroupPackages where PkgRowID_ = $PkgId)" $CatalogName
$Revision =ExecuteSQLQuery "select Revision from ASCMApplicationDeployment where Group_=(select ParentGroupCode from cstblGroupPackages where PkgRowID_ = $PkgId)" $CatalogName
$ASContentLoc= $PublishLoc + '\' + $GUId + '\' + $Revision + '\' + $PkgID + '\'
Add-Content -Path $logFile -Value "Content location of the package $PackageName in AM is :$ASContentLoc"

$SCCMContentLoc= SCCM_GetContentTabProperties $SCCMID1 'Content location' $SessionID
Add-Content -Path $logFile -Value "Content location of the package $PackageName in SCCM is :$SCCMContentLoc"

WriteResultsToFile $logFile "Validating Content Lcoation value after first publish of $PackageName package in SCCM is:" $ASContentLoc $SCCMContentLoc

#####################################################################################################################################################
###################################              Republish activities begin     ############################################################
#####################################################################################################################################################

#Create a distribution point group on SCCM
$Retval = CreateDistributionPointGroup $SCCMDPGroup
WriteResultsToFile $logFile "Creating distribution point group on sccm" $Retval 0

# Process CSV for updating Appmodel values in Application Manager
$Retval=Process_SCCMPublish_CSV $csvFilePath $CatalogName $PkgID 'Update Properties' $SessionID

$RetVal=ProcessCSVColumnValue $csvFilePath "REPUBLISHSTATUS" "Fail"
WriteResultsToFile $logFile "Updating AppModel properties of the $PackageName package in Application Manager using CSV File is:" $retval -1

#Update Properties in Application Manager

#Share the test case folder.
$Retval = Sharefolder $TestCaseFolder
WriteResultsToFile $logFile "Creating a shared folder" $Retval 0

#Set content location value.
$Retval = Set-ASProperty -PackageId $PkgID -PropertyName "Location" -PropertyValue $UNCPath
WriteResultsToFile $logFile "Set Content location with test case UNC path" $Retval True

<#$Sup2SqlPath= $SQLScriptsFolder +'\Supersedence\Update'
UpdateSupersedence $Sup2SqlPath $PkgId $SuperPkgID1 $SuperPkgID2 $CatalogName

$Dep2SqlPath= $SQLScriptsFolder +'\Dependency\Update'
UpdateDependencies $Dep2SqlPath $PkgId $depPkgID1 $Null $CatalogName

$DR2SqlPath= $SQLScriptsFolder +'\DeviceRequirements\Update'
UpdateDeviceRequirements $DR2SqlPath $PkgID $CatalogName

$DM2SqlPath= $SQLScriptsFolder +'\DetectionMethod\Update'
UpdateDetectionMethod $DM2SqlPath $PkgID $CatalogName

$UR2SqlPath= $SQLScriptsFolder +'\UserRequirements\Update'
UpdateUserRequirements $UR2SqlPath $PkgID $CatalogName

$RC2SqlPath= $SQLScriptsFolder +'\ReturnCodes\Update'
UpdateReturnCodes $RC2SqlPath $PkgID $CatalogName#>

#Updating Supercedence
$Type="Supercedence"
$Uninstall="true"
UpdateAppModelData $Type $SupersedenceXmlPath $PkgID $Uninstall

#Adding Supersedence
$Type="Supercedence"
$SupersedenceXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Supersedence1.xml"
AddAppModelData $Type $SupersedenceXmlPath $PkgID $SuperPkgID2

<#Updating UserRequirement
$Type="UserRequirement"
$Val="False"
UpdateAppModelData $Type $UserRequirementXmlPath $PkgID $Val
#>

#Updating UserRequirement
$Type="UserRequirement1"
$UpdatedUserRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\UpdatedUserRequirement.xml"
UpdateAppModelData $Type $UpdatedUserRequirementXmlPath $PkgID

#Removing UserRequirement
$Type="UserRequirement"
$AppIndex=1
RemoveAppModelData $Type $PkgID $AppIndex

<#
#Updating DeviceRequirement
$Type="DeviceRequirement"
$Value=300
$Operator="GreaterThan"
UpdateAppModelData $Type $DeviceRequirementXmlPath $PkgID $Value $Operator
#>

#Updating DeviceRequirement1
$Type="DeviceRequirement1"
$UpdatedDeviceRequirementXmlPath1="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\UpdatedRequirement1.xml"
UpdateAppModelData $Type $UpdatedDeviceRequirementXmlPath1 $PkgID

#Updating DeviceRequirement2
$Type="DeviceRequirement2"
$UpdatedDeviceRequirementXmlPath2="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\UpdatedRequirement2.xml"
UpdateAppModelData $Type $UpdatedDeviceRequirementXmlPath2 $PkgID

#Updating DeviceRequirement3
$Type="DeviceRequirement3"
$UpdatedDeviceRequirementXmlPath3="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\UpdatedRequirement3.xml"
UpdateAppModelData $Type $UpdatedDeviceRequirementXmlPath3 $PkgID

#Updating FreeDiskDeviceRequirement
$Type="FreeDiskDeviceRequirement"
$UpdatedFreeDiskDeviceRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\UpdatedFreeDiskReq.xml"
UpdateAppModelData $Type $UpdatedFreeDiskDeviceRequirementXmlPath $PkgID

#Removing DeviceRequirement
$Type="DeviceRequirement"
$AppIndex=2
RemoveAppModelData $Type $PkgID $AppIndex

#Updating Dependency
$Type="Dependency"
$AutoInstall=1
UpdateAppModelData $Type $DependencyXmlPath $PkgID $AutoInstall

#Updating ReturnCodes
$Type="ReturnCodes"
$Name="test"
UpdateAppModelData $Type $ReturnCodesXmlPath $PkgID $Name

<#
#Updating Detectionmethod
$Type="DetectionMethod"
$DetectionType="Integer"
$IntegerValue=68
UpdateAppModelData $Type $DetectionMethodXmlPath $PkgID $DetectionType $IntegerValue
#>

#Updating File Detection
$Type="FileDetectionMethod"
$FileDetectionMethodXmlPathUpdate="$ParentFolder\$TestCaseName\XmlDocuments\Detection\file_update.xml"
UpdateAppModelData $Type $FileDetectionMethodXmlPathUpdate $PkgID

#Updating Folder Detection
$Type="FolderDetectionMethod"
$FolderDetectionMethodXmlPathUpdate="$ParentFolder\$TestCaseName\XmlDocuments\Detection\folder _update.xml"
UpdateAppModelData $Type $FolderDetectionMethodXmlPathUpdate $PkgID

#updating Registry Detection
$Type= "RegistryDetectionMethod"
$RegistryDetectionMethodXmlPathUpdate = "$ParentFolder\$TestCaseName\XmlDocuments\Detection\registry_update.xml"
UpdateAppModelData $Type $RegistryDetectionMethodXmlPathUpdate $PkgID

#Updating Installer Detection
$Type= "InstallerDetectionMethod"
$InstallerDetectionMethodXmlPathUpdate = "$ParentFolder\$TestCaseName\XmlDocuments\Detection\windowsInstaller_update.xml"
UpdateAppModelData $Type $InstallerDetectionMethodXmlPathUpdate $PkgID

#Removing Detection AppModelData
$Type= "MSIDetectionMethod"
$order = 3
RemoveAppModelData $Type $PkgID $order



#Re-Publishing application to SCCM
$Retval = DistributeApplication $SCCM_ConnectionName $AppID $SCCMTargetGroup

IF ($Retval -eq 0){
    WriteResultsToFile $logFile "Re-Publishing of $PackageName application:" $Retval 0
}
else
{
    WriteResultsToFile $logFile "Re-Publishing of $PackageName application:" $Retval 0
    Exit 1
}

$SCCMID2= AS_GetSCCMAppID $CatalogName $PkgID
Add-Content -Path $logFile -Value "republish application ID :$SCCMID2"

#validating properties of applications republished to SCCM
$retval=Process_SCCMPublish_CSV $csvFilePath $CatalogName $PkgID 'Republished' $SessionID

$RetVal=ProcessCSVColumnValue $csvFilePath "REPUBLISHSTATUS" "Fail"
WriteResultsToFile $logFile "Validating AppModel properties of the $PackageName package in SCCM with Application Manager after republish in CSV File is:" $retval -1

#Validate updated 'Content Location'
$UNCPath = (Get-ASProperty -PackageId $PkgId -PropertyName "Location")+'\'
Add-Content -Path $logFile -Value "Content location of the package $PackageName in AM is :$UNCPath"

$Retval = SCCM_GetContentTabProperties $SCCMID2 "Content location" $SessionID
Add-Content -Path $logFile -Value "Content location of the package $PackageName in SCCM is :$Retval"

WriteResultsToFile $logFile "Validating Content Location property of the $PackageName package in SCCM with Application Manager after re-publish in CSV File is:" $retval $UNCPath

#Deleting all applications published to SCCM
$PkgList = @($PkgID,$SuperPkgID2,$SuperPkgID1,$depPkgID1)
RemoveSCCMApplication $PkgList $SessionID

#removing ps session
Remove-PSSession -Session $SessionID

#Unsharing of TestCase folder
$Retval = UnShareFolder $TestCaseFolder
WriteResultsToFile $logFile "Unsharing of folder is :" $retval 0



If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile))
{
    Write-host (Write-Header $TestName) "MSIPublish_ToSCCM_And_Validate Test Case Failed"
    $retval=-1
	Get-Process AdminStudioHost | Stop-Process
	exit 1
}
Else 
{
    Write-host (Write-Header $TestName) "MSIPublish_ToSCCM_And_Validate Test Case Passed"
    $retval=0
	#Deleting catalog
    DeleteCatalog $CatalogName
	Get-Process AdminStudioHost | Stop-Process
	exit 0
}
