   Set-ExecutionPolicy Unrestricted -Force
   Enable-PSRemoting -Force
   netsh advfirewall set allprofiles state off
   winrm quickconfig
   winrm s winrm/config/client '@{TrustedHosts="*"}'