#pragma once

#include "atlcom.h"
#include "ismautowrapper.h"
#include "refcollection.h"
using namespace is;

/////////////////////////////////////////////////////////////////////////////////
// IPrivAddToCollection
// Template interface used by CEntityCollectionMock for adding items to a mock collection
//
// IObject:		The interface of the object contained by the collection
//				defined in CEntityCollectionMock
/////////////////////////////////////////////////////////////////////////////////
template<class IObject>
interface __declspec(uuid("E023D03D-CE27-11D5-ABD1-00B0D02332EB"))IPrivAddToCollection : public IUnknown
{
	virtual void Add(VARIANT sItem, IObject* pObject) =0;
};

/////////////////////////////////////////////////////////////////////////////////
// CEntityCollectionMock
// Template class for mocking an entity collection
//
// ICollection:	The interface of the collection to be mocked
// IObject:		The interface of the object contained by the collection
/////////////////////////////////////////////////////////////////////////////////
template<class ICollection,class IObject>
class ATL_NO_VTABLE CEntityCollectionMock : 
	public CComCoClass<CEntityCollectionMock,&CLSID_NULL>,
	public IPrivAddToCollection<IObject>,
	public IRefCollectionOnSTLImpl<ICollection, &__uuidof(ICollection),
	&IsmAuto::LIBID_IsmAutoLib, IObject*, vector_map<IObject*, stringw> >
{
	typedef IRefCollectionOnSTLImpl<ICollection, &__uuidof(ICollection),
		&IsmAuto::LIBID_IsmAutoLib, IObject*, vector_map<IObject*, stringw> > BASEREFCOL;

public:

	CEntityCollectionMock(){};
	virtual ~CEntityCollectionMock(){};

BEGIN_COM_MAP(CEntityCollectionMock)
	COM_INTERFACE_ENTRY(ICollection)
	COM_INTERFACE_ENTRY(IPrivAddToCollection<IObject>)
END_COM_MAP()

	STDMETHOD(Refresh)() 
	{
		return E_NOTIMPL;
	}

	STDMETHOD(get__NewEnum)(LPUNKNOWN *ppUnk)
	{
		return BASEREFCOL::get__NewEnum(ppUnk);
	}

    STDMETHOD(get_NewEnum)(IsmAuto::IVBEnumVARIANT** ppVariant)
	{
		CComPtr<IUnknown> pUnk;
		get__NewEnum(&pUnk);

		CComQIPtr<IEnumVARIANT> pVar = pUnk;

		return pVar->QueryInterface(__uuidof(IEnumVARIANT), (void**)ppVariant);
	}

	void Add(VARIANT sItem, IObject* pObject)
	{
		CComVariant vt(sItem);
		vt.ChangeType(VT_BSTR);
		stringx str(vt.bstrVal);
		BASEREFCOL::Add((LPCTSTR)str,pObject);
	}
};