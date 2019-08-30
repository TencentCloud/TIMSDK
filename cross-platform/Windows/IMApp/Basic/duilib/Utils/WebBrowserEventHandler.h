#pragma once
#include <ExDisp.h>
#include <ExDispid.h>
#include <mshtmhst.h>

namespace DuiLib
{
    class CWebBrowserUI;
    class CWebBrowserEventHandler
    {
    public:
        CWebBrowserEventHandler() {}
        ~CWebBrowserEventHandler() {}

        virtual void BeforeNavigate2(CWebBrowserUI* pWeb, IDispatch *pDisp,VARIANT *&url,VARIANT *&Flags,VARIANT *&TargetFrameName,VARIANT *&PostData,VARIANT *&Headers,VARIANT_BOOL *&Cancel ) {}
        virtual void NavigateError(CWebBrowserUI* pWeb, IDispatch *pDisp,VARIANT * &url,VARIANT *&TargetFrameName,VARIANT *&StatusCode,VARIANT_BOOL *&Cancel) {}
        virtual void NavigateComplete2(CWebBrowserUI* pWeb, IDispatch *pDisp,VARIANT *&url){}
        virtual void ProgressChange(CWebBrowserUI* pWeb, LONG nProgress, LONG nProgressMax){}
        virtual void NewWindow3(CWebBrowserUI* pWeb, IDispatch **pDisp, VARIANT_BOOL *&Cancel, DWORD dwFlags, BSTR bstrUrlContext, BSTR bstrUrl){}
        virtual void CommandStateChange(CWebBrowserUI* pWeb, long Command,VARIANT_BOOL Enable){};
        virtual void TitleChange(CWebBrowserUI* pWeb, BSTR bstrTitle){};
        virtual void DocumentComplete(CWebBrowserUI* pWeb, IDispatch *pDisp,VARIANT *&url){}

        // interface IDocHostUIHandler
        virtual HRESULT STDMETHODCALLTYPE ShowContextMenu(CWebBrowserUI* pWeb, 
            /* [in] */ DWORD dwID,
            /* [in] */ POINT __RPC_FAR *ppt,
            /* [in] */ IUnknown __RPC_FAR *pcmdtReserved,
            /* [in] */ IDispatch __RPC_FAR *pdispReserved)
        {
            //return E_NOTIMPL;
            //返回 E_NOTIMPL 正常弹出系统右键菜单
            return S_OK;
            //返回S_OK 则可屏蔽系统右键菜单
        }

        virtual HRESULT STDMETHODCALLTYPE GetHostInfo(CWebBrowserUI* pWeb, 
            /* [out][in] */ DOCHOSTUIINFO __RPC_FAR *pInfo)
        {
            return E_NOTIMPL;
        }

        virtual HRESULT STDMETHODCALLTYPE ShowUI(CWebBrowserUI* pWeb, 
            /* [in] */ DWORD dwID,
            /* [in] */ IOleInPlaceActiveObject __RPC_FAR *pActiveObject,
            /* [in] */ IOleCommandTarget __RPC_FAR *pCommandTarget,
            /* [in] */ IOleInPlaceFrame __RPC_FAR *pFrame,
            /* [in] */ IOleInPlaceUIWindow __RPC_FAR *pDoc)
        {
            return S_FALSE;
        }

        virtual HRESULT STDMETHODCALLTYPE HideUI( CWebBrowserUI* pWeb)
        {
            return S_OK;
        }

        virtual HRESULT STDMETHODCALLTYPE UpdateUI( CWebBrowserUI* pWeb)
        {
            return S_OK;
        }

        virtual HRESULT STDMETHODCALLTYPE EnableModeless(CWebBrowserUI* pWeb, 
            /* [in] */ BOOL fEnable)
        {
            return S_OK;
        }

        virtual HRESULT STDMETHODCALLTYPE OnDocWindowActivate(CWebBrowserUI* pWeb, 
            /* [in] */ BOOL fActivate)
        {
            return S_OK;
        }

        virtual HRESULT STDMETHODCALLTYPE OnFrameWindowActivate(CWebBrowserUI* pWeb, 
            /* [in] */ BOOL fActivate)
        {
            return S_OK;
        }

        virtual HRESULT STDMETHODCALLTYPE ResizeBorder(CWebBrowserUI* pWeb, 
            /* [in] */ LPCRECT prcBorder,
            /* [in] */ IOleInPlaceUIWindow __RPC_FAR *pUIWindow,
            /* [in] */ BOOL fRameWindow)
        {
            return S_OK;
        }

        virtual HRESULT STDMETHODCALLTYPE TranslateAccelerator(CWebBrowserUI* pWeb, 
            /* [in] */ LPMSG lpMsg,
            /* [in] */ const GUID __RPC_FAR *pguidCmdGroup,
            /* [in] */ DWORD nCmdID)
        {
            return S_FALSE;
        }

        virtual HRESULT STDMETHODCALLTYPE GetOptionKeyPath(CWebBrowserUI* pWeb, 
            /* [out] */ LPOLESTR __RPC_FAR *pchKey,
            /* [in] */ DWORD dw)
        {
            return S_OK;
        }

        virtual HRESULT STDMETHODCALLTYPE GetDropTarget(CWebBrowserUI* pWeb, 
            /* [in] */ IDropTarget __RPC_FAR *pDropTarget,
            /* [out] */ IDropTarget __RPC_FAR *__RPC_FAR *ppDropTarget)
        {
            return E_NOTIMPL;
        }

        virtual HRESULT STDMETHODCALLTYPE GetExternal(CWebBrowserUI* pWeb, 
            /* [out] */ IDispatch __RPC_FAR *__RPC_FAR *ppDispatch)
        {
            return E_NOTIMPL;
        }

        virtual HRESULT STDMETHODCALLTYPE TranslateUrl(CWebBrowserUI* pWeb, 
            /* [in] */ DWORD dwTranslate,
            /* [in] */ OLECHAR __RPC_FAR *pchURLIn,
            /* [out] */ OLECHAR __RPC_FAR *__RPC_FAR *ppchURLOut)
        {
            return S_OK;
        }

        virtual HRESULT STDMETHODCALLTYPE FilterDataObject(CWebBrowserUI* pWeb, 
            /* [in] */ IDataObject __RPC_FAR *pDO,
            /* [out] */ IDataObject __RPC_FAR *__RPC_FAR *ppDORet)
        {
            return S_OK;
        }

        //     virtual HRESULT STDMETHODCALLTYPE GetOverrideKeyPath( 
        //         /* [annotation][out] */ 
        //         __deref_out  LPOLESTR *pchKey,
        //         /* [in] */ DWORD dw)
        //     {
        //         return E_NOTIMPL;
        //     }

        // IDownloadManager
        virtual HRESULT STDMETHODCALLTYPE Download( CWebBrowserUI* pWeb, 
            /* [in] */ IMoniker *pmk,
            /* [in] */ IBindCtx *pbc,
            /* [in] */ DWORD dwBindVerb,
            /* [in] */ LONG grfBINDF,
            /* [in] */ BINDINFO *pBindInfo,
            /* [in] */ LPCOLESTR pszHeaders,
            /* [in] */ LPCOLESTR pszRedir,
            /* [in] */ UINT uiCP)
        {
            return S_OK;
        }
    };
}
