. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
#start
Start-Process AdminStudioHost.exe 
$ParentFolder = "C:\AS_Automation"
if ((Test-Path -path $ParentFolder) -eq "True")
    {
	    Remove-Item -Path $ParentFolder -recurse -force
    }
New-Item -path $ParentFolder -ItemType Directory -Force |out-null
$ProjectName='SerialKey_Activations'
$ProjectFolder=$ParentFolder+"\"+$ProjectName
$logFile=$ProjectFolder + "\"+$ProjectName+".log"
$retval= Createlog($logFile)
Write-Host (Write-Header $ProjectName )  "Test Started"
$sCurrentLoc = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$sAsLocTPSConfig = $sAsLoc + "\TpsConfig.exe"
$slicenseType              = "LSProductID"
$global:Type = $null
# Copying the ActivationList.csv file
$ActivationCSV = "ActivationList.csv"
$TestDataSourceActivation = $TestDataSource  + "\Activations\"
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
$computers = “C:ActivationList.csv”
$a = Import-Csv C:ActivationList.csv | Measure-Object
$RowCount = $a.count
    for ($i=0; $i -lt $RowCount; $i++)
        {
            $output=(import-csv $computers)[$i]
            $activationCode = $output.ActivationId
            $sActivationExe = $sAsLocTPSConfig
            Write-Host "Testing Serial Number:" $activationCode -foregroundcolor white
            Add-Content -Path $logFile -Value "Started Activating Serial number" -PassThru
            [int] $FoundError = 0
            $Return = Activate($activationCode)
            WriteResultsToFile $logFile "Activation is successful." $Return 0
            if ($Return -eq 0)
                {
                    $ErrorCount = LicenseFeaturetest $output.Features 0
                    if ($ErrorCount -ne 0)
                        {
                            Write-Host " Feature Checkout Failed" $ErrorCount -foregroundcolor red
                            $FoundError ++
                        }
                    $ErrorCount = LicenseFeaturetest $output.NoFeatures -1
                    if ($ErrorCount -ne 0)
                        {
                            Write-Host " Extra Feature line detected" -foregroundcolor red
                            $FoundError ++
                        }
                    $retLicence = LicenseIdentification $sASLicType $global:Type
                    $retFeatures = ValidateFeatures $ProcessCount $global:Type
                    if ($global:Type -ne 'Standard License')
                        {
                            DeleteCatalog  $global:CatalogName
                        }
                    $Return = ReturnLicense($Sn)
                    if ($Return -ne 0)
                        {
                            Write-Host " Failed to return" $ActivationCode -foregroundcolor yellow
                            $FoundError ++
                        }
                }
            else
                {
                    Write-Host " Failed to activate" $ActivationCode -foregroundcolor red
                    Add-Content -Path $logFile -Value "Failed to activate $ActivationCode" -PassThru
                    $FoundError ++
                }

            if (($FoundError -eq 0) -and ($retLicence -eq 0) -and ($retFeatures -eq 0))
                {
                    Write-Host " Serial Number Activation Test Passed" -foregroundcolor green
                    Add-Content -Path $logFile -Value "Serial Number Activation Test Passed" -PassThru
                    Write-Host (Write-Header) "Serial Number Activation Test case Passed"  
                }
            else
                {
                    Write-Host " Serial Number Activation Test Failed" -foregroundcolor red
                    Add-Content -Path $logFile -Value " Serial Number Activation Test Failed" -PassThru
                    Write-Host (write-Header) "Serial Number Activation Test case Failed"
                }


}






