###############################################################
# Input required from users
###############################################################
$DefaultExt         =  @('*.msi','*.sft','*.appv','*.ipa','*.apk','*.exe','*.zip')
$folder             = "C:\code\demo\"
$DeepLinkTestFile   = "C:\Tests\Deeplinks.txt"
$global:CatalogName = 'Test14'

###############################################################
# Non-User Settings
###############################################################
$global:nPkgPass = 0
$global:nPkgFail = 0
$global:WebServiceURL        = "http://localhost:8086/"
$global:WebServiceHeader     = @{"ConnectionInfo"="Data Source=localhost;User ID=isas\mmarino;Initial Catalog=master;Integrated Security=SSPI;"} 

###############################################################
# Functions
###############################################################
function Write-Header ()
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' [003DBImportWS]'
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

function ImportItem ($Item)
{
    if ($Item)
    {
        $URL = $global:WebServiceURL + 'catalog/deploymenttypes/groups//?filepath=' + (MakeURISafe($Item))
        #Write-Host (Write-Header) 'Importing:' $Item $URL
        $result = Invoke-RestMethod $URL -Method POST -Header $global:WebServiceHeader 
        $error = WaitOnWebService ($result.response.data.data.Receipt.ReceiptID) 1000
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
    [string]$CatalogName = 'UnitTestWS' + $Name
    $URL = $global:WebServiceURL + 'catalog/' + (MakeURISafe($CatalogName)) 
    Write-Host (Write-Header) 'Creating DB through WebService:' $CatalogName
    Write-Host (Write-Header) 'URL:' $URL
    $result = Invoke-RestMethod $URL -Method POST -Header $global:WebServiceHeader 

    $error = WaitOnWebService ($result.response.data.data.Receipt.ReceiptID) 6000
    if ($error -eq 0)
    {
        Write-Host (Write-Header) 'Failed to create catalog'
	ExitWithFailure
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
    Exit 1
}

################################################################
# Main Loop
###############################################################
try
{
    $tBegin = Get-Date
    Write-Host (Write-Header) 'Test Start'
    
    CreateNewCatalog $args[1]
    #Write-Host (Write-Header) 'Database Create Success: ' (Write-Host-Timestamp)
   
    ImportFolder
    #Write-Host (Write-Header) 'Package Import: ' (Write-Host-Timestamp)

    #ImportDeepLinkFromFile
    #Write-Host  (Write-Header) 'Package Deeplink Import: ' (Write-Host-Timestamp)

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
