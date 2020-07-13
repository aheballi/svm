. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

$TestCaseName= "03Import_And_Validate_SuiteExes_BundledPkgs_Properties"
#start
#CopyInnoSetupDll
$InnosetupDLL = "innounp.exe"
$InnosetupDLLSourcePath = "\\10.80.150.184\Automation_TestData\Import\"+$TestCaseName+"\SuiteEXEDLLS\InnoSetup\" + $InnosetupDLL
$InnosetupDLLFolder = $sAsLoc+"\Tools"
$InnosetupDLLFileLoc = $InnosetupDLLFolder+"\" + $InnosetupDLL


#CopyInstallAnywhereDll
$InstallAnywhereDLL = "7z920x86.dll"
$InstallAnywhereDLLSourcePath = "\\10.80.150.184\Automation_TestData\Import\"+$TestCaseName+"\SuiteEXEDLLS\InstallAnyWhere\" + $InstallAnywhereDLL
$InstallAnywhereDLLFileLoc = $sAsLoc+"\" + $InstallAnywhereDLL


$retval=CopyTestDataLocally $InnosetupDLLSourcePath $InnosetupDLLFolder 0
$retval=CopyTestDataLocally $InstallAnywhereDLLSourcePath $sAsLoc 0

$ParentFolder = "C:\AS_Automation"
 
$arr=@("Import_And_Validate_InstallAnywhereSuiteExe_Properties","Import_And_Validate_InnoSetupSuiteExe_Properties","Import_And_Validate_NullSoftSuiteExe_Properties","Import_And_Validate_WixBurnSuiteExe_Properties","Import_And_Validate_InstallShieldSuiteExe_Properties")
#$arr=@("Import_And_Validate_InstallShieldSuiteExe_Properties")
$csv=@("Import_And_Validate_InstallAnywhereSuiteExe_Properties.csv","Import_And_Validate_InnoSetupSuiteExe_Properties.csv","Import_And_Validate_NullSoftSuiteExe_Properties.csv","Import_And_Validate_WixBurnSuiteExe_Properties.csv","Import_And_Validate_InstallShieldSuiteExe_Properties.csv")
#$csv=@("Import_And_Validate_InstallShieldSuiteExe_Properties.csv")
$pkg=@("install.exe","TestSuite4setup.exe","Paint.NET.3.5.3.Install.exe","wix310.exe","InstallShield2017Professional.exe")
#$pkg=@("InstallShield2017Professional.exe")


$SRFlag=0
$CatalogName= $TestCaseName
$TestRunStatus=0


Write-Host (Write-Header $TestCaseName) "Test Started"

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
    $retval= SelectAllRules $catalogName 0
    #WriteResultsToFile $logFile "Unselecting all rules." $retval 0


for($i=0;$i -lt $arr.Count; $i++) 
{ 
    $TestScriptName=$arr[$i]
    $TestCaseFolder=$ParentFolder+"\"+$TestScriptName
    $logFile=$TestCaseFolder + "\"+$TestScriptName+".log"	 

    
    $strSourcePath="\\10.80.150.184\Automation_TestData\Import\"+$TestCaseName+"\"+$arr[$i]
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

#Delete Innoup Dll
remove-item -path $InnosetupDLLFileLoc -force

#Delete Install Anywhere Dll
remove-item -path $InstallAnywhereDLLFileLoc -force


if($TestRunStatus -eq 0)
{
	DeleteCatalog $CatalogName
    Get-Process AdminStudioHost | Stop-Process
	Write-Host (Write-Header $TestCaseName) "Import_And_Validate_SuiteExes_BundledPkgs_Properties Test Case Passed"
    exit 0	
}  
else
{
	Get-Process AdminStudioHost | Stop-Process
	Write-Host (write-Header $TestCaseName) "Import_And_Validate_SuiteExes_BundledPkgs_Properties Test Case Failed"
	exit 1
}

