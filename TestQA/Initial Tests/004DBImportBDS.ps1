###############################################################
# Input required from users
###############################################################
$DefaultExt           =  @('*.msi','*.sft','*.appv','*.ipa','*.apk','*.exe','*.dmg','*.pkg')
$folder               = "\\adminstudiofs\Cat\Software"
#$folder               = "C:\code\demo\Blender"
$DatabaseFile         = "C:\DailyDB.csv"
$DeepLinkTestFile     = "C:\Tests\Deeplinks.txt"
$global:CatalogName   = 'Daily_BDS'
#$global:CatalogName   = 'Daily_BDS123'
$global:connectionstring = "Data Source=localhost;User ID=isas\mmarino;Initial Catalog=Daily_BDS;Integrated Security=SSPI;"
$HostProcess          = "C:\Program Files (x86)\AdminStudio\2016\Common\AdminStudioHost.exe"
$connectionstringFNMS = "Data Source=isasfnms2012.isas.flexdev.com;User ID=sa;Initial Catalog=FNMS;password=Flexera!;"

###############################################################
# Non-User Settings
###############################################################
$global:nPkgPass         = 0
$global:nPkgFail         = 0
$global:nPkgPassFID      = 0
$global:nPkgFailFID      = 0

$global:WebServiceURL    = "http://localhost:8086/"
$global:WebServiceHeader = @{"ConnectionInfo"="Data Source=localhost;User ID=isas\mmarino;Initial Catalog=master;Integrated Security=SSPI;"} 

###############################################################
# Functions
###############################################################
function Write-Header ()
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' [004DBImportBDS]'
    return $Header
}

function SetDB ($DB)
{
	$global:CatalogName = $DB
    $Connect = "Data Source=localhost;User ID=isas\mmarino;Initial Catalog=" + $DB + ";Integrated Security=SSPI;"
    $global:WebServiceHeader     = @{"ConnectionInfo"=$Connect} 
}

function MakeURISafe ([string]$URI)
{
    $URISafeItem = [System.Uri]::EscapeDataString($URI)
	return [string]$URISafeItem
}

function MakeGroup ([string]$Path)
{
    $FolderFormat = Split-Path $Path -Parent
    $FolderMatch = $folder -replace "\\","_"
    $FolderFormat = $FolderFormat -replace "\\","_"
    $FolderFormat = $FolderFormat -replace $FolderMatch,""
    $FolderFormat = $FolderFormat.Trim("_")
    return [string] $FolderFormat
}

function ImportItem ($Item)
{
    if ($Item)
    {
        $Group = MakeGroup $Item
        $URL = $global:WebServiceURL + 'catalog/deploymenttypes/groups/' + $Group + '/?filepath=' + (MakeURISafe($Item))
        #Debugging Fun
        Write-Host (Write-Header) 'Importing:' $Item 
        #Write-Host (Write-Header) 'Importing:' $URL
        $result = Invoke-RestMethod $URL -Method POST -Header $global:WebServiceHeader 
        $error = WaitOnWebService ($result.response.data.data.Receipt.ReceiptID) 6000

        if ($error -eq 1)
        {
            $global:nPkgPass ++
        }
        else
        {
            Write-Host (Write-Header) 'Import Failure on:' $Item
            $global:nPkgFail ++
        }
    }
}

function ImportFile ($s)
{
    $f = [System.IO.File]::GetAttributes($s)
    $d = ($f -band [System.IO.FileAttributes]::Directory)
    if (!$d)
    {
        ImportItem($s)
    }
}

function ImportFolder ()
{    
    if ($folder)
    {
        foreach ($file in Get-Childitem -include $DefaultExt -Recurse $folder) 
        {
            ImportFile ($file)
        }
    }
}

function ImportDeepLinkFromFile ()
{
   $Deeplinks = Import-Csv $DeepLinkTestFile 
   foreach ($Deeplink in $Deeplinks) 
   {       
       ImportItem($Deeplink.URL)
   }
}

function CreateNewCatalog ($Name)
{
    [string]$CatalogName = $Name
    $URL = $global:WebServiceURL + 'catalog/' + (MakeURISafe($CatalogName)) 
    Write-Host (Write-Header) 'Creating DB through WebService:' $CatalogName
    Write-Host (Write-Header) 'URL:' $URL
    $result = Invoke-RestMethod $URL -Method POST -Header $global:WebServiceHeader 

    $error = WaitOnWebService ($result.response.data.data.Receipt.ReceiptID) 2000
    if ($error -eq 0)
    {
        Write-Host (Write-Header) 'Failed to create catalog'
        $global:nPkgFail ++
    }
    SetDB($CatalogName)
}

function WaitOnWebService ($ReceiptID, $Wait)
{
    $Done = 0
    $Seconds = 0
    $URL = $global:WebServiceURL + 'message/transactions/' + $ReceiptID + '/details'
    do
    {
          #Write-Host (Write-Header) 'URL:' $URL
          $resultWait = Invoke-RestMethod $URL -Method GET -Header $global:WebServiceHeader 
          $state = $resultWait.response.data.data.Receipt.State 
          if ($state -le 2)
          {
              Start-Sleep -s 4
              $Seconds = $Seconds + 4
          }
          #Write-Host (Write-Header) 'Waiting on WebService:' $ReceiptID : $state  
          if ($state -gt 2)
          {
              $Done = 1
          }
          if ($Seconds -gt $Wait)
          {
              $Done = 1
              Write-Host (Write-Header) 'Task timed out' $ReceiptID : $Seconds 
          }
    }
    while ($Done -eq 0)
    #Write-Host (Write-Header) 'Done' $state  -foregroundcolor gray
    if ($state -eq 3)
    {
        return 1
    }
    else
    {	
        return 0
    }
}

function Write-Host-Timestamp ()
{
    $tEnd = Get-Date
    $tDiff = $tEnd - $tBegin
    $return = 'Total Time:' + $tDiff.Hours + ':' + $tDiff.Minutes + ':' + $tDiff.Seconds
    $tBegin = Get-Date
    return $return
}

function ExitWithFailure()
{ 
    Write-Host (Write-Header) $_ 
    Write-Host (Write-Header)
    Exit 1

}

function ExecuteSql ($sql, $connectInfo)
{
    $Result = ''
    try
    {
        $connection = new-object system.data.SqlClient.SQLConnection($connectInfo)
        $command = $connection.CreateCommand()
        $command.CommandText = $sql 
        $Result = $connection.Open()
        $Result = $command.ExecuteNonQuery()
        if ($Result -ne 1)
        {
            Write-Host (Write-Header) ("Query Failed:" + $_)
        }
        $connection.Close()
    }
    catch
    {
        ExitWithFailure
    }
    return $Result
 }

function LogSoftware ($HashMap, $OID, $FlexeraID, $ASName, $ASVersion, $ASCompany, $ProductCode, $FileName)
{   
    # Generate Hash Values
    $MD5 = ""
    $SHA1 = ""
    $SHA256 = ""
    try
    {
        $MD5 = (Get-FileHash -Path $FileName -Algorithm MD5).Hash
        $SHA1 = (Get-FileHash -Path $FileName -Algorithm SHA1).Hash
        $SHA256 = (Get-FileHash -Path $FileName -Algorithm SHA256).Hash
    }
    catch
    {
        
    }

    # Look Up Flexera ID in FNMS
    $FNMSName = ""
    $FNMSVersion = ""
    $FNMSCompany = ""

    if ($FlexeraID -eq "Not connected to Flexera Service Gateway")
    {
        $global:nPkgFailFID ++
    }
    elseif ($FlexeraID -eq "Flexera Identifier not found")
    {
        $global:nPkgFailFID ++
    }
    elseif ([string]::IsNullorEmpty($FlexeraID))
    {
        $global:nPkgFailFID ++
    }
    else
    {
        $global:nPkgPassFID ++
        try
        {
            $connection = new-object system.data.SqlClient.SQLConnection($connectionstringFNMS)
            $command = $connection.CreateCommand()
            $command.CommandText = "SELECT SoftwareTitleName, ProductName, SoftwareTitleVersion, EditionName, Publisher from SoftwareTitleInfo where FlexeraID = '" + $FlexeraID +"'"
            $Result = $connection.Open()
            $command.CommandTimeout = 0
            $adapter = New-Object System.Data.SqlClient.SqlDataAdapter
            $adapter.SelectCommand = $command 
            $dataset = New-Object System.Data.DataSet
            $output = $adapter.Fill($dataset)
            #$DataSet.Tables[0].Rows | Format-Table
            # Write Header
            foreach ($Row in $DataSet.Tables[0].Rows)
            {
                #$Row.SoftwareTitleName
                $FNMSName = $Row.ProductName
                $FNMSVersion = $Row.SoftwareTitleVersion
                $FNMSCompany = $Row.Publisher
            }
        }
        catch
        {
        
        }
    }

    $Software = [PSCustomObject]@{
       OID        = [string]$OID
       FlexeraID  = [string]$FlexeraID
       ASName     = [string]$ASName
       ASVersion  = [string]$ASVersion
       ASCompany  = [string]$ASCompany
       FNMSName   = [string]$FNMSName
       FNMSVersion= [string]$FNMSVersion
       FNMSCompany= [string]$FNMSCompany
       ProductCode= [string]$ProductCode
       MD5        = [string]$MD5
       SHA1       = [string]$SHA1
       SHA256     = [string]$SHA256
       FileName   = [string]$FileName
       }
    $HashMap[$OID] = $Software
}

function CollectionToCSV ($HashMap, $FileName)
{
    $SimpleArray = @()
    foreach ($Item in $HashMap.GetEnumerator()) 
    {
         foreach ($SubItem in $Item.value)
         {
            $SimpleArray = $SimpleArray + $SubItem
         }        
    }
    Write-Host (Write-Header) "Writing data to file: " $FileName
    $SimpleArray | Export-Csv -path $FileName -NoTypeInformation
}

function ExecuteSqlGetDataSet ($sql, $connectInfo)
{
    $Result = ''
    try
    {
        $connection = new-object system.data.SqlClient.SQLConnection($connectInfo)
        $command = $connection.CreateCommand()
        $command.CommandText = $sql 
        $Result = $connection.Open()
        $command.CommandTimeout = 0
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $adapter.SelectCommand = $command 
        $dataset = New-Object System.Data.DataSet
        $output = $adapter.Fill($dataset)
        #$DataSet.Tables[0].Rows | Format-Table
        # Write Header
        $Software = New-Object Hashtable
        foreach ($Row in $DataSet.Tables[0].Rows)
        {
            try
            {
                LogSoftware $Software $Row.OID $Row.FlexeraID $Row.'Product Name' $Row.'Product Version' $Row.'Application Publisher' $Row.ProductCode $Row.'File Name'
            }
            catch
            {
                Write-Host (Write-Header) $_
            }
        }
        $connection.Close()
        CollectionToCSV $Software $DatabaseFile
    }
    catch
    {
        Write-Host (Write-Header) $Result
        ExitWithFailure
    }
    return $Result
 }


################################################################
# Main Loop
###############################################################
try
{
    $tBegin = Get-Date
    Write-Host (Write-Header) 'Test Start'
    
    CreateNewCatalog $global:CatalogName

    #Create FSG Information
    $Supress = ExecuteSql "INSERT INTO [dbo].[cssysConnectionInfo] ([Name] ,[Server] ,[ServerAuthentication],[Username],[Password],[Object],[Optional] ) VALUES  ('FlexeraBus' ,'Win10ASDemo.isas.flexdev.com', 0, 'admin' , '' , '', 0)" $connectionstring 
    $Supress = ExecuteSql "INSERT INTO [dbo].[cssysConnectionInfo] ([Name] ,[Server] ,[ServerAuthentication],[Username],[Password],[Object],[Optional] ) VALUES  ('FlexNetManagerPlatform' ,'', 0, '' , '', 'liayc5Jt0jmbP2rFr8xVPobylg+GQzpVQHiz8gWE7B+RDpLSWoVyA0G2yy/Pf5Eo' , 0)" $connectionstring
   
    # Recycle Host Process so FSG gets setup correctly
    Stop-Process -processname AdminStudioHost -Force -erroraction 'silentlycontinue'
    Start-Process -FilePath $HostProcess

    ImportFolder

    # Run the SQL, and dump the report to a Log
    $content = [IO.File]::ReadAllText("C:\TestSetDev\Tests\FIDReport.SQL")
    $Supress = ExecuteSqlGetDataSet $content $connectionstring
    Write-Host (Write-Header) 'Total Packages:' ($global:nPkgPassFID + $global:nPkgFailFID)
    Write-Host (Write-Header) '      Packages with FlexeraID:' $global:nPkgPassFID
    Write-Host (Write-Header) '      Packages without FlexeraID:' $global:nPkgFailFID

    # Log import Failures
    if ($global:nPkgFail -gt 0)
    {
	Write-Host (Write-Header) 'Packages that Import Succeeded:' $global:nPkgPass
	Write-Host (Write-Header) 'Packages that Import Failed:' $global:nPkgFail
        ExitWithFailure
    }
    Write-Host (Write-Header) 'Test Succeeded'
}
catch
{
    Write-Host (Write-Header) 'Failed (General Exception)'
    ExitWithFailure
}
