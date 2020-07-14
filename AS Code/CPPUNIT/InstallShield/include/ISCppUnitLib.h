
#pragma once

#if !defined CPPUNIT_LIB && !defined _LIB
#   ifdef CPPUNIT_EXPORTS
#       define IS_CPP_UNIT_API __declspec(dllexport)
#   else
#       define IS_CPP_UNIT_API __declspec(dllimport)
#   endif
#else
#   define IS_CPP_UNIT_API
#	ifdef _DLL
#   	pragma comment(lib, "ISCppUnit.lib")
#	else
#   	pragma comment(lib, "ISCppUnitS.lib")
#   endif
#endif

