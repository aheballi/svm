
. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

#start
$TestName='WrappedMSIPublish_ToSCCM_And_Validate'

$ParentFolder = "C:\AS_Automation"
$TestCaseName="WrappedMSIPublish_ToSCCM_And_Validate"
$PackageName = "Firefox.msi"
$Dep1 ="Orca.msi"
$Dep2 ="MsiVal2.msi"
$Sup1="CERAS.msi"
$Sup2="msxml3.msi"
$csvFileName="WrappedMSIPublish_ToSCCM_And_Validate.csv"
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

$HostName = hostname
$UNCPath = "\\$HostName\$TestCaseName"

Write-Host (Write-Header $TestName) "Test Started"

If(Test-Path $logFile)
{
    Remove-Item $logFile
}

$strSourcePath="\\10.20.150.10\AdminStudio\AS_Automation\TestCases\"+$TestCaseName

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
$RetVal= SelectAllRules $catalogName 0
WriteResultsToFile $logFile "Unselecting all rules in the catalog $CatalogName" $Retval 0

#connect to new catalog
$Retval=ConnectToCatalog($CatalogName)

#Import the package

$PkgID=ImportSinglePackage $PackageLocation $CatalogName
WriteResultsToFile $logFile "Import $PackageName Package to catalog." ($PkgID -gt 0) $true

$wrapid= Wrappackage $PkgID $CatalogName $Null

if($wrapid -ge -1)
{
        $depPkgID1=ImportSinglePackage $DepPkgLocation1 $CatalogName
        WriteResultsToFile $logFile "Import Dependency Package $Dep1 " ($depPkgID1 -gt 0) $true

        $SuperPkgID1=ImportSinglePackage $SuperPkgLocation1 $CatalogName
        WriteResultsToFile $logFile "Import Supersedence Package $Sup1 " ($SuperPkgID1 -gt 0) $true

        $SuperPkgID2=ImportSinglePackage $SuperPkgLocation2 $CatalogName
        WriteResultsToFile $logFile "Import Supersedence Package $Sup2 " ($SuperPkgID2 -gt 0) $true


        $SuperAppId1= Get-ASApplicationID -PackageId $SuperPkgID1
        WriteResultsToFile $logFile "Fetching Supersedence Applicaiton ID for $Sup1 is: $SuperAppId1" ($SuperAppID1 -gt 0) $true

        $SuperAppId2= Get-ASApplicationID -PackageId $SuperPkgID2
        WriteResultsToFile $logFile "Fetching Supersedence Applicaiton ID for $Sup2 is: $SuperAppId2" ($SuperAppID2 -gt 0) $true

        CreateDistributionConnection $SCCM_ConnectionName 'SCCM' $SCCMServername $SCCMSitecode $PublishLoc $CatalogName

        $Retval = DistributeApplication $SCCM_ConnectionName $SuperAppID1 $SCCMTargetGroup
        WriteResultsToFile $logFile "Publishing of supersedence $Sup1 application:" $Retval 0

        $Retval = DistributeApplication $SCCM_ConnectionName $SuperAppID2 $SCCMTargetGroup
        WriteResultsToFile $logFile "Publishing of supersedence $Sup2 application:" $Retval 0

        #Adding data to Requirements, Dependencies, Supersedence, ReturnCodes tabs
        $DRSqlPath= $SQLScriptsFolder +'\DeviceRequirements\Add'
        AddDeviceRequirements $DRSqlPath $wrapid $CatalogName

        $URSqlPath= $SQLScriptsFolder +'\UserRequirements\Add'
        AddUserRequirements $URSqlPath $wrapid $Catalogname

        $DMSqlPath= $SQLScriptsFolder +'\DetectionMethod\Add'
        AddDetectionMethod $DMSqlPath $wrapid $CatalogName

        $DepSqlPath= $SQLScriptsFolder +'\Dependency\Add'
        AddDependencies $DepSqlPath $wrapid $depPkgID1 $CatalogName

        $SupSqlPath= $SQLScriptsFolder +'\Supersedence\Add'
        AddSupersedence $SupSqlPath $wrapid $SuperPkgID1 $CatalogName

        $RCSqlPath= $SQLScriptsFolder +'\ReturnCodes\Add'
        AddReturnCodes $RCSqlPath $wrapid $CatalogName

        $AppId= Get-ASApplicationID -PackageId $wrapid
        WriteResultsToFile $logFile "Fetching Applicaiton ID for $PackageName : $AppID" ($AppID -gt 0) $true

        #Publishing application to SCCM
        $Retval = DistributeApplication $SCCM_ConnectionName $AppID $SCCMTargetGroup

        IF ($Retval -eq 0){
            WriteResultsToFile $logFile "Publishing of wrapped $PackageName application:" $Retval 0
        }
        else
        {
            WriteResultsToFile $logFile "Publishing of wrapped $PackageName application:" $Retval 0
            Exit 1
        }

        $SCCMID1= AS_GetSCCMAppID $CatalogName $wrapid
        Add-Content -Path $logFile -Value "publish id: $SCCMID2"

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
        
        # Process CSV for updating Appmodel values in Application Manager
        $Retval=Process_SCCMPublish_CSV $csvFilePath $CatalogName $wrapid 'Update Properties' $SessionID

        $RetVal=ProcessCSVColumnValue $csvFilePath "REPUBLISHSTATUS" "Fail"
        WriteResultsToFile $logFile "Updating AppModel properties of the $PackageName package in Application Manager using CSV File is:" $retval -1
        
        #Update Properties in Application Manager

        #Share the test case folder.
        $Retval = Sharefolder $TestCaseFolder
        WriteResultsToFile $logFile "Creating a shared folder" $Retval 0

        #Set content location value.
        $Retval = Set-ASProperty -PackageId $wrapid -PropertyName "Location" -PropertyValue $UNCPath
        WriteResultsToFile $logFile "Set Content location with test case UNC path" $Retval True

        $Sup2SqlPath= $SQLScriptsFolder +'\Supersedence\Update'
        UpdateSupersedence $Sup2SqlPath $wrapid $SuperPkgID1 $SuperPkgID2 $CatalogName

        $Dep2SqlPath= $SQLScriptsFolder +'\Dependency\Update'
        UpdateDependencies $Dep2SqlPath $wrapid $depPkgID1 $Null $CatalogName

        $DR2SqlPath= $SQLScriptsFolder +'\DeviceRequirements\Update'
        UpdateDeviceRequirements $DR2SqlPath $wrapid $CatalogName

        $DM2SqlPath= $SQLScriptsFolder +'\DetectionMethod\Update'
        UpdateDetectionMethod $DM2SqlPath $wrapid $CatalogName

        $UR2SqlPath= $SQLScriptsFolder +'\UserRequirements\Update'
        UpdateUserRequirements $UR2SqlPath $wrapid $CatalogName

        $RC2SqlPath= $SQLScriptsFolder +'\ReturnCodes\Update'
        UpdateReturnCodes $RC2SqlPath $wrapid $CatalogName

        #Re-Publishing application to SCCM
        $Retval = DistributeApplication $SCCM_ConnectionName $AppID $SCCMTargetGroup

        IF ($Retval -eq 0){
            WriteResultsToFile $logFile "Re-Publishing of wrapped $PackageName application:" $Retval 0
        }
        else
        {
            WriteResultsToFile $logFile "Re-Publishing of wrapped $PackageName application:" $Retval 0
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

        #Deleting all applications published to SCCM
        #$PkgList = @($wrapid,$SuperPkgID2,$SuperPkgID1,$depPkgID1)
        #RemoveSCCMApplication $PkgList $SessionID

        #removing ps session
        Remove-PSSession -Session $SessionID

        #Unsharing of TestCase folder
        $Retval = UnShareFolder $TestCaseFolder
        WriteResultsToFile $logFile "Unsharing of folder is :" $retval 0


        If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile))
        {
            Write-host (Write-Header $TestName) "Publish wrapped MSI to SCCM Test Case Failed"
            $retval=-1
        }
        Else 
        {
            Write-host (Write-Header $TestName) "Publish wrapped MSI to SCCM Test Case Passed"
            $retval=0
        }
}
else
{
    Write-host (Write-Header $TestName) "MSI Wrap Failed"
}

#Deleting catalog
#DeleteCatalog $CatalogName
#DeleteCatalog WrappedMSIPublish_ToSCCM_And_Validate