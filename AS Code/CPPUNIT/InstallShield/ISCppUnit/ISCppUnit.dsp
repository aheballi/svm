# Microsoft Developer Studio Project File - Name="ISCppUnit" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Static Library" 0x0104

CFG=ISCppUnit - Win32 Debug Static
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "ISCppUnit.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "ISCppUnit.mak" CFG="ISCppUnit - Win32 Debug Static"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "ISCppUnit - Win32 Release" (based on "Win32 (x86) Static Library")
!MESSAGE "ISCppUnit - Win32 Debug" (based on "Win32 (x86) Static Library")
!MESSAGE "ISCppUnit - Win32 Debug Unicode" (based on "Win32 (x86) Static Library")
!MESSAGE "ISCppUnit - Win32 Debug Unicode Static" (based on "Win32 (x86) Static Library")
!MESSAGE "ISCppUnit - Win32 Debug Static" (based on "Win32 (x86) Static Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName "Perforce Project"
# PROP Scc_LocalPath "."
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "ISCppUnit - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_MBCS" /D "_LIB" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "." /I "..\..\..\..\src\inc" /I "..\Include" /D "WIN32" /D "NDEBUG" /D "_MBCS" /D "_LIB" /Yu"stdafx.h" /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo /out:"..\..\..\..\src\lib\ISCppUnit.lib"

!ELSEIF  "$(CFG)" == "ISCppUnit - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "ISCppUnit___Win32_Debug"
# PROP BASE Intermediate_Dir "ISCppUnit___Win32_Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "ISCppUnit___Win32_Debug"
# PROP Intermediate_Dir "ISCppUnit___Win32_Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /I "." /I "..\..\..\..\src\inc" /I "..\Include" /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /Yu"stdafx.h" /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo /out:"..\..\..\..\src\lib\ISCppUnit.lib"

!ELSEIF  "$(CFG)" == "ISCppUnit - Win32 Debug Unicode"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug Unicode"
# PROP BASE Intermediate_Dir "Debug Unicode"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug Unicode"
# PROP Intermediate_Dir "Debug Unicode"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /I "..\..\..\..\src\inc" /I "..\Include" /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /I "." /I "..\..\..\..\src\inc" /I "..\Include" /D "WIN32" /D "_DEBUG" /D "_LIB" /D "_UNICODE" /D "UNICODE" /Yu"stdafx.h" /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo /out:"..\..\..\..\src\lib\ISCppUnit.lib"
# ADD LIB32 /nologo /out:"..\..\..\..\src\lib\ISCppUnitU.lib"

!ELSEIF  "$(CFG)" == "ISCppUnit - Win32 Debug Unicode Static"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "ISCppUnit___Win32_Debug_Unicode_Static"
# PROP BASE Intermediate_Dir "ISCppUnit___Win32_Debug_Unicode_Static"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "ISCppUnit___Win32_Debug_Unicode_Static"
# PROP Intermediate_Dir "ISCppUnit___Win32_Debug_Unicode_Static"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /I "." /I "..\..\..\..\src\inc" /I "..\Include" /D "WIN32" /D "_DEBUG" /D "_LIB" /D "_UNICODE" /D "UNICODE" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "." /I "..\..\..\..\src\inc" /I "..\Include" /D "WIN32" /D "_DEBUG" /D "_LIB" /D "_UNICODE" /D "UNICODE" /Yu"stdafx.h" /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo /out:"..\..\..\..\src\lib\ISCppUnitU.lib"
# ADD LIB32 /nologo /out:"..\..\..\..\src\lib\ISCppUnitUS.lib"

!ELSEIF  "$(CFG)" == "ISCppUnit - Win32 Debug Static"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "ISCppUnit___Win32_Debug_Static"
# PROP BASE Intermediate_Dir "ISCppUnit___Win32_Debug_Static"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "ISCppUnit___Win32_Debug_Static"
# PROP Intermediate_Dir "ISCppUnit___Win32_Debug_Static"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /I "." /I "..\..\..\..\src\inc" /I "..\Include" /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "." /I "..\..\..\..\src\inc" /I "..\Include" /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /Yu"stdafx.h" /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo /out:"..\..\..\..\src\lib\ISCppUnit.lib"
# ADD LIB32 /nologo /out:"..\..\..\..\src\lib\ISCppUnitS.lib"

!ENDIF 

# Begin Target

# Name "ISCppUnit - Win32 Release"
# Name "ISCppUnit - Win32 Debug"
# Name "ISCppUnit - Win32 Debug Unicode"
# Name "ISCppUnit - Win32 Debug Unicode Static"
# Name "ISCppUnit - Win32 Debug Static"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Group "ProjectHelpers"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\src\ISFolderUtils.cpp
# End Source File
# Begin Source File

SOURCE=..\src\ISProject.cpp
# End Source File
# Begin Source File

SOURCE=..\src\ISProjectBase.cpp
# End Source File
# Begin Source File

SOURCE=..\src\MSIProject.cpp
# End Source File
# Begin Source File

SOURCE=..\src\ProjectHelper.cpp
# End Source File
# End Group
# Begin Source File

SOURCE=..\src\PerformanceMonitor.cpp
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Group "inc_h"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\..\Src\inc\IsCppUnit.h
# End Source File
# End Group
# Begin Group "ProjectHelpers_h"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\include\ISProject.h
# End Source File
# Begin Source File

SOURCE=..\include\ISProjectBase.h
# End Source File
# Begin Source File

SOURCE=..\include\MSIProject.h
# End Source File
# Begin Source File

SOURCE=..\include\ProjectHelper.h
# End Source File
# End Group
# Begin Source File

SOURCE=..\include\CppUnitHelper.h
# End Source File
# Begin Source File

SOURCE=..\include\ISCppUnitLib.h
# End Source File
# Begin Source File

SOURCE=..\include\ISFolderUtils.h
# End Source File
# Begin Source File

SOURCE=..\include\MockCollectionHelper.h
# End Source File
# Begin Source File

SOURCE=..\include\MockObjectHelper.h
# End Source File
# Begin Source File

SOURCE=..\include\PerformanceMonitor.h
# End Source File
# Begin Source File

SOURCE=.\StdAfx.h
# End Source File
# End Group
# End Target
# End Project
