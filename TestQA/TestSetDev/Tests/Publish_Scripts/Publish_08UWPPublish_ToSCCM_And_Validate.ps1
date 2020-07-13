. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

Start-Process AdminStudioHost
Start-Sleep 30

#start
$TestName='08UWPPublish_ToSCCM_And_Validate'

$ParentFolder = "C:\AS_Automation"
$TestCaseName="08UWPPublish_ToSCCM_And_Validate"
$PackageName = "UWP-Desktop.appx"
$Dep1 ="Viber.appx"
$Dep2 ="GoogleEarth.appx"
$Sup1="Evernote.appx"
$Sup2="Firefox.appx"
$csvFileName="UWPPublish_ToSCCM_And_Validate"+$SCCMServerVersion+".csv"
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

$SCCM_ConnectionName= "SCCM_UWP"

$HostName = hostname
$UNCPath = "\\$HostName\$TestCaseName"

Write-Host (Write-Header $TestName) "Test Started"

If(Test-Path $logFile)
{
    Remove-Item $logFile
}

$strSourcePath="\\10.80.150.184\Automation_TestData\Publish\"+$TestCaseName

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
$retval= SelectAllRules $catalogName 0
WriteResultsToFile $logFile "Unselecting all rules." $retval 0

#connect to new catalog
$Retval = ConnectToCatalog($CatalogName)
WriteResultsToFile $logFile "Connecting to catalog $CatalogName" $retval 0

CreateDistributionConnection $SCCM_ConnectionName 'SCCM' $SCCMServername $SCCMSitecode $PublishLoc $CatalogName

#Import the packages
$depPkgID1=ImportSinglePackage $DepPkgLocation1 $CatalogName
WriteResultsToFile $logFile "Import Dependency Package $Dep1 " ($depPkgID1 -gt 0) $true

$depPkgID2=ImportSinglePackage $DepPkgLocation2 $CatalogName
WriteResultsToFile $logFile "Import Dependency Package $Dep2 " ($depPkgID2 -gt 0) $true

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

$AppId= Get-ASApplicationID -PackageId $PkgID
WriteResultsToFile $logFile "Fetching Applicaiton ID for $PackageName : $AppID" ($AppID -gt 0) $true

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

<#Adding DeviceRequirement
$Type="DeviceRequirement"
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
Add-Content -Path $logFile -Value "publish id: $SCCMID" #writing value of $SCCMID to log file.

$SessionID = Create_PSSession $SCCMServername $SCCMSitecode
Add-Content -Path $logFile -Value "session id is: $SessionID" #Write session id into log file.

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

# Process CSV for updating values in Application Manager
$Retval=Process_SCCMPublish_CSV $csvFilePath $CatalogName $PkgID 'Update Properties' $SessionID

$RetVal=ProcessCSVColumnValue $csvFilePath "REPUBLISHSTATUS" "Fail"
WriteResultsToFile $logFile "Updating AppModel properties of the $PackageName package in Application Manager using CSV File is:" $retval -1

#Share the test case folder.
$Retval = Sharefolder $TestCaseFolder
WriteResultsToFile $logFile "Creating a shared folder" $Retval 0

#Set content location value.
$Retval = Set-ASProperty -PackageId $PkgID -PropertyName "Location" -PropertyValue $UNCPath
WriteResultsToFile $logFile "Set Content location with test case UNC path" $Retval True

<#Updating UserRequirement
$Type="UserRequirement"
$Value="False"
UpdateAppModelData $Type $UserRequirementXmlPath $PkgID $Value
#>

#Updating UserRequirement
$Type="UserRequirement1"
$UpdatedUserRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Requirements\UpdatedUserRequirement.xml"
UpdateAppModelData $Type $UpdatedUserRequirementXmlPath $PkgID

#Removing UserRequirement
$Type="UserRequirement"
$AppIndex=0
RemoveAppModelData $Type $PkgID $AppIndex

<#Updating DeviceRequirement
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
$AppIndex=16
RemoveAppModelData $Type $PkgID $AppIndex

#Updating Dependency
$Type="Dependency"
$AutoInstall=1
UpdateAppModelData $Type $DependencyXmlPath $PkgID $AutoInstall

#Updating Supercedence
$Type="Supercedence"
$Uninstall="true"
UpdateAppModelData $Type $SupersedenceXmlPath $PkgID $Uninstall

#Updating ReturnCodes
$Type="ReturnCodes"
$Name="test"
UpdateAppModelData $Type $ReturnCodesXmlPath $PkgID $Name

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
WriteResultsToFile $logFile "Validating AppModel properties of the $PackageName package in SCCM with Application Manager after re-publish in CSV File is:" $retval -1

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
    Write-host (Write-Header $TestName) "UWPPublish_ToSCCM_And_Validate Test Case Failed"
    $retval=-1
	Get-Process AdminStudioHost | Stop-Process
	exit 1
}
Else 
{
    Write-host (Write-Header $TestName) "UWPPublish_ToSCCM_And_Validate Test Case Passed"
    $retval=0
	#Deleting catalog
    DeleteCatalog $CatalogName
	Get-Process AdminStudioHost | Stop-Process
	exit 0
}




