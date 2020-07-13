
. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

#start
$ParentFolder = "C:\AS_Automation"

$arr=@("Import_And_Validate_WrappedMSI_Properties","Import_And_Validate_WrappedEXE_Properties") 
$csv=@("Import_And_Validate_WrappedMSI_Properties.csv","Import_And_Validate_WrappedEXE_Properties.csv") 
$pkg=@('Deploy-Application.ps1','Deploy-Application.ps1')   

$SRFlag=0
$CatalogName= "Import_And_Validate_Wrapped_EXE_MSI_Types"
$TestCaseName = "Import_And_Validate_Wrapped_EXE_MSI_Types"
$TestRunStatus=0

Write-Host (Write-Header $TestCaseName ) "Test Started"

#create a new catalog 
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

#UnSelecting all rules in Select Tests to Execute Window
$RetVal= SelectAllRules $catalogName 0

for($i=0;$i -lt $arr.Count; $i++) 
{ 
    $TestScriptName=$arr[$i]
    $TestCaseFolder=$ParentFolder+"\"+$TestScriptName
    $logFile=$TestCaseFolder + "\"+$TestScriptName+".log"	 

    
    $strSourcePath="\\10.20.150.10\AdminStudio\AS_Automation\TestCases\"+$arr[$i]
    $csvFileLocation=$TestCaseFolder +"\"+ $csv[$i]
    $PackageLocation=$TestCaseFolder +"\"+ $pkg[$i]

    $retval= Createlog($logFile)

    #Copy test data
    $Retval=CopyTestDataLocally $strSourcePath $ParentFolder 0
    WriteResultsToFile $logFile "Copy test data from shared folder." $Retval 0

    #connect to new catalog 
    $Retval=ConnectToCatalog $CatalogName
    WriteResultsToFile $logFile "Connection to catalog -  $CatalogName." $Retval 0
    
    #Importing of packages
    $PkgID=ImportSinglePackage $PackageLocation $CatalogName
    WriteResultsToFile $logFile "Import Package to catalog." ($PkgID -gt 0) $true
    If($PkgID -gt 0)
    {
        
        #Process Csv file 
        $retval = ProcessImportCSVFile $csvFileLocation $CatalogName $PkgID
        WriteResultsToFile $logFile "Validate Porperties of the package in CSV File." $retval 0

        if(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile) )
        {       
            $TestRunStatus =-1
            Write-Host (Write-Header $TestCaseName) $TestScriptName "Test case Failed"
        }
        else
        {
            Write-Host (Write-Header $TestCaseName) $TestScriptName "Test case Passed"
        }
    }
    else
    {
        $TestRunStatus =-1
        Write-Host (Write-Header $TestCaseName) $TestScriptName "Test case failed to import package"
    }  
}

DeleteCatalog $CatalogName

if($TestRunStatus -eq 0)
{
	Write-Host (Write-Header $TestCaseName) "Import Validate Test case Passed"   
}  
else
{
	Write-Host (Write-Header $TestCaseName) "Import Validate Test case Failed"
}