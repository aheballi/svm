'If a specific MSI property is set, then this method will return false causing the installation to abort.
'This is only meant for internal testing purposes to verify that the install correctly rollsback.
Const IDOK = 1
Const IDCANCEL = 2
Const IDABORT = 3

function ASCauseRollback()
	'if (Property("ASCAUSEROLLBACK") = "1")
	'	ASCauseRollback = IDCANCEL
	'end if
	ASCauseRollback = IDCANCEL
end function	