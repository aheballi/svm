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

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: ImportSinglePackage($PackageLocation,$CatalogName)
  Description: Import a package to an AdminStudio Catalog
  Input Parameters:
       $PackageLocation - Path to the package
       $CatalogName - AdminStudio Catalog Name
       
  Output Parameters - PackageID for Success, -1 for failure
  Author    : Rakesh Ramesh  #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: ProcessImportCSVFile($csvFileLocation,$CatalogName,$PkgID)
  Description: Process and validate the properties in the import CSV file .
  Input Parameters:
       $csvFileLocation - CSV file path
       $CatalogName - AdminStudio Catalog Name
       $EnvVar - Environment Variable Hash table
  Output Parameters - 
  Author    : Tathvik Tejas   #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function ProcessImportCSVFile($csvFileLocation,$CatalogName,$PkgID)
{  
    If(Test-Path $csvFileLocation)
    {
        $CSVcontent=Import-Csv $csvFileLocation
        $RetVal=0         
        $CSVcontent | ForEach-Object{           
        If(($_.Get_API_Cmd) -and ($_.Get_SQL_Query)) #status is set to failed when either of the fields checked for is empty.
            {            
                 If(($_.Get_API_Cmd -ne "<Not Available>"))
                     {                            
                            $_.Get_API_Cmd = [String]$_.Get_API_Cmd.replace("<PkgID>",$PkgID)
                            $_.Actual_Value = [String](ExecuteAPICmd $_.Get_API_Cmd $CatalogName)
                     }
                 
                 ElseIf(($_.Get_SQL_Query -ne "<Not Available>"))
                     {                        
                            $_.Get_SQL_Query = [String]$_.Get_SQL_Query.replace("<PkgID>",$PkgID)
                            $_.Actual_Value = [String](ExecuteSQLQuery $_.Get_SQL_Query $CatalogName)
                            $_.Actual_Value = [String]($_.Actual_Value -join ' ')                            
                     }
                 Else
                    {                    
                            $_.Actual_Value = "<Not Available>"
                            $Actual_Value1 = "No  Get_API_Cmd/Get_SQL_Query"
                            Add-Content $logFile $Actual_Value1 + " present for " + $_.Property
                    }
                 
                If($_.Expected_Value -eq $_.Actual_Value)
                   {
                            $_.Status="Success"
                   }
                Else
                   {
                            $_.Status="Failed"
                            $RetVal=-1
                   }
            }
        Else
        {
            $_.Status = "Failed"
            $RetVal=-1
        }


        If(($_.Set_API_Cmd) -and ($_.Set_SQL_Query))
            {
                     If(($_.Set_API_Cmd -ne "<Not Available>"))
                     {
                            $_.Set_API_Cmd = [String]$_.Set_API_Cmd.replace("<PkgID>",$PkgID)
                            $_.Set_API_Cmd_Result = [String]( ExecuteAPICmd $_.Set_API_Cmd $CatalogName)
                           
                            If($_.Set_API_Cmd_Result  -eq "True")
                                {
                                    $Set_Actual_Value = [String](ExecuteAPICmd $_.Get_API_Cmd $CatalogName)
                                    $_.Set_Result = [String]$Set_Actual_Value
                                }
                            Else
                                {   
                                    Add-Content -Path $logFile -Value "False, was returned on executing Set_API_Cmd of $_"
                                    $_.New_Status = "Failed"
                                }
                     }
                     ElseIf(($_.Set_SQL_Query -ne "<Not Available>"))
                     {
                            $_.Set_SQL_Query = [String]$_.Set_SQL_Query.replace("<PkgID>",$PkgID)                            
                            $tmpValue= [String](ExecuteSQLQuery $_.Set_SQL_Query $CatalogName)
                            
                            $Set_Actual_Value = [String](ExecuteSQLQuery $_.Get_SQL_Query $CatalogName )#getting the set value.
                            $Set_Actual_Value = ($Set_Actual_Value -join ' ')
                            $_.Set_Result = [String]$Set_Actual_Value
                     }
                     Else
                     {            
                        $Set_Actual_Value = "<Not Available>" 
                        $Set_Actual_Value1 = "No  Set_API_Cmd/Set_SQL_Query"
                        Add-Content $logFile $Set_Actual_Value1+" present for "+$_.Property
                     }


                    If($_.New_Value -eq $Set_Actual_Value) 
                        { 
                            If($_.New_Value -ne $null )
                                {
                                    $_.New_Status="Success"
                                }
                        }
                    Else
                        {
                            $_.New_Status="Failed"
                            $RetVal=-1
                        }
            }
        Else
        {
             $_.New_Status = "Failed"
             $RetVal=-1
        }
        
    }
    $CSVcontent |Export-Csv -Path $csvFileLocation -Force -NoTypeInformation
    
    } 
   return $RetVal
}


#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: ExecuteSQLQuery($strSQLQuery, $CatalogName)
  Description: Execute an SQL Query
  Input Parameters:
       $strSQLQuery - SQL Query
       $CatalogName - CatalogName on which to execute the Query
  Output Parameters - -1 for failure, result for success(select queries)
  Author    : Tathvik Tejas #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


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



<#Function ExecuteSQLQuery($strSQLQuery, $CatalogName)
{
    $retval=-1
    If($strSQLQuery)
    {
     $connectionString = "Data Source=$SQLServer;Integrated Security=SSPI;Initial Catalog=$catalogName"
   
   
    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($strSQLQuery,$connection)
    $connection.Open()

    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $x= $adapter.Fill($dataSet) 
    
    $result= $dataset.Tables
           
        $strSQLQuerySplit = $strSQLQuery.split()      
        if(($strSQLQuerySplit.item(0) -eq "select"))
        {                 
            #$Value = $strSQLQuerySplit.item(1)
            $Value=$result[0].Columns[0].ColumnName

            if(![string]::IsNullOrEmpty($result.$Value)) 
            {
                       
                $retval= ([string]$result.$Value).trim()
            }
            else 
            { 
                        
                $retval= $result.$Value   #Some select queries return null values 
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
$>

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: CreateLog($logFile)
  Description: Creates log file
  Input Parameters:
       $logFile - log file path       
  Output Parameters - -1 for failure , 0 for success
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Function CreateLog($logFile)
{
    If(Test-Path -Path $logFile)
    {
    Remove-Item -Path $logFile 
    }
    Else
    {
    New-Item -Path $logFile -ItemType file -Value $(Get-Date) -Force | out-null
    
    return 0
    }
}


#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: ExecuteAPICmd($API_Cmd,$CatalogName)
  Description: Execute an AS API command
  Input Parameters:
       $API_Cmd - API command String 
       $EnvVar - Environment Variable Hash table
  Output Parameters - -1 for failure , result for success
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: VirtualReadiness($csvFileLocation,$CatalogName)
  Description: Running Virtualization Compatability Tests
  Input Parameters:
       $csvFileLocation - CSV file location 
       $logFile - log file path
  Output Parameters - -1 for failure , 0 for success
  Author    : YojanaYarradoddi #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Function VirtualReadiness($csvFileLocation,$TestCaseFolder,$logFile)
{     
 
    If(Test-Path $csvFileLocation)
    {
        $CSVcontent=Import-Csv $csvFileLocation
        $RetVal=0
        PrepAS
        $CSVcontent | ForEach-Object{   
       
        $PackageName=$_.Package_Name
        $strSourcePath=$_.Package_Location
        $ExpectedResult=$_.VirtualReadiness_ExpectedResult
        $strDestPath= $TestCaseFolder
        $PackageLoc= $strDestPath + "\" + $PackageName + ".msi"
        $RetValCopy=CopyTestDataLocally $strSourcePath $strDestPath 1
        
        if ($RetValCopy -eq 0)
        {                       
            $ActualResult= Get-ASVirtualReadiness -PackagePath $PackageLoc
            $_.VirtualReadiness_ActualResult =$ActualResult
                    
            if ($ExpectedResult -eq $ActualResult)
            {           
                        $_.VirtualReadiness_Status="Pass"
                                               
             }
            Else
             { 
                        $_.VirtualReadiness_Status="Fail"
                        $RetVal=-1
             }
             
                   
             WriteResultsToFile $logFile "Test for $PackageName virtualization readiness " $ActualResult $ExpectedResult
             
          }

         Else
          {
                $_.VirtualReadiness_Status="Fail"
                $RetVal=-1
                $Result= $PackageName +"    failed to copy  "
                WriteResultsToFile $logFile $Result $Retval 0
          }

        $CSVcontent |Export-Csv -Path $csvFileLocation -Force -NoTypeInformation
    
    return $RetVal
    } 
} 
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: GetRuleCategory($strRule)
  Description: The function to get the rule test category based on the input rule number
  Input Parameters:
       $strRule - Rule Name displayed in csv file 
  Output Parameters: Return Rule test category name      
  Author    : YojanaYarradoddi #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function GetRuleCategory($strRule)
{
$strTestOption = -1
	$strSQLQuery="select Name from ASTestCategory Where OID= (Select ParentCategory from ASTest where TestIdInternal='$strRule')"
    $strTestOption=ExecuteSQLQuery $strSQLQuery $CatalogName
    return $strTestOption

}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: ExecuteTestASPackage($CatalogName, $strProjectFolder,$csvPath,$logfile)
  Description: Running OSCompatibility rules based on csv file
  Input Parameters:
       $CatalogName - Catalog Name where to execute rules 
       $strProjectFolder - Project Folder location where test data to be copied
       $csvPath - CSV file location
       $logFile - log file path      
  Author    : YojanaYarradoddi
  LastModifiedBy:YojanaYarardoddi
  LastModifiedDate: 12/14/2016  #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Function ExecuteTestASPackage($CatalogName, $TestCaseFolder,$csvPath,$logfile)
{

$LogsFolder=$TestCaseFolder+"\Logs"
New-Item -Path $LogsFolder -ItemType Directory -Force | out-null

$TestData=$TestCaseFolder+"\TestData"
New-Item -Path $TestData -ItemType Directory -Force | out-null

If(Test-Path $csvPath)
    {
        $CSVcontent=Import-Csv $csvPath
        $RetVal=0
        $CSVcontent | ForEach-Object{   
        $strPackageloc= $_.Package_Location
        $strRule= $_.Rule
        $strDeploymentType=$_.DeploymentType
        $strPackageName=$_.Package_Name
        $ExpectedError=$_.ExpectedErr
        $ExpectedWarning=$_.ExpectedWarning       

                If ($strPackageloc)
                {

                        $strPath=Split-path $strPackageloc -leaf
                        $strPackage=$strPackageName+"."+$strDeploymentType
                        $strPackageLocation= $TestData+"\"+$strPath+"\"+$strPackage
                                                
                        $PackageIDFlag=0 
                        
                        $OutFilePath = $LogsFolder +"\"+ $strRule + ".txt"                                         

                        $strSQLQuery =  "select Rowid from cstblpackage where OriginalMsiFileName='$strPackage'"
                        $PackageRowIDExist = ExecuteSQLQuery $strSQLQuery $CatalogName
                        if ($PackageRowIDExist -ge 0){
                            $PackageIDFlag=$PackageRowIDExist
                            $oPackage = Get-ASPackage -PackageId $PackageIDFlag
                            $strPackageLocation= $oPackage.PackagePath
                        }
                        else{
                            $strCopy= CopyTestDataLocally $strPackageloc $TestData 0
                            If ($strCopy -ne 0){
                                WriteResultsToFile $logFile "Test data is not present for the rule $strRule at: $strPackageloc" $strCopy 0
                                "Test data is not present for the rule $strRule at: $strPackageloc" | Out-File $OutFilePath
                                $_.AppCompValidate_Status ="Fail"                              
                                return}
                        }
                                                
                        $strRuleCategory= GetRuleCategory $strRule
                        
                        $retval=Set-ASTestState -TestId $strRule -TestState 1 
                        
        
                        $PSOutFilePath= $LogsFolder+"\Appcompat_Output.txt"
                        If(Test-Path $PSOutFilePath)
                        {Remove-Item $PSOutFilePath -recurse -Force |out-null
                        }
        
                        ExecuteRules $strPackageLocation $strRule $strRuleCategory $PackageIDFlag $ExpectedError $ExpectedWarning $PSOutFilePath $OutFilePath
                        
                        If (Test-Path $PSOutFilePath)
                        {
                            IF ((Get-Content $PSOutFilePath) -eq $Null){$Actual_Result="Fail"}
                            else {$Actual_Result= Get-Content $PSOutFilePath}                            
                        }    
                        else{$Actual_Result="Fail"}
                        
                        $_.AppCompValidate_Status =$Actual_Result
                        WriteResultsToFile $logFile "Validation of results for the rule $strRule is :" $Actual_Result "Pass"                  
                       
                        $retval=Set-ASTestState -TestId $strRule -TestState 0 
                }
                else
                {
                        $OutFilePath = $LogsFolder +"\"+ $strRule + ".txt"
                        "Test data location not mentioned in the CSV for the rule # -" +$strRule | Out-File $OutFilePath
                        $_.AppCompValidate_Status ="Test data location not mentioned in the CSV. "
                        WriteResultsToFile $logFile "Test data location not mentioned in the CSV for the rule # - $strRule is :" 0 0
                }
        }                          
    
    $CSVcontent |Export-Csv -Path $csvPath -Force -NoTypeInformation    
    } 
 }

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: ExecuteRules($PackageLocation,$Rule,$strRuleCategory,$PackageIDFlag,$ExpectedErr,$ExpectedWarning,$PSOutFilePath,$OutFilePath)
  Description: Importing package, running specific rule for the package and validating with expected error or warning counts
  Author    : YojanaYarradoddi #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    
Function ExecuteRules($PackageLocation,$Rule,$strRuleCategory,$PackageIDFlag,$ExpectedErr,$ExpectedWarning,$PSOutFilePath,$OutFilePath)
{

    If ($PackageIDFlag -eq 0)
    {
        $ImportPackage = Invoke-ASImportPackage -PackagePath $PackageLocation

        If ($ImportPackage -like "*failed*")
        {                
            "Invoke-asimportPackage failed to import - Rule # " +$Rule | Out-File $OutFilePath
            return
        }
        ElseIf ($ImportPackage -eq $null)
        {
            "Invoke-asimportPackage returned a blank object - Rule # " +$Rule | Out-File $OutFilePath
            return
        }    
        $PkgId = $ImportPackage.RowId   
    }
    Else
    {
        $PkgId = $PackageIDFlag
    }    
    
    $ValidateResultSummary = Test-ASPackage -PackageId $PkgId

    If ($ValidateResultSummary.Stats.Count -eq 0)
    {
     "Test-ASPackage returned a blank object for rule # -" +$Rule | Out-File $OutFilePath
     return
    }
    $ValidateResultDetailed = Test-ASPackage -PackageId $PkgId -DetailedResults
 
#Validate with the Expected count
$nCount = $ValidateResultSummary.Stats.Count

for ($i=0; $i -le $nCount; $i++)
{

      If ($ValidateResultSummary.Stats.Item($i).Category -eq $strRuleCategory) 
      {  
            If ($ValidateResultSummary.Stats.Item($i).Errors -eq $ExpectedErr)
            {
                  If ($ValidateResultSummary.Stats.Item($i).Warnings -eq $ExpectedWarning) 
                  {

                    "Pass"| Out-File $PSOutFilePath -Append
                    "Status      : Pass" | Out-File $OutFilePath -Append                
                  }
                  else
                  {
                    "Fail"| Out-File $PSOutFilePath -Append
                    "Status      : Fail"| Out-File $OutFilePath -Append
                    "Status Desc : Fail - Mismatch with the Actual and Expected Warning count"| Out-File $OutFilePath -Append  
                  }   
            }
            else
            {
                    "Fail"| Out-File $PSOutFilePath -Append
                    "Status      : Fail"| Out-File $OutFilePath -Append
                    "Status Desc : Fail - Mismatch with the Actual and Expected count of Error, Warning"| Out-File $OutFilePath -Append
             }
           Break
           } 
       else
       {
            "Fail"|Out-File $PSOutFilePath -Append
            "Status      : Fail"| Out-File $OutFilePath -Append
            "Status Desc : Fail - Mismatch with the OsCategory names"| Out-File $OutFilePath -Append
            "Expected    :" + " " + $strRuleCategory| Out-File $OutFilePath -Append
            "Actual      :" + " " + $ValidateResultSummary.Stats.Item($i).Category| Out-File $OutFilePath -Append
            return
       }
}
  
#Append the Result of Execution to OutputFile
    #$ProductName = "Package          : " + $ImportPackage.ProductName
    #$ProductName | Out-File $OutFilePath -Append
    $PackageLoc = "Package Location         : " + $PackageLocation
    $PackageLoc | Out-File $OutFilePath -Append
$RuleID =  "Rule             : " + $Rule
$RuleID | Out-File $OutFilePath -Append
"***********************************************************************************"| Out-File $OutFilePath -Append
$ExpErr = "Expected Errors   :" + "  " + $ExpectedErr
$ExpWarn = "Expected Warnings :" + "  " + $ExpectedWarning
 
$ActuErr = "Actual Errors   :" + "  " + $ValidateResultSummary.Stats.Item($i).Errors
$ActuWarn = "Actual Warnings :" + "  " + $ValidateResultSummary.Stats.Item($i).Warnings

"" , $ExpErr , $ExpWarn , "" , $ActuErr , $ActuWarn | Out-File $OutFilePath -Append
" " , "Detailed Description" , "********************" , $ValidateResultDetailed.TestResults | Out-File $OutFilePath -Append
"-----------------------------------------------------------------------------------"| Out-File $OutFilePath -Append
}   

#---------------------------------------------------------------------------------------------------------------------------------------------------
<# Function SelectAllRules($catalogName, $TFlag)
Description: Selecting or Unselecting allRules in 'Select TeststoExecute' window
Input paramaeters: $catalogName: Database on which to select or unselect rules
                   $TFlag: 0 -for unselect 1- for Selecting all rules
output: 0 or -1
Author: YojanaYarradoddi
LastModifiedDate:
LastModifiedBy:
#>
#---------------------------------------------------------------------------------------------------------------------------------------------------

Function SelectAllRules($catalogName, $TFlag)

{
    $RQuery= "Update ASTEST SET TestStatus=$TFlag"
    $Result=ExecuteSQLQuery $RQuery $CatalogName
    return $Result
}

#--------------------------------------------------------------------------------------------------------------------------------------------------
#Publish Functions
#--------------------------------------------------------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: ExecuteSQLScript($SQLFilePath,$DBName)
  Description: Execute an SQL Query
  Input Parameters:
       $SQLFilePath - Path of the SQL file
       $DBName - CatalogName on which to run sql script
  Output Parameters - -1 for failure, 0 for success #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Adding Application Model data for Supersedence, Requirements, Detection Methods, Dependencies and Resturn Code tabs
#--------------------------------------------------------------------------------------------------------------------------------------------------


 Function AddSupersedence ($SqlFileFolder, $PkgId, $SupersedenceID, $CatalogName)
  {
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {       
        $SQLCode = Get-Content $file.FullName    
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)    
        $SQLCode =$SQLCode -replace("<SupersededPkgID>",$SupersedenceID)     
    
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName $CatalogName     
        WriteResultsToFile $logFile ("Adding Supersedence : " ) $Retval 0
    }
    
 }

 Function AddDependencies ($SqlFileFolder, $PkgId, $DependencyID, $CatalogName)
 {
    
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {       
        $SQLCode = Get-Content $file.FullName     
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)
        $SQLCode =$SQLCode -replace("<DepPkgID>",$DependencyID)    
                
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName $CatalogName   
        WriteResultsToFile $logFile ("Adding Dependencies : " ) $Retval 0
    }
 }

 Function AddDetectionMethod ($SqlFileFolder, $PkgID, $Catalogname)
 {    
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {       
        $SQLCode = Get-Content $file.FullName     
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)
              
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName  $CatalogName   
        WriteResultsToFile $logFile ("Adding DetectionMethods : " ) $Retval 0
    }
 }

 Function AddDeviceRequirements ($SqlFileFolder, $PkgID, $Catalogname)
 {
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {       
        $SQLCode = Get-Content $file.FullName     
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)
              
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName $CatalogName   
        WriteResultsToFile $logFile ("Adding DeviceRequirements : " ) $Retval 0
    }
 }


  Function AddUserRequirements ($SqlFileFolder, $PkgID, $Catalogname)
 {
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {       
        $SQLCode = Get-Content $file.FullName     
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)
              
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName $CatalogName   
        WriteResultsToFile $logFile ("Adding UserRequirements : " ) $Retval 0
    }
 }


  Function AddReturnCodes ($SqlFileFolder, $PkgID, $Catalogname)
 {
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {       
        $SQLCode = Get-Content $file.FullName     
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)
              
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName $CatalogName   
        WriteResultsToFile $logFile ("Adding ReturnCodes : " ) $Retval 0
    }
 }

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Updating Application Model data for Supersedence, Requirements, Detection Methods, Dependencies and Resturn Code tabs
#--------------------------------------------------------------------------------------------------------------------------------------------------


Function UpdateSupersedence ($SqlFileFolder, $PkgId, $SuperPkgID, $NewSuperPkgID, $CatalogName)
  {

    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {       
        $SQLCode = Get-Content $file.FullName    
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)    
        $SQLCode =$SQLCode -replace("<SupersededPkgID>",$SuperPkgID)
        if ($NewSuperPkgID -ne $Null)
        {
        $SQLCode =$SQLCode -replace("<NewSupersededPkgID>",$NewSuperPkgID)
        } 
            
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName $CatalogName     
        WriteResultsToFile $logFile ("Updating Supersedence : " ) $Retval 0
    }
    
 }

 Function UpdateDependencies ($SqlFileFolder, $PkgId, $DepPkgID, $NewDepPkgID, $CatalogName)
 {
    
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {       
        $SQLCode = Get-Content $file.FullName     
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)
        $SQLCode =$SQLCode -replace("<DepPkgID>",$DepPkgID)   
        if ($NewDepPkgID -ne $Null)
        {
        $SQLCode =$SQLCode -replace("<NewDepPkgID>",$NewDepPkgID)
        } 

        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName $CatalogName   
        WriteResultsToFile $logFile ("Updating Dependencies : " ) $Retval 0
    }
 }

 Function UpdateDetectionMethod ($SqlFileFolder, $PkgID, $Catalogname)
 {    
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {       
        $SQLCode = Get-Content $file.FullName     
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)
              
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName  $CatalogName   
        WriteResultsToFile $logFile ("Updating DetectionMethods : " ) $Retval 0
    }
 }


  Function UpdateDeviceRequirements ($SqlFileFolder, $PkgID, $Catalogname)
 {
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {   
        $SQLCode = Get-Content $file.FullName     
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)
              
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName $CatalogName   
        WriteResultsToFile $logFile ("Updating DeviceRequirements : " ) $Retval 0
    }
 }

  Function UpdateUserRequirements ($SqlFileFolder, $PkgID, $Catalogname)
 {
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {   
        $SQLCode = Get-Content $file.FullName     
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)
              
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName $CatalogName   
        WriteResultsToFile $logFile ("Updating UserRequirements : " ) $Retval 0
    }
 }

Function UpdateReturnCodes ($SqlFileFolder, $PkgID, $Catalogname)
 {
    $SQL_Files=Get-ChildItem -Path $SqlFileFolder –File
    Foreach($file in $SQL_Files)
    {   
        $SQLCode = Get-Content $file.FullName     
        $SQLCode =$SQLCode -replace("<PkgID>",$PkgID)
              
        set-content $file.FullName $SQLCode
        $Retval= ExecuteSQLScript $file.FullName $CatalogName   
        WriteResultsToFile $logFile ("Updating ReturnCodes : " ) $Retval 0
    }
 }

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: CreateDistributionConnection($Connectionname, $ConnectionType,$CatalogName,$ServerName, $Sitecode,$SharedPath)
    Description: adding Distribution Server Details in Options Window
    Input Parameters:
       $ConnectionName - Distribution Server Connection name to add in the options window
       $ConnectionType - DistributionServer Type like 'SCCM'
       $ServerName -Distribution Server Name 
       $Sitecode -Site of the distribution Server
       $SharedPath - Publish shared path
       $CatalogName - Catalog name for which to add distribution server details
#>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Function CreateDistributionConnection($Connectionname, $ConnectionType,$ServerName, $Sitecode,$SharedPath,$CatalogName)
{
  Set-ASConfigPlatform -ConnectionString "PROVIDER=SQLNCLI11;Data Source=$SQLServer;Initial Catalog=$CatalogName;Integrated Security=SSPI;"
    
  If($ConnectionType -eq 'SCCM')
  { 
    $Query= "select OID from ASCMSupportedPackageTypes Where PluginName='ConfigMgr Distribution Plugin'"
    $PlugID=ExecuteSQLQuery $Query $CatalogName
    
    New-ASDistributionConnection -Name $ConnectionName -PluginID $PlugID -DistributionWindowsAuthentication 1 -ServerAddress $ServerName -SiteCode $SiteCode -ShareWindowsAuthentication 1 -SharePath $SharedPath     
  }  
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: DistributeApplication($ConnectionName,$AppID,$TargetGroup)
   Description: Publishes application to SCCM
  Input Parameters:
       $ConnectionName - Distribution Server Connection name in the options window
       $AppID - Application id of publishing application
       $TargetGroup - SCCM target group to publish
  Output Parameters - 0 for success -1 for Failure #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Function DistributeApplication($ConnectionName,$AppID,$TargetGroup)
{   
 try{
        $result= Invoke-ASPublish -ConnectionName $ConnectionName -ApplicationID $AppID -TargetGroup $TargetGroup  -ErrorAction SilentlyContinue
   
        If($result.contains("success"))
        {
            return 0
        }
        else 
        {
            return -1
        }
    }
Catch{
        Add-Content -Path $logFile -Value "Unable to publish Application to SCCM"
        return -1
     }
}



#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: AS_GetSCCMAppID($CatalogName,$PkgId)
  Description: Fetch CI_UniqueID of application in SCCM from AS catalog
  Input Parameters:
       $DBName - AS Catalog Name
       $PkgID  - Package Id
  Output Parameters - SCCM ApplicationID #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function AS_GetSCCMAppID($CatalogName,$PkgId)
{    
    $ScopeID = ExecuteSQLQuery "select ScopeID from ASCMApplicationDeployment where Group_=(select ParentGroupCode from cstblGroupPackages where PkgRowID_ = $PkgId)" $CatalogName
    $ApplicationID = ExecuteSQLQuery "select ApplicationID from ASCMApplicationDeployment where Group_=(select ParentGroupCode from cstblGroupPackages where PkgRowID_ = $PkgId)" $CatalogName
    $Revision = ExecuteSQLQuery "select Revision from ASCMApplicationDeployment where Group_=(select ParentGroupCode from cstblGroupPackages where PkgRowID_ = $PkgId)" $CatalogName
        
    $AppId = $ScopeID +"/"+ $ApplicationID +"/"+ $Revision
    Return $AppId
}





#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: SCCM_GetAppDependencies($AppID, $sessionID)
  Description: Fetch Applicaiton Dependencies from AdminStudio Catalog using SQL Script
  Input Parameters:
       $sessionID - SCCMSessionID
       $AppID  - CI_UniqueID of application in SCCM
  Output Parameters - Dependency array
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function SCCM_GetAppDependencies($AppID,$sessionID)
{
             
       $DepList  = Invoke-Command -Session $sessionID -ScriptBlock{
       param([string] $AppID )           
              
       $App=Get-CMApplication | Where { $_.CI_UniqueID -eq $AppID }   
       $SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($App.SDMPackageXML))                     
       $DeploymentTypes=$SDMPackageXML.DeploymentTypes    
       $DepList=@()   
       
       $DT=$DeploymentTypes.Item(0)

       Foreach($Dep in $DT.Dependencies)
       {
                 For($i=0;$i -lt $Dep.Expression.Operands.Count;$i++)
                 {
                    $SupportedApp=Get-CMApplication | Where { $_.CI_UniqueID.Contains($Dep.Expression.Operands[$i].ApplicationLogicalName) } 
                    $App_SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($SupportedApp.SDMPackageXML))                     
                    $DepList += $Dep.Name+","+$SupportedApp.LocalizedDisplayName+","+$App_SDMPackageXML.Title+","+ $Dep.Expression.Operands[$i].EnforceDesiredState  #$App_SDMPackageXML.AutoInstall
                 }                                 
                                  
       }

            return $DepList
       } -ArgumentList $AppID

       return $DepList  
}



#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: SCCM_GetAppRequirements($AppID,$sessionID)
  Description: Fetch Applicaiton requirements from SCCM , designed for only one deployment type
  Input Parameters:
       $AppID - CI_UniqueID of Application in SCCM
       $sessionID - SCCMSessionID
  Output Parameters - Requirement array
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function SCCM_GetAppRequirements($AppID,$sessionID)
{
          
    $ReqArr = Invoke-Command -Session $sessionID -ScriptBlock{
       param([string] $AppID)
    
       $App=Get-CMApplication | Where { $_.CI_UniqueID -eq $AppID }   
       $SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($App.SDMPackageXML))                     
       $DeploymentTypes=$SDMPackageXML.DeploymentTypes       
       $req=@()

       Foreach($DT in $DeploymentTypes)
       {
            $Requirements=$dt.requirements

            Foreach($r in $Requirements)
            {
                $req += $r.Name                                 
            }
       }
       return $req        
    
    } -ArgumentList $AppID

    return $ReqArr  
} 




#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: SCCM_GetAppSupersedes($AppID,$sessionID)
  Description: Fetch Applicaiton Spersedes from SCCM , designed for only one deployment type
  Input Parameters:
       $AppID - CI_UniqueID of Application in SCCM
       $sessionID - SCCMSessionID
  Output Parameters - Requirement array
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function SCCM_GetAppSupersedes($AppID,$sessionID)
{
            
        $SupersedesList  = Invoke-Command -Session $sessionID -ScriptBlock{
        param(
            [string] $AppID            
            )     

           $App=Get-CMApplication | Where { $_.CI_UniqueID -eq $AppID } 
           $SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($App.SDMPackageXML))
           $DeploymentTypes=$SDMPackageXML.DeploymentTypes                
           $DT=$DeploymentTypes.Item(0)       
           $SuperAppList=@()  

           Foreach($Super in $DT.Supersedes)
           {
                $SuperAppId=$Super.Expression.ApplicationAuthoringScopeId+"/"+$Super.Expression.ApplicationLogicalName           
                $SuperApp=Get-CMApplication | Where { $_.CI_UniqueID.contains($SuperAppId) }
                $App_SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($SuperApp.SDMPackageXML))            
                $OldDT=$App_SDMPackageXML.DeploymentTypes.Item(0).title + " ["+$App_SDMPackageXML.DeploymentTypes.Item(0).Technology+"]"
                $ReplaceDT=$SDMPackageXML.DeploymentTypes.Item(0).title + " ["+$SDMPackageXML.DeploymentTypes.Item(0).Technology+"]"
            
                $SuperAppList += $SuperApp.LocalizedDisplayName +","+ $OldDT + ","+$ReplaceDT
           }

           $SuperAppList
        } -ArgumentList $AppID

        return $SupersedesList
}




#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: SCCM_GetDetectionMethods($AppID,$sessionID)
  Description: Fetch Application DetectionMethods from SCCM
  Input Parameters:
       $sessionID - SCCMSessionID
       $AppID  - CI_UniqueID of application in SCCM
  Output Parameters - Detection Methods array
  Author    : Rakesh Ramesh 
  Created Date:
  Last Modified Date:11/11/2016
  Last Modified by: Yojana (Added condition to retreive values of Script detection method)
  #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function SCCM_GetDetectionMethods($AppID,$sessionID)
{
    $DetectionArr=''

    $DetectionArr = Invoke-Command -Session $sessionID -ScriptBlock{
        param([string] $AppID)

        $App=''
        $SDMPackageXML=''
        $DetectionCol= @()
        $detectionObj=''
        $str=''

        $App=Get-CMApplication | Where { $_.CI_UniqueID -eq $AppID }   
        $SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($app.SDMPackageXML))                            
        
            
        If($SDMPackageXML.DeploymentTypes[0].Technology -eq 'Windows8App')
            {
                $str='Name: '+$SDMPackageXML.DeploymentTypes[0].Installer.IdentityName
                $DetectionCol += $str
                $str='Publisher: '+$SDMPackageXML.DeploymentTypes[0].Installer.IdentityPublisher
                $DetectionCol += $str
                $str='Version: '+$SDMPackageXML.DeploymentTypes[0].Installer.IdentityVersion
                $DetectionCol += $str
                $str='Resource Id: '+$SDMPackageXML.DeploymentTypes[0].Installer.IdentityResourceId
                $DetectionCol += $str
                $str='Processor architecture: '+$SDMPackageXML.DeploymentTypes[0].Installer.IdentityProcessorArchitecture
                $DetectionCol += $str 
            }
        ElseIf(($SDMPackageXML.DeploymentTypes[0].Installer.EnhancedDetectionMethod.Settings) -ne '')
        {
            Foreach($detectionObj in $SDMPackageXML.DeploymentTypes[0].Installer.EnhancedDetectionMethod.Settings)
            {            
                Switch($detectionObj.SourceType)
                {            
                    'MSI'{ 
                    $str= 'MSI ProductCode : '+ $detectionObj.ProductCode 
                    $DetectionCol += $str                
                    }

                    'File'{
                    $str= $detectionObj.Location
                    $DetectionCol += $str 
                    }

                    'Folder'{
                    $str= $detectionObj.Location 
                    $DetectionCol += $str 
                    }

                    'Registry'{
                    $str= [string]$detectionObj.RootKey +'\'+[string]$detectionObj.Key +'\'+[string]$detectionObj.ValueName + ' '+ [string]$detectionObj.ver
                    $DetectionCol += $str 
                    }
                }
            }
        }
        ElseIf (($SDMPackageXML.DeploymentTypes[0].Installer.DetectionScript) -ne '')
        {
            $Str = $SDMPackageXML.DeploymentTypes[0].Installer.DetectionScript.language
            $DetectionCol +=$str
            $str =$SDMPackageXML.DeploymentTypes[0].Installer.DetectionScript.runAS32bit
            $DetectionCol +=$str
            $str =$SDMPackageXML.DeploymentTypes[0].Installer.DetectionScript.Text
            $DetectionCol +=$str          
        } 
        return $DetectionCol
    
    } -ArgumentList $AppID
    return $DetectionArr            
 }

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: SCCM_GetReturnCodes($AppID,$sessionID)
  Description: Fetch Return Codes of an Application from SCCM
  Input Parameters:
       $sessionID - SCCMSessionID
       $AppID  - CI_UniqueID of application in SCCM
  Output Parameters - ReturnCodes array
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function SCCM_GetAppReturnCodes($AppID,$sessionID)
 {
    $ReturnCodes=''       

    $ReturnCodes = Invoke-Command -Session $sessionID -ScriptBlock{
        param([string] $AppID)
        
        $App=''
        $SDMPackageXML=''
        $ReturnCodes=@()  
        $ExitCodeClass=''         

        $App=Get-CMApplication | Where { $_.CI_UniqueID -eq $AppID }   
        $SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($app.SDMPackageXML))                     

        foreach($e in $SDMPackageXML.DeploymentTypes[0].Installer.ExitCodes)
        {
            if(([string]$e.Class -eq 'Success') -or ([string]$e.Class -eq 'Failure'))
            {
                $ExitCodeClass=[string]$e.Class + ' (no reboot)'
            }
            else 
            {
                $ExitCodeClass=[string]$e.Class 
            }
            $ReturnCodes += [string]$e.Code + ','+ $ExitCodeClass +','+ [string]$e.Name + ',' + [string]$e.Description
            $ExitCodeClass=''

        }
        
        return $ReturnCodes
    
    } -ArgumentList $AppID
    
      
    return $ReturnCodes
            
 }




#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: SCCM_GetContentTabProperties($AppID,$PropertyName,$sessionID)
  Description: Fetch Content Tab properties from SCCM
  Input Parameters:
       $sessionID - SCCMSessionID
       $AppID  - CI_UniqueID of application in SCCM
       $PropertyName - Property Name
  Output Parameters - Property Value
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 function SCCM_GetContentTabProperties($AppID,$PropertyName,$sessionID)
 {
    $PropertyValue=''       

    $PropertyValue = Invoke-Command -Session $sessionID -ScriptBlock{
        param([string] $AppID ,
        [string] $PropertyName)
        
        $App=''
        $SDMPackageXML=''
        $PropertyValue=''    

        $App=Get-CMApplication | Where { $_.CI_UniqueID -eq $AppID }   
        $SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($app.SDMPackageXML))                     
       
        Switch($PropertyName){

           'Use fallback source location for content'{
            $PropertyValue=@($SDMPackageXML.DeploymentTypes[0].Installer.Contents)[0].FallbackToUnprotectedDP
            }

           'Content location'{
            $PropertyValue= @($SDMPackageXML.DeploymentTypes[0].Installer.Contents)[0].Location
            }

           'Deployment option when client is on fast(LAN) network'{
            $PropertyValue= [string](@($SDMPackageXML.DeploymentTypes[0].Installer.Contents)[0].OnFastNetwork)
            }

            'Uninstall content settings'{
            $PropertyValue=$SDMPackageXML.DeploymentTypes[0].Installer.UninstallSetting
           
            }

           'Deployment option when client is on slow network'{
            $PropertyValue= [string](@($SDMPackageXML.DeploymentTypes[0].Installer.Contents)[0].OnSlowNetwork)
            
            }            

            'Enable peer-to-peer content distribution'{
            @($SDMPackageXML.DeploymentTypes[0].Installer.Contents)[0].PeerCache                  
            }

           'Allow client to share content on same subnet'{
           $PropertyValue=@($SDMPackageXML.DeploymentTypes[0].Installer.Contents)[0].PeerCache
           }

           'Persist content in the client cache'{
           $PropertyValue=@($SDMPackageXML.DeploymentTypes[0].Installer.Contents)[0].PinOnClient
           }

           'Load content to App-V cache'{
           $PropertyValue=$SDMPackageXML.DeploymentTypes[0].Installer.RequireLoad
           }

        }

        return $PropertyValue
    
    } -ArgumentList $AppID, $PropertyName
    
     
    return $PropertyValue
            
 }
   



#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: SCCM_GetProgramTabProperties($AppID,$PropertyName,$sessionID)
  Description: Fetch Program Tab properties from SCCM
  Input Parameters:
       $sessionID - SCCMSessionID
       $AppID  - CI_UniqueID of application in SCCM
       $PropertyName - Property Name
  Output Parameters - Property Value
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 function SCCM_GetProgramTabProperties($AppID,$PropertyName,$sessionID)
 {
    $PropertyValue=''       

    $PropertyValue = Invoke-Command -Session $sessionID -ScriptBlock{
        param([string] $AppID ,
        [string] $PropertyName)
        
        $App=''
        $SDMPackageXML=''
        $PropertyValue=''    

        $App=Get-CMApplication | Where { $_.CI_UniqueID -eq $AppID }   
        $SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($app.SDMPackageXML))                     
               
        Switch($PropertyName)
        {
           'Install command line'{
           $PropertyValue=$SDMPackageXML.DeploymentTypes[0].Installer.InstallCommandLine
           <#if(-not $PropertyValue)
           {
                $PropertyValue='Null'
           }#>
           }

           'Install folder'{
           $PropertyValue=$SDMPackageXML.DeploymentTypes[0].Installer.InstallFolder
           }

           'Uninstall command line'{
           $PropertyValue=$SDMPackageXML.DeploymentTypes[0].Installer.UninstallCommandLine
           <#if(-not $PropertyValue)
           {
                $PropertyValue='Null'
           } #>          
           }

           'Uninstall folder'{
           $PropertyValue=$SDMPackageXML.DeploymentTypes[0].Installer.UninstallFolder
           }

           'Repair Commad Line'{
           $PropertyValue=$SDMPackageXML.DeploymentTypes[0].Installer.RepairCommandLine
           }

           'Repair Folder'{
           $PropertyValue=$SDMPackageXML.DeploymentTypes[0].Installer.RepairFolder
           }
       
           'Run installation as 32-bit process on 64-bit client'{
           $PropertyValue=$SDMPackageXML.DeploymentTypes[0].Installer.RedirectCommandLine
           }

           'Installation source management product code'{
           $ProductCode=$SDMPackageXML.DeploymentTypes[0].Installer.ProductCode
           $UpdateProductCode=$SDMPackageXML.DeploymentTypes[0].Installer.SourceUpdateProductCode

               if($ProductCode)
               {
                    $PropertyValue =$ProductCode
               }
               else
               {
                    $PropertyValue =$UpdateProductCode
               }
           }
        }

        return $PropertyValue
    
    } -ArgumentList $AppID, $PropertyName
    
    
    return $PropertyValue
            
 }


#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: SCCM_GetUserExperienceTabProperties($AppID,$PropertyName,$sessionID)
  Description: Fetch UserExperience Tab properties from SCCM
  Input Parameters:
       $sessionID - SCCMSessionID
       $AppID  - CI_UniqueID of application in SCCM
       $PropertyName - Property Name
  Output Parameters - Property Value
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function SCCM_GetUserExperienceTabProperties($AppID,$PropertyName,$sessionID)
 {
    $PropertyValue=''       

    $PropertyValue = Invoke-Command -Session $sessionID -ScriptBlock{
        param([string] $AppID ,
        [string] $PropertyName)
        
        $App=''
        $SDMPackageXML=''
        $PropertyValue=''    

        $App=Get-CMApplication | Where { $_.CI_UniqueID -eq $AppID }   
        $SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($app.SDMPackageXML))                     
               
        Switch($PropertyName)
        {
            'Installation behavior'{
                $PropertyValue=[string]$SDMPackageXML.DeploymentTypes[0].Installer.ExecutionContext
             }

            'Logon requirement'{
                $PropertyValue=[string]$SDMPackageXML.DeploymentTypes[0].Installer.RequiresLogOn
                <#If($PropertyValue -eq '')
                {
                    $PropertyValue='Null'
                }#>
                <#$logonreq=[string]$SDMPackageXML.DeploymentTypes[0].Installer.RequiresLogOn
                if ($logonreq -eq '')
                {
                    $PropertyValue = "Whether or not a user is logged on"
                }
                elseif ($logonreq -eq "True")
                {
                    $PropertyValue = "Only When a user is logged on"
                }
                elseif ($logonreq -eq "False")
                {
                    $PropertyValue = "Only when no user is logged on"
                }#>
            }

            'Installation program visibility'{
                $PropertyValue=[string]$SDMPackageXML.DeploymentTypes[0].Installer.UserInteractionMode
            }

            'Enforce specific behavior'{
                $PropertyValue=[string]$SDMPackageXML.DeploymentTypes[0].Installer.PostInstallBehavior
                <#if($PropertyValue -eq 'BasedOnExitCode')
                {
                    $PropertyValue='Determine behavior based on return codes'
                }
                elseif($PropertyValue -eq 'NoAction')
                {
                    $PropertyValue='No specific action'
                }
                elseif($PropertyValue -eq 'ProgramReboot')
                {
                    $PropertyValue='The software installation program might force a device restart'
                }
                elseif($PropertyValue -eq 'ForceReboot')
                {
                    $PropertyValue='Configuration Manager client will force a mandatory device restart'
                }#>
            }

            'Maximum allowed run time (min)'{
                $PropertyValue=[string]$SDMPackageXML.DeploymentTypes[0].Installer.MaxExecuteTime
            }

            'Estimated installation time (min)'{
                $PropertyValue=[string]$SDMPackageXML.DeploymentTypes[0].Installer.ExecuteTime
            }

            'Allow user to view and interact with the program installation'{
                $PropertyValue=[string]$SDMPackageXML.DeploymentTypes[0].Installer.RequiresUserInteraction
            }
        }
        return $PropertyValue
    
    } -ArgumentList $AppID, $PropertyName
    
    return $PropertyValue
            
 }

 
 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: SCCM_GeneralInformationTabProperties($AppID,$PropertyName,$sessionID)
  Description: Fetch GeneralInformationTab Tab properties from SCCM
  Input Parameters:
       $sessionID - SCCMSessionID
       $AppID  - CI_UniqueID of application in SCCM
       $PropertyName - Property Name
  Output Parameters - Property Value
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function SCCM_GeneralInformationTabProperties($AppID,$PropertyName,$sessionID)
 {
    $PropertyValue=''           

    $PropertyValue = Invoke-Command -Session $sessionID -ScriptBlock{
        param([string] $AppID ,
        [string] $PropertyName)
        
        $App=''
        $SDMPackageXML=''
        $PropertyValue=''    

        $App=Get-CMApplication | Where { $_.CI_UniqueID -eq $AppID }   
        $SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($app.SDMPackageXML))                     
               
        Switch($PropertyName)
        {
            'Administrator Comments'{
                $PropertyValue=[String]$SDMPackageXML.DeploymentTypes[0].Application.Description
             }   

            'Manufacturer'{
                $PropertyValue=[String]$SDMPackageXML.DeploymentTypes[0].Application.Publisher
             }

            'SoftwareVersion'{
                $PropertyValue=[String]$SDMPackageXML.DeploymentTypes[0].Application.SoftwareVersion
            }

            'DatePublished'{                
                $date=[DateTime]$SDMPackageXML.DeploymentTypes[0].Application.ReleaseDate
                #$PropertyValue=$date.ToString("M/dd/yyyy")
                $PropertyValue=$date.ToString("M/d/yyyy")
            }

            'Install from Install Application task sequence'{
                $PropertyValue=[string]$SDMPackageXML.DeploymentTypes[0].Application.AutoInstall
            }

            'DistributionPriority'{
                $PropertyValue=$SDMPackageXML.DeploymentTypes[0].Application.HighPriority
                if($PropertyValue -eq 1)
                {
                    $PropertyValue='High'
                }
                elseif($PropertyValue -eq 2)
                {
                    $PropertyValue='Medium'
                }
                elseif($PropertyValue =3)
                {
                    $PropertyValue='Low'
                }
            }

            'Distribute to preferred DP'{
                $PropertyValue=[string]$SDMPackageXML.DeploymentTypes[0].Application.SendToProtectedDP
            }
                        
            'Prestaged DP Settings'{
                $DownloadDelta= $SDMPackageXML.DeploymentTypes[0].Application.DownloadDelta
                $AutoDistribute=$SDMPackageXML.DeploymentTypes[0].Application.AutoDistribute

                If($AutoDistribute -or $DownloadDelta)
                {
                    If($AutoDistribute)
                    {
                        $PropertyValue= 'Auto'  
                    }
                    else
                    {
                        $PropertyValue='OnlyContentChange'
                    }
                }
                Else
                {
                    $PropertyValue='ManualCopy'
                }
            }

            'Display supersedes information to user'{            
                $PropertyValue =[String]$SDMPackageXML.DeploymentTypes[0].Application.DisplaySupersedes
            }

            'DistributionPointGroups'{
            $PropertyValue ='Not Found in SCCM'
            }

            'LocalizedDisplayName'{
            $PropertyValue =[String]$App.LocalizedDisplayName
            }

            'LocalizedDescription'{
            $PropertyValue =[String]$SDMPackageXML.DeploymentTypes[0].Application.DisplayInfo[0].Description
            }

            'UserDocumentation'{
            $PropertyValue =[string]$SDMPackageXML.DeploymentTypes[0].Application.DisplayInfo[0].InfoUrl
            }

            'Icon File'{
            $PropertyValue ='Not Found in SCCM'
            }

            'Classification'{
            $PropertyValue ='Not Found in SCCM'
            }

            'Flexera Identifier'{
            $PropertyValue ='Not Found in SCCM'
            }
                                    
        }
        return $PropertyValue
    
    } -ArgumentList $AppID, $PropertyName
    
     
    return $PropertyValue
            
 }


 

 
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: Process_SCCMPublish_CSV($csvFilePath,$CatalogName,$PkgID,$sessionID)
  Description: Fetch Applicaiton Dependencies from AdminStudio Catalog using SQL Script
  Input Parameters:
       $csvFilePath  - CSV File Path
       $CatalogName  - AS catalog Name
       $PkgID  - Package ID
       $SessionID - SCCMSessionID
  Output Parameters - NA
  Author    : Rakesh Ramesh #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Process_SCCMPublish_CSV($csvFileLocation,$CatalogName,$PkgID,$Flag, $sessionID)
{
    $Retval=-1

    $AppID=AS_GetSCCMAppID $CatalogName $PkgId
    If(Test-Path $csvFileLocation)
    {
        $CSVcontent=Import-Csv $csvFileLocation                   

        $CSVcontent | ForEach-Object{ 
        if($Flag -eq 'Published')
        {
            
                #Fetching data from AS       
                if($_.AS_GET_API -or $_.AS_GET_SQL_QUERY)
                {
                    If($_.AS_GET_API -ne '<N.A>')
                    {
                        $_.AS_GET_API= [String]$_.AS_GET_API.replace("<PkgID>",$PkgID)          
                        $_.AS_VALUE = [String](ExecuteAPICmd $_.AS_GET_API $CatalogName)
                    }
                    elseIf($_.AS_GET_SQL_QUERY -ne '<N.A>')
                    {
                        $_.AS_GET_SQL_QUERY= [String]$_.AS_GET_SQL_QUERY.replace("<PkgID>",$PkgID)  
                        $_.AS_VALUE = [String](ExecuteSQLQuery $_.AS_GET_SQL_QUERY $CatalogName)
                    }
                    else
                    {
                        
                    }
                }
                else
                {
                    $_.PUBLISHSTATUS='Failed'
                }

                #Fetching Data from SCCM
                #if(([String]$_.PROPERTY -eq "Requirements") -or ([String]$_.PROPERTY -eq "Dependency") -or ([String]$_.PROPERTY -eq "Supersedence") -or ([String]$_.PROPERTY -eq "DetectionMethods") -or ([String]$_.PROPERTY -eq "ReturnCodes"))
                if($_.SCCM_GET_API)
                { 
                    if($_.SCCM_GET_API -ne '<N.A>')
                    {
                        $Result=''
                        $r=''
                        $FunctionCall=''
                        $FunctionCall=[string]$_.SCCM_GET_API            
                         $Result = Invoke-Expression $FunctionCall            
                        $_.SCCM_VALUE=""
                        Foreach($r in $Result)
                        {
                            $_.SCCM_VALUE += ([string]$r+"`n" )
                        }
                    }
                    else
                    {
                            $_.SCCM_VALUE='<N.A>'
                    }
                }
                else
                {
                    $_.PUBLISHSTATUS="Failed"
                    
                }

                #Compare AS and SCCM values
                
                    If(([string]$_.SCCM_VALUE).trim() -eq ([string]$_.AS_VALUE).Trim())
                    {
                        $_.PUBLISHSTATUS="Passed"
                    }
                    else
                    {
                        $_.PUBLISHSTATUS="Failed"
                        $Failure= $_.PROPERTY+" value mismatch with Application Manager and SCCM :Failed"
                        Add-Content -Path $logFile -Value $Failure
                    }
                                   
        }
        elseif($Flag -eq 'Republished')
        {
             #Fetching Data from SCCM  
                if($_.AS_GET_API -or $_.AS_GET_SQL_QUERY)
                {
                    If($_.AS_GET_API -ne '<N.A>')
                    {
                        $_.AS_GET_API= [String]$_.AS_GET_API.replace("<PkgID>",$PkgID)          
                        $_.NEW_AS_VALUE = [String](ExecuteAPICmd $_.AS_GET_API $CatalogName)
                    }
                    elseIf($_.AS_GET_SQL_QUERY -ne '<N.A>')
                    {
                        $_.AS_GET_SQL_QUERY= [String]$_.AS_GET_SQL_QUERY.replace("<PkgID>",$PkgID)  
                        $_.NEW_AS_VALUE = [String](ExecuteSQLQuery $_.AS_GET_SQL_QUERY $CatalogName)
                    }
                    
                }
                else
                {
                    $_.REPUBLISHSTATUS='Failed'
                }
                              
                if($_.SCCM_GET_API)
                { 
                    if($_.SCCM_GET_API -ne '<N.A>')
                    {
                        $FunctionCall=$_.SCCM_GET_API            
                        $Result = Invoke-Expression $FunctionCall            
                        $_.NEW_SCCM_VALUE=""
                        Foreach($r in $Result)
                        {
                            $_.NEW_SCCM_VALUE += ([string]$r+"`n" )
                        }
                    }
                    else
                    {
                            #$_.SCCM_VALUE="<N.A>"
                    }
                }
                else
                {
                    $_.REPUBLISHSTATUS="Failed"
                }

                #Compare AS and SCCM values
               
                    If(([string]$_.NEW_SCCM_VALUE).trim() -eq ([string]$_.NEW_AS_VALUE).Trim())
                    {
                        $_.REPUBLISHSTATUS="Passed"
                    }
                    else
                    {
                        $_.REPUBLISHSTATUS="Failed"
                        $Failure2= $_.PROPERTY+" value mismatch after republish with Application Manager and SCCM :Failed"
                        Add-Content -Path $logFile -Value $Failure2
                    }
                              
        }

        elseif($Flag -eq 'Update Properties')
        {
            if($_.AS_SET_API -or $_.AS_SET_SQL_QUERY)
                {
                try{
                    If($_.AS_SET_API -ne '<N.A>')
                    {
                        $_.AS_SET_API= [String]$_.AS_SET_API.replace("<PkgID>",$PkgID)          
                        $tmpValue = ExecuteAPICmd $_.AS_SET_API $CatalogName
                    }
                    elseIf($_.AS_SET_SQL_QUERY -ne '<N.A>')
                    {
                        $_.AS_SET_SQL_QUERY= [String]$_.AS_SET_SQL_QUERY.replace("<PkgID>",$PkgID)  
                        $tmpValue = ExecuteSQLQuery $_.AS_SET_SQL_QUERY $CatalogName
                    }
                    else
                    {
                    }
                  }
                  catch{
                    #WriteResultsToFile "Failed" 0 -1
                    WriteResultsToFile "General Exception $_" 0 -1
                    $Failure3= $_.PROPERTY+" updating value in Application Manager is :Failed"
                    Add-Content -Path $logFile -Value $Failure3
                  }
                }
                else
                {
                    $_.REPUBLISHSTATUS='Failed'
                }            
        }

        } #end of foreach 

        $CSVcontent |Export-Csv -Path $csvFileLocation -Force -NoTypeInformation
        $retval=0        
    } 
      
    return $retval      
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#  Function name: ProcessCSVColumnValue($csvFilePath,$ColumnName, $Value)

  Description: Search for specific value in columnname of CSV file
  Input Parameters:
       $csvFilePath  - CSV File Path
       $ColumnName  - CSV column name to search for specific value
       $Value -Value to search in column       
  Output Parameters - 0 for success -1 for failure #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Function ProcessCSVColumnValue($csvFilePath, $ColumnName, $Value)
{
$Results=-1
    if($csvFilePath){
        Import-Csv $csvFilePath |`
            ForEach-Object {
                $SearchColumn += $_.$ColumnName
            }
        If ($SearchColumn -ne '' -and $SearchColumn.contains($Value))
        { 
          $Results=0
        }
    }
    $Results
}
#-----------------------------------------------------------------------------------------
<#  Function name: SCCM_GetFramework($AppID,$s)

  Description: Fetch values of Framework tab, from a UWP\appx package present on SCCM
  Input Parameters:
       $sessionID - SCCMSessionID
       $AppID  - CI_UniqueID of application in SCCM
  Output Parameters - Framework array
  Author: Tathvik Tejas
  Created Date: 11/3/2016
  Modified By:----
  Modified Date:--- #>
#-----------------------------------------------------------------------------------------
function SCCM_GetFramework($AppID,$SessionID)
{
    $FrameworkOutput = ''

    $FrameworkOutput = Invoke-Command -Session $SessionID -ScriptBlock{param($AppID) 

    $App=''
    $SDMPackageXML=''
    $Framework=@()
    $ColumnName=''
    $ColumnObj = ''
    $Str = ''
    $Dependencies = ''
    $Dependency = ''

    $App=Get-CMApplication | Where { $_.CI_UniqueID -eq $AppID }
    $SDMPackageXML=([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($app.SDMPackageXML))

        $ColumnName = "Name","MinVersion","ProcessorArchitecture"
        $Dependencies = $SDMPackageXML.DeploymentTypes[0].Installer.Frameworks.Dependencies

        for($Dependency=0; $Dependency -lt $Dependencies.Count; $Dependency++)
        {
            foreach($ColumnObj in $ColumnName)
            {
              if($SDMPackageXML.DeploymentTypes[0].Installer.Frameworks.Dependencies[$Dependency].$ColumnObj)
              {
                    $Str= $SDMPackageXML.DeploymentTypes[0].Installer.Frameworks.Dependencies[$Dependency].$ColumnObj
                    $Framework+=$Str
              }
      
              else
              {
                    $Str='Unknown'
                    $Framework+=$Str
              }


            }
        }

    return $Framework
    }-ArgumentList $AppID

return $FrameworkOutput
}

#-----------------------------------------------------------------------------------------
<#  Function name: RemoveSCCMApplication($PkgID,$SessionID)

  Description: This function is to delete applications present on SCCM, that were published from Application Manager.
  Input Parameters:
      $PkgID  - Pkg RowID of any application imported into Application Catalog [this parameter could be a single PkgID or an array of PkgIDs]
      $SessionID – is the SCCM powershell SessionID
  Output– None, instead results are written to the UI and log file.
  Author: Yojana,Tathvik Tejas
  Created Date: 11/14/2016
  Modified By:----
  Modified Date:--- #>
#-----------------------------------------------------------------------------------------
Function RemoveSCCMApplication($PkgID, $SessionID) 
{
    $id='' #local variables
    $result = ''
    $AppID = ''
    $OutputArray = @()
    $Output = ''
    $NameArray = @()
    $PkgName = ''
    $AppID = @(foreach($Pkg in $PkgID){AS_GetSCCMAppID $CatalogName $Pkg})
    foreach($id in $AppID)
    {
        Invoke-Command -Session $SessionID -ScriptBlock{param([string] $id)
        $App=''   #remote variables
        $CMID=''
        $CID=''
        $Name=''
        $removeapp = -1
            try
            { 
            $App = Get-CMApplication | Where { $_.CI_UniqueID -eq $id}
            $Name = $app.LocalizedDisplayName 
            $CMID=$App.CI_ID
            Remove-CMApplication -Id $CMID -Force
            #Write-host "Deleting $Name from SCCM was successful!"
            $removeapp = 0
            }
            catch
            {
            #Write-host "Failed to remove application from SCCM"
            }
        }-ArgumentList $id #end of script block
    $OutputArray+=Invoke-Command -Session $SessionID -ScriptBlock{$removeapp}
    $NameArray+=Invoke-Command -Session $SessionID -ScriptBlock{$Name}
     } 
   for($Output = 0; $Output -lt $OutputArray.count; $Output++)
   {
        $PkgName = $NameArray.Item($Output)
        if($OutputArray.Item($Output) -eq 0)
        {
            Add-Content -Path $logFile -Value "Application was succesfully deleted: $PkgName" 
        }
        else
        { 
            Add-Content -Path $logFile -Value "Failed to delete application"

        }
   }
}
#-----------------------------------------------------------------------------------------
<# Function name: Write-Header ($TestCaseName)
  Description: To write Header of each test case name while writing output to main log
  Input Parameters:
       $TestcaseName - Testcase Name
  Output Parameters - Adding testcase name along with time
  Author: Yojana
  Created Date: 17/8/2016
  Last Modified By:----
  Last Modified Date:--- #>
#-----------------------------------------------------------------------------------------
function Write-Header ($TestCaseName)
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' ['+$TestCaseName+']'
    return $Header
}

#-----------------------------------------------------------------------------------------
<# Function name: SCCM_GetAppDistripointGroup($pkgID,$SCCMServerName,$SCCMSiteCode,$sessionID)
  Description: To find the specified application is added to Distribution Point Group
  Input Parameters:
       $APPID - SCCM Application ID
       $SCCMServerName - SCCM Computer name
       $SCCMSiteCode - SCCM site code
       $sessionID - Session id of SCCM
  Output Parameters - return SCCMDistributionPointGroup if package is added to Distribution point group
                      return Null if package is not added to Distribution point group
  Author: Yojana
  Created Date: 24/11/2016
  Last Modified By:----
  Last Modified Date:--- #>
#-----------------------------------------------------------------------------------------

Function SCCM_GetAppDistripointGroup($AppID,$SCCMServerName,$SCCMSiteCode,$sessionID)
{
    $DPGroupName= ''
      
    $DPGroupName = Invoke-Command -Session $sessionID -ScriptBlock{param($AppID, $SCCMServerName, $SCCMSiteCode) 

        $SCCMNameSpace= "root\sms\site_$SCCMSiteCode"
        $GroupID= ''
        $GroupName= ''
        $Id=$AppID.Split('/')
        $SCCMAppID=  $Id[0] + '/' + $Id[1]
        
        $GroupID= (Get-WmiObject -Namespace $SCCMNameSpace -query "select * from sms_dpgroupcontentinfo" -ComputerName $SCCMServerName | Where{$_.ObjectID -eq $SCCMAppID}).GroupId
        $GroupName=(Get-WmiObject -Namespace $SCCMNameSpace -query "select * from sms_Distributionpointgroup where GroupID='$GroupID'" -ComputerName $SCCMServerName).Name
            <#If($GroupName){   
                return $GroupName}
                else{
                $GroupName  ='Null'
                return $GroupName
            }#>
            return $GroupName
        } -ArgumentList $AppID, $SCCMServerName, $SCCMSiteCode 

return $DPGroupName
}

<#---------------------------------------------------------------------------------------------------------------------------------
FunctionName: ShareFolder ($FolderPath)
Description: This function shares a local folder by assigning 'full control' to 'everyone' group.
If a folder is existing, then it is shared else a folder is created in the provided path and is then shared.
  Input Parameters: $FolderPath - Path of the folder that is to be shared.
  Output Parameters - 0 if passed, -1 if failed
  Example: ShareFolder "C:\test data"
  Author: Tathvik Tejas
  Created Date: 11/21/2016
  Modified By:----
  Modified Date:--- 
  ---------------------------------------------------------------------------------------------------------------------------------#>
Function ShareFolder ($FolderPath)
{
    $ShareFolder = -1
    $FolderName = ''
    $Share = ''
    $Folder = ''
    $ShareCheck = ''
    
    try{     
            if(!($Folder =Test-Path -Path $FolderPath)) #create folder if not present
            {
            $Folder = New-Item -Path $FolderPath -ItemType "Directory"
            }  
    
            if($Folder)
            {
               $Share = Split-Path -Path $FolderPath -Leaf
               $FolderName = "'$Share'"
               if(!(Get-WmiObject -Class Win32_Share -Filter "Name = $FolderName")) #check if folder is already shared.
                {
                   $Sharing=net share "$share=$FolderPath" "/Grant:EveryOne,Full" /unlimited /cache:none #Share folder
                   $ShareFolder = 0
                   return $ShareFolder 
                }
                else {      
                    $ShareFolder = 0          
                    return $ShareFolder
                }
            }
            else {
                return $ShareFolder
            }
        }

   catch{
            Add-Content -Path $logFile -Value "Error attempting to share folder $FolderPath"
                return $ShareFolder   
         }
}

<#---------------------------------------------------------------------------------------------------------------------------------
  FunctionName: UnShareFolder($FolderPath)  
  Description: This function unshares the local folder provided in a path.
  Input Parameters: $FolderPath - Path of the folder that is to be shared.
  Output Parameters - 0 if passed, -1 if failed
  Example: UnShareFolder "C:\test data"
  Author: Tathvik Tejas
  Created Date: 11/21/2016
  Modified By:----
  Modified Date:--- 
 ---------------------------------------------------------------------------------------------------------------------------------#>

Function UnShareFolder($FolderPath)
{
    $UnShareFolder = -1
    $Share = ''
    $FolderName = ''
    $UnShare = ''
    
    $Share = Split-Path -Path $FolderPath -Leaf
    $FolderName = "'$Share'"
    
        if(!(Test-Path -Path $FolderPath)) #return if folder isn't present
        {
            
            Add-Content -Path $logFile -Value "Folder $FolderName wasn't present in the provided path."
            return $UnShareFolder
        }
        elseif(!($UnShare = Get-WmiObject -Class Win32_Share -Filter "Name = $FolderName")) #return if folder is present but unshared.
        {
            $UnShareFolder = 0
            return $UnShareFolder   
        }
        else
        {   #unshare if folder is present and shared.
            $output =$UnShare.Delete() 
            if(($ReturnValue =$output.ReturnValue) -eq 0)
            {
                $UnShareFolder = 0
                return $UnShareFolder              
            }
            else
            {
                return $UnShareFolder
            }             
            
        }        
    }

 #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: ExecuteTestASConflicts_BP($CatalogName,$strTestCaseFolder,$csvPath,$logfile)
  Description: This function processes to run best practice tests based on CSV and writes the final results in to the same
  Input Parameters: 
  $CatalogName- Name of the Catalog in which the packages should get import and tests should run
  $strTestCaseFolder- Path of the Project folder where CSVs, Testdata, Logs folders reside
  $csvPath-Path of the CSV file
  $logfile- Path of the testcase logfile
  Output Parameters:NA
  Author: Chiranjeevi M
  Created Date: 11/22/2016
  Last Modified By:----
  Last Modified Date:--- 
#>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
Function ExecuteTestASConflicts_BP($CatalogName,$strTestCaseFolder,$csvPath,$logfile)
{
 
$LogsFolder=$strTestCaseFolder+"\Logs"
New-Item -Path $LogsFolder -ItemType Directory -Force | out-null
 
$TestData=$strTestCaseFolder+"\TestData"
New-Item -Path $TestData -ItemType Directory -Force | out-null
 
If(Test-Path $csvPath)
    {
        $CSVcontent=Import-Csv $csvPath
        $RetVal=0
        $CSVcontent | ForEach-Object{   
        $strPackageloc= $_.Package_Location
        $strRule= $_.Rule
        $strDeploymentType=$_.DeploymentType
        $strPackageName=$_.Package_Name
        $ExpectedError=$_.ExpectedErr
        $ExpectedWarning=$_.ExpectedWarning
        $ExpectedResolvable=$_.ExpectedResolvable
         
                If ($strPackageloc)
                { 
                        $strPath=Split-path $strPackageloc -leaf
                        $strPackage=$strPackageName+"."+$strDeploymentType
                        $strPackageLocation= $TestData+"\"+$strPath+"\"+$strPackage

                        $OutFilePath = $LogsFolder +"\"+ $strRule + ".txt"
                                                
                        $PackageIDFlag=0                                          
 
                        $strSQLQuery =  "select Rowid from cstblpackage where OriginalMsiFileName='$strPackage'"
                        $PackageRowIDExist = ExecuteSQLQuery $strSQLQuery $CatalogName
                        if ($PackageRowIDExist -ge 0)
                           {
                            $PackageIDFlag=$PackageRowIDExist
                            $oPackage = Get-ASPackage -PackageId $PackageIDFlag
                            $strPackageLocation= $oPackage.PackagePath
                           }
                        else
                           {
                            $strCopy= CopyTestDataLocally $strPackageloc $TestData 0
                            If ($strCopy -ne 0)
                              {
                                WriteResultsToFile $logFile "Test data is not present for the rule $strRule at: $strPackageloc" $strCopy 0
                                "Test data is not present for the rule $strRule at: $strPackageloc" | Out-File $OutFilePath
                                $_.BestPracticeValidate_Status ="Fail"
                                return
                              }
                           }
                                                
                        #$strRuleCategory= GetRuleCategory $strRule
                        $retval=Set-ASTestState -TestId $strRule -TestState 1
        
                        $PSOutFilePath= $LogsFolder+"\BestPractices_Output.txt"
                        If(Test-Path $PSOutFilePath){
                        Remove-Item $PSOutFilePath -recurse -Force |out-null}
         
                        #ExecuteBPRules $strPackageLocation $strRule $strRuleCategory $PackageIDFlag $ExpectedError $ExpectedWarning $ExpectedResolvable $PSOutFilePath $OutFilePath
                        ExecuteBPRules $strPackageLocation $strRule $PackageIDFlag $ExpectedError $ExpectedWarning $ExpectedResolvable $PSOutFilePath $OutFilePath
                        
                        If (Test-Path $PSOutFilePath)
                        {
                            IF ((Get-Content $PSOutFilePath) -eq $Null){
                            $Actual_Result="Fail"}
                            else {
                            $Actual_Result= Get-Content $PSOutFilePath}                            
                        }    
                        else{
                        $Actual_Result="Fail"}
                        $_.BestPracticeValidate_Status =$Actual_Result
                        WriteResultsToFile $logFile "Validation of results for the rule $strRule is :" $Actual_Result "Pass" 
                                         
                        #unselecting the rules 
                        $retval=Set-ASTestState -TestId $strRule -TestState 0
                }
                else
                {
                        $OutFilePath = $LogsFolder +"\"+ $strRule + ".txt"
                        "Test data location not mentioned in the CSV for the rule # -" +$strRule | Out-File $OutFilePath
                        $_.BestPracticeValidate_Status ="Test data location not mentioned in the CSV. "
                        WriteResultsToFile $logFile "Test data location not mentioned in the CSV for the rule # - $strRule is :" 0 0
                }               
        }                            
    
    $CSVcontent |Export-Csv -Path $csvPath -Force -NoTypeInformation    
    } 
 }
 
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: ExecuteBPRules($PackageLocation,$Rule,$strRuleCategory,$PackageIDFlag,$ExpectedErr,$ExpectedWarning,$ExpectedResolvable,$PSOutFilePath,$OutFilePath)
  Description: This Function Imports packages, runs best practice rules on the imported packages and validates the expected error,warning, resolvable counts
  Input Parameters:
  $PackageLocation- Location of the package
  $Rule- Name of the Rule
  $PackageIDFlag- Package ID flag value to import a package or not
  $ExpectedErr- Expected Error Count
  $ExpectedWarning- Expected Warning count
  $ExpectedResolvable- Expected Resolvable count
  $PSOutFilePath- Temporary Log file path to define the over status of the running of rule
  $OutFilePath- Creates text file with rule number, contains detailed results of test after running
  Output Parameters :NA
  Created Date: 11/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
#Function ExecuteBPRules($PackageLocation,$Rule,$strRuleCategory,$PackageIDFlag,$ExpectedErr,$ExpectedWarning,$ExpectedResolvable,$PSOutFilePath,$OutFilePath)
Function ExecuteBPRules($PackageLocation,$Rule,$PackageIDFlag,$ExpectedErr,$ExpectedWarning,$ExpectedResolvable,$PSOutFilePath,$OutFilePath)
{
    $PkgId=0
 
    If ($PackageIDFlag -eq 0)
    {
        $ImportPackage = Invoke-ASImportPackage -PackagePath $PackageLocation
 
        If ($ImportPackage -like "*failed*")
        {                
            "Invoke-asimportPackage failed to import - Rule # " +$Rule | Out-File $OutFilePath
            return
        }
        ElseIf ($ImportPackage -eq $null)
        {
            "Invoke-asimportPackage returned a blank object - Rule # " +$Rule | Out-File $OutFilePath
            return
        }    
        $PkgId = $ImportPackage.RowId   
    }
    Else
    {
        $PkgId = $PackageIDFlag
    }    
    
    $ValidateResultSummary = Test-ASConflicts -PackageId $PkgId
 
    # Getting the total error and warning counts
    $ECount=0
    $WCount=0
    $ResCount=0 
     
    If ($ValidateResultSummary.ConflictResults.Count -eq 0)
    {
     if(($ECount -eq $ExpectedErr) -And ($WCount -eq $ExpectedWarning))
         {
         "No Conflicts found for the rule as expected # -" +$Rule | Out-File $OutFilePath
       
          "Pass"| Out-File $PSOutFilePath -Append
          "Status: Pass" | Out-File $OutFilePath -Append
          return
         }
     else{
            "Fail"| Out-File $PSOutFilePath -Append
            "No Conflicts found for the rule # -" +$Rule | Out-File $OutFilePath
            "Status: Fail" | Out-File $OutFilePath -Append
          }
            
    }
 
  Else
    {
      $Len=$ValidateResultSummary.ConflictResults.Count 
      $Result=$ValidateResultSummary.ConflictResults
  
         For ($i=0; $i -le $Len-1 ; $i++)
            {
      
              $temp=$Result.item($i).Severity
 
 
                  If ($temp -eq "Error")
                   { 
                    $ECount++              
                   }     
          
              ElseIf($temp -eq "Warning")
                   {
                     $WCount++
                   }            
           }
 
 $ResCount=ExecuteSQLQuery "select Count(*) from cstblConflictResults where PkgRowID_=$PkgId and CARDRule <>' '" $CatalogName
      
     If ($ECount -eq $ExpectedErr)
     {
            If ($WCount -eq $ExpectedWarning) 
            {
                  if($ResCount -eq $ExpectedResolvable)
                   {
                    "Pass"| Out-File $PSOutFilePath -Append
                    "Status : Pass" | Out-File $OutFilePath -Append
                   }
                else
                   {
                    "Fail"| Out-File $PSOutFilePath -Append
                    "Status : Fail"| Out-File $OutFilePath -Append
                    "Status Desc : Fail - Mismatch with the Actual and Expected Resolvable count"| Out-File $OutFilePath -Append 
                   }
 
             }
            else
            {   
                if($ResCount -eq $ExpectedResolvable)
                {
                "Fail"| Out-File $PSOutFilePath -Append
                "Status : Fail"| Out-File $OutFilePath -Append
                "Status Desc : Fail - Mismatch with the Actual and Expected Warning count"| Out-File $OutFilePath -Append 
                }
                else
                {
                "Fail"| Out-File $PSOutFilePath -Append
                "Status : Fail"| Out-File $OutFilePath -Append
                "Status Desc : Fail - Mismatch with the Actual and Expected Warning and Resolvable counts"| Out-File $OutFilePath -Append 
                }
  
            }
    }
    Else 
    {
        If ($WCount -eq $ExpectedWarning)
            {
              if($ResCount -eq $ExpectedResolvable)
              {
 
                "Fail"| Out-File $PSOutFilePath -Append
                "Status : Fail"| Out-File $OutFilePath -Append
                "Status Desc : Fail - Mismatch with the Actual and Expected Error count"| Out-File $OutFilePath -Append 
              }
              else
              {
                "Fail"| Out-File $PSOutFilePath -Append
                "Status : Fail"| Out-File $OutFilePath -Append
                "Status Desc : Fail - Mismatch with the Actual and Expected Error and Resolvable counts "| Out-File $OutFilePath -Append 
              }
 
            }
        Else
         {    if($ResCount -eq $ExpectedResolvable)
              {
                "Fail"| Out-File $PSOutFilePath -Append
                "Status : Fail"| Out-File $OutFilePath -Append
                "Status Desc : Fail - Mismatch with the Actual and Expected Error and Warning counts"| Out-File $OutFilePath -Append 
              }
              else
              {
              
                "Fail"| Out-File $PSOutFilePath -Append
                "Status : Fail"| Out-File $OutFilePath -Append
                "Status Desc : Fail - Mismatch with the Actual and Expected Error, Warning, and Resolvable counts"| Out-File $OutFilePath -Append 
              }
 
         }
     }   
}
 
#Append the Result of Execution to OutputFile 
$PackageLoc = "Package Location : " + $PackageLocation
$PackageLoc | Out-File $OutFilePath -Append
$RuleID =  "Rule : " + $Rule
$RuleID | Out-File $OutFilePath -Append
"***********************************************************************************"| Out-File $OutFilePath -Append
$ExpErr = "Expected Errors     :" + "  " +$ExpectedErr
$ExpWarn = "Expected Warnings   :" + "  " +$ExpectedWarning
$ExpRes = "Expected Resolvable :" + "  " +$ExpectedResolvable
 
$ActuErr = "Actual Errors     :" + "  " +$ECount
$ActuWarn = "Actual Warnings   :" + "  " +$WCount
$ActuRes = "Actual Resolvable :" + "  " +$ResCount
 
 
"" , $ExpErr , $ExpWarn , $ExpRes , "" , $ActuErr , $ActuWarn , $ActuRes | Out-File $OutFilePath -Append
" " , "Detailed Description" , "********************" , $Result | Out-File $OutFilePath -Append
"-----------------------------------------------------------------------------------"| Out-File $OutFilePath -Append
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#FunctionName: ExecuteTestASConflicts($catalogName,$TestCaseFolder,$csvFileLocation,$logfile)  
Description: This function runs Conflict rules on Packages by processing the csv.
Input Parameters: 
$catalogName - Catalog Name.
$TestCaseFolder - TestCase Folder Path.
$ csvFileLocation - CSV file location.
$logfile - Log file Path.
Output Parameters - 
 Author: Manu A V
Created Date: 14-12-2016
Modified By:
Modified Date:#>
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Function ExecuteTestASConflicts($catalogName,$strTestCaseFolder,$csvPath,$logfile)
{

$LogsFolder=$strTestCaseFolder+"\Logs"
New-Item -Path $LogsFolder -ItemType Directory -Force | out-null

$TestData=$strTestCaseFolder+"\TestData"
New-Item -Path $TestData -ItemType Directory -Force | out-null

    If(Test-Path $csvPath)
      {
        $CSVcontent=Import-Csv $csvPath
        $RetVal=0
        $CSVcontent | ForEach-Object{   
        $strsourcePackageloc= $_.Source_Package_Location       
        $strtargetPackageloc= $_.Target_Package_Location   
        $strRule= $_.Rule
        $strsourcePkg=$_.Source_Package_Name
        $strtargetPkg=$_.Target_Package_Name
        $ExpectedError=$_.ExpectedErr
        $ExpectedWarning=$_.ExpectedWarning
        $ExpectedFixables=$_.ExpectedFixables

            If ($strsourcePackageloc -and $strtargetPackageloc)
            {
                  $SourcePath=Split-path $strsourcePackageloc -leaf
                  $targetPath=Split-path $strtargetPackageloc -leaf               
                  $strsourcePkgLocation= $TestData+"\"+$SourcePath+"\"+$strsourcePkg
                  $strtargetPkgLocation= $TestData+"\"+$targetPath+"\"+$strtargetPkg                
                  $sourcePackageIDFlag=0                                          
                  $targetPackageIDFlag=0

                  $OutFilePath = $LogsFolder +"\"+ $strRule + ".txt"

                  $strCopy1=CopyTestDataLocally $strsourcePackageloc $TestData 0
                  $strCopy2=CopyTestDataLocally $strtargetPackageloc $TestData 0 
                                                            
                  if (($strCopy1 -ne 0) -Or ($strCopy2 -ne 0))
                  {
                        $Actual_Result="Fail"
                        WriteResultsToFile $logFile "Test data is not present for the rule $strRule" -1 0                    
                        "Test data is not present for the rule $strRule" | Out-File $OutFilePath
                        $_.ConflictsValidate_Status =$Actual_Result
                        return
                   }

                   $retval=Set-ASTestState -TestId $strRule -TestState 1 
                   
                   $PSOutFilePath= $LogsFolder+"\ConflictsOutput.txt"
                   If(Test-Path $PSOutFilePath)
                    {
                        Remove-Item $PSOutFilePath -recurse -Force |out-null
                    }
                                 
                   ExecuteConflictRules $strsourcePkgLocation $strtargetPkgLocation $strRule $sourcePackageIDFlag $targetPackageIDFlag $ExpectedError $ExpectedWarning $ExpectedFixables $PSOutFilePath $OutFilePath
                        
                   If (Test-Path $PSOutFilePath)
                   {
                         IF ((Get-Content $PSOutFilePath) -eq $Null){$Actual_Result="Fail"}
                         else{$Actual_Result= Get-Content $PSOutFilePath}
                   }                                                           
                   else {$Actual_Result="Fail"} 

                   $_.ConflictsValidate_Status = $Actual_Result
                   WriteResultsToFile $logFile "Validation of results for the rule $strRule is :" $Actual_Result "Pass"                  
                  
                   #unselecting the str rules 
                   $retval=Set-ASTestState -TestId $strRule -TestState 0                                                                          
              }             
            else{
                    $OutFilePath = $LogsFolder +"\"+ $strRule + ".txt"
                    "Test data location not mentioned in the CSV for the rule # -" +$strRule | Out-File $OutFilePath
                    $_.ConflictsValidate_Status ="Test data location not mentioned in the CSV. "
                    WriteResultsToFile $logFile "Test data location not mentioned in the CSV for the rule # - $strRule is :" 0 0 
            }
       }
                           
    $CSVcontent |Export-Csv -Path $csvPath -Force -NoTypeInformation
    }  
 }       
 #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#FunctionName: ExecuteConflictRules($strsourcePkgLocation,$strtargetPkgLocation,$Rule,$sourcePackageIDFlag,$targetPackageIDFlag,$ExpectedError,$ExpectedWarning,$ExpectedFixables,$PSOutFilePath,$OutFilePath)  
  Description: This function runs Conflict rules on Packages and validates the Actual results with the Expected results.
  Input Parameters: 
  $strsourcePkgLocation - Source Package Location
  $strtargetPkgLocation - Target Package Location
  $Rule - Rule Number
  $sourcePackageIDFlag - source package Row id 
  $targetPackageIDFlag - target package Row id
  $ExpectedError - Expected Error count
  $ExpectedWarning - Expected Warning count
  $ExpectedFixables - Expected Fixable count
  $PSOutFilePath - Temporary Log file path to define the over status of the running of rule 
  $OutFilePath - Creates text file with rule number, contains detailed results of test after running 
  Output Parameters - 0 if passed, -1 if failed
  Author: Manu A V
  Created Date: 14-12-2016
  Modified By:
  Modified Date:#>
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Function ExecuteConflictRules($strsourcePkgLocation,$strtargetPkgLocation,$Rule,$sourcePackageIDFlag,$targetPackageIDFlag,$ExpectedError,$ExpectedWarning,$ExpectedFixables,$PSOutFilePath,$OutFilePath)
{
    If ($sourcePackageIDFlag -eq 0)
    {
        $srcImportPackage = Invoke-ASImportPackage -PackagePath $strsourcePkgLocation
        
        If ($srcImportPackage -like "*failed*")
        {                
            "Invoke-asimportPackage failed to import - Rule # " +$Rule | Out-File $OutFilePath
            return
        }
        ElseIf ($srcImportPackage -eq $null)
        {
            "Invoke-asimportPackage returned a blank object - Rule # " +$Rule | Out-File $OutFilePath
            return
        }    
        $srcPkgId = $srcImportPackage.RowId 
    }
    Else
    {
        $srcPkgId = $sourcePackageIDFlag
    } 
    
    If ($targetPackageIDFlag -eq 0)
    {
    $targetImportPackage = Invoke-ASImportPackage -PackagePath $strtargetPkgLocation

    If ($targetImportPackage -like "*failed*")
        {                
            "Invoke-asimportPackage failed to import - Rule # " +$Rule | Out-File $OutFilePath
            return
        }
        ElseIf ($targetImportPackage -eq $null)
        {
            "Invoke-asimportPackage returned a blank object - Rule # " +$Rule | Out-File $OutFilePath
            return
        }    
        $targetPkgId = $targetImportPackage.RowId  
    }
    Else
    {
        $targetPkgId = $targetPackageIDFlag
    }
    
    $ValidateResultSummary = Test-ASConflicts -PackageId $srcPkgId -TargetPackageIDs $targetPkgId  
    
    $ECount=0
    $WCount=0
    $Resolvables=ExecuteSQLQuery "select Count(*) from cstblConflictResults where PkgRowID_=$srcPkgId and CARDRule <>' '" $CatalogName
    
    If ($ValidateResultSummary.ConflictResults.Count -eq 0)
    {
        If($ExpectedError -eq 0 -and $ExpectedWarning -eq 0)
        {
         "Test-ASConflicts returned a blank object as expected for rule # -" +$strRule | Out-File $OutFilePath
         "Pass"| Out-File $PSOutFilePath -Append
         "Status      : Pass" | Out-File $OutFilePath -Append
         "Status Desc : Pass - No conflicts"| Out-File $OutFilePath -Append 
         return
        } 
        else
        {
         "Test-ASConflicts returned a blank object for rule # -" +$strRule | Out-File $OutFilePath
         "Fail"| Out-File $PSOutFilePath -Append
         "Status      : Fail"| Out-File $OutFilePath -Append
         "Status Desc : Fail - Mismatch with the Conflicts count"| Out-File $OutFilePath -Append 
        }
    }
    Else
    {
        #Validating Actual Count with the Expected count
        $Len=$ValidateResultSummary.ConflictResults.Count
        $Result=$ValidateResultSummary.ConflictResults
        For ($i=0; $i -le $Len-1 ; $i++)
        {      
                $temp=$Result.item($i).Severity

                    If ($temp -eq "Error")
                    { 
                        $ECount++}     
          
                    ElseIf($temp -eq "Warning")
                     {
                         $WCount++}   
        }
        
        If ($ECount -eq $ExpectedError)
        {
            If ($WCount -eq $ExpectedWarning) 
             {
                    if($Resolvables -eq $ExpectedFixables)
                    {                              
                    "Pass"| Out-File $PSOutFilePath -Append
                    "Status      : Pass" | Out-File $OutFilePath -Append
                    }
                    else
                    {
                     "Fail"| Out-File $PSOutFilePath -Append
                     "Status      : Fail"| Out-File $OutFilePath -Append
                     "Status Desc : Fail - Mismatch with the Fixable count"| Out-File $OutFilePath -Append 
                    }
              }
            else
             {
                     if($Resolvables -eq $ExpectedFixables)
                      {
                            "Fatus      : Fail"| Out-File $OutFilePath -Append
                            "Staail"| Out-File $PSOutFilePath -Append
                            "Sttus Desc : Fail - Mismatch with the Actual and Expected Warning count"| Out-File $OutFilePath -Append 
                      }
                     else
                      {
                            "Fail"| Out-File $PSOutFilePath -Append
                            "Status      : Fail"| Out-File $OutFilePath -Append
                            "Status Desc : Fail - Mismatch with the Actual and Expected Warning and Resolvable counts"| Out-File $OutFilePath -Append 
                      }
              }
         }  
         else
         {
            If ($WCount -eq $ExpectedWarning)
            {
                      if($Resolvables -eq $ExpectedFixables)
                      {
                        "Fail"| Out-File $PSOutFilePath -Append
                        "Status      : Fail"| Out-File $OutFilePath -Append
                        "Status Desc : Fail - Mismatch with the Actual and Expected Error count"| Out-File $OutFilePath -Append 
                      }
                      else
                      {
                        "Fail"| Out-File $PSOutFilePath -Append
                        "Status      : Fail"| Out-File $OutFilePath -Append
                        "Status Desc : Fail - Mismatch with the Actual and Expected Error and Resolvable counts "| Out-File $OutFilePath -Append 
                      }
             }
             else
             {  if($Resolvables -eq $ExpectedFixables)
                {
                    "Fail"| Out-File $PSOutFilePath -Append
                    "Status      : Fail"| Out-File $OutFilePath -Append
                    "Status Desc : Fail - Mismatch with the Actual and Expected Error and Warning counts"| Out-File $OutFilePath -Append 
                 }
                 else
                 {
              
                    "Fail"| Out-File $PSOutFilePath -Append
                    "Status      : Fail"| Out-File $OutFilePath -Append
                    "Status Desc : Fail - Mismatch with the Actual and Expected Error, Warning, and Resolvable counts"| Out-File $OutFilePath -Append 
                 }
             }
         }   
}
#Append the Result of Execution to OutputFile
    $SrcPackageLoc = "Source Package Location         : " + $strsourcePkgLocation 
    $TarPackageLoc = "Target Package Location         : " + $strtargetPkgLocation 
    $SrcPackageLoc | Out-File $OutFilePath -Append
    $TarPackageLoc | Out-File $OutFilePath -Append
$RuleID =  "Rule             : " + $strRule
$RuleID | Out-File $OutFilePath -Append
"***********************************************************************************"| Out-File $OutFilePath -Append
$ExpErr = "Expected Errors   :" + "  " + $ExpectedError
$ExpWarn = "Expected Warnings :" + "  " + $ExpectedWarning
$ExpRes     = "Expected Fixables :" + "  " + $ExpectedFixables

$ActuErr = "Actual Errors   :" + "  " + $ECount
$ActuWarn = "Actual Warnings :" + "  " + $WCount
$ActRes  = "Actual Fixables :" + "  " + $Resolvables

"" , $ExpErr , $ExpWarn , $ExpRes, "" , $ActuErr , $ActuWarn ,$ActRes | Out-File $OutFilePath -Append
" " , "Detailed Description" , "********************" , $Result | Out-File $OutFilePath -Append
"-----------------------------------------------------------------------------------"| Out-File $OutFilePath -Append
}   


<#Function name: Wait()
  Description: This Function holds powershell execution for specified time
  Created Date: 03/20/2017
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A V #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Function Wait()
{
    Start-Sleep -s 40
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: ConvertAndValidate($CSVPath,$CatalogName,$LogFile)
  Description: This Function Converts MSI/EXE into different virtual Formats
  Input Parameters:
  $CSVPath-Path of the Test data CSV file
  $CatalogName-Name of the Catalog
  $LogFile-Path of the Main Log File
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M #>
  <# Modified by : Sweta Rawat
     Last Modified Date: 28/3/2019 #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function ConvertAndValidate($CSVPath,$CatalogName,$LogFile,$AppVLauncherFile)
{
  
  $RetVal=-1
  If(Test-Path $CSVPath)
    { 
        PrepAS
        $CSVcontent=Import-Csv $CSVPath
        $CSVcontent | ForEach-Object{ 
                $strPackageloc= $_.PackageLocation
                $strTargetType=$_.TargetType                                
                $PackageID=0
                $shortcut=$_.Shortcut
                $Powershell_wrap=$_.Powershell_wrap
                #$PathofAllFiles= "C:\Firefox\App-VPackage\Firefox"
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
                                                    
                 If ($PackageIDFlag -eq 0 -and $Powershell_wrap -eq 'Yes')
                         {
                           $ImportPackageID = ImportSinglePackage $strPackageLoc $CatalogName
                           $PackageID = $ImportPackageID                           
                           $InstallCommandLine = $CommandLine
                           if($strPackage -match '.exe')
                           {
                           Set-ASProperty -PackageId $ImportPackageID -PropertyName "InstallCommandLine" -PropertyValue $InstallCommandLine
                           $ImportPackageID = Wrappackage $PackageID $CatalogName $Null 
                           $PackageID = $ImportPackageID  
                           }
                           else
                           { 
                           $ImportPackageID = Wrappackage $PackageID $CatalogName $Null 
                           $PackageID = $ImportPackageID
                           }                                                           
                         }
                         ElseIf($PackageIDFlag -eq 0 -and $Powershell_wrap -eq 'No')
                         {
                           $ImportPackageID = ImportSinglePackage $strPackageloc $CatalogName
                           $PackageID = $ImportPackageID
                         }
                         ElseIf($PackageIDFlag -ne 0 -and $Powershell_wrap -eq 'Yes')
                         {
                                                    
                              $PackageID = $PackageIDFlag
                              $PackageID = Wrappackage $PackageID $CatalogName $Null
                         }
                         Else
                            {
                             $PackageID = $PackageIDFlag
                            }
                         
                             
                #To Call AAC Conversion Functions based on the Target Conversion Type and write the status to Testdata CSV and get the converted package path for launch and validation    
                 if($strPackage -match '.sft')
                           { 
                           #$ConvRetval=InvokeASConversion_SFT $strPackage $PackageID $strTargetType $LogFile
                           WriteResultsToFile $logFile "Converting $strPackage to $strTargetType virtual format started...."
                           $Result=Invoke-ASConvertPackageEx -PackageID $PackageID -TargetType $strTargetType
                           WriteResultsToFile $logFile "Converting $strPackage to $strTargetType virtual format started...."
                           $ConvRetval= Vaildate_ASConversion $strPackage $Result $strTargetType $LogFile $ExpectedConversion_files
                           }
                  Else
                           {
                           $AACSettingsFilePath=$_.AACSettingsFilePath
                           $CommandLine=$_.CommandLine
                           
                           #$ConvRetval=InvokeASConversion $strPackage $PackageID $strTargetType $AACSettingsFilePath $CommandLine $LogFile
                           #$Result=Invoke-ASConvertPackageEx -PackageID $PackageID -TargetType $strTargetType -AACSettings $AACSettingsFilePath -CommandLine $CommandLine
                           #$Result=Invoke-ASConvertPackageEx -PackageID $PackageID -TargetType $strTargetType -AACSettings $AACSettingsFilePath
                           WriteResultsToFile $logFile "Converting $strPackage to $strTargetType virtual format started...."
                           #Check whether it is a powershell wrapped package or not. If yes, then the command lines values shouldn't be taken from the csv which are applicable for underlying package. In case of powershell wrapped package, the command lines are automatically taken from programs tab during conversion. Hence, no need to pass the command lines extensively
                           if($Powershell_wrap -eq 'Yes')
                           {
                           $Result=Invoke-ASConvertPackageEx -PackageID $PackageID -TargetType $strTargetType -AACSettings $AACSettingsFilePath
                           }
                           else
                           {
						   $Result=Invoke-ASConvertPackageEx -PackageID $PackageID -TargetType $strTargetType -AACSettings $AACSettingsFilePath -CommandLine $CommandLine 
                           }
                           WriteResultsToFile $logFile "Converting $strPackage to $strTargetType virtual format completed, Validation and launching is Pending...."
                           if($ExpectedConversion_files -eq "NA")
                           {
                           WriteResultsToFile $logFile "Validating  virtual format output files not required as it is not specifed for $strPackage virtual format type $strTargetType ...."
                           $ConvRetval=0
                           
                           }
                           else
                           {
                           WriteResultsToFile $logFile "Validating  virtual format output files started...."
                           $ConvRetval= Vaildate_ASConversion $strPackage $Result $strTargetType $LogFile $ExpectedConversion_files 
                           }                            
                     }

                           #To Call Launch and Validate Functions based on the Target Conversion Type and write the status to Testdata CSV
                           #write-host $ConvertedPackagePath
                                  
                     if($ConvRetval -eq 0)
                         
                            {
                             $strSQLQuery =  "select Filename from cstblpackage where RowID=(SELECT TOP 1 RowID FROM cstblPackage ORDER BY RowID DESC)"
                             $ConvertedPackagePath = ExecuteSQLQuery $strSQLQuery $CatalogName
                          
                              Switch($strTargetType)
                                   { 
                                                                                                            
                                     "AppV5"
                                        {                                         
                                            $AppvLaunchStatus = Validate_AppvLaunch $ConvertedPackagePath $taskname                                            
                                            if($AppvLaunchStatus -eq 0)
                                            {
                                                $LaunchStatus = "Pass"
                                                WriteResultsToFile $logFile "$strTargetType Package Launched Status : " $AppvLaunchStatus 0                                          
                                                Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Virtual Format- Passed "
                                            }
                                            else
                                            {
                                                $LaunchStatus="Fail"
                                                WriteResultsToFile $logFile "$strTargetType Package Launched Status : " $AppvLaunchStatus 0
                                                Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Virtual Format- Fail "
                                            }                                
                                        }                                        

                                      "AppV4"
                                        {                                                                                     
                                            $sftlaunchstatus= Validate_sftLaunch $ConvertedPackagePath $taskname
                                            if($sftlaunchstatus -eq 0)
                                            {
                                                $LaunchStatus="Pass"
                                                WriteResultsToFile $logFile "$strTargetType Package Launched Status : " $sftlaunchstatus 0
                                                Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Virtual Format- Passed "
                                            }
                                           else
                                            {
                                                $LaunchStatus="Fail"
                                                WriteResultsToFile $logFile "$strTargetType Package Launched Status : " $sftlaunchstatus 0
                                                Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Virtual Format- Fail "
                                            }
                                        }
                                      "Profile"
                                        {
                                           $LaunchStatus="Pass"
                                           Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Virtual Format- Passed "
                                        }
                                      "ThinApp"
                                        {                                                                                   
                                            $thinapplaunchstatus= Validate_ThinappLaunch $ConvertedPackagePath $taskname
                                            if($thinapplaunchstatus -eq 0)
                                            {
                                                $LaunchStatus="Pass"
                                                WriteResultsToFile $logFile "$strTargetType Package Launched Status : " $thinapplaunchstatus 0
                                                Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Virtual Format- Passed "
                                            }
                                           else
                                            {
                                                $LaunchStatus="Fail"
                                                WriteResultsToFile $logFile "$strTargetType Package Launched Status : " $thinapplaunchstatus 0
                                                Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Virtual Format- Fail "
                                            }
                                        }
                                     "Symantec"
                                        {                                                                             
                                            $xpflaunchstatusres= Validate_XPFLaunch $ConvertedPackagePath $taskname $shortcut                                      
                                            if($xpflaunchstatusres -eq 0)
                                            {   
                                                $LaunchStatus="Pass"
                                                WriteResultsToFile $logFile "$strTargetType Package Launched Status : " $xpflaunchstatusres 0
                                                Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Virtual Format- Passed "
                                            }
                                           else
                                            {                                           
                                                $LaunchStatus="Fail"
                                                WriteResultsToFile $logFile "$strTargetType Package Launched Status : " $xpflaunchstatusres 0
                                                Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Virtual Format- Fail "                                           
                                            }
                                        }
                                     "Msi"
                                        { 
                                          $LaunchStatus="Pass"
                                          Write-Host (Write-Header $TestName) "Lauching and Validation of $strTargetType Virtual Format- Passed " 
                                        }
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
                            If (($_.ASConversion_Validate_Status -eq "Pass") -and ($_.LVStatus -eq "Pass")) 
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

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: InvokeASConversion($PackageID,$TargetType,$PathToAACSettingsFile,$CommandLine,$logFile)
  Description: This Function Converts MSI/EXE into different virtual Formats
  Input Parameters:
  $strPackageName-Name of the Package
  $PackageID - Package RowID of the Package
  $TargetType - Conversion Target Type
  $PathToAACSettingsFile - Path of the AAC settings File
  $CommandLine - Package CommandLine Parameter
  $logFile – Path of the Log File
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:-- Sweta Rawat
  Last Modified Date:-- 10/7/2019
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
Function Vaildate_ASConversion($strPackageName,$Result,$strTargetType,$logFile,$ExpectedConversion_AppVfiles)
{
$ConversionStatus=-1
If(($Result -match 'was successfully imported') -or ($Result -match 'Warning - application must be signed before it can be run!'))
           {                  
              $strSQLQuery =  "select Filename from cstblpackage where RowID=(SELECT TOP 1 RowID FROM cstblPackage ORDER BY RowID DESC)"
              $ConvertedPackagePath = ExecuteSQLQuery $strSQLQuery $CatalogName
            
              #Since the msix is a suite package the $ConvertedPackagePath contains the path of child package. Handling the code in case of msix to get the path of parent pacakge i.e convertedpackage
            if($strTargetType -eq 'Msix')
              {
                  #handling the escape sequence \v in $ConvertedPackagePath
                  #$ConvertedPackagePath=  "'"+ $ConvertedPackagePath +"'"
                  #$StrSQLQuery= "select Filename from cstblpackage where RowID=(select ParentPkgRowID_ from ASCMSuitePackages where FileName=$ConvertedPackagePath)"
                  #$ConvertedPackagePath= ExecuteSQLQuery $StrSQLQuery $CatalogName
                  WriteResultsToFile $logFile "Converted Package Path:$ConvertedPackagePath" 0 0
              }
          else
              {
                  WriteResultsToFile $logFile "Converted Package Path:$ConvertedPackagePath" 0 0
              }
              #Function for OutputValiation
             
              $ValidationRetVal=ValidateConversionOutput $ConvertedPackagePath $strTargetType $ExpectedConversion_AppVfiles 
            if($ValidationRetVal -eq 0)
              {
              $ConversionStatus=0
              $_.ASConversion_Validate_Status="Pass"
              WriteResultsToFile $logFile "Converting $strPackageName Package to $strTargetType Virtual Format " $ConversionStatus 0
              Write-Host (Write-Header $TestName) "Converting $strPackageName Package to $strTargetType Virtual Format- Passed "
              }
           else
              {
              $Result=""
              $_.ASConversion_Validate_Status="Fail"
              WriteResultsToFile $logFile "Converting $strPackageName Package to $strTargetType Virtual Format " $ConversionStatus 0 
              Write-Host (Write-Header $TestName) "Converting $strPackageName Package to $strTargetType Virtual Format- Failed "  
              }                 
           }
		    elseif(($Result -match 'was successfully imported') -And ($ExpectedConversion_AppVfiles -eq 'NA') )
            {
              $ConversionStatus=0
              $_.ASConversion_Validate_Status="Pass"
              WriteResultsToFile $logFile "Converting $strPackageName Package to $strTargetType Virtual Format " $ConversionStatus 0
              Write-Host (Write-Header $TestName) "Converting $strPackageName Package to $strTargetType Virtual Format- Passed "
            }
        else
           {
              $_.ASConversion_Validate_Status="Fail"
              WriteResultsToFile $logFile "Converting $strPackageName Package to $strTargetType Virtual Format " $ConversionStatus 0
              Write-Host (Write-Header $TestName) "Converting $strPackageName Package to $strTargetType Virtual Format- Failed " 
           }
                                                                              
         return $ConversionStatus
} 




#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: ValidateConversionOutput($ConvertedPackagePath,$strTargetType)
  Description: This Function validates the output of different virtual Formats
  Input Parameters:
  $ConvertedPackagePath-Path of the converted packages
  $strTargetType-Type of the Conversion
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:-- Sweta Rawat
  Last Modified Date:-- 10/7/2019
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Function ValidateConversionOutput($ConvertedPackagePath,$strTargetType,$ExpectedConversion_AppVfiles)
{
    
    $ValidationRetVal=-1
    Switch($strTargetType)
    { 
        "AppV5"
         {
            $ValidationRetVal=Validate_AppVOutputFiles $ConvertedPackagePath $ExpectedConversion_AppVfiles                                  		                                                                         
         }
                             
         "AppV4"
         {                                 
            $ValidationRetVal=Validate_SFTOutputFiles $ConvertedPackagePath $ExpectedConversion_AppVfiles                                                                                                                
         }

         "Profile"
         {
            $ValidationRetVal=Validate_CitrixOutputFiles $ConvertedPackagePath $ExpectedConversion_AppVfiles                                             
         }

         "ThinApp"
         {
            $ValidationRetVal=Validate_ThinAppOutputFiles $ConvertedPackagePath $ExpectedConversion_AppVfiles                                                                    
         }

         "Symantec"
         {
            $ValidationRetVal=Validate_SymantecOutputFiles $ConvertedPackagePath $ExpectedConversion_AppVfiles                                                                    
         }

         "Msi"
         {
            $ValidationRetVal=Validate_MSIOutputFiles $ConvertedPackagePath $ExpectedConversion_AppVfiles                                                                    
         } 
         "Msix"
         {
            $ValidationRetVal=Validate_MSIXOutputFiles $ConvertedPackagePath $ExpectedConversion_AppVfiles                                                                    
         }                               
     }
     return $ValidationRetVal
}


#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: Validate_AppVOutputFiles($ConvertedPackagePath)
  Description: This Function validates the output of AppVFiles
  Input Parameters:
  $ConvertedPackagePath-Path of the converted packages
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

<#Function name: Validate_AppVOutputFiles($ConvertedPackagePath)
  Description: This Function validates the output of AppVFiles
  Input Parameters:
  $ConvertedPackagePath-Path of the converted packages
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Validate_AppVOutputFiles($ConvertedPackagePath,$ExpectedConversion_files)
{
	$RetVal=-1      
	$PathofAllFiles=Split-Path -Parent $ConvertedPackagePath
    $ExpectedOutputFilesCount=$ExpectedConversion_files.Count
    $GetFiles= Get-ChildItem $PathofAllFiles | Where-Object{$_.extension} 
    $GetFilesCount=$GetFiles.Count
    if($GetFilesCount -eq $ExpectedOutputFilesCount) 
    {
     $AppVOutputFiles_status=Validate_OutputFiles $PathofAllFiles $ExpectedConversion_files
     if($AppVOutputFiles_status -eq 0)
     {
        $RetVal=0
     } 
	}
 return $RetVal
} 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: Validate_SFTOutputFiles($ConvertedPackagePath)
  Description: This Function validates the output of SFT Files
  Input Parameters:
  $ConvertedPackagePath-Path of the converted packages
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Validate_SFTOutputFiles($ConvertedPackagePath,$ExpectedConversion_files)
{
	$RetVal=-1
	$ExpectedOutputFilesCount=6        
	$PathofAllFiles=Split-Path -Parent $ConvertedPackagePath
    $GetFiles= Get-ChildItem $PathofAllFiles | Where-Object{$_.extension -ne ".osd"} 
    $GetFilesCount=$GetFiles.Count
    if($GetFilesCount -eq $ExpectedOutputFilesCount) 
    {
     
     $SFTOutputFiles_status=Validate_OutputFiles $PathofAllFiles $ExpectedConversion_files
     if($SFTOutputFiles_status -eq 0)
     {
        $RetVal=0
     } 
	}
 return $RetVal
} 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: Validate_CitrixOutputFiles($ConvertedPackagePath)
  Description: This Function validates the output of Citrix Files
  Input Parameters:
  $ConvertedPackagePath-Path of the converted packages
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Validate_CitrixOutputFiles($ConvertedPackagePath,$ExpectedConversion_files)
{
	$RetVal=-1
	$ExpectedOutputFilesCount=4        
	$PathofAllFiles=Split-Path -Parent $ConvertedPackagePath
    $GetFiles= Get-ChildItem $PathofAllFiles | Where-Object{$_.extension} 
    $GetFilesCount=$GetFiles.Count
    if($GetFilesCount -eq $ExpectedOutputFilesCount) 
    {
     
     $CitrixOutputFiles_status=Validate_OutputFiles $PathofAllFiles $ExpectedConversion_files
     if($CitrixOutputFiles_status -eq 0)
     {
        $RetVal=0
     } 
	}
 return $RetVal

} 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: Validate_ThinAppOutputFiles($ConvertedPackagePath)
  Description: This Function validates the output of ThinAppFiles
  Input Parameters:
  $ConvertedPackagePath-Path of the converted packages
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Validate_ThinAppOutputFiles($ConvertedPackagePath,$ExpectedConversion_files)
{
$RetVal=-1
	
    $PathofAllFiles=Split-Path -Parent $ConvertedPackagePath
    $ThinAppOutputFiles_status=Validate_OutputFiles $PathofAllFiles $ExpectedConversion_files
    if($ThinAppOutputFiles_status -eq 0)
     {
        $RetVal=0
     } 
 return $RetVal
} 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: Validate_SymantecOutputFiles($ConvertedPackagePath)
  Description: This Function validates the output of Symantec Files
  Input Parameters:
  $ConvertedPackagePath-Path of the converted packages
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Validate_SymantecOutputFiles($ConvertedPackagePath,$ExpectedConversion_files)
{
	$RetVal=-1
	$ExpectedOutputFilesCount=2        
	$PathofAllFiles=Split-Path -Parent $ConvertedPackagePath
    $GetFiles= Get-ChildItem $PathofAllFiles | Where-Object{$_.extension} 
    $GetFilesCount=$GetFiles.Count
    if($GetFilesCount -eq $ExpectedOutputFilesCount) 
    {
     
     $SymantecOutputFiles_status=Validate_OutputFiles $PathofAllFiles $ExpectedConversion_files
     if($SymantecOutputFiles_status -eq 0)
     {
        $RetVal=0
     } 
	}
 return $RetVal
} 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: Validate_MSIOutputFiles($ConvertedPackagePath)
  Description: This Function validates the output of MSI Files
  Input Parameters:
  $ConvertedPackagePath-Path of the converted packages
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Validate_MSIOutputFiles($ConvertedPackagePath,$ExpectedConversion_files)
{
	$RetVal=-1
	$ExpectedOutputFilesCount=6        
	$PathofAllFiles=Split-Path -Parent $ConvertedPackagePath
    $GetFiles= Get-ChildItem $PathofAllFiles | Where-Object{$_.extension} 
    $GetFilesCount=$GetFiles.Count
    if($GetFilesCount -eq $ExpectedOutputFilesCount) 
    {
     
     $MSIOutputFiles_status=Validate_OutputFiles $PathofAllFiles $ExpectedConversion_files
     if($MSIOutputFiles_status -eq 0)
     {
        $RetVal=0
     } 
	}
 return $RetVal
} 


#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: Validate_MSIXOutputFiles($ConvertedPackagePath)
  Description: This Function validates the output of MSIX Files
  Input Parameters:
  $ConvertedPackagePath-Path of the converted packages
  Output Parameters :NA
  Created Date: 7/4/2019
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Sweta Rawat #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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


#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: AppvLaunch($ConvertedPackagePath,$taskname)
  Description: This Function Launches and Validates AppV Applications
  Input Parameters:
  $ConvertedPackagePath-Path of the converted package
  $taskname- Name of the Task
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Validate_AppVLaunch($ConvertedPackagePath,$taskname)
{
    $RetVal=-1
    #$strSQLQuery =  "select Filename from cstblpackage where RowID=(SELECT TOP 1 RowID FROM cstblPackage ORDER BY RowID DESC)"
    #$ConvertedPackagePath = ExecuteSQLQuery $strSQLQuery $CatalogName                                        
    $StatusLogFile=$LogFile 
        If ( (Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit" )
            {                                                                                             
                $AppvLaunchStatus= C:\Windows\Sysnative\WindowsPowerShell\v1.0\PowerShell.exe -File $AppVLauncherFile "$ConvertedPackagePath" "$taskname" "$StatusLogFile"
                $RetVal=$AppvLaunchStatus
                Wait
            }
        else
            {	
                $AppvLaunchStatus= C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -File $AppVLauncherFile "$ConvertedPackagePath" "$taskname" "$StatusLogFile"
                $RetVal=$AppvLaunchStatus
                Wait           	            
        }
return $RetVal
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: sftLaunch($ConvertedPackagePath,$taskname)
  Description: This Function Launches and Validates SFT Applications
  Input Parameters:
  $ConvertedPackagePath-Path of the converted package
  $taskname- Name of the Task
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Validate_sftLaunch($ConvertedPackagePath,$taskname)
{
	$RetVal=-1 
	$PathofAllFiles=Split-Path -Parent $ConvertedPackagePath
	$Launcher=Get-ChildItem -Name $PathofAllFiles
	$LauncherPath=$PathofAllFiles +"\"+$Launcher[1]
    Wait
    Invoke-item "C:\Autoit\HandlingAPPV4.exe"
	Invoke-item $LauncherPath
    Wait
	$sftpkg=Get-Process -Name $taskname
	$GetProcess=Get-Process -ProcessName $taskname
	$GetProcessName=$GetProcess.ProcessName
		if($GetProcessName -eq $taskname)
		{	
		$RetVal=0
		WriteResultsToFile $logFile "sft Launch Status : " 0 0
		Get-Process -Name $taskname | Stop-Process
		}
		else
		{
		WriteResultsToFile $logFile "sft Launch Status : " -1 0
		}
	return $RetVal
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: XPFLaunch($ConvertedPackagePath,$taskname,$shortcut)
  Description: This Function Launches and Validates XPF Applications
  Input Parameters:
  $ConvertedPackagePath-Path of the converted package
  $taskname- Name of the Task
  $shortcut - Name of the Shortcut
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Validate_XPFLaunch($ConvertedPackagePath,$taskname,$shortcut)
{
	$xpflaunchstatusres=-1
	$import=SVSCMD.EXE I -P $ConvertedPackagePath
	$activate=SVSCMD.EXE * A -NDR REF
	Wait
	$a=join-path "C:\Users\Public\Desktop"$shortcut
	Invoke-Item $a
	Wait
	$GetProcess=Get-Process -ProcessName $taskname
	$GetProcessName=$GetProcess.ProcessName
		if($GetProcessName -eq $taskname)
		{
			$xpflaunchstatusres=0
			Get-Process -Name $taskname | Stop-Process
			WriteResultsToFile $logFile "$ConvertedPackagePath XPF Launch Status : " 0 0
			Wait
			$deactivate=SVSCMD.EXE * D -NDR REF
			$delete=SVSCMD.EXE * DEL -NDR REF
		}
		else
		{
		WriteResultsToFile $logFile "$ConvertedPackagePath XPF Launch Status : " -1 0
		}
	Return $xpflaunchstatusres
} 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
<#Function name: ThinappLaunch($ConvertedPackagePath,$taskname)
  Description: This Function Launches and Validates SFT Applications
  Input Parameters:
  $ConvertedPackagePath-Path of the converted package
  $taskname- Name of the Task
  Output Parameters :NA
  Created Date: 12/22/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function Validate_ThinappLaunch($ConvertedPackagePath,$taskname)
{
	$thinapplaunchstatus=-1
	Invoke-Item $ConvertedPackagePath
	Wait
	$GetProcess=Get-Process -ProcessName $taskname
	$GetProcessName=$GetProcess.ProcessName
		if($GetProcessName -eq $taskname)
		{
		$thinapplaunchstatus=0
		Stop-Process -processname $taskname
		WriteResultsToFile $logFile "$ConvertedPackagePath ThinApp Launch Status : " 0 0
		}
		else
		{
		WriteResultsToFile $logFile "$ConvertedPackagePath ThinApp Launch Status : " -1 0
		}
	return $thinapplaunchstatus
}

<#Function name: Validate_OutputFiles($PathofAllFiles,$ConvertedPackagePath)
  Description: This Function validates the output of Converted Packages
  Input Parameters:$ConvertedPackagePath
  $ConvertedPackagePath-Path of the converted packages
  Output Parameters :NA
  Created Date: 20/3/2016
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A V #>

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

<#Function name: Validate_wrapOutputFiles($WrapFolderPath,$ExpectedFilesAfterWrap)
  Description: This Function validates the output of Converted Packages
  Input Parameters:$WrapFolderPath,$ExpectedFilesAfterWrap
  $WrapFolderPath:Path of wrapped output folder
  $ExpectedFilesAfterWrap- Expected Files List
  Output Parameters :NA
  Created Date: 17/11/2017
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A V #>

Function Validate_wrapOutputFiles($WrapFolderPath,$ExpectedFilesAfterWrap)
{

$ActualFilesAfterWrap = Get-ChildItem -Path $WrapFolderPath -Recurse  | Where-Object{$_.extension}
$ActualFiles = $ActualFilesAfterWrap.Name
    ForEach($Expfile in $ExpectedFilesAfterWrap)
    {
        if($ActualFiles -match $Expfile)
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

<#Function name: Adddependency($PrimaryPackage,$DependencyPackage,$sitecode,$sccmip,$SessionID)
  Description: This Function Adds dependency to primary package in SCCM
  Input Parameters:$ConvertedPackagePath
  $sitecode-WMIobject namespace
  $sccmip :SCCM Machine Name
  Created Date: 19/10/2017
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A V #>

function Adddependency($PrimaryPackage,$DependencyPackage,$sitecode,$sccmip,$SessionID)
{
	$Dependency = Invoke-Command -Session $SessionID -ScriptBlock{
	param([string] $PrimaryPackage,[string] $DependencyPackage, [string] $sitecode, [string] $sccmip)             
 
	#Load the Default Parameter Values for Get-WMIObject cmdlet
	$PSDefaultParameterValues =@{"Get-wmiobject:namespace"=$sitecode;"Get-WMIObject:computername"=$sccmip}

	#Creating Type Accelerators - for making assembly references easier later
	$accelerators = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
	$accelerators::Add('SccmSerializer',[type]'Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer')

	#get direct reference to the Application's WMI Instance
	$application1 = [wmi](Get-WmiObject -Query "select * from sms_application where LocalizedDisplayName='$PrimaryPackage' AND ISLatest='true'").__PATH

	#Deserialize the SDMPackageXML
	$App1Deserializedstuff = [SccmSerializer]::DeserializeFromString($application1.SDMPackageXML)

	#Reference to the above application
	$application2 = [wmi](Get-WmiObject -Query "select * from sms_application where LocalizedDisplayName='$DependencyPackage' AND ISLatest='true'").__PATH

	#deserialize the XML
	$App2Deserializedstuff = [SccmSerializer]::DeserializeFromString($application2.SDMPackageXML)

	#Store the arguments before hand
	$ApplicationAuthoringScopeId = ($application2.CI_UniqueID -split "/")[0]
	$ApplicationLogicalName = ($application2.CI_UniqueID -split "/")[1]
	$ApplicationVersion =  $application2.SourceCIVersion
	$DeploymentTypeAuthoringScopeId = $App2Deserializedstuff.DeploymentTypes.scope
	$DeploymentTypeLogicalName = $App2Deserializedstuff.DeploymentTypes.name
	$DeploymentTypedefaultLanguage = $App2Deserializedstuff.DisplayInfo.DefaultLanguage
	$DeploymentTypeVersion = $App2Deserializedstuff.DeploymentTypes.Version
	$EnforceDesiredState = $True

	# set the Desired State as "Required" or Mandatory
	$DTDesiredState = [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DeploymentTypeDesiredState]::Required

	#create the intent expression which will be added to the Operand
	$intentExpression = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DeploymentTypeIntentExpression -ArgumentList  $ApplicationAuthoringScopeId, $ApplicationLogicalName, $ApplicationVersion, $DeploymentTypeAuthoringScopeId, $DeploymentTypeLogicalName, $DeploymentTypeVersion, $DTDesiredState, $EnforceDesiredState

	#Create the Operand - Note the typename of this one
	$operand = New-Object  Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DeploymentTypeIntentExpression]

	#add the Intent Expression to the Operand
	$operand.Add($intentExpression)

	#create the new OR operator 
	$OrOperator = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ExpressionOperators.ExpressionOperator]::Or

	#Now the Operator and Operand are added to the Expression
	$BaseExpression = New-Object -TypeName Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DeploymentTypeExpression -ArgumentList $OrOperator,$operand

	# Create the Severity Critical
	$severity = [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.NoncomplianceSeverity]::Critical

	# Create the Empty Rule Context
	$RuleContext = New-Object -TypeName Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.RuleScope

	#Create the Annotation - Name & description of the Dependency 
	$annotation = New-Object -TypeName Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.Annotation
	$annotation.DisplayName.Text = "DependencyName"

	#Create the new DeploymentType Rule
	$DTRUle = New-Object -TypeName Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.DeploymentTypeRule -ArgumentList $("DTRule_"+[guid]::NewGuid().Guid),$severity, $annotation, $BaseExpression

	#add the DepolymentType Rule to Dependecies
	$App1Deserializedstuff.DeploymentTypes[0].Dependencies.Add($DTRUle)

	# Serialize the XML 
	$newappxml = [SccmSerializer]::Serialize($App1Deserializedstuff, $false)

	#set the property back on the local copy of the Object
	$application1.SDMPackageXML = $newappxml

	#Now time to set the changes back to the ConfigMgr
	$application1.Put()
	} -ArgumentList $PrimaryPackage,$DependencyPackage,$sitecode,$sccmip

    return $Dependency
}

<#Function name: SCCCMPackagePath ([string]$ApplicationName)
  Description: This Function Finds Application Relative path in sccm
  Input Parameters:$ApplicationName
  $ApplicationName:Package Name
  Created Date: 19/10/2017
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A V #>

function SCCCMPackagePath ([string]$ApplicationName)
{   
    $GetPackageID=Get-CMApplication | Where { $_.LocalizedDisplayName -eq $ApplicationName}
    $InstanceKey=$GetPackageID.ModelName
    $ContainerNode = Get-WmiObject -Namespace root/SMS/site_AR3 -ComputerName "AS201604CM1710" -Query "SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='$InstanceKey'"
    if ($ContainerNode -ne $null) 
    {
        $ObjectFolder = $ContainerNode.Name
        if ($ContainerNode.ParentContainerNodeID -eq 0) 
        {
            $ParentFolder = $false
        }
        else 
        {
            $ParentFolder = $true
            $ParentContainerNodeID = $ContainerNode.ParentContainerNodeID
        }
        while ($ParentFolder -eq $true) 
        {
            $ParentContainerNode = Get-WmiObject -Namespace root/SMS/site_AR3 -ComputerName "AS201604CM1710" -Query "SELECT * FROM SMS_ObjectContainerNode WHERE ContainerNodeID = '$ParentContainerNodeID'"
            $ObjectFolder =  $ParentContainerNode.Name + "\" + $ObjectFolder
            if ($ParentContainerNode.ParentContainerNodeID -eq 0) 
            {
                $ParentFolder = $false
            }
            else 
            {
                $ParentContainerNodeID = $ParentContainerNode.ParentContainerNodeID
            }
        }
        $ObjectFolder = "Root\" + $ObjectFolder
        Return $ObjectFolder
    }
    else 
    {
        $ObjectFolder = "Root"
        Return $ObjectFolder
    }
}


<#Function name: Load-ConfigMgrAssemblies($AdminConsoleDirectory,$SessionID)
  Description: This Function Loads Config Manager Assemblies
  Input Parameters:$ApplicationName
  $ApplicationName:Package Name
  Created Date: 19/10/2017
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A V #>

function Load-ConfigMgrAssemblies($AdminConsoleDirectory,$SessionID) 
{
$Assemblies = Invoke-Command -Session $SessionID -ScriptBlock{
Param([string] $AdminConsoleDirectory)
     $filesToLoad = "Microsoft.ConfigurationManagement.ApplicationManagement.dll","AdminUI.WqlQueryEngine.dll", "AdminUI.DcmObjectWrapper.dll","DcmObjectModel.dll","AdminUI.AppManFoundation.dll","AdminUI.WqlQueryEngine.dll","Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll","Microsoft.ConfigurationManagement.ManagementProvider.dll","Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll"
     Push-Location $AdminConsoleDirectory
     [System.IO.Directory]::SetCurrentDirectory($AdminConsoleDirectory)
      foreach($fileName in $filesToLoad)
      {
         $fullAssemblyName = [System.IO.Path]::Combine($AdminConsoleDirectory, $fileName)
         if([System.IO.File]::Exists($fullAssemblyName ))
         {
             $FileLoaded = [Reflection.Assembly]::LoadFrom($fullAssemblyName )
         }
         else
         {
              Write-Host ([System.String]::Format("File not found {0}",$fileName )) -backgroundcolor "red"
         }
      } 
      Pop-Location 
      } -ArgumentList $AdminConsoleDirectory 
 }

<#Function name: SetSCCMFileDetection($type,$FolderPath,$FileName,$Operator,$ApplicationName,$DeploymentTypeName,$Is64bit,$SccmServer,$site,$SessionID)
  Description: This Function Adds FileDetection Type to SCCM 2012
  Input Parameters:$type,$FolderPath,$FileName,$Operator,$ApplicationName,$DeploymentTypeName,$Is64bit,$SccmServer,$site,$SessionID
  Created Date: 19/10/2017
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A V #>

Function SetSCCMFileDetection($type,$FolderPath,$FileName,$Operator,$ApplicationName,$DeploymentTypeName,$Is64bit,$SccmServer,$site,$SessionID)
{
$Sccmdetection = Invoke-Command -Session $SessionID -ScriptBlock{
Param([string] $type,[string] $FolderPath,[string] $FileName,[string] $Operator,[string] $ApplicationName,[string] $DeploymentTypeName,[string] $Is64bit,[string] $SccmServer,[string] $site)
Push-Location 
Set-Location $site":"
$NoncomplianceSeverity = "None"
      
    #Deserialize the SDMPackageXML
    $connection = New-Object Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlConnectionManager
    [void]$connection.Connect($SccmServer)
    $application1 = Get-CMApplication -Name $ApplicationName

    # initialise management scope.
    $factory = New-Object Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.ApplicationFactory
    $wrapper = [Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.AppManWrapper]::Create($connection, $factory)
    $App1Deserializedstuff = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($application1.SDMPackageXML) 
    $oEnhancedDetection = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.EnhancedDetectionMethod                       
                 write-verbose "--> Creating Enhanced File Detection Method"
                $oDetectionType              = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemPartType]::$type
                $oFileSetting                 = New-Object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.FileOrFolder( $oDetectionType , $null)
                  if ($oFileSetting -ne $null) { write-verbose " oFileSetting object Created"} else {write-warning " oFileSetting object Creation failed"; break}
  
                $oFileSetting.FileOrFolderName = $FileName
                $oFileSetting.Path             =  $FolderPath
                #$oFileSetting.PropertyList
                
                if ($Is64bit -eq 0) {$Is64bits= 1}else{$Is64bits = 0}
                $oFileSetting.Is64Bit          = $Is64bits
                $oFileSetting.SettingDataType  = [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::Int64               
                $oEnhancedDetection.Settings.Add($oFileSetting)  
                         
                write-verbose  "Settings Reference"
                $oSettingRef= New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.SettingReference(
                $App1Deserializedstuff.Scope,
                $App1Deserializedstuff.Name,
                $App1Deserializedstuff.Version,
                $oFileSetting.LogicalName,
                $oFileSetting.SettingDataType,
                $oFileSetting.SourceType,
                [bool]0 )
                # setting bool 0 as false
                if ($oSettingRef -ne $null) { write-verbose " oSettingRef object Created"} else {write-warning " oSettingRef object Creation failed"; exit}  
                $oSettingRef.MethodType    = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemSettingMethodType]::Value
                $oConstValue               = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ConstantValue( 0, 
                [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::Int64)                
                if ($oConstValue -ne $null) { write-verbose " oConstValue object Created"} else {write-warning " oConstValue object Creation failed"; exit}
                $oFileCheckOperands = new-object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection``1[[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ExpressionBase]]
                $oFileCheckOperands.Add($oSettingRef)
                $oFileCheckOperands.Add($oConstValue)
  
                $FileCheckExpression = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.Expression(
                [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ExpressionOperators.ExpressionOperator]::$Operator, $oFileCheckOperands)
  
                $oRule = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.Rule("IsInstalledRule", 
                [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.NoncomplianceSeverity]::$NoncomplianceSeverity, $null, $FileCheckExpression)
                   if ($oRule  -ne $null) { write-verbose " rule object Created"} else {write-warning " rule object Creation failed"; exit}                
                $oEnhancedDetection.Rule = $oRule
                              
                $DTR = $oEnhancedDetection
                #return $oEnhancedDetection
                #Set the detection method to the deserialized application
                $i = 0
                    foreach ($DT in $App1Deserializedstuff.DeploymentTypes){
                    write-verbose "Analying $($DT.Title)"
                    if ($DT.Title -eq $DeploymentTypeName){
                        write-verbose "Adding Enhanced detection type to application $($ApplicationName) and deploymentType $($DeploymentTypeName)"       
                    $App1Deserializedstuff.DeploymentTypes[$i].Installer.DetectionMethod = [Microsoft.ConfigurationManagement.ApplicationManagement.DetectionMethod]::Enhanced
                    $App1Deserializedstuff.DeploymentTypes[$i].Installer.EnhancedDetectionMethod = $DTR
                    continue
    }else{
        $i++
    }
}
# save the application.
$wrapper.InnerAppManObject = $App1Deserializedstuff

$factory.PrepareResultObject($wrapper)
$wrapper.InnerResultObject.Put()
Pop-Location 
} -ArgumentList $type,$FolderPath,$FileName,$Operator,$ApplicationName,$DeploymentTypeName,$Is64bit,$SccmServer,$site
}

<#Function name: SetSCCMMSIDetection($ApplicationName,$DeploymentTypeName,$ProductCode,$Operator,$SccmServer,$site,$SessionID)
  Description: This Function Adds MSI Detection Method Type in SCCM
  Input Parameters:$ApplicationName,$DeploymentTypeName,$ProductCode,$Operator,$SccmServer,$site,$SessionID
  Created Date: 3/11/2017
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A V #>

Function SetSCCMMSIDetection($ApplicationName,$DeploymentTypeName,$ProductCode,$Operator,$SccmServer,$site,$SessionID)
{
$Sccmdetection = Invoke-Command -Session $SessionID -ScriptBlock{
Param([string] $ApplicationName,[string] $DeploymentTypeName,[string] $ProductCode,[string] $Operator,[string] $SccmServer,[string] $site)
Push-Location 
Set-Location $site":"
$NoncomplianceSeverity = "None"   
    #Deserialize the SDMPackageXML
    $connection = New-Object Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlConnectionManager
    [void]$connection.Connect($SccmServer)
    $application1 = Get-CMApplication -Name $ApplicationName

    # initialise management scope.
    $factory = New-Object Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.ApplicationFactory
    $wrapper = [Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.AppManWrapper]::Create($connection, $factory)

    $App1Deserializedstuff = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($application1.SDMPackageXML)    
    write-verbose "Creating Enhanced Product Code Detection Method"
            $oEnhancedDetection = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.EnhancedDetectionMethod            
            $msiSetting = New-Object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.MSISettingInstance($ProductCode, $null)
            $oEnhancedDetection.Settings.Add($msiSetting)
            $setting = $msiSetting
            $msiDataType = [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::Int64
            $msiConstValue = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ConstantValue('0', $msiDataType)
            $msiSettingRef = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.SettingReference(
                $App1Deserializedstuff.Scope,
                $App1Deserializedstuff.Name,
                $App1Deserializedstuff.Version,
                $msiSetting.LogicalName,
                $msiDataType,
            $msiSetting.SourceType,
                 [bool]0
            )
            $msiSettingRef.MethodType = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemSettingMethodType]::Count
            $msiOperands = new-object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection``1[[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ExpressionBase]]
            $msiOperands.Add($msiSettingRef);
            $msiOperands.Add($msiConstValue);
            $msiExpression = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.Expression(
                [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ExpressionOperators.ExpressionOperator]::$Operator, $msiOperands)
         
            $oRule = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.Rule("IsInstalledRule", 
                [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.NoncomplianceSeverity]::$NoncomplianceSeverity, $null, $msiExpression)
            if ($oRule  -ne $null) { write-verbose " rule object Created"} else {write-warning " rule object Creation failed"; break}
              
             $oEnhancedDetection.Rule = $oRule            
             $DTR = $oEnhancedDetection
            #return $oEnhancedDetection


            #Set the detection method to the deserialized application
             $i = 0
             foreach ($DT in $App1Deserializedstuff.DeploymentTypes){
             write-verbose "Analying $($DT.Title)"
                  if ($DT.Title -eq $DeploymentTypeName){
                    write-verbose "Adding Enhanced detection type to application $($ApplicationName) and deploymentType $($DeploymentTypeName)"        
                    $App1Deserializedstuff.DeploymentTypes[$i].Installer.DetectionMethod = [Microsoft.ConfigurationManagement.ApplicationManagement.DetectionMethod]::Enhanced
                    $App1Deserializedstuff.DeploymentTypes[$i].Installer.EnhancedDetectionMethod = $DTR
                    continue
                    }else{
                            $i++
                         }
                    }

            # save the application.
$wrapper.InnerAppManObject = $App1Deserializedstuff

$factory.PrepareResultObject($wrapper)
$wrapper.InnerResultObject.Put()
Pop-Location
} -ArgumentList  $ApplicationName,$DeploymentTypeName,$ProductCode,$Operator,$SccmServer,$site 
}

<#Function name: SetSCCMRegistryDetection($RegistryHyve,$RegistryKey,$RegistryKeyValue,$RegistryKeyValueDataType,$Is64bit,$ApplicationName,$DeploymentTypeName,$ConstantValue,$ConstantDataType,$Operator,$SccmServer,$site,$SessionID)
  Description: This Function Adds RegistryDetectionMethod Type in SCCM
  Input Parameters:$RegistryHyve,$RegistryKey,$RegistryKeyValue,$RegistryKeyValueDataType,$Is64bit,$ApplicationName,$DeploymentTypeName,$ConstantValue,$ConstantDataType,$Operator,$SccmServer,$site,$SessionID
  Created Date: 3/11/2017
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Manu A V #>

Function SetSCCMRegistryDetection($RegistryHyve,$RegistryKey,$RegistryKeyValue,$RegistryKeyValueDataType,$Is64bit,$ApplicationName,$DeploymentTypeName,$ConstantValue,$ConstantDataType,$Operator,$SccmServer,$site,$SessionID)
{
$Sccmdetection = Invoke-Command -Session $SessionID -ScriptBlock{
Param([string] $RegistryHyve,[string] $RegistryKey,[string] $RegistryKeyValue,[string] $RegistryKeyValueDataType,[string] $Is64bit,[string] $ApplicationName,[string] $DeploymentTypeName,[string] $ConstantValue,[string] $ConstantDataType,[string] $Operator,[string] $SccmServer,[string] $site)
$DcmObjectModelPath = "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\DcmObjectModel.dll"
Push-Location 
Set-Location $site":"
    $NoncomplianceSeverity = "None"    
    #Deserialize the SDMPackageXML
    $connection = New-Object Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlConnectionManager
    [void]$connection.Connect($SccmServer)
    $application1 = Get-CMApplication -Name $ApplicationName

    # initialise management scope.
    $factory = New-Object Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.ApplicationFactory
    $wrapper = [Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.AppManWrapper]::Create($connection, $factory)

    $App1Deserializedstuff = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($application1.SDMPackageXML)     
     
    $oEnhancedDetection = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.EnhancedDetectionMethod

      if ($RegistryKeyValue -eq "" -or $RegistryKeyValue -eq "NULL" -or $RegistryKeyValue -eq $Null){
                #Hack to bypass RegistryKey Bug
                $sourceKeyFix = @"
using Microsoft.ConfigurationManagement.DesiredConfigurationManagement;
using System;
namespace RegistryKeyNamespace
{
       public class RegistryKeyFix
       {
              private RegistryKey _registryKey;
              public RegistryKeyFix(string str)
              {
                     this._registryKey = new RegistryKey(null);
              }
              public RegistryKey GetRegistryKey()
              {
                     return this._registryKey;
              }
       }
}
"@
                Add-Type -ReferencedAssemblies $DcmObjectModelPath -TypeDefinition $sourceKeyFix -Language CSharp
                $temp = New-Object RegistryKeyNamespace.RegistryKeyFix "" 

                $oRegistrySetting = $temp.GetRegistryKey()
                write-verbose "--> Creating Enhanced RegistryKey Detection Method"
            }else{
                 #Hack to bypass bug in Microsoft.ConfigurationManagement.DesiredConfigurationManagement.registrySetting which doesn't allow us to create a enhanced detection method.
                $sourceSettingFix = @"
using Microsoft.ConfigurationManagement.DesiredConfigurationManagement;
using System;
namespace RegistrySettingNamespace
{
       public class RegistrySettingFix
       {
              private RegistrySetting _registrysetting;
              public RegistrySettingFix(string str)
              {
                     this._registrysetting = new RegistrySetting(null);
              }
              public RegistrySetting GetRegistrySetting()
              {
                     return this._registrysetting;
              }
       }
}
"@                             
                 Add-Type -ReferencedAssemblies $DcmObjectModelPath -TypeDefinition $sourceSettingFix -Language CSharp
                 $temp = New-Object RegistrySettingNamespace.RegistrySettingFix ""                 
                 $oRegistrySetting = $temp.GetRegistrySetting()
                 
                 write-verbose "--> Creating Enhanced Registry Setting Detection Method"
                }
            $oEnhancedDetection = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.EnhancedDetectionMethod

            write-verbose "--> Creating Enhanced Registry Detection Method"
            
            $oDetectionType = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemPartType]::RegistryKey
                
                
            if ($oRegistrySetting -ne $null) { write-verbose " oRegistrySetting object Created"} else {write-warning " oRegistrySetting object Creation failed";Break}

                switch ($RegistryHyve){
                    "HKEY_CLASSES_ROOT"{
                        $oRegistrySetting.RootKey = "ClassesRoot"
                        Break
                    }
                    "HKEY_CURRENT_CONFIG"{
                        $oRegistrySetting.RootKey = "CurrentConfig"
                        Break
                    }
                    "HKEY_CURRENT_USER"{
                        $oRegistrySetting.RootKey = "CurrentUser"
                        Break
                    }
                    "HKEY_LOCAL_MACHINE"{
                        $oRegistrySetting.RootKey = "LocalMachine"
                        Break
                    }
                    "HKEY_USERS"{
                        $oRegistrySetting.RootKey = "Users"
                        Break
                    }
                }
             
                $oregistrysetting.Key = $RegistryKey
                if ($RegistryKeyValue){
                    $oRegistrySetting.ValueName = $RegistryKeyValue
                     $oRegistrySetting.CreateMissingPath = $false
                }
                if ($Is64bit -eq 0){$Is64bits= 1}else{$Is64bits = 0}
                $oRegistrySetting.Is64Bit          = $Is64bits#$Is64bits
                if (!($RegistryKeyValue)){
                    $oRegistrySetting.SettingDataType  = [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::Boolean
                }else{
                    $oRegistrySetting.SettingDataType  = [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::$RegistryKeyValueDataType
                }
                
                #$oRegistrySetting.ChangeLogicalName()
               
                #$oRegistrySetting.SupportsRemediation = $false
                $oEnhancedDetection.Settings.Add($oRegistrySetting)
                #$oFileSetting
            write-verbose  "Settings Reference"
            $oSettingRef = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.SettingReference(
                $App1Deserializedstuff.Scope,
                $App1Deserializedstuff.Name,
                $oApplicApp1Deserializedstuffation.Version,
                $oRegistrySetting.LogicalName,
                $oRegistrySetting.SettingDataType,
                $oRegistrySetting.SourceType,
            [bool]0 )
                # setting bool 0 as false
            if ($oSettingRef -ne $null) { write-verbose " oSettingRef object Created"} else {write-warning " oSettingRef object Creation failed"; break}

            #Registry Setting must satisfy the following rule
                $oSettingRef.MethodType = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemSettingMethodType]::Value
                if ($PropertyPath -ne "NULL"){
                    $oSettingRef.PropertyPath = $PropertyPath
                }
                #$oSettingRef
                
                   if (!($ConstantValue)){
                $ConstantValue = $true
                $ConstantDataType = "boolean"
                #$PropertyPath = 'RegistryValueExists'
                #$Operator = 'isEquals'
                $oSettingRef.PropertyPath = 'RegistryValueExists'
                $oSettingRef.SettingDataType = [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::Boolean
            } else {
                $ConstantDataType = $RegistryKeyValueDataType
            }                                
                 $operandDataType = [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::$ConstantDataType
                 $oConstValue = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ConstantValue($ConstantValue, $operandDataType)                
                   if ($oConstValue -ne $null) { write-verbose " oConstValue object Created"} else {write-warning " oConstValue object Creation failed";break}

                $oRegistrySettingOperands = new-object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection``1[[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ExpressionBase]]
                $oRegistrySettingOperands.Add($oSettingRef)
                $oRegistrySettingOperands.Add($oConstValue)                             
                 
                $RegistryCheckExpression = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.Expression(
                [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ExpressionOperators.ExpressionOperator]::$Operator, $oRegistrySettingOperands)
            
                #$RegistryCheckExpression = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.Expression("isEquals",$oRegistrySettingOperands)

                $oRule = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.Rule("IsInstalledRule", 
                [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.NoncomplianceSeverity]::$NoncomplianceSeverity, $null, $RegistryCheckExpression)
                   if ($oRule  -ne $null) { write-verbose " rule object Created"} else {write-warning " rule object Creation failed"; break}

                #$oEnhancedDetection.ChangeId()
                $oEnhancedDetection.Rule = $oRule 

                $DTR = $oEnhancedDetection
    #return $oEnhancedDetection


   #Set the detection method to the deserialized application
   $i = 0
    foreach ($DT in $App1Deserializedstuff.DeploymentTypes){
    write-verbose "Analying $($DT.Title)"
     if ($DT.Title -eq $DeploymentTypeName){
        write-verbose "Adding Enhanced detection type to application $($ApplicationName) and deploymentType $($DeploymentTypeName)"
        
        $App1Deserializedstuff.DeploymentTypes[$i].Installer.DetectionMethod = [Microsoft.ConfigurationManagement.ApplicationManagement.DetectionMethod]::Enhanced
        $App1Deserializedstuff.DeploymentTypes[$i].Installer.EnhancedDetectionMethod = $DTR
        continue
      }else{
        $i++
     }
  }

# save the application.
$wrapper.InnerAppManObject = $App1Deserializedstuff

$factory.PrepareResultObject($wrapper)
$wrapper.InnerResultObject.Put()
Pop-Location
} -ArgumentList $RegistryHyve,$RegistryKey,$RegistryKeyValue,$RegistryKeyValueDataType,$Is64bit,$ApplicationName,$DeploymentTypeName,$ConstantValue,$ConstantDataType,$Operator,$SccmServer,$site
}


Function Wrappackage($PackageID,$CatalogName,$WrapFolderPath)
{  
 $WrapID=-1   
 
    if($WrapFolderPath -eq $Null)
        {   
            $OutputPath=  "select propertyValue from ASoptions where propertyName='PSOutputLocation'" 
            $Wrapoutputloc = ExecuteSQLQuery $OutputPath $CatalogName 
            If ($Wrapoutputloc -contains “[InstallLocation]WrappedPackages”)
            {
                $WrapFolderPath = $AdminStudioSharedLocation +'WrappedPackages' 
            }
            else
            { $WrapFolderPath = $WrapoutputLoc
            }
           $WrapPackagestatus = Invoke-ASWrapPackage -PackageID $PackageID -WrapType $WrapType -ErrorAction SilentlyContinue                                   
        }
        else
        {           
            $WrapPackagestatus = Invoke-ASWrapPackage -PackageID $PackageID -WrapType $WrapType -OutputLocation $WrapFolderPath -ErrorAction SilentlyContinue           
        }       

    if($WrapPackagestatus -match 'success' -or $WrapPackagestatus -match 'Given package is already wrapped' -or $WrapPackagestatus -match 'Run Tests - Complete.')
    {        
        $strPkgQuery =  "select OriginalMsiFileName from cstblpackage where RowID=$PackageID"
        $strPackage = ExecuteSQLQuery $strPkgQuery $CatalogName
        $strPackage =[io.path]::GetFileNameWithoutExtension("$strPackage")    
        $wrapfolder= $strPackage+'_'+$PackageID
        $WrapFolderPath= $WrapFolderPath+ '\' +$wrapfolder
        #$strWrapQuery =  "select Rowid from cstblpackage where OriginalPackageLocation='$WrapFolderPath'"
		$strWrapQuery =  "select ParentPkgRowID_ from ASCMSuitePackages where PkgRowID_ = '$PackageID'"
        $WrapID = ExecuteSQLQuery $strWrapQuery $CatalogName    
     }
    else
    {
        $WrapID=-1
        write-host 'Package doesnt have a valid name or structure'
        
    }
    return $WrapID
}

Function SCCM_GetCID($AppID,$SessionID)
{       
       #$SCCMServerName='10.80.150.95'
       #$SCCMSiteCode= 'AR3'
       $DepList  = Invoke-Command -Session $SessionID -ScriptBlock{
       param([string]$AppID,$SCCMServerName,$SCCMSiteCode)
       Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
       $SCCMNameSpace= "root\sms\site_$SCCMSiteCode"  
       $PSdefaultParameterValues=@{"Get-wmiobject:namespace"=$SCCMNameSpace;"Get-wmiobject:computername"=$SCCMServerName}                        
       $CID = (Get-WmiObject -Namespace $SCCMNameSpace -query "select * from sms_application" -ComputerName $SCCMServerName | Where{$_.ModelName -eq $AppID}).CI_ID                                 
         return  $CID                        
        } -ArgumentList $AppID,$SCCMServerName,$SCCMSiteCode
       return  $DepList
 }

Function updatexml($xmlPath,$Placeholder,$ExpectedSCCMids)
 {
 $XmlScript= Get-Content $xmlPath
 if($Placeholder.Length -eq $ExpectedSCCMids.Length)
 {
   for($i=0;$i -le $Placeholder.Length;$i++)
        {
            $XmlScript=$XmlScript -replace($Placeholder[$i],$ExpectedSCCMids[$i])
        }
        Set-Content $xmlPath $XmlScript
 }
 else
 {
    WriteResultsToFile $logFile "Placeholders is not equal to ExpectedSCCMids" -1 0
 }
 }


 function Process_SCCMImport_CSV($csvFileLocation,$CatalogName,$PkgID,$Flag, $sessionID)
{
    $Retval=-1

    #$AppID=AS_GetSCCMAppID $CatalogName $PkgId
    If(Test-Path $csvFileLocation)
    {
        $CSVcontent=Import-Csv $csvFileLocation                   

        $CSVcontent | ForEach-Object{ 
        if($Flag -eq 'Import')
        {
            
                #Fetching data from AS       
                
                    If($_.AS_GET_API -ne '<N.A>')
                    {
                        $_.AS_GET_API= [String]$_.AS_GET_API.replace("<PkgID>",$PkgID)          
                        $_.AS_VALUE = [String](ExecuteAPICmd $_.AS_GET_API $CatalogName)
                    }
                    
                    
                else
                {
                    $_.SCCMIMPORTSTATUS='Failed'
                }

                #Compare AS and SCCM values
                
                    If(([string]$_.SCCM_VALUE).trim() -eq ([string]$_.AS_VALUE).Trim())
                    {
                        $_.SCCMIMPORTSTATUS="Passed"
                    }
                    else
                    {
                        $_.SCCMIMPORTSTATUS="Failed"
                        $Failure= $_.PROPERTY+" value mismatch with Application Manager and SCCM :Failed"
                        Add-Content -Path $logFile -Value $Failure
                    }
                                   
        }
        elseif($Flag -eq 'ReImport')
        {
             #Fetching Data from SCCM  
                If($_.AS_GET_API -ne '<N.A>')
                    {
                        $_.AS_GET_API= [String]$_.AS_GET_API.replace("<PkgID>",$PkgID)          
                        $_.NEW_AS_VALUE = [String](ExecuteAPICmd $_.AS_GET_API $CatalogName)
                    }                    
                    
                else
                {
                    $_.SCCMREIMPORTSTATUS='Failed'
                }
                
                #Compare AS and SCCM values
                
                    If(([string]$_.NEW_SCCM_VALUE).trim() -eq ([string]$_.NEW_AS_VALUE).Trim())
                    {
                        $_.SCCMREIMPORTSTATUS="Passed"
                    }
                    else
                    {
                        $_.SCCMREIMPORTSTATUS="Failed"
                        $Failure= $_.PROPERTY+" value mismatch with Application Manager and SCCM :Failed"
                        Add-Content -Path $logFile -Value $Failure
                    }                                   
                              
        }
        
        } #end of foreach 

        $CSVcontent |Export-Csv -Path $csvFileLocation -Force -NoTypeInformation
        $retval=0        
    } 
      
    return $retval      
}


Function updatecsv($csvFilePath,$Placeholder,$ExpectedSCCMids,$Flag)
 {
$Retval=-1
 If(Test-Path $csvFilePath)
    {
        if($Placeholder.Length -eq $ExpectedSCCMids.Length)
        {
            $CSVcontent=Import-Csv $csvFilePath
            $CSVcontent | ForEach-Object{
            if($Flag -eq 'Import')
            {

                    for($i=0;$i -le $Placeholder.Length;$i++)
                    {
                        $_.SCCM_VALUE= [String]$_.SCCM_VALUE.replace($Placeholder[$i],$ExpectedSCCMids[$i]) 
                    }
            } 
            elseif($Flag -eq 'ReImport')
            {
                for($i=0;$i -le $Placeholder.Length;$i++)
                    {
                        $_.NEW_SCCM_VALUE= [String]$_.NEW_SCCM_VALUE.replace($Placeholder[$i],$ExpectedSCCMids[$i]) 
                    }
            }       
         }
         $CSVcontent |Export-Csv -Path $csvFilePath -Force -NoTypeInformation
         $retval=0 
         }
        else
        {
            WriteResultsToFile $logFile "Placeholders is not equal to ExpectedSCCMids" -1 0
        }        
    }
     return $retval
 }

     
Function ASCreateApplicationFromSCCMXML($XMLPath,$SCCM_ConnectionName,$TargetGroup,$SCCMAppid)
{
try{
        if($SCCMAppid)
        {
            $result=Invoke-ASCreateApplicationFromSCCMXML -XMLPath $XMLPath -ConnectionName $SCCM_ConnectionName -TargetGroup $TargetGroup -SCCMApplicationID $SCCMAppid
        }
        else
        {
            $result=Invoke-ASCreateApplicationFromSCCMXML -XMLPath $XMLPath -ConnectionName $SCCM_ConnectionName -TargetGroup $TargetGroup
        }
        
   
        If($result.contains("Application"))
        {
            return $result
        }
        else 
        {
            return -1
        }
    }
Catch{
        Add-Content -Path $logFile -Value "Unable to create Application in SCCM using XML"
        return -1
     }
return $result
}

Function ASImportAppFromDeploymentSystem($SCCM_ConnectionName,$CID)
{
try{
        $result=Invoke-ASImportAppFromDeploymentSystem -ConnectionName $SCCM_ConnectionName -SystemDeploymentID $CID
        $pkgid = $result.RowID
        return $pkgid
    }
Catch{
        Add-Content -Path $logFile -Value "Unable to create Application in SCCM using XML"
        return -1
     }
return $pkgid
}

<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Function name   :    AddAppModelData($Type,$XmlPath,$SourcePackageID,$TargetPackageID)
  Description     :    This Function adds UserRequirement, DeviceRequirement, Dependency and Supersedence types of Appmodeldata to a given package using API's.
  Input Parameters:    $Type=Type of Appmodeldata, $xmlpath, $SourcePackageID=Package to which Appmodeldata is added, $TargetPackageID= Dependency or Supersedence Package
  Created Date    :    11/06/2018
  Last Modified   :    By:----
  Last Modified   :    Date:--- 
  Author          :    Sharvani T Hiremath #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>

Function AddAppModelData()
{
param(
[Parameter(Mandatory=$true)]$Type,
[Parameter(Mandatory=$true)][String]$XmlPath,
[Parameter(Mandatory=$true)][String]$SourcePackageID,
[Parameter(Mandatory=$false)][String]$TargetPackageID
)
$xml=New-Object XML
$xml.Load($XmlPath)
Switch($Type)
    {

        UserRequirement
        {
            $global:UserRequirementID=Set-ASAppModelData -PackageId $SourcePackageID -Type Requirement -XmlPath $XmlPath
            WriteResultsToFile $logFile "Adding UserRequirement" ($UserRequirementID -gt 0) $true
        }

        DeviceRequirement
        {
            $global:DeviceRequirementID=Set-ASAppModelData -PackageId $SourcePackageID -Type Requirement -XmlPath $XmlPath
            WriteResultsToFile $logFile "Adding DeviceRequirement" ($DeviceRequirementID -gt 0) $true
        }

        Dependency
        {
            $xml.SelectNodes("//Dependency//DependencyHelper//PackageId")[0].InnerText=$TargetPackageID
            $xml.Save($XmlPath)
            $global:DependencyID=set-ASAppModeldata -PackageId $SourcePackageID -type Dependency -XmlPath $XmlPath
            WriteResultsToFile $logFile "Adding Dependency" ($DependencyID -gt 0) $true
        }

        Supercedence
        {
            $xml.SelectNodes("//Supersedence//SupersedenceHelper//SupersededPackage")[0].InnerText=$TargetPackageID
            $xml.Save($XmlPath)
            $global:SupersedenceID=Set-ASAppModelData -PackageId $SourcePackageID -Type Supercedence -XmlPath $XmlPath
            WriteResultsToFile $logFile "Adding Supercedence" ($SupersedenceID -gt 0) $true
        }
	    ReturnCodes
        {
            $global:ReturnCodesID=Set-ASAppModelData -PackageId $SourcePackageID -Type ReturnCode -XmlPath $XmlPath
            WriteResultsToFile $logFile "Adding ReturnCodes" ($ReturnCodesID -gt 0) $true
        }

        DetectionMethod
        {
            $global:DetectionmethodID=Set-ASAppModelData -PackageId $SourcePackageID -Type DetectionMethod -XmlPath $XmlPath
            WriteResultsToFile $logFile "Adding DetectionMethod" ($DetectionmethodID -gt 0) $true
        }


    }

}
<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Function name   :    Function UpdateAppModelData($Type,$XmlPath,$PackageID,$Node1,$Node2,$Node3)
  Description     :    This Function updates UserRequirement, DeviceRequirement, Dependency and Supersedence types of Appmodeldata using API's.
  Input Parameters:    $Type=Type of Appmodeldata, $xmlpath, $PackageID=Package to which Appmodeldata is added, $Node1, $Node2, $Node3 -> NodeValues of Xml to update the values.
  Created Date    :    13/06/2018
  Last Modified   :    By:----
  Last Modified   :    Date:--- 
  Author          :    Sharvani T Hiremath #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>
Function UpdateAppModelData
{
param(
[Parameter(Mandatory=$true)]$Type,
[Parameter(Mandatory=$true)][String]$XmlPath,
[Parameter(Mandatory=$true)][String]$PackageID,
[Parameter(Mandatory=$false)][String]$Node1,
[Parameter(Mandatory=$false)][String]$Node2,
[Parameter(Mandatory=$false)][String]$Node3
)
$xml=New-Object XML
$xml.Load($XmlPath)
Switch($Type)
    {

        UserRequirement
        {
            $xml.SelectNodes("//UserRequirementHelper//Id")[0].InnerText =$UserRequirementID
            $xml.SelectNodes("//UserRequirementHelper//Value")[0].InnerText =$Node1
            $xml.Save($XmlPath)
            $URId=Set-ASAppModelData -PackageId $PackageID -Type Requirement -XmlPath $XmlPath
            WriteResultsToFile $logFile "Updating UserRequirement" ($URId -gt 0) $true
        }

        DeviceRequirement
        {
            $xml.SelectNodes("//DeviceRequirementHelper//Id")[0].InnerText = $DeviceRequirementID
            $xml.SelectNodes("//DeviceRequirementHelper//Value")[0].InnerText =$Node1
            $xml.SelectNodes("//DeviceRequirementHelper//Operator")[0].InnerText=$Node2
            $xml.Save($XmlPath)
            $DRId=Set-ASAppModelData -PackageId $PackageID -Type Requirement -XmlPath $XmlPath
            WriteResultsToFile $logFile "Updating DeviceRequirement" ($DRId -gt 0) $true
        }

        Dependency
        {
            $xml.SelectNodes("//Dependency//Id")[0].InnerText = $DependencyID
            $xml.SelectNodes("//Dependency//DependencyHelper//AutoInstall")[0].InnerText =$Node1
            $xml.Save($XmlPath)
            $DId=set-ASAppModeldata -PackageId $PackageID -type Dependency -XmlPath $XmlPath
            WriteResultsToFile $logFile "Updating Dependency" ($DId -gt 0) $true
        }

        Supercedence
        {
            $xml.SelectNodes("//Supersedence//SupersedenceHelper//Id")[0].InnerText= $SupersedenceID
            $xml.SelectNodes("//Supersedence//SupersedenceHelper//Uninstall")[0].InnerText= $Node1
            $xml.Save($XmlPath)
            $SId=Set-ASAppModelData -PackageId $PackageID -Type Supercedence -XmlPath $XmlPath
            WriteResultsToFile $logFile "Updating Supercedence" ($SId -gt 0) $true
        }
	
	    ReturnCodes
        {
            $xml.SelectNodes("//ReturnCodeHelper//Id")[0].InnerText=$ReturnCodesID
            $xml.SelectNodes("//ReturnCodeHelper//Name")[0].InnerText=$Node1
            $xml.Save($XmlPath)
            $RID=Set-ASAppModelData -PackageId $PackageID -Type ReturnCode -XmlPath $XmlPath
            WriteResultsToFile $logFile "Updating ReturnCodes" ($RId -gt 0) $true
        }

        DetectionMethod
        {
            $xml.SelectNodes("//DetectionMethod//RegistryDetectionMethodHelper//Id")[0].InnerText=$DetectionmethodID
            $xml.SelectNodes("//DetectionMethod//RegistryDetectionMethodHelper//DataType")[0].InnerText=$Node1
            $xml.SelectNodes("//DetectionMethod//RegistryDetectionMethodHelper//Value")[0].InnerText=$Node2
            $xml.Save($XmlPath)
            $DMId=Set-ASAppModelData -PackageId $PackageID -Type DetectionMethod -XmlPath $XmlPath
            WriteResultsToFile $logFile "Updating Detectionmethod" ($DMId -gt 0) $true
        }

   }

}



<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Function name   :    Function Activate($Sn)
  Description     :    This Function is used to Activate Admin Studio using serial key 
  Input Parameters:    $Sn is the Activation Code
  Created Date    :    1/8/2018
  Last Modified   :    By:----
  Last Modified   :    Date:--- 
  Author          :    Shikha Sahu #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>

function Activate ($Sn)

{
    return (Start-Process -FilePath $sActivationExe -ArgumentList "-serial_number$Sn -silent" -Wait -PassThru).ExitCode
}


<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Function name   :    Function ReturnLicense($Sn)
  Description     :    This Function is used to return the Licenses when Admin Studio is activated using serial key
  Input Parameters:    $Sn is the Activation Code
  Created Date    :    1/8/2018
  Last Modified   :    By:----
  Last Modified   :    Date:--- 
  Author          :    Shikha Sahu #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>


function ReturnLicense ($Sn)

{
    return (Start-Process -FilePath $sActivationExe -ArgumentList "-return -silent" -Wait -PassThru).ExitCode
}

<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Function name   :    LicenseFeaturetest ([string] $Features, [int] $Expected)
  Description     :    This Function is used to validate the licensed features when Admin Studio is activated using serial key
  Input Parameters:    $Features is the features in Admin Studio activated for the serial key, $Expected is the expected count of feature failures
  Created Date    :    
  Last Modified   :    By:Shikha Sahu
  Last Modified   :    Date:1/8/2018
  Author          :    Mike Marino #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>

function LicenseFeaturetest ([string] $Features, [int] $Expected)

{
[int] $Error = 0
if ($Features.Length -eq 0)
  {
    Write-Host " No Features to test:" $Feature -foregroundcolor yellow
    #Add-Content -Path $logFile -Value "No feature to test - $Feature" -PassThru
  }
else
  {
    $FeatureArray = $Features.split(" ")
    foreach ($Feature in $FeatureArray)
     {
        #Write-Host $Feature
        [int] $ReturnCode = (Start-Process -FilePath $sActivationExe -ArgumentList "-test_checkout$Feature -test_ignore_eval" -Wait -PassThru).ExitCode
        if ($ReturnCode -eq $Expected)
           {
              Write-Host "Success" $Feature -foregroundcolor gray
              #Add-Content -Path $logFile -Value "Successfully validated feature - $Feature" -PassThru
           }
        else
           {
              Write-Host " Failure line failed Test:" $Feature -foregroundcolor red
              #Add-Content -Path $logFile -Value "Failed to validate feature - $Feature" -PassThru
              $Error ++
           }
      } 
  }
return $Error
}

<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Function name   :    LicenseIdentification($sASLicType, $global:Type)
  Description     :    This Function check the type of license activated in Admin Studio. Also Catalogs are created here for respective licensed versions.
  Input Parameters:    $sASLicType is the registry entry 'LSProductID, $global:Type is the type of license
  Created Date    :    1/8/2018
  Last Modified   :    By:----
  Last Modified   :    Date:--- 
  Author          :    Shikha Sahu #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>

function LicenseIdentification($sASLicType, $global:Type)

{
  #cd $sCurrentLoc
  invoke-expression -command "cd $ProjectFolder"
  $ISCMIDE = $sAsLoc + '\ISCMIDE.exe' 
  #Start-Process 'C:\Program Files (x86)\AdminStudio\2018\Common\ISCMIDE.exe'
  Start-Process $ISCMIDE
  Start-Sleep -s 10
  $Result = 'Fail'
  $sASLicType          = (Get-ItemProperty $shive $slicenseType).$slicenseType
  $ProcessCount        = 0
  If ($sASLicType -Like "*ARM*")  
    {
       $global:CatalogName  = 'ARM_License_Test'
       $global:Type = "ARM Enterprise License"
       Write-Host "The license is activated with ARM Enterprise Subscription License"
       #Add-Content -Path $logFile -Value "The license is activated with ARM Enterprise Subscription License" -PassThru
       $Result = 'Pass'
    }
  ElseIf ($sASLicType -Like "*PRO*")
    {
       $global:CatalogName  = 'Professional_License_Test'
       $global:Type = "Professional License"
       Write-Host "The license is activated with Professional License"
       #Add-Content -Path $logFile -Value "The license is activated with Professional License" -PassThru
       $Result = 'Pass'
    }  
  ElseIf ($sASLicType -Like "*STN*") 
    {
       $global:Type = "Standard License"
       Write-Host "The license is activated with Standard License"
       #Add-Content -Path $logFile -Value "The license is activated with Standard License" -PassThru
       $Result = 'Pass'
    }
   ElseIf ($sASLicType -Like "*EVAL*")  
    {
       $global:CatalogName  = 'AdminStudio Evaluation Catalog'
       $global:Type = "Eval Mode"
       Write-Host "The license is activated with Eval Mode"
       #Add-Content -Path $logFile -Value "The license is activated with Eval Mode" -PassThru
       $Result = 'Pass'
    }
   ElseIf ($sASLicType -Like "*ENT*")
    {
       $global:CatalogName  = 'Enterprise_License_Test'
       $global:Type = "Enterprise License"
       Write-Host "The license is activated with Enterprise License"
       #Add-Content -Path $logFile -Value "The license is activated with Enterprise License" -PassThru
       $Result = 'Pass'
    } 
   Else
    {
       Write-Host "The license is not identified"
       #Add-Content -Path $logFile -Value "The license is not identified" -PassThru
    }
   
   If ($global:Type -eq "Eval Mode")
    {
       $retval = ConnectToCatalog($global:CatalogName)
    }
   ElseIf ($global:Type -eq "Standard License")
    {
        Write-Host "Standard License does not have Application Manager. Hence Catalog Creation is not needed."
        #Add-Content -Path $logFile -Value "Standard License does not have Application Manager. Hence Catalog Creation is not needed." -PassThru
        $retval = 0 
    }
   else 
    {
        $ConnectionString    = 'PROVIDER=SQLNCLI11;Data Source=' +$SQLServer +';Initial Catalog=' + $global:CatalogName + ';Integrated Security=SSPI;'
        $sAsLoc              = (Get-ItemProperty $shive $slocation).$slocation
        $sCurrentLoc         = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
        $sAsLoc              = @{$true=$sAsLoc;$false=$sAsLoc +'\'}[$sAsLoc.EndsWith("\")]
        $sAsLoc              = Join-Path $sAsLoc "Common"
        cd $sAsLoc
        $SRFlag = 0
        #create a new catalog 
        $retval=CreateNewCatalog $global:CatalogName $SRFlag
        if ($retval -eq 0)
            {
            Write-Host (Write-Header) "Create new catalog - $CatalogName is Successful" 
            #Add-Content -Path $logFile -Value "Successfully created catalog $CatalogName" -PassThru
            ConnectToCatalog($global:CatalogName)
            }
        else
            {
            Write-Host (Write-Header) "Create new catalog - $CatalogName is Failed"
            #Add-Content -Path $logFile -Value "Create new catalog - $CatalogName is Failed" -PassThru
            Exit 1
            }
    }

   if (($Result -ne 'Fail') -and ($retval -eq 0))
    {
        return 0
    }
   else
    {
        return -1
    }
}

<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Function name   :    ValidateFeatures($ProcessCount, $global:Type)
  Description     :    This Function launches the enabled tools in Admin Studio and Counts the Processes running
  Input Parameters:    $ProcessCount is the count of processes running after launching tools in Admin Studio, $global:Type is the type of license activated
  Created Date    :    1/8/2018
  Last Modified   :    By:----
  Last Modified   :    Date:--- 
  Author          :    Shikha Sahu #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>


function ValidateFeatures($ProcessCount, $global:Type)
{
$ProcessCount = 0
$Result = 'Fail'
$Process = $null
invoke-expression -command "cd $ProjectFolder"


    If (($global:Type -eq 'Eval Mode') -or ($global:Type -eq 'Enterprise License')  -or ($global:Type -eq 'ARM Enterprise License'))
    {
        If ( (Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit" )
        {
        $computers = “C:ProcessEnt.csv”
        }
        else 
        {
        $computers = “C:ProcessEnt32Bit.csv”
        }
        $a = Import-Csv C:ProcessEnt.csv | Measure-Object
        $RowCount = $a.count
        for ($i=0; $i -lt $RowCount; $i++)
            {
                $output=(import-csv $computers)[$i]
                $Path = $output.Path
                Start-Process $Path
            }
    }
    ElseIf ($global:Type -eq 'Professional License')
    {
    If ( (Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit" )
        {
        $computers = “C:ProcessPro.csv”
        }
        else
        {
        $computers = “C:ProcessPro32Bit.csv”
        }
        $a = Import-Csv C:ProcessPro.csv | Measure-Object
        $RowCount = $a.count
        for ($i=0; $i -lt $RowCount; $i++)
        {
            $output=(import-csv $computers)[$i]
            $Path = $output.Path
            Start-Process $Path
        }
    }
    ElseIf ($global:Type -eq 'Standard License')
    {
     If ( (Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit" )
        {
        $computers = “C:ProcessStn.csv”
        }
        else 
        {
        $computers = “C:ProcessStn32Bit.csv”
        }
        $a = Import-Csv C:ProcessStn.csv | Measure-Object
        $RowCount = $a.count
        for ($i=0; $i -lt $RowCount; $i++)
        {
            $output=(import-csv $computers)[$i]
            $Path = $output.Path
            Start-Process $Path
        }
    }
    Else
    {
        Write-Host "CSV File not found in the specified location"
    }
        Start-Sleep -s 100
        $taskSnapshot = gwmi -cn localhost -class win32_process
        $taskList = @()
        foreach ($task in $taskSnapshot)
        {
            $taskProps = @{
            'SID'=$task.SessionId
            'Name'=$task.ProcessName
            'PID'=$task.ProcessId}
            $taskObject = New-Object -TypeName PSObject -Property $taskProps
            $taskList += $taskObject
        }
        taskList | Out-GridView

    if (($global:Type -eq "Enterprise License") -or ($global:Type -eq "Eval mode") -or ($global:Type -eq "ARM Enterprise License"))
    {
        $GetProcessRepack = Get-Process repack
        $GetProcessQM = Get-Process isqm
        $GetProcessTuner = Get-Process iside
        $GetProcessAIW = Get-Process AIW
        $GetProcessISCMIDE = Get-Process ISCMIDE 
        $GetProcessProcessTemplateEditor = Get-Process ProcessTemplateEditor
        $GetProcessAdminStudio = Get-Process ISCMIDE
        $GetProcessDistributer = Get-Process Distributer 
        $GetProcessIsdev = Get-Process isdev
        $GetProcessVirtualEditor = Get-Process VirtualEditor
        $GetProcessOSSnapshot = Get-Process OSSnapshot
        $GetProcessAacxide = Get-Process Aacxide
    }

    ElseIf($global:Type -eq "Professional License")
    {
        $GetProcessRepack = Get-Process repack
        $GetProcessQM = Get-Process isqm
        $GetProcessTuner = Get-Process iside
        $GetProcessAIW = Get-Process AIW
        $GetProcessISCMIDE = Get-Process ISCMIDE 
        $GetProcessAdminStudio = Get-Process ISCMIDE
        $GetProcessDistributer = Get-Process Distributer 
        $GetProcessIsdev = Get-Process isdev
        $GetProcessVirtualEditor = Get-Process VirtualEditor
        $GetProcessOSSnapshot = Get-Process OSSnapshot
        $GetProcessAacxide = Get-Process Aacxide
    }
    Else
    {
        #$GetProcessISCMIDE = Get-Process ISCMIDE
        #$GetProcessISCMIDE.Kill() 
        $GetProcessRepack = Get-Process repack
        $GetProcessTuner = Get-Process iside
        $GetProcessAIW = Get-Process AIW 
        $GetProcessIsdev = Get-Process isdev
        $GetProcessVirtualEditor = Get-Process VirtualEditor
        $GetProcessAacxide = Get-Process Aacxide
     }
        $ProcessNames = @("repack.exe","isqm.exe","AIW.exe","ISCMIDE .exe","ProcessTemplateEditor.exe","ISCMIDE.exe","Distributer.exe","isdev.exe","VirtualEditor.exe","OSSnapshot.exe","Aacxide.exe","iside.exe")
        $GetProcesses = @($GetProcessRepack,$GetProcessQM,$GetProcessAIW,$GetProcessISCMIDE,$GetProcessProcessTemplateEditor,$GetProcessAdminStudio,$GetProcessDistributer,$GetProcessIsdev,$GetProcessVirtualEditor,$GetProcessOSSnapshot,$GetProcessAacxide,$GetProcessTuner)
        $CountProcessNames = $ProcessNames.Count
        for ($i=0; $i -lt $CountProcessNames; $i++)
        {
            $task.ProcessName = $ProcessNames[$i]
            if($GetProcesses[$i] -ne $null)
            {
                $ProcessCount = $ProcessCount + 1
                #Write-Host $ProcessCount
            }
        }

   #Killing the Process
    if (($global:Type -eq 'Eval Mode') -or ($global:Type -eq  'Enterprise License') -or ($global:Type -eq 'ARM Enterprise License'))
    {
        $KillProcesses = @($GetProcessRepack,$GetProcessQM,$GetProcessTuner,$GetProcessAIW,$GetProcessISCMIDE,$GetProcessProcessTemplateEditor,$GetProcessDistributer,$GetProcessIsdev,$GetProcessVirtualEditor,$GetProcessOSSnapshot,$GetProcessAacxide)
        $CountKillProcesses = $KillProcesses.Count
        for ($i=0; $i -lt $CountKillProcesses; $i++)
        {
            $KillProcesses[$i].Kill()
        }
    }
    ElseIf($global:Type -eq 'Professional License')
    {
        $KillProcesses = @($GetProcessRepack,$GetProcessQM,$GetProcessTuner,$GetProcessAIW,$GetProcessISCMIDE,$GetProcessDistributer,$GetProcessIsdev,$GetProcessVirtualEditor,$GetProcessOSSnapshot,$GetProcessAacxide)
        $CountKillProcesses = $KillProcesses.Count
        for ($i=0; $i -lt $CountKillProcesses; $i++)
        {
            $KillProcesses[$i].Kill()
        }
    }
    Else
    {
        $KillProcesses = @($GetProcessRepack,$GetProcessTuner,$GetProcessAIW,$GetProcessIsdev,$GetProcessVirtualEditor,$GetProcessAacxide)
        $CountKillProcesses = $KillProcesses.Count
        for ($i=0; $i -lt $CountKillProcesses; $i++)
        {
            $KillProcesses[$i].Kill()
        }
    }
    If (($ProcessCount -eq 12) -and ($global:Type -eq 'Eval Mode'))
    {
        $Process = "Eval Mode Activation launches all the necessary tools. Hence validation of features is successful."
        $Result = 'Pass'
        #Add-Content -Path $logFile -Value "Eval Mode Activation launches all the necessary tools. Hence validation of features is successful." -PassThru
    }
    ElseIf (($ProcessCount -eq 12) -and ($global:Type -eq "Enterprise License"))
    {
        $Process = "Enterprise Activation launches all the necessary tools. Hence validation of features is successful."
        $Result = 'Pass'
        #Add-Content -Path $logFile -Value "Enterprise Activation launches all the necessary tools. Hence validation of features is successful." -PassThru
    }
    ElseIf (($ProcessCount -eq 12) -and ($global:Type -eq "ARM Enterprise License"))
    {
        $Process = "ARM Enterprise Activation launches all the necessary tools. Hence validation of features is successful."
        $Result = 'Pass'
        #Add-Content -Path $logFile -Value "ARM Enterprise Activation launches all the necessary tools. Hence validation of features is successful." -PassThru
    }
    ElseIf (($ProcessCount -eq 11) -and ($global:Type -eq "Professional License"))
    {
        $Process = "Professional Activation launches all the necessary tools. Hence validation of features is successful."
        $Result = 'Pass'
        #Add-Content -Path $logFile -Value "Professional Activation launches all the necessary tools. Hence validation of features is successful." -PassThru
    }
    ElseIf (($ProcessCount -eq 6) -and ($global:Type -eq "Standard License"))
    {
        $Process = "Standard Activation launches all the necessary tools. Hence validation of features is successful."
        $Result = 'Pass'
        #Add-Content -Path $logFile -Value "Standard Activation launches all the necessary tools. Hence validation of features is successful." -PassThru
    }
    else 
    {
        $ProcessFailed = "Test failed."
        #Add-Content -Path $logFile -Value "Validation of features Failed" -PassThru
    }
    if (($Result -ne 'Fail') -and ($Process -ne $null))
    {
        return 0
    }
    else
    {
        return -1
    }
}


<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Function name   :    EvalTPSConfigInfo
  Description     :    This Function validates the features activated for Eval mode
  Input Parameters:    
  Created Date    :    1/8/2018
  Last Modified   :    By:----
  Last Modified   :    Date:--- 
  Author          :    Shikha Sahu #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>

function EvalTPSConfigInfo

{
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
        return $returnVal
}
<#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Function name: ASCatalogUpgrade($DBDetailsCSV,$logFile)
  Description: This Function upgrades to the Current Version of AdminStudio Installed in the machine
  Input Parameters:($DBDetailsCSV,$logFile)
  Created Date: 3/09/2018
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Shashikiran S
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- #>

Function ASCatalogUpgrade ($DBDetailsCSV)
 {
  $retvalRestore=0
  $retvalupgrade=0
  $IntRetVal=0
  writeResultsToFile $logFile "The ASCatalog Upgrade has Started" 
  $CurrentVersion=Get-ItemProperty -path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\InstallShield\AdminStudio" -Name "CurrentVersion"
  $MinorVersionNumber=Get-ItemProperty -path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\InstallShield\AdminStudio\16.0" -Name "BuildNumber"
  
      If(Test-Path $DBDetailsCSV)
      {         
        $CSVcontent=Import-Csv $DBDetailsCSV
        $CSVcontent | 
        ForEach-Object{   
             try {
        
                   $EnableUpgrade=$_.EnableUpgrade
       
                   if($EnableUpgrade -eq 'yes')
                     {
                        $CatalogName=$_.FromDB
                        #Checking for an Existing Catalog,If exists then delete the Catalog
                        DeleteCatalog $CatalogName
                        $TempBakfilepath=$_.SourceDBPath
                        $BakFilePath=$TestDataSource+$TempBakfilepath
                        $SupportedMajorVersion=$CatalogName.Split("_")
                        $FinalSupportedMajorVersion=$SupportedMajorVersion.Split(".")
                        $TargetMajorVersion=$CurrentVersion.CurrentVersion
                        $TargetMajorVersion=$TargetMajorVersion.Split(".")
                        $SupportedMinorVersionNumber=$MinorVersionNumber.BuildNumber.Split(";")
                        $FinalSupportedMinorVersionNumber=$SupportedMinorVersionNumber
                        $LastFinalSupportedMinorVersionNumber=$FinalSupportedMinorVersionNumber.Split(".")
                    
                              if([int]$FinalSupportedMajorVersion[1] -le [int]$TargetMajorVersion[0])
                               {  
                                  $FinalSupportedMinorVersion =$FinalSupportedMajorVersion[1]+'.'+$FinalSupportedMajorVersion[2]
                                  $FinalTargetMinorVersion=$LastFinalSupportedMinorVersionNumber[0]+'.'+$LastFinalSupportedMinorVersionNumber[1]

                                      if([Single]$FinalSupportedMinorVersion -lt [Single]$FinalTargetMinorVersion)
                                         {
                                            #Restores the Catalog 
                                            $RestoreRetVal=RestoreDB $CatalogName $BakFilePath
                                            if($RestoreRetVal -eq $null)
                                              {
                                                $retvalRestore=0                                                
                                              }

                                            elseif ($RestoreRetVal -eq -1)
                                              {
                                               $retvalRestore=-1
                                               return
                                              }
                         
                                          }

                                      
                                             #Connects To the Catalog
                                             $retConval=ConnectToCatalog($CatalogName)
                                             WriteResultsToFile $logFile "Connected to Catalog $CatalogName :" $retConval 0
                                             #Upgrades the Catalog      
                                             $Output =  Set-ASCatalog
                                             if ($Output -contains "Upgrade of catalog ""$CatalogName"" Succeeded")
                                                {
                                                     $retvalupgrade=0
                                                     WriteResultsToFile $logFile "Upgrade of $CatalogName to $TargetVersion is completed:" $retvalupgrade 0
                                                     $_.UpgradeStatus='Passed'
                                                }             
                                             elseif ($Output -like '*Failed*')
                                                 { 
                                                    $retvalupgrade=-1   
                                                    WriteResultsToFile $logFile "$CatalogName is at the same level as the requested upgrade of $TargetVersion :" $retvalupgrade 0 
                                                    $_.UpgradeStatus='Skipped'
                                                 }
                               }
                                               
                     }

                 elseif(([int]$FinalSupportedMajorVersion[0] -gt [int]$TargetMajorVersion[0]))
                      {
                         $retvalupgrade=0    
                         WriteResultsToFile $logFile "$CatalogName is above the $TargetMajorVersion :" $retvalupgrade 0
                         $_.UpgradeStatus='Skipped'
                         writeResultsToFile $logFile "Restoring DB $CatalogName is not required as it is above the $TargetMajorVersion"  $retvalupgrade 0
                      }
        
                 else         
                {
                  $retvalupgrade=0   
                  WriteResultsToFile $logFile "Catalog upgrade Skipped as EnableUpgrade is not set to "Yes" in CSV " $retvalupgrade 0
                  $_.UpgradeStatus='Skipped'
                }
               
                }
           catch 
                { 
                    $retvalupgrade=-1   
                    WriteResultsToFile $logFile "Error occured while processing the upgrade of $CatalogName" $retvalupgrade 0
                    WriteResultsToFile $logFile $Error 
                }  
              
   if(($retvalRestore -eq -1) -or ($retvalupgrade -eq -1))
     {
          $IntRetVal=-1
     }
         
   }
 }
 
 else
 {
 $IntRetVal=-1
 }  
      if($IntRetVal -eq -1)
      {
      $CSVcontent |Export-Csv -Path $DBDetailsCSV -Force -NoTypeInformation
      writeResultsToFile $logFile "The ASCatalog Upgrade has been Completed " $IntRetVal 0
      return $IntRetVal
      }
      else
      {
      return $IntRetVal      
      }
 }
 
<#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Function name: RestoreDB($CatalogName,$BakFilePath)
  Description: This Function Restores the specific DB provided by the path
  Input Parameters:($CatalogName,$BakFilePath)
  Created Date: 3/09/2018
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Shashikiran S 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>

 Function RestoreDB ($CatalogName,$BakFilePath)
{
   $RestoreRetVal=0
    if(($BakFilePath -ne $null)-and (Test-path $BakFilePath))
     { 
             $Restore=Restore-SqlDatabase -ServerInstance $SQLServer -Database $CatalogName -BackupFile $BakFilePath 
    if($Restore -eq $null)
        {  
             writeResultsToFile $logFile "Restoring of DB $CatalogName is Successful " $RestoreRetVal 0
             $RestoreRetVal=0
        }
     }
   elseif(($BakFilePath -eq $null) -and ($Restore -ne $null))
        {
             $RestoreRetVal=-1
             writeResultsToFile $logFile  "Operating system error 2 The system cannot find the file specified " $RestoreRetVal 0
        }
   else

   {
     $RestoreRetVal=-1
     writeResultsToFile $logFile $Error $RestoreRetVal 0
   } 
  
 return $RestoreRetVal
}


<#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Function name: SCCMDeleteAllApplicationsInAFolder($SCCMServerName,$UserName,$Password,$Sitecode,$TargetFolder)
  Description: This Function takes the folder name as input and deletes all the applications present under it. It makes use of 
  Input Parameters:$SCCMServerName,$UserName,$Password,$Sitecode,$TargetFolder
  Created Date: 06/09/2018
  Last Modified By:----
  Last Modified Date:--- 
  Author    : Chiranjeevi M
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>
Function SCCMDeleteAllApplicationsInAFolder($SCCMServerName,$UserName,$Password,$Sitecode,$TargetFolder)
{
   
   $EnablePSRemoting=Enable-PSRemoting -Force
   $SetFireWallStatus=netsh advfirewall set allprofiles state off
   $WinRmQUickConfig=winrm quickconfig
   $TrustedHosts=winrm s winrm/config/client '@{TrustedHosts="*"}'
   $SessionID=Create_RemotePSSession $SCCMServerName $UserName $Password
   Invoke-Command -Session $SessionID -ScriptBlock {Param($SCCMServerName,$Sitecode,$TargetFolder)

                      $SitecodeDrive=$Sitecode+":"
                      Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'  
                      Set-Location $SitecodeDrive
                      $Folders=gwmi -Namespace root\sms\site_AR3 -Class SMS_ObjectContainerNode
                      Write-Host 'Folders present under Application Node in SCCM:' $SCCMServerName are $Folders.Name

                      if($Folders.Name -contains $TargetFolder)
                      {
                      foreach($Name in $Folders)
                            {

                              if($Name.Name -eq $TargetFolder)
                                {
                                 Write-Host 'Target Folder name:'$Name.Name
                                 $ContainerNodeId=$Name.ContainerNodeID
                                 
                                 Write-Host 'Getting Applications in the folder:'$Name.Name
                                
                                 $Instancekeys = (Get-WmiObject -ComputerName $SCCMServerName -Namespace “ROOT\SMS\Site_$Sitecode” -query “select InstanceKey from SMS_ObjectContainerItem where ObjectType='6000' and ContainerNodeID='$ContainerNodeId'”).instanceKey
                                  
                                 if($Instancekeys -ne $null)
                                    {
                                
                                         foreach ($key in $Instancekeys)
                                                {
     
                                                 $AppName=(Get-WmiObject -ComputerName $SCCMServerName -Namespace “ROOT\SMS\Site_$Sitecode” -Query “select * from SMS_Applicationlatest where ModelName = '$key'”).LocalizedDisplayName
                                                 $App=(Get-WmiObject -ComputerName $SCCMServerName -Namespace “ROOT\SMS\Site_$Sitecode” -Query “select * from SMS_Applicationlatest where ModelName = '$key'”).ModelName
                                                 Write-Host 'Removing Application:'$AppName
                                                 Remove-CMApplication -ModelName $App -Force
                                                 Write-Host 'Application:'$AppName' Successfully removed from Folder:' $Name.Name
                                                }
                                   }

                                  else
                                    {
                                     Write-Host 'No Applications present to remove in the Folder:' $Name.Name
                                    }
  
                               }
                              

                            }
   
                      }
                      else
                      {
                       Write-Host 'Specified folder:' $TargetFolder 'is not present on the SCCM:'$SCCMServerName
                      }
                        
    }-ArgumentList $SCCMServerName,$Sitecode,$TargetFolder

    Remove-PSSession $SessionID
}


<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Function name   :    CreateDistributionPointGroup($GroupName)
  Description     :    This function creates a distribution point group by the specified name on SCCM.
  Input Parameters:    $GroupName
  Output Parameters:   '0' if group creation is successful and '-1' if it doesn't
  Created Date    :    10/1/2018
  Last Modified   :    By:----
  Last Modified   :    Date:--- 
  Author    : Tathvik Tejas #>
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>
Function CreateDistributionPointGroup($GroupName)
{
    if([string]::IsNullOrEmpty($GroupName))
    {
     $GroupName = $SCCMDPGroup   #pick value from Global variable file.
    }    
    $RetVal = -1
    $SQLServer = $SCCMServerName    
    $GuidID = [Guid]::NewGuid()
    $CreateDPGroupQuery = "INSERT INTO DistributionPointGroup (ID,Name,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn,Description,SourceSite) values ('{$GuidID}','$GroupName','$UserName','','','','','$SCCMSiteCode')"
    $GetExistingDPGroupQuery = "SELECT * FROM DistributionPointGroup WHERE Name = '$GroupName'"  
    try
    {
        $RetVal = ExecuteSQLQuery $GetExistingDPGroupQuery $SCCMDB 
        if([string]::IsNullOrEmpty($RetVal)) #check if DP group exists.
        {
            $RetVal = ExecuteSQLQuery $CreateDPGroupQuery $SCCMDB #create DP group, if it doesn't exist.
            if($RetVal -eq 0)
            {                        
                return 0
            }
            else
            {                
                return -1
            }
        }
        else #make use of the existing DP group.
        {
            return 0             
        }                
    }
    catch
    {        
        Add-Content -Path $logFile -Value "GeneralException $_"
        return -1
    }                                                                        
}