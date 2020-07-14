#pragma once

#include "iscppunit.h"
#include "singleton.h"
////////////////////////////////////////////////////////////////////////////////////////
// CPerformanceBase
// Simple class that measures the ammount of time it takes to perform some action
////////////////////////////////////////////////////////////////////////////////////////
class CPerformanceBase
{
public:
	CPerformanceBase():m_dwStartTickCount(0),m_dwEndTickCount(0){};

	void Start()
	{
		m_dwStartTickCount = GetTickCount();
	}

	void Finish()
	{
		m_dwEndTickCount = GetTickCount();
	}

protected:	

	DWORD GetPerformance()
	{
		return m_dwEndTickCount - m_dwStartTickCount;
	}

private:
	DWORD m_dwStartTickCount;
	DWORD m_dwEndTickCount;
};

////////////////////////////////////////////////////////////////////////////////////////
// CPerformanceTestCase
// Class for testing the performance of a specific test case This is a smart class so you 
// only need to define the object in the scope of the code that you want to profile and
// when that function goes out of scope the results will be written to the output window.
//
// Related Macros:
// GET_TEST_METHOD_PERFORMANCE()
////////////////////////////////////////////////////////////////////////////////////////
class CPerformanceTestCase : public CPerformanceBase
{
public:
	CPerformanceTestCase()
	{
		Start();
	}

	~CPerformanceTestCase()
	{
		Finish();
		DisplayResults();
	}

	
	void DisplayResults()
	{
		stringx sResultsLine1;
		sResultsLine1.format(L"TEST EXECUTED IN %d MILLISECONDS",GetPerformance());
		
		//std::ostream stream(std::cerr);
		//stream << " " << std::endl;
		//stream << "-----------PERFORMANCE MONITORING RESULTS: METHOD----------" << std::endl;
		//stream << (LPCSTR)sResultsLine1 << std::endl;
		//stream << "-----------------------------------------------------------" << std::endl;
		//stream << " " << std::endl;
	}		
};

////////////////////////////////////////////////////////////////////////////////////////
// CPerformanceSuite
// Class for testing the performance of a suite of test cases. Normally used via the macros 
// defined at the end of this file.
//
// Related Macros:
// CPPUNIT_USES_PERFMON()
// CPPUNIT_STARTPERFMON()
// CPPUNIT_FINISHPERFMON()
//
////////////////////////////////////////////////////////////////////////////////////////
class CPerformanceSuite : public CPerformanceBase
{
public:
	CPerformanceSuite():m_nTests(0){};

	void AddTest()
	{
		m_nTests++;
	}

	void SetTestCount(int iCount)
	{
		m_nTests = iCount;
	}

	void DisplayResults()
	{
		stringx sResultsLine1;
		sResultsLine1.format(L"TOTAL %d TESTS IN %d MILLISECONDS",m_nTests,GetPerformance());
		
		stringx sResultsLine2;
		if(m_nTests>0)
		{
			sResultsLine2.format(L"AVERAGE 1 TEST PER %d MILLISECONDS",GetPerformance()/m_nTests);
		}

		//std::ostream stream(std::cerr);
		//stream << " " << std::endl;
		//stream << "-----------PERFORMANCE MONITORING RESULTS: SUITE-----------" << std::endl;
		//stream << (LPCSTR)sResultsLine1 << std::endl;
		//stream << (LPCSTR)sResultsLine2 << std::endl;
		//stream << "-----------------------------------------------------------" << std::endl;
		//stream << " " << std::endl;
	}	

private:
	int m_nTests;
};

////////////////////////////////////////////////////////////////////////////////////////
// CPerformanceProject
// Class for testing the performance of an entire project. This is a smart class so you 
// only need to define the object in the scope of the code that you want to profile and
// when that function goes out of scope the results will be written to the output window.
//
// Related Macros:
// GET_TEST_PROJECT_PERFORMANCE()
////////////////////////////////////////////////////////////////////////////////////////
class CPerformanceProject : public CPerformanceBase
{
public:
	CPerformanceProject()
	{
		Start();
	}

	~CPerformanceProject()
	{
		Finish();
		DisplayResults();
	}


	void DisplayResults()
	{
		stringx sResultsLine1;
		sResultsLine1.format(L"PROJECT TESTS EXECUTED IN %d MILLISECONDS",GetPerformance());
		
		//std::ostream stream(std::cerr);
		//stream << " " << std::endl;
		//stream << "-----------PERFORMANCE MONITORING RESULTS: PROJECT---------" << std::endl;
		//stream << (LPCSTR)sResultsLine1 << std::endl;
		//stream << "-----------------------------------------------------------" << std::endl;
		//stream << " " << std::endl;
	}
};

////////////////////////////////////////////////////////////////////////////////////////
// GET_TEST_PROJECT_PERFORMANCE()
// Helper macro for testing the performance of a projct
////////////////////////////////////////////////////////////////////////////////////////
#define GET_TEST_PROJECT_PERFORMANCE() \
CPerformanceProject testProjectPerformance; 

////////////////////////////////////////////////////////////////////////////////////////
// GET_TEST_METHOD_PERFORMANCE()
// Helper macro for testing the performance of a method
////////////////////////////////////////////////////////////////////////////////////////
#define GET_TEST_METHOD_PERFORMANCE() \
CPerformanceTestCase testCasePerformance; 

////////////////////////////////////////////////////////////////////////////////////////
// SUITE_PERFORMANCE_MONITOR
// Typedef for using CPerformance suite as a singleton
////////////////////////////////////////////////////////////////////////////////////////
typedef CSingleton<CPerformanceSuite> SUITE_PERFORMANCE_MONITOR;

////////////////////////////////////////////////////////////////////////////////////////
// CPPUNIT_USES_PERFMON
// Macro to define the functions FinishSuitePerformanceTest and StartSuitePerformanceTest
////////////////////////////////////////////////////////////////////////////////////////
#define CPPUNIT_USES_PERFMON() \
void FinishSuitePerformanceTest() \
{ \
	SUITE_PERFORMANCE_MONITOR* perfmon = SUITE_PERFORMANCE_MONITOR::Instance(); \
	perfmon->Finish(); \
	perfmon->DisplayResults(); \
}\
\
void StartSuitePerformanceTest() \
{ \
	SUITE_PERFORMANCE_MONITOR* perfmon = SUITE_PERFORMANCE_MONITOR::Instance(); \
	perfmon->Start(); \
}

////////////////////////////////////////////////////////////////////////////////////////
// CPPUNIT_STARTPERFMON
// Macro to register the StartSuitePerformanceTest method with CppUnit
////////////////////////////////////////////////////////////////////////////////////////
#define CPPUNIT_STARTPERFMON() \
CPPUNIT_TEST(StartSuitePerformanceTest);

////////////////////////////////////////////////////////////////////////////////////////
// CPPUNIT_FINISHPERFMON
// Macro to register the FinishSuitePerformanceTest method with CppUnit
// Also sets the total test count for the suite into perfmon for calculating averages.
////////////////////////////////////////////////////////////////////////////////////////
#define CPPUNIT_FINISHPERFMON() \
CPPUNIT_TEST(FinishSuitePerformanceTest); \
SUITE_PERFORMANCE_MONITOR* perfmon = SUITE_PERFORMANCE_MONITOR::Instance(); \
perfmon->SetTestCount(builder.suite()->countTestCases()); 

