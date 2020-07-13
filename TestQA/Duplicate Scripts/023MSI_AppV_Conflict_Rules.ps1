. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

$TestName = "025MSI_AppV_Conflict_Rules"

Write-Host (Write-Header $TestName) "Test Started"

$ParentFolder = "C:\AS_Automation"
$arr=@("MSIconflicts","SFTconflicts")
$SRFlag=0
$CatalogName= "MSI_AppV_Conflict_Rules"
$TestRunStatus=0
$TestCaseName="MSI_AppV_Conflict_Rules"
$TestCaseFolder=$ParentFolder+"\"+$TestCaseName

if (Test-Path $TestCaseFolder){Remove-Item $TestCaseFolder -recurse -Force}
New-Item -Path $TestCaseFolder -ItemType Directory -Force | out-null

$CSVFolder=$TestCaseFolder+"\CSVs"
New-Item -Path $CSVFolder -ItemType Directory -Force | out-null

$logFile=$TestCaseFolder +"\"+$TestCaseName+".log"
$retval= Createlog($logFile)

#create a new catalog 
$retval=CreateNewCatalog $CatalogName $SRFlag
if ($retval -eq 0)
{
    Write-Host (Write-Header $TestName) "Create new catalog - $CatalogName is Successful" 
    WriteResultsToFile $logFile "Create new catalog." $retval 0
}
else
{
    Write-Host (Write-Header $TestName) "Create new catalog - $CatalogName is Failed"
    WriteResultsToFile $logFile "Create new catalog." $retval 0
    Exit 1
}

$Retval= SelectAllRules $CatalogName 0
WriteResultsToFile $logFile "Unselecting all rules for catalog $CatalogName is :" $Retval 0


For($i=0;$i -lt $arr.Count; $i++) 
{ 
    $ConflictRules=$arr[$i]
    $strSourcePath="\\10.20.150.10\AdminStudio\AS_Automation\TestCases\MSI_AppV_Conflict_Rules\CSV\"+$arr[$i]+".csv"  
    $csvFileLocation=$CSVFolder+"\"+$arr[$i]+".csv"
    
    $Retval=CopyTestDataLocally $strSourcePath $CSVFolder 0
    WriteResultsToFile $logFile "Copy of $ConflictRules CSV test data is-" $Retval 0

    $Retval=ConnectToCatalog $CatalogName

    #Process Csv file 
    $retval = ExecuteTestASConflicts $catalogName $TestCaseFolder $csvFileLocation $logfile

    If(Select-String -Pattern "Fail" -InputObject $(Get-Content $csvFileLocation) )
    {       
        $TestRunStatus = -1
        WriteResultsToFile $logFile "$ConflictRules Test case " -1 0
        Write-Host (Write-Header $TestName) "$ConflictRules Test case Failed"       
    } 
    else
    {
        WriteResultsToFile $logFile "$ConflictRules Test case " 0 0
        Write-Host (Write-Header $TestName) "$ConflictRules Test case Passed" 
    }  

}

$TestData=$TestCaseFolder+"\Testdata"
if (Test-Path $TestData){Remove-Item $TestData -recurse -Force -ErrorAction SilentlyContinue}

IF($TestRunStatus -eq 0)
{
     Write-Host (Write-Header $TestName) "MSI,AppV Conflict rules validation Test cases Passed `r`n"
     WriteResultsToFile $logFile "MSI,AppV Conflict rules validation Test cases" $TestRunStatus 0 
 }  
else
{
     Write-Host (Write-Header $TestName) "MSI,AppV Conflict rules  validation Test cases Failed `r`n"
     WriteResultsToFile $logFile "MSI,AppV Conflict rules validation Test cases" $TestRunStatus 0
}

DeleteCatalog $CatalogName