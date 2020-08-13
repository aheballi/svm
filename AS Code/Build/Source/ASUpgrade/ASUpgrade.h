// ASUpgrade.h : main header file for the ASUPGRADE DLL
//

#if !defined(AFX_ASUPGRADE_H__45440FF2_68ED_46F8_BCA4_5DE2BC3D6B50__INCLUDED_)
#define AFX_ASUPGRADE_H__45440FF2_68ED_46F8_BCA4_5DE2BC3D6B50__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

static const TCHAR* const g_lpszASDatabaseSection = _T("Database Settings");
static const TCHAR* const g_lpszASDefaultDatabaseKey = _T("DefaultDatabase");
static const TCHAR* const g_szASRecentDatabaseKey = _T("Software\\InstallShield\\AdminStudio\\Recent List");

/////////////////////////////////////////////////////////////////////////////
// CASUpgradeApp
// See ASUpgrade.cpp for the implementation of this class
//

class CASUpgradeApp : public CWinApp
{
public:
	CASUpgradeApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CASUpgradeApp)
	//}}AFX_VIRTUAL

	//{{AFX_MSG(CASUpgradeApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ASUPGRADE_H__45440FF2_68ED_46F8_BCA4_5DE2BC3D6B50__INCLUDED_)
