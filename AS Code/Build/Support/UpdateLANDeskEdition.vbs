Const ADMINSTUDIOMSISUBPATH = "AdminStudio.msi"
Dim xInst
Dim xDB
Dim xView

Set xInst = CreateObject("WindowsInstaller.Installer")
Set xDB = xInst.OpenDatabase(WScript.Arguments(0) & ADMINSTUDIOMSISUBPATH, 1)

Set xView = xDB.OpenView("INSERT INTO `Property` (`Property`,`Value`) VALUES ('EDITION', 'LANDesk')")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("INSERT INTO `Property` (`Property`,`Value`) VALUES ('OEMEDITIONPRODNAME', 'AdminStudio LE for LANDesk Management Suite')")
Call xView.Execute
Set xView = Nothing

Call xDB.Commit

Set xDB = Nothing
Set xInst = Nothing


