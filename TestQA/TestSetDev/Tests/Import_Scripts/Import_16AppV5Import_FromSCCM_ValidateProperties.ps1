. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

$ParentFolder = "C:\AS_Automation"
$TestCaseName="16AppV5Import_FromSCCM_ValidateProperties"
$csvFileName="AppV5Import_FromSCCM_Validate.csv"
$CatalogName= $TestCaseName
$SRFlag=0
$SCCM_ConnectionName="IMPORT_SCCM"
$TestCaseFolder=$ParentFolder+"\"+$TestCaseName
$logFile=$TestCaseFolder + "\"+$TestCaseName+".log"
$csvFilePath=$TestCaseFolder + "\"+ $csvFileName
$xmlpath = $TestCaseFolder + "\"+ "Firefox.xml"
$dependency1 = $TestCaseFolder + "\"+ "ImageJ.xml"
$dependency2 = $TestCaseFolder + "\"+ "NestedSendToMenus.xml"
$dependency3 = $TestCaseFolder + "\"+ "SafeSign.xml"
$supersedes1 = $TestCaseFolder + "\"+ "DB2RunTime.xml"
$supersedes2 = $TestCaseFolder + "\"+ "ForceReboot.xml"
$supersedes3 = $TestCaseFolder + "\"+ "HexEditor.xml"  
$updatexmlpath = $TestCaseFolder + "\"+ "Firefox_Update.xml"
$TargetGroup = "Applications\Automation"

$strSourcePath="\\10.80.150.184\Automation_TestData\Import\"+$TestCaseName
$SCCMScopeid = "ScopeId_97DA6E8E-2069-445D-8FD4-F1F1A4B396A0"


Write-Host (Write-Header $TestCaseName) "Test Started"
$Retval= CopyTestDataLocally $strSourcePath $ParentFolder 0


$retval= Createlog($logFile)
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
$dependency1 = ASCreateApplicationFromSCCMXML $dependency1 $SCCM_ConnectionName $TargetGroup
$dependency2 = ASCreateApplicationFromSCCMXML $dependency2 $SCCM_ConnectionName $TargetGroup
$dependency3 = ASCreateApplicationFromSCCMXML $dependency3 $SCCM_ConnectionName $TargetGroup   

$parseSupersedes1PackageSCCIDs=$Supersedes1.Split("{;}")
$SupersedesAppId1=$parseSupersedes1PackageSCCIDs[0]
$SupersedesDeploymenttypeId1=$parseSupersedes1PackageSCCIDs[1]

$parseSupersedes2PackageSCCIDs=$Supersedes2.Split("{;}")
$SupersedesAppId2=$parseSupersedes2PackageSCCIDs[0]
$SupersedesDeploymenttypeId2=$parseSupersedes2PackageSCCIDs[1]

$parseSupersedes3PackageSCCIDs=$Supersedes3.Split("{;}")
$SupersedesAppId3=$parseSupersedes3PackageSCCIDs[0]
$SupersedesDeploymenttypeId3=$parseSupersedes3PackageSCCIDs[1]

$parseDependency1PackageSCCIDs=$Dependency1.Split("{;}")
$DependencyAppID1=$parseDependency1PackageSCCIDs[0]
$DependencyDeploymenttypeID1=$parseDependency1PackageSCCIDs[1]

$parseDependency2PackageSCCIDs=$Dependency2.Split("{;}")
$DependencyAppID2=$parseDependency2PackageSCCIDs[0]
$DependencyDeploymenttypeID2= $parseDependency2PackageSCCIDs[1]

$parseDependency3PackageSCCIDs=$Dependency3.Split("{;}")
$DependencyAppID3=$parseDependency3PackageSCCIDs[0]
$DependencyDeploymenttypeID3= $parseDependency3PackageSCCIDs[1]

$ExpectedSCCMids1 = @($SupersedesAppId1,$SupersedesDeploymenttypeId1,$SupersedesAppId2,$SupersedesDeploymenttypeId2,$DependencyAppID1,$DependencyDeploymenttypeID1,$DependencyAppID2,$DependencyDeploymenttypeID2,$SCCMScopeid)
$Placeholder1 = @("<SupersedesAppId1>","<SupersedesDeploymenttypeId1>","<SupersedesAppId2>","<SupersedesDeploymenttypeId2>","<DependencyAppID1>","<DependencyDeploymenttypeID1>","<DependencyAppID2>","<DependencyDeploymenttypeID2>","<Scope_Id>")


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
$Placeholder2= @("<SCCMAppId>","<SCCMDeploymentId>","<SupersedesAppId1>","<SupersedesDeploymenttypeId1>","<SupersedesAppId3>","<SupersedesDeploymenttypeId3>","<DependencyAppID1>","<DependencyDeploymenttypeID1>","<DependencyAppID3>","<DependencyDeploymenttypeID3>","<Scope_Id>")

$ExpectedSCCMids2=@($SCCMAppId,$SCCMDeploymentId,$SupersedesAppId1,$SupersedesDeploymenttypeId1,$SupersedesAppId3,$SupersedesDeploymenttypeId3,$DependencyAppID1,$DependencyDeploymenttypeID1,$DependencyAppID3,$DependencyDeploymenttypeID3,$SCCMScopeid)


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
	Write-host (Write-Header $TestCaseName) "AppV5Import_FromSCCM_ValidateProperties Test Case Failed"
    WriteResultsToFile $logFile "AppV5Import_FromSCCM_ValidateProperties Test Case Failed:" $retval -1
    $retval=-1
	exit 1
}
Else 
{
    DeleteCatalog $CatalogName
	Get-Process AdminStudioHost | Stop-Process
	Write-host (Write-Header $TestCaseName) "AppV5Import_FromSCCM_ValidateProperties Test Case Passed"
    WriteResultsToFile $logFile "AppV5Import_FromSCCM_ValidateProperties Test Case Passed:" $retval -1
    $retval=0
	exit 0
}


