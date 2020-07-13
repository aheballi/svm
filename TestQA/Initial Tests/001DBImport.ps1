###############################################################
# Input required from users
###############################################################
$DefaultExt         =  @('*.msi','*.sft','*.appv','*.ipa','*.apk','*.exe','*.zip','*.dmg','*.pkg')
$folder             = "C:\code\demo\"
$DeepLinkTestFile   = "C:\TestSetDev\Tests\Deeplinks.txt"
$global:CatalogName = 'Test14'
$ConnectionString   = 'PROVIDER=SQLOLEDB.1;Data Source=localhost;Initial Catalog=' + $global:CatalogName + ';Integrated Security=SSPI;'

###############################################################
# Non-User Settings
###############################################################
[string]$sMajorVersionNo    = $args[0]
[int]$global:nPackageCount    = 0
$shive              = 'HKLM:\SOFTWARE\Wow6432Node\InstallShield\AdminStudio\' + $sMajorVersionNo  +'\'
$slocation          = "Product Location"
$sAsLoc             = (Get-ItemProperty $shive $slocation).$slocation
$sCurrentLoc        = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$sAsLoc             = @{$true=$sAsLoc;$false=$sAsLoc +'\'}[$sAsLoc.EndsWith("\")]
$sAsLoc             = Join-Path $sAsLoc "Common"
$global:oPkgArray   = @()
$global:oPkgArrayError = @()
$global:oPkgArrayPass = @()
$global:oPkgArrayFail = @()

###############################################################
# Functions
###############################################################
function Write-Header ()
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' [001DBImport]'
    return $Header
}

function Import ($s)
{
    $f = [System.IO.File]::GetAttributes($s)
    $d = ($f -band [System.IO.FileAttributes]::Directory)
    if (!$d)
    {
        # Write-Host 'Importing:' $s -foregroundcolor white
        $obj = Invoke-ASImportPackage -PackagePath $s
        if ($obj.GetType().FullName -eq 'AdminStudio.Platform.Helpers.PackageHelper')
        {
            $global:oPkgArray = $global:oPkgArray + $obj
        }
        else
        {
            Write-Host (Write-Header) 'Failed to import:' $s -foregroundcolor red
            $global:oPkgArrayError = $global:oPkgArrayError + $obj
        }
    }
}

function ImportFolder ()
{    
    if ($folder)
    {
        #Write-Host 'Importing Applications from' $folder -foregroundcolor yellow
        foreach ($file in Get-Childitem -include $DefaultExt -Recurse $folder) 
        {
            Import ($file)
        }
        #Write-Host 'Packages that Import Succeeded:' $global:oPkgArray.Count
        #Write-Host 'Packages that Import Failed:' $global:oPkgArrayError.Count 
    }
}

function ImportDeepLinkURL ($URL)
{
    if ($URL)
    {
        $obj = Invoke-ASImportPackage -PackagePath $URL        
        if ($obj.GetType().FullName -eq 'AdminStudio.Platform.Helpers.PackageHelper')
        {
            $global:oPkgArray = $global:oPkgArray + $obj
        }
        else
        {
            Write-Host (Write-Header) 'Failured to import:' $URL -foregroundcolor red
            $global:oPkgArrayError = $global:oPkgArrayError + $obj
        }
    }
}

function ImportDeepLinkFromFile ()
{
   $Deeplinks = Import-Csv $DeepLinkTestFile 
   foreach ($Deeplink in $Deeplinks) 
   {       
       ImportDeepLinkURL($Deeplink.URL)
   }
}

function LoadDLL ($s)
{ 
    $FileName = Join-Path $sAsLoc $s
    import-module -name $FileName
}

function PrepAS ()
{    
    LoadDLL 'AdminStudio.Platform.PowerShellExtensions.dll'
    LoadDLL 'AdminStudio.Utilities.dll'
    LoadDLL 'AdminStudio.SCCM.Model.dll'
    LoadDLL 'AdminStudio.Services.Client.dll'
    LoadDLL 'AdminStudio.SCCM.Model.Disconnected.dll' 
    Set-ASConfigPlatform -ConnectionString   $ConnectionString
}

function Write-Host-Indent ()
{
    Write-Host '                 ' -nonewline
}

function Write-Host-Indent-Tree ([int] $Base)
{
    for ($i=0; $i -lt $Base; $i++)
    {
        Write-Host  '      '  -nonewline
    }
}

function CreateNewCatalog ($Name)
{
    $Name | Add-Content C:\TestLogPS.txt
    $global:oPkgArray   = @()
    $global:CatalogName = 'UnitTest' + $Name
    $global:CatalogName | Add-Content C:\TestLogPS.txt
    $result = New-ASCatalog -CatalogName $global:CatalogName
    $result | Add-Content C:\TestLogPS.txt
}

function DisplayPackage([int] $LevelPack, $Package)
{ 
    #Write-Host-Indent-Tree $LevelPack          
    #Write-Host  '      -  ' -nonewline -foregroundcolor Yellow
    #Write-Host  $Package.ProductName -nonewline -foregroundcolor white
    #Write-Host  ' ' -nonewline 
    #Write-Host  $Package.ProductVersion -nonewline -foregroundcolor yellow
    #Write-Host  ' ' -nonewline 
    #Write-Host  '[Type=' $Package.Flags ']'  -foregroundcolor blue -nonewline 
    #Write-Host  ' ' -nonewline 
    #Write-Host  '[RowId=' $Package.RowId ']'  -foregroundcolor gray
    if ($Package.RowId -ne 0)
    {
        $global:nPackageCount = $global:nPackageCount + 1
    }
}

function DisplayApplications([int]$LevelApp, $Applications)
{ 
    foreach ($Package in $Applications)
    {
          DisplayPackage $LevelApp (Get-ASCatalogItem -ItemId $Package.RowId -ItemType 'Package')
    }
}

function DisplayApplicationGroups ([int]$Level, $Group)
{ 
    foreach ($item in $Group)
    {
       Write-Host-Indent-Tree $Level
       if ($item.Description -eq 'Application Group')
       {
          #Write-Host  '   +  ' -nonewline -foregroundcolor Yellow
          #Write-Host  $item.GroupName -nonewline -foregroundcolor white
          #Write-Host  ' ' -nonewline 
          #Write-Host  '[RowId=' $item.RowId ']'  -foregroundcolor gray
          DisplayApplications $Level (Get-ASCatalogItem -ItemId $item.RowId -ItemType 'Application')
        }
        else
        {
          #Write-Host  '   +  ' -nonewline -foregroundcolor Yellow
          #Write-Host  $item.GroupName -foregroundcolor gray -nonewline 
          #Write-Host  ' ' -nonewline 
          #Write-Host  '[RowId=' $item.RowId ']'  -foregroundcolor gray
          DisplayApplicationGroups ($Level + 1) (Get-ASCatalogItem -ItemId $item.RowId -ItemType 'Group')
        }
    }
}

function DisplayPackageTree ()
{
    #Write-Host  '+  Applications'
    DisplayApplicationGroups 0  (Get-ASCatalogItem -ItemId 1 -ItemType 'Group')
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
	  cd $sCurrentLoc	
    Exit 1
}

################################################################
# Main Loop
###############################################################
try
{
   '001DBImportps1' | Add-Content C:\TestLogPS.txt
   $sAsLoc | Add-Content C:\TestLogPS.txt
   cd $sAsLoc
   $ConnectionString | Add-Content C:\TestLogPS.txt
   PrepAS
   $tBegin = Get-Date
   
   Write-Host (Write-Header) 'Test Start'  
   $args[1] | Add-Content C:\TestLogPS.txt
   CreateNewCatalog $args[1]
   Write-Host  (Write-Header) 'Database Create Success: ' (Write-Host-Timestamp) 

   ImportFolder
   Write-Host  (Write-Header) 'Package Import: ' (Write-Host-Timestamp)

   ImportDeepLinkFromFile
   Write-Host  (Write-Header) 'Package Deeplink Import: ' (Write-Host-Timestamp)
   
   if ($global:oPkgArrayError.Count -eq 0)
   {
       # Write-Host (Write-Header) 'Package Import: Success'
   }
   else
   {
       Write-Host (Write-Header) 'Packages that Import Succeeded:' $global:oPkgArray.Count
       Write-Host (Write-Header) 'Packages that Import Failed:' $global:oPkgArrayError.Count
       Write-Host (Write-Header) 'Package Import: FAILED'
       ExitWithFailure
   }
   
   DisplayPackageTree
   if ($global:oPkgArray.Count -eq $global:nPackageCount)
   {
       # Write-Host (Write-Header) 'Package Display: Success'
   }
   else
   {
       Write-Host (Write-Header) 'Package Display: FAILED Items Found:' $global:nPackageCount
       ExitWithFailure
   }
   Write-Host (Write-Header) 'Test Succeeded'
}
catch
{
   Write-Host (Write-Header) 'Failed (General Exception)'
   ExitWithFailure
}

cd $sCurrentLoc