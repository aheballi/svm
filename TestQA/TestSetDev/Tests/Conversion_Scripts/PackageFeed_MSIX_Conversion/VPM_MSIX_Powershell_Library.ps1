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
   
   $Path=Test-Path $strsourcePath
   If ($Path -eq 'True'){
      Copy-Item -Path $strSourcePath -Destination $strDestPath -Recurse -Force | out-null
   }
   Else{
        #$F=Remove-PSDrive N
        Write-Host "Testdata is not present"
        return -1
   }
         
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



Function PackageFeedConversion($CatalogName,$DownloadPath,$LogFile,$ResultLog)
{
    
    Import-Module BitsTransfer
    $PFData= Invoke-RestMethod -Uri "https://dl.csi7.secunia.com/?action=vpm_list&token=F8859A92-C9C5-43F2-95D7-9A3E19FEC0B6&cstid=test"  
    
    #for($i=143; $i -lt 250 ; $i++ )
    for($i=0; $i -lt $PFData.data.Count; $i++ )
    {
        $ConvRetval=-1
        if(($PFData.data[$i].type -eq "Legacy") -or ($PFData.data[$i].type -eq "MSI"))
        {

            Write-host (Write-Header $TestName) "Package Details:"
            $VPMId= $PFData.data[$i].vpm_id
            write-host "VPM_Id: $VPMId"
            WriteResultsToFile $logFile "VPM_Id: $VPMId" 0 0
            $timeStamp = ('['+(Get-Date -Format 'hh:mm:ss')+']')
            Add-Content $ResultLog "`r`n$timeStamp : VPM_Id: $VPMId"
            $productName= $PFData.data[$i].product_name
            write-host "Product Name: $productName"
            WriteResultsToFile $logFile "Product Name: $productName" 0 0
            #Add-Content $ResultLog "Product Name: $productName"
            $downloadLink= $PFData.data[$i].download_link
            write-host "Download link: $downloadLink"
            WriteResultsToFile $logFile "Download link: $downloadLink" 0 0
            Add-Content $ResultLog "Download link: $downloadLink"
            if($downloadLink)
            {
                $FileName=Split-path $downloadLink -leaf 
                if($FileName -match '.exe' -or $FileName -match '.msi')
                {
                    Write-host "Downloading the package..."
                    WriteResultsToFile $logFile "Downloading the package..." 0 0
                    $downloadedFolderPath= $DownloadPath + "\"+ $productName
                    If(Test-Path $downloadedFolderPath)
                    {
                        Remove-Item $downloadedFolderPath -recurse -Force
                    }
                    New-Item -Path $downloadedFolderPath -ItemType Directory -Force | out-null
                    Start-BitsTransfer -Source $downloadLink -Destination $downloadedFolderPath
                    $packageName= Get-ChildItem -Path $DownloadedFolderPath
                    write-host "Downloaded Package name: $packageName"
                    WriteResultsToFile $logFile "Downloaded Package name: $packageName" 0 0
                    #Add-Content $ResultLog "Downloaded Package name: $packageName"
                    $downloadedPackagePath= $downloadedFolderPath + "\" + $packageName
                    write-host "Downloaded package path: $downloadedPackagePath"
                    WriteResultsToFile $logFile "Downloaded package path: $downloadedPackagePath" 0 0
                    Add-Content $ResultLog "Downloaded package path: $downloadedPackagePath"
                    $PackageDetails= Invoke-RestMethod -Uri "https://dl.csi7.secunia.com/?action=vpm_details&token=F8859A92-C9C5-43F2-95D7-9A3E19FEC0B6&vpm_id=$VPMId&cstid=test"
                    if($PackageDetails.data.silent_switches)
                    {
                        $commandlineSwitches= $PackageDetails.data.silent_switches
                        write-host "Command Line switches: $commandlineSwitches"
                        WriteResultsToFile $logFile "Command Line switches: $commandlineSwitches" 0 0
                        Add-Content $ResultLog "Command Line switches: $commandlineSwitches"
                        $ConvRetval = ConvertAndValidate $catalogName $downloadedPackagePath $commandlineSwitches $LogFile $ResultLog
            
                    }
                    elseif($PackageDetails.data.silent_switches_generated)
                    {
                        $commandlineSwitches= $PackageDetails.data.silent_switches_generated
                        write-host "Command Line switches: $commandlineSwitches"
                        WriteResultsToFile $logFile "Command Line switches: $commandlineSwitches" 0 0
                        Add-Content $ResultLog "Command Line switches: $commandlineSwitches"
                        $ConvRetval = ConvertAndValidate $catalogName $downloadedPackagePath $commandlineSwitches $LogFile $ResultLog
            
                     }
                    else
                    {
                        write-host "Command line switches are not found for the package"
                        WriteResultsToFile $logFile "Command line switches are not found for the package" -1 0
                        Add-Content $ResultLog "Command line switches are not found for the package"
                     

                    }
                 
                    if ($ConvRetval -eq 0)
                    {
                        Write-host (Write-Header $TestName) "Conversion and validation for $downloadedPackagePath : Successful"
                        WriteResultsToFile $logFile "Conversion and validation for $downloadedPackagePath : Successful" $ConvRetval 0
                        Add-Content $ResultLog "Conversion and validation for $downloadedPackagePath : Successful"
                    
                    }
                    else
                    {
                        Write-host (Write-Header $TestName) "Conversion and validation for $downloadedPackagePath : Failed"
                        WriteResultsToFile $logFile "Conversion and validation for $downloadedPackagePath : Failed" $ConvRetval 0
                        Add-Content $ResultLog "Conversion and validation for $downloadedPackagePath : Failed"
                    
                    }
                 }
                 else
                 {
                    Write-host (Write-Header $TestName) "Download link points to unsupported package type for MSIX conversion"
                    WriteResultsToFile $logFile "Download link points to unsupported package type for MSIX conversion" -1 0
                    Add-Content $ResultLog "Download link points to unsupported package type for MSIX conversion"
                   
                 }
                 If(Test-Path $downloadedPackagePath)
                    {
                        Write-host (Write-Header $TestName) "Removing the $downloadedPackagePath"
                        WriteResultsToFile $logFile "Removing the $downloadedPackagePath" 0 0
                        Add-Content $ResultLog "Removing the $downloadedPackagePath"
                        Remove-Item $downloadedPackagePath -recurse -Force
                        If(Test-Path $downloadedPackagePath)
                        {
                            Write-host (Write-Header $TestName) "Failed to Remove the $downloadedPackagePath"
                            WriteResultsToFile $logFile "Failed to Remove the $downloadedPackagePath" 0 0
                            Add-Content $ResultLog "Failed to Remove the $downloadedPackagePath"
                        }
                        else
                        {
                            Write-host (Write-Header $TestName) "Successfully removed the $downloadedPackagePath"
                            WriteResultsToFile $logFile "Successfully removed the $downloadedPackagePath" 0 0
                            Add-Content $ResultLog "Successfully Removed the $downloadedPackagePath"
                        }

                    }
             }
            else
            { 
                write-host (Write-Header $TestName) "Download link not found for the package"
                WriteResultsToFile $logFile "Download link not found for the package" $downloadLink 0
                Add-Content $ResultLog "Download link not found for the package"
               
               
            }

        }
    
        else
        {
            Write-Host (Write-Header $TestName) "Package Type not supported for MSIX conversion"
            WriteResultsToFile $logFile "Package Type not supported for MSIX conversion" -1 0
            Add-Content $ResultLog "Package Type not supported for MSIX conversion"
           
            
        }
    }
    
}


Function ConvertAndValidate($catalogName,$strPackageLoc,$commandlineSwitches,$LogFile,$ResultLog)
{
  
  $RetVal=-1
  $ConversionLog=$TestCaseFolder +"\"+"ConversionLog.log"
  $strTargetType= "MSIX"  
  $AACSettingsFilePath="C:\AS_Automation\VPM_MSIX_Conversion\AACSettingsFiles\AACWin10x64WithSeq.aacx"                             
  $PackageID=0
  $ConvertedPackagePath=””                
  #Checking the Testdata location
  If($strPackageLoc)
  {    
      $strPackage=Split-path $strPackageloc -leaf                                           
      $strSQLQuery =  "select Rowid from cstblpackage where OriginalMsiFileName='$strPackage'"
      $PackageRowIDExist = ExecuteSQLQuery $strSQLQuery $CatalogName
                        
      if($PackageRowIDExist -ge 0)
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
      Write-host (Write-Header $TestName) "Package not found at the downloaded location or Package path is incorrect"
      WriteResultsToFile $LogFile "Package not found at the downloaded location or Package path is incorrect :" 0 0
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
     Add-Content $ConversionLog "`r`n$timeStamp : Processing $strPackage for $strTargetType Conversion :"
     Write-Host (Write-Header $TestName) "Processing $strPackage for $strTargetType Conversion:"
     WriteResultsToFile $logFile "Processing $strPackage for $strTargetType Conversion:"
     WriteResultsToFile $logFile "Converting $strPackage to $strTargetType format started...."
     $Result=Invoke-ASConvertPackageEx -PackageID $PackageID -TargetType $strTargetType -AACSettings $AACSettingsFilePath -CommandLine $commandlineSwitches
     Write-host (Write-Header $TestName) "Converting $strPackage to $strTargetType format completed, Scanning for errors and MSIX file Validation is Pending.... "                 
     WriteResultsToFile $logFile "Converting $strPackage to $strTargetType format completed, Scanning for errors and MSIX file Validation is Pending...."
     $Retval= Vaildate_ASConversion $strPackage $AACSettingsFilePath $strTargetType $LogFile $ConversionLog $ResultLog            
    
    return $RetVal
}




Function Vaildate_ASConversion($strPackage,$AACSettingsFilePath,$strTargetType,$logFile,$ConversionLog,$ResultLog)
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
              WriteResultsToFile $logFile "Schema Validation Error" $ConversionStatus 0
              Add-Content $ResultLog "Schema Validation Error Found"
              $ErrorFound=-1
          }
          ElseIf($text.Message -match "Warning -9572 virtualizing package: This package contains no shortcuts")
          {
              Write-Host (Write-Header $TestName) "No shortcuts Warning Found"
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
     #Commenting the code which validates the extraction of child packages from msix file since the support for extraction has been stopped in product
     #handling the escape sequence \v in $ConvertedPackagePath
     #$ConvertedPackagePath=  "'"+ $ConvertedPackagePath +"'"
     #$StrSQLQuery= "select Filename from cstblpackage where RowID=(select ParentPkgRowID_ from ASCMSuitePackages where FileName=$ConvertedPackagePath)"
     #$ConvertedPackagePath= ExecuteSQLQuery $StrSQLQuery $CatalogName
     write-host(Write-Header $TestName) "Converted Package Path: $ConvertedPackagePath"
     WriteResultsToFile $logFile "Converted Package Path: $ConvertedPackagePath" 0 0
    
     if($ConvertedPackagePath)
     {

         $ConvertedPackage=Split-path $ConvertedPackagePath -leaf  
         if($ConvertedPackage -match '.msix')
         {
             $ConversionStatus=0
             WriteResultsToFile $logFile "Converting $strPackage Package to $strTargetType Format " $ConversionStatus 0
             Write-Host (Write-Header $TestName) "Converting $strPackage Package to $strTargetType Format- Passed "

         }
         else
         {
           
             WriteResultsToFile $logFile "Converting $strPackage Package to $strTargetType Format " $ConversionStatus 0 
             Write-Host (Write-Header $TestName) "Converting $strPackage Package to $strTargetType Format- Failed "  
         } 
     }
     else
     {
        Write-host (Write-Header $TestName) "Converted package path is not available for .msix file validation"
        WriteResultsToFile $logFile "Converted package path is not available for .msix file validation" $ConversionStatus 0 
     }
  
     return $ConversionStatus
} 




