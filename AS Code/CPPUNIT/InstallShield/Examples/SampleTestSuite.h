#pragma once

#include "iscppunit.h"

class CSampleTestSuite : public CppUnit::TestFixture
{
public:
	CSampleTestSuite(){};
	virtual ~CSampleTestSuite(){};
	
	CPPUNIT_TEST_SUITE(CSampleTestSuite);
	//CPPUNIT_TEST(testAlwaysFail);
	CPPUNIT_TEST(testAlwaysPass);
	CPPUNIT_TEST_SUITE_END();

public:
	virtual void setUp();
	virtual void tearDown();
	void testAlwaysFail();
	void testAlwaysPass();
};