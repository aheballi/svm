###############################################################
# Input required from users
###############################################################
$DefaultExt         =  @('*.ps1')
$folder             = "tests"

###############################################################
# Non-User Settings
###############################################################
[string]$sMajorVersionNo    = $args[0]
$shive              = 'HKLM:\SOFTWARE\Wow6432Node\InstallShield\AdminStudio\' + $sMajorVersionNo  +'\'
$slocation          = "Product Location"
$sAsLoc             = (Get-ItemProperty $shive $slocation).$slocation
$sCurrentLoc        = [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$sAsLoc             = @{$true=$sAsLoc;$false=$sAsLoc +'\'}[$sAsLoc.EndsWith("\")]
$sAsLoc             = Join-Path $sAsLoc "Common"

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

function DropDatabase ($table, $connection)
{
    $sql = "ALTER DATABASE [$table] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
    ExecuteSql $sql $connection

    $sql = "DROP DATABASE [$table]"
    ExecuteSql $sql $connection
}

################################################################
# Main Loop
###############################################################
try
{
   'Testps1' | Add-Content C:\TestLogPS.txt
   $sAsLoc | Add-Content C:\TestLogPS.txt
   cd $sAsLoc   
   Start-Process AdminStudioHost.exe  
   cd $sCurrentLoc
   $sCurrentLoc | Add-Content C:\TestLogPS.txt
   $args | Add-Content C:\TestLogPS.txt  

   foreach ($file in Get-Childitem -include $DefaultExt -Recurse $folder) 
   {
       $file | Add-Content C:\TestLogPS.txt
       invoke-expression -Command "$file $args"
   }
   
   Stop-Process -processname AdminStudioHost -ErrorAction Stop

   # Cleanup DBs created in tests
   #Start-Sleep -s 120
   
   #$connectionstring = "Data Source=localhost;User ID=isas\mmarino;Integrated Security=SSPI;"
   #DropDatabase ('UnitTest' + $args[1]) $connectionstring
   #DropDatabase ('UnitTestWS' + $args[1]) $connectionstring
   #DropDatabase ('UnitTest_Test' + $args[1]) $connectionstring
   
   Exit $LASTEXITCODE
}
catch [Microsoft.PowerShell.Commands.ProcessCommandException]
{
    Write-Host "Main Test Script Failed"  + $_
    Exit 1
}
catch
{
    Write-Host "Main Test Script Failed"  + $_
    Exit 1
}