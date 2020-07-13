. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

$ParentFolder = "C:\AS_Automation"
$SRFlag=0
$TestCaseName = "08ValidateWrapDefaultTemOutputLoc"
$strSourcePath = "\\10.80.150.184\Automation_TestData\Import\"+$TestCaseName
$exePackage="vlc-2.2.4-win32.exe"
$exePackageName="vlc-2.2.4-win32"
$msiPackage="JetAudio.msi"
$msiPackageName= "JetAudio"
$CatalogName =$TestCaseName

$exeFile = "$exePackageName"+"."+"exe"
$ExpectedExeFilesAfterWrap = @("Deploy-Application.exe","Deploy-Application.exe.config","Deploy-Application.ps1","AppDeployToolkitBanner.png","AppDeployToolkitConfig.xml","AppDeployToolkitExtensions.ps1","AppDeployToolkitHelp.ps1","AppDeployToolkitLogo.ico","AppDeployToolkitMain.cs","AppDeployToolkitMain.ps1",$exeFile)

$msiFile= "$msiPackageName"+"."+"msi"
$cabFile= "$msiPackageName"+"_"+"SoftwareId"+"."+"cab"
$mstFile= "$msiPackageName"+"_"+"SoftwareId"+"."+"mst"

$ExpectedMsiFilesAfterWrap= @("Deploy-Application.exe","Deploy-Application.exe.config","Deploy-Application.ps1","AppDeployToolkitBanner.png","AppDeployToolkitConfig.xml","AppDeployToolkitExtensions.ps1","AppDeployToolkitHelp.ps1","AppDeployToolkitLogo.ico","AppDeployToolkitMain.cs","AppDeployToolkitMain.ps1",,$cabFile,$mstFile,$msiFile)


$GetdefaultTemplocations=  $AdminStudioSharedLocation+'PowerShellTemplate'

$GetdefaultOutlocations=  $AdminStudioSharedLocation+'WrappedPackages'


$TestCaseFolder=$ParentFolder+"\"+$TestCaseName
$logFile=$TestCaseFolder +"\"+$TestCaseName+".log"
$CustomTemplateFolder = $TestCaseFolder +"\PowerShellTemplate"
$CustomOutputFolder = $TestCaseFolder +"\"+"Outputfiles"
Write-Host (Write-Header $TestCaseName) "Test Started"
#Copy test data
$Retval= CopyTestDataLocally $strSourcePath $ParentFolder 0
$exePackageLocation=$TestCaseFolder +"\"+"ExeTestData" +"\"+$exePackage
$msiPackageLocation=$TestCaseFolder +"\"+"MsiTestData" +"\"+$msiPackage 
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

$RetVal= SelectAllRules $catalogName 0
WriteResultsToFile $logFile "Unselecting all rules in the catalog $CatalogName" $Retval 0

$exePkgID=ImportSinglePackage $exePackageLocation $CatalogName
WriteResultsToFile $logFile "Import $exePackage Package to catalog." ($exePkgID -gt 0) $true

$msiPkgID=ImportSinglePackage $msiPackageLocation $CatalogName
WriteResultsToFile $logFile "Import $msiPackage Package to catalog." ($msiPkgID -gt 0) $true

$exewrapid= Wrappackage $exePkgID $CatalogName $Null
 

if($exewrapid -ne -1)
{
    WriteResultsToFile $logFile "Wraping $exePackage is successful" 0 0
	$strexePkgQuery ="select OriginalPackageLocation from cstblpackage where RowID=$exewrapid"
    $WrapFolderPath = ExecuteSQLQuery $strexePkgQuery $CatalogName
    $RetVal=Validate_wrapOutputFiles $WrapFolderPath $ExpectedExeFilesAfterWrap
    if($RetVal -eq 0)
        {
            WriteResultsToFile $logFile "Validation of $exePackage wrap output files" 0 0            
        }
        else
        {
            WriteResultsToFile $logFile "Validation of $exePackage wrap output files" -1 0             
        }

$exebundledpackage=Get-ASBundledPackages -PackageId $exewrapid

$actualexebundledpackage=$exebundledpackage -replace "\s",""

$expectedexebundledpackage="Bundled Package : 1
Package      : vlc-2.2.4-win32
File Name    : vlc-2.2.4-win32.exe
Product Code :
Version      : 0.0.0.0"

$expectedexebundledpackage = $expectedexebundledpackage -replace "\s",""

    If($expectedexebundledpackage -eq $actualexebundledpackage)
    {
        WriteResultsToFile $logFile "Validation of Bundled Packages" 0 0
    }
    else
    {
        WriteResultsToFile $logFile "Validation of Bundled Packages" -1 0
    }
}
else
{
    WriteResultsToFile $logFile "Wraping $exePackage is failed" -1 0
}

If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile))
{    
    Write-Host (Write-Header $TestCaseName) "Validation of $exePackage wrap output files is failed"	
}
else
{    
    Write-Host (Write-Header $TestCaseName) "Validation of $exePackage wrap output files is Passed"	
}


$msiwrapid= Wrappackage $msiPkgID $CatalogName $Null

if($msiwrapid -ne -1)
{
	WriteResultsToFile $logFile "Wraping $msiPackage is successful"	
	$strmsiPkgQuery ="select OriginalPackageLocation from cstblpackage where RowID=$msiwrapid"
    $WrapFolderPath = ExecuteSQLQuery $strmsiPkgQuery $CatalogName
    $RetVal=Validate_wrapOutputFiles $WrapFolderPath $ExpectedMsiFilesAfterWrap

    if($RetVal -eq 0)
    {
        WriteResultsToFile $logFile "Validation of $msiPackage wrap output files" 0 0        
    }
    else
    {
        WriteResultsToFile $logFile "Validation of $msiPackage wrap output files" -1 0        
    }
$msibundledpackage=Get-ASBundledPackages -PackageId $msiwrapid
$actualmsibundledpackage=$msibundledpackage -replace "\s",""

$expectedmsibundledpackage="Bundled Package : 1
Package      : JetAudio
File Name    : JetAudio.msi
Product Code : {13CAB301-E295-4855-97F8-E0CAAFDD4926}
Version      : 10.50"


$expectedmsibundledpackage = $expectedmsibundledpackage -replace "\s",""
If($expectedmsibundledpackage -eq $actualmsibundledpackage)
{
WriteResultsToFile $logFile "Validation of Bundled Packages" 0 0
}
else
{
WriteResultsToFile $logFile "Validation of Bundled Packages" -1 0
}
}
else
{
WriteResultsToFile $logFile "Wraping $msiPackage is failed" -1 0	
}

If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile))
{    
    Get-Process AdminStudioHost | Stop-Process
	Write-Host (Write-Header $TestCaseName) "ValidateWrapDefaultTemOutputLoc Test Case Failed"
    exit 1	
}
else
{    
    DeleteCatalog $CatalogName
    Get-Process AdminStudioHost | Stop-Process
	Write-Host (Write-Header $TestCaseName) "ValidateWrapDefaultTemOutputLoc Test Case Passed"
    exit 0	
}


