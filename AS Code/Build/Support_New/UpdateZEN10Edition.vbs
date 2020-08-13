Const ADMINSTUDIOMSISUBPATH = "AdminStudio.msi"
Const QMMSISUBPATH = "{0E5E5DAE-9F63-479B-B5AF-2C1BCEC16B84}.AdminStudio QualityMonitor.msi"
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

'delete shortcuts not used by ZEN10
Set xView = xDB.OpenView("DELETE FROM `Shortcut` Where `Shortcut`.`Shortcut`='JobManager'")
Call xView.Execute
Set xView = Nothing
Set xView = xDB.OpenView("DELETE FROM `Icon` Where `Icon`.`Name`='JobManager_BE354504CE2E4C07AA90364826C5D589.exe'")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("DELETE FROM `Shortcut` Where `Shortcut`.`Shortcut`='ConflictSolver'")
Call xView.Execute
Set xView = Nothing
Set xView = xDB.OpenView("DELETE FROM `Icon` Where `Icon`.`Name`='ConflictSolver_BE354504CE2E4C07AA90364826C5D589.exe'")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("DELETE FROM `Shortcut` Where `Shortcut`.`Shortcut`='CitrixHelpShortcut'")
Call xView.Execute
Set xView = Nothing
Set xView = xDB.OpenView("DELETE FROM `Icon` Where `Icon`.`Name`='CitrixHelpShortcut_2760CC537E9E4AF79EC9BD51E67E9B13.exe'")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("DELETE FROM `Shortcut` Where `Shortcut`.`Shortcut`='NewShortcut10'")
Call xView.Execute
Set xView = Nothing
Set xView = xDB.OpenView("DELETE FROM `Icon` Where `Icon`.`Name`='NewShortcut10_DBBA015D39E04E938698A4D82F8EA493.exe'")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("DELETE FROM `Shortcut` Where `Shortcut`.`Shortcut`='NewShortcut13'")
Call xView.Execute
Set xView = Nothing
Set xView = xDB.OpenView("DELETE FROM `Icon` Where `Icon`.`Name`='NewShortcut13_A4CFD985379647F4A3DEC7603E72B597.exe'")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("DELETE FROM `Shortcut` Where `Shortcut`.`Shortcut`='NewShortcut5'")
Call xView.Execute
Set xView = Nothing
Set xView = xDB.OpenView("DELETE FROM `Icon` Where `Icon`.`Name`='NewShortcut5_BE354504CE2E4C07AA90364826C5D589.exe'")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("DELETE FROM `Shortcut` Where `Shortcut`.`Shortcut`='OSSnapshot'")
Call xView.Execute
Set xView = Nothing
Set xView = xDB.OpenView("DELETE FROM `Icon` Where `Icon`.`Name`='OSSnapshot.exe'")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("DELETE FROM `Shortcut` Where `Shortcut`.`Shortcut`='AppManager'")
Call xView.Execute
Set xView = Nothing
Set xView = xDB.OpenView("DELETE FROM `Icon` Where `Icon`.`Name`='AppManager_BE354504CE2E4C07AA90364826C5D589.exe'")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("DELETE FROM `Shortcut` Where `Shortcut`.`Shortcut`='msi2vpShortcut'")
Call xView.Execute
Set xView = Nothing
Set xView = xDB.OpenView("DELETE FROM `Icon` Where `Icon`.`Name`='msi2vpShortcut_D540C2C42F2A45B7814F4BC8A7BE1030.exe'")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("DELETE FROM `IniFile` Where `IniFile`.`IniFile`='IniTableKey29'")
Call xView.Execute
Set xView = Nothing
Set xView = xDB.OpenView("DELETE FROM `IniFile` Where `IniFile`.`IniFile`='IniTableKey30'")
Call xView.Execute
Set xView = Nothing

Call xDB.Commit

Set xDB = Nothing
Set xInst = Nothing


'New starting in AS 9.0 - need to remove AS Distribution Wizard shortcut from Distribution Wizard isolated MSI because it is not appropriately conditioned based on EDITION property

Set xInst = CreateObject("WindowsInstaller.Installer")
Set xDB = xInst.OpenDatabase(WScript.Arguments(0) & QMMSISUBPATH, 1)

Set xView = xDB.OpenView("DELETE FROM `Shortcut` Where `Shortcut`.`Shortcut`='NewShortcut1'")
Call xView.Execute
Set xView = Nothing

Set xView = xDB.OpenView("DELETE FROM `Icon` Where `Icon`.`Name`='NewShortcut1_5A3242FC4E15471FA2ED95971311CF01.exe'")
Call xView.Execute
Set xView = Nothing

Call xDB.Commit

Set xDB = Nothing
Set xInst = Nothing
