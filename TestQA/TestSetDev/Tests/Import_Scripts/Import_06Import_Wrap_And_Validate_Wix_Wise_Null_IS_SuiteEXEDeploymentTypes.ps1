. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

#start
$ParentFolder = "C:\AS_Automation"

<#if ((Test-Path -path $ParentFolder) -eq "True")
{
	Remove-Item -Path $ParentFolder -recurse -force
}
New-Item -path $ParentFolder -ItemType Directory -Force |out-null#>

If ( (Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit" )
    {
        $arr=@("Import_And_Validate_WixBurn_Properties_64","Import_And_Validate_WiseScript_Properties_64","Import_And_Validate_NullSoft_Properties_64","Import_And_Validate_InstallShield_Properties_64")
    }
    else
    {
        $arr=@("Import_And_Validate_WixBurn_Properties_32","Import_And_Validate_WiseScript_Properties_32","Import_And_Validate_NullSoft_Properties_32","Import_And_Validate_InstallShield_Properties_32")
    }

$csv=@("Import_And_Validate_WixBurn_Properties.csv","Import_And_Validate_WiseScript_Properties.csv","Import_And_Validate_NullSoft_Properties.csv","Import_And_Validate_InstallShield_Properties.csv")
$pkg=@('wix310.exe','Wise_SuiteExe_01.exe','nsis-3.0-setup.exe','Setup.exe')   
 
$TestCaseName="06Import_Wrap_And_Validate_Wix_Wise_Null_IS_SuiteEXEDeploymentTypes"
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

for($i=0;$i -lt $arr.Count; $i++) 
{ 
    $ProjectName=$arr[$i]
    $ProjectFolder=$ParentFolder+"\"+$ProjectName
    $logFile=$ProjectFolder + "\"+$ProjectName+".log"	 

    
    $strSourcePath="\\10.80.150.184\Automation_TestData\Import\"+$TestCaseName+"\"+$arr[$i]
    $csvFileLocation=$projectFolder +"\"+ $csv[$i]
    $PackageLocation=$projectFolder +"\"+ $pkg[$i]

    $retval= Createlog($logFile)

    #Copy test data
    $Retval=CopyTestDataLocally $strSourcePath $ParentFolder 0
    WriteResultsToFile $logFile "Copy test data from shared folder." $Retval 0

    #connect to new catalog 
    $Retval=ConnectToCatalog $CatalogName
    WriteResultsToFile $logFile "Connection to catalog -  $CatalogName." $Retval 0

    $TFlag=0
    $Retval=SelectAllRules $catalogName $TFlag
    
    #Importing of packages
    $PkgID=ImportSinglePackage $PackageLocation $CatalogName
    WriteResultsToFile $logFile "Import Package to catalog." ($PkgID -gt 0) $true
    $wrapid= Wrappackage $PkgID $CatalogName $Null

    If($wrapid -gt 0)
    {
        
        #Process Csv file 
        $retval = ProcessImportCSVFile $csvFileLocation $CatalogName $wrapid
        WriteResultsToFile $logFile "Validate Porperties of the package in CSV File." $retval 0

        if(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile) )
        {       
            $TestRunStatus =-1
            Write-Host (Write-Header $TestCaseName) $ProjectName "Test case Failed"
        }
        else
        {
            Write-Host (Write-Header $TestCaseName) $ProjectName "Test case Passed"
        }
    }
    else
    {
        $TestRunStatus =-1
        Write-Host (Write-Header $TestCaseName) $ProjectName "Test case failed to import package"
    }  

}

if($TestRunStatus -eq 0)
{
	DeleteCatalog $CatalogName
    Get-Process AdminStudioHost | Stop-Process
	Write-Host (Write-Header $TestCaseName) "Import_Wrap_And_Validate_Wix_Wise_Null_IS_SuiteEXEDeploymentTypes Test Case Passed"
    exit 0	
}  
else
{
    Get-Process AdminStudioHost | Stop-Process
	Write-Host (write-Header $TestCaseName) "Import_Wrap_And_Validate_Wix_Wise_Null_IS_SuiteEXEDeploymentTypes Test Case Failed"
	exit 1
}

