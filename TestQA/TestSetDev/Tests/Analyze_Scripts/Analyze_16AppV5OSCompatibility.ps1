. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

$TestName = "007AppV5OSCompatibility"

Write-Host (Write-Header $TestName) "Test Started"

$ParentFolder = "C:\AS_Automation"
$arr=@("Windows 10(1607) 32-bit","Windows 10(1607) 64-bit","Windows 10(1703) 32-bit","Windows 10(1703) 64-bit","Windows 10(1709) 32-bit","Windows 10(1709) 64-bit","Windows 10(1803) 32-bit","Windows 10(1803) 64-bit","Windows 10(1809) 32-bit","Windows 10(1809) 64-bit","Win8 64-bit","Win8 32-bit","WinSer2012","Win7 32-bit","Win7 64-bit","Win7 32-bit","WinSer2008R2", "WinSer2016")
$SRFlag=0
$CatalogName= "AppV5OSCompatibility"
$TestRunStatus=0

$TestCaseName="AppV5OSCompatibility"
$TestCaseFolder=$ParentFolder+"\"+$TestCaseName

if (Test-Path $TestCaseFolder)
    {
        Remove-Item $TestCaseFolder -recurse -Force
    }
New-Item -Path $TestCaseFolder -ItemType Directory -Force | out-null

$CSVFolder=$TestCaseFolder+"\CSVs"
New-Item -Path $CSVFolder -ItemType Directory -Force | out-null

$logFile= $TestCaseFolder +"\"+$TestCaseName+".log"
$retval= Createlog($logFile)

#create a new catalog 
$retval= CreateNewCatalog $CatalogName $SRFlag
if ($retval -eq 0)
{
    Write-Host (Write-Header $TestName) "Create new catalog - $CatalogName is Successful"
    WriteResultsToFile $logFile "Catalog created successfully $CatalogName is :" $retval 0  
}
else
{
    Write-Host (Write-Header $TestName) "Create new catalog - $CatalogName is Failed"
    WriteResultsToFile $logFile "Catalog created successfully $CatalogName is :" $retval 0
    Exit 1
}

#UnSelecting all rules in Select Tests to Execute Window
$RetVal= SelectAllRules $catalogName 0
WriteResultsToFile $logFile "Unselecting all rules in the catalog $CatalogName" $Retval 0

#Processing CSV to run rules
For($i=0;$i -lt $arr.Count; $i++) 
{ 
    $OSRules=$arr[$i]
    $strSourcePath="\\10.80.150.184\Automation_TestData\Analyze\AppV5OSCompTests\"+$arr[$i]+".csv"
    $csvFileLocation=$CSVFolder+"\"+$arr[$i]+".csv"
     
    $Retval= CopyTestDataLocally $strSourcePath $CSVFolder 1
    WriteResultsToFile $logFile "Copy of $OSRules CSV test data is-" $Retval 0

    $Retval= ConnectToCatalog $CatalogName 
           
    #Process Csv file 
    $retval = ExecuteTestASPackage $catalogName $TestCaseFolder $csvFileLocation $logfile
   
    If(Select-String -Pattern "Fail" -InputObject $(Get-Content $csvFileLocation) )
    {       
        $TestRunStatus =-1
        WriteResultsToFile $logFile "$OSRules Operation System Compatibility Test case " -1 0
        Write-Host (Write-Header $TestName) "$OSRules Operation System Compatibility Test case Failed"       
    } 
    else
    {
        WriteResultsToFile $logFile "$OSRules Operation System Compatibility Test case " 0 0
        Write-Host (Write-Header $TestName) "$OSRules Operation System Compatibility Test case Passed" 
    }  

}


IF($TestRunStatus -eq 0)
{
 Write-Host (Write-Header $TestName) "AppV5 Operation System Compatibility validation Test cases Passed `r`n"
 DeleteCatalog $CatalogName
 Get-Process AdminStudioHost | Stop-Process 
 $TestData=$TestCaseFolder+"\Testdata"
if (Test-Path $TestData)
{
    Remove-Item $TestData -recurse -Force -ErrorAction SilentlyContinue
 }
 exit 0
 }  
else
{
 Write-Host (Write-Header $TestName) "AppV5 Operation System Compatibility validation Test cases Failed `r`n"
 Get-Process AdminStudioHost | Stop-Process
 exit 1
}


