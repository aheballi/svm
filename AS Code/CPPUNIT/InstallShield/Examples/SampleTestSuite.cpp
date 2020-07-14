#include "stdafx.h"
#include "SampleTestSuite.h"

void CSampleTestSuite::setUp()
{
	/////////////////////////////////////////////
	//TODO:: Add any initialization/constructor code here
	/////////////////////////////////////////////
}
	
void CSampleTestSuite::tearDown()
{
	/////////////////////////////////////////////
	//TODO:: Add any destructor code here
	/////////////////////////////////////////////
}

void CSampleTestSuite::testAlwaysFail()
{
	CPPUNIT_ASSERT(false);
}

void CSampleTestSuite::testAlwaysPass()
{
	CPPUNIT_ASSERT(true);
}