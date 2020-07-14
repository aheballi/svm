VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "VCObject"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private objVCApp As Object
Private objVCProjs As Object
Private objVCDocs As Object
Private objVCBuilder As Object
Private objVCConfigs As Object
Private objVCConfig As Object
Private sProjectWorkspace As String

'***************************************************************************
'Function: LoadVCProject()
'Description: Loads the given VC++ project on either an Intel or Alpha machine
'***************************************************************************
Public Sub LoadVCProject(strProjectfile As String, sProcessorType As String)
    
    On Error GoTo ErrorHandler
    
    sProjectWorkspace = strProjectfile
    'If this is an Alpha binary, open the project on the Alpha machine - otherwise
    'load the project on the local machine
    If sProcessorType = "ALPHA" Then
        Set objVCApp = CreateObject("MSDev.Application", DEC_ALPHA_MACHINE)
    Else
        Set objVCApp = CreateObject("MSDev.Application")
    End If
    
    Set objVCDocs = objVCApp.Documents
    Set objVCProjs = objVCApp.Projects
    
    objVCApp.Visible = True
     
    objVCDocs.Open strProjectfile, "Auto", True
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "VCObject::LoadVCProject;" + Err.Source
End Sub

'***************************************************************************
'Function: ExitVC()
'Description: Exit VC and free memory
'***************************************************************************
Public Sub ExitVC()
    objVCApp.Quit
    Set objVCApp = Nothing
    Set objVCProjs = Nothing
    Set objVCDocs = Nothing
    Set objVCBuilder = Nothing
    Set objVCConfigs = Nothing
    Set objVCConfig = Nothing
End Sub

'***************************************************************************
'Function: BuildVCProject()
'Description: Builds the given configuration of the loaded VC++ project
'               if strConfiguration is "All" then all configurations will
'                    be built
'               if strConfiguration is "All Release" then all configurations
'                   with the word Release will be built
'               if strConfiguration is "All Debug" then all configurations
'                   with the word Debug will be built
'***************************************************************************
Public Sub BuildVCProject(strConfiguration As String, sDebugFlag As String)
    Dim bBuild As Boolean
    Dim bAllRelease As Boolean
    Dim bAllDebug As Boolean
    Dim mywindow As Variant
    Dim fso As New FileSystemObject
    Dim sBuildNoHVSS As String
    Dim sBuildNoHTarget As String
    Dim colCheckedOutFiles As New Collection
    Dim CheckedOutfile As Variant
    Dim sBuildErrors As String
    Dim sPlgFile As String
    Dim sProjectVSSPath As String
    Dim sRebuiltFilesCurrent As String
     
    On Error GoTo ErrorHandler
                
    bBuild = False
    bAllRelease = False
    bAllDebug = False
    
    If StrComp(strConfiguration, "All") = 0 Then
        bAllRelease = True
        bAllDebug = True
    End If
    If StrComp(strConfiguration, "All Release") = 0 Then
        bAllRelease = True
        bAllDebug = False
    End If
    If StrComp(strConfiguration, "All Debug") = 0 Then
        bAllRelease = False
        bAllDebug = True
    End If
    
    
    'Check out all BUILDNO.H files of all projects (if it exists) in workspace before building
    'WriteToLogFile "Checking out buildno.h for each project in workspace"
    'For Each objVCBuilder In objVCProjs
        
     '   sBuildNoHTarget = fso.GetParentFolderName(objVCBuilder.FullName) + "\res\buildno.h"
     '   sProjectVSSPath = GetVSSProjectPath(objVCBuilder.Name, sProjectWorkspace)
        
     '   If fso.FileExists(sBuildNoHTarget) Then
     '       sBuildNoHVSS = sProjectVSSPath + "/res/buildno.h"
     '       If InStr(sBuildNoHVSS, "$") > 0 Then
     '           colCheckedOutFiles.Add sBuildNoHVSS
'                Checkout sBuildNoHVSS, ""
     '       Else
     '           WriteToLogFile ("Invalid VSS Path... " + sBuildNoHVSS)
     '       End If
     '   End If
    'Next
   
   
    'Iterate through each project in the workspace
    For Each objVCBuilder In objVCProjs
        Set objVCConfigs = objVCBuilder.Configurations
        'Itereate through each configuration in the given project
        For Each objVCConfig In objVCConfigs
              
            'Check what configuration needs to be built
            If ((bAllRelease = True) And (bAllDebug = True)) Then
                bBuild = True
            Else
                If ((bAllRelease = True) And (InStr(objVCConfig.Name, "Release") > 0)) Then
                    bBuild = True
                Else
                    If ((bAllDebug = True) And (InStr(objVCConfig.Name, "Debug") > 0)) Then
                        bBuild = True
                    End If
                End If
            End If
            
            If (StrComp(objVCConfig.Name, objVCBuilder.Name + " - " + strConfiguration) = 0) Then
               bBuild = True
            End If
            
            'Check if debug version should be built
            If (sDebugFlag = "1") Then
                If (StrComp(objVCConfig.Name, objVCBuilder.Name + " - " + Replace(strConfiguration, "Release", "Debug")) = 0) Then
                    bBuild = True
                End If
            End If
            
            'Build it
            If (bBuild = True) Then
                WriteToLogFile "Building " + objVCBuilder.FullName + vbNewLine + "Config = " + strConfiguration
                
                sPlgFile = VBA.Left$(objVCBuilder.FullName, VBA.Len(objVCBuilder.FullName) - 4) + ".plg"
                'Delete the .Plg file if it exists
                If fso.FileExists(sPlgFile) Then
                    fso.DeleteFile sPlgFile, True
                End If
                
                objVCApp.Build objVCConfig
                'Check for errors
                If objVCApp.Errors > 0 Then
                
                    WriteToLogFile "Plg File:  " + sPlgFile
                    
                    If fso.FileExists(sPlgFile) Then
                        If fso.FileExists(LOG_DIR + "\" + Date$ + "\Error.Plg") Then
                            SetAttr LOG_DIR + "\" + Date$ + "\Error.Plg", vbNormal
                            fso.DeleteFile LOG_DIR + "\" + Date$ + "\Error.Plg"
                        End If
                        fso.CopyFile sPlgFile, LOG_DIR + "\" + Date$ + "\Error.Plg"
                    End If
        
                    sBuildErrors = GetErrorDetails(objVCBuilder.FullName)
                    Err.HelpFile = LOG_DIR + "\" + Date$ + "\Error.Plg"
                    sErrorProject = objVCBuilder.FullName
                    
                    WriteToLogFile "Checking in buildno.h for each project in workspace"
                    For Each CheckedOutfile In colCheckedOutFiles
                           Checkin CStr(CheckedOutfile), objVSSDatabase
                    Next
                    
                    Err.Raise VC_BUILD_ERROR, Err.Source, sBuildErrors, Err.HelpFile
                End If
                
                WriteToLogFile "Building " + objVCBuilder.FullName + " done..."
                 
                'Add rebuilt files (if any) to the master list for this edition
                sRebuiltFilesCurrent = GetRebuiltFiles(sPlgFile)
                WriteToLogFile (sRebuiltFilesCurrent)
                If sRebuiltFilesList <> "" Then
                    If sRebuiltFilesCurrent <> "" Then
                        sRebuiltFilesList = sRebuiltFilesList + vbNewLine + sRebuiltFilesCurrent
                    End If
                Else
                    sRebuiltFilesList = sRebuiltFilesCurrent
                End If
                
                bBuild = False
            End If
        Next
    Next
    
    'Check in all buildno.h files that were checked out
    'WriteToLogFile "Checking in buildno.h for each project in workspace"
    'For Each CheckedOutfile In colCheckedOutFiles
    '    Checkin CStr(CheckedOutfile)
    'Next
    WriteToLogFile ""

    Exit Sub
ErrorHandler:
    Err.Raise Err.Number, "VCObject::BuildVCProject;" + Err.Source
End Sub

'***************************************************************************
'Function: BuildVCWrapperProject()
'Description: Builds the given configuration of the loaded (VB) VC++ wrapper project
'***************************************************************************
Public Sub BuildVCWrapperProject(strConfiguration As String, sDebugFlag As String)
    Dim bBuild As Boolean
    Dim fso As New FileSystemObject
    Dim sBuildErrors As String
    
    On Error GoTo ErrorHandler
                
    bBuild = False
    
    'Iterate through each project in the workspace
    For Each objVCBuilder In objVCProjs
        Set objVCConfigs = objVCBuilder.Configurations
        'Itereate through each configuration in the given project
        For Each objVCConfig In objVCConfigs
               
            If (StrComp(objVCConfig.Name, objVCBuilder.Name + " - " + strConfiguration) = 0) Then
               bBuild = True
            End If
            
            If (bBuild = True) Then
                objVCApp.Build objVCConfig
                bBuild = False
            End If
        Next
    Next
    
    Exit Sub
ErrorHandler:
    Err.Raise Err.Number, "VCObject::BuildVCWrapperProject;" + Err.Source
End Sub

'***************************************************************************
'Function: GetErrorsWarnings()
'Description: Returns the number of Errors and Warnings of the last build
'***************************************************************************
Public Sub GetErrorsWarnings(ByRef iErrors As Integer, ByRef iWarnings As Integer)
    iErrors = objVCApp.Errors
    iWarnings = objVCApp.Warnings
End Sub

'***************************************************************************
'Function: GetErrorDetails()
'Description: Parses a VC project's .plg file for error information
'***************************************************************************
Public Function GetErrorDetails(strProjectfile As String) As String

    Dim nFile As Integer
    Dim strStringToParse As String
    Dim lPosition As Integer
    Dim strPlgFile As String
    Dim fso As New FileSystemObject
    Dim sBuildErrors As String
    
    GetErrorDetails = ""
    
    On Error Resume Next
    'Strip off .dsp extension and add .plg
    strPlgFile = VBA.Left$(strProjectfile, VBA.Len(strProjectfile) - 3) & "plg"
    
    'Open the .plg file, read in each line and check for errors
    nFile = FreeFile
    Open strPlgFile For Input As nFile
                    
    Line Input #nFile, strStringToParse
    While Not EOF(nFile)
        'Handle a Link error
        If (InStr(1, strStringToParse, "LINK : fatal error", vbTextCompare)) Then
            sBuildErrors = sBuildErrors + vbNewLine + strStringToParse
        'Handle a Compile Error
        ElseIf (InStr(1, strStringToParse, ": error", vbTextCompare)) Then
            sBuildErrors = sBuildErrors + vbNewLine + strStringToParse
        'Handle fatal compile error
        ElseIf (InStr(1, strStringToParse, ": fatal error", vbTextCompare)) Then
            sBuildErrors = sBuildErrors + vbNewLine + strStringToParse
        End If

        Line Input #nFile, strStringToParse
    Wend
    
    Close #nFile
    
    GetErrorDetails = sBuildErrors

End Function

'***************************************************************************
' Function:  GetVSSProjectPath
' Description:  Parse a workspace file (.DSW) to find the location in VSS
'               of the given project
'***************************************************************************
Public Function GetVSSProjectPath(sProjectName As String, sProjectWorkspace As String) As String

    Dim intFile As Integer
    Dim strLine As String
    Dim vVSSLocation As Variant
    Dim sBuildNoHVSSPath As String

   
    On Error Resume Next
    
    sBuildNoHVSSPath = ""
    sProjectName = UCase$("Project: " + Chr(34) + sProjectName + Chr(34))
    
    intFile = FreeFile
    Open sProjectWorkspace For Input As intFile
    Do Until EOF(intFile)
        Line Input #intFile, strLine
        
        'Find the project section in .DSW file
        If InStr(UCase$(strLine), sProjectName) Then
            sBuildNoHVSSPath = strLine
            
            'Look for VSS Path until reaching the end of the section
            While InStr(strLine, "$") = 0 And InStr(strLine, "###") = 0
                Line Input #intFile, strLine
            Wend
            
            'If not the end of file and not end of section then found it
            If Not EOF(intFile) And InStr(strLine, "###") <= 0 Then
                vVSSLocation = Split(strLine, Chr$(34))
                sBuildNoHVSSPath = vVSSLocation(1)
            End If
        End If
    Loop
    
    Close #intFile
    
    GetVSSProjectPath = sBuildNoHVSSPath
End Function

'***************************************************************************
' Function:  GetRebuiltFiles
' Description:  Parse the .plg file to see what files were rebuilt,
'               including any dependencies that were built
' ***************************************************************************

Public Function GetRebuiltFiles(sPlgFile As String) As String

    Dim intFile As Integer
    Dim strLine As String
    Dim sRebuiltFiles As String
    Dim sRebuiltFileTemp As String
    
    On Error GoTo ErrorHandler
    
    intFile = FreeFile
    Open sPlgFile For Input As intFile
    Line Input #intFile, strLine

    Do Until EOF(intFile)
        
        If InStr(strLine, "---Configuration:") Then
            sRebuiltFileTemp = strLine
            Line Input #intFile, strLine
            'While haven't reached the next section or end of file
            While InStr(strLine, "---Configuration:") = 0 And (Not EOF(intFile))
                Line Input #intFile, strLine
                
                If InStr(strLine, "Output Window") Then
                    If sRebuiltFiles = "" Then
                        sRebuiltFiles = "    REBUILT: " + sRebuiltFileTemp
                    Else
                        sRebuiltFiles = sRebuiltFiles + vbNewLine + "    REBUILT: " + sRebuiltFileTemp
                    End If
                    GoTo NextBuild
                End If
                
                If EOF(intFile) Then
                    GoTo NextBuild
                End If
            Wend
            
        End If
        
        Line Input #intFile, strLine
NextBuild:

    Loop
    
    Close #intFile
    
    GetRebuiltFiles = sRebuiltFiles
    
    Exit Function
ErrorHandler:
    Err.Raise Err.Number, "VCObject::BuildVCWrapperProject;" + Err.Source, Err.Description

End Function


Public Sub ExecuteCommand(strCommand As String)
    objVCApp.ExecuteCommand strCommand
End Sub
