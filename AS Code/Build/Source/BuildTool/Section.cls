VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Section"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public m_ValueKeyPairs As New Collection
Private m_sFile As String
Private m_sSection As String
Private Declare Function GetPrivateProfileSection Lib "kernel32" Alias "GetPrivateProfileSectionA" (ByVal lpAppName As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long

Public Property Let INIFile(sFile As String)
    m_sFile = sFile
End Property

Public Property Get INIFile() As String
    INIFile = m_sFile
End Property

Public Property Let Section(sSection As String)
    m_sSection = sSection
End Property

Public Property Get Section() As String
    Section = m_sSection
End Property

'***************************************************************************
'Function: LoadValueKeyPairs()
'Description: Loads all the Value-Key pairs of the m_sSection in to the
'               m_ValueKeyPairs collection
'***************************************************************************
Public Sub LoadValueKeyPairs()
    Dim sValueKeyPairs As String
    Dim sValueKeyPair As String
    Dim lSize As Long
    Dim lPos As Long
    Dim objValueKeyPair As ValueKeyPair
            
    On Error GoTo ErrorHandler
    
    sValueKeyPairs = String(10240, Chr$(0))
    lSize = GetPrivateProfileSection(m_sSection, sValueKeyPairs, 10240, m_sFile)
    If Not (VBA.Left$(sValueKeyPairs, 1) = Chr$(0)) Then
        sValueKeyPairs = VBA.Left$(sValueKeyPairs, lSize)
        
        While (Len(sValueKeyPairs) > 0)
            lPos = InStr(sValueKeyPairs, Chr$(0))
            sValueKeyPair = VBA.Left$(sValueKeyPairs, lPos - 1)
            sValueKeyPairs = Right$(sValueKeyPairs, lSize - lPos)
            lSize = lSize - lPos
            
            Set objValueKeyPair = New ValueKeyPair
            lPos = InStr(sValueKeyPair, "=")
            objValueKeyPair.m_sKey = VBA.Left$(sValueKeyPair, lPos - 1)
            objValueKeyPair.m_sValue = Right$(sValueKeyPair, Len(sValueKeyPair) - lPos)
            m_ValueKeyPairs.Add objValueKeyPair, objValueKeyPair.m_sKey
            Set objValueKeyPair = Nothing
        Wend
    End If
    Exit Sub
    
ErrorHandler:
    Err.Raise Err.Number, "Section::LoadValueKeyPairs;" + Err.Source
End Sub
