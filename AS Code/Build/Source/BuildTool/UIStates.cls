VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "UIStates"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_collStateOfEditions As New Collection
Private m_collStateOfComponents As New Collection

'***************************************************************************
'Function: AddEdition()
'Description: Adds the given edition and its state to the
'               m_collStateOfEditions collection
'***************************************************************************
Public Sub AddEdition(sEdition As String, bState As Boolean)
    Dim sState As String
    Dim i As Integer
    
    If bState Then
        i = 1
    Else
        i = 0
    End If
    sState = sEdition + CStr(i)
    m_collStateOfEditions.Add sState, sEdition
End Sub

'***************************************************************************
'Function: AddComponent()
'Description: Adds the given component and its state to the
'               m_collStateOfComponents collection
'***************************************************************************
Public Sub AddComponent(sEdition As String, sComponent As String, bState As Boolean)
    Dim sState As String
    Dim i As Integer
    
    If bState Then
        i = 1
    Else
        i = 0
    End If
    sState = sEdition + sComponent + CStr(i)
    m_collStateOfComponents.Add sState, (sEdition + sComponent)
End Sub

'***************************************************************************
'Function: FlipEditionState()
'Description: Changes the state of the given edition in the collection
'***************************************************************************
Public Sub FlipEditionState(sEdition As String)
    Dim sOldState As String
    Dim sNewState As String
    Dim s As String
    Dim iIndex As Integer
    Dim vEd As Variant
    Dim iCount As Integer
    
    iCount = m_collStateOfEditions.Count
    sOldState = m_collStateOfEditions.Item(sEdition)
    sNewState = FlipState(sOldState)
    
    iIndex = 1
    For Each vEd In m_collStateOfEditions
        If vEd = sOldState Then
            Exit For
        End If
        iIndex = iIndex + 1
    Next
    
    m_collStateOfEditions.Remove (sEdition)
    If iCount = iIndex Then
        If iCount = 1 Then
            m_collStateOfEditions.Add sNewState, sEdition
        Else
            m_collStateOfEditions.Add sNewState, sEdition, , iIndex - 1
        End If
    Else
        m_collStateOfEditions.Add sNewState, sEdition, iIndex
    End If
End Sub

'***************************************************************************
'Function: FlipComponentState()
'Description: Changes the state of the given component in the collection
'***************************************************************************
Public Sub FlipComponentState(sEdition As String, sComponent As String)
    Dim sOldState As String
    Dim sNewState As String
    Dim s As String
    Dim iIndex As Integer
    Dim vComp As Variant
    Dim iCount As Integer
    
    iCount = m_collStateOfComponents.Count
    sOldState = m_collStateOfComponents.Item(sEdition + sComponent)
    sNewState = FlipState(sOldState)
    
    iIndex = 1
    For Each vComp In m_collStateOfComponents
        If vComp = sOldState Then
            Exit For
        End If
        iIndex = iIndex + 1
    Next

    m_collStateOfComponents.Remove (sEdition + sComponent)
    If iCount = iIndex Then
        If iCount = 1 Then
            m_collStateOfComponents.Add sNewState, (sEdition + sComponent)
        Else
            m_collStateOfComponents.Add sNewState, (sEdition + sComponent), , iIndex - 1
        End If
    Else
        m_collStateOfComponents.Add sNewState, (sEdition + sComponent), iIndex
    End If
End Sub

'***************************************************************************
'Function: GetComponentState()
'Description: Gets the state of the given component in the collection
'***************************************************************************
Public Function GetComponentState(sEdition As String, sComponent As String) As Boolean
    Dim sState As String
    Dim s As String
    
    sState = m_collStateOfComponents.Item(sEdition + sComponent)
    s = Right$(sState, 1)
    If s = "0" Then
        GetComponentState = False
    Else
        GetComponentState = True
    End If
End Function

'***************************************************************************
'Function: FlipState()
'Description: Flips the state from 0->1 or 1->0
'***************************************************************************
Private Function FlipState(sState As String) As String
    Dim s As String

    s = Right$(sState, 1)
    If s = "0" Then
        s = "1"
    Else
        s = "0"
    End If
    FlipState = VBA.Left$(sState, Len(sState) - 1) + s
End Function

'***************************************************************************
'Function: GetSelectedEditions()
'Description: Gets all the selected editions in the collection
'***************************************************************************
Public Function GetSelectedEditions() As Collection
    Dim collSelected As New Collection
    Dim vEd As Variant
    
    For Each vEd In m_collStateOfEditions
        If (Right(vEd, 1) = "1") Then
            collSelected.Add VBA.Left(vEd, Len(vEd) - 1)
        End If
    Next
    
    Set GetSelectedEditions = collSelected
End Function

'***************************************************************************
'Function: GetSelectedComponents()
'Description: Gets all the selected components in the collection
'***************************************************************************
Public Function GetSelectedComponents(sEdition As String) As Collection
    Dim collSelected As New Collection
    Dim vComp As Variant
    Dim sEd As String
    Dim lEdName As Long
    
    For Each vComp In m_collStateOfComponents
        sEd = VBA.Left(vComp, Len(sEdition))
        If sEd = sEdition Then
            If (Right(vComp, 1) = "1") Then
                lEdName = Len(sEd)
                collSelected.Add Mid(vComp, lEdName + 1, Len(vComp) - lEdName - 1)
            End If
        End If
    Next
    
    Set GetSelectedComponents = collSelected
End Function
