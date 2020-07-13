. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

$TestCaseName="ASCatalogUpgrades"
$TargetVersion="AdminStudio 2018"

    try{

            $TestDatadir=$ParentFolder+'\*'
            Remove-Item $TestDatadir -recurse -Force -ErrorAction SilentlyContinue
            Write-host "Started Executing $TestCaseName...."

            $strSourcePath="$TestDataSource\Upgrades\$TestCaseName"

            #Copy test data

            $Retval=CopyTestDataLocally $strSourcePath $ParentFolder 
  
            WriteResultsToFile $logFile "Copying test data from shared folder to $ParentFolder is successful " 

            #SQL Server is not installed with the last version of sqlps (SQL PowerShell),So we use this command to update the sqlps module: 
 
            Update-Module -Name SqlServer
    
            $DBDetailsCSV=$ParentFolder+'\'+$TestCaseName+'\TestData\CSVs\UpgradeASCatalogs.csv'

            $RetVal=ASCatalogUpgrade $DBDetailsCSV

                if($RetVal -eq 0)
                    {
                        WriteResultsToFile $logFile "Upgrading the previous version catalog(s) to $TargetVersion is successful"  $RetVal 0
                        Write-host "Completed Executing $TestCaseName...."
                    }

                   else
                    {
                        WriteResultsToFile $logFile "Upgrading the previous version catalog(s) to $TargetVersion is Unsuccessful" $RetVal 0
                        Write-host "Completed Executing $TestCaseName...."
                    }

      }

    catch {           
            WriteResultsToFile $logFile $Error
          }
   
  #Stop-Process -Name AdminStudioHost

 