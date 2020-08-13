#include "stdafx.h"

#ifdef _DEBUG

#include "iscppunit.h"		//Brings in the supporting code for registering and running test cases
#include "iscppunitutils.cpp"		//Brings in the global allocations for performance monitor and proejct type singletons
#include "SampleTestSuite.h"		//SampleTestSuite

BEGIN_TESTSUITE_MAP()
ADD_TEST_SUITE(CSampleTestSuite)
END_TESTSUITE_MAP()

#endif //_DEBUG