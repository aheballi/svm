. C:\TestSetDev\Tests\AS_Powershell_Library.ps1

Start-Process AdminStudioHost
Start-Sleep 30


###############################################################
# Input required from users
###############################################################
#$DefaultWD          =  @('*.zip')
$DefaultMSI         =  @('*.MSI')
#$DefaultIPA         =  @('*.IPA')
#$DefaultMac         =  @('*.PKG')
$DefaultExe         =  @('*.EXE')
#$folderWD           = "\\10.80.150.184\Automation_TestData\Analyze\WrapSuiteExe_ShimDB\Packages\WDPackages"
$folderMSI	        = "\\10.80.150.184\Automation_TestData\Analyze\WrapSuiteExe_ShimDB\Packages\MSIPackages"
#$folderIPA	        = "\\10.80.150.184\Automation_TestData\Analyze\WrapSuiteExe_ShimDBP\ackages\AppleIOSPackages"
#$folderMac	        = "\\10.80.150.184\Automation_TestData\Analyze\WrapSuiteExe_ShimDB\Packages\AppleMacPackages"
$folderExe          = "\\10.80.150.184\Automation_TestData\Analyze\WrapSuiteExe_ShimDB\Packages\SuiteExePackages"
#$TestResultFile     = "\\10.80.150.184\Automation_TestData\Analyze\WrapSuiteExe_ShimDBTests\TestResults.txt"
If ( (Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit" )
{
    $TestResultFile     = "\\10.80.150.184\Automation_TestData\Analyze\WrapSuiteExe_ShimDB\WrapTestResults_64.txt"
}
else
{
    $TestResultFile     = "\\10.80.150.184\Automation_TestData\Analyze\WrapSuiteExe_ShimDB\WrapTestResults_32.txt"
}

$global:CatalogName = '18WrapSuiteExe_ShimDB'
$global:TestErrorCount = 0

#CopyInnoSetupDll
   $dllInnosetup = "innounp.exe"
   $strDLLSourcePath = "\\10.80.150.184\Automation_TestData\Analyze\WrapSuiteExe_ShimDB\SuiteEXEDLLS\InnoSetup\" + $dllInnosetup
   $DLLFolder = "C:\Program Files (x86)\AdminStudio\2019\Common\Tools"
   $DllFile = "C:\Program Files (x86)\AdminStudio\2019\Common\Tools\" + $dllInnosetup

  

#$global:RTestErrorCount = 0
$ConnectionString   = 'PROVIDER=SQLOLEDB.1;Data Source=' +$SQLServer +';Initial Catalog=' + $global:CatalogName + ';Integrated Security=SSPI;'

###############################################################
# Non-User Settings
###############################################################
[string]$sMajorVersionNo    =  "18.0"
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
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' [018WrapSuiteExe_ShimDB]'
    return $Header
}

function Import ($s)
{
    $f = [System.IO.File]::GetAttributes($s)
    $d = ($f -band [System.IO.FileAttributes]::Directory)
    if (!$d)
    {

        #SelectAllRules $global:CatalogName 1
     


        $obj = Invoke-ASImportPackage -PackagePath $s
        
        #$obj = Invoke-ASImportPackage -PackagePath "\\10.80.150.184\Automation_TestData\Analyze\WrapSuiteExe_ShimDBPackages\SuiteExePackages\NullSoft\Paint.NET.3.5.3.Install.exe"
        $id=$obj.RowId
        write-host $id
        if ($obj.GetType().FullName -eq 'AdminStudio.Platform.Helpers.PackageHelper')
        {

           #SelectAllRules $global:CatalogName 0

           $global:oPkgArray = $global:oPkgArray + $obj
           $wrapid = Wrappackage $id $global:CatalogName $Null
           Write-Host $wrapid
           $Wrapobj = Get-aspackage -packageId $wrapid
           Test $Wrapobj
        }
        else
        {
            Write-Host (Write-Header) 'Failed to import:' $s -foregroundcolor red
            $global:oPkgArrayError = $global:oPkgArrayError + $obj
        }
    }
} 

Function Wrappackage($PackageID,$CatalogName,$WrapFolderPath)
{  
 $WrapID=-1   
 
    if($WrapFolderPath -eq $Null)
        {            
            $ASsharelocation          = "Shared Location"
            $defaultwrappedOutputFilesloc = (Get-ItemProperty $shive $ASsharelocation).$ASsharelocation
            $wrappedOutputFilesloc=   $defaultwrappedOutputFilesloc+'WrappedPackages' 
            $WrapPackagestatus = Invoke-ASWrapPackage -PackageID $PackageID -WrapType $WrapType
        }
        else
        {
            $WrapPackagestatus = Invoke-ASWrapPackage -PackageID $PackageID -WrapType $WrapType -OutputLocation $WrapFolderPath
        }
    
    $ActualPkgQuery =  "Select PkgRowID_ from ASCMSuitePackages where PkgRowID_=$PackageID"
    $ActualpkgID = ExecuteSQLQuery $ActualPkgQuery $CatalogName

    if($WrapPackagestatus -match 'success' -or $ActualpkgID-eq $PackageID -or 'Run Tests - Complete.' )
    {        
        $strPkgQuery =  "select OriginalMsiFileName from cstblpackage where RowID=$PackageID"
        $strPackage = ExecuteSQLQuery $strPkgQuery $CatalogName
        $strPackage =[io.path]::GetFileNameWithoutExtension("$strPackage")    
        $wrapfolder= $strPackage+'_'+$PackageID
        $WrapFolderPath= $wrappedOutputFilesloc+ '\' +$wrapfolder
        $strWrapQuery =  "select Rowid from cstblpackage where OriginalPackageLocation='$WrapFolderPath'"
        $WrapID = ExecuteSQLQuery $strWrapQuery $CatalogName    
     }
    elseif($WrapPackagestatus -match 'Given package is already wrapped')
    {
        $WrapID=-1
        write-host 'Wrap already done'
        #WriteResultsToFile $logFile "Wrap already done" -1 0
    }
    else
    {
        $WrapID=-1
        write-host 'Package doesnt have a valid name or structure'
        #WriteResultsToFile $logFile "Package doesnt have a valid name or structure" -1 0
    }
    return $WrapID
}  

function ImportFolder ($folder, $extension)
{    
    if ($folder)
    {
        foreach ($file in Get-Childitem -include $extension -Recurse $folder) 
        {
            Import ($file)
        }
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

function TestError ([string] $TestId, [string] $Tests)
{
    [int] $Error = 1
    if ($TestId.Length -eq 0)
    {
         Write-Host " No error to test"
    }
    else
    {
      $TestArrary = $Tests.split(" ")
      foreach ($Test in $TestArrary) 
      {
          if ($Test -eq $TestId)
          {
             $Error = 0
          }
      }
    }
    return $Error
}

function Test ($o)
{
   
    $OSIssues=0
    $ICEIssues=0
    $ResIssues=0
    $Total = 0
    $FoundProductMatch = 0
    $TtlFailures=0
    $TtlResolvables=0
    $oTest = Test-ASPackage -PackageId $o.RowID -DetailedResults 
    foreach ($oTestResult in $oTest.TestResults) 
    {
        
        if ($oTestResult.Category -NotLike '*ICE'){
        $OSIssues=$OSIssues + 1
        }
        Else{
        $ICEIssues=$ICEIssues+1
        }
    
        If($oTestResult.IsFixable -eq 'TRUE'){
        $ResIssues= $ResIssues + 1
        }

        $TestResults = Import-Csv $TestResultFile 
        $Total = $Total + 1
        foreach ($Result in $TestResults) 
        {
            if ($Result.PackageName -eq $o.ProductName)
            {
                $Error = TestError $oTestResult.TestId $Result.AllowedFailures
                if ($Error -eq 1)
                {
                    Write-Host (Write-Header) "Undeclared error or warning detected" $o.ProductName $oTestResult.TestId
                    $global:TestErrorCount = $global:TestErrorCount + 1
                }
                else
                {
                    #Write-Host (Write-Header) 'Testing Package: Success'
                }
                $TtlFailures=$Result.TotalFailures
                $TtlResolvables=$Result.TotalResolvables
                $FoundProductMatch = 1
            }
        }
   }
   Write-Host (Write-Header) 'Tested Package:' $o.DisplayedProductName '[' $o.Flags ']' -nonewline -foregroundcolor white
   Write-Host 'total resolvable issues are :' $TtlResolvables ' Actual:' $ResIssues -foregroundcolor yellow
   
          
   if ($Total -eq 0)
   {
        #Write-Host (Write-Header) 'Failed Found 0 errors in package (There should be at least one):' $o.DisplayedProductName -foregroundcolor red
        #$global:TestErrorCount = $global:TestErrorCount + 1
		Write-Host ''
   }
   elseif ($Total -ne $TtlFailures)
   {
        Write-Host 'Errors/Warnings count mismatch. Expected:' $TtlFailures ' Actual:' $Total -foregroundcolor yellow
   }
   else
   {
        Write-Host 'Total Errors and Warnings:'  $Total -foregroundcolor yellow
   }
   
   if ($FoundProductMatch -eq 0)
    {
            Write-Host (Write-Header) 'Failed find product in Test Results INI:' $o.DisplayedProductName -foregroundcolor red
            $global:TestErrorCount = $global:TestErrorCount + 1
    }
	else
	{
   
		If ($o.IsMsi -eq 'True' -And $ResIssues -gt 0)
		{
			Write-Host (Write-Header) 'Total ICE:'  $ICEIssues -foregroundcolor yellow
			Write-Host (Write-Header) 'Total OS:'  $OSIssues -foregroundcolor yellow

			If($ResIssues -ne $TtlResolvables)
			{
				Write-Host (Write-Header) 'Total Resolvable Errors/Warnings count mismatch. Expected:' $TtlResolvables ' Actual:' $ResIssues -foregroundcolor yellow
			}
			else
			{
				Write-Host (Write-Header) 'Total Resolvable Errors/Warnings:'  $ResIssues -foregroundcolor yellow
			}
            
			ResolveIssues $o
        }
		else 
		{
            Write-Host (Write-Header) 'No isssues to resolve for this package type :' $o.DisplayedProductName
		}
	}

}

function ResolveIssues ($r){
 
    $ResolveSummary = Resolve-ASPackage -PackageId $r.RowID
 
    $FixTransformLoc = $ResolveSummary.FixTransformPath
    write-host (Write-Header) 'Fix Transform Path :' $FixTransformLoc -ForegroundColor white
 
    If(Test-path -path $FixTransformLoc)
    {
        ReTestAfterResolve $r.RowID
    }
    else
    {
        Write-Host (Write-Header) 'Failed to fix issues for:'  $o.ProductName  -foregroundcolor red
    }
 
}  


function ReimportPackagewithFixTrans ($r, $FixTransformLoc)

{
        $robj = Invoke-ASImportPackage -PackagePath $r.FileName -Transforms $FixTransformLoc -ExistingPackageId $r.RowId
        if ($robj.GetType().FullName -eq 'AdminStudio.Platform.Helpers.PackageHelper')
        {
            #$global:oPkgArray = $global:oPkgArray + $robj
            Write-host (Write-Header) 'Reimport of package is successfull'
            ReTestAfterResolve $robj
        }
        else
        {
            Write-Host (Write-Header) 'Failed to import package after resolving of issues:' $r.FileName -foregroundcolor red
            #$global:oPkgArrayError = $global:oPkgArrayError + $robj
        }

}

function ReTestAfterResolve($Reimport){
    $OSCount=0
    $ICECount=0
    $Resolvables=0
    $RTotal = 0
    $Fixables=@()
    
    $RTest = Test-ASPackage -PackageId $Reimport.RowID -DetailedResults 
    foreach ($RTestResult in $RTest.SuiteExeTests) 
    {
       
        if ($RTestResult.Category -NotLike '*ICE'){
        $OSCount=$OSCount + 1
        }
        else{
        $ICECount=$ICECount+1
        }
    
        If($RTestResult.IsFixable -eq 'TRUE'){
        $Resolvables= $Resolvables + 1
        $fixables +=$RTestResult.TestId
        }

        $RTestResults = Import-Csv $TestResultFile 
        $RTotal = $RTotal + 1
        foreach ($RResult in $RTestResults) 
        {
            if ($RResult.PackageName -eq $Reimport.ProductName)
            {
                $Error = TestError $RTestResult.TestId $RResult.AllowedFailuresafterresolve
                if ($Error -eq 1)
                {
                    Write-Host (Write-Header) "Undeclared error or warning detected after resolving of issues" $Reimport.ProductName $RTestResult.TestId
                    #$global:RTestErrorCount = $global:RTestErrorCount + 1
                }
                else
                {
                    #Write-Host (Write-Header) 'ReTesting Package: Success'
                }
                $ResolveTotalFailures= $RResult.TotalFailuresafterresolve
               
            }
        }
   }
   
   
   if ($RTotal -eq 0)
   {
        Write-Host (Write-Header) 'Failed Found 0 errors in package (There should be at least one):' $Reimport.DisplayedProductName -foregroundcolor red
        $global:RTestErrorCount = $global:RTestErrorCount + 1
   }   
   elseif ( $RTotal -ne $ResolveTotalFailures)
   {
        Write-Host (Write-Header) 'Total Errors/Warnings count mismatch as Expected is :' $ResolveTotalFailures ' Actual is :' $RTotal -foregroundcolor yellow
   }
   else
   {
        Write-Host (Write-Header) 'Total Errors/Warnings after resolving of issues:'  $RTotal -foregroundcolor yellow
   }

   Write-Host (Write-Header) 'Total ICE after resolving of issues:'  $ICECount -foregroundcolor yellow
   Write-Host (Write-Header) 'Total OS after resolving of issues:'  $OSCount -foregroundcolor yellow
        
   If($Resolvables -ne 0)
   {
        Write-Host (Write-Header) 'Failed to resolve issues '  -foregroundcolor yellow
   
        foreach ($Fix in $Fixables | Select -Uniq)
        {
            Write-Host $Fix -ForegroundColor Red
        }   
   }
   else
   {
        Write-Host (Write-Header) 'Total Resolvable Errors/Warnings after resolving issues:'  $Resolvables -foregroundcolor yellow          
   }
}

<#
function CreateNewCatalog ($Name)
{
    $global:oPkgArray   = @()
    $global:CatalogName = 'New_WrapPackage_Tests5' + $Name
    $result = New-ASCatalog -CatalogName $global:CatalogName
}
#>

function DisplayPackage([int] $LevelPack, $Package)
{ 
    if ($Package.RowId -ne 0)
    {
        #Write-Host ($Package.RowId)
        $global:nPackageCount = $global:nPackageCount + 1
    }
}

function DisplayApplicationGroups ([int]$Level, $Group)
{ 
    foreach ($item in $Group)
    {
       if ($item.Description -eq 'Application Group')
       {
			DisplayApplications $Level (Get-ASCatalogItem -ItemId $item.RowId -ItemType 'Application')
       }
       else
       {
			DisplayApplicationGroups ($Level + 1) (Get-ASCatalogItem -ItemId $item.RowId -ItemType 'Group')
       }
    }
}

function DisplayApplications([int]$LevelApp, $Applications)
{ 
    foreach ($Package in $Applications)
    {
          DisplayPackage $LevelApp (Get-ASCatalogItem -ItemId $Package.RowId -ItemType 'Package')
    }
}

function DisplayPackageTree ()
{
    DisplayApplicationGroups 0  (Get-ASCatalogItem -ItemId 1 -ItemType 'Group')
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
cd $sAsLoc

try
{
   PrepAS
   Write-Host (Write-Header) 'Test Start'

   CopyTestDataLocally $strDLLSourcePath $DLLFolder 0
   #CopyTestDataLocally $strDLLSourcePathInstallAnywhere $DLLFolderInstallAnywhere 0


   CreateNewCatalog $global:CatalogName 0
   Write-Host (Write-Header) 'Database Create: Success'
   
   write-host (Write-Header)'Selecting all tests for catalog' $global:CatalogName
   $USQL= "Update ASTest SET TestStatus=1"
   $t=ExecuteSQLQuery $USQL $global:CatalogName
   

   #ImportFolder $folderWD $DefaultWD 
   ImportFolder $folderExe $DefaultExe
   ImportFolder $folderMSI $DefaultMSI 
   #ImportFolder $folderIPA $DefaultIPA
   #ImportFolder $folderMac $DefaultMac 
  

   if ($global:oPkgArrayError.Count -eq 0)
   {
       # Write-Host (Write-Header) 'Package Import: Success'
   }
   else
   {
       Write-Host (Write-Header) 'Packages that Import Succeeded:' $global:oPkgArray.Count
       Write-Host (Write-Header) 'Packages that Import Failed:' $global:oPkgArrayError.Count 
       Write-Host (Write-Header) ' Package Import: FAILED'
       ExitWithFailure
   }

   if ($global:TestErrorCount -eq 0 )
   {
        Write-Host (Write-Header) 'Package Testing: Success'
   }
   else
   {
       Write-Host (Write-Header) 'Package Testing: FAILED'
       ExitWithFailure
   }
   
   DisplayPackageTree
   if ($global:oPkgArray.Count -eq $global:nPackageCount)
   {
       #DeleteCatalog  $global:CatalogName
       Write-Host (Write-Header) 'Package Display: Success'
       Write-Host (Write-Header) 'Test Succeeded'
	   Get-Process AdminStudioHost | Stop-Process
	   exit 0
   }
   else
   {
       Write-Host (Write-Header) 'Package Display:Items with issues Found:' $global:nPackageCount
	   Get-Process AdminStudioHost | Stop-Process
	   Write-Host (Write-Header) 'Test Succeeded'
	   exit 0
       
   }
   #Delete Innoup Dll
   remove-item -path $DllFile -force
   Get-Process AdminStudioHost | Stop-Process
   exit 0

}
catch
{
   Write-Host (Write-Header) 'FAILED'
   Get-Process AdminStudioHost | Stop-Process
   ExitWithFailure
}


