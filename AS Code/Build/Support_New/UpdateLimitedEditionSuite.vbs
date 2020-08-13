' Wscript.Arguments are the following:
' (0) = Folder path to .issuite project
' (1) = IS atuomation interface version such as ISWiAuto20.ISWiProject
' (2) = New product name for project such as AdminStudio Symantec Limited Edition


Dim pFS
Set pFS = CreateObject("Scripting.FileSystemObject")
   
Dim pFolder
Set pFolder = pFS.GetFolder(Wscript.Arguments(0))
 
Dim pProject
Set pProject = CreateObject(Wscript.Arguments(1))
 
pProject.OpenProject pFolder.Path & "\AdminStudioSuite.issuite", False
pProject.ProductName = Wscript.Arguments(2)
pProject.SaveProject
pProject.CloseProject

Set pProject = Nothing   
Set pFolder = Nothing    
Set pFS = Nothing
