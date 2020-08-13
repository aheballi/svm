@echo off
echo #define BUILDNO_FILE 	%BUILDNO% > %BUILDNO_H%
echo #define BUILDNO_FILESTR 	" %BUILDNO%" >> %BUILDNO_H%
echo #define VERSION_MAJOR           7  >> %BUILDNO_H%
echo #define VERSION_MINOR           00 >> %BUILDNO_H%
echo #define VERSION_PRODUCTVERSTR   "7, 00" >> %BUILDNO_H%
echo #define VERSION_COMPANYNAME     "Macrovision Corporation" >> %BUILDNO_H%
echo #define VERSION_COPYRIGHT       "Copyright © 1990-2011  Flexera Software, Inc. and/or InstallShield Co. Inc., All Rights Reserved" >> %BUILDNO_H%

REM Output the product name according to the version
echo #ifdef ITWI_OEMVERSION >> %BUILDNO_H%
echo #define VERSION_PRODUCTNAME     "Tuner OEM Edition" >> %BUILDNO_H%
echo #else >> %BUILDNO_H%
echo #define VERSION_PRODUCTNAME     "AdminStudio" >> %BUILDNO_H%
echo #endif // ITWI_OEMVERSION >> %BUILDNO_H%

echo #define VERSION_CONFIGTOOL_PRODUCTNAME     "Tuner Configuration Tool" >> %BUILDNO_H%
echo #define CUSTOMVER		        00 >> %BUILDNO_H%
echo #define CUSTOMVERSTR	        "00" >> %BUILDNO_H%
echo. >> %BUILDNO_H%
