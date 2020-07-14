Attribute VB_Name = "BuildTools"
Option Explicit

'***************************************************************************
'Function: BuildVCProject()
'Description: Build a VC++ project
'***************************************************************************
Public Sub BuildVCProject(sProjectFile As String, ByVal sConfiguration As String, sGetFrom As String, sDebugFlag As String)
    Dim objVC As New VCObject
    Dim sProcessorType As String
    
    WriteToLogFile "Building " + sProjectFile + "..."
    
    On Error GoTo ErrorHandler
    
    'Check if building Alpha or Intel configuration
    If InStr(StrConv(sConfiguration, vbUpperCase), "ALPHA") Then
        sProcessorType = "ALPHA"
    Else
        sProcessorType = "INTEL"
    End If
        
    'Build Project and check for errors
    objVC.LoadVCProject sProjectFile, sProcessorType
    objVC.ExecuteCommand "BuildProjectExport"
    objVC.BuildVCProject sConfiguration, sDebugFlag
    objVC.ExitVC
    
    Exit Sub
    
ErrorHandler:
    objVC.ExitVC
    Err.Raise Err.Number, "BuildVCProject;" + Err.Source
End Sub

'***************************************************************************
'Function: BuildVBProject()
'Description: Build a VB project
'***************************************************************************
Public Sub BuildVBProject(sVCProjectFile As String, ByVal sConfiguration As String, sGetFrom As String, sDebugFlag As String)
    Dim objFileSys As New FileSystemObject
    Dim objTextStream As TextStream
    Dim sProjectDir As String, sBuildLog As String, sText As String, sPathToBuildNoH As String
    Dim objVC As New VCObject
    Dim iErr As Integer, iWarn As Integer, iPos As Integer
    Dim bWasRebuilt As Boolean
    Dim fso As New FileSystemObject
    Dim sVBProjectFile As String, sRevisionVersion As String
    Dim lResult As Long
    Dim sProcessorType As String
    Dim sCmdLine As String
    
    WriteToLogFile "Building " + sVCProjectFile + "..."
    
    On Error GoTo ErrorHandler
    
    'Get the path to build.log, buildno.h, project directory and VB project file
    sProjectDir = objFileSys.GetParentFolderName(sVCProjectFile)
    sBuildLog = sProjectDir + "\build.log"
    sPathToBuildNoH = sProjectDir + "\buildno.h"
    sVBProjectFile = VBA.Left$(sVCProjectFile, VBA.Len(sVCProjectFile) - 4) + ".vbp"
    
    RemoveReadOnlyFlag (sProjectDir)
    
    'delete build.log if it exists
    If fso.FileExists(sBuildLog) Then
        fso.DeleteFile sBuildLog, True
    End If
   
    'Create a new makefile for the project
'    CreateMakefile sVCProjectFile
    
    'Clear Read-Only flag from VBP file
    SetAttr sVBProjectFile, vbNormal
    
    'Clear Read-Only flag from buildno.h
    If fso.FileExists(sPathToBuildNoH) Then
        SetAttr sPathToBuildNoH, vbNormal
    End If
    
    'Get Revision Version from buildno.h
    sRevisionVersion = String(1024, Chr$(0))
    lResult = GetPrivateProfileString("Version", "Revision", "001", sRevisionVersion, 1024, sPathToBuildNoH)
    iPos = VBA.InStr(sRevisionVersion, Chr$(0))
    sRevisionVersion = VBA.Left$(sRevisionVersion, iPos - 1)
    
    'Take revision version from buildno.h and update VB project file
    UpdateVersion sVBProjectFile, sRevisionVersion, "RevisionVer"
    
    'Check if building Alpha or Intel configuration
    If InStr(StrConv(sConfiguration, vbUpperCase), "ALPHA") Then
        sProcessorType = "ALPHA"
    Else
        sProcessorType = "INTEL"
    End If
    
    sCmdLine = "vb6.exe /m " + Chr(34) + sVBProjectFile + Chr(34) + _
                " /out " + Chr(34) + sProjectDir + "\" + "build.log" + Chr(34)
                
    ExecuteAndWait sCmdLine, True
    
'*****************************
    'Build the VC wrapper project and check for errors
'    objVC.LoadVCProject sVCProjectFile, sProcessorType
'    objVC.BuildVCWrapperProject sConfiguration, sDebugFlag
'    objVC.GetErrorsWarnings iErr, iWarn
'    If (iErr > 0) Then
        'Get VB Errors from build.log if it exists
'        objVC.ExitVC
'        Err.Description = CStr(iErr) + " VC Makefile errors"
'        Err.Raise -1, Err.Source + "BuildVBProject", Err.Description
'    End If
    
'    objVC.ExitVC
'*********************************
    'If build.log exists, then the VB binary was rebuilt, otherwise it was not rebuilt
    If fso.FileExists(sBuildLog) Then
    
        'Check if the build succeeded by parsing build.log
        Set objTextStream = objFileSys.OpenTextFile(sBuildLog)
        sText = objTextStream.ReadAll
        If Not (InStr(sText, "succeeded") > 0) Then
            Err.Number = VB_BUILD_ERROR
            Err.Description = "VB project failed to build:  " + vbNewLine + sText
            If fso.FileExists(LOG_DIR + "\" + Date$ + "\VBError.Log") Then
                SetAttr LOG_DIR + "\" + Date$ + "\VBError.Log", vbNormal
                fso.DeleteFile LOG_DIR + "\" + Date$ + "\VBError.Log"
            End If
            fso.CopyFile sBuildLog, LOG_DIR + "\" + Date$ + "\VBError.Log"
            Err.HelpFile = LOG_DIR + "\" + Date$ + "\VBError.Log"
            sErrorProject = sVBProjectFile
            GoTo ErrorHandler
        End If
        
        'Must have succeeded so add project name to the list of rebuilt projects
        sRebuiltFilesList = sRebuiltFilesList + vbNewLine + "    REBUILT: " + sVCProjectFile
        WriteToLogFile "Building " + sVCProjectFile + "...done" + "  ***REBUILT***"
        
        'Increment build number in buildno.h
        Checkout sGetFrom + "/buildno.h", "", objVSSDatabase
        If sBuildMode <> BUILD_MODE_TEST Then
            lResult = WritePrivateProfileString("Version", "Revision", CStr(CInt(sRevisionVersion) + 1), sPathToBuildNoH)
        End If
        Checkin (sGetFrom + "/buildno.h"), objVSSDatabase

    Else
        WriteToLogFile "Building " + sVCProjectFile + "...done" + "  ***NOT REBUILT***"
    End If
        
    Exit Sub

ErrorHandler:
    Err.Raise Err.Number, "BuildVBProject;" + Err.Source
End Sub

'***************************************************************************
'Function: CopyFiles()
'Description: Copies files
'***************************************************************************
Public Sub CopyFiles(sFrom As String, sTo As String)
    Dim objFileSystemObj As New FileSystemObject
    Dim bWildCard As Boolean
    Dim bFile As Boolean
    Dim bDir As Boolean
    
    WriteToLogFile "Copying files from " + sFrom + " to " + sTo + "..."
    
    On Error GoTo ErrorHandler
    
    bWildCard = False
    bFile = False
    bDir = False

    If (InStrRev(sFrom, "*") > 0) Then
        If (objFileSystemObj.FolderExists(objFileSystemObj.GetParentFolderName(sFrom)) = False) Then
            Err.Number = -1
            Err.Description = "path or file not exist"
            GoTo ErrorHandler
        Else
            bWildCard = True
        End If
    Else
        If (objFileSystemObj.FolderExists(sFrom)) Then
            bDir = True
        Else
            If (objFileSystemObj.FileExists(sFrom)) Then
                bFile = True
            Else
                Err.Number = -1
                Err.Description = "path or file not exist"
                GoTo ErrorHandler
            End If
        End If
    End If
    
    If bWildCard Then
        If (objFileSystemObj.FolderExists(sTo) = False) Then
            CreateFolder sTo
        End If
        RemoveReadOnlyFlag sTo
        objFileSystemObj.CopyFile sFrom, sTo
        RemoveReadOnlyFlag sTo
    Else
        If bFile Then
            If (objFileSystemObj.FolderExists(objFileSystemObj.GetParentFolderName(sTo)) = False) Then
                CreateFolder objFileSystemObj.GetParentFolderName(sTo)
            End If
            RemoveReadOnlyFlag sTo
            objFileSystemObj.CopyFile sFrom, sTo
            RemoveReadOnlyFlag sTo
        Else
            If bDir Then
                If (objFileSystemObj.FolderExists(sTo) = False) Then
                    CreateFolder sTo
                End If
                RemoveReadOnlyFlag sTo
                objFileSystemObj.CopyFolder sFrom, sTo
                RemoveReadOnlyFlag sTo
            Else
                Err.Number = -1
                Err.Description = "general error"
                GoTo ErrorHandler
            End If
        End If
    End If
    WriteToLogFile "Copying files from " + sFrom + " to " + sTo + "...done"
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "CopyFiles;" + Err.Source
End Sub

'***************************************************************************
'Function: CreateFolder()
'Description: Creates the given directory by creating all parent directories first
' e.g.   C:\test\test1\test2
'   Create C:\test
'   Create C:\test\test1
'   Create C:\test\test1\test2
'***************************************************************************
Public Sub CreateFolder(sPath)

    Dim fso As New FileSystemObject
    Dim aPath As Variant
    Dim i As Integer
    Dim sFolderToCreate
    
    aPath = VBA.Split(sPath, "\")
    
    'Get drive
    sFolderToCreate = aPath(0)
    
    For i = 1 To UBound(aPath)
        sFolderToCreate = sFolderToCreate + "\" + aPath(i)
        If Not fso.FolderExists(sFolderToCreate) Then
            fso.CreateFolder sFolderToCreate
        End If
    Next
End Sub

'***************************************************************************
'Function: RemoveReadOnlyFlag()
'Description: Reucrsively removes the Read-Only flag from the given directory
'(all sub-directories) and all files in those directories
'***************************************************************************
Public Sub RemoveReadOnlyFlag(sTarget)

    Dim fso As New FileSystemObject
    Dim objCurrentFolder As Folder
    Dim objFiles As Files
    Dim vFile
    Dim vFolders
    Dim vFolder
    
    'Clear read-only flag from file
    If fso.FileExists(sTarget) Then
        SetAttr sTarget, vbNormal + vbArchive
    'Clear read-only flag from a directory and all files in that directory
    ElseIf fso.FolderExists(sTarget) Then
        Set objCurrentFolder = fso.GetFolder(sTarget)
        objCurrentFolder.Attributes = Normal + Archive
    
        Set vFolders = objCurrentFolder.SubFolders
        For Each vFolder In vFolders
            RemoveReadOnlyFlag (sTarget + "\" + vFolder.Name)
        Next
    
        Set objFiles = objCurrentFolder.Files
    
        For Each vFile In objFiles
            SetAttr sTarget + "\" + vFile.Name, vbNormal + vbArchive
        Next
    'Must end with *.* or . so get parent folder
    Else
        RemoveReadOnlyFlag (fso.GetParentFolderName(sTarget))
    End If
       

End Sub


'***************************************************************************
'Function: DeleteFiles()
'Description: Delete files
'***************************************************************************
Public Sub DeleteFiles(sItem As String, sOptions As String)
    Dim objFileSystemObj As New FileSystemObject
    Dim bRecursive As Boolean
    Dim sFolder As String
    Dim sFile As String
    
    WriteToLogFile "Deleting " + sItem + "..."
    
    On Error GoTo ErrorHandler
    
    RemoveReadOnlyFlag sItem
    
    bRecursive = False
    If (VBA.Right(sOptions, 3) = "-R") Then
        bRecursive = True
    End If
    
    StripQuotes sItem
    
    If bRecursive Then
        sFolder = objFileSystemObj.GetParentFolderName(sItem)
        If (objFileSystemObj.FolderExists(sFolder) = True) Then
            sFile = objFileSystemObj.GetFileName(sItem)
            On Error Resume Next
            objFileSystemObj.DeleteFile sItem
            DeleteFilesRecursively sFolder, sFile
        Else
            WriteToLogFile sItem & " folder does not exist"
            Exit Sub
        End If
    Else
        If (objFileSystemObj.FolderExists(sItem) = True) Then
            objFileSystemObj.DeleteFolder sItem
        Else
            If (objFileSystemObj.FileExists(sItem) = True) Then
                objFileSystemObj.DeleteFile sItem
            Else
                WriteToLogFile sItem & " does not exist"
                Exit Sub
            End If
        End If
    End If
    WriteToLogFile "Deleting " + sItem + "..."
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "DeleteFiles;" + Err.Description
End Sub

'***************************************************************************
'Function: DeleteFilesRecursively()
'Description: Delete files, includes subdirectories
'***************************************************************************
Public Sub DeleteFilesRecursively(sFolder As String, sFile As String)
    Dim objFileSystemObj As New FileSystemObject
    Dim objFolder As Folder
    Dim objFolders As Folders
    Dim vFolder As Variant
    
    On Error GoTo ErrorHandler
    
    If (objFileSystemObj.FolderExists(sFolder)) Then
        Set objFolder = objFileSystemObj.GetFolder(sFolder)
        Set objFolders = objFolder.SubFolders
        For Each vFolder In objFolders
            On Error Resume Next
            objFileSystemObj.DeleteFile CStr(vFolder) + "\" + sFile
            DeleteFilesRecursively CStr(vFolder), sFile
        Next
    End If
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "DeleteFilesRecursively;" + Err.Source
End Sub

'***************************************************************************
'Function: RunShellCommand()
'Description: Executes a DOS command
'***************************************************************************
Public Sub RunShellCommand(sCmd As String)
    Dim X As Long
    
    WriteToLogFile "Running shell command " + sCmd + "..."
    
    X = ExecuteAndWait(sCmd, True)
    If (X <> 0) Then
        Err.Raise X, "RunShellCommand", sCmd
        Exit Sub
    End If

    WriteToLogFile "Running shell command " + sCmd + "...done"
End Sub


'***************************************************************************
'Function: BuildISPROProject()
'Description: Builds an InstallShield Pro project
'***************************************************************************
Public Sub BuildISPROProject(sProject As String, sMedia As String, sPreProcessArgs As String, sISProPath As String)
    Dim X As Long
    Dim sCmd As String

    WriteToLogFile "Building " + sProject + "..."
    
    ' Compile
    sCmd = Chr$(34) + sISProPath + "\program\compile.exe" + Chr$(34) + " " + Chr$(34) + sProject + "\Script Files\Setup.rul" + Chr$(34)
    ' Append PrePocess Args to command line
    If (sPreProcessArgs <> "") Then
        sCmd = sCmd + " " + sPreProcessArgs + Chr$(34)
    End If
    
    WriteToLogFile "Compiling..." + "  COMMAND: " + sCmd
        
    X = ExecuteAndWait(sCmd, True)
    If (X <> 0) Then
        Err.Raise X, "BuildISProProject", sCmd
        Exit Sub
    End If

    WriteToLogFile "Compiling Done..."
    ' Build
    sCmd = Chr$(34) + sISProPath + "\program\isbuild.exe" + Chr$(34) + " -p" + Chr$(34) + sProject + Chr$(34) + " -m" + Chr$(34) + sMedia + Chr$(34)
    X = ExecuteAndWait(sCmd, True)
    If (X <> 0) Then
        Err.Raise X, "BuildISProProject", sCmd
        Exit Sub
    End If

    WriteToLogFile "Building " + sProject + "...done"
End Sub

'***************************************************************************
'Function: CreateMakefile()
'Description: Creates a makefile for the given VB project
'***************************************************************************
Private Function CreateMakefile(sVCProjectFile As String)

    Dim sProjectName As String
    Dim fso As New FileSystemObject
    Dim sMakeDependencies As String
    Dim sFile As String
    Dim sOutputFileName As String
    Dim objMakeFile As TextStream
    Dim sMakeFile As String
    Dim sVBProjectFile As String
    Dim sLibFile As String
    Dim sExpFile As String
    
    On Error GoTo ErrorHandler
    
    WriteToLogFile "Creating Makefile..."
   
    sProjectName = fso.GetBaseName(sVCProjectFile)
    sVBProjectFile = fso.GetParentFolderName(sVCProjectFile) + "\" + sProjectName + ".vbp"
    sMakeFile = fso.GetParentFolderName(sVCProjectFile) + "\" + sProjectName + ".mak"
    
    'delete old makefile
    If fso.FileExists(sMakeFile) Then
        fso.DeleteFile sMakeFile, True
    End If
    
    Set objMakeFile = fso.CreateTextFile(sMakeFile, True)
  
    'Scan the VB project for its dependecies
    sMakeDependencies = ScanVBPFile(sVBProjectFile, sOutputFileName)
    
    StripQuotes sOutputFileName
        
    objMakeFile.Write (sOutputFileName + " :")
  
    'Write Dependecies to Makefile
    objMakeFile.WriteLine (sMakeDependencies)
  
    sLibFile = fso.GetBaseName(sOutputFileName) + ".lib"
    sExpFile = fso.GetBaseName(sOutputFileName) + ".exp"
    
    'Write commands to Makefile
    objMakeFile.WriteLine (vbTab + "attrib -r " + sOutputFileName)
    objMakeFile.WriteLine (vbTab + "attrib -r " + sLibFile)
    objMakeFile.WriteLine (vbTab + "attrib -r " + sExpFile)
    objMakeFile.WriteLine (vbTab + "vb6 /m " + sProjectName + ".vbp /out build.log")
    
    WriteToLogFile "Creating Makefile...done"
  
    Exit Function
    
ErrorHandler:
    Err.Raise Err.Number, "CreateMakeFile;" + Err.Source

End Function

'***************************************************************************
'Function: ScanVBFile()
'Description: Scans a VB Project's VB file for it's dependencies
'***************************************************************************
Public Function ScanVBPFile(mstrFileName As String, ByRef sFileType As String) As String

    Dim intFile As Integer
    Dim strLine As String
    Dim sResult As String
    Dim iPos As Integer
    Dim sTemp As String
    Dim aTempArray As Variant
    
    intFile = FreeFile
    Open mstrFileName For Input As intFile
    Do Until EOF(intFile)
        Line Input #intFile, strLine
        If VBA.Left(strLine, 5) = "Form=" Then
             ' you got a .frm file reference
             sResult = sResult + " " + Mid(strLine, 6)
            GoTo NextLine2
        End If

        If VBA.Left(strLine, 7) = "Module=" Then
            'you got a .bas file reference
            iPos = InStr(strLine, ";")
            sResult = sResult + VBA.Right$(strLine, Len(strLine) - iPos)
            GoTo NextLine2
        End If

        
        If VBA.Left(strLine, 6) = "Class=" Then
            'you got a .cls file reference
            iPos = InStr(strLine, ";")
            sResult = sResult + VBA.Right$(strLine, Len(strLine) - iPos)
            GoTo NextLine2
        End If
        
        If VBA.Left(strLine, 10) = "ExeName32=" Then
            'you got a .cls file reference
            iPos = InStr(strLine, "=")
            sFileType = VBA.Right$(strLine, Len(strLine) - iPos)
            GoTo NextLine2
        End If
        
        If VBA.Left(strLine, 10) = "Reference=" Then
            'exclude system file references
            If InStr(UCase(strLine), "WINNT") = 0 Then
                iPos = InStr(strLine, "=")
                sTemp = VBA.Right$(strLine, Len(strLine) - iPos)
                aTempArray = Split(sTemp, "#")
                sResult = sResult + " " + Chr$(34) + CStr(aTempArray(3)) + Chr$(34)
            End If
            GoTo NextLine2
        End If

NextLine2:
        Loop
        ScanVBPFile = sResult
        Close #intFile

End Function

'***************************************************************************
'Function: UpdateVersion()
'Description: Updates the specified version in the VBP file
'             sVersionKey:  MajorVer
'                           MinorVer
'                           RevisionVer
'***************************************************************************
Private Sub UpdateVersion(sVbpFile As String, sBuildNum As String, sVersionKey As String)

    Dim intFile As Integer
    Dim strLine As String
    Dim colFile As New Collection
    Dim vLine As Variant
    Dim fso As New FileSystemObject
    Dim updatedVbpFile As TextStream
       
    On Error GoTo ErrorHandler
          
    WriteToLogFile ("Updating " + sVbpFile + "  " + sVersionKey + " = " + sBuildNum)
             
    intFile = FreeFile
    
    'Read in contents of VBP file to the file collection
    Open sVbpFile For Input As intFile
    Do Until EOF(intFile)
        Line Input #intFile, strLine
        'if key that is being updated is encountered the update it
        'otherwise, add the line to the collection as is
        If InStr(strLine, sVersionKey) Then
            colFile.Add sVersionKey + "=" + sBuildNum
        Else
            colFile.Add strLine
        End If
    Loop
    Close #intFile
    
    'delete the old .vbp project file
    SetAttr sVbpFile, vbNormal
    fso.DeleteFile (sVbpFile)
    
    'create a new empty .vbp of the same name
    Set updatedVbpFile = fso.CreateTextFile(sVbpFile)
        
    'write the contents of the file collection to the new .vbp, updating the specified version
    For Each vLine In colFile
        updatedVbpFile.WriteLine CStr(vLine)
    Next
    
    WriteToLogFile ("Updating " + sVbpFile + " done...")
   
    Exit Sub
    
ErrorHandler:
    Err.Raise "-1", "UpdateVersion", "Error updating version in File: " + sVbpFile

End Sub



