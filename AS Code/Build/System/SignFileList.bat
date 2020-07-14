::-----------------------------------------------------------------
:: Values passed in on the command line from the make file:
:
:: %1 is the location of the AS Current Folder on the build machine
:: %2 is the location of the build result logs on the build machine
::-----------------------------------------------------------------

::-------------------------------------------------------------
:: Variables that will persist during the run of this .bat file
::-------------------------------------------------------------
::Set sSignTool="C:\Program Files\Microsoft Visual Studio 8\SDK\v2.0\Bin\signtool.exe"
Set sSignTool="C:\Program Files\InstallShield\2012\System\signtool.exe"
Set sSignToolCmd=sign /f C:\DigitalCertificates\FlexeraSoftwareCert2011.pfx /p flexera2011 /du http://www.flexerasoftware.com
Set sSignToolTimestampCmd=timestamp /t http://timestamp.verisign.com/scripts/timstamp.dll
Set sResultsLog1="%2\FileSigningResults.log"
Set sResultsLog2="%2\FileSigningTimestampResults.log"

::-------------------------------------------------------------
:: Digitally signing files
::-------------------------------------------------------------
%sSignTool% %sSignToolCmd% %1 >>%sResultsLog1%
%sSignTool% %sSignToolTimestampCmd% %1 >>%sResultsLog2%

