Const ADMINSTUDIOMSISUBPATH = "AdminStudio.msi"
Dim xInst
Dim xDB
Dim xView

Set xInst = CreateObject("WindowsInstaller.Installer")
Set xDB = xInst.OpenDatabase(WScript.Arguments(0) & ADMINSTUDIOMSISUBPATH, 1)

Set xView = xDB.OpenView("INSERT INTO `Property` (`Property`,`Value`) VALUES ('EDITION', 'NOVELL')")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("INSERT INTO `Property` (`Property`,`Value`) VALUES ('OEMEDITIONPRODNAME', 'AdminStudio ZENworks Edition')")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("INSERT INTO `LaunchCondition` (`Condition`, `Description`) VALUES ('Not(AS30 OR AS35 OR AS5055 OR AS60)','[ProductName] cannot be installed on this machine because a previous version of AdminStudio is already installed. Please uninstall the previous version and launch this installation again.')")    
Call xView.Execute
Set xView = Nothing

Call xDB.Commit

Set xDB = Nothing
Set xInst = Nothing




