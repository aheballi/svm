. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
#Start-Process AdminStudioHost
Start-Sleep 30

#start
$ParentFolder = "C:\AS_Automation"
$TestRunStatus=0

if ((Test-Path -path $ParentFolder) -eq "True")
{
	Remove-Item -Path $ParentFolder -recurse -force -erroraction SilentlyContinue
}
New-Item -path $ParentFolder -ItemType Directory -Force |out-null

$TestCaseName="21FolderImport"
$SRFlag=0
$CatalogName= $TestCaseName
$TestRunStatus=0
$logFile=$ParentFolder + "\"+$ProjectName+".log"


function Write-Header ()
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' ['+$TestCaseName+']'
    return $Header
}
Write-Host (Write-Header) "Test Started"

$retval=CreateNewCatalog $CatalogName $SRFlag

if ($retval -eq 0)
{
    Write-Host (Write-Header $TestCaseName) "Create new catalog - $CatalogName is Successful" 
}
else
{
    Write-Host (Write-Header $TestCaseName) "Create new catalog - $CatalogName is Failed"
    Exit 1
}
$strSourcePath = "\\10.80.150.184\Automation_TestData\Import\21FolderImport"

$CopyData = CopyTestDataLocally $strSourcePath $ParentFolder 0
$Packageslocation = $ParentFolder+'\'+$TestCaseName

$logFile=$Packageslocation + "\"+$TestCaseName+".log"
WriteResultsToFile $logFile "Copy test data from shared folder." $Retval 0

$Types = 'msi','apk','appx','profile','appv','msix','exe','dmg','pkg','zip','ipa','thinapp','html'
$GroupName = "Applications"

$names = '7-Zip 16.04','Acrobat2015Upd1500630060','DBFullSQLCommand','EIPA','Firefox','Globe7 Application','Welcome to XAMPP','JRE 6','NumberCruncher','Orca','Remedy','safarijavaunsafe','Viber - Free Phone Calls & Text','WhatsApp','Deploy Application','Firefox','7-Zip'

$pkgs = FolderImport $Packageslocation $Types $GroupName $CatalogName
WriteResultsToFile $logFile "Import Packages to catalog." + "True" + $pkgs
Write-Host (Write-Header) "Import of the packages is complete"

foreach ($names1 in $pkgs)
{
  Write-Host (Write-Header) "Validation of the packages started"
  if ($names1 -in $names)
  {
        
        WriteResultsToFile $logFile "Match between the package names and product names array is" 
        WriteResultsToFile $logFile $names1 + "is the product name from Admin studio catalog"
        WriteResultsToFile $logFile $names + "is the package name provided dynamically in the script"
        WriteResultsToFile $logFile "Both the value Match hence the package is imported successfully and validated"
    } 
  else
  { 
  $TestRunStatus =-1
   WriteResultsToFile $logFile "Failed to validate or import the package please check the catalog"
  }
}

Write-Host (Write-Header) "Validation of the packages are completed and success"

if($TestRunStatus -eq 0)
{        
	DeleteCatalog $CatalogName
 	Write-Host (Write-Header) "Import_And_Validate_FolderImport Test Case Passed"
    exit 0	
}  
else
{   
    Get-Process AdminStudioHost | Stop-Process
	Write-Host (write-Header) "Import_And_Validate_FolderImport Test Case Failed"
	exit 1
}
