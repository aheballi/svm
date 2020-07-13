. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

$ParentFolder = "C:\AS_Automation"
$SRFlag=0
$exePackage="vlc-2.2.4-win32.exe"
$exePackageName="vlc-2.2.4-win32"
$TestCaseName="09ValidateExewrap_CustomTemOutputloc"

$strSourcePath= "\\10.80.150.184\Automation_TestData\Import\"+$TestCaseName
$CatalogName =$TestCaseName
$File="Deploy-Application.exe"

$exeFile= "$exePackageName"+"."+"exe"
$ExpectedExeFilesAfterWrap= @("Deploy-Application.exe","Deploy-Application.exe.config","Deploy-Application.ps1","AppDeployToolkitBanner.png","AppDeployToolkitConfig.xml","AppDeployToolkitExtensions.ps1","AppDeployToolkitHelp.ps1","AppDeployToolkitLogo.ico","AppDeployToolkitMain.cs","AppDeployToolkitMain.ps1",$exeFile)

$TestCaseFolder=$ParentFolder+"\"+$TestCaseName
$logFile=$TestCaseFolder +"\"+$TestCaseName+".log"
$CustomTemplateFolder = $TestCaseFolder +"\PowerShellTemplate"
$CustomOutputFolder = $TestCaseFolder +"\"+"Outputfiles"
$PackageLocation = $TestCaseFolder +"\"+"TestData" +"\"+"$exePackage"
Write-Host (Write-Header $TestCaseName) "Test Started"

#Copy test data
$Retval= CopyTestDataLocally $strSourcePath $ParentFolder 0

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

$Retval=ConnectToCatalog($CatalogName)
$RetVal= SelectAllRules $CatalogName 0
WriteResultsToFile $logFile "Unselecting all rules in the catalog $CatalogName" $Retval 0
$defaultTemplateFilesloc=   $AdminStudioSharedLocation+'PowerShellTemplate'
$SetDefaulttemplatepath = "update ASOptions set PropertyValue='$CustomTemplateFolder' where PropertyName = 'TemplateLocation'"
$SetTemplateLocation = ExecuteSQLQuery $SetDefaulttemplatepath $CatalogName
WriteResultsToFile $logFile "Default Template path changed to $CustomTemplateFolder" $Retval 0
$Retval= CopyTestDataLocally $defaultTemplateFilesloc $TestCaseFolder 0

WriteResultsToFile $logFile "Template folder Structure copied to $CustomTemplateFolder Successfull" $Retval 0
$RemoveFile=join-Path "$CustomTemplateFolder" "$File"
Remove-Item $RemoveFile
WriteResultsToFile $logFile "$File removed from $CustomTemplateFolder Location"
$SetOutputdirectoryPath = "update ASOptions set PropertyValue='$CustomOutputFolder' where PropertyName = 'OutputLocation'"
$SetOutputLocation  = ExecuteSQLQuery $SetOutputdirectoryPath $CatalogName
WriteResultsToFile $logFile "Default Output location changed to $CustomOutputFolder"
$PkgID=ImportSinglePackage $PackageLocation $CatalogName
WriteResultsToFile $logFile "Import $PackageName Package to catalog." ($PkgID -gt 0) $true
$wrapid= Wrappackage $PkgID $CatalogName $CustomOutputFolder
WriteResultsToFile $logFile "Wraping is not successful because Package doesnt have a valid name or structure"
if($wrapid -ne 0)
{
    $GetRemovedFile= Join-Path "$defaultTemplateFilesloc" "$File"
    $Retval= Copy-Item "$GetRemovedFile" "$CustomTemplateFolder"        
    WriteResultsToFile $logFile "$File added to $CustomTemplateFolder Location"
    $wrapid= Wrappackage $PkgID $CatalogName $CustomOutputFolder
    WriteResultsToFile $logFile "Wraping $Package is successful"
}
else
{
    WriteResultsToFile $logFile "Template is correct"
}
$strPkgQuery ="select OriginalPackageLocation from cstblpackage where RowID=$wrapid"
$WrapFolderPath = ExecuteSQLQuery $strPkgQuery $CatalogName
$RetVal=Validate_wrapOutputFiles $WrapFolderPath $ExpectedExeFilesAfterWrap

if($RetVal -eq 0)
{
	WriteResultsToFile $logFile "Validation of $exePackage wrap output files" 0 0 	
	$exebundledpackage=Get-ASBundledPackages -PackageId $wrapid
	$actualexebundledpackage=$exebundledpackage -replace "\s",""
	$expectedexebundledpackage="Bundled Package : 1
	Package      : vlc-2.2.4-win32
	File Name    : vlc-2.2.4-win32.exe
	Product Code :
	Version      : 0.0.0.0"

	$expectedexebundledpackage = $expectedexebundledpackage -replace "\s",""

If($expectedexebundledpackage -eq $actualexebundledpackage)
{
	WriteResultsToFile $logFile "Validation of Bundled Packages :" 0 0
}
else
{
	WriteResultsToFile $logFile "Validation of Bundled Packages :" -1 0
}
}
else
{
WriteResultsToFile $logFile "Validation of $exePackage wrap output files" -1 0 
}

If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile))
{
    Get-Process AdminStudioHost | Stop-Process
    Write-Host (Write-Header $TestCaseName) "ValidateExewrap_CustomTemOutputloc Test Case Failed"
    exit 1	
}
else
{   
    DeleteCatalog $CatalogName
    Get-Process AdminStudioHost | Stop-Process
    Write-Host (Write-Header $TestCaseName) "ValidateExewrap_CustomTemOutputloc Test Case Passed"
    exit 0	
}


