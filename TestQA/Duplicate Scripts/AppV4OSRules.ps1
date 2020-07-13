
. C:\Users\mmarino\Desktop\TestQA\AS_Powershell_Library.ps1


#start
$ParentFolder = "C:\AS_Automation"
#$arr=@("WinSer2008R2","WinSer2012","Win7 32-bit","Win7 64-bit","Win8 32-bit","Win8 64-bit","Win10 32-bit","Win10 64-bit") 
$arr=@("Win10 32-bit","Win10 64-bit","Win8 32-bit","Win8 64-bit","WinSer2012","Win7 32-bit","Win7 64-bit","WinSer2008R2")
#$arr=@("Win10 32-bit","Win10 64-bit","Win8 32-bit","Win8 64-bit") 
$SRFlag=0
$CatalogName= "AppV4Appcomp1"
$TestRunStatus=0
#create a new catalog 
$retval=CreateNewCatalog $CatalogName $SRFlag
if ($retval -eq 0)
{
    Write-Host "`n Create new catalog - $CatalogName is Successful `r`n" 
}
else
{
    Write-Host "`n Create new catalog - $CatalogName is Failed `r`n"
    Exit 1
}
    $ProjectName="AppV4OSRules"
    $ProjectFolder=$ParentFolder+"\"+$ProjectName
    $logFile=$ProjectFolder +"\"+$ProjectName+".log"
    Createlog($logFile)

For($i=0;$i -lt $arr.Count; $i++) 
{ 
    <#$ProjectName=$arr[$i]
    $ProjectFolder=$ParentFolder+"\"+$ProjectName
    $logFile=$ProjectFolder +"\"+$ProjectName+".log"#>	 
    $OSRules=$arr[$i]
    $strSourcePath="C:\Users\mmarino\Desktop\TestQA\Tests\AppCompatibilityAppV4\"+$arr[$i]+".csv"
    #$strSourcePath="\\10.20.150.10\AdminStudio\AS_Automation\Input Files\AppCompatibilityAppV4\"+$arr[$i]
    $csvFileLocation=$projectFolder+"\"+$arr[$i]+".csv"
   write-host $csvFileLocation
   
    $Retval=CopyTestDataLocally $strSourcePath $ProjectFolder 1
    WriteResultsToFile $logFile "Copy of $OSRules CSV test data is-" $Retval 0

    #connect to new catalog 
    $Retval=ConnectToCatalog $CatalogName 
    #WriteResultsToFile $logFile "Connection to catalog -  $CatalogName." $Retval 0

   
    #Process Csv file 
    $retval = ExecuteOSTest $catalogName $ProjectFolder $csvFileLocation $logfile
    #WriteResultsToFile $logFile "Validate Porperties of the package in CSV File." $retval 0

    If(Select-String -Pattern "Failed" -InputObject $(Get-Content $logFile) )
    {       
        $TestRunStatus =-1
        WriteResultsToFile $logFile "$OSRules Test case Failed" $TestRunStatus 0
        #Write-Host $projectName "Test case Failed `r`n"
    } 
    else
    {
    WriteResultsToFile $logFile "$OSRules Test case Passed" $TestRunStatus 0
        #Write-Host $projectName "Test case Passed `r`n"
    }  

}
<#Foreach($_ In Get-ChildItem $ProjectFolder) 
{ 
    If(!$_.PSIsContainer) { Remove-Item $_.Fullname } 
}#>


#return $TestRunStatus
IF($TestRunStatus -eq 0)
{
 Write-Host "AppV4 AppComp Validate Test case Passed `r`n"   
 }  
else
{
 Write-Host "AppV4 AppComp Validate Test case Failed `r`n"
}