#-------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------

. C:\TestSetDev\Tests\GlobalVariables.ps1

function LoadDLL ($s)
{ 
    $FileName = Join-Path $sAsLoc $s
    import-module -name $FileName
}

function PrepAS ()
{    

   $EnablePSRemoting=Enable-PSRemoting -Force
   $SetFireWallStatus=netsh advfirewall set allprofiles state off
   $WinRmQUickConfig=winrm quickconfig
   $TrustedHosts=winrm s winrm/config/client '@{TrustedHosts="*"}'
   
    LoadDLL 'AdminStudio.Platform.PowerShellExtensions.dll'
    LoadDLL 'AdminStudio.Utilities.dll'
    LoadDLL 'AdminStudio.SCCM.Model.dll'
    LoadDLL 'AdminStudio.Services.Client.dll'
    LoadDLL 'AdminStudio.SCCM.Model.Disconnected.dll' 


    #Set-ASConfigPlatform -ConnectionString $ConnectionString
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: WriteResultsToFile($logFile,$strStepDesc,$strActual,$strExpected)
  Description: Writes result in to a file
  Input Parameters:
       $logFile - Log file path
       $strStepDesc - Step Description
       $strActual - Actual result of the step
       $strExpected - Expected Result of the step
       
  Output Parameters -
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function WriteResultsToFile($logFile,$strStepDesc,$strActual,$strExpected)
{
	$timeStamp = ('['+(Get-Date -Format 'hh:mm:ss')+']') 
	$result = "Failed"
    if($strActual -eq $strExpected)
    {
		$result = "Passed"
    }
	$resultStr= "$timeStamp $strStepDesc - $result"
	Add-Content $logFile $resultStr
}

function ExecuteSql ($sql, $connectInfo)
{
    $connection = new-object system.data.SqlClient.SQLConnection($connectInfo)
    $command = $connection.CreateCommand()
    $command.CommandText = $sql 
    $connection.Open()
    if ($command.ExecuteNonQuery() -ne -1)
    {
        Write-Host "Query Failed:" $sql 
    }
    $connection.Close()
 }


function DeleteCatalog ($CatalogName)
{
   Try
   {

    $connectionstring = "Data Source=$SQLServer;User ID=$UserName;Integrated Security=SSPI;"     
    
    #if ( $null -ne $Connectionstring.Databases[$CatalogName] ) { $exists = $true } else { $exists = $false }
    $sql = "ALTER DATABASE [$CatalogName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
    ExecuteSql $sql $connectionstring
    $sql = "DROP DATABASE [$CatalogName]"
    ExecuteSql $sql $connectionstring
    }
    Catch
    {
     if($logFile -ne $null)
     {
     #WriteResultsToFile $logFile "Catalog $CatalogName  Doesn't Exist to delete in the DB Server"
     }
     elseif($logFile -eq $null)
     {
     #Write-Host "Catalog $CatalogName  Doesn't Exist to delete in the DB Server"
     }
    }

}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: Create_RemotePSSession($HostName,$UserName,$Password)
  Description: Creates a remote powershell session
  Input Parameters:
       $HostName - Remote machine hostname
       $UserName - Remote machine User Name
       $Password - Remote machine Password
  Output Parameters - Session
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Create_RemotePSSession($HostName,$UserName,$Password)
{
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
    $Session=New-PSSession -ComputerName $HostName -Credential $cred 
    $session     
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: Create_PSSession($HostName,$sitecode)
  Description: Creates an SCCM powershell session and import the psd1 modules
  Input Parameters:
       $HostName - Remote machine hostname
       $SiteCode -  SCCM Site code       
  Output Parameters - Session
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Create_PSSession($HostName,$sitecode)
{    
    $sitecode=$sitecode +":"  
    $SCCM_Session= Create_RemotePSSession $HostName $UserName $Password
                
    Invoke-Command -Session $SCCM_Session -ScriptBlock {
    param([string] $sitecode)
    Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
    Set-Location $sitecode
    } -ArgumentList $sitecode

    $SCCM_Session
}
   



Function CopyTestDataLocally($strSourcePath,$strDestPath,$strIsFile)

{ 
   $strSource= split-path $strsourcePath -leaf
   $strDestination= Join-Path $strDestPath $strSource    
   
   <#$SharedDrive="\\10.20.150.10\AdminStudio"
   $UserName="acresso\releaseengineer"
   $Password = "Narlokwilt647"
   #$net = new-object -ComObject WScript.Network
   #$x=$net.MapNetworkDrive("N:", $SharedDrive, $false, $UserName, $Password)
   $cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($UserName,(ConvertTo-SecureString -String $Password -AsPlainText -Force))
   $F=New-PSDrive -Name N -PSProvider FileSystem -Root $SharedDrive -Credential $cred#>
   $Path=Test-Path $strsourcePath
   If ($Path -eq 'True'){
      Copy-Item -Path $strSourcePath -Destination $strDestPath -Recurse -Force | out-null
   }
   Else{
        #$F=Remove-PSDrive N
        Write-Host "Testdata is not present"
        return -1
   }
   #$x=$net.RemoveNetworkDrive("N:")
   #$F=Remove-PSDrive N
         
   If ((Test-Path -path $strDestination) -eq "True")
   {return 0}  
   else  
   {return -1} 
   
 }

 
 
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: CreateNewCatalog($CatalogName,$SRFlag)
  Description: Creates a new AdminStudio Catalog
  Input Parameters:
       $CatalogName - AdminStudio Catalog Name
       $SRFlag - Software Repositary Flag
       
  Output Parameters - 0 for Success, -1 for failure
  Author    : Rakesh Ramesh  #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function CreateNewCatalog($CatalogName,$SRFlag)
{
    #Checking for existance of catalog and delete if exists
    #Creating new catalog
    PrepAS 
    
    DeleteCatalog $CatalogName
    
    $setDB = "PROVIDER=SQLNCLI11;Data Source=$SQLServer;Initial Catalog=$CatalogName;Integrated Security=SSPI;" 
    Set-ASConfigPlatform -ConnectionString $setDB

    $Result = New-ASCatalog -CatalogName $CatalogName
        
    $RetVal = Select-String -Pattern "Succeeded" -InputObject $Result

    
    if($RetVal -ne $null)
    {
        return 0
    }
    Else
    {
        return -1
    }

}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: ConnectToCatalog($CatalogName)
  Description: Connect to an AdminStudio Catalog
  Input Parameters:
       $CatalogName - AdminStudio Catalog Name
      
  Output Parameters - 0 for Success, -1 for failure
  Author    : Rakesh Ramesh   #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function ConnectToCatalog($CatalogName)
{
       
   PrepAS

   Set-ASConfigPlatform -ConnectionString "PROVIDER=SQLNCLI11;Data Source=$SQLServer;Initial Catalog=$CatalogName;Integrated Security=SSPI;"    
   return 0
}


Function ImportSinglePackage($PackageLocation,$CatalogName)
{
    $retval=-1
    If(Test-Path $PackageLocation)
    {
        PrepAS

        Set-ASConfigPlatform -ConnectionString "PROVIDER=SQLNCLI11;Data Source=$SQLServer;Initial Catalog=$CatalogName;Integrated Security=SSPI;"    
        $Import = Invoke-ASImportPackage -PackagePath $PackageLocation

        if($Import)
        {
            if($Import.RowID -gt 0)
            {
                $retval= $Import.RowID
            }
        }        
    }   
    return $retval
}

Function ExecuteSQLQuery($strSQLQuery, $CatalogName)
{
    $retval=-1
    $temp = ''
    $adapter = ''
    $command = ''
    $dataset = ''
    $Value = @()
    $result = ''
    $strSQLQuerySplit = ''
    If($strSQLQuery)
    {
     $connectionString = "Data Source=$SQLServer;Integrated Security=SSPI;Initial Catalog=$catalogName"
   
   
    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($strSQLQuery,$connection)
    $connection.Open()

    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $temp= $adapter.Fill($dataSet) 
    
    
    $result= $dataset.Tables
           
        $strSQLQuerySplit = $strSQLQuery.split()      
        if(($strSQLQuerySplit.item(0) -eq "select"))
        {
            if($strSQLQuerySplit[1].Contains(","))
            {
                
                for($row=0; $row -lt $result[0].Rows.Count;$row++)
                {
                    $Value+= $result[0].rows[$row].ItemArray+"`n"
                    $retval=$Value                   
                }
             }   
                
            else
            {        
                 $Value = $result[0].Columns[0].ColumnName
                 
              if(![string]::IsNullOrEmpty($result.$Value)) 
                {
                       
                    $retval = ([string]$result.$Value).trim()
                    
                }
                else 
                {                         
                    $retval= $result.$Value   #Some select queries return null values
                }
            }
        }
        else
        {
            $retval = 0
        }  
        
    $connection.Close()       

    }
    return $retval
}


Function ExecuteAPICmd($API_Cmd,$CatalogName)
{    
    $Retval=-1
    if($API_Cmd)
    {
        $retval= ConnectToCatalog $CatalogName
        $Retval = Invoke-Expression $API_Cmd    

    }
    return $Retval
}


Function ExecuteSQLScript($SQLFilePath,$DBName)
 {
    
    If($SQLFilePath)
    {
         
        <#try{
            Push-location
            Import-module sqlps -DisableNameChecking
            Pop-Location
            $ScriptRun=Invoke-sqlcmd -Inputfile $sqlFilePath -ServerInstance '$SQLServer' -Database $DBName -ErrorAction Stop
            return 0
            
            }
       Catch{
                WriteResultsToFile "failed" 0 -1
                Add-Content -Path $logFile -Value "GeneralException $_"
                return -1
            }#>
            try{
            
            $contents = [IO.File]::ReadAllBytes( $SQLFilePath ) 
            If($contents)
            {
                $SessionID=Create_RemotePSSession $SCCMServerName $UserName $Password
                Invoke-Command -Session $SessionID -ComputerName $SQLServer -ScriptBlock { 
                        param( 
                            [byte[]] $Contents, 
                            $SQLServer, 
                            $DBName 
                            ) 
                        Import-module sqlps -DisableNameChecking
                        [IO.File]::WriteAllBytes( 'C:\SQL\Script.sql', $Contents) 
                        Invoke-sqlcmd -Inputfile 'C:\SQL\Script.sql' -ServerInstance $SQLServer -Database $DBName                                 
                        } -ArgumentList ([byte[]] $contents),$SQLServer,$DBName
                        Remove-PSSession $SessionID          
                return 0
            }

            }
       Catch{
                WriteResultsToFile "failed" 0 -1
                Add-Content -Path $logFile -Value "GeneralException $_"
                return -1
            }
                
     }
    Else
    {
        WriteResultsToFile "SQL Script file is empty" 0 -1
        return -1
    }

 }



function Write-Header ($TestCaseName)
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' ['+$TestCaseName+']'
    return $Header
}


Function Wait()
{
    Start-Sleep -s 40
}


Function ConvertAndValidate($CSVPath,$CatalogName,$LogFile,$ResultLog)
{
  
  $RetVal=-1
  If(Test-Path $CSVPath)
    { 
        PrepAS
        $ConversionLog=$TestCaseFolder +"\"+"ConversionLog.log"
        $CSVcontent=Import-Csv $CSVPath
        $CSVcontent | ForEach-Object{ 
        
                $strPackageloc= $_.PackageLocation
                $strTargetType=$_.TargetType                                
                $PackageID=0
                $ExpectedOutputFiles=$_.OutputFiles                               
                $ExpectedConversion_files = @()
                $ExpectedConversion_files =$ExpectedOutputFiles -split '/'
                $taskname=$_.TaskName
                $CommandLine=$_.CommandLine
                $ConvertedPackagePath=””                
               #Checking the Testdata location mentioned in testdata CSV
                If($strPackageloc)
                 {    
                        $strPackage=Split-path $strPackageloc -leaf                                           
                        $strSQLQuery =  "select Rowid from cstblpackage where OriginalMsiFileName='$strPackage'"
                        $PackageRowIDExist = ExecuteSQLQuery $strSQLQuery $CatalogName
                        
                        if ($PackageRowIDExist -ge 0)
                           {
                                $PackageIDFlag=$PackageRowIDExist
                           }
                        else
                           {                          
                                $PackageIDFlag=0
                           }                        
                  }
                else
                  {
                        $_.ASConversion_Validate_Status ="Test data location not mentioned in the CSV. "
                        WriteResultsToFile $LogFile "Test data location not mentioned in the CSV for the pacakge $strPackage :" 0 0
                        return
                  }              
                                                    
                 If ($PackageIDFlag -eq 0)
                  {
                      $ImportPackageID = ImportSinglePackage $strPackageLoc $catalogName
                      $PackageID = $ImportPackageID                           
                                                                           
                  }
                  
                  Else
                  {
                      $PackageID = $PackageIDFlag
                  }
       
                         
                             
                   $timeStamp = ('['+(Get-Date -Format 'hh:mm:ss')+']')
                   Add-Content $ConversionLog "`r`n$timeStamp : Processing $strPackage :"
                   Add-Content $ResultLog "`r`n$timeStamp : Processing $strPackage :"
                   Write-Host (Write-Header $TestName) "Processing $strPackage :"
                   WriteResultsToFile $logFile "Processing $strPackage :"
                   $AACSettingsFilePath=$_.AACSettingsFilePath
                   $CommandLine=$_.CommandLine
                           
                   WriteResultsToFile $logFile "Converting $strPackage to $strTargetType format started...."
                   
				   $Result=Invoke-ASConvertPackageEx -PackageID $PackageID -TargetType $strTargetType -AACSettings $AACSettingsFilePath -CommandLine $CommandLine 
                      
                   WriteResultsToFile $logFile "Converting $strPackage to $strTargetType format completed, Validation and launching is Pending...."
                   if($ExpectedConversion_files -eq "NA")
                      {
                           WriteResultsToFile $logFile "Validating  virtual format output files not required as it is not specifed for $strPackage virtual format type $strTargetType ...."
                           $ConvRetval=0
                           
                      }
                   else
                      {
                           
                           $ConvRetval= Vaildate_ASConversion $strPackage $AACSettingsFilePath $strTargetType $LogFile $ExpectedConversion_files $ConversionLog $ResultLog
                      }                            
                     

                           #To Call Launch and Validate Functions based on the Target Conversion Type and write the status to Testdata CSV
                           #write-host $ConvertedPackagePath
                                  
                     if($ConvRetval -eq 0)
                         
                            {
                                         $strSQLQuery =  "select Filename from cstblpackage where RowID=(SELECT TOP 1 RowID FROM cstblPackage ORDER BY RowID DESC)"
                                         $ConvertedPackagePath = ExecuteSQLQuery $strSQLQuery $CatalogName
                          
 
                                          # Commenting the code since we have stopped extracting the child packages from msix
                                          #handling the escape sequence \v in $ConvertedPackagePath
                                          #$ConvertedPackagePath=  "'"+ $ConvertedPackagePath +"'"
                                          #$StrSQLQuery= "select Filename from cstblpackage where RowID=(select ParentPkgRowID_ from ASCMSuitePackages where FileName=$ConvertedPackagePath)"
                                          #$ConvertedPackagePath= ExecuteSQLQuery $StrSQLQuery $CatalogName
                                             
                                          $Msixlaunchstatusres= Validate_MsixLaunch $ConvertedPackagePath $taskname                                  
                                            if($Msixlaunchstatusres -eq 0)
                                            {   
                                                $LaunchStatus="Pass"
                                                WriteResultsToFile $logFile "$strTargetType Package Launched Status : " $Msixlaunchstatusres 0
                                                Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Format- Passed "
                                            }
                                           else
                                            {                                           
                                                $LaunchStatus="Fail"
                                                WriteResultsToFile $logFile "$strTargetType Package Launched Status : " $Msixlaunchstatusres 0
                                                Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Format- Failed "                                           
                                            } 
                                         
                                                       
                                                         
                            }
                           else
                            {
                                    WriteResultsToFile $logFile "$strTargetType Package Conversion Failed" $ConvRetval 0                            
                                    $LaunchStatus="Fail"
                            }
                            $_.LVStatus = $LaunchStatus
                            

                            #To Write overall Status in to the Testdata CSV 
                            $CSVcontent |Export-Csv -Path $CSVPath -Force -NoTypeInformation
                            <#If (($_.ASConversion_Validate_Status -eq "Pass") -and ($_.LVStatus -eq "Pass")) 
                            {
                                $_.Overall_Status="Pass" 
                                $RetVal=0                        
                            }
                            else
                            {
                                $_.Overall_Status="Fail"
                                $RetVal=-1
                            }
                            #>
                            If($_.ASConversion_Validate_Status -eq "Pass") 
                            {
                                $_.Overall_Status="Pass" 
                                $RetVal=0                        
                            }
                            else
                            {
                                $_.Overall_Status="Fail"
                                $RetVal=-1
                            }
                      }
                      $CSVcontent |Export-Csv -Path $CSVPath -Force -NoTypeInformation
    }
    return $RetVal
}


    
Function Vaildate_ASConversion($strPackage,$AACSettingsFilePath,$strTargetType,$logFile,$ExpectedConversion_files,$ConversionLog,$ResultLog)
{

    $ConversionStatus=-1
    $ErrorFound=0
    $strPackageName= [System.IO.Path]::GetFileNameWithoutExtension($strPackage)
    $ParentAacFolder=Split-Path -Parent $AACSettingsFilePath
    $xmlPath= $ParentAacFolder + "\" + $xmlFileName
    if(Test-Path -Path $xmlPath)
    {
        Remove-Item -Path $xmlPath
    }

    $GetFiles= Get-ChildItem $ParentAacFolder | Where-Object{$_.extension} 

    ForEach($Expfile in $GetFiles) 
    {       
	    if($Expfile -match ".copy.aacx")
        {
            $PathOfAacCopyFile= $ParentAacFolder +"\"+ $Expfile
            Rename-item $PathOfAacCopyFile $xmlFileName
        }
    }
    
    [System.Xml.XmlDocument]$file = new-object System.Xml.XmlDocument
    $file.load($xmlpath)
    $ns = New-Object Xml.XmlNamespaceManager $file.NameTable
    $ns.AddNamespace( "e", "http://schemas.installshield.com/adminstudio/2010/packagelist" )
    $xml_LogItem= $file.SelectNodes("/e:PackageList/e:Results/e:Resultset/e:Result[@Name='$strPackageName']/e:Messages/e:LogItem",$ns)

    Write-Host (Write-Header $TestName) "Scanning the Conversion Logs"
    WriteResultsToFile $logFile "Scanning the conversion logs"
    Add-Content $ConversionLog "Conversion Logs:"

    foreach ($text in $xml_LogItem) 
    {
      Add-Content $ConversionLog $text.Message
          if($text.Message -match "Schema validation error")
          {
              Write-Host (Write-Header $TestName) "Schema Validation Error Found"
              WriteResultsToFile $logFile "Schema Validation Error Found" $ConversionStatus 0
              Add-Content $ResultLog "Schema Validation Error Found"
              $ErrorFound=-1
          }
          ElseIf($text.Message -match "Warning -9572 virtualizing package: This package contains no shortcuts")
          {
              Write-Host (Write-Header $TestName) "No shortcuts Warningr Found"
              WriteResultsToFile $logFile "No shortcuts Warning Found" $ConversionStatus 0
              Add-Content $ResultLog "No shortcuts Warning Found"
              $ErrorFound=-1
          } 
          ElseIf($text.Message -match "Failed running Package Installation" -or $text.Message -match "Failed getting response from VM")
          {
              Write-Host (Write-Header $TestName) "Msix conversion Error Found"
              WriteResultsToFile $logFile "Msix conversion Error Found" $ConversionStatus 0
              Add-Content $ResultLog "Msix conversion Error Found"
              $ErrorFound=-1
          } 
          ElseIf($text.Message -match "error: 0x800700C1")
          {
              Write-Host (Write-Header $TestName) "Bad Exe format Error Found"
              WriteResultsToFile $logFile "Bad Exe format Error Found" $ConversionStatus 0
              Add-Content $ResultLog "Bad Exe format Error Found"
              $ErrorFound=-1
          } 
  
     }

     if($ErrorFound -eq 0)
     {
          Write-Host (Write-Header $TestName) "Error match not found"
          WriteResultsToFile $logFile "Error match not found" $ErrorFound 0
          Add-Content $ResultLog "Error match not found"

     }
     
     $strSQLQuery =  "select Filename from cstblpackage where RowID=(SELECT TOP 1 RowID FROM cstblPackage ORDER BY RowID DESC)"
     $ConvertedPackagePath = ExecuteSQLQuery $strSQLQuery $CatalogName
     
     #Commenting the code since we have stopped extracting the child packages from msix
     #handling the escape sequence \v in $ConvertedPackagePath
     #$ConvertedPackagePath=  "'"+ $ConvertedPackagePath +"'"
     #$StrSQLQuery= "select Filename from cstblpackage where RowID=(select ParentPkgRowID_ from ASCMSuitePackages where FileName=$ConvertedPackagePath)"
     #$ConvertedPackagePath= ExecuteSQLQuery $StrSQLQuery $CatalogName
     WriteResultsToFile $logFile "Converted Package Path:$ConvertedPackagePath" 0 0
     Add-Content $ResultLog "Converted Package Path:$ConvertedPackagePath"
    
     Write-Host (Write-Header $TestName) "Validating  virtual format output files started...."
     WriteResultsToFile $logFile "Validating  virtual format output files started...." 
     $ValidationRetVal=Validate_MSIXOutputFiles $ConvertedPackagePath $ExpectedConversion_files 
     
     if($ValidationRetVal -eq 0)
     {
           $ConversionStatus=0
           $_.ASConversion_Validate_Status="Pass"
           WriteResultsToFile $logFile "Converting $strPackage Package to $strTargetType Format " $ConversionStatus 0
           Write-Host (Write-Header $TestName) "Converting $strPackage Package to $strTargetType Format- Passed "
           Add-Content $ResultLog "Converting and Validating $strPackage Package to $strTargetType Format: Passed"
     }
     else
     {
              
           $_.ASConversion_Validate_Status="Fail"
           WriteResultsToFile $logFile "Converting $strPackage Package to $strTargetType Format " $ConversionStatus 0 
           Write-Host (Write-Header $TestName) "Converting $strPackage Package to $strTargetType Format- Failed " 
           Add-Content $ResultLog "Converting and Validating $strPackage Package to $strTargetType Format: Failed" 
     } 
  
     return $ConversionStatus
} 


Function Validate_MSIXOutputFiles($ConvertedPackagePath,$ExpectedConversion_files)
{
	$RetVal=-1
	$ExpectedOutputFilesCount=1        
	$PathofAllFiles=Split-Path -Parent $ConvertedPackagePath
    $GetFiles= Get-ChildItem $PathofAllFiles | Where-Object{$_.extension} 
    $GetFilesCount=$GetFiles.Count
    if($GetFilesCount -eq $ExpectedOutputFilesCount) 
    {
     
     $MSIXOutputFiles_status=Validate_OutputFiles $PathofAllFiles $ExpectedConversion_files
     if($MSIXOutputFiles_status -eq 0)
     {
        $RetVal=0
     } 
	}
    return $RetVal
} 


Function Validate_OutputFiles($PathofAllFiles,$ExpectedFilesAfterConversion)
{
    $OutputFiles=Get-ChildItem -Name $PathofAllFiles
    ForEach($Expfile in $ExpectedFilesAfterConversion) 
	{       
		if($OutputFiles -eq $Expfile)
		{
	        $RetVal=0           
		}
        else
        {
            $RetVal=-1           
            break 
        }
	}
return $RetVal
}


Function Validate_MsixLaunch($ConvertedPackagePath,$taskname)
{
	$Msixlaunchstatus=-1
    #Add-AppPackage -Path $ConvertedPackagePath -AppInstallerFile 
	Invoke-Item $ConvertedPackagePath 
	Wait
	$GetProcess=Get-Process -ProcessName $taskname
	$GetProcessName=$GetProcess.ProcessName
		if($GetProcessName -eq $taskname)
		{
		$Msixlaunchstatus=0
		Stop-Process -processname $taskname
		WriteResultsToFile $logFile "$ConvertedPackagePath Msix Launch Status : " 0 0
		}
		else
		{
		WriteResultsToFile $logFile "$ConvertedPackagePath Msix Launch Status : " -1 0
		}
	return $Msixlaunchstatus
}

<#Function Sign_Package($ConvertedPackageID,$FilePath,$Password)
{
	 
    $SignResult= Invoke-ASSignPackage -PackageId $ConvertedPackageID -CertificateInfoType PfxFile -FilePath $FilePath -Password $Password
    return $SignResult

} #>