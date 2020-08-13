Attribute VB_Name = "BuildEngine"
Option Explicit

Private m_ColCheckedOutFiles As Collection
Private m_objConsole As clsConsole

'***************************************************************************
'Function: Main()
'Description: Where it all begins
'***************************************************************************
Public Sub Main()
    Dim SelectedEditions As Collection, EnvironmentVariables As Collection
    Dim vEnv As Variant
    Dim sComponent As String, sConfiguration As String
    Dim i As Integer, pos As Integer
    Dim sEnv As String, sEnvVar As String, sEnvValue As String
    Dim iStartEdition As Integer, iEndEdition As Integer
    Dim iStartComponent As Integer, iEndComponent As Integer
    Dim colComponents As Collection
    Dim sBuildType As String
    Dim sLogfile As String
    Dim sFinishedMailMessage As String
    Dim sBuildNumber As String
    Dim iBuildFailures As Integer
    Dim bEmailNextComplete As Boolean
    Dim sOldBuildNumber As String
    
    On Error GoTo ErrorHandler
    
    '   Open the console
'    Set m_objConsole = New clsConsole
'    m_objConsole.OpenConsole
    
    
    Set m_ColCheckedOutFiles = New Collection
    iBuildFailures = 0
    sFinishedMailMessage = ""
    bEmailNextComplete = False
  
    ' Load INI File
    objConfigFile.INIFile = GetCommandLine(Command$)
    objConfigFile.LoadSections
    
    'get build type
    sBuildType = objConfigFile.GetValue("Product", "ContinuousBuild")
    
    'get build mode
    sBuildMode = objConfigFile.GetValue("Product", "TestBuild")
    
    'get eMail recipients
    sEmailBuildErrorsList = objConfigFile.GetValue("Product", "EmailBuildErrors")
    sEmailLogFilesList = objConfigFile.GetValue("Product", "EmailBuildLogs")
        
    'Create the log file
    sBuildNumber = objConfigFile.GetValue("Product", "BuildNumber")
    
    '   Increment the build number
    Dim lOldNumber As Long
    lOldNumber = CLng(sBuildNumber)
    
    Dim lNewNumber As Long
    lNewNumber = lOldNumber + 1
    
    sBuildNumber = CStr(lNewNumber)
    CreateLogFile sLogfile, sBuildNumber
    
    ' Open VSS database VSS4 to get the online registration stuff
    ' OpenVSSDatabaseVSS4
    
    ' Open VSS database and label
    OpenVSSDatabase
    
    ' Set environment variables
    ProcessEnvironmentVars
    
    AddEnvVar "BUILDNO", sBuildNumber, False
    AddEnvVar "BUILDLOGFILE", sLogfile, False

    ' Get editions to build
    Set SelectedEditions = objConfigFile.GetValues("Product", "Edition")
    
START:
    WriteToLogFile "Current Build Failures:  " + CStr(iBuildFailures), 1
    
    'For future - may want to have command line params to specify a particular
    'Component to start and end with
    iStartEdition = 1
    iEndEdition = SelectedEditions.Count
    ' For edition specified, build selected component
    While iStartEdition <= iEndEdition
        sRebuiltFilesList = ""
        WriteToLogFile SelectedEditions(iStartEdition), , 1
        WriteToLogFile "Building " + SelectedEditions(iStartEdition) + "..."
        sConfiguration = objConfigFile.GetValue(SelectedEditions(iStartEdition), "Config")
        Set colComponents = objConfigFile.GetValues(SelectedEditions(iStartEdition), "Comp")
        iStartComponent = 1
        iEndComponent = colComponents.Count
        i = iStartComponent
        While i <= iEndComponent
            On Error GoTo ErrorHandler
            WriteToLogFile "Processing " + sComponent + "..."
            ProcessSection SelectedEditions(iStartEdition) + " - " + colComponents(i), sConfiguration
            i = i + 1
            On Error GoTo Done
        Wend
        WriteToLogFile "--" + SelectedEditions(iStartEdition) + " sucessfully built--", 1
        WriteToLogFile "Rebuilt Files:" + vbNewLine + sRebuiltFilesList, 2
        iStartEdition = iStartEdition + 1
    Wend
    
    'Increment the build number in the build configuration file
    UpdateINIBuildNumber CStr(lNewNumber)
    
'    'Check in the buildno.h file
'   Checkin CStr(BuildNoFile)
    
    LogDoneBuilding
    
'    If (sBuildType = BUILD_TYPE_CONTINUOUS) Then
'        objLogFile.Close
'        CreateLogFile sLogfile, sBuildNumber
'        If (iBuildFailures >= 2 Or bEmailNextComplete = True) Then
'            SendMailMessage sEmailBuildErrorsList, BUILD_COMPLETE_MSG, BUILD_COMPLETE_AFTER_ERROR, ""
'            bEmailNextComplete = False
'        End If
'        iBuildFailures = 0
'        WriteToLogFile "Resetting Build Failures:  " + CStr(iBuildFailures), 1
'        GoTo START
'    End If
    
    GoTo Done

ErrorHandler:

    LogErrorInformation
    
    If (sBuildType = BUILD_TYPE_CONTINUOUS) Then
        
        If (Err.Number = VC_BUILD_ERROR Or Err.Number = VB_BUILD_ERROR) Then
            iBuildFailures = iBuildFailures + 1
            WriteToLogFile "Current Build Failures:  " + CStr(iBuildFailures), 1
            
            Select Case iBuildFailures
            
            Case 1
                Wait
                
            Case 2
                sLastEmail = Err.Description
                SendMailMessage sEmailBuildErrorsList, BUILD_ERROR_MSG_SUBJECT, BUILD_ERROR_BODY1 + sErrorProject + vbNewLine + vbNewLine + BUILD_ERROR_BODY2, Err.HelpFile
                sErrorProject = ""
                bEmailNextComplete = True
                        
            Case Else
                    If sLastEmail <> Err.Description Then
                        iBuildFailures = 0
                        bEmailNextComplete = True
                    Else
                        WriteToLogFile "BUILD FAILURES:  " + CStr(iBuildFailures)
                    End If
            End Select
 
'                    WriteToLogFile "PREVIOUS FAILURE:  " + sLastEmail
'                    WriteToLogFile "CURRENT FAILURE:  " + Err.Description
        Else
            'Unanticipated error
            SendMailMessage sEmailLogFilesList, "BUILD FAILED - look at log!!!", "Please see attached log file...", sLogfile
        End If
        
        Err.Clear
        objLogFile.Close
        CreateLogFile sLogfile, sBuildNumber
        Resume START
    End If

    sFinishedMailMessage = "BUILD FAILED!!!!"
    
    
Done:
    On Error Resume Next
    
    Dim iCount As Integer
    If sFinishedMailMessage = "" Then
        sFinishedMailMessage = "BUILD " & sBuildNumber & " SUCCEEDED!!!!"
        
        '   On Success, checkin the files
        For iCount = 1 To m_ColCheckedOutFiles.Count
            Checkin m_ColCheckedOutFiles(i), objVssDatabase
        Next iCount
        Set m_ColCheckedOutFiles = Nothing
    
    Else
        '   On Failure, undo the ckeckouts - Don't delete the local copy, but replace with VSS copy.
        For iCount = 1 To m_ColCheckedOutFiles.Count
            UndoCheckOut m_ColCheckedOutFiles(i), objVssDatabase, VSSFLAG_DELNOREPLACE
        Next iCount
        Set m_ColCheckedOutFiles = Nothing
    End If
    
    SendMailMessage sEmailLogFilesList, sFinishedMailMessage, "Please see attached log file...", sLogfile
    CleanUpBeforeExit

End Sub

'***************************************************************************
'Function: GetCommandLine()
'Description: Parses the command line
'***************************************************************************
Private Function GetCommandLine(sCmd As String) As String
    Dim i As Integer, z As Integer
    Dim EndChar As String
    Dim strConfigFile As String
    Dim fso As New FileSystemObject
    
    If (sCmd = "") Then
        MsgBox "USAGE:  " + Chr(34) + "Build tool" + Chr(34) + " <build configuration file>"
        End
    End If
    
    If (Mid(sCmd, 1, 1) = Chr(34)) Then
        EndChar = Chr(34)
        z = 2
    Else
        EndChar = " "
        z = 1
    End If
    i = z
    While ((Mid(sCmd, i, 1) <> EndChar) And (i <= Len(sCmd)))
        i = i + 1
    Wend
    
    strConfigFile = Mid(sCmd, z, i - z)
    
    If Not fso.FileExists(strConfigFile) Then
        MsgBox "Build configuration file:  '" & strConfigFile & "' does not exist in the specified location", vbCritical
        End
    Else
        GetCommandLine = strConfigFile
    End If
    
End Function

'***************************************************************************
'Function: ProcessSection()
'Description: Processes the given section
'***************************************************************************
Public Sub ProcessSection(sSection As String, ByVal sConfiguration As String)
    Dim sConfig As String
    
    On Error Resume Next
    
    sConfig = objConfigFile.GetValue(sSection, "Config")
    If Not (sConfig = vbNullString) Then
        sConfiguration = sConfig
    End If

    On Error GoTo ErrorHandler
    WriteToLogFile "Processing " + sSection + "..."
   
    ProcessLabel sSection
    
    ProcessUses sSection, sConfiguration
    
    ProcessGets sSection
    
    ProcessBuilds sSection, sConfiguration
    
    WriteToLogFile "Processing " + sSection + "...done"
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "ProcessSection;" + Err.Source
End Sub

'***************************************************************************
'Function: ProcessBuilds()
'Description: Processes the Build part of the given section
'               Builds either a VC++ project, or a VB project, or performs
'               a copy or a delete
'***************************************************************************
Private Sub ProcessBuilds(sSection As String, ByVal sConfiguration As String)
    Dim X As New Collection
    Dim z As Variant
    Dim i As Integer
    Dim sBuildTool As String, sBuildProject As String, sBuildProjectFile As String, sMedia As String, sPreProcessArgs As String
    Dim sProjectConfig As String, sFrom As String, sTo As String, sCommandLine As String
    Dim sPos As Long
    Dim sGetFrom As String, sDebugFlag As String
    Dim sISProPath As String
    Dim sCheckOutFrom As String
    Dim sCheckOutTo As String
    Dim sBuildProjectConfig As String
    
    On Error GoTo ErrorHandler
    
    Set X = Nothing
    i = 1
    Set X = objConfigFile.GetValues(sSection, "BuildTool")
    For Each z In X
        sBuildTool = objConfigFile.GetValue(sSection, "BuildTool" + CStr(i))
        
        Select Case sBuildTool
            Case "VC6"
                sBuildProject = objConfigFile.GetValue(sSection, "BuildProject" + CStr(i))
                sBuildProjectFile = objConfigFile.GetValue(sSection, "GetTo" + CStr(i)) + "\" + sBuildProject + ".dsw"
                sBuildProjectConfig = objConfigFile.GetValue(sSection, "BuildConfig" + CStr(i))
                sProjectConfig = sConfiguration
                If (sBuildProjectConfig <> vbNullString) Then
                    sProjectConfig = sBuildProjectConfig
                End If
                
                sGetFrom = objConfigFile.GetValue(sSection, "GetFrom" + CStr(i))
                sDebugFlag = objConfigFile.GetValue("Product", "Debug")
                BuildVCProject sBuildProjectFile, sProjectConfig, sGetFrom, sDebugFlag
            
            Case "VB6"
                sBuildProject = objConfigFile.GetValue(sSection, "BuildProject" + CStr(i))
                sBuildProjectFile = objConfigFile.GetValue(sSection, "GetTo" + CStr(i)) + "\" + sBuildProject + ".dsp"
                sProjectConfig = sConfiguration
                sGetFrom = objConfigFile.GetValue(sSection, "GetFrom" + CStr(i))
                sDebugFlag = objConfigFile.GetValue("Product", "Debug")
                BuildVBProject sBuildProjectFile, sProjectConfig, sGetFrom, sDebugFlag
                
            Case "ISPRO"
                sBuildProject = objConfigFile.GetValue(sSection, "BuildProject" + CStr(i))
                StripQuotes sBuildProject
                sMedia = objConfigFile.GetValue(sSection, "Media" + CStr(i))
                StripQuotes sMedia
                sPreProcessArgs = objConfigFile.GetValue(sSection, "PreProcess" + CStr(i))
                StripQuotes sPreProcessArgs
                sISProPath = objConfigFile.GetValue(sSection, "ISProPath" + CStr(i))
                StripQuotes sISProPath
                BuildISPROProject sBuildProject, sMedia, sPreProcessArgs, sISProPath
            
            Case "Copy"
                sCommandLine = objConfigFile.GetValue(sSection, "CommandLine" + CStr(i))
                sPos = InStr(sCommandLine, Chr(34) + " " + Chr(34))
                sFrom = VBA.Left(sCommandLine, sPos)
                StripQuotes sFrom
                sTo = VBA.Right(sCommandLine, Len(sCommandLine) - sPos - 1)
                StripQuotes sTo
                CopyFiles sFrom, sTo
                
            Case "Delete"
                sCommandLine = objConfigFile.GetValue(sSection, "CommandLine" + CStr(i))
                StripQuotes sCommandLine
                DeleteFiles sCommandLine, objConfigFile.GetValue(sSection, "Options" + CStr(i))
                
            Case "Shell"
                RunShellCommand objConfigFile.GetValue(sSection, "CommandLine" + CStr(i))
                
            Case "MkDir"
                sCommandLine = objConfigFile.GetValue(sSection, "CommandLine" + CStr(i))
                StripQuotes sCommandLine
                WriteToLogFile "Creating Directory " + sCommandLine + "..."
                CreateFolder sCommandLine
            
         End Select
        i = i + 1
    Next
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "ProcessBuilds;" + Err.Source
End Sub

'***************************************************************************
'Function: ProcessLabel()
'Description: Processes labels the part of the given section
'***************************************************************************
Private Sub ProcessLabel(sSection As String)
    
    Dim X As New Collection
    Dim z As Variant
    Dim i As Integer
    
    On Error GoTo ErrorHandler
    
    Set X = Nothing
    i = 1
    Set X = objConfigFile.GetValues(sSection, "Label")
    
    Dim sVssProject As String
    For Each z In X
        sVssProject = objConfigFile.GetValue(sSection, "Label" + CStr(i))
        ProcessSingleLabel sVssProject, objVssDatabase
        i = i + 1
    Next
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "ProcessLabel;" + Err.Source
End Sub

'***************************************************************************
'Function: ProcessSingleLabel()
'Description: Processes a single label
'***************************************************************************
Private Sub ProcessSingleLabel(sVssProject As String, objVssDatabase As VSSDatabase)
    
    On Error GoTo ErrorHandler

    Dim objVSSItem As VSSItem
    Set objVSSItem = objVssDatabase.VSSItem(sVssProject)
    
    'Label the files
    Dim sLabel As String
    sLabel = objConfigFile.GetValue("Product", "Label")
    WriteToLogFile "Labeling VSS project " & sVssProject & " in " & objVssDatabase.SrcSafeIni & " with label: " + sLabel + "...", 0, 0
    objVSSItem.Label sLabel
    WriteToLogFile "Labeling VSS project " & sVssProject & " in " & objVssDatabase.SrcSafeIni & " with label: " + sLabel + ".. Done.", 0, 0
    
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "ProcessSingleLabel;" + Err.Source
End Sub


'***************************************************************************
'Function: ProcessGets()
'Description: Processes the Get part of the given section
'               Get files from VSS
'***************************************************************************
Private Sub ProcessGets(sSection As String)
    Dim X As New Collection
    Dim z As Variant
    Dim i As Integer
    Dim sGetFlags As String, sGetFrom As String, sGetTo As String
    Dim n As String
    Dim lVSSFlags As Long
    Dim sLabel As String
    Dim sCheckOutFrom  As String
    Dim sCheckOutTo  As String
    Dim sCompileOnlineRegFile As String
    Dim sGetVssName As String
    Dim sLocalLabel As String
    Dim objLocalVSSDatabase As VSSDatabase
    
    On Error GoTo ErrorHandler
    
    sGetVssName = objConfigFile.GetValue(sSection, "VSSNAME")
    If (sGetVssName = "VSS4") Then
        ProcessGetsVss4 sSection
        Exit Sub
    End If
    
    sGetVssName = objConfigFile.GetValue(sSection, "VSSDatabase")
    
    Dim sGetVssUser As String
    sGetVssUser = objConfigFile.GetValue(sSection, "VSSUserName")
    
    Dim bLabel As Boolean
    bLabel = False
    If objConfigFile.GetValue(sSection, "Label") <> vbNullString Then
        bLabel = True
    End If
    
    If (sGetVssName <> vbNullString) And (sGetVssUser <> vbNullString) Then
        Set objLocalVSSDatabase = New VSSDatabase
        objLocalVSSDatabase.Open sGetVssName, sGetVssUser, vbNullString
        WriteToLogFile "Opening database..." & sGetVssName & " done"
    Else
        Set objLocalVSSDatabase = objVssDatabase
    End If
    
    Set X = Nothing
    i = 1
    Set X = objConfigFile.GetValues(sSection, "GetFrom")
    For Each z In X
        n = CStr(i)
        sGetFlags = objConfigFile.GetValue(sSection, "GetFlags" + n)
        lVSSFlags = DetermineVSSFlags(sGetFlags)
        sGetFrom = objConfigFile.GetValue(sSection, "GetFrom" + n)
        sGetTo = objConfigFile.GetValue(sSection, "GetTo" + n)
        
        Set objVSSItem = Nothing
        Set objVSSItem = objLocalVSSDatabase.VSSItem(sGetFrom)
        objVSSItem.LocalSpec = sGetTo
        sLabel = objConfigFile.GetValue("Product", "Label")
        
        If bLabel Then ProcessSingleLabel sGetFrom, objLocalVSSDatabase
        
        GetProjectFromLabel sLabel, lVSSFlags
        RemoveReadOnlyFlag (sGetTo)
        i = i + 1
    Next z
    
    'Get Files individually
    Set X = Nothing
    i = 1
    Set X = objConfigFile.GetValues(sSection, "GetFileFrom")
    For Each z In X
        n = CStr(i)
        sGetFlags = objConfigFile.GetValue(sSection, "GetFlags" + n)
        lVSSFlags = DetermineVSSFlags(sGetFlags)
        sGetFrom = objConfigFile.GetValue(sSection, "GetFileFrom" + n)
        sGetTo = objConfigFile.GetValue(sSection, "GetFileTo" + n)
        
        Set objVSSItem = Nothing
        Set objVSSItem = objLocalVSSDatabase.VSSItem(sGetFrom)
        
        'first check if if want to get from another label
        'if not use the mail ini label.
        sLocalLabel = objConfigFile.GetValue(sSection, "LocalLabel" + n)
        If (sLocalLabel <> "") Then
            sLabel = sLocalLabel
        Else
            sLabel = objConfigFile.GetValue("Product", "Label")
        End If
        
        GetProjectFromLabel sLabel, lVSSFlags, sGetTo
        
        'Check if build file belongs to this section
        sCheckOutFrom = objConfigFile.GetValue(sSection, "CheckOutFrom" + n)
        If (sCheckOutFrom <> "") Then
            Checkout sCheckOutFrom, sGetTo, objLocalVSSDatabase
            RunShellCommand objConfigFile.GetValue(sSection, "IncrementBuild" + n)
            
            '   Add it to the collection for future checkin on success of the build
            m_ColCheckedOutFiles.Add Item:=sCheckOutFrom, Key:=sCheckOutFrom
        End If
        
        RemoveReadOnlyFlag (sGetTo)
        i = i + 1
    Next z
    
    
    Exit Sub

ErrorHandler:
    Err.Raise Err.Number, "ProcessGets;" + Err.Source
End Sub

'***************************************************************************
'Function: ProcessGetsVss4()
'Description: Processes the Get part of the given section
'               Get files from VSS
'***************************************************************************
Private Sub ProcessGetsVss4(sSection As String)
    Dim X As New Collection
    Dim z As Variant
    Dim i As Integer
    Dim sGetFlags As String, sGetFrom As String, sGetTo As String
    Dim n As String
    Dim lVSSFlags As Long
    Dim sLabel As String
    Dim sCheckOutFrom  As String
    Dim sCheckOutTo  As String
    Dim sCompileOnlineRegFile As String
        
    On Error GoTo ErrorHandler
    
    Set X = Nothing
    i = 1
    Set X = objConfigFile.GetValues(sSection, "GetFrom")
    For Each z In X
        n = CStr(i)
        sGetFlags = objConfigFile.GetValue(sSection, "GetFlags" + n)
        sGetFrom = objConfigFile.GetValue(sSection, "GetFrom" + n)
        sGetTo = objConfigFile.GetValue(sSection, "GetTo" + n)
        
        Set objVSS4Item = Nothing
        Set objVSS4Item = objVSS4Database.VSSItem(sGetFrom)
        objVSS4Item.LocalSpec = sGetTo
        objVSS4Item.Get
        RemoveReadOnlyFlag (sGetTo)
        i = i + 1
    Next z
    
    'Get Files individually
    Set X = Nothing
    i = 1
    Set X = objConfigFile.GetValues(sSection, "GetFileFrom")
    For Each z In X
        n = CStr(i)
        sGetFlags = objConfigFile.GetValue(sSection, "GetFlags" + n)
        sGetFrom = objConfigFile.GetValue(sSection, "GetFileFrom" + n)
        sGetTo = objConfigFile.GetValue(sSection, "GetFileTo" + n)
        
        Set objVSS4Item = Nothing
        Set objVSS4Item = objVSS4Database.VSSItem(sGetFrom)
        objVSS4Item.Get Local:=sGetTo
        RemoveReadOnlyFlag (sGetTo)
        i = i + 1
    Next z
    
    'Check if Online registration belongs to this section
    sCompileOnlineRegFile = objConfigFile.GetValue(sSection, "CompileOnlineRegFile")
    If (sCompileOnlineRegFile <> "") Then
        RunShellCommand sCompileOnlineRegFile
    End If
    
    Exit Sub

ErrorHandler:
    Err.Raise Err.Number, "ProcessGets;" + Err.Source
End Sub


'***************************************************************************
'Function: ProcessUses()
'Description: Processes the Uses part of the section
'***************************************************************************
Private Sub ProcessUses(sSection As String, ByVal sConfiguration As String)
    Dim X As New Collection
    Dim z As Variant
    
    Set X = objConfigFile.GetValues(sSection, "Uses")
    For Each z In X
        ProcessSection CStr(z), sConfiguration
    Next
End Sub

'***************************************************************************
'Function: ProcessEnvironmentVars()
'Description: Add an environment variables specified in .ini
'***************************************************************************
Public Sub ProcessEnvironmentVars()
    Dim vEnv As Variant
    Dim sEnv As String
    Dim pos As Integer
    Dim EnvironmentVariables As Collection
    Dim sEnvVar As String
    Dim sEnvValue As String


    WriteToLogFile "Setting Environment Variables", , UNDERLINE

    Set EnvironmentVariables = objConfigFile.GetValues("Environment Variables", "EnvVar")
    For Each vEnv In EnvironmentVariables
        sEnv = CStr(vEnv)
        pos = InStr(sEnv, "=")
        sEnvVar = VBA.Left$(sEnv, pos - 1)
        sEnvValue = VBA.Right$(sEnv, VBA.Len(sEnv) - pos)
        AddEnvVar sEnvVar, sEnvValue, False
    Next

End Sub

'***************************************************************************
'Function: StripQuotes()
'Description: Strip quotes from string  "WOW!" -> WOW!
'***************************************************************************
Public Sub StripQuotes(sString As String)
    Dim s As String
    
    s = VBA.Left(sString, 1)
    If (s = Chr(34)) Then
        sString = VBA.Mid(sString, 2)
    End If
    s = VBA.Right(sString, 1)
    If (s = Chr(34)) Then
        sString = VBA.Mid(sString, 1, Len(sString) - 1)
    End If
End Sub

'***************************************************************************
'Function: AddEnvVar()
'Description: Adds a value to an existing environment variable or creates
'                new one
'***************************************************************************
Private Sub AddEnvVar(sEnvVar As String, sSetting As String, Optional bAppend As Boolean = True)
    Dim EnvVarValue As String
    Dim NewValue As String
    Dim X As Long
    
    WriteToLogFile "Adding " + sSetting + " to Environment Variable " + sEnvVar + "..."
        
    On Error GoTo ErrorHandler
    
    EnvVarValue = String(1024, Chr$(0))
    X = GetEnvironmentVariable(sEnvVar, EnvVarValue, 1024)
    
    If (VBA.Left$(EnvVarValue, 1) = Chr$(0) And (X <> 0)) Then
        Err.Number = -1
        Err.Description = "Buffer Not Big Enough"
        GoTo ErrorHandler
    End If
    
    If ((X = 0) Or (sSetting = "")) Then
        NewValue = sSetting
    ElseIf (bAppend = True) Then
        NewValue = VBA.Left$(EnvVarValue, X) & ";" & sSetting & ";"
    Else
        NewValue = sSetting
    End If
    
    X = SetEnvironmentVariable(sEnvVar, NewValue)
    If (X = 0) Then
        Err.Number = -1
        Err.Description = "Environment Variable Not Set"
        GoTo ErrorHandler
    End If
    WriteToLogFile "Adding " + sSetting + " to Environment Variable " + sEnvVar + "...done", 1

    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "AddEnvVar;" + Err.Source
End Sub


'***************************************************************************
'Function: UpdateBuildNumber()
'Description: Updates the build number in the build configuration file
'***************************************************************************
Public Sub UpdateINIBuildNumber(ByVal sBuildNumber As String)
    Dim bResult As Boolean
    Dim sIniFile As String
    
    sIniFile = objConfigFile.INIFile
    
    bResult = WritePrivateProfileString("Product", "BuildNumber", sBuildNumber, sIniFile)
    
    If bResult <> True Then
        Err.Raise BUILD_ERROR_UPDATEINIBUILDNUMBER, "UpdateINIBuildNumber", "Failed to update build number"
    Else
        WriteToLogFile "Updating build number to " & sBuildNumber & "...done"
    End If

End Sub

'***************************************************************************
'Function: CreateLogFile()
'Description: Create a log file
'***************************************************************************
Public Sub CreateLogFile(ByRef sLogfile As String, ByVal sBuildNumber As String)

    Dim sCurrentTime As String
    Dim sLogFileDir As String
    Dim fs As New FileSystemObject

    sCurrentTime = Replace(Time$, ":", ".")
    sLogFileDir = LOG_DIR + "\" + Date$
    If Not fs.FolderExists(sLogFileDir) Then
        CreateFolder (sLogFileDir)
    End If
    sLogfile = sLogFileDir + "\" + sBuildNumber + " -- " + sCurrentTime + ".txt"
    
    Set objLogFile = fs.CreateTextFile(sLogfile, True)
    WriteToLogFile "Build started on " + CStr(Date) + " at " + CStr(Time), 1, 0

End Sub


'***************************************************************************
'Function: WriteToLogFile()
'Description: Writes the given text to the log file followed by the given
'             number of blank lines and format code
'             Format:
'             1 = Underline
'***************************************************************************
Public Sub WriteToLogFile(sMessage As String, Optional iBlankLines As Integer = 0, Optional iFormat As Integer = 0)
    
    objLogFile.WriteLine sMessage
    
    'underline
    If (iFormat = 1) Then
        objLogFile.WriteLine (String(VBA.Len(sMessage), Chr$(45)))
    End If
    
    objLogFile.WriteBlankLines iBlankLines
    
    Debug.Print sMessage
    
'    m_objConsole.SendText sMessage
    
    Exit Sub
    
End Sub

'***************************************************************************
'Function: SendMailMessage()
'Description: Send an e-mail message
'***************************************************************************
Public Sub SendMailMessage(sRecipient As String, sSubject As String, sBody As String, sAttachment As String)
    
    On Error GoTo ErrorHandler
    
    If sRecipient <> "" Then
    
        Dim objMessage As New MAPIMail
    
        WriteToLogFile "Sending Mail Message:   " + sSubject
       
       
        'Get the user profile name
        objMessage.UserName = objConfigFile.GetValue("Product", "EmailProfile")
        objMessage.Recipient = sRecipient
        objMessage.Subject = sSubject
        objMessage.Message = sBody
        objMessage.Attachment = sAttachment
        objMessage.SendMail
   
        WriteToLogFile "Done Sending Message"
    
    End If
    
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "SendMailMessage;" + Err.Source, Err.Description
    
End Sub

'***************************************************************************
'Function: LogDoneBuilding()
'Description: Log a message indicating the build finished
'***************************************************************************
Public Sub LogDoneBuilding()

    WriteToLogFile ""
    WriteToLogFile "*******************************************************"
    WriteToLogFile "*******************************************************"
    WriteToLogFile "**                   DONE BUILDING!!                 **"
    WriteToLogFile "*******************************************************"
    WriteToLogFile "*******************************************************"

End Sub

'***************************************************************************
'Function: LogErrorInformation()
'Description: Log detailed information contained in Err object
'***************************************************************************
Public Sub LogErrorInformation()

    WriteToLogFile ""
    WriteToLogFile "!!!!!!!!!!!!!!!!!!!!!!!!!!BUILD FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!"
    WriteToLogFile "ERROR NUMBER:  " + CStr(Err.Number)
    WriteToLogFile "ERROR SOURCE:  " + CStr(Err.Source)
    WriteToLogFile "ERROR DESCRIPTION", , UNDERLINE
    WriteToLogFile CStr(Err.Description)


End Sub

'***************************************************************************
'Function: CleanUp()
'Description: Perform clean up before terminating app
'***************************************************************************
Public Sub CleanUpBeforeExit()

    Dim vEnv As Variant
    Dim sEnv As String
    Dim pos As Integer
    Dim EnvironmentVariables As Collection
    Dim sEnvVar As String
    Dim sEnvValue As String
    
    WriteToLogFile "", 1
    WriteToLogFile "Cleaning Up", , UNDERLINE

    ' UnSet environment variables
    Set EnvironmentVariables = objConfigFile.GetValues("Environment Variables", "EnvVar")
    For Each vEnv In EnvironmentVariables
        sEnv = CStr(vEnv)
        pos = InStr(sEnv, "=")
        sEnvVar = VBA.Left$(sEnv, pos - 1)
        sEnvValue = ""
        AddEnvVar sEnvVar, sEnvValue, False
    Next
    
    objLogFile.Close
    
End Sub

'***************************************************************************
'Function: Wait()
'Description: Waits the given number of seconds
'***************************************************************************

Public Sub Wait()

    Dim dStartTime As Date
    Dim iMinutes As Long
    Dim iSeconds As Long
    Dim sWaitLength As String
    Dim iWaitLength As Integer

    On Error GoTo ErrorHandler
    
    Dim objMail As New MAPIMail
    objMail.UserName = objConfigFile.GetValue("Product", "EmailProfile")
    
    Form1.Show
        
    'default is 30 minutes
    iWaitLength = 30
    sWaitLength = objConfigFile.GetValue("Product", "ContinuousBuildWaitTime")
    
    iWaitLength = CInt(sWaitLength)
        
    WriteToLogFile "Sleeping for " + sWaitLength + " minutes"
        
    iWaitLength = iWaitLength * 60
    
    While iWaitLength > 0
        iSeconds = iWaitLength Mod 60
        iMinutes = iWaitLength \ 60
        If iSeconds < 10 Then
            Form1.Display "Time Remaining - " + CStr(iMinutes) + ":" + "0" + CStr(iSeconds)
        Else
            Form1.Display "Time Remaining - " + CStr(iMinutes) + ":" + CStr(iSeconds)
        End If
        
        Sleep (1000)
        iWaitLength = iWaitLength - 1
        
        'Check for new mail every minute
        If iSeconds = 0 Then
            If objMail.GetNewMailMessages > 0 Then
                GoTo Done
            End If
        End If
    Wend

Done:
    Form1.Hide
    Unload Form1
    Set objMail = Nothing
    
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "Wait", Err.Description
End Sub

