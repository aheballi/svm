. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

Start-Process AdminStudioHost
Start-Sleep 30

$TestName = "020AppX_OS_RA_Rules"

Write-Host (Write-Header $TestName) "Test Started"

$ParentFolder = "C:\AS_Automation"
$arr=@("UWP-DesktopOSrules","UWP-MobileOSrules","UWP-MobileRArules","WinRT-DesktopOSrules","WinRT-MobileOSrules","WinRT-MobileRArules")
$SRFlag=0
$CatalogName= "AppX_OS_RA_Rules"
$TestRunStatus=0
$TestCaseName="AppX_OS_RA_Rules"
$TestCaseFolder=$ParentFolder+"\"+$TestCaseName
if (Test-Path $TestCaseFolder){Remove-Item $TestCaseFolder -recurse -Force}
New-Item -Path $TestCaseFolder -ItemType Directory -Force | out-null

$CSVFolder=$TestCaseFolder+"\CSVs"
New-Item -Path $CSVFolder -ItemType Directory -Force | out-null

$logFile=$TestCaseFolder +"\"+$TestCaseName+".log"
$Retval=Createlog($logFile)

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
    $AppxRules=$arr[$i]
    $strSourcePath="\\10.80.150.184\Automation_TestData\Analyze\AppX_OS_RA_Rules\CSVs\"+$arr[$i]+".csv"
    $csvFileLocation=$CSVFolder+"\"+$arr[$i]+".csv"
     
    $Retval=CopyTestDataLocally $strSourcePath $CSVFolder 0
    WriteResultsToFile $logFile "Copy of $AppxRules CSV test data is-" $Retval 0

    $Retval=ConnectToCatalog $CatalogName 
           
    #Process Csv file 
    $retval = ExecuteTestASPackage $catalogName $TestCaseFolder $csvFileLocation $logfile

 If(Select-String -Pattern "Fail" -InputObject $(Get-Content $csvFileLocation) )
    {       
        $TestRunStatus =-1
        WriteResultsToFile $logFile "$AppxRules Test case " -1 0
        Write-Host (Write-Header $TestName) "$AppxRules Test case Failed"       
    } 
    else
    {
        WriteResultsToFile $logFile "$AppxRules Test case " 0 0
        Write-Host (Write-Header $TestName) "$AppxRules Test case Passed" 
    }     
}



IF($TestRunStatus -eq 0)
{
 DeleteCatalog $CatalogName
 Write-Host (Write-Header $TestName) "AppX Operation System Compatibility, Risk Assesments rules validation Test cases Passed `r`n"  
 Get-Process AdminStudioHost | Stop-Process
 $TestData=$TestCaseFolder+"\Testdata"
 if (Test-Path $TestData){Remove-Item $TestData -recurse -Force -ErrorAction SilentlyContinue}
 exit 0
  
 }  
else
{
 Write-Host (Write-Header $TestName) "AppX Operation System Compatibility, Risk Assesments rules validation Test cases Failed `r`n"
 Get-Process AdminStudioHost | Stop-Process
 exit 1
}




