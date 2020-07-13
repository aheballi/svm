. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

#start
$TestName='03WrappedEXEPublish_ToSCCM_And_Validate'

$ParentFolder = "C:\AS_Automation"
$TestCaseName="03WrappedEXEPublish_ToSCCM_And_Validate"
$PackageName = "Ad-AwareAE.exe"
$Dep1 ="prune.exe"
$Dep2 ="JetAudio.msi"
$Sup1="Stamper.exe"
$Sup2="Real player.msi"
$csvFileName="WrappedEXEPublish_ToSCCM_And_Validate.csv"
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

#$SQLScriptsFolder =$TestCaseFolder + '\SQLScripts'

$SCCM_ConnectionName= "SCCM_EXE"
#$PublishLoc= '\\'+$SCCMServerName+'\Publish'

$HostName = hostname
$UNCPath = "\\$HostName\$TestCaseName"

Write-Host (Write-Header $TestName) "Test Started"

If(Test-Path $logFile)
{
    Remove-Item $logFile
}

$strSourcePath="\\10.80.150.184\Automation_TestData\Publish\"+$TestCaseName
#$strSourcePath="C:\"+$TestCaseName

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

#Import the package
$PkgID=ImportSinglePackage $PackageLocation $CatalogName
WriteResultsToFile $logFile "Import $PackageName Package to catalog." ($PkgID -gt 0) $true

$wrapid= Wrappackage $PkgID $CatalogName $Null

if($wrapid -ge -1)
{

#Import the package
$depPkgID1=ImportSinglePackage $DepPkgLocation1 $CatalogName
WriteResultsToFile $logFile "Import Dependency Package $Dep1 " ($depPkgID1 -gt 0) $true

$depPkgID2=ImportSinglePackage $DepPkgLocation2 $CatalogName
WriteResultsToFile $logFile "Import Dependency Package $Dep2 " ($depPkgID2 -gt 0) $true

$SuperPkgID1=ImportSinglePackage $SuperPkgLocation1 $CatalogName
WriteResultsToFile $logFile "Import Supersedence Package $Sup1 " ($SuperPkgID1 -gt 0) $true

$SuperPkgID2=ImportSinglePackage $SuperPkgLocation2 $CatalogName
WriteResultsToFile $logFile "Import Supersedence Package $Sup2 " ($SuperPkgID2 -gt 0) $true

CreateDistributionConnection $SCCM_ConnectionName 'SCCM' $SCCMServername $SCCMSitecode $PublishLoc $CatalogName

$SuperAppId1= Get-ASApplicationID -PackageId $SuperPkgID1
WriteResultsToFile $logFile "Fetching Supersedence Applicaiton ID for $Sup1 is: $SuperAppId1" ($SuperAppID1 -gt 0) $true

$SuperAppId2= Get-ASApplicationID -PackageId $SuperPkgID2
WriteResultsToFile $logFile "Fetching Supersedence Applicaiton ID for $Sup2 is: $SuperAppId2" ($SuperAppID2 -gt 0) $true
#$Retval = DistributeApplication $SCCM_ConnectionName $SuperAppID1 $SCCMTargetGroup
#WriteResultsToFile $logFile "Publishing of supersedence $Sup1 application if no detection methods are added:" $Retval -1

#Adding Detection Methods for Superseded package
$Type="DetectionMethod"
$DetectionMethodXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\DetectionMethod1.xml"
AddAppModelData $Type $DetectionMethodXmlPath $SuperPkgID1

$Retval = DistributeApplication $SCCM_ConnectionName $SuperAppID1 $SCCMTargetGroup
WriteResultsToFile $logFile "Publishing of supersedence $Sup1 application:" $Retval 0

$Retval = DistributeApplication $SCCM_ConnectionName $SuperAppID2 $SCCMTargetGroup
WriteResultsToFile $logFile "Publishing of supersedence $Sup2 application:" $Retval 0

#Adding Detection Methods for Dependency package
$Type="DetectionMethod"
$DetectionMethodXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\DetectionMethod2.xml"
AddAppModelData $Type $DetectionMethodXmlPath $depPkgID1

#Adding DeviceRequirement
$Type="DeviceRequirement"
$DeviceRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\DeviceRequirement.xml"
AddAppModelData $Type $DeviceRequirementXmlPath $wrapid

#Adding UserRequirement
$Type="UserRequirement"
$UserRequirementXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\UserRequirement.xml"
AddAppModelData $Type $UserRequirementXmlPath $wrapid

#Adding DetectionMethod
$Type="DetectionMethod"
$DetectionMethodXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\DetectionMethod.xml"
AddAppModelData $Type $DetectionMethodXmlPath $wrapid

#Adding Dependency
$Type="Dependency"
$DependencyXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Dependency.xml"
AddAppModelData $Type $DependencyXmlPath $wrapid $depPkgID1

#Adding Supercedence
$Type="Supercedence"
$SupersedenceXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Supersedence.xml"
AddAppModelData $Type $SupersedenceXmlPath $wrapid $SuperPkgID1

#Adding ReturnCodes
$Type="ReturnCodes"
$ReturnCodesXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\ReturnCodes.xml"
AddAppModelData $Type $ReturnCodesXmlPath $wrapid

$AppId= Get-ASApplicationID -PackageId $wrapid
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

$SCCMID1= AS_GetSCCMAppID $CatalogName $wrapid
Add-Content -Path $logFile -Value "publish id: $SCCMID1"

$SessionID = Create_PSSession $SCCMServername $SCCMSitecode
Add-Content -Path $logFile -Value "session id is: $SessionID"

#validating properties of applications published to SCCM
$Retval=Process_SCCMPublish_CSV $csvFilePath $CatalogName $wrapid 'Published' $SessionID

$RetVal=ProcessCSVColumnValue $csvFilePath "PUBLISHSTATUS" "Fail"
WriteResultsToFile $logFile "Validating AppModel properties of the $PackageName package in SCCM with Application Manager after publish in CSV File is:" $retval -1

#Validating Content location in SCCM after first publish as in AM UI the content value will be blank
$GUId= ExecuteSQLQuery "SELECT CustomID FROM ASCMApplicationDeployment WHERE Group_=(select ParentGroupCode from cstblGroupPackages where PkgRowID_ = $wrapid)" $CatalogName
$Revision =ExecuteSQLQuery "select Revision from ASCMApplicationDeployment where Group_=(select ParentGroupCode from cstblGroupPackages where PkgRowID_ = $wrapid)" $CatalogName
$ASContentLoc= $PublishLoc + '\' + $GUId + '\' + $Revision + '\' + $wrapid + '\'
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
$Retval=Process_SCCMPublish_CSV $csvFilePath $CatalogName $wrapid 'Update Properties' $SessionID

$RetVal=ProcessCSVColumnValue $csvFilePath "REPUBLISHSTATUS" "Fail"
WriteResultsToFile $logFile "Updating AppModel properties of the $PackageName package in Application Manager using CSV File is:" $retval -1

#Share the test case folder.
$Retval = Sharefolder $TestCaseFolder
WriteResultsToFile $logFile "Creating a shared folder" $Retval 0

#Set content location value.
$Retval = Set-ASProperty -PackageId $wrapid -PropertyName "Location" -PropertyValue $UNCPath
WriteResultsToFile $logFile "Set Content location with test case UNC path" $Retval True

<#$Sup2SqlPath= $SQLScriptsFolder +'\Supersedence\Update'
AddSupersedence $Sup2SqlPath $wrapid $SuperPkgID2 $CatalogName#>

#Updating Dependency
$Type="Dependency"
$AutoInstall=1
UpdateAppModelData $Type $DependencyXmlPath $wrapid $AutoInstall

#Updating DeviceRequirement
$Type="DeviceRequirement"
$Value=300
$Operator="GreaterThan"
UpdateAppModelData $Type $DeviceRequirementXmlPath $wrapid $Value $Operator

#Updating Detectionmethod
$Type="DetectionMethod"
$DetectionType="Integer"
$IntegerValue=68
UpdateAppModelData $Type $DetectionMethodXmlPath $wrapid $DetectionType $IntegerValue

#Updating UserRequirement
$Type="UserRequirement"
$Val="False"
UpdateAppModelData $Type $UserRequirementXmlPath $wrapid $Val

#Updating ReturnCodes
$Type="ReturnCodes"
$Name="test"
UpdateAppModelData $Type $ReturnCodesXmlPath $wrapid $Name

#Adding Supersedence
$Type="Supercedence"
$SupersedenceXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Supersedence1.xml"
AddAppModelData $Type $SupersedenceXmlPath $wrapid $SuperPkgID2

#Adding Dependency
$Type="Dependency"
$DependencyXmlPath="$ParentFolder\$TestCaseName\XmlDocuments\Dependency1.xml"
AddAppModelData $Type $DependencyXmlPath $wrapid $depPkgID2

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

$SCCMID2= AS_GetSCCMAppID $CatalogName $wrapid
Add-Content -Path $logFile -Value "republish application ID :$SCCMID2"

#validating properties of applications republished to SCCM
$retval=Process_SCCMPublish_CSV $csvFilePath $CatalogName $wrapid 'Republished' $SessionID

$RetVal=ProcessCSVColumnValue $csvFilePath "REPUBLISHSTATUS" "Fail"
WriteResultsToFile $logFile "Validating AppModel properties of the $PackageName package in SCCM with Application Manager after republish in CSV File is:" $retval -1

#Validate updated 'Content Location'
$UNCPath = (Get-ASProperty -PackageId $wrapid -PropertyName "Location")+'\'
Add-Content -Path $logFile -Value "Content location of the package $PackageName in AM is :$UNCPath"

$Retval = SCCM_GetContentTabProperties $SCCMID2 "Content location" $SessionID
Add-Content -Path $logFile -Value "Content location of the package $PackageName in SCCM is :$Retval"

WriteResultsToFile $logFile "Validating Content Location property of the $PackageName package in SCCM with Application Manager after re-publish in CSV File is:" $retval $UNCPath

#Removing published applications from SCCM
$PkgList = @($wrapid,$SuperPkgID2,$SuperPkgID1,$depPkgID1,$depPkgID2)
RemoveSCCMApplication $PkgList $SessionID 

#removing ps session
Remove-PSSession -Session $SessionID

#Unsharing of TestCase folder
$Retval = UnShareFolder $TestCaseFolder
WriteResultsToFile $logFile "Unsharing of folder is :" $retval 0



If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile))
{
    Write-host (Write-Header $TestName) "WrappedEXEPublish_ToSCCM_And_Validate Test Case Failed"
    $retval=-1
	Get-Process AdminStudioHost | Stop-Process
	exit 1
}
Else 
{
    Write-host (Write-Header $TestName) "WrappedEXEPublish_ToSCCM_And_Validate Test Case Passed"
    $retval=0
	#Deleting catalog
    DeleteCatalog $CatalogName
	Get-Process AdminStudioHost | Stop-Process
	exit 0
}
}
else
{
    Get-Process AdminStudioHost | Stop-Process
	Write-host (Write-Header $TestName) "EXE Wrap Failed"
	exit 1
}

