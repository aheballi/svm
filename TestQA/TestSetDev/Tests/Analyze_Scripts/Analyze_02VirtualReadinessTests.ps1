. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

Start-Process AdminStudioHost
Start-Sleep 30

$TestName = "006VirtualReadinessTests"

Write-Host (Write-Header $TestName) "Test Started"

$ParentFolder = "C:\AS_Automation"
$TestCaseName="VirtualReadiness"
$TestCaseFolder=$ParentFolder+"\"+$TestCaseName

if (Test-Path $TestCaseFolder) 
{ 
    Remove-Item $TestCaseFolder -recurse -Force
}
New-Item -Path $TestCaseFolder -ItemType Directory -Force | out-null

#Creating log file for the test script
$logFile= $TestCaseFolder +"\"+$TestCaseName+".log" 
$Supress = Createlog($logFile)

$csvFileLocation=$TestCaseFolder + "\VirtualReadinessTests.csv"
$strSourcePath= "\\10.80.150.184\Automation_TestData\Analyze\VirtualReadiness\VirtualReadinessTests.csv"

#Copying input.csv file
$Retval=CopyTestDataLocally $strSourcePath $TestCaseFolder 1

If ($Retval -ne 0){
    $Result= $strSourcePath +"    failed to copy  "
    WriteResultsToFile $logFile $Result $Retval 0
    return
}
WriteResultsToFile $logFile "Copy input csv test data from shared folder." $retval 0
 
#Running virtualization readiness test for the packages present in input.csv
$retval = VirtualReadiness $csvFileLocation $TestCaseFolder $logFile

#write-host (Write-Header $TestName) 
#Get-Content -Path $logfile 



# Cheking the test script run status
If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile) )
{
    Write-host (Write-Header $TestName) "Virtualization Readiness Test case failed. CSV file Path is:"$csvFileLocation
	Get-Process AdminStudioHost | Stop-Process
	exit 1
}
Else 
{
    Write-host (Write-Header $TestName) "Virtualization Readiness Test case passed. CSV file Path is:"$csvFileLocation
	Get-Process AdminStudioHost | Stop-Process
	Remove-Item $TestCaseFolder"\*.msi" -Force -ErrorAction SilentlyContinue
	exit 0
}




