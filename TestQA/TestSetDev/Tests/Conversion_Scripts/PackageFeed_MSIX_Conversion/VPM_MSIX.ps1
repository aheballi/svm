﻿#Importing Powershell Library Functions 
. C:\TestSetDev\Tests\VPM_MSIX_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

#Variable Declaration
$TestName = "VPM_MSIX_Conversion"
Write-Host (Write-Header $TestName) "TestCase Execution Started..."

$ParentFolder = "C:\AS_Automation"
$TestCaseName="VPM_MSIX_Conversion"
$CatalogName="VPM_MSIX_Conversion_2907"
$TestRunStatus=0
$SRFlag=0
$xmlFileName= "aac.xml"
$DownloadFolderName= "DownloadedPackages"


#Creating Testcase folder inside Parent Folder
 Write-Host (Write-Header $TestName) "Creating TestCase Folder..."

 $TestCaseFolder= $ParentFolder+"\"+$TestCaseName
 
 #Handling the exception thrown by Remove-Item cmdlt "Unable to find the part of path" using the literal path
 $LiteralPath= "\\?\" + $TestCaseFolder 
 If(Test-Path $TestCaseFolder){Remove-Item $LiteralPath -recurse -Force}
 New-Item -Path $TestCaseFolder -ItemType Directory -Force | out-null

#Copying TestData
$SourcePath = "C:\VPM_MSIX_Conversion"
$Retval=CopyTestDataLocally $SourcePath $ParentFolder 0

#Creating Log file
$LogFile=$TestCaseFolder +"\"+$TestCaseName+".log"
WriteResultsToFile $LogFile "Copying TestData is - " $Retval 0
$ResultLog=$TestCaseFolder +"\"+"ResultLog.log"
#Creating New Catalog 
#$Retval=CreateNewCatalog $CatalogName $SRFlag

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

$DownloadPath= $TestCaseFolder+"\"+ $DownloadFolderName
 
#Calling PackageFeedConversion Function
PackageFeedConversion $CatalogName $DownloadPath $LogFile $ResultLog
if(Select-String -Pattern "Failed" -InputObject $(Get-Content $ResultLog))
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






