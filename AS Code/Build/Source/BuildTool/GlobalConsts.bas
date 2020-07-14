Attribute VB_Name = "GlobalConsts"
Option Explicit

'Log file formatting constants
Public Const UNDERLINE = 1
Public Const NOFORMATTING = 0

' Create Process
Public Const NORMAL_PRIORITY_CLASS = &H20&
Public Const INFINITE = -1&
Public Const STARTF_USESHOWWINDOW = &H1

' Show Window
Public Const SW_HIDE = 0
Public Const SW_SHOWNORMAL = 1

'   For CreateProcess Function
Type SECURITY_ATTRIBUTES
    nLength As Long
    lpSecurityDescriptor As Long
    bInheritHandle As Long
End Type

'   For CreateProcess Function
Type STARTUPINFO
    cb As Long
    lpReserved As String
    lpDesktop As String
    lpTitle As String
    dwX As Long
    dwY As Long
    dwXSize As Long
    dwYSize As Long
    dwXCountChars As Long
    dwYCountChars As Long
    dwFillAttribute As Long
    dwFlags As Long
    wShowWindow As Integer
    cbReserved2 As Integer
    lpReserved2 As Byte
    hStdInput As Long
    hStdOutput As Long
    hStdError As Long
End Type

'   For CreateProcess Function
Type PROCESS_INFORMATION
    hProcess As Long
    hThread As Long
    dwProcessId As Long
    dwThreadId As Long
End Type

'Windows APIs
Declare Function GetLastError Lib "kernel32" () As Long
Declare Function CreateProcess Lib "kernel32" Alias "CreateProcessA" (ByVal lpApplicationName As Long, ByVal lpCommandLine As String, ByVal lpProcessAttributes As Long, ByVal lpThreadAttributes As Long, ByVal bInheritHandles As Long, ByVal dwCreationFlags As Long, ByVal lpEnvironment As Long, ByVal lpCurrentDirectory As Long, lpStartupInfo As STARTUPINFO, lpProcessInformation As PROCESS_INFORMATION) As Long
Declare Function WaitForSingleObject Lib "kernel32" (ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
Public Declare Function SetEnvironmentVariable Lib "kernel32" Alias "SetEnvironmentVariableA" (ByVal lpName As String, ByVal lpValue As String) As Long
Public Declare Function GetEnvironmentVariable Lib "kernel32" Alias "GetEnvironmentVariableA" (ByVal lpName As String, ByVal lpBuffer As String, ByVal nSize As Long) As Long
Public Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long
Public Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

'--------------------------------------------------------
'API declares to manipulate the console
'--------------------------------------------------------
Declare Function AllocConsole Lib "kernel32" () As Long
Declare Function FreeConsole Lib "kernel32" () As Long
Declare Function GetStdHandle Lib "kernel32" (ByVal nStdHandle As Long) As Long
Declare Function WriteConsole Lib "kernel32" Alias "WriteConsoleA" (ByVal hConsoleOutput As Long, lpBuffer As Any, ByVal nNumberOfCharsToWrite As Long, lpNumberOfCharsWritten As Long, lpReserved As Any) As Long
Declare Function SetConsoleCtrlHandler Lib "kernel32" (ByVal HandlerRoutine As Long, ByVal Add As Long) As Long

'--------------------------------------------------------
'Public Constants
'--------------------------------------------------------
Public Const STD_OUTPUT_HANDLE = -11&
Public hConsole As Long 'Handle of console window

'Dec Alpha machine name
Public Const DEC_ALPHA_MACHINE = "dectest"

'Directory constants
Public Const TEMP_DIR = "C:\Temp"
Public Const LOG_DIR = "C:\BuildResults"

'Build Errors
Public Const VC_BUILD_ERROR = -99
Public Const VB_BUILD_ERROR = -98

'Error Messages
Public Const BUILD_ERROR_MSG_SUBJECT = "ARGON BUILD FAILED"
Public Const BUILD_ERROR_BODY1 = "The Argon build process failed due to an error building the following project (or one of its dependencies):  "
Public Const BUILD_ERROR_BODY2 = "Please see the attached .plg file for more detailed information."
Public Const BUILD_COMPLETE_MSG = "Argon Build"
Public Const BUILD_COMPLETE_AFTER_ERROR = "All previous build errors have been resolved.  The build has successfully completed."

'Email aliases
Public Const BUILD_TOOLS_ENGINEER = "Martin Markevics"
Public Const RELEASE_ENGINEER = "Richard Schmid"
Public Const ARGON_DEV_TEAM = "Adam Sapek;Amber Aggarwal;Barry Nelson;Bharathi Ganapathi;Devin Ellingson;Kent Foyer;Mingbiao Fei;Ritesh Parikh;Vallinayagam Sankar;Rajesh Ramachandran;Stephen Downard;Stefan Tucker;Richard Schmid"

'Sleep Constants
'Public Const HALF_HOUR = 1800
Public Const HALF_HOUR = 20

'Build Modes
Public Const BUILD_MODE_TEST = "1"
Public Const BUILD_MODE_REAL_BUILD = "0"

'Build Types
Public Const BUILD_TYPE_CONTINUOUS = "1"
'Public Const BUILD_MODE_NORMAL = "Normal"
                         
'Globals that really shouldn't be - need to change this to use only in proper scope
Public sIniFile As String
Public objConfigFile As New ConfigurationFile
Public objVSSDatabase As New VSSDatabase
Public objVSSItem As VSSItem
Public objVSS4Database As New VSSDatabase
Public objVSS4Item As VSSItem
Public sVSSDatabase As String
Public objLogFile As TextStream
Public sRebuiltFilesList As String
Public sLastEmail As String
Public sBuildMode As String
Public sEmailBuildErrorsList As String
Public sEmailLogFilesList As String
Public sErrorProject As String

'   Errors
Public Const BUILD_ERROR_UPDATEINIBUILDNUMBER As Long = -1000

Public Function ExecuteAndWait(CmdLine As String, bShow As Boolean) As Long
    
    Dim NameOfProc As PROCESS_INFORMATION
    Dim NameStart As STARTUPINFO
    Dim X As Long
    On Error GoTo ERROR_HANDLER

    ExecuteAndWait = 0
    
    NameStart.cb = Len(NameStart)
    NameStart.dwFlags = STARTF_USESHOWWINDOW
    If (bShow) Then
        NameStart.wShowWindow = SW_SHOWNORMAL
    Else
        NameStart.wShowWindow = SW_HIDE
    End If
    
    X = CreateProcess(0&, CmdLine, 0&, 0&, 1&, NORMAL_PRIORITY_CLASS, _
       0&, 0&, NameStart, NameOfProc)
    If (X) Then
        X = WaitForSingleObject(NameOfProc.hProcess, INFINITE)
        X = CloseHandle(NameOfProc.hProcess)
    Else
        X = GetLastError()
    End If
    
    WriteToLogFile "Executing " & CmdLine & "..." & "Error = " & X

    Exit Function
    
ERROR_HANDLER:

    ExecuteAndWait = Err.Number
    WriteToLogFile "Error Executing " & CmdLine & "..." & "Error = " & Err.Description

End Function



Public Function ConsoleHandler(ByVal CtrlType As Long) As Long
    
    ConsoleHandler = 1  'This tells the console window to ignore all console
                        'signals. If you don't do this, closing the console window
                        'or typing Ctrl-Break would cause your program to end.
                
End Function

