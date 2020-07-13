. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

$ParentFolder = "C:\AS_Automation"

$SRFlag=0
$msiPackage="JetAudio.msi"
$msiPackageName= "JetAudio"
$TestCaseName="ChangewrapOutputfolderWIZ"
$strSourcePath = "\\10.20.150.10\AdminStudio\AS_Automation\TestCases\"+$TestCaseName
$CatalogName ="ChangewrapOutputfolderWIZ1"
$File="Deploy-Application.exe"

$msiFile= "$msiPackageName"+"."+"msi"
$cabFile= "$msiPackageName"+"_"+"SoftwareId"+"."+"cab"
$mstFile= "$msiPackageName"+"_"+"SoftwareId"+"."+"mst"

$ExpectedFilesAfterWrap=@("Deploy-Application.exe","Deploy-Application.exe.config","Deploy-Application.ps1","AppDeployToolkitBanner.png","AppDeployToolkitConfig.xml","AppDeployToolkitExtensions.ps1","AppDeployToolkitHelp.ps1","AppDeployToolkitLogo.ico","AppDeployToolkitMain.cs","AppDeployToolkitMain.ps1",$cabFile,$mstFile,$msiFile)


$TestCaseFolder=$ParentFolder+"\"+$TestCaseName
$logFile=$TestCaseFolder +"\"+$TestCaseName+".log"
$CustomTemplateFolder = $TestCaseFolder +"\PowerShellTemplate"
$CustomOutput = $TestCaseFolder +"\"+"Outputfiles"
$PackageLocation = $TestCaseFolder +"\"+"TestData" +"\"+"$msiPackage"

#Copy test data
$Retval= CopyTestDataLocally $strSourcePath $ParentFolder 0
    

Write-Host (Write-Header $TestCaseName) "Test Started"

$retval=CreateNewCatalog $CatalogName $SRFlag
IF ($retval -eq 0){
    WriteResultsToFile $logFile "Create new catalog." $retval 0
}
else
{
    WriteResultsToFile $logFile "Create new catalog." $retval 0
    Exit 1
}

$retval= Createlog($logFile)

$Retval= ConnectToCatalog($CatalogName)
$RetVal= SelectAllRules $catalogName 0

$defaultTemplateFilesloc=   $AdminStudioSharedLocation+'PowerShellTemplate'
$SetDefaulttemplatepath = "update ASOptions set PropertyValue='$CustomTemplateFolder' where PropertyName = 'TemplateLocation'"

$setTemplateLocation = ExecuteSQLQuery $SetDefaulttemplatepath $CatalogName
WriteResultsToFile $logFile "Default Template path changed to $CustomTemplateFolder"

$Retval= CopyTestDataLocally $defaultTemplateFilesloc $TestCaseFolder 0
WriteResultsToFile $logFile "Template folder Structure copied to $CustomTemplateFolder Successfull" $Retval 0
$RemoveFile=join-Path "$CustomTemplateFolder" "$File"
Remove-Item $RemoveFile
WriteResultsToFile $logFile "$File removed from $CustomTemplateFolder Location"
$SetOutputdirectoryPath = "update ASOptions set PropertyValue='$CustomOutput' where PropertyName = 'OutputLocation'"
$SetOutputLocation  = ExecuteSQLQuery $SetOutputdirectoryPath $CatalogName
WriteResultsToFile $logFile "Default Output location changed to $CustomOutput"
$PkgID=ImportSinglePackage $PackageLocation $CatalogName
WriteResultsToFile $logFile "Import $msiPackage Package to catalog." ($PkgID -gt 0) $true
$wrapid= Wrappackage $PkgID $CatalogName $Null
WriteResultsToFile $logFile "Wraping failed because Package doesnt have a valid name or structure"
if($wrapid -ne 0)
{
    $GetRemovedFile= Join-Path "$defaultTemplateFilesloc" "$File"
    $Retval= Copy-Item "$GetRemovedFile" "$CustomTemplateFolder"
    WriteResultsToFile $logFile "$File added to $CustomTemplateFolder Location"
    $wrapid= Wrappackage $PkgID $CatalogName $Null
    WriteResultsToFile $logFile "Wraping $msiPackage is successful"
}
else
{
    WriteResultsToFile $logFile"Template is correct"
}

$strPkgQuery ="select OriginalPackageLocation from cstblpackage where RowID=$wrapid"
$WrapFolderPath = ExecuteSQLQuery $strPkgQuery $CatalogName
$RetVal=Validate_wrapOutputFiles $WrapFolderPath $ExpectedFilesAfterWrap
 
if($RetVal -eq 0)
{
	WriteResultsToFile $logFile "Validation of $msiPackage wrap output files" 0 0 
	Write-Host (Write-Header $TestCaseName) "Validation of $msiPackageName wrap output files is passed"
	$msibundledpackage=Get-ASBundledPackages -PackageId $wrapid

$actualmsibundledpackage=$msibundledpackage -replace "\s",""

$expectedmsibundledpackage="Bundled Package : 1
Package      : JetAudio
File Name    : $CustomOutput\JetAudio_$PkgID\Files\$msiPackage
Product Code : {13CAB301-E295-4855-97F8-E0CAAFDD4926}
Version      : 10.50"

$expectedmsibundledpackage = $expectedmsibundledpackage -replace "\s",""

If($expectedmsibundledpackage -eq $actualmsibundledpackage)
{
    WriteResultsToFile $logFile "Validation of Bundled Packages : Passed"
}
else
{
    WriteResultsToFile $logFile "Validation of Bundled Packages : failed"
}	
}
else
{
	WriteResultsToFile $logFile "Validation of $msiPackage wrap output files" -1 0 
    Write-Host (Write-Header $TestCaseName) "Validation of $msiPackageName wrap output files is failed"	
}