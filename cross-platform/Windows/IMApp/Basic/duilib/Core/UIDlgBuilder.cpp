#include "StdAfx.h"

namespace DuiLib {

    CDialogBuilder::CDialogBuilder() : m_pCallback(NULL), m_pstrtype(NULL)
    {
        m_instance = NULL;
    }

    CControlUI* CDialogBuilder::Create(STRINGorID xml, LPCTSTR type, IDialogBuilderCallback* pCallback, 
        CPaintManagerUI* pManager, CControlUI* pParent)
    {
        //资源ID为0-65535，两个字节；字符串指针为4个字节
        //字符串以<开头认为是XML字符串，否则认为是XML文件
        if(HIWORD(xml.m_lpstr) != NULL && *(xml.m_lpstr) != _T('<')) {
            LPCTSTR xmlpath = CResourceManager::GetInstance()->GetXmlPath(xml.m_lpstr);
            if (xmlpath != NULL) {
                xml = xmlpath;
            }
        }

        if( HIWORD(xml.m_lpstr) != NULL ) {
            if( *(xml.m_lpstr) == _T('<') ) {
                if( !m_xml.Load(xml.m_lpstr) ) return NULL;
            }
            else {
                if( !m_xml.LoadFromFile(xml.m_lpstr) ) return NULL;
            }
        }
        else {
            HINSTANCE dll_instence = NULL;
            if (m_instance)
            {
                dll_instence = m_instance;
            }
            else
            {
                dll_instence = CPaintManagerUI::GetResourceDll();
            }
            HRSRC hResource = ::FindResource(dll_instence, xml.m_lpstr, type);
            if( hResource == NULL ) return NULL;
            HGLOBAL hGlobal = ::LoadResource(dll_instence, hResource);
            if( hGlobal == NULL ) {
                FreeResource(hResource);
                return NULL;
            }

            m_pCallback = pCallback;
            if( !m_xml.LoadFromMem((BYTE*)::LockResource(hGlobal), ::SizeofResource(dll_instence, hResource) )) return NULL;
            ::FreeResource(hResource);
            m_pstrtype = type;
        }

        return Create(pCallback, pManager, pParent);
    }

    CControlUI* CDialogBuilder::Create(IDialogBuilderCallback* pCallback, CPaintManagerUI* pManager, CControlUI* pParent)
    {
        m_pCallback = pCallback;
        CMarkupNode root = m_xml.GetRoot();
        if( !root.IsValid() ) return NULL;

        if( pManager ) {
            LPCTSTR pstrClass = NULL;
            int nAttributes = 0;
            LPCTSTR pstrName = NULL;
            LPCTSTR pstrValue = NULL;
            LPTSTR pstr = NULL;
            for( CMarkupNode node = root.GetChild() ; node.IsValid(); node = node.GetSibling() ) {
                pstrClass = node.GetName();
                if( _tcsicmp(pstrClass, _T("Image")) == 0 ) {
                    nAttributes = node.GetAttributeCount();
                    LPCTSTR pImageName = NULL;
                    LPCTSTR pImageResType = NULL;
                    bool shared = false;
                    DWORD mask = 0;
                    for( int i = 0; i < nAttributes; i++ ) {
                        pstrName = node.GetAttributeName(i);
                        pstrValue = node.GetAttributeValue(i);
                        if( _tcsicmp(pstrName, _T("name")) == 0 ) {
                            pImageName = pstrValue;
                        }
                        else if( _tcsicmp(pstrName, _T("restype")) == 0 ) {
                            pImageResType = pstrValue;
                        }
                        else if( _tcsicmp(pstrName, _T("mask")) == 0 ) {
                            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
                            mask = _tcstoul(pstrValue, &pstr, 16);
                        }
                        else if( _tcsicmp(pstrName, _T("shared")) == 0 ) {
                            shared = (_tcsicmp(pstrValue, _T("true")) == 0);
                        }
                    }
                    if( pImageName ) pManager->AddImage(pImageName, pImageResType, mask, false, shared);
                }
                else if( _tcsicmp(pstrClass, _T("Font")) == 0 ) {
                    nAttributes = node.GetAttributeCount();
                    int id = -1;
                    LPCTSTR pFontName = NULL;
                    int size = 12;
                    bool bold = false;
                    bool underline = false;
                    bool italic = false;
                    bool defaultfont = false;
                    bool shared = false;
                    for( int i = 0; i < nAttributes; i++ ) {
                        pstrName = node.GetAttributeName(i);
                        pstrValue = node.GetAttributeValue(i);
                        if( _tcsicmp(pstrName, _T("id")) == 0 ) {
                            id = _tcstol(pstrValue, &pstr, 10);
                        }
                        else if( _tcsicmp(pstrName, _T("name")) == 0 ) {
                            pFontName = pstrValue;
                        }
                        else if( _tcsicmp(pstrName, _T("size")) == 0 ) {
                            size = _tcstol(pstrValue, &pstr, 10);
                        }
                        else if( _tcsicmp(pstrName, _T("bold")) == 0 ) {
                            bold = (_tcsicmp(pstrValue, _T("true")) == 0);
                        }
                        else if( _tcsicmp(pstrName, _T("underline")) == 0 ) {
                            underline = (_tcsicmp(pstrValue, _T("true")) == 0);
                        }
                        else if( _tcsicmp(pstrName, _T("italic")) == 0 ) {
                            italic = (_tcsicmp(pstrValue, _T("true")) == 0);
                        }
                        else if( _tcsicmp(pstrName, _T("default")) == 0 ) {
                            defaultfont = (_tcsicmp(pstrValue, _T("true")) == 0);
                        }
                        else if( _tcsicmp(pstrName, _T("shared")) == 0 ) {
                            shared = (_tcsicmp(pstrValue, _T("true")) == 0);
                        }
                    }
                    if( id >= 0 ) {
                        pManager->AddFont(id, pFontName, size, bold, underline, italic, shared);
                        if( defaultfont ) pManager->SetDefaultFont(pFontName, pManager->GetDPIObj()->Scale(size), bold, underline, italic, shared);
                    }
                }
                else if( _tcsicmp(pstrClass, _T("Default")) == 0 ) {
                    nAttributes = node.GetAttributeCount();
                    LPCTSTR pControlName = NULL;
                    LPCTSTR pControlValue = NULL;
                    bool shared = false;
                    for( int i = 0; i < nAttributes; i++ ) {
                        pstrName = node.GetAttributeName(i);
                        pstrValue = node.GetAttributeValue(i);
                        if( _tcsicmp(pstrName, _T("name")) == 0 ) {
                            pControlName = pstrValue;
                        }
                        else if( _tcsicmp(pstrName, _T("value")) == 0 ) {
                            pControlValue = pstrValue;
                        }
                        else if( _tcsicmp(pstrName, _T("shared")) == 0 ) {
                            shared = (_tcsicmp(pstrValue, _T("true")) == 0);
                        }
                    }
                    if( pControlName ) {
                        pManager->AddDefaultAttributeList(pControlName, pControlValue, shared);
                    }
                }
                else if( _tcsicmp(pstrClass, _T("Style")) == 0 ) {
                    nAttributes = node.GetAttributeCount();
                    LPCTSTR pName = NULL;
                    LPCTSTR pStyle = NULL;
                    bool shared = false;
                    for( int i = 0; i < nAttributes; i++ ) {
                        pstrName = node.GetAttributeName(i);
                        pstrValue = node.GetAttributeValue(i);
                        if( _tcsicmp(pstrName, _T("name")) == 0 ) {
                            pName = pstrValue;
                        }
                        else if( _tcsicmp(pstrName, _T("value")) == 0 ) {
                            pStyle = pstrValue;
                        }
                        else if( _tcsicmp(pstrName, _T("shared")) == 0 ) {
                            shared = (_tcsicmp(pstrValue, _T("true")) == 0);
                        }
                    }
                    if( pName ) {
                        pManager->AddStyle(pName, pStyle, shared);
                    }
                }
                else if (_tcsicmp(pstrClass, _T("Import")) == 0) {
                    nAttributes = node.GetAttributeCount();
                    LPCTSTR pstrPath = NULL;
                    for (int i = 0; i < nAttributes; i++) {
                        pstrName = node.GetAttributeName(i);
                        pstrValue = node.GetAttributeValue(i);
                        if (_tcsicmp(pstrName, _T("fontfile")) == 0) {
                            pstrPath = pstrValue;
                        }
                    }
                    if (pstrPath) {
                        pManager->AddFontArray(pstrPath);
                    }
                }
            }

            pstrClass = root.GetName();
            if( _tcsicmp(pstrClass, _T("Window")) == 0 ) {
                if( pManager->GetPaintWindow() ) {
                    int nAttributes = root.GetAttributeCount();
                    for( int i = 0; i < nAttributes; i++ ) {
                        pstrName = root.GetAttributeName(i);
                        pstrValue = root.GetAttributeValue(i);
                        if( _tcsicmp(pstrName, _T("size")) == 0 ) {
                            LPTSTR pstr = NULL;
                            int cx = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
                            int cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr); 
                            pManager->SetInitSize(pManager->GetDPIObj()->Scale(cx), pManager->GetDPIObj()->Scale(cy));
                        } 
                        else if( _tcsicmp(pstrName, _T("sizebox")) == 0 ) {
                            RECT rcSizeBox = { 0 };
                            LPTSTR pstr = NULL;
                            rcSizeBox.left = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
                            rcSizeBox.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
                            rcSizeBox.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
                            rcSizeBox.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
                            pManager->SetSizeBox(rcSizeBox);
                        }
                        else if( _tcsicmp(pstrName, _T("caption")) == 0 ) {
                            RECT rcCaption = { 0 };
                            LPTSTR pstr = NULL;
                            rcCaption.left = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
                            rcCaption.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
                            rcCaption.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
                            rcCaption.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
                            pManager->SetCaptionRect(rcCaption);
                        }
                        else if( _tcsicmp(pstrName, _T("roundcorner")) == 0 ) {
                            LPTSTR pstr = NULL;
                            int cx = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
                            int cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr); 
                            pManager->SetRoundCorner(cx, cy);
                        } 
                        else if( _tcsicmp(pstrName, _T("mininfo")) == 0 ) {
                            LPTSTR pstr = NULL;
                            int cx = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
                            int cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr); 
                            pManager->SetMinInfo(cx, cy);
                        }
                        else if( _tcsicmp(pstrName, _T("maxinfo")) == 0 ) {
                            LPTSTR pstr = NULL;
                            int cx = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
                            int cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr); 
                            pManager->SetMaxInfo(cx, cy);
                        }
                        else if( _tcsicmp(pstrName, _T("showdirty")) == 0 ) {
                            pManager->SetShowUpdateRect(_tcsicmp(pstrValue, _T("true")) == 0);
                        } 
                        else if( _tcsicmp(pstrName, _T("opacity")) == 0 || _tcsicmp(pstrName, _T("alpha")) == 0 ) {
                            pManager->SetOpacity(_ttoi(pstrValue));
                        } 
                        else if( _tcscmp(pstrName, _T("layeredopacity")) == 0 ) {
                            pManager->SetLayeredOpacity(_ttoi(pstrValue));
                        } 
                        else if( _tcscmp(pstrName, _T("layered")) == 0 || _tcscmp(pstrName, _T("bktrans")) == 0) {
                            pManager->SetLayered(_tcsicmp(pstrValue, _T("true")) == 0);
                        }
                        else if( _tcscmp(pstrName, _T("layeredimage")) == 0 ) {
                            pManager->SetLayered(true);
                            pManager->SetLayeredImage(pstrValue);
                        } 
                        else if( _tcscmp(pstrName, _T("noactivate")) == 0 ) {
                            pManager->SetNoActivate(_tcsicmp(pstrValue, _T("true")) == 0);
                        }
                        else if( _tcsicmp(pstrName, _T("disabledfontcolor")) == 0 ) {
                            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
                            LPTSTR pstr = NULL;
                            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
                            pManager->SetDefaultDisabledColor(clrColor);
                        } 
                        else if( _tcsicmp(pstrName, _T("defaultfontcolor")) == 0 ) {
                            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
                            LPTSTR pstr = NULL;
                            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
                            pManager->SetDefaultFontColor(clrColor);
                        }
                        else if( _tcsicmp(pstrName, _T("linkfontcolor")) == 0 ) {
                            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
                            LPTSTR pstr = NULL;
                            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
                            pManager->SetDefaultLinkFontColor(clrColor);
                        } 
                        else if( _tcsicmp(pstrName, _T("linkhoverfontcolor")) == 0 ) {
                            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
                            LPTSTR pstr = NULL;
                            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
                            pManager->SetDefaultLinkHoverFontColor(clrColor);
                        } 
                        else if( _tcsicmp(pstrName, _T("selectedcolor")) == 0 ) {
                            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
                            LPTSTR pstr = NULL;
                            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
                            pManager->SetDefaultSelectedBkColor(clrColor);
                        } 
                        else if( _tcsicmp(pstrName, _T("shadowsize")) == 0 ) {
                            pManager->GetShadow()->SetSize(_ttoi(pstrValue));
                        }
                        else if( _tcsicmp(pstrName, _T("shadowsharpness")) == 0 ) {
                            pManager->GetShadow()->SetSharpness(_ttoi(pstrValue));
                        }
                        else if( _tcsicmp(pstrName, _T("shadowdarkness")) == 0 ) {
                            pManager->GetShadow()->SetDarkness(_ttoi(pstrValue));
                        }
                        else if( _tcsicmp(pstrName, _T("shadowposition")) == 0 ) {
                            LPTSTR pstr = NULL;
                            int cx = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
                            int cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr); 
                            pManager->GetShadow()->SetPosition(cx, cy);
                        }
                        else if( _tcsicmp(pstrName, _T("shadowcolor")) == 0 ) {
                            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
                            LPTSTR pstr = NULL;
                            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
                            pManager->GetShadow()->SetColor(clrColor);
                        }
                        else if( _tcsicmp(pstrName, _T("shadowcorner")) == 0 ) {
                            RECT rcCorner = { 0 };
                            LPTSTR pstr = NULL;
                            rcCorner.left = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
                            rcCorner.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
                            rcCorner.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
                            rcCorner.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
                            pManager->GetShadow()->SetShadowCorner(rcCorner);
                        }
                        else if( _tcsicmp(pstrName, _T("shadowimage")) == 0 ) {
                            pManager->GetShadow()->SetImage(pstrValue);
                        }
                        else if( _tcsicmp(pstrName, _T("showshadow")) == 0 ) {
                            pManager->GetShadow()->ShowShadow(_tcsicmp(pstrValue, _T("true")) == 0);
                        } 
                        else if( _tcsicmp(pstrName, _T("gdiplustext")) == 0 ) {
                            pManager->SetUseGdiplusText(_tcsicmp(pstrValue, _T("true")) == 0);
                        } 
                        else if( _tcsicmp(pstrName, _T("textrenderinghint")) == 0 ) {
                            pManager->SetGdiplusTextRenderingHint(_ttoi(pstrValue));
                        } 
                        else if( _tcsicmp(pstrName, _T("tooltiphovertime")) == 0 ) {
                            pManager->SetHoverTime(_ttoi(pstrValue));
                        } 
                    }
                }
            }
        }
        return _Parse(&root, pParent, pManager);
    }

    CMarkup* CDialogBuilder::GetMarkup()
    {
        return &m_xml;
    }

    void CDialogBuilder::GetLastErrorMessage(LPTSTR pstrMessage, SIZE_T cchMax) const
    {
        return m_xml.GetLastErrorMessage(pstrMessage, cchMax);
    }

    void CDialogBuilder::GetLastErrorLocation(LPTSTR pstrSource, SIZE_T cchMax) const
    {
        return m_xml.GetLastErrorLocation(pstrSource, cchMax);
    }

    CControlUI* CDialogBuilder::_Parse(CMarkupNode* pRoot, CControlUI* pParent, CPaintManagerUI* pManager)
    {
        IContainerUI* pContainer = NULL;
        CControlUI* pReturn = NULL;
        for( CMarkupNode node = pRoot->GetChild() ; node.IsValid(); node = node.GetSibling() ) {
            LPCTSTR pstrClass = node.GetName();
            if( _tcsicmp(pstrClass, _T("Image")) == 0 || _tcsicmp(pstrClass, _T("Font")) == 0 \
                || _tcsicmp(pstrClass, _T("Default")) == 0 || _tcsicmp(pstrClass, _T("Style")) == 0 ) continue;

            CControlUI* pControl = NULL;
            if (_tcsicmp(pstrClass, _T("Import")) == 0) continue;
            if( _tcsicmp(pstrClass, _T("Include")) == 0 ) {
                if( !node.HasAttributes() ) continue;
                int count = 1;
                LPTSTR pstr = NULL;
                TCHAR szValue[500] = { 0 };
                SIZE_T cchLen = lengthof(szValue) - 1;
                if ( node.GetAttributeValue(_T("count"), szValue, cchLen) )
                    count = _tcstol(szValue, &pstr, 10);
                cchLen = lengthof(szValue) - 1;
                if ( !node.GetAttributeValue(_T("source"), szValue, cchLen) ) continue;
                for ( int i = 0; i < count; i++ ) {
                    CDialogBuilder builder;
                    if( m_pstrtype != NULL ) { // 使用资源dll，从资源中读取
                        WORD id = (WORD)_tcstol(szValue, &pstr, 10); 
                        pControl = builder.Create((UINT)id, m_pstrtype, m_pCallback, pManager, pParent);
                    }
                    else {
                        pControl = builder.Create((LPCTSTR)szValue, (UINT)0, m_pCallback, pManager, pParent);
                    }
                }
                continue;
            }
            else {
                CDuiString strClass;
                strClass.Format(_T("C%sUI"), pstrClass);
                pControl = dynamic_cast<CControlUI*>(CControlFactory::GetInstance()->CreateControl(strClass));

                // 检查插件
                if( pControl == NULL ) {
                    CStdPtrArray* pPlugins = CPaintManagerUI::GetPlugins();
                    LPCREATECONTROL lpCreateControl = NULL;
                    for( int i = 0; i < pPlugins->GetSize(); ++i ) {
                        lpCreateControl = (LPCREATECONTROL)pPlugins->GetAt(i);
                        if( lpCreateControl != NULL ) {
                            pControl = lpCreateControl(pstrClass);
                            if( pControl != NULL ) break;
                        }
                    }
                }
                // 回掉创建
                if( pControl == NULL && m_pCallback != NULL ) {
                    pControl = m_pCallback->CreateControl(pstrClass);
                }
            }

            if( pControl == NULL ) {
#ifdef _DEBUG
                DUITRACE(_T("未知控件:%s"), pstrClass);
#else
                continue;
#endif
            }

            // Add children
            if( node.HasChildren() ) {
                _Parse(&node, pControl, pManager);
            }
            // Attach to parent
            // 因为某些属性和父窗口相关，比如selected，必须先Add到父窗口
            CTreeViewUI* pTreeView = NULL;
            if( pParent != NULL && pControl != NULL ) {
                CTreeNodeUI* pParentTreeNode = static_cast<CTreeNodeUI*>(pParent->GetInterface(_T("TreeNode")));
                CTreeNodeUI* pTreeNode = static_cast<CTreeNodeUI*>(pControl->GetInterface(_T("TreeNode")));
                pTreeView = static_cast<CTreeViewUI*>(pParent->GetInterface(_T("TreeView")));
                // TreeNode子节点
                if(pTreeNode != NULL) {
                    if(pParentTreeNode) {
                        pTreeView = pParentTreeNode->GetTreeView();
                        if(!pParentTreeNode->Add(pTreeNode)) {
                            delete pTreeNode;
                            pTreeNode = NULL;
                            continue;
                        }
                    }
                    else {
                        if(pTreeView != NULL) {
                            if(!pTreeView->Add(pTreeNode)) {
                                delete pTreeNode;
                                pTreeNode = NULL;
                                continue;
                            }
                        }
                    }
                }
                // TreeNode子控件
                else if(pParentTreeNode != NULL) {
                    pParentTreeNode->GetTreeNodeHoriznotal()->Add(pControl);
                }
                // 普通控件
                else {
                    if( pContainer == NULL ) pContainer = static_cast<IContainerUI*>(pParent->GetInterface(_T("IContainer")));
                    ASSERT(pContainer);
                    if( pContainer == NULL ) return NULL;
                    if( !pContainer->Add(pControl) ) {
                        delete pControl;
                        continue;
                    }
                }
            }
            if( pControl == NULL ) continue;

            // Init default attributes
            if( pManager ) {
                if(pTreeView != NULL) {
                    pControl->SetManager(pManager, pTreeView, true);
                }
                else {
                    pControl->SetManager(pManager, NULL, false);
                }
                LPCTSTR pDefaultAttributes = pManager->GetDefaultAttributeList(pstrClass);
                if( pDefaultAttributes ) {
                    pControl->ApplyAttributeList(pDefaultAttributes);
                }
            }
            // Process attributes
            if( node.HasAttributes() ) {
                TCHAR szValue[500] = { 0 };
                SIZE_T cchLen = lengthof(szValue) - 1;
                // Set ordinary attributes
                int nAttributes = node.GetAttributeCount();
                for( int i = 0; i < nAttributes; i++ ) {
                    pControl->SetAttribute(node.GetAttributeName(i), node.GetAttributeValue(i));
                }
            }
            if( pManager ) {
                if(pTreeView == NULL) {
                    pControl->SetManager(NULL, NULL, false);
                }
            }
            // Return first item
            if( pReturn == NULL ) pReturn = pControl;
        }
        return pReturn;
    }

} // namespace DuiLib
