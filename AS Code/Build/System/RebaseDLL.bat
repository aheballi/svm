REM Rebase all the DLL's and the OCX's
REM For more information refer to MSDN. 
REM Starting addresses are based on recommendations in MSDN

REM A-C Starting address 0x60000000
REM -----------------------------------
echo REBASING DLL's  >> "%BUILDLOGFILE%"
echo -------------- >> "%BUILDLOGFILE%"

rebase -b 0x60000000 %1\*.dll %1\*.ocx