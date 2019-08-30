#include "StdAfx.h"
#include "UIResourceManager.h"

namespace DuiLib {

    CResourceManager::CResourceManager(void)
    {
        m_pQuerypInterface = NULL;

    }

    CResourceManager::~CResourceManager(void)
    {
        ResetResourceMap();
    }

    BOOL CResourceManager::LoadResource(STRINGorID xml, LPCTSTR type)
    {
        if( HIWORD(xml.m_lpstr) != NULL ) 
        {
            if( *(xml.m_lpstr) == _T('<') ) 
            {
                if( !m_xml.Load(xml.m_lpstr) ) return NULL;
            }
            else 
            {
                if( !m_xml.LoadFromFile(xml.m_lpstr) ) return NULL;
            }
        }
        else
        {
            HRSRC hResource = ::FindResource(CPaintManagerUI::GetResourceDll(), xml.m_lpstr, type);
            if( hResource == NULL ) return NULL;
            HGLOBAL hGlobal = ::LoadResource(CPaintManagerUI::GetResourceDll(), hResource);
            if( hGlobal == NULL ) 
            {
                FreeResource(hResource);
                return NULL;
            }

            if( !m_xml.LoadFromMem((BYTE*)::LockResource(hGlobal), ::SizeofResource(CPaintManagerUI::GetResourceDll(), hResource) )) {
                return NULL;
            }
            ::FreeResource(hResource);
        }

        return LoadResource(m_xml.GetRoot());
    }

    BOOL CResourceManager::LoadResource(CMarkupNode Root)
    {
        if( !Root.IsValid() ) return FALSE;

        LPCTSTR pstrClass = NULL;
        int nAttributes = 0;
        LPCTSTR pstrName = NULL;
        LPCTSTR pstrValue = NULL;
        LPTSTR pstr = NULL;

        //加载图片资源
        LPCTSTR pstrId = NULL;
        LPCTSTR pstrPath = NULL;
        for( CMarkupNode node = Root.GetChild() ; node.IsValid(); node = node.GetSibling() ) 
        {
            pstrClass = node.GetName();
            CMarkupNode ChildNode = node.GetChild();
            if(ChildNode.IsValid()) LoadResource(node);
            else if ((_tcsicmp(pstrClass,_T("Image")) == 0) && node.HasAttributes())
            {
                //加载图片资源
                nAttributes = node.GetAttributeCount();
                for( int i = 0; i < nAttributes; i++ ) 
                {
                    pstrName = node.GetAttributeName(i);
                    pstrValue = node.GetAttributeValue(i);

                    if( _tcsicmp(pstrName, _T("id")) == 0 ) 
                    {
                        pstrId = pstrValue;
                    }
                    else if( _tcsicmp(pstrName, _T("path")) == 0 ) 
                    {
                        pstrPath = pstrValue;
                    }
                }
                if( pstrId == NULL ||  pstrPath == NULL) continue;
                CDuiString * pstrFind = static_cast<CDuiString *>(m_mImageHashMap.Find(pstrId));
                if(pstrFind != NULL) continue;
                m_mImageHashMap.Insert(pstrId, (LPVOID)new CDuiString(pstrPath));
            }
            else if( _tcsicmp(pstrClass,_T("Xml")) == 0 && node.HasAttributes()) {
                //加载XML配置文件
                nAttributes = node.GetAttributeCount();
                for( int i = 0; i < nAttributes; i++ ) 
                {
                    pstrName = node.GetAttributeName(i);
                    pstrValue = node.GetAttributeValue(i);

                    if( _tcsicmp(pstrName, _T("id")) == 0 ) 
                    {
                        pstrId = pstrValue;
                    }
                    else if( _tcsicmp(pstrName, _T("path")) == 0 ) 
                    {
                        pstrPath = pstrValue;
                    }
                }
                if( pstrId == NULL ||  pstrPath == NULL) continue;
                CDuiString * pstrFind = static_cast<CDuiString *>(m_mXmlHashMap.Find(pstrId));
                if(pstrFind != NULL) continue;
                m_mXmlHashMap.Insert(pstrId, (LPVOID)new CDuiString(pstrPath));
            }
            else continue;
        }
        return TRUE;
    }

    LPCTSTR CResourceManager::GetImagePath(LPCTSTR lpstrId)
    {
        CDuiString * lpStr = static_cast<CDuiString *>(m_mImageHashMap.Find(lpstrId));
        return lpStr == NULL? NULL:lpStr->GetData();
    }

    LPCTSTR CResourceManager::GetXmlPath(LPCTSTR lpstrId)
    {
        CDuiString * lpStr = static_cast<CDuiString *>(m_mXmlHashMap.Find(lpstrId));
        return lpStr == NULL? NULL:lpStr->GetData();
    }

    void CResourceManager::ResetResourceMap()
    {
        CDuiString* lpStr;
        for( int i = 0; i< m_mImageHashMap.GetSize(); i++ )
        {
            if(LPCTSTR key = m_mImageHashMap.GetAt(i))
            {
                lpStr = static_cast<CDuiString *>(m_mImageHashMap.Find(key));
                delete lpStr;
                lpStr = NULL;
            }
        }
        for( int i = 0; i< m_mXmlHashMap.GetSize(); i++ )
        {
            if(LPCTSTR key = m_mXmlHashMap.GetAt(i))
            {
                lpStr = static_cast<CDuiString *>(m_mXmlHashMap.Find(key));
                delete lpStr;
                lpStr = NULL;
            }
        }
        for( int i = 0; i< m_mTextResourceHashMap.GetSize(); i++ )
        {
            if(LPCTSTR key = m_mTextResourceHashMap.GetAt(i))
            {
                lpStr = static_cast<CDuiString *>(m_mTextResourceHashMap.Find(key));
                delete lpStr;
                lpStr = NULL;
            }
        }
    }

    BOOL CResourceManager::LoadLanguage(LPCTSTR pstrXml)
    {
        CMarkup xml;
        if( *(pstrXml) == _T('<') ) {
            if( !xml.Load(pstrXml) ) return FALSE;
        }
        else {
            if( !xml.LoadFromFile(pstrXml) ) return FALSE;
        }
        CMarkupNode Root = xml.GetRoot();
        if( !Root.IsValid() ) return FALSE;

        LPCTSTR pstrClass = NULL;
        int nAttributes = 0;
        LPCTSTR pstrName = NULL;
        LPCTSTR pstrValue = NULL;
        LPTSTR pstr = NULL;

        //加载图片资源
        LPCTSTR pstrId = NULL;
        LPCTSTR pstrText = NULL;
        for( CMarkupNode node = Root.GetChild() ; node.IsValid(); node = node.GetSibling() ) 
        {
            pstrClass = node.GetName();
            if ((_tcsicmp(pstrClass,_T("Text")) == 0) && node.HasAttributes())
            {
                //加载图片资源
                nAttributes = node.GetAttributeCount();
                for( int i = 0; i < nAttributes; i++ ) 
                {
                    pstrName = node.GetAttributeName(i);
                    pstrValue = node.GetAttributeValue(i);

                    if( _tcsicmp(pstrName, _T("id")) == 0 ) 
                    {
                        pstrId = pstrValue;
                    }
                    else if( _tcsicmp(pstrName, _T("value")) == 0 ) 
                    {
                        pstrText = pstrValue;
                    }
                }
                if( pstrId == NULL ||  pstrText == NULL) continue;

                CDuiString *lpstrFind = static_cast<CDuiString *>(m_mTextResourceHashMap.Find(pstrId));
                if(lpstrFind != NULL) {
                    lpstrFind->Assign(pstrText);
                }
                else {
                    m_mTextResourceHashMap.Insert(pstrId, (LPVOID)new CDuiString(pstrText));
                }
            }
            else continue;
        }

        return TRUE;
    }

    CDuiString CResourceManager::GetText(LPCTSTR lpstrId, LPCTSTR lpstrType)
    {
        if(lpstrId == NULL) return _T("");

        CDuiString *lpstrFind = static_cast<CDuiString *>(m_mTextResourceHashMap.Find(lpstrId));
        if (lpstrFind == NULL && m_pQuerypInterface)
        {
            lpstrFind = new CDuiString(m_pQuerypInterface->QueryControlText(lpstrId, lpstrType));
            m_mTextResourceHashMap.Insert(lpstrId, (LPVOID)lpstrFind);
        }
        return lpstrFind == NULL ? lpstrId : *lpstrFind;
    }

    void CResourceManager::ReloadText()
    {
        if(m_pQuerypInterface == NULL) return;
        //重载文字描述
        LPCTSTR lpstrId = NULL;
        LPCTSTR lpstrText;
        for( int i = 0; i < m_mTextResourceHashMap.GetSize(); i++ )
        {
            lpstrId = m_mTextResourceHashMap.GetAt(i);
            if (lpstrId == NULL) continue;
            lpstrText = m_pQuerypInterface->QueryControlText(lpstrId, NULL);
            if(lpstrText != NULL) {
                CDuiString * lpStr = static_cast<CDuiString *>(m_mTextResourceHashMap.Find(lpstrId));
                lpStr->Assign(lpstrText);
            }
        }
    }
    void CResourceManager::ResetTextMap()
    {
        CDuiString * lpStr;
        for( int i = 0; i< m_mTextResourceHashMap.GetSize(); i++ )
        {
            if(LPCTSTR key = m_mTextResourceHashMap.GetAt(i))
            {
                lpStr = static_cast<CDuiString *>(m_mTextResourceHashMap.Find(key));
                delete lpStr;
            }
        }
    }


} // namespace DuiLib