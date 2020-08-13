VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsConsole"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ------------------------------------------------------------------------
' Copyright © 1997 Microsoft Corporation. All rights reserved.
'
' You have a royalty-free right to use, modify, reproduce and distribute
' the Sample Application Files (and/or any modified version) in any way
' you find useful, provided that you agree that Microsoft has no warranty,
' obligations or liability for any Sample Application Files.
' ------------------------------------------------------------------------

Public Function CloseConsole() As Boolean

    'Close the console handle and clear the cached handle
    If CloseHandle(hConsole) <> 0 Then hConsole = 0
    
    'Disconnects this process from the console.  It will close if no other
    'processes are using the console.
    FreeConsole
  
End Function

Public Function OpenConsole() As Boolean
    
    'If we successfully open a console window then
    If AllocConsole() Then
        'we get the handle to the new console window.
        hConsole = GetStdHandle(STD_OUTPUT_HANDLE)

        'If we didn't successfully get the handle
        If hConsole = 0 Then
            'we should disconnect from the console otherwise
            FreeConsole
        Else
            'we need to add our custom console handler to
            'avoid the default console handler and
            SetConsoleCtrlHandler AddressOf ConsoleHandler, True
            'set the return value to indicate success.
            OpenConsole = True
        End If

    End If

End Function

Public Function SendText(sText As String) As Boolean
  
    Dim sOut As String, cWritten As Long

    sOut = sText & vbCrLf
    'Write the text to the console
    SendText = WriteConsole(hConsole, ByVal sOut, Len(sOut), cWritten, ByVal 0&)
    
End Function

Private Sub Class_Terminate()

    'If a console is open then
    If hConsole <> 0 Then
        'close our handle to it and
        CloseHandle hConsole
        'disconnect it from the process.
        FreeConsole
    End If

End Sub

