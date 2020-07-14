#include "iscppunit.h"
#include "istestrunner.h"

///////////////////////////////////////////////////////////////////////////////////////////
// DLL Projects need to export the RunTests method
// The alias RunTests@@YGJPAUHWND__@@PAUHINSTANCE__@@PADH@Z is generated based on the compiler
// If you start to get runtime errors saying that the entry point could not be found
// it is possible that the decoration is wrong for the compiler you are using.
///////////////////////////////////////////////////////////////////////////////////////////
#ifdef _USRDLL
#pragma comment(linker, "/EXPORT:RunTests=?RunTests@@YGJPAUHWND__@@PAUHINSTANCE__@@PADH@Z")
#endif

///////////////////////////////////////////////////////////////////////////////////////////
// pragma to include the CppUnit library into the project
// They also force the inclusion of the c runtime libraries before the cppunit library
///////////////////////////////////////////////////////////////////////////////////////////
#ifdef _DEBUG
#if _MSC_VER < 1300
	#ifdef _DLL
		#pragma comment(lib, "cppunitd.lib")
	#else
		#pragma comment(lib, "cppunitds.lib")
	#endif
#elif _MSC_VER < 1500
	#ifndef _WIN64
		#ifdef _DLL
			#pragma comment(lib, "cppunitd8.lib")
		#else
			#pragma comment(lib, "cppunitd8s.lib")
		#endif
	#else
		#ifdef _DLL
			#pragma comment(lib, "cppunitd8x64.lib")
		#else
			#pragma comment(lib, "cppunitd8sx64.lib")
		#endif
	#endif
#elif _MSC_VER < 1600
	#ifndef _WIN64
		#ifdef _DLL
			#pragma comment(lib, "cppunitd9.lib")
		#else
			#pragma comment(lib, "cppunitd9s.lib")
		#endif
	#else
		#ifdef _DLL
			#pragma comment(lib, "cppunitd9x64.lib")
		#else
			#pragma comment(lib, "cppunitd9sx64.lib")
		#endif
	#endif
#elif _MSC_VER < 1700
	#ifndef _WIN64
		#ifdef _DLL
			#pragma comment(lib, "cppunitd10.lib")
		#else
			#pragma comment(lib, "cppunitd10s.lib")
		#endif
	#else
		#ifdef _DLL
			#pragma comment(lib, "cppunitd10x64.lib")
		#else
			#pragma comment(lib, "cppunitd10sx64.lib")
		#endif
	#endif
#else
	#ifndef _WIN64
		#ifdef _DLL
			#pragma comment(lib, "cppunitd11.lib")
		#else
			#pragma comment(lib, "cppunitd11s.lib")
		#endif
	#else
		#ifdef _DLL
			#pragma comment(lib, "cppunitd11x64.lib")
		#else
			#pragma comment(lib, "cppunitd11sx64.lib")
		#endif
	#endif
#endif
#endif // _DEBUG


///////////////////////////////////////////////////////////////////////////////////////////
// BEGIN_TESTSUITE_MAP
// This macro begins the defenition of the RunTests function for DLL proejcts
///////////////////////////////////////////////////////////////////////////////////////////
#define BEGIN_TESTSUITE_MAP() \
__declspec(dllexport) HRESULT __stdcall RunTests(HWND hwnd,HINSTANCE hinst,LPSTR lpCmdLine,int nCmdShow)\
{\
	ISTestRunner runner;

///////////////////////////////////////////////////////////////////////////////////////////
// BEGIN_TESTSUITE_MAP_MFC_EXE
// This macro begins a code block to run tests in MFC Exe Projects
// By adding this macr ot the InitInstance of your EXE you will automatically be able to 
// run test cases
///////////////////////////////////////////////////////////////////////////////////////////
#define BEGIN_TESTSUITE_MAP_MFC_EXE() \
if(lstrcmp(m_lpCmdLine,_T("-RunTests"))==0)\
{\
	ISTestRunner runner;

///////////////////////////////////////////////////////////////////////////////////////////
// ADD_TEST_SUITE
// Registers a test suite to be run when the test cases are executed.
//
// SuiteClass: The TestFixture class that needs to be executed
///////////////////////////////////////////////////////////////////////////////////////////
#define ADD_TEST_SUITE(SuiteClass) \
runner.addTest( SuiteClass::suite() );

///////////////////////////////////////////////////////////////////////////////////////////
// END_TESTSUITE_MAP
// This macro finished the code block for running test cases in your project
///////////////////////////////////////////////////////////////////////////////////////////
#define END_TESTSUITE_MAP() \
	runner.setOutputter(CppUnit::CompilerOutputter::defaultOutputter( &runner.result(), std::cerr )); \
	runner.run("", true); \
	return 0; \
}

template <class _IColl, class _IClass>
class CIsmAutoCollectionHelper
{
public:
	CIsmAutoCollectionHelper(){}
	virtual ~CIsmAutoCollectionHelper(){}

	static long GetCount(_IColl *pCol)
	{
		enumerator<_IColl, _IClass> enumCol(pCol);	
		CComPtr<_IClass> spClass;
		long lCount = 0;
		while (enumCol.next(spClass)) ++lCount;
		return lCount;
	}
};

#define ISMAUTO_ADD_DELETE_TEST(MyClassName,MethodName,GetParentMethodName,GetColMethodName,IParentCol,ICol,IClass,enumChild,Name,lDiff)	\
	ISMAUTO_ADD_TEST(MyClassName,MethodName,GetParentMethodName,GetColMethodName,IParentCol,ICol,IClass,enumChild,Name,lDiff)\
	ISMAUTO_DELETE_TEST(MyClassName,MethodName,GetParentMethodName,GetColMethodName,IParentCol,ICol,IClass,enumChild,Name,lDiff)

#define ISMAUTO_ADD_TEST(MyClassName,MethodName,GetParentMethodName,GetColMethodName,IParentCol,ICol,IClass,enumChild,Name,lDiff)	\
	void MyClassName##::testAdd##MethodName##()	\
{	\
	CComPtr<IsmAuto::IParentCol> spParent = GetParentMethodName##();\
	CComPtr<IsmAuto::ICol> spCol;\
	hrx hr = spParent->get_##GetColMethodName##(&spCol);\
	CIsmAutoCollectionHelper<IsmAuto::ICol, IsmAuto::IClass> ismAutoHelper;\
	long lCountBeforeAdd = ismAutoHelper.GetCount(spCol);\
	CComPtr<IsmAuto::IBusinessObject> spBusObj;\
	HRESULT hres = spParent->AddChild(IsmAuto::enumChild, stringx(Name), CComVariant(), &spBusObj);\
	CPPUNIT_ASSERT(SUCCEEDED(hres) && (spBusObj!=NULL));\
	long lCountAfterAdd = ismAutoHelper.GetCount(spCol);\
	CPPUNIT_ASSERT(lCountAfterAdd == lCountBeforeAdd+lDiff);\
}\

#define ISMAUTO_DELETE_TEST(MyClassName,MethodName,GetParentMethodName,GetColMethodName,IParentCol,ICol,IClass,enumChild,Name,lDiff)	\
	void MyClassName##::testDelete##MethodName##()	\
{	\
	CComPtr<IsmAuto::IParentCol> spParent = GetParentMethodName##();\
	CComPtr<IsmAuto::ICol> spCol;\
	hrx hr = spParent->get_##GetColMethodName##(&spCol);\
	CComPtr<IsmAuto::IBusinessObject> spBusObj;\
	hr = spParent->AddChild(IsmAuto::enumChild, stringx(Name), CComVariant(), &spBusObj);\
	CIsmAutoCollectionHelper<IsmAuto::ICol, IsmAuto::IClass> ismAutoHelper;\
	long lCountBeforeDelete = ismAutoHelper.GetCount(spCol);\
	HRESULT hres = spBusObj->Delete();\
	CPPUNIT_ASSERT(SUCCEEDED(hres));\
	long lCountAfterDelete = ismAutoHelper.GetCount(spCol);\
	CPPUNIT_ASSERT(lCountAfterDelete == lCountBeforeDelete-lDiff);\
}

#define ISMAUTO_DELETE_TEST_WITH_REMOVE(MyClassName,MethodName,GetParentMethodName,GetColMethodName,IParentCol,ICol,IClass,enumChild,Name,lDiff)	\
	void MyClassName##::testDelete##MethodName##()	\
{	\
	CComPtr<IsmAuto::IParentCol> spParent = GetParentMethodName##();\
	CComPtr<IsmAuto::ICol> spCol;\
	hrx hr = spParent->get_##GetColMethodName##(&spCol);\
	CComPtr<IsmAuto::IBusinessObject> spBusObj;\
	hr = spParent->AddChild(IsmAuto::enumChild, stringx(Name), CComVariant(), &spBusObj);\
	CIsmAutoCollectionHelper<IsmAuto::ICol, IsmAuto::IClass> ismAutoHelper;\
	long lCountBeforeDelete = ismAutoHelper.GetCount(spCol);\
	CComPtr<IsmAuto::IBusinessObject> spBusObjParent = is_com_cast<IsmAuto::IBusinessObject>(spParent);\
	CComPtr<IsmAuto::IClass> spClass = is_com_cast<IsmAuto::IClass>(spBusObj);\
	HRESULT hres = spClass->Remove(spBusObjParent);\
	CPPUNIT_ASSERT(SUCCEEDED(hres));\
	hres = spBusObj->Delete();\
	CPPUNIT_ASSERT(SUCCEEDED(hres));\
	long lCountAfterDelete = ismAutoHelper.GetCount(spCol);\
	CPPUNIT_ASSERT(lCountAfterDelete == lCountBeforeDelete-lDiff);\
}

#define PUT_GET_PARITY_TEST(ObjectPtr,Method,Value,ValueType) \
	{\
	hrx hr = ObjectPtr->put_##Method(Value);\
	GET_VALUE_TEST(ObjectPtr,Method,Value,ValueType) \
	}

#define PUT_GET_PARITY_TEST2(ObjectPtr,Method,Param1,Value,ValueType) \
	{\
	hrx hr = ObjectPtr->put_##Method(Param1,Value);\
	GET_VALUE_TEST2(ObjectPtr,Method,Param1,Value,ValueType) \
	}

#define GET_VALUE_TEST(ObjectPtr,Method,Value,ValueType) \
	{\
	ValueType valCheck;\
	hrx hr = ObjectPtr->get_##Method(&valCheck);\
	CPPUNIT_ASSERT(valCheck == Value);\
	}

#define GET_VALUE_TEST2(ObjectPtr,Method,Param1,Value,ValueType) \
	{\
	ValueType valCheck;\
	hrx hr = ObjectPtr->get_##Method(Param1,&valCheck);\
	CPPUNIT_ASSERT(valCheck == Value);\
	}

#define PUT_GET_PARITY_TEST_BSTR(ObjectPtr,Method,Value) \
	{\
	hrx hr = ObjectPtr->put_##Method(Value);\
	GET_VALUE_TEST_BSTR(ObjectPtr,Method,Value) \
	}

#define GET_VALUE_TEST_BSTR(ObjectPtr,Method,Value) \
	{\
	CComBSTR valCheck;\
	hrx hr = ObjectPtr->get_##Method(&valCheck);\
	CPPUNIT_ASSERT(!::wcscmp(valCheck, Value));\
	}


#define PUT_VALUE_TEST(ObjectPtr,Method,Value) \
	{\
	try\
		{\
		hrx hr = ObjectPtr->put_##Method(Value);\
		}catch(...)\
		{\
		CPPUNIT_ASSERT(false);\
		}\
	}

#define GET_ITEM_TEST(ObjectPtr,Method,ColType,Type,Index,Return) \
	{\
	CComPtr<ColType> spObjects;\
	hrx hr = ObjectPtr->get_##Method(&spObjects);\
	CComPtr<Type> spObject;\
	hr = spObjects->get_Item(CComVariant(Index),&Return);\
	CPPUNIT_ASSERT(Return);\
	}

#define GET_ITEM_TEST2(ObjectPtr,Method,Index,Return) \
	{\
	hrx hr = ObjectPtr->##Method(Index,&Return);\
	CPPUNIT_ASSERT(Return);\
	}

#define DELETE_ISMAUTO_ITEM(ObjectPtr) \
	{\
	is_com_cast<IsmAuto::IBusinessObject> spObject = ObjectPtr;\
	hrx hr = spObject->Delete();\
	}

#define PUT_GET_PARITY_TEST_RAW(ObjectPtr,Method,Value,ValueType) \
	{\
	hrx hr = ObjectPtr->raw_put_##Method(Value);\
	GET_VALUE_TEST_RAW(ObjectPtr,Method,Value,ValueType) \
	}

#define GET_VALUE_TEST_RAW(ObjectPtr,Method,Value,ValueType) \
	{\
	ValueType valCheck;\
	hrx hr = ObjectPtr->raw_get_##Method(&valCheck);\
	CPPUNIT_ASSERT(valCheck == Value);\
	}



