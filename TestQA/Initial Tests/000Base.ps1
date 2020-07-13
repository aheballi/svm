function Write-Header ()
{
    $Header = ('['+(Get-Date -Format 'hh:mm:ss')+']') + ' [Base Test]'
    return $Header
}
################################################################
# Main Loop
###############################################################
try
{
  Write-Host (Write-Header) 'Success'  'Major Version' $args.GetValue(0)  'Build Number' $args.GetValue(1) 'Machine Name' $env:computername
}
catch
{
  Write-Host (Write-Header) 'Error!'  + $_
  Exit 1
}
