cd c:\TestSetDev\
C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -File "test.ps1" "%2" "%3" > "%1"
echo %ERRORLEVEL% > resultsOut.txt
exit %ERRORLEVEL%
