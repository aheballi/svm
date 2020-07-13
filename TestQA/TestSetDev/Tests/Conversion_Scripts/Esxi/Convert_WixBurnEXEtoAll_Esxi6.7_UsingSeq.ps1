﻿#Importing Powershell Library Functions 
. C:\TestSet\Tests\AS_Powershell_Library.ps1

#Variable Declaration
$TestName = "Convert_WixBurnEXEtoAll_Esxi6.7_UsingSeq"
Write-Host (Write-Header $TestName) "TestCase Execution Started..."

$ParentFolder = "C:\AS_Automation"
$TestCaseName="Convert_WixBurnEXEtoAll_Esxi6.7_UsingSeq"
$CatalogName="Convert_WixBurnEXEtoAll_Esxi6.7_UsingSeq"
$TestRunStatus=0
$SRFlag=0
$AppVLauncherFile="C:\TestSet\TestData\AppVLaunch.ps1"

#Creating Testcase folder inside Parent Folder
 Write-Host (Write-Header $TestName) "Creating TestCase Folder..."
 $TestCaseFolder=$ParentFolder+"\"+$TestCaseName
 if (Test-Path $TestCaseFolder){Remove-Item $TestCaseFolder -recurse -Force}
 New-Item -Path $TestCaseFolder -ItemType Directory -Force | out-null

$CSVFolder=$TestCaseFolder+"\CSVs"
$CSVPath=$CSVFolder+"\"+$TestCaseName+".csv"

#Copying TestData
$SourcePath = "\\10.20.150.10\AdminStudio\AS_Automation\TestCases\AACConversions\Convert_WixBurnEXEtoAll_Esxi6.7_UsingSeq"
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
 }  
else
{
   Write-Host (Write-Header $TestName) "$TestCaseName Test case -Failed `r`n"
   WriteResultsToFile $LogFile "$TestCaseName Test case" -1 0  
 }