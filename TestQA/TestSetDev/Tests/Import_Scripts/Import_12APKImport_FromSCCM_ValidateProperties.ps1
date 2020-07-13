 . C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

$ParentFolder = "C:\AS_Automation"
$TestCaseName="12APKImport_FromSCCM_ValidateProperties"
$csvFileName="APKImport_FromSCCM_ValidateProperties.csv"
$CatalogName= $TestCaseName
$SRFlag=0
$SCCM_ConnectionName="IMPORT_SCCM"
$TestCaseFolder=$ParentFolder+"\"+$TestCaseName
$logFile=$TestCaseFolder + "\"+$TestCaseName+".log"
$csvFilePath=$TestCaseFolder + "\"+ $csvFileName
$xmlpath = $TestCaseFolder + "\"+ "LinkedIn.xml"
$supersedes1 = $TestCaseFolder + "\"+ "Chrome.xml"
$supersedes2 = $TestCaseFolder + "\"+ "Chase.xml"
$supersedes3 = $TestCaseFolder + "\"+ "AdobeReader.xml"
$supersedes4 = $TestCaseFolder + "\"+ "AirDroid.xml"
$updatexmlpath = $TestCaseFolder + "\"+ "LinkedIn_Update.xml"
$TargetGroup = "Applications\Automation"

$strSourcePath="\\10.80.150.184\Automation_TestData\Import\"+$TestCaseName

Write-Host (Write-Header $TestCaseName) "Test Started"
$SCCMScopeid = "ScopeId_97DA6E8E-2069-445D-8FD4-F1F1A4B396A0"
$Retval= CopyTestDataLocally $strSourcePath $ParentFolder 0


 #$retval= Createlog($logFile)

$retval=CreateNewCatalog $CatalogName $SRFlag

if ($retval -eq 0)
{    
    WriteResultsToFile $logFile "Catalog created successfully $CatalogName is :" $retval 0 
}
else
{    
    WriteResultsToFile $logFile "Catalog created successfully $CatalogName is :" $retval 0
    Exit 1
}

#unselecting all rules of catalog

CreateDistributionConnection $SCCM_ConnectionName 'SCCM' $SCCMServerName $SCCMSitecode $PublishLoc $CatalogName

$supersedes1 = ASCreateApplicationFromSCCMXML $supersedes1 $SCCM_ConnectionName $TargetGroup
$supersedes2 = ASCreateApplicationFromSCCMXML $supersedes2 $SCCM_ConnectionName $TargetGroup
$supersedes3 = ASCreateApplicationFromSCCMXML $supersedes3 $SCCM_ConnectionName $TargetGroup
$supersedes4 = ASCreateApplicationFromSCCMXML $supersedes4 $SCCM_ConnectionName $TargetGroup
 

$parseSupersedes1PackageSCCIDs=$Supersedes1.Split("{;}")
$SupersedesAppId1=$parseSupersedes1PackageSCCIDs[0]
$SupersedesDeploymenttypeId1=$parseSupersedes1PackageSCCIDs[1]

$parseSupersedes2PackageSCCIDs=$Supersedes2.Split("{;}")
$SupersedesAppId2=$parseSupersedes2PackageSCCIDs[0]
$SupersedesDeploymenttypeId2=$parseSupersedes2PackageSCCIDs[1]

$parseSupersedes3PackageSCCIDs=$Supersedes3.Split("{;}")
$SupersedesAppId3=$parseSupersedes3PackageSCCIDs[0]
$SupersedesDeploymenttypeId3=$parseSupersedes3PackageSCCIDs[1]

$parseSupersedes4PackageSCCIDs=$Supersedes4.Split("{;}")
$SupersedesAppId4=$parseSupersedes4PackageSCCIDs[0]
$SupersedesDeploymenttypeId4=$parseSupersedes4PackageSCCIDs[1]


$ExpectedSCCMids1 = @($SupersedesAppId1,$SupersedesDeploymenttypeId1,$SupersedesAppId2,$SupersedesDeploymenttypeId2,$SupersedesAppId3,$SupersedesDeploymenttypeId3,$SupersedesAppId4,$SupersedesDeploymenttypeId4,$SCCMScopeid)
$Placeholder1 = @("<SupersedesAppId1>","<SupersedesDeploymenttypeId1>","<SupersedesAppId2>","<SupersedesDeploymenttypeId2>","<SupersedesAppId3>","<SupersedesDeploymenttypeId3>","<SupersedesAppId4>","<SupersedesDeploymenttypeId4>","<Scope_Id>")


#updating csv with new Appid and deployment ids
updatecsv $csvFilePath $Placeholder1 $ExpectedSCCMids1 'Import' 

#updating xml with new Appid and deployment ids
updatexml $xmlpath $Placeholder1 $ExpectedSCCMids1
$MainPackageSCCMIds = ASCreateApplicationFromSCCMXML $xmlpath $SCCM_ConnectionName $TargetGroup 
$parseMainPackageSCCIDs=$MainPackageSCCMIds.Split("{;}")
$SCCMAppId=$parseMainPackageSCCIDs[0]
$SCCMDeploymentId=$parseMainPackageSCCIDs[1]
$ModelName= "$SCCMScopeid"+"/"+$SCCMAppid
$SessionID = Create_PSSession $SCCMServerName $SCCMSitecode

$CID= SCCM_GetCID $ModelName $SessionID 

#importing of Package to Admin Studio from SCCM
$pkgid = ASImportAppFromDeploymentSystem $SCCM_ConnectionName $CID

$Retval=Process_SCCMImport_CSV $csvFilePath $CatalogName $pkgid 'Import' ''
$RetVal = ProcessCSVColumnValue $csvFilePath "SCCMIMPORTSTATUS" "Fail"

WriteResultsToFile $logFile "Validating AppModel properties of the $PackageName package in Admin Studio with Application Manager after importing from sccm in CSV File is:" $retval -1

#Reimporting code starts
$Placeholder2= @("<SCCMAppId>","<SCCMDeploymentId>","<SupersedesAppId1>","<SupersedesDeploymenttypeId1>","<SupersedesAppId3>","<SupersedesDeploymenttypeId3>","<SupersedesAppId4>","<SupersedesDeploymenttypeId4>","<Scope_Id>")

$ExpectedSCCMids2=@($SCCMAppId,$SCCMDeploymentId,$SupersedesAppId1,$SupersedesDeploymenttypeId1,$SupersedesAppId3,$SupersedesDeploymenttypeId3,$SupersedesAppId4,$SupersedesDeploymenttypeId4,$SCCMScopeid)


#updating csv with new Appid and deployment ids for Reimport
updatecsv $csvFilePath $Placeholder2 $ExpectedSCCMids2 'ReImport'

#updating xml with new Appid and deployment ids for Reimport
updatexml $updatexmlpath $Placeholder2 $ExpectedSCCMids2
$UpdateMainPackageSCCMIds = ASCreateApplicationFromSCCMXML $updatexmlpath $SCCM_ConnectionName $TargetGroup $SCCMAppId

$CID= SCCM_GetCID $ModelName $SessionID 
$updatedCID=$CID[1]
$pkgid2 = ASImportAppFromDeploymentSystem $SCCM_ConnectionName $updatedCID

$Retval=Process_SCCMImport_CSV $csvFilePath $CatalogName $pkgid2 'ReImport' ''
$RetVal = ProcessCSVColumnValue $csvFilePath "SCCMREIMPORTSTATUS" "Fail"
WriteResultsToFile $logFile "Validating AppModel properties of the $PackageName package in Admin Studio with Application Manager after Re-importing from sccm in CSV File is:" $retval -1

$s=Get-PSSession | Remove-PSSession


If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile))
{
    Get-Process AdminStudioHost | Stop-Process
	Write-host (Write-Header $TestCaseName) "APKImport_FromSCCM_ValidateProperties Test Case Failed"
    WriteResultsToFile $logFile "APKImport_FromSCCM_ValidateProperties Test Case Failed:" $retval -1
    $retval=-1
	exit 1
}
Else 
{
    DeleteCatalog $CatalogName
	Get-Process AdminStudioHost | Stop-Process
	Write-host (Write-Header $TestCaseName) "APKImport_FromSCCM_ValidateProperties Test Case Passed"
    WriteResultsToFile $logFile "APKImport_FromSCCM_ValidateProperties Test Case Passed:" $retval -1
    $retval=0
	exit 0
}

