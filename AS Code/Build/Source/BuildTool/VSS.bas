Attribute VB_Name = "VSS"
Option Explicit

'***************************************************************************
'Function: OpenVSSDatabase()
'Description: Opens the VSS Database
'***************************************************************************
Public Sub OpenVSSDatabase()

    Dim sVSSDatabase As String
    Dim sVSSUserName As String
    Dim sVSSPassword As String
    Dim sCheckOutFrom As String
    Dim sCheckOutTo As String
    Dim sLabel As String

    WriteToLogFile "Initializing VSS", , UNDERLINE
    WriteToLogFile "Opening database..."
    sVSSDatabase = objConfigFile.GetValue("Product", "VSSDatabase")
    sVSSUserName = objConfigFile.GetValue("Product", "VSSUserName")
    sVSSPassword = objConfigFile.GetValue("Product", "VSSPassword")
    objVSSDatabase.Open sVSSDatabase, sVSSUserName, sVSSPassword
    Set objVSSItem = objVSSDatabase.VSSItem(objConfigFile.GetValue("Product", "VSSRoot"))
    WriteToLogFile "Opening database...done"
    
   
    'Label the files
    sLabel = objConfigFile.GetValue("Product", "Label")
             
    If (Not LabelExists(sLabel) And sLabel <> "") Then
        WriteToLogFile "Labeling VSS project with label: " + sLabel + "...", 0, 0
        objVSSItem.Label sLabel
        WriteToLogFile "Labeling VSS project with label: " + sLabel + "...done", 0, 0
    End If
    
    WriteToLogFile ""
    
End Sub

'***************************************************************************
'Function: OpenVSSDatabaseVSS4()
'Description: Opens the VSS Database
'***************************************************************************
Public Sub OpenVSSDatabaseVSS4()

    Dim sVSSDatabase As String
    Dim sVSSUserName As String
    Dim sVSSPassword As String
    Dim sRoot As String
    
    WriteToLogFile "Initializing VSS4", , UNDERLINE
    WriteToLogFile "Opening database..."
    sVSSDatabase = objConfigFile.GetValue("Product", "VSS4Database")
    sVSSUserName = objConfigFile.GetValue("Product", "VSS4UserName")
    sVSSPassword = objConfigFile.GetValue("Product", "VSS4Password")
    objVSS4Database.Open sVSSDatabase, sVSSUserName, sVSSPassword
    sRoot = objConfigFile.GetValue("Product", "VSS4Root")
    Set objVSS4Item = objVSS4Database.VSSItem(sRoot)
    WriteToLogFile "Opening database...VSS4 done"
    
End Sub


'***************************************************************************
'Function: DetermineVSSFlags()
'Description: Determines how to Get the files from VSS
'***************************************************************************
Public Function DetermineVSSFlags(sFlags As String) As Long
    DetermineVSSFlags = 0
    If (InStr(sFlags, "-R") <> 0) Then
        DetermineVSSFlags = DetermineVSSFlags + VSSFLAG_RECURSYES
    Else
        DetermineVSSFlags = DetermineVSSFlags + VSSFLAG_RECURSNO
    End If
    If (InStr(sFlags, "-GTC") <> 0) Then
        DetermineVSSFlags = DetermineVSSFlags + VSSFLAG_TIMENOW
    End If
    If (InStr(sFlags, "-GTM") <> 0) Then
        DetermineVSSFlags = DetermineVSSFlags + VSSFLAG_TIMEMOD
    End If
    If (InStr(sFlags, "-GTU") <> 0) Then
        DetermineVSSFlags = DetermineVSSFlags + VSSFLAG_TIMEUPD
    End If
    If (InStr(sFlags, "-W") <> 0) Then
        DetermineVSSFlags = DetermineVSSFlags + VSSFLAG_USERRONO + VSSFLAG_REPREPLACE
    Else
        DetermineVSSFlags = DetermineVSSFlags + VSSFLAG_USERROYES + VSSFLAG_REPREPLACE
    End If

End Function

'***************************************************************************
'Function: GetProjectFromLabel()
'Description: Gets the project referred in objVSSItem from the given label
'***************************************************************************
Public Sub GetProjectFromLabel(sLabel As String, lFlags As Long, Optional sLocalpath As String = vbNullString)
    Dim objSpecificVer As VSSItem
    
    On Error GoTo ErrorHandler
        
    If sLabel = "" Then
        objVSSItem.Get iFlags:=lFlags, Local:=sLocalpath
    ElseIf Not LabelExists(sLabel) Then
        'Added to allow ability to grab unlabeled code from other products in VSS
        'without updating their labeling scheme
        ' e.g. On-Line reg
        WriteToLogFile ("Label not found, getting latest version of file(s) in VSS")
        objVSSItem.Get iFlags:=lFlags, Local:=sLocalpath
'        Err.Number = -1
'        Err.Description = "label does not exist"
'        GoTo ErrorHandler
    Else
        Set objSpecificVer = objVSSItem.Version(sLabel)
        objSpecificVer.Get iFlags:=lFlags, Local:=sLocalpath
    End If
    Exit Sub

ErrorHandler:
    Err.Raise Err.Number, "GetProjectFromLabel;" + Err.Source
End Sub


'***************************************************************************
'Function: LabelExists()
'Description: Determines if the given label exists on objVSSItem
'***************************************************************************
Public Function LabelExists(sLabel As String) As Boolean
    Dim objSpecificVer As VSSItem
    Dim lVer As Long
    
    On Error GoTo ErrorHandler
    Set objSpecificVer = objVSSItem.Version(sLabel)
    lVer = objSpecificVer.VersionNumber
    LabelExists = True
    Exit Function

ErrorHandler:
    LabelExists = False
End Function



'***************************************************************************
'Function: LastCheckedInFile()
'Description: Finds the user of the last check-in of objVSSItem
'***************************************************************************
Public Function LastCheckedInFile() As String
    Dim objSpecificVer As VSSVersion
    
    For Each objSpecificVer In objVSSItem.Versions
        If VBA.Left(objSpecificVer.Action, 10) = "Checked in" Then
            LastCheckedInFile = objSpecificVer.UserName
            Exit For
        End If
    Next
    LastCheckedInFile = ""
End Function

'***************************************************************************
'Function: FindLastUser()
'Description: Given the name of a file in VSS, return the user who last
'             checked in the file
'***************************************************************************
Public Function FindLastUser(sFileName As String, objLocalVSSDatabase As VSSDatabase) As String

    Dim objVSSFile As VSSItem
    Dim objVSSItem As VSSItem
    Dim objSpecificVer As VSSVersion
    Dim sFileOwner As String
        
    sFileOwner = ""
    
    Set objVSSItem = objLocalVSSDatabase.VSSItem(sFileName)
   
    'Start with latest version and look for action "Checked in".  If
    'not found then it will return the owner of first version - creator.
    For Each objSpecificVer In objVSSItem.Versions
        sFileOwner = objSpecificVer.UserName
        If VBA.Left(objSpecificVer.Action, 10) = "Checked in" Then
            Exit For
        End If
    Next
    
    FindLastUser = sFileOwner

End Function

'***************************************************************************
'Function: Checkout()
'Description: Checks out a file from VSS given the location in VSS and the
'             target destination.  If destination is "", then it uses the
'             current working directory
'***************************************************************************
Public Sub Checkout(sFrom As String, sTo As String, objLocalVSSDatabase As VSSDatabase)
    
    'Don't do anything if running in Test Mode
    If sBuildMode <> BUILD_MODE_TEST Then
    
        Dim objVSSItem As VSSItem
    
        On Error GoTo ErrorHandler
    
        WriteToLogFile "Checking out " + sFrom + "..."
   
        Set objVSSItem = objLocalVSSDatabase.VSSItem(sFrom)
'        If sTo <> "" Then
'            objVSSItem.LocalSpec = sTo
'        End If
 
        'If the item is not already checked out, then check it out.  Otherwise log it.
        If (objVSSItem.IsCheckedOut <= 0) Then
            objVSSItem.Checkout Local:=sTo
        Else
            WriteToLogFile "Checkout of file " + sFrom + " FAILED.  This file is already checked out..."
        End If
    
    End If
    
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "Checkout" + Err.Source

End Sub

'***************************************************************************
'Function: CheckIn()
'Description: Checks in a file to VSS given the location in VSS and labels
'             it with the current label
'***************************************************************************
Public Sub Checkin(sVSSFile As String, objLocalVSSDatabase As VSSDatabase, Optional nFlags As Long = VSSFLAG_KEEPYES)
    
    'Don't do anything if running in Test Mode
    If sBuildMode <> BUILD_MODE_TEST Then
    
        Dim objVSSItem As VSSItem
        Dim sLabel As String
    
        On Error GoTo ErrorHandler
    
        WriteToLogFile "Checking in " + sVSSFile + "..."
    
        Set objVSSItem = objLocalVSSDatabase.VSSItem(sVSSFile)
        
        'If the item is checked out, then check it in and label it
        If (objVSSItem.IsCheckedOut > 0) Then
            objVSSItem.Checkin iFlags:=nFlags
'            sLabel = objConfigFile.GetValue("Product", "Label")
'            objVSSItem.Label (sLabel)
        End If
    
    End If
    
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "CheckIn" + Err.Source
    
End Sub

'***************************************************************************
'Function: UndoCheckOut()
'Description: Undo the check out of a file to VSS given the location in VSS
'***************************************************************************
Public Sub UndoCheckOut(sVSSFile As String, objLocalVSSDatabase As VSSDatabase, Optional nFlags As Long = VSSFLAG_KEEPYES)
    
    'Don't do anything if running in Test Mode
    If sBuildMode <> BUILD_MODE_TEST Then
    
        Dim objVSSItem As VSSItem
        Dim sLabel As String
    
        On Error GoTo ErrorHandler
    
        WriteToLogFile "Undo Check out " + sVSSFile + "..."
    
        Set objVSSItem = objLocalVSSDatabase.VSSItem(sVSSFile)
        
        'If the item is checked out, then check it in and label it
        If (objVSSItem.IsCheckedOut > 0) Then
            objVSSItem.UndoCheckOut iFlags:=nFlags
        End If
    
    End If
    
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "CheckOut: " + Err.Source
    
End Sub

