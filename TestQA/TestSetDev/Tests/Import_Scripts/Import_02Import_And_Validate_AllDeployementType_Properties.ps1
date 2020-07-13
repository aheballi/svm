. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

#start
$ParentFolder = "C:\AS_Automation"
if ((Test-Path -path $ParentFolder) -eq "True")
{
	Remove-Item -Path $ParentFolder -recurse -force -erroraction SilentlyContinue
}
New-Item -path $ParentFolder -ItemType Directory -Force |out-null

$arr=@("Import_And_Validate_EXE_Properties","Import_And_Validate_MSI_Properties","Import_And_Validate_APPX_Properties","Import_And_Validate_AppV4_Properties","Import_And_Validate_APPV5_Properties","Import_And_Validate_APK_Properties","Import_And_Validate_IPA_Properties","Import_And_Validate_ThinApp 4.X_Properties","Import_And_Validate_ThinApp 5.X_Properties","Import_And_Validate_XenApp_Properties","Import_And_Validate_HTML_Properties","Import_And_Validate_WebDeploy_Properties") 
$csv=@('G_Import_EXE.csv','G_Import_MSI.csv','G_Import_APPX.csv','G_Import_AppV4.csv','G_Import_APPV5.csv','G_Import_APK.csv','G_Import_IPA.csv','G_Import_SymantecXPF.csv','G_Import_ThinApp 4.X.csv','G_Import_ThinApp 5.X.csv','G_Import_XenApp.csv','G_Import_HTML.csv','G_Import_WebDeploy.csv') 
$pkg=@('thunderbird_64.exe','Firefox.msi','Facebook_1.4.0.9_x86.appx','Firefox.sft','Hex Editor Neo.appv','LinkedIn.apk','WhatsApp 2.11.8.ipa','Mozilla Firefox.EXE','Google Chrome.EXE','Firefox.profile','Google.htm','AppHostConfigCommand_Landesk.zip')   

$SRFlag=0
$TestCaseName= "02Import_And_Validate_AllDeployementType_Properties"
$CatalogName= "02Import_And_Validate_AllDeployementType_Properties"
$TestRunStatus=0

function Write-Header ()
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' ['+$TestCaseName+']'
    return $Header
}
Write-Host (Write-Header) "Test Started"

#create a new catalog 
$retval=CreateNewCatalog $CatalogName $SRFlag
if ($retval -eq 0)
{
    Write-Host (Write-Header) "Create new catalog - $CatalogName is Successful" 
}
else
{
    Write-Host (Write-Header) "Create new catalog - $CatalogName is Failed"
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
            Write-Host (Write-Header) $ProjectName "Test case Failed"
        }
        else
        {
            Write-Host (Write-Header) $ProjectName "Test case Passed"
        }
    }
    else
    {
        $TestRunStatus =-1
        Write-Host (Write-Header) $ProjectName "Test case failed to import package"
    }  
}


if($TestRunStatus -eq 0)
{        
	DeleteCatalog $CatalogName
    Get-Process AdminStudioHost | Stop-Process
	Write-Host (Write-Header) "Import_And_Validate_AllDeployementType_Properties Test Case Passed"
    exit 0	
}  
else
{   
    Get-Process AdminStudioHost | Stop-Process
	Write-Host (write-Header) "Import_And_Validate_AllDeployementType_Properties Test Case Failed"
	exit 1
}

