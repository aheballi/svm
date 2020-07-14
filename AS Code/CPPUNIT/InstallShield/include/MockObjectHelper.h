#pragma once

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_INIT
// Macro defines a map that is used to register when mock methods have been initialized
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_INIT() \
std::map<stringx,bool> m_mapInit;

/////////////////////////////////////////////////////////////////////////////////////
// !!!NOT IMPLEMENTED!!!
// MOCK_METHOD_WRAP_RAW
// Macro used to mock methods that take no arguments
//
// Method:	The name of the method to mock
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_RAW(Method) \
STDMETHOD (##Method)() \
{ \
	CPPUNIT_ASSERT_MESSAGE("MOCK_METHOD_WRAP_RAW mock macro has not yet been implemented",false); \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// !!!NOT IMPLEMENTED!!!
// MOCK_METHOD_WRAP_RAW_ONE
// Macro used to mock methods that take 1 argument
//
// Method:	The name of the method to mock
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_RAW_ONE(Method,Type) \
STDMETHOD (##Method)(Type var) \
{ \
	CPPUNIT_ASSERT_MESSAGE("MOCK_METHOD_WRAP_RAW_ONE mock macro has not yet been implemented",false); \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// !!!NOT IMPLEMENTED!!!
// MOCK_METHOD_WRAP_RAW_TWO
// Macro used to mock methods that take 2 arguments
//
// Method:	The name of the method to mock
// Type1:	The Type of the first argument
// Type2:	The Type of the second argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_RAW_TWO(Method,Type1,Type2) \
STDMETHOD (##Method)(Type1 var1,Type2 var2) \
{ \
	CPPUNIT_ASSERT_MESSAGE("MOCK_METHOD_WRAP_RAW_TWO mock macro has not yet been implemented",false); \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// !!!NOT IMPLEMENTED!!!
// MOCK_METHOD_WRAP_RAW_THREE
// Macro used to mock methods that take 3 arguments
//
// Method:	The name of the method to mock
// Type1:	The Type of the first argument
// Type2:	The Type of the second argument
// Type3:	The Type of the third argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_RAW_THREE(Method,Type1,Type2,Type3) \
STDMETHOD (##Method)(Type1 var1,Type2 var2,Type3 var3) \
{ \
	CPPUNIT_ASSERT_MESSAGE("MOCK_METHOD_WRAP_RAW_THREE mock macro has not yet been implemented",false); \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// !!!NOT IMPLEMENTED!!!
// MOCK_METHOD_WRAP_RAW_FOUR
// Macro used to mock methods that take 3 arguments
//
// Method:	The name of the method to mock
// Type1:	The Type of the first argument
// Type2:	The Type of the second argument
// Type3:	The Type of the third argument
// Type4:	The Type of the fourth argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_RAW_FOUR(Method,Type1,Type2,Type3,Type4) \
STDMETHOD (##Method)(Type1 var1,Type2 var2,Type3 var3,Type4 var4) \
{ \
	CPPUNIT_ASSERT_MESSAGE("MOCK_METHOD_WRAP_RAW_FOUR mock macro has not yet been implemented",false); \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// !!!NOT IMPLEMENTED!!!
// MOCK_METHOD_WRAP_RAW_FIVE
// Macro used to mock methods that take 5 arguments
//
// Method:	The name of the method to mock
// Type1:	The Type of the first argument
// Type2:	The Type of the second argument
// Type3:	The Type of the third argument
// Type4:	The Type of the fourth argument
// Type5:	The Type of the fifth argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_RAW_FIVE(Method,Type1,Type2,Type3,Type4,Type5) \
STDMETHOD (##Method)(Type1 var1,Type2 var2,Type3 var3,Type4 var4,Type5 var5) \
{ \
	CPPUNIT_ASSERT_MESSAGE("MOCK_METHOD_WRAP_RAW_FIVE mock macro has not yet been implemented",false); \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// !!!NOT IMPLEMENTED!!!
// MOCK_METHOD_WRAP_RAW_SIX
// Macro used to mock methods that take 6 arguments
//
// Method:	The name of the method to mock
// Type1:	The Type of the first argument
// Type2:	The Type of the second argument
// Type3:	The Type of the third argument
// Type4:	The Type of the fourth argument
// Type5:	The Type of the fifth argument
// Type6:	The Type of the sixth argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_RAW_SIX(Method,Type1,Type2,Type3,Type4,Type5,Type6) \
STDMETHOD (##Method)(Type1 var1,Type2 var2,Type3 var3,Type4 var4,Type5 var5,Type6 var6) \
{ \
	CPPUNIT_ASSERT_MESSAGE("MOCK_METHOD_WRAP_RAW_SIX mock macro has not yet been implemented",false); \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// !!!NOT IMPLEMENTED!!!
// MOCK_METHOD_WRAP_RAW_SEVEN
// Macro used to mock methods that take 7 arguments
//
// Method:	The name of the method to mock
// Type1:	The Type of the first argument
// Type2:	The Type of the second argument
// Type3:	The Type of the third argument
// Type4:	The Type of the fourth argument
// Type5:	The Type of the fifth argument
// Type6:	The Type of the sixth argument
// Type7:	The Type of the seventh argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_RAW_SEVEN(Method,Type1,Type2,Type3,Type4,Type5,Type6,Type7) \
STDMETHOD (##Method)(Type1 var1,Type2 var2,Type3 var3,Type4 var4,Type5 var5,Type6 var6,Type7 var7) \
{ \
	CPPUNIT_ASSERT_MESSAGE("MOCK_METHOD_WRAP_RAW_SEVEN mock macro has not yet been implemented",false); \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// !!!NOT IMPLEMENTED!!!
// MOCK_METHOD_WRAP_ADDCHILD
// Macro that mocks an AddChild function call
//
// Type: The type fo the first argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_ADDCHILD(Type) \
STDMETHOD(AddChild)( Type type, BSTR strName, VARIANT strUniqueKey, IsmAuto::IBusinessObject** pVal) \
{ \
	CPPUNIT_ASSERT_MESSAGE("MOCK_METHOD_WRAP_ADDCHILD mock macro has not yet been implemented",false); \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_PUT
// Macro used to mock a put_ method that takes 1 argument. Stores the value in a member 
// variable for retrieval using the MOCK_METHOD_WRAP_GET macro
//
// Method:	The name of the method to mock
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_PUT(Method,Type) \
Type m_##Method; \
STDMETHOD (put_##Method)(Type var) \
{ \
	m_##Method = var;\
	m_mapInit[#Method] = true; \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_GET
// Macro used to mock a get_ method that takes 1 argument. Retrieves the value from a member 
// variable for set using the MOCK_METHOD_WRAP_PUT macro
//
// Method:	The name of the method to mock
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_GET(Method,Type) \
STDMETHOD (get_##Method)(Type* var) \
{ \
	CPPUNIT_ASSERT_MESSAGE("Data for mock method not initialized",m_mapInit.find(#Method)!=m_mapInit.end()); \
	*var = m_##Method;\
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_PUT_GET
// Macro that defiines both the put_ and get_ methods
//
// Method:	The name of the method to mock
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_PUT_GET(Method,Type) \
MOCK_METHOD_WRAP_PUT(Method,Type) \
MOCK_METHOD_WRAP_GET(Method,Type)

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_PUT_ONE
// Macro used to mock a put_ method that takes 2 arguments where one fo the argumens
// is a key or index that uniquely identifies the value of the second argument. 
//
// Method:	The name of the method to mock
// Key:		The type of data used as the key
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_PUT_ONE(Method,Key,Type) \
std::map<Key,Type> m_map##Method; \
STDMETHOD (put_##Method)(Key key,Type var) \
{ \
	m_map##Method[key] = var;\
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_GET_ONE
// Macro used to mock a get_ method that takes 2 arguments where one of the argumens
// is a key or index that uniquely identifies the value of the second argument. Retrieves
// the value set by the MOCK_METHOD_WRAP_PUT_ONE macro.
//
// Method:	The name of the method to mock
// Key:		The type of data used as the key
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_GET_ONE(Method,Key,Type) \
STDMETHOD (get_##Method)(Key key,Type* var) \
{ \
	std::map<Key,Type>::iterator iter = m_map##Method.find(key); \
	CPPUNIT_ASSERT_MESSAGE("Data for mock method not initialized",iter!=m_map##Method.end()); \
	if(iter != m_map##Method.end()) \
	{ \
		*var = iter->second;\
	} \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_PUT_GET_ONE
// Macro that defiines both the put_ and get_ methods where one of the argumens
// is a key or index that uniquely identifies the value of the second argument.
//
// Method:	The name of the method to mock
// Key:		The type of data used as the key
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_PUT_GET_ONE(Method,Key,Type) \
MOCK_METHOD_WRAP_PUT_ONE(Method,Key,Type) \
MOCK_METHOD_WRAP_GET_ONE(Method,Key,Type)

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_PUT_ONE
// Macro used to mock a put_ method that takes 3 arguments where two of the arguments
// serve as a key or index that uniquely identifies the value of the third argument. 
//
// Method:	The name of the method to mock
// Key:		The type of data used as the key
// Key2:	The type of data used as the key
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_PUT_TWO(Method,Key,Key2,Type) \
std::map<std::pair<Key,Key2> ,Type> m_map##Method; \
STDMETHOD (put_##Method)(Key key,Key2 key2,Type var) \
{ \
	std::pair<Key,Key2> uberKey(key,key2); \
	m_map##Method[uberKey] = var;\
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_GET_TWO
// Macro used to mock a get_ method that takes 3 arguments where two of the arguments
// serve as a key or index that uniquely identifies the value of the third argument. Retrieves
// the value set by the MOCK_METHOD_WRAP_PUT_TWO macro.
//
// Method:	The name of the method to mock
// Key:		The type of data used as the key
// Key2:	The type of data used as the key
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_GET_TWO(Method,Key,Key2,Type) \
STDMETHOD (get_##Method)(Key key,Key2 key2,Type* var) \
{ \
	std::pair<Key,Key2> uberKey(key,key2); \
	std::map<std::pair<Key,Key2> ,Type>::iterator iter = m_map##Method.find(uberKey); \
	CPPUNIT_ASSERT_MESSAGE("Data for mock method not initialized",iter!=m_map##Method.end()); \
	if(iter != m_map##Method.end()) \
	{ \
		*var = iter->second;\
	} \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_PUT_GET_TWO
// Macro that defiines both the put_ and get_ methods that takes 3 arguments where two of the arguments
// serve as a key or index that uniquely identifies the value of the third argument.
//
// Method:	The name of the method to mock
// Key:		The type of data used as the key
// Key2:	The type of data used as the key
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_PUT_GET_TWO(Method,Key,Key2,Type) \
MOCK_METHOD_WRAP_PUT_TWO(Method,Key,Key2,Type) \
MOCK_METHOD_WRAP_GET_TWO(Method,Key,Key2,Type)

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_PUT_COMPTR
// Macro used to mock a put_ method that takes 1 argument where that argument is a COM interface
// Stores the value in a member variable for retrieval using the MOCK_METHOD_WRAP_GET_COMPTR macro
//
// Method:	The name of the method to mock
// Type:	The interface of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_PUT_COMPTR(Method,Type) \
CComPtr<Type> m_##Method; \
STDMETHOD (put_##Method)(Type* var) \
{ \
	m_##Method = var;\
	m_mapInit[#Method] = true; \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_GET_COMPTR
// Macro used to mock a get_ method that takes 1 argument where that argument is a COM interface
// Retrieves the value in a member variable for set using the MOCK_METHOD_WRAP_PUT_COMPTR macro
//
// Method:	The name of the method to mock
// Type:	The interface of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_GET_COMPTR(Method,Type) \
STDMETHOD (get_##Method)(Type** var) \
{ \
	CPPUNIT_ASSERT_MESSAGE("Data for mock method not initialized",m_mapInit.find(#Method)!=m_mapInit.end()); \
	m_##Method.QueryInterface(var);\
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_PUT_GET_COMPTR
// Macro that defiines both the put_ and get_ methods that takes 1 argument 
// where that argument is a COM interface
//
// Method:	The name of the method to mock
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_PUT_GET_COMPTR(Method,Type) \
MOCK_METHOD_WRAP_PUT_COMPTR(Method,Type) \
MOCK_METHOD_WRAP_GET_COMPTR(Method,Type)

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_PUT_COMPTR_ONE
// Macro used to mock a put_ method that takes 2 argument where one argument is a key
// and the other argument is a COM interface indexed by that key.
// Stores the value in a member variable for retrieval using the MOCK_METHOD_WRAP_GET_COMPTR_ONE
// macro
//
// Method:	The name of the method to mock
// Key:		The type of data used as the key
// Type:	The interface of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_PUT_COMPTR_ONE(Method,Key,Type) \
std::map<Key,CComPtr<Type> > m_map##Method; \
STDMETHOD (put_##Method)(Key key,Type* var) \
{ \
	m_map##Method[key] = var;\
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_GET_COMPTR_ONE
// Macro used to mock a get_ method that takes 2 argument where one argument is a key
// and the other argument is a COM interface indexed by that key.
// Retrieves the value in a member variable for set using the MOCK_METHOD_WRAP_PUT_COMPTR_ONE
// macro
//
// Method:	The name of the method to mock
// Key:		The type of data used as the key
// Type:	The interface of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_GET_COMPTR_ONE(Method,Key,Type) \
STDMETHOD (get_##Method)(Key key,Type** var) \
{ \
	std::map<Key,CComPtr<Type> >::iterator iter = m_map##Method.find(key); \
	CPPUNIT_ASSERT_MESSAGE("Data for mock method not initialized",iter!=m_map##Method.end()); \
	if(iter != m_map##Method.end()) \
	{ \
		iter->second.QueryInterface(var);\
	} \
	return S_OK; \
}

/////////////////////////////////////////////////////////////////////////////////////
// MOCK_METHOD_WRAP_PUT_GET_COMPTR
// Macro that defiines both the put_ and get_ methods that takes 2 argument where one
// argument is a key and the other argument is a COM interface indexed by that key.
//
// Method:	The name of the method to mock
// Key:		The type of data used as the key
// Type:	The Type of the argument
/////////////////////////////////////////////////////////////////////////////////////
#define MOCK_METHOD_WRAP_PUT_GET_COMPTR_ONE(Method,Key,Type) \
MOCK_METHOD_WRAP_PUT_COMPTR_ONE(Method,Key,Type) \
MOCK_METHOD_WRAP_GET_COMPTR_ONE(Method,Key,Type)