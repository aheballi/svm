#include <TCHAR.h>

BOOL RebootPending(MSIHANDLE hInstall);
long __stdcall CheckRebootStatus(MSIHANDLE hMsi);
long __stdcall WriteRunOnce4WebReg(MSIHANDLE hMsi);
