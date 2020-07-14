VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MAPIMail"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit

Private m_Recipient As String  'name of recipient for mail message
Private m_Subject As String    'subject of message
Private m_Message As String    'message text
Private m_Attachment As String 'attachment
Private m_UserName As String
Private m_Recipients As New Collection
Private MAPISession1 As New MAPISession
Private MapiMess As New MAPIMessages

Public Property Let Attachment(ByVal vData As String)
    m_Attachment = vData
End Property

Public Property Let UserName(ByVal vData As String)
    m_UserName = vData
End Property

Public Property Get Attachment() As String
    Attachment = m_Attachment
End Property

Public Property Let Message(ByVal vData As String)
    m_Message = vData
End Property

Public Property Get Message() As String
    Message = m_Message
End Property


Public Property Let Subject(ByVal vData As String)
    m_Subject = vData
End Property

Public Property Get Subject() As String
    Subject = m_Subject
End Property


Public Property Let Recipient(ByVal vData As String)
    m_Recipient = vData
    
    Dim a As Variant
    Dim i As Integer
    
    a = Split(m_Recipient, ";")
    
    i = 0
    Do While i <= UBound(a)
        m_Recipients.Add (CStr(a(i)))
        i = i + 1
    Loop
    
End Property

Public Property Get Recipient() As String
    Recipient = m_Recipient
End Property

'***************************************************************************
'Function: SendMail()
'Description: Sends an e-mail using the specified information
'             (recipient, subject, message, attachment...)
'***************************************************************************
Public Sub SendMail()

    Dim objRecipient As Variant
    Dim i As Integer
    
    On Error GoTo ErrorHandler

    Logon
    
    'Compose and send the message
    With MapiMess
        .Compose
        .MsgSubject = m_Subject
        i = 0
        For Each objRecipient In m_Recipients
            .RecipIndex = i
            .RecipAddress = CStr(objRecipient)
            .ResolveName
            i = i + 1
        Next
        .MsgNoteText = m_Message
        If m_Attachment <> "" Then
            .AttachmentPathName = m_Attachment
        End If
        .Send
    End With
   
    Logoff
    
    Set m_Recipients = Nothing
   
    Exit Sub
   
ErrorHandler:

    Err.Raise Err.Number, "Mail::SendMail", Err.Description

End Sub

Public Sub Logon()

    On Error GoTo errLogInFail
    With MAPISession1
        .DownLoadMail = False
        .UserName = "Release Engineer"  'm_UserName
        .LogonUI = False
        .SignOn
        .NewSession = True
        MapiMess.SessionID = .SessionID
    End With
    
Exit Sub
errLogInFail:
    Err.Raise Err.Number, "Mail::Logon", "Login in Failed"


End Sub

Public Sub Logoff()

    On Error GoTo ErrLogOffFail


    MAPISession1.SignOff
    MAPISession1.NewSession = False

Exit Sub

ErrLogOffFail:
    Err.Raise Err.Number, "Mail::Logoff", "Sending Msg Failed"

End Sub

Public Function GetNewMailMessages() As Integer
    
    Dim sBodyText As String
    
    On Error GoTo ErrorHandler
    
    GetNewMailMessages = 0
    Logon
    
    With MapiMess
         ' Fetch unread messages only, then display number
         ' of unread messages in Statusbar.
        .FetchUnreadOnly = True
        .Fetch
        GetNewMailMessages = CInt(.MsgCount)
    End With
    
    Dim i As Integer
    For i = 0 To MapiMess.MsgCount - 1
        MapiMess.MsgIndex = i
        
         'Do this to mark each message as 'read' if not already
         sBodyText = MapiMess.MsgNoteText
    Next i
    
    Logoff
    
 Exit Function
 
ErrorHandler:
    Err.Raise Err.Number, "Mail::GetNewMailMessages", Err.Description
End Function

Private Sub Class_Initialize()
    m_UserName = "MS Exchange Settings"
End Sub
