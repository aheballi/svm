'Ajay L - 09/11/2008
'Purpose is to write a given description into an existing Perforce changelist file
'Input 1 - changelist file path
'Input 2 - description
'Input 3 - new changelist file path (this will be created based on Input 1 and Input 2

Const IDOK = 1
Const IDABORT = 3

WriteChangeListDescription

Function WriteChangeListDescription()

If Wscript.Arguments.Count <> 3 Then
    Wscript.Echo "Please provide three arguments - Input 1 - changelist file path. Input 2 - description, Input 3 - new changelist file path"
    WriteChangeListDescription = IDABORT
    Exit Function
End If

Wscript.Echo Wscript.Arguments(0)
Wscript.Echo Wscript.Arguments(1)
Wscript.Echo Wscript.Arguments(2)

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.GetFile(Wscript.Arguments(0))
If objFile.Size > 0 Then
    Set objReadFile = objFSO.OpenTextFile(Wscript.Arguments(0), 1)
    Set objWriteFile = objFSO.CreateTextFile(Wscript.Arguments(2), True)
    
    Do While strLine <> "Description:"
        'strLine = objReadFile.ReadLine
        
        strLine = objReadFile.ReadLine
        objWriteFile.WriteLine(strLine)
    Loop
    
    objWriteFile.WriteLine(vbtab & Wscript.Arguments(1))
    strLine = objReadFile.ReadLine
    
    Do While strLine <> "Description:" AND objReadFile.AtEndOfStream = False
        'strLine = objReadFile.ReadLine
        
        strLine = objReadFile.ReadLine
        objWriteFile.WriteLine(strLine)
    Loop    
    
    objReadFile.Close
    objWriteFile.Close
Else
    Wscript.Echo "The given changelist file is empty."
    WriteChangeListDescription = IDABORT
    Exit Function
End If


WriteChangeListDescription = IDOK
End Function


