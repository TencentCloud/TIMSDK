// IDataObjectImpl.h: interface for the CIDataObjectImpl class.
/**************************************************************************
THIS CODE AND INFORMATION IS PROVIDED 'AS IS' WITHOUT WARRANTY OF
ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
PARTICULAR PURPOSE.
Author: Leon Finker  1/2001
**************************************************************************/
#ifndef __DRAGDROPIMPL_H__
#define __DRAGDROPIMPL_H__
#include <shlobj.h>
#include <vector>

namespace DuiLib {
	typedef std::vector<FORMATETC> FormatEtcArray;
	typedef std::vector<FORMATETC*> PFormatEtcArray;
	typedef std::vector<STGMEDIUM*> PStgMediumArray;
	
	///////////////////////////////////////////////////////////////////////////////////////////////
	class UILIB_API CEnumFormatEtc : public IEnumFORMATETC
	{
	private:
		ULONG           m_cRefCount;
		FormatEtcArray  m_pFmtEtc;
		int           m_iCur;

	public:
		CEnumFormatEtc(const FormatEtcArray& ArrFE);
		CEnumFormatEtc(const PFormatEtcArray& ArrFE);
		//IUnknown members
		STDMETHOD(QueryInterface)(REFIID, void FAR* FAR*);
		STDMETHOD_(ULONG, AddRef)(void);
		STDMETHOD_(ULONG, Release)(void);

		//IEnumFORMATETC members
		STDMETHOD(Next)(ULONG, LPFORMATETC, ULONG FAR *);
		STDMETHOD(Skip)(ULONG);
		STDMETHOD(Reset)(void);
		STDMETHOD(Clone)(IEnumFORMATETC FAR * FAR*);
	};

	///////////////////////////////////////////////////////////////////////////////////////////////
	class UILIB_API CIDropSource : public IDropSource
	{
		long m_cRefCount;
	public:
		bool m_bDropped;

		CIDropSource::CIDropSource():m_cRefCount(0),m_bDropped(false) {}
		//IUnknown
		virtual HRESULT STDMETHODCALLTYPE QueryInterface(
			/* [in] */ REFIID riid,
			/* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);        
		virtual ULONG STDMETHODCALLTYPE AddRef( void);
		virtual ULONG STDMETHODCALLTYPE Release( void);
		//IDropSource
		virtual HRESULT STDMETHODCALLTYPE QueryContinueDrag( 
			/* [in] */ BOOL fEscapePressed,
			/* [in] */ DWORD grfKeyState);

		virtual HRESULT STDMETHODCALLTYPE GiveFeedback( 
			/* [in] */ DWORD dwEffect);
	};

	///////////////////////////////////////////////////////////////////////////////////////////////
	class UILIB_API CIDataObject : public IDataObject//,public IAsyncOperation
	{
		CIDropSource* m_pDropSource;
		long m_cRefCount;
		PFormatEtcArray m_ArrFormatEtc;
		PStgMediumArray m_StgMedium;

	public:
		CIDataObject(CIDropSource* pDropSource);
		~CIDataObject();
		void CopyMedium(STGMEDIUM* pMedDest, STGMEDIUM* pMedSrc, FORMATETC* pFmtSrc);
		//IUnknown
		virtual HRESULT STDMETHODCALLTYPE QueryInterface(
			/* [in] */ REFIID riid,
			/* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);        
		virtual ULONG STDMETHODCALLTYPE AddRef( void);
		virtual ULONG STDMETHODCALLTYPE Release( void);

		//IDataObject
		virtual /* [local] */ HRESULT STDMETHODCALLTYPE GetData( 
			/* [unique][in] */ FORMATETC __RPC_FAR *pformatetcIn,
			/* [out] */ STGMEDIUM __RPC_FAR *pmedium);

		virtual /* [local] */ HRESULT STDMETHODCALLTYPE GetDataHere( 
			/* [unique][in] */ FORMATETC __RPC_FAR *pformatetc,
			/* [out][in] */ STGMEDIUM __RPC_FAR *pmedium);

		virtual HRESULT STDMETHODCALLTYPE QueryGetData( 
			/* [unique][in] */ FORMATETC __RPC_FAR *pformatetc);

		virtual HRESULT STDMETHODCALLTYPE GetCanonicalFormatEtc( 
			/* [unique][in] */ FORMATETC __RPC_FAR *pformatectIn,
			/* [out] */ FORMATETC __RPC_FAR *pformatetcOut);

		virtual /* [local] */ HRESULT STDMETHODCALLTYPE SetData( 
			/* [unique][in] */ FORMATETC __RPC_FAR *pformatetc,
			/* [unique][in] */ STGMEDIUM __RPC_FAR *pmedium,
			/* [in] */ BOOL fRelease);

		virtual HRESULT STDMETHODCALLTYPE EnumFormatEtc( 
			/* [in] */ DWORD dwDirection,
			/* [out] */ IEnumFORMATETC __RPC_FAR *__RPC_FAR *ppenumFormatEtc);

		virtual HRESULT STDMETHODCALLTYPE DAdvise( 
			/* [in] */ FORMATETC __RPC_FAR *pformatetc,
			/* [in] */ DWORD advf,
			/* [unique][in] */ IAdviseSink __RPC_FAR *pAdvSink,
			/* [out] */ DWORD __RPC_FAR *pdwConnection);

		virtual HRESULT STDMETHODCALLTYPE DUnadvise( 
			/* [in] */ DWORD dwConnection);

		virtual HRESULT STDMETHODCALLTYPE EnumDAdvise( 
			/* [out] */ IEnumSTATDATA __RPC_FAR *__RPC_FAR *ppenumAdvise);

		//IAsyncOperation
		//virtual HRESULT STDMETHODCALLTYPE SetAsyncMode( 
		//    /* [in] */ BOOL fDoOpAsync)
		//{
		//	return E_NOTIMPL;
		//}
		//
		//virtual HRESULT STDMETHODCALLTYPE GetAsyncMode( 
		//    /* [out] */ BOOL __RPC_FAR *pfIsOpAsync)
		//{
		//	return E_NOTIMPL;
		//}
		//
		//virtual HRESULT STDMETHODCALLTYPE StartOperation( 
		//    /* [optional][unique][in] */ IBindCtx __RPC_FAR *pbcReserved)
		//{
		//	return E_NOTIMPL;
		//}
		//
		//virtual HRESULT STDMETHODCALLTYPE InOperation( 
		//    /* [out] */ BOOL __RPC_FAR *pfInAsyncOp)
		//{
		//	return E_NOTIMPL;
		//}
		//
		//virtual HRESULT STDMETHODCALLTYPE EndOperation( 
		//    /* [in] */ HRESULT hResult,
		//    /* [unique][in] */ IBindCtx __RPC_FAR *pbcReserved,
		//    /* [in] */ DWORD dwEffects)
		//{
		//	return E_NOTIMPL;
		//}
	};

	///////////////////////////////////////////////////////////////////////////////////////////////
	class UILIB_API CIDropTarget : public IDropTarget
	{
		DWORD m_cRefCount;
		bool m_bAllowDrop;
		struct IDropTargetHelper *m_pDropTargetHelper;
		FormatEtcArray m_formatetc;
		FORMATETC* m_pSupportedFrmt;
	protected:
		HWND m_hTargetWnd;
	public:

		CIDropTarget(HWND m_hTargetWnd = NULL);
		virtual ~CIDropTarget();
		void AddSuportedFormat(FORMATETC& ftetc) { m_formatetc.push_back(ftetc); }
		void SetTargetWnd(HWND hWnd) { m_hTargetWnd = hWnd; }

		//return values: true - release the medium. false - don't release the medium 
		virtual bool OnDrop(FORMATETC* pFmtEtc, STGMEDIUM& medium,DWORD *pdwEffect) = 0;

		virtual HRESULT STDMETHODCALLTYPE QueryInterface( 
			/* [in] */ REFIID riid,
			/* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
		virtual ULONG STDMETHODCALLTYPE AddRef( void) { return ++m_cRefCount; }
		virtual ULONG STDMETHODCALLTYPE Release( void);

		bool QueryDrop(DWORD grfKeyState, LPDWORD pdwEffect);
		virtual HRESULT STDMETHODCALLTYPE DragEnter(
			/* [unique][in] */ IDataObject __RPC_FAR *pDataObj,
			/* [in] */ DWORD grfKeyState,
			/* [in] */ POINTL pt,
			/* [out][in] */ DWORD __RPC_FAR *pdwEffect);
		virtual HRESULT STDMETHODCALLTYPE DragOver( 
			/* [in] */ DWORD grfKeyState,
			/* [in] */ POINTL pt,
			/* [out][in] */ DWORD __RPC_FAR *pdwEffect);
		virtual HRESULT STDMETHODCALLTYPE DragLeave( void);    
		virtual HRESULT STDMETHODCALLTYPE Drop(
			/* [unique][in] */ IDataObject __RPC_FAR *pDataObj,
			/* [in] */ DWORD grfKeyState,
			/* [in] */ POINTL pt,
			/* [out][in] */ DWORD __RPC_FAR *pdwEffect);
	};

	class UILIB_API CDragSourceHelper
	{
		IDragSourceHelper* pDragSourceHelper;
	public:
		CDragSourceHelper()
		{
			if(FAILED(CoCreateInstance(CLSID_DragDropHelper,
				NULL,
				CLSCTX_INPROC_SERVER,
				IID_IDragSourceHelper,
				(void**)&pDragSourceHelper)))
				pDragSourceHelper = NULL;
		}
		virtual ~CDragSourceHelper()
		{
			if( pDragSourceHelper!= NULL )
			{
				pDragSourceHelper->Release();
				pDragSourceHelper=NULL;
			}
		}

		// IDragSourceHelper
		HRESULT InitializeFromBitmap(HBITMAP hBitmap, 
			POINT& pt,	// cursor position in client coords of the window
			RECT& rc,	// selected item's bounding rect
			IDataObject* pDataObject,
			COLORREF crColorKey=GetSysColor(COLOR_WINDOW)// color of the window used for transparent effect.
			)
		{
			if(pDragSourceHelper == NULL)
				return E_FAIL;

			SHDRAGIMAGE di;
			BITMAP      bm;
			GetObject(hBitmap, sizeof(bm), &bm);
			di.sizeDragImage.cx = bm.bmWidth;
			di.sizeDragImage.cy = bm.bmHeight;
			di.hbmpDragImage = hBitmap;
			di.crColorKey = crColorKey; 
			di.ptOffset.x = pt.x - rc.left;
			di.ptOffset.y = pt.y - rc.top;
			return pDragSourceHelper->InitializeFromBitmap(&di, pDataObject);
		}
		HRESULT InitializeFromWindow(HWND hwnd, POINT& pt,IDataObject* pDataObject)
		{		
			if(pDragSourceHelper == NULL)
				return E_FAIL;
			return pDragSourceHelper->InitializeFromWindow(hwnd, &pt, pDataObject);
		}
	};
}
#endif //__DRAGDROPIMPL_H__