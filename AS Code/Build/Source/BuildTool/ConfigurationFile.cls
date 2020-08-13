VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ConfigurationFile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public m_Sections As New Collection
Private m_sFile As String
Private Declare Function GetPrivateProfileSectionNames Lib "kernel32" Alias "GetPrivateProfileSectionNamesA" (ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
Private Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long

Public Property Let INIFile(sFile As String)
    m_sFile = sFile
End Property

Public Property Get INIFile() As String
    INIFile = m_sFile
End Property

'***************************************************************************
'Function: LoadSections()
'Description: Loads all the Sections (and their Value-Key pairs) of the
'               m_sFile in to the m_Sections collection
'***************************************************************************
Public Sub LoadSections()
    Dim sSectionName As String
    Dim sSectionNames As String
    Dim lSize As Long
    Dim lPos As Long
    Dim objSection As Section
    Dim x As Variant
    Dim z As Long
    
    On Error GoTo ErrorHandler
    
    z = 0
    sSectionNames = String(2048, Chr$(0))
    lSize = GetPrivateProfileSectionNames(sSectionNames, 2048, m_sFile)
    If Not (VBA.Left$(sSectionNames, 1) = Chr$(0)) Then
        sSectionNames = VBA.Left$(sSectionNames, lSize)
        While (Len(sSectionNames) > 0)
            lPos = InStr(sSectionNames, Chr$(0))
            sSectionName = VBA.Left$(sSectionNames, lPos - 1)
            sSectionNames = Right$(sSectionNames, lSize - lPos)
            lSize = lSize - lPos
            
            Set objSection = New Section
            objSection.INIFile = m_sFile
            objSection.Section = sSectionName
            objSection.LoadValueKeyPairs
            m_Sections.Add objSection, sSectionName
            Set objSection = Nothing
        Wend
    End If
    Exit Sub

ErrorHandler:
    Err.Raise Err.Number, "ConfigurationFile::LoadSections;" + Err.Source
End Sub

'***************************************************************************
'Function: GetValue()
'Description: Get a value given the section and key name.
'***************************************************************************
Public Function GetValue(sSection As String, sKey As String) As String
    Dim objSection As New Section
    Dim objValueKeyPair As New ValueKeyPair
    Dim sValue As String
    
    On Error GoTo ErrorHandler
    
    Set objSection = m_Sections.Item(sSection)
    
    On Error Resume Next
    
    Set objValueKeyPair = objSection.m_ValueKeyPairs.Item(sKey)
    
    On Error GoTo ErrorHandler
    
    sValue = objValueKeyPair.m_sValue
    SubstituteVars sValue
    GetValue = sValue
    Exit Function

ErrorHandler:
    GetValue = vbNullString
    Err.Raise Err.Number, "ConfigurationFile::GetValue;" + Err.Source
End Function

'***************************************************************************
'Function: GetValues()
'Description: Gets a collection of values given the section and the key
'               name prefix
'***************************************************************************
Public Function GetValues(sSection As String, sKey As String) As Collection
    Dim collValues As New Collection
    Dim objSection As New Section
    Dim objValueKeyPair As New ValueKeyPair
    Dim iIndex As Integer
    Dim sValue As String
    
    On Error GoTo ErrorHandler
    
    iIndex = 1
    Set objSection = m_Sections.Item(sSection)
    While True
        On Error GoTo ExitLoop
        Set objValueKeyPair = objSection.m_ValueKeyPairs.Item(sKey + CStr(iIndex))
        sValue = objValueKeyPair.m_sValue
        SubstituteVars sValue
        collValues.Add sValue
        iIndex = iIndex + 1
    Wend
    
ExitLoop:
    Set GetValues = collValues
    Exit Function
    
ErrorHandler:
    Set GetValues = Nothing
    Err.Raise Err.Number, "ConfigurationFile::GetValues;" + Err.Source
End Function

'***************************************************************************
'Function: GetValues()
'Description: Gets a collection of values given the section and the key
'               name prefix
'***************************************************************************
Public Sub SetValue(sSection As String, sKey As String, sValue As String)
    On Error GoTo ErrorHandler

    Dim objSection As Section
    Set objSection = m_Sections.Item(sSection)
    
    '   Set the value in the internal data structure
    Dim objValueKeyPair As ValueKeyPair
    Set objValueKeyPair = objSection.m_ValueKeyPairs.Item(sKey)
    If (Not objValueKeyPair Is Nothing) Then
        objValueKeyPair.m_sValue = sValue
    End If
    
    '   Write to the file
    WritePrivateProfileString sSection, sKey, sValue, m_sFile
    Exit Sub
ErrorHandler:
    Err.Raise Err.Number, "ConfigurationFile::SetValue: " + Err.Source
End Sub

'***************************************************************************
'Function: SubstituteVars()
'Description: Evaluate the variable(s) (e.g. <MyVar>) in the given string
'***************************************************************************
Private Sub SubstituteVars(sValue As String)
    Dim lStart As Long
    Dim lEnd As Long
    Dim sVar As String
    Dim sVarValue As String
    Dim i As Integer
    Dim sBuildNumber As String
    
    If ((sValue = "") Or (sValue = vbNullString)) Then
        Exit Sub
    End If
    
    If InStr(sValue, "%B") Then
        sBuildNumber = GetValue("Product", "BuildNumber")
        
        Dim lNewNumber As Long
        lNewNumber = CLng(sBuildNumber) + 1
        
        sValue = Replace(sValue, "%B", CStr(lNewNumber))
    End If
    
    lStart = InStr(sValue, "<")
    If (lStart = 0) Then
        Exit Sub
    Else
        lEnd = InStr(sValue, ">")
        If (lEnd = 0) Then
            Exit Sub
        End If
    End If
    
    sVar = Mid(sValue, lStart + 1, lEnd - lStart - 1)
    i = 1
    sVarValue = GetValue("Variables", sVar)
    If sVarValue = "" Then
        Exit Sub
    End If

    sValue = VBA.Left$(sValue, lStart - 1) + sVarValue + Right$(sValue, Len(sValue) - lEnd)
    SubstituteVars sValue
End Sub

