. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

#start
$ParentFolder = "C:\AS_Automation"
if ((Test-Path -path $ParentFolder) -eq "True")
{
	Remove-Item -Path $ParentFolder -recurse -force
}
New-Item -path $ParentFolder -ItemType Directory -Force |out-null
$ProjectName='LSActivations'
$ProjectFolder=$ParentFolder+"\"+$ProjectName
$logFile=$ProjectFolder + "\"+$ProjectName+".log"
$retval= Createlog($logFile)
Write-Host (Write-Header $ProjectName) "Test Started"
$sCurrentLoc = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$sAsLocTPSConfig = $sAsLoc + "\TpsConfig.exe"
$slicenseType              = "LSProductID"
$global:Type = $null
# Copying the LSActivationList.csv file
$TestDataSourceActivation = $TestDataSource  + "\Activations\"
$ActivationCSV = "LSActivationList.csv"
$CsvFileSourcePath = $TestDataSourceActivation + $ActivationCSV
$Retval = CopyTestDataLocally $CsvFileSourcePath $ProjectFolder 0
WriteResultsToFile $logFile "Copied CSV from the shared folder." $Retval 0
$csv=@("ProcessEnt.csv","ProcessPro.csv","ProcessStn.csv","ProcessEnt32Bit.csv","ProcessPro32Bit.csv","ProcessStn32Bit.csv")
for($i=0;$i -lt $csv.Count; $i++) 
    {
        $CsvFile = $TestDataSourceActivation + $csv[$i]
        $Retval = CopyTestDataLocally $CsvFile $ProjectFolder 0
        WriteResultsToFile $logFile "Copied $csv[$i] from the shared folder." $Retval 0
    }
invoke-expression -command "cd $ProjectFolder"
$computers = “C:LSActivationList.csv”
$a = Import-Csv C:LSActivationList.csv | Measure-Object
$RowCount = $a.count
for ($i=0; $i -lt $RowCount; $i++)
{
        $output=(import-csv $computers)[$i]
        $activationCode = $output.ActivationId
        If ($activationCode -eq "License Server")
        {
            Set-itemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio\16.0" -name "LSProductID" -Value "AS2018-ENTSHPELS"
            Set-itemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio\16.0" -name "LicenseServer" -Value "@10.80.150.149"
            $retLicence = LicenseIdentification $sASLicType $global:Type
            WriteResultsToFile $logFile "The License Identification is successful." $retLicence 0
            $retFeatures = ValidateFeatures $ProcessCount $global:Type
            WriteResultsToFile $logFile "The validation of features is successful." $retFeatures 0
            DeleteCatalog  $global:CatalogName
            if (($retLicence -eq 0) -and ($retFeatures -eq 0))
               {
                    Add-Content -Path $logFile -Value "Test Case Passed successfully" -PassThru
                    Write-Host (write-Header) "Test Case Passed successfully"
               }
            else 
               {
                    Add-Content -Path $logFile -Value "Test for License Server Failed" -PassThru
                    Write-Host (write-Header) "Test for License Server Failed"
               }
         
         }

}
         