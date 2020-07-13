. C:\TestSetDev\Tests\AS_Powershell_Library.ps1
#start
$ParentFolder = "C:\AS_Automation"
if ((Test-Path -path $ParentFolder) -eq "True")
    {
	    Remove-Item -Path $ParentFolder -recurse -force
    }
New-Item -path $ParentFolder -ItemType Directory -Force |out-null
$ProjectName='Eval_Activations'
$ProjectFolder=$ParentFolder+"\"+$ProjectName
$logFile=$ProjectFolder + "\"+$ProjectName+".log"
$retval= Createlog($logFile)
Write-Host (Write-Header $ProjectName )  "Test Started"
$sCurrentLoc = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$sAsLocTPSConfig = $sAsLoc + "\TpsConfig.exe"
$slicenseType              = "LSProductID"
$global:Type = $null
$EvalMode_TPSInfo_Check = $ProjectFolder + '\EvalMode_TPSInfo_Check.txt'
$EvalModeInfo = $ProjectFolder + '\EvalModeInfo.txt'
# Copying the ActivationList.csv file
$TestDataSourceActivation = $TestDataSource  + "\Activations\"
$ActivationCSV = "ActivationList.csv"
$CsvFileSourcePath = $TestDataSourceActivation + $ActivationCSV
$Retval = CopyTestDataLocally $CsvFileSourcePath $ProjectFolder 0
WriteResultsToFile $logFile "Copied CSV from the shared folder." $Retval 0
$csv=@("ProcessEnt.csv","ProcessPro.csv","ProcessStn.csv", "EvalMode_TPSInfo_Check.txt","PreRequisite.ps1","PreRequisite.bat","ProcessEnt32Bit.csv","ProcessPro32Bit.csv","ProcessStn32Bit.csv")
for($i=0;$i -lt $csv.Count; $i++) 
    {
        $CsvFile = $TestDataSourceActivation + $csv[$i]
        $Retval = CopyTestDataLocally $CsvFile $ProjectFolder 0
    }
invoke-expression -command "cd $ProjectFolder"
$computers = “C:ActivationList.csv”
$a = Import-Csv C:ActivationList.csv | Measure-Object
$RowCount = $a.count
for ($i=0; $i -lt $RowCount; $i++)
{
        $output=(import-csv $computers)[$i]
        write-host $output
        $activationCode = $output.ActivationId
        $GetDate = Get-Date
        $ModDate = $GetDate.AddDays(21)
        Write-Host $ModDate
        $ModDate = [datetime]::ParseExact($ModDate,"MM/dd/yyyy HH:mm:ss",$null)
        $NewDate = Get-Date $ModDate -Format "dd-MMM-yyyy"
        (Get-Content .\EvalMode_TPSInfo_Check.txt ).Replace('16-aug-2018',$NewDate) | Out-File .\EvalMode_TPSInfo_Check.txt
        Set-itemProperty -path "Registry::HKLM\Software\InstallShield\AdminStudio\16.0" -name "LSProductID" -Value "Eval"
        $sASLicType          = (Get-ItemProperty $shive $slicenseType).$slicenseType
        $returnVal=0
        start-process C:Prerequisite.bat
        Start-Sleep -Seconds 5
        New-Item $EvalModeInfo -ItemType file
        $wshell = New-Object -ComObject wscript.shell;
        if($wshell.AppActivate('AdminStudio'))
            {
                Start-Sleep -Seconds 1
                [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
                [System.Windows.Forms.SendKeys]::SendWait("^{TAB}") 
                [System.Windows.Forms.SendKeys]::SendWait("^{TAB}") 
                [System.Windows.Forms.SendKeys]::SendWait("^{c}")    
                $TPSconfigInfo = [System.Windows.Forms.Clipboard]::GetText()
                [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
            }
      
        Add-Content -Path $EvalModeInfo -Value $TPSconfigInfo
        Start-Sleep -Seconds 10
        if(Compare-Object -ReferenceObject $(Get-Content $EvalModeInfo) -DifferenceObject $(Get-Content $EvalMode_TPSInfo_Check))
            {            
                $returnVal = -1
            }
        Remove-Item -Path $EvalMode_TPSInfo_Check -Force
        Remove-Item -Path $EvalModeInfo -Force
        WriteResultsToFile $logFile "The License Information related to Eval mode is successfully validated" $retEvalInfo 0
        $retLicence = LicenseIdentification $sASLicType
        WriteResultsToFile $logFile "The License Identification is successful." $retLicence 0
        Write-Host $global:Type
        $retFeatures = ValidateFeatures $ProcessCount $global:Type
        WriteResultsToFile $logFile "The validation of features is successful." $retFeatures 0
        if (($returnVal -eq 0) -and ($retLicence -eq 0) -and ($retFeatures -eq 0))
                {
                    Write-Host 'Test Case Passed successfully'
                    Write-Host (write-Header $ProjectName) "Test Case for Eval Mode Activation Passed successfully"
                }
        else 
                {
                    Write-Host 'Test Case Failed'
                    Write-Host (write-Header $ProjectName) "Test Case Failed for Eval Mode Activation"
                }
}