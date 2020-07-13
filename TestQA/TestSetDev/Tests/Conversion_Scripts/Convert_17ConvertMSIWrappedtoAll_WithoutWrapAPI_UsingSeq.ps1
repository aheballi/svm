﻿#Importing Powershell Library Functions 
. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

#Variable Declaration
$TestName = "ConvertMSIWrappedtoAll_WithoutWrapAPI_UsingSeq"
Write-Host (Write-Header $TestName) "TestCase Execution Started..."

$ParentFolder = "C:\AS_Automation"
$TestCaseName="ConvertMSIWrappedtoAll_WithoutWrapAPI_UsingSeq"
$CatalogName="ConvertMSIWrappedtoAll_WithoutWrapAPI_UsingSeq"
$TestRunStatus=0
$SRFlag=0
$AppVLauncherFile="C:\TestSetDev\TestData\AppVLaunch.ps1"

#Creating Testcase folder inside Parent Folder
Write-Host (Write-Header $TestName) "Creating TestCase Folder..."

$TestCaseFolder= $ParentFolder+"\"+$TestCaseName

#Handling the exception thrown by Remove-Item cmdlt "Unable to find the part of path" using the literal path
$LiteralPath= "\\?\" + $TestCaseFolder 
If(Test-Path $TestCaseFolder){Remove-Item $LiteralPath -recurse -Force}
New-Item -Path $TestCaseFolder -ItemType Directory -Force | out-null

$CSVFolder=$TestCaseFolder+"\CSVs"
$CSVPath=$CSVFolder+"\"+$TestCaseName+".csv"

#Copying TestData
$SourcePath = "\\10.80.150.184\Automation_TestData\AACConversions\"+$TestCaseName
$Retval=CopyTestDataLocally $SourcePath $ParentFolder 0

$TestData=$TestCaseFolder+"\TestData"

#Creating Log file
$LogFile=$TestCaseFolder +"\"+$TestCaseName+".log"
WriteResultsToFile $LogFile "Copying TestData is - " $Retval 0
#Creating New Catalog 
$Retval=CreateNewCatalog $CatalogName $SRFlag

If($Retval -eq 0)
  {
    Write-Host (Write-Header $TestName) "Creating new catalog - $CatalogName is Successful" 
    WriteResultsToFile $LogFile "Creating new catalog - $CatalogName is:" $Retval 0
  }
else
  {
    Write-Host (Write-Header $TestName) "Creating new catalog - $CatalogName is Failed"
    WriteResultsToFile $LogFile "Creating new catalog - $CatalogName is:" $Retval 0
    Exit 1
  }

#Connecting to the Catalog
$Retval=ConnectToCatalog $CatalogName
 
#Calling Conversion Function
$Retval = ConvertAndValidate $CSVPath $CatalogName $LogFile $AppVLauncherFile
if(Select-String -Pattern "Fail" -InputObject $(Get-Content $LogFile))
{
$TestRunStatus=-1
}

#Checking the final status of the test case                      
If($TestRunStatus -eq 0)
{
   Write-Host (Write-Header $TestName) "$TestCaseName Test case -Passed `r`n" 
   WriteResultsToFile $LogFile "$TestCaseName Test case" 0 0 
   DeleteCatalog $CatalogName
   Get-Process AdminStudioHost | Stop-Process
   exit 0
 }  
else
{
   Write-Host (Write-Header $TestName) "$TestCaseName Test case -Failed `r`n"
   WriteResultsToFile $LogFile "$TestCaseName Test case" -1 0  
   Get-Process AdminStudioHost | Stop-Process
   exit 1
 }
 
 