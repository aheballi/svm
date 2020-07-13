$global:WebServiceHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$global:WebServiceHeader.Add("Content-Type", 'application/x-www-form-urlencoded; charset=UTF-8')
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$TestRunStatus=0

$response = Invoke-RestMethod -uri 'https://dl.csi7.secunia.com/?action=vpm_list&token=F8859A92-C9C5-43F2-95D7-9A3E19FEC0B6&cstid=eval' -Method Get -Headers $global:WebServiceHeader



$count = $response.data.Count
$product_names = $response.data.product_name
$type = $response.data.type



$product_name_list = "7-Zip (x86)","Chrome for Business 64-bit", "Reader DC (English)", "Notepad++ (x64)", "Microsoft Teams for Mac", ".NET Framework 4.8"


#validating product names
Write-Host "Validation of the product names started"

foreach ($names in $product_names)
{
  foreach ($element in $product_name_list)
  {
    #Write-Host $element
    if ($element -like $names)
    {
      Write-Host "product name matched with the list", $names      
    }
    continue

    else
    {
      Write-Host "product name did not match with the list", $names
      $TestRunStatus =-1
      
    }
  }
  
}

Write-Host "Validation of the product names ended"



#validating count
Write-Host "Validation of the product count started"

if ($count -match 6)
{
  Write-Host "product count is a match",$count
}
else
{
  Write-Host "product count is not a match",$count
  $TestRunStatus =-1
}

Write-Host "Validation of the product count ended"




#validating type
Write-Host "Validation of the product type started"

$type_value = "MSI","MSI","MSI","Legacy","PKG","Legacy"

foreach ($type_ele in $type)
{
  foreach ($type_element in $type_value)
  {
    #Write-Host $element
    if ($type_element -match $type_ele)
    {
      Write-Host "product type is a match", $type      
    }
    break

    else
    {
      Write-Host "product type is not a match", $type
      $TestRunStatus =-1
      
    }
  }
  
}
Write-Host "Validation of the product type ended"


if($TestRunStatus -eq 0)
{        
	
 	Write-Host "Validation of Eval mode of package feed is passed"
    exit 0	
}  
else
{   
    
	Write-Host "Validation of Eval mode of package feed is Failed"
	exit 1
}