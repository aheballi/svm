
. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

$TestName = "024MSI_APPV_BP_WTS_Rules"

Write-Host (Write-Header $TestName) "Test Started"

$ParentFolder = "C:\AS_Automation"
$arr=@("MSI_BP_Rules","SFT_BP_Rules")
$SRFlag=0
$CatalogName= "MSI_APPV_BP_WTS_Rules"
$TestRunStatus=0

$TestCaseName="MSI_APPV_BP_WTS_Rules"
$TestCaseFolder=$ParentFolder+"\"+$TestCaseName

if (Test-Path $TestCaseFolder){Remove-Item $TestCaseFolder -recurse -Force}
New-Item -Path $TestCaseFolder -ItemType Directory -Force | out-null

$CSVFolder=$TestCaseFolder+"\CSVs"
New-Item -Path $CSVFolder -ItemType Directory -Force | out-null

$logFile=$TestCaseFolder +"\"+$TestCaseName+".log"
$Retval=Createlog($logFile)

#Create a new catalog 
$Retval=CreateNewCatalog $CatalogName $SRFlag
if ($Retval -eq 0)
{
    Write-Host (Write-Header $TestName) "Create new catalog - $CatalogName is Successful" 
    WriteResultsToFile $logFile "Create new catalog - $CatalogName is:" $Retval 0
}
else
{
    Write-Host (Write-Header $TestName) "Create new catalog - $CatalogName is Failed"
    WriteResultsToFile $logFile "Create new catalog - $CatalogName is:" $Retval 0
    Exit 1
}

$Retval= SelectAllRules $CatalogName 0
WriteResultsToFile $logFile "Unselecting all rules for catalog $CatalogName is :" $Retval 0

For($i=0;$i -lt $arr.Count; $i++) 
{ 
    $BPRules=$arr[$i]
    $strSourcePath = "\\10.20.150.10\AdminStudio\AS_Automation\TestCases\MSI_APPV_BP_WTS_Rules\CSVs\"+$arr[$i]+".csv"
    $csvFileLocation=$CSVFolder+"\"+$arr[$i]+".csv"
     
    $Retval=CopyTestDataLocally $strSourcePath $CSVFolder 0
    WriteResultsToFile $logFile "Copy of $BPRules CSV test data is:" $Retval 0 
    
    $Retval=ConnectToCatalog $CatalogName 
           
    #Process Csv file 
    $Retval = ExecuteTestASConflicts_BP $catalogName $TestCaseFolder $csvFileLocation $logfile
   
    If(Select-String -Pattern "Fail" -InputObject $(Get-Content $csvFileLocation) )
    {       
        $TestRunStatus =-1
        WriteResultsToFile $logFile "$BPRules Test case " -1 0 
        Write-Host (Write-Header $TestName) "$BPRules Test case Failed"       
    } 
    else
    {
        WriteResultsToFile $logFile "$BPRules Test case " 0 0 
        Write-Host (Write-Header $TestName) "$BPRules Test case Passed" 
    } 
 }

$TestData=$TestCaseFolder+"\Testdata"
if (Test-Path $TestData){Remove-Item $TestData -recurse -Force -ErrorAction SilentlyContinue}

IF($TestRunStatus -eq 0)
{
 Write-Host (Write-Header $TestName) "MSI,AppV Bestpractice and Remote Desktop Service Rules validation Test cases -Passed `r`n" 
 WriteResultsToFile $logFile "MSI,AppV Bestpractice and Remote Desktop Service Rules validation Test cases" 0 0   
 }  
else
{
 Write-Host (Write-Header $TestName) "MSI,AppV Bestpractice and Remote Desktop Service Rules validation Test cases -Failed `r`n"
 WriteResultsToFile $logFile "MSI,AppV Bestpractice and Remote Desktop Service Rules validation Test cases" -1 0   
}

DeleteCatalog $CatalogName

