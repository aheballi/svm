. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

Start-Process AdminStudioHost
Start-Sleep 30


#start
$ParentFolder = "C:\AS_Automation"
$TestCaseName="10SFTPublish_ToSCCM_And_Validate"
$PackageName = "Firefox.sft"
$Dep1 ="UltraEdit.sft"
$Sup1="SafeSign.sft"
$Sup2="NestedSendToMenus.sft"
$csvFileName="SFTPublish_ToSCCM_And_Validate.csv"
$AppId=0

$TestCaseFolder=$ParentFolder+"\"+$TestCaseName
$logFile=$TestCaseFolder +"\"+$TestCaseName+".log"
$CatalogName=$TestCaseName
$SRFlag=0
$csvFilePath=$TestCaseFolder + "\"+ $csvFileName
$PackageLocation=$TestCaseFolder + "\Firefox_AppV4\"+$PackageName
$DepPkgLocation1=$TestCaseFolder+"\UltraEdit_v1\"+$Dep1
$SuperPkgLocation1=$TestCaseFolder+"\SafeSign_v1\"+$Sup1
$SuperPkgLocation2=$TestCaseFolder+"\NestedSendToMenus\"+$Sup2

$SQLScriptsFolder =$TestCaseFolder + '\SQLScripts'

$SCCM_ConnectionName= "SCCM_SFT"
$PublishLoc= '\\'+$SCCMServerName+'\Publish'

$HostName = hostname
$UNCPath = "\\$HostName\$TestCaseName" + "\Firefox_AppV4"

Write-Host (Write-Header $TestCaseName) "Test Started"

$strSourcePath="$TestDataSource\Publish\"+$TestCaseName
If(Test-Path $logFile)
{
    Remove-Item $logFile
}

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
    WriteResultsToFile $logFile "Create new catalog." $retval -1
    Exit 1
} 

#UnSelecting all rules in Select Tests to Execute Window
$retval= SelectAllRules $catalogName 0
WriteResultsToFile $logFile "Unselecting all rules." $retval 0

#connect to new catalog
$Retval = ConnectToCatalog($CatalogName)
WriteResultsToFile $logFile "Connecting to catalog $CatalogName" $retval 0

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

$AppId= Get-ASApplicationID -PackageId $PkgID
WriteResultsToFile $logFile "Fetching Applicaiton ID for the main package $PackageName : $AppId" ($AppId -gt 0) $true

$Retval = DistributeApplication $SCCM_ConnectionName $SuperAppID1 $SCCMTargetGroup
WriteResultsToFile $logFile "Publishing of supersedence $Sup1 application:" $Retval 0

$Retval = DistributeApplication $SCCM_ConnectionName $SuperAppID2 $SCCMTargetGroup
WriteResultsToFile $logFile "Publishing of supersedence $Sup2 application:" $Retval 0

#Adding data to Requirements, Dependencies, Supersedence tabs

<#$DRSqlPath= $SQLScriptsFolder +'\DeviceRequirements\Add'
AddDeviceRequirements $DRSqlPath $PkgID $CatalogName

$URSqlPath= $SQLScriptsFolder +'\UserRequirements\Add'
AddUserRequirements $URSqlPath $PkgID $Catalogname

$DepSqlPath= $SQLScriptsFolder +'\Dependency\Add'
AddDependencies $DepSqlPath $PkgID $depPkgID1 $CatalogName

$SupSqlPath= $SQLScriptsFolder +'\Supersedence\Add'
AddSupersedence $SupSqlPath $PkgId $SuperPkgID1 $CatalogName
#>

#Adding UserRequirement
$Type="UserRequirement"
$UserRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\UserRequirement.xml"
AddAppModelData $Type $UserRequirementXmlPath $PkgID

#Adding DeviceRequirement
$Type="DeviceRequirement"
$DeviceRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\DeviceRequirement.xml"
AddAppModelData $Type $DeviceRequirementXmlPath $PkgID

#Adding Supercedence
$Type="Supercedence"
$SupersedenceXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Supersedence.xml"
AddAppModelData $Type $SupersedenceXmlPath $PkgID $SuperPkgID1

#Adding Dependency
$Type="Dependency"
$DependencyXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Dependency.xml"
AddAppModelData $Type $DependencyXmlPath $PkgID $depPkgID1

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
#WriteResultsToFile $logFile "publish id: $SCCMID" 0 0
Add-Content -Path $logFile -Value "publish id: $SCCMID1"

$SessionID = Create_PSSession $SCCMServername $SCCMSitecode
#WriteResultsToFile $logFile "session id is: $SessionID" 0 0
Add-Content -Path $logFile -Value "session id is: $SessionID"

#validating properties of applications published to SCCM
$Retval=Process_SCCMPublish_CSV $csvFilePath $CatalogName $PkgID 'Published' $SessionID
 
$RetVal=ProcessCSVColumnValue $csvFilePath "PUBLISHSTATUS" "Fail"
WriteResultsToFile $logFile "Validating AppModel properties of the $PackageName package in SCCM with Application Manager after publish in CSV File is:" $retval -1

#Validating Content location in SCCM after first publish as in AM UI the content value will be blank
$GUId= ExecuteSQLQuery "SELECT CustomID FROM ASCMApplicationDeployment WHERE Group_=(select ParentGroupCode from cstblGroupPackages where PkgRowID_ = $PkgId)" $CatalogName
$Revision =ExecuteSQLQuery "select Revision from ASCMApplicationDeployment where Group_=(select ParentGroupCode from cstblGroupPackages where PkgRowID_ = $PkgId)" $CatalogName
$ASContentLoc= $PublishLoc + '\' + $GUId + '\' + $Revision + '\' + $PkgID
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

<#$Sup2SqlPath= $SQLScriptsFolder +'\Supersedence\Update'
UpdateSupersedence $Sup2SqlPath $PkgId $SuperPkgID1 $SuperPkgID2 $CatalogName

$Dep2SqlPath= $SQLScriptsFolder +'\Dependency\Update'
UpdateDependencies $Dep2SqlPath $PkgId $depPkgID1 $Null $CatalogName

$DR2SqlPath= $SQLScriptsFolder +'\DeviceRequirements\Update'
UpdateDeviceRequirements $DR2SqlPath $PkgID $CatalogName

$UR2SqlPath= $SQLScriptsFolder +'\UserRequirements\Update'
UpdateUserRequirements $UR2SqlPath $PkgID $CatalogName#>

#Share the test case folder.
$Retval = Sharefolder $TestCaseFolder
WriteResultsToFile $logFile "Creating a shared folder" $Retval 0

#Set content location value.
$Retval = Set-ASProperty -PackageId $PkgID -PropertyName "Location" -PropertyValue $UNCPath
WriteResultsToFile $logFile "Set Content location with test case UNC path" $Retval True

#Updating UserRequirement
$Type="UserRequirement"
$Val="False"
UpdateAppModelData $Type $UserRequirementXmlPath $PkgID $Val

#Updating DeviceRequirement
$Type="DeviceRequirement"
$Value=300
$Operator="GreaterThan"
UpdateAppModelData $Type $DeviceRequirementXmlPath $PkgID $Value $Operator

#Updating Dependency
$Type="Dependency"
$AutoInstall=1
UpdateAppModelData $Type $DependencyXmlPath $PkgID $AutoInstall

#Updating Supercedence
$Type="Supercedence"
$Uninstall="true"
UpdateAppModelData $Type $SupersedenceXmlPath $PkgID $Uninstall

#Updating ReturnCodes
$ReturnCodesXmlPath = "C:\AS_Automation\10SFTPublish_ToSCCM_And_Validate\XmlDocuments\ReturnCodes.xml"
$Type="ReturnCodes"
$Name="test"
UpdateAppModelData $Type $ReturnCodesXmlPath $PkgID $Name

#Updating Detectionmethod
#$Type="DetectionMethod"
#$DetectionType="Integer"
#$IntegerValue=68
#UpdateAppModelData $Type $DetectionMethodXmlPath $PkgID $DetectionType $IntegerValue

#Adding Supersedence
$Type="Supercedence"
$SupersedenceXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Supersedence1.xml"
AddAppModelData $Type $SupersedenceXmlPath $PkgID $SuperPkgID2

#Adding Dependency
#$Type="Dependency"
#$DependencyXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Dependency1.xml"
#AddAppModelData $Type $DependencyXmlPath $PkgID $depPkgID2

#Re-Publishing application to SCCM and 
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
$UNCPath = (Get-ASProperty -PackageId $PkgId -PropertyName "Location")
Add-Content -Path $logFile -Value "Content location of the package $PackageName in AM is :$UNCPath"

$Retval = SCCM_GetContentTabProperties $SCCMID2 "Content location" $SessionID

Add-Content -Path $logFile -Value "Content location of the package $PackageName in SCCM is :$Retval"

WriteResultsToFile $logFile "Validating Content Location property of the $PackageName package in SCCM with Application Manager after re-publish in CSV File is:" $Retval $UNCPath

#Deleting all applications published to SCCM
$PkgList = @($PkgID,$SuperPkgID2,$SuperPkgID1,$depPkgID1)
RemoveSccmApplication $PkgList $SessionID 

#removing ps session
Remove-PSSession -Session $SessionID

#Unsharing of TestCase folder
$retval = UnShareFolder $TestCaseFolder
WriteResultsToFile $logFile "Unsharing of folder is :" $retval 0



If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile))
{
    Write-host (Write-Header $TestCaseName) "SFTPublish_ToSCCM_And_Validate Test Case Failed"
    $retval=-1
	Get-Process AdminStudioHost | Stop-Process
	exit 1
}
Else 
{
    Write-host (Write-Header $TestCaseName) "SFTPublish_ToSCCM_And_Validate Test Case Passed"
    $retval=0
	#Deleting catalog
    DeleteCatalog $CatalogName
	Get-Process AdminStudioHost | Stop-Process
	exit 0
}

Get-Process AdminStudioHost | Stop-Process