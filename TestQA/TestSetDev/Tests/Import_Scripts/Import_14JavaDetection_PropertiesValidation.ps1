. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
Start-Process AdminStudioHost
Start-Sleep 30

#start
$ParentFolder = "C:\AS_Automation"
$TestCaseName="14JavaDetection_PropertiesValidation"
$ProjectFolder=$ParentFolder+"\"+$TestCaseName	 
$pkg=@("JavaAI.exe","Inno2setup.exe","install.exe","Setup.exe","setup.exe","zdesktop_2_0_1_b10659_win32.msi","zdesktop_2_0_1_b10659_win32.exe","WiseScript_ZDesktop.exe","SampleProject.exe")
$csv=@("JavaDetection_AdvancedInstaller_Properties.csv","JavaDetection_InnoSetup_Properties.csv","JavaDetection_InstallAnywhere_Properties.csv","JavaDetection_InstallShield_Properties.csv","JavaDetection_LegacyInstaller_Properties.csv","JavaDetection_MSI_Properties.csv","JavaDetection_NullSoft_Properties.csv","JavaDetection_WiseScript_Properties.csv","JavaDetection_WixBurn_Properties.csv")
$arr=@("JavaDetection_AdvancedInstaller_Properties","JavaDetection_InnoSetup_Properties","JavaDetection_InstallAnywhere_Properties","JavaDetection_InstallShield_Properties","JavaDetection_LegacyInstaller_Properties","JavaDetection_MSI_Properties","JavaDetection_NullSoft_Properties","JavaDetection_WiseScript_Properties","JavaDetection_WixBurn_Properties")

$CatalogName=$TestCaseName
$SRFlag=0
Write-Host (Write-Header $TestCaseName) "Test Started"

$logFile=$ProjectFolder + "\"+$TestCaseName+".log"

Createlog($logFile)

#create a new catalog
$retval= CreateNewCatalog $CatalogName $SRFlag

IF ($retval -eq 0){
    WriteResultsToFile $logFile "Create new catalog." $retval 0
}
else
{
    WriteResultsToFile $logFile "Create new catalog." $retval 0
    Exit 1
}


for($i=0;$i -lt $arr.Count; $i++) 
{

    $TestScriptName=$arr[$i]
    $TestCaseFolder=$ParentFolder+"\"+$TestScriptName
    $logFile=$TestCaseFolder + "\"+$TestScriptName+".log"	    
    $strSourcePath="\\10.80.150.184\Automation_TestData\Import\"+$TestCaseName+"\"+$arr[$i]
    $csvFileLocation=$TestCaseFolder +"\"+ $csv[$i]
    $PackageLocation=$TestCaseFolder +"\"+ $pkg[$i]


#Copy test data
    $Retval=CopyTestDataLocally $strSourcePath $ParentFolder 0
    WriteResultsToFile $logFile "Copy test data from shared folder." $Retval 0

#connect to new catalog
$Retval=ConnectToCatalog($CatalogName)
WriteResultsToFile $logFile "Connection to catalog." $retval 0

#UnSelecting all rules in Select Tests to Execute Window
$retval= SelectAllRules $catalogName 0
WriteResultsToFile $logFile "Unselecting all rules." $retval 0


#Import the package
$PkgID=ImportSinglePackage $PackageLocation $CatalogName
WriteResultsToFile $logFile "Import Package to catalog" ($PkgID -gt 0) $true

$ActualJavaDetectionKeys=Get-ASPackageJavaSummary -PackageId $PkgID

$CSVcontent=Import-Csv $csvFileLocation

$CSVcontent | ForEach-Object{
    $Expected_Value=$_.Expected_Value
    $_.Actual_Value = $ActualJavaDetectionKeys[$_.Property]
    $Actual_Value=$_.Actual_Value
    $Property=$_.Property
    
                    If($Expected_Value -eq $Actual_Value) 
                        { 
                           
                           $_.Status="Passed"   
                           WriteResultsToFile $logFile "$Property Validation is" 0 0                                                      
                        }
                    Else
                        {
                           
                            $_.Status="Failed"
                            WriteResultsToFile $logFile "$Property Validation is" -1 0                           
                            $RetVal=-1
                        }
}
$CSVcontent |Export-Csv -Path $csvFileLocation -Force -NoTypeInformation

}

If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile))
{
    Get-Process AdminStudioHost | Stop-Process
	Write-host (Write-Header $TestCaseName) "JavaDetection_PropertiesValidation Test Case Failed"
    exit 1	
  
}
Else 
{
    DeleteCatalog $CatalogName
    Get-Process AdminStudioHost | Stop-Process
	Write-host (Write-Header $TestCaseName) "JavaDetection_PropertiesValidation Test Case Passed"
    exit 0	
 
}

