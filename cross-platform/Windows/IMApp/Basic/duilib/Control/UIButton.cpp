#include "StdAfx.h"
#include "UIButton.h"

namespace DuiLib
{
    IMPLEMENT_DUICONTROL(CButtonUI)

    CButtonUI::CButtonUI()
        : m_uButtonState(0)
        , m_iHotFont(-1)
        , m_iPushedFont(-1)
        , m_iFocusedFont(-1)
        , m_dwHotTextColor(0)
        , m_dwPushedTextColor(0)
        , m_dwFocusedTextColor(0)
        , m_dwHotBkColor(0)
        , m_dwPushedBkColor(0)
        , m_dwDisabledBkColor(0)
        , m_iBindTabIndex(-1)
        , m_nStateCount(0)
    {
        m_uTextStyle = DT_SINGLELINE | DT_VCENTER | DT_CENTER;
    }

    LPCTSTR CButtonUI::GetClass() const
    {
        return _T("ButtonUI");
    }

    LPVOID CButtonUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_BUTTON) == 0 ) return static_cast<CButtonUI*>(this);
        return CLabelUI::GetInterface(pstrName);
    }

    UINT CButtonUI::GetControlFlags() const
    {
        return (IsKeyboardEnabled() ? UIFLAG_TABSTOP : 0) | (IsEnabled() ? UIFLAG_SETCURSOR : 0);
    }

    void CButtonUI::DoEvent(TEventUI& event)
    {
        if( !IsMouseEnabled() && event.Type > UIEVENT__MOUSEBEGIN && event.Type < UIEVENT__MOUSEEND ) {
            if( m_pParent != NULL ) m_pParent->DoEvent(event);
            else CLabelUI::DoEvent(event);
            return;
        }

        if( event.Type == UIEVENT_SETFOCUS ) 
        {
            Invalidate();
        }
        if( event.Type == UIEVENT_KILLFOCUS ) 
        {
            Invalidate();
        }
        if( event.Type == UIEVENT_KEYDOWN )
        {
            if (IsKeyboardEnabled()) {
                if( event.chKey == VK_SPACE || event.chKey == VK_RETURN ) {
                    Activate();
                    return;
                }
            }
        }        
        if( event.Type == UIEVENT_BUTTONDOWN || event.Type == UIEVENT_DBLCLICK)
        {
            if( ::PtInRect(&m_rcItem, event.ptMouse) && IsEnabled() ) {
                m_uButtonState |= UISTATE_PUSHED | UISTATE_CAPTURED;
                Invalidate();
            }
            return;
        }    
        if( event.Type == UIEVENT_MOUSEMOVE )
        {
            if( (m_uButtonState & UISTATE_CAPTURED) != 0 ) {
                if( ::PtInRect(&m_rcItem, event.ptMouse) ) m_uButtonState |= UISTATE_PUSHED;
                else m_uButtonState &= ~UISTATE_PUSHED;
                Invalidate();
            }
            return;
        }
        if( event.Type == UIEVENT_BUTTONUP )
        {
            if( (m_uButtonState & UISTATE_CAPTURED) != 0 ) {
                m_uButtonState &= ~(UISTATE_PUSHED | UISTATE_CAPTURED);
                Invalidate();
                if( ::PtInRect(&m_rcItem, event.ptMouse) ) Activate();                
            }
            return;
        }
        if( event.Type == UIEVENT_CONTEXTMENU )
        {
            if( IsContextMenuUsed() ) {
                m_pManager->SendNotify(this, DUI_MSGTYPE_MENU, event.wParam, event.lParam);
            }
            return;
        }
        if( event.Type == UIEVENT_MOUSEENTER )
        {
            if( IsEnabled() ) {
                m_uButtonState |= UISTATE_HOT;
                Invalidate();
            }
        }
        if( event.Type == UIEVENT_MOUSELEAVE )
        {
            if( IsEnabled() ) {
                m_uButtonState &= ~UISTATE_HOT;
                Invalidate();
            }
        }
        CLabelUI::DoEvent(event);
    }

    bool CButtonUI::Activate()
    {
        if( !CControlUI::Activate() ) return false;
        if( m_pManager != NULL )
        {
            m_pManager->SendNotify(this, DUI_MSGTYPE_CLICK);
            BindTriggerTabSel();
        }
        return true;
    }

    void CButtonUI::SetEnabled(bool bEnable)
    {
        CControlUI::SetEnabled(bEnable);
        if( !IsEnabled() ) {
            m_uButtonState = 0;
        }
    }


    void CButtonUI::SetHotFont(int index)
    {
        m_iHotFont = index;
        Invalidate();
    }

    int CButtonUI::GetHotFont() const
    {
        return m_iHotFont;
    }

    void CButtonUI::SetPushedFont(int index)
    {
        m_iPushedFont = index;
        Invalidate();
    }

    int CButtonUI::GetPushedFont() const
    {
        return m_iPushedFont;
    }

    void CButtonUI::SetFocusedFont(int index)
    {
        m_iFocusedFont = index;
        Invalidate();
    }

    int CButtonUI::GetFocusedFont() const
    {
        return m_iFocusedFont;
    }

    void CButtonUI::SetHotBkColor( DWORD dwColor )
    {
        m_dwHotBkColor = dwColor;
        Invalidate();
    }

    DWORD CButtonUI::GetHotBkColor() const
    {
        return m_dwHotBkColor;
    }

    void CButtonUI::SetPushedBkColor( DWORD dwColor )
    {
        m_dwPushedBkColor = dwColor;
        Invalidate();
    }

    DWORD CButtonUI::GetPushedBkColor() const
    {
        return m_dwPushedBkColor;
    }

    void CButtonUI::SetDisabledBkColor( DWORD dwColor )
    {
        m_dwDisabledBkColor = dwColor;
        Invalidate();
    }

    DWORD CButtonUI::GetDisabledBkColor() const
    {
        return m_dwDisabledBkColor;
    }

    void CButtonUI::SetHotTextColor(DWORD dwColor)
    {
        m_dwHotTextColor = dwColor;
    }

    DWORD CButtonUI::GetHotTextColor() const
    {
        return m_dwHotTextColor;
    }

    void CButtonUI::SetPushedTextColor(DWORD dwColor)
    {
        m_dwPushedTextColor = dwColor;
    }

    DWORD CButtonUI::GetPushedTextColor() const
    {
        return m_dwPushedTextColor;
    }

    void CButtonUI::SetFocusedTextColor(DWORD dwColor)
    {
        m_dwFocusedTextColor = dwColor;
    }

    DWORD CButtonUI::GetFocusedTextColor() const
    {
        return m_dwFocusedTextColor;
    }

    LPCTSTR CButtonUI::GetNormalImage()
    {
        return m_sNormalImage;
    }

    void CButtonUI::SetNormalImage(LPCTSTR pStrImage)
    {
        m_sNormalImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CButtonUI::GetHotImage()
    {
        return m_sHotImage;
    }

    void CButtonUI::SetHotImage(LPCTSTR pStrImage)
    {
        m_sHotImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CButtonUI::GetPushedImage()
    {
        return m_sPushedImage;
    }

    void CButtonUI::SetPushedImage(LPCTSTR pStrImage)
    {
        m_sPushedImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CButtonUI::GetFocusedImage()
    {
        return m_sFocusedImage;
    }

    void CButtonUI::SetFocusedImage(LPCTSTR pStrImage)
    {
        m_sFocusedImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CButtonUI::GetDisabledImage()
    {
        return m_sDisabledImage;
    }

    void CButtonUI::SetDisabledImage(LPCTSTR pStrImage)
    {
        m_sDisabledImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CButtonUI::GetHotForeImage()
    {
        return m_sHotForeImage;
    }

    void CButtonUI::SetHotForeImage( LPCTSTR pStrImage )
    {
        m_sHotForeImage = pStrImage;
        Invalidate();
    }

    void CButtonUI::SetStateCount(int nCount)
    {
        m_nStateCount = nCount;
        Invalidate();
    }

    int CButtonUI::GetStateCount() const
    {
        return m_nStateCount;
    }

    LPCTSTR CButtonUI::GetStateImage()
    {
        return m_sStateImage;
    }

    void CButtonUI::SetStateImage( LPCTSTR pStrImage )
    {
        m_sNormalImage.Empty();
        m_sStateImage = pStrImage;
        Invalidate();
    }

    void CButtonUI::BindTabIndex(int _BindTabIndex )
    {
        if( _BindTabIndex >= 0)
            m_iBindTabIndex    = _BindTabIndex;
    }

    void CButtonUI::BindTabLayoutName( LPCTSTR _TabLayoutName )
    {
        if(_TabLayoutName)
            m_sBindTabLayoutName = _TabLayoutName;
    }

    void CButtonUI::BindTriggerTabSel( int _SetSelectIndex /*= -1*/ )
    {
        LPCTSTR pstrName = GetBindTabLayoutName();
        if(pstrName == NULL || (GetBindTabLayoutIndex() < 0 && _SetSelectIndex < 0))
            return;

        CTabLayoutUI* pTabLayout = static_cast<CTabLayoutUI*>(GetManager()->FindControl(pstrName));
        if(!pTabLayout) return;
        pTabLayout->SelectItem(_SetSelectIndex >=0?_SetSelectIndex:GetBindTabLayoutIndex());
    }

    void CButtonUI::RemoveBindTabIndex()
    {
        m_iBindTabIndex    = -1;
        m_sBindTabLayoutName.Empty();
    }

    int CButtonUI::GetBindTabLayoutIndex()
    {
        return m_iBindTabIndex;
    }

    LPCTSTR CButtonUI::GetBindTabLayoutName()
    {
        return m_sBindTabLayoutName;
    }

    SIZE CButtonUI::EstimateSize(SIZE szAvailable)
    {
        SIZE size = CLabelUI::EstimateSize(szAvailable);
        //size.cx = size.cx + 0x6;
        return size;
    }

    void CButtonUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if( _tcsicmp(pstrName, _T("normalimage")) == 0 ) SetNormalImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("hotimage")) == 0 ) SetHotImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("pushedimage")) == 0 ) SetPushedImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("focusedimage")) == 0 ) SetFocusedImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("disabledimage")) == 0 ) SetDisabledImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("hotforeimage")) == 0 ) SetHotForeImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("stateimage")) == 0 ) SetStateImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("statecount")) == 0 ) SetStateCount(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("bindtabindex")) == 0 ) BindTabIndex(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("bindtablayoutname")) == 0 ) BindTabLayoutName(pstrValue);
        else if( _tcsicmp(pstrName, _T("hotbkcolor")) == 0 )
        {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetHotBkColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("pushedbkcolor")) == 0 )
        {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetPushedBkColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("disabledbkcolor")) == 0 )
        {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetDisabledBkColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("hottextcolor")) == 0 )
        {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetHotTextColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("pushedtextcolor")) == 0 )
        {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetPushedTextColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("focusedtextcolor")) == 0 )
        {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetFocusedTextColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("hotfont")) == 0 ) SetHotFont(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("pushedfont")) == 0 ) SetPushedFont(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("focuedfont")) == 0 ) SetFocusedFont(_ttoi(pstrValue));

        else CLabelUI::SetAttribute(pstrName, pstrValue);
    }

    void CButtonUI::PaintText(HDC hDC)
    {
        if( IsFocused() ) m_uButtonState |= UISTATE_FOCUSED;
        else m_uButtonState &= ~ UISTATE_FOCUSED;
        if( !IsEnabled() ) m_uButtonState |= UISTATE_DISABLED;
        else m_uButtonState &= ~ UISTATE_DISABLED;

        if( m_dwTextColor == 0 ) m_dwTextColor = m_pManager->GetDefaultFontColor();
        if( m_dwDisabledTextColor == 0 ) m_dwDisabledTextColor = m_pManager->GetDefaultDisabledColor();

        CDuiString sText = GetText();
        if( sText.IsEmpty() ) return;

        RECT m_rcTextPadding = CButtonUI::m_rcTextPadding;
        GetManager()->GetDPIObj()->Scale(&m_rcTextPadding);
        int nLinks = 0;
        RECT rc = m_rcItem;
        rc.left += m_rcTextPadding.left;
        rc.right -= m_rcTextPadding.right;
        rc.top += m_rcTextPadding.top;
        rc.bottom -= m_rcTextPadding.bottom;

        DWORD clrColor = IsEnabled()?m_dwTextColor:m_dwDisabledTextColor;

        if( ((m_uButtonState & UISTATE_PUSHED) != 0) && (GetPushedTextColor() != 0) )
            clrColor = GetPushedTextColor();
        else if( ((m_uButtonState & UISTATE_HOT) != 0) && (GetHotTextColor() != 0) )
            clrColor = GetHotTextColor();
        else if( ((m_uButtonState & UISTATE_FOCUSED) != 0) && (GetFocusedTextColor() != 0) )
            clrColor = GetFocusedTextColor();

        int iFont = GetFont();
        if( ((m_uButtonState & UISTATE_PUSHED) != 0) && (GetPushedFont() != -1) )
            iFont = GetPushedFont();
        else if( ((m_uButtonState & UISTATE_HOT) != 0) && (GetHotFont() != -1) )
            iFont = GetHotFont();
        else if( ((m_uButtonState & UISTATE_FOCUSED) != 0) && (GetFocusedFont() != -1) )
            iFont = GetFocusedFont();

        if( m_bShowHtml )
            CRenderEngine::DrawHtmlText(hDC, m_pManager, rc, sText, clrColor, \
            NULL, NULL, nLinks, iFont, m_uTextStyle);
        else
            CRenderEngine::DrawText(hDC, m_pManager, rc, sText, clrColor, \
            iFont, m_uTextStyle);
    }

    void CButtonUI::PaintBkColor(HDC hDC)
    {
        if( (m_uButtonState & UISTATE_DISABLED) != 0 ) {
            if(m_dwDisabledBkColor != 0) {
                CRenderEngine::DrawColor(hDC, m_rcPaint, GetAdjustColor(m_dwDisabledBkColor));
                return;
            }
        }
        else if( (m_uButtonState & UISTATE_PUSHED) != 0 ) {
            if(m_dwPushedBkColor != 0) {
                CRenderEngine::DrawColor(hDC, m_rcPaint, GetAdjustColor(m_dwPushedBkColor));
                return;
            }
        }
        else if( (m_uButtonState & UISTATE_HOT) != 0 ) {
            if(m_dwHotBkColor != 0) {
                CRenderEngine::DrawColor(hDC, m_rcPaint, GetAdjustColor(m_dwHotBkColor));
                return;
            }
        }

        return CControlUI::PaintBkColor(hDC);
    }

    void CButtonUI::PaintStatusImage(HDC hDC)
    {
        if(!m_sStateImage.IsEmpty() && m_nStateCount > 0)
        {
            TDrawInfo info;
            info.Parse(m_sStateImage, _T(""), m_pManager);
            const TImageInfo* pImage = m_pManager->GetImageEx(info.sImageName, info.sResType, info.dwMask, info.bHSL);
            if(m_sNormalImage.IsEmpty() && pImage != NULL)
            {
                SIZE szImage = {pImage->nX, pImage->nY};
                SIZE szStatus = {pImage->nX / m_nStateCount, pImage->nY};
                if( szImage.cx > 0 && szImage.cy > 0 )
                {
                    RECT rcSrc = {0, 0, szImage.cx, szImage.cy};
                    if(m_nStateCount > 0) {
                        int iLeft = rcSrc.left + 0 * szStatus.cx;
                        int iRight = iLeft + szStatus.cx;
                        int iTop = rcSrc.top;
                        int iBottom = iTop + szStatus.cy;
                        m_sNormalImage.Format(_T("res='%s' restype='%s' dest='%d,%d,%d,%d' source='%d,%d,%d,%d'"), info.sImageName.GetData(), info.sResType.GetData(), info.rcDest.left, info.rcDest.top, info.rcDest.right, info.rcDest.bottom, iLeft, iTop, iRight, iBottom);
                    }
                    if(m_nStateCount > 1) {
                        int iLeft = rcSrc.left + 1 * szStatus.cx;
                        int iRight = iLeft + szStatus.cx;
                        int iTop = rcSrc.top;
                        int iBottom = iTop + szStatus.cy;
                        m_sHotImage.Format(_T("res='%s' restype='%s' dest='%d,%d,%d,%d' source='%d,%d,%d,%d'"), info.sImageName.GetData(), info.sResType.GetData(), info.rcDest.left, info.rcDest.top, info.rcDest.right, info.rcDest.bottom, iLeft, iTop, iRight, iBottom);
                        m_sPushedImage.Format(_T("res='%s' restype='%s' dest='%d,%d,%d,%d' source='%d,%d,%d,%d'"), info.sImageName.GetData(), info.sResType.GetData(), info.rcDest.left, info.rcDest.top, info.rcDest.right, info.rcDest.bottom, iLeft, iTop, iRight, iBottom);
                    }
                    if(m_nStateCount > 2) {
                        int iLeft = rcSrc.left + 2 * szStatus.cx;
                        int iRight = iLeft + szStatus.cx;
                        int iTop = rcSrc.top;
                        int iBottom = iTop + szStatus.cy;
                        m_sPushedImage.Format(_T("res='%s' restype='%s' dest='%d,%d,%d,%d' source='%d,%d,%d,%d'"), info.sImageName.GetData(), info.sResType.GetData(), info.rcDest.left, info.rcDest.top, info.rcDest.right, info.rcDest.bottom, iLeft, iTop, iRight, iBottom);
                    }
                    if(m_nStateCount > 3) {
                        int iLeft = rcSrc.left + 3 * szStatus.cx;
                        int iRight = iLeft + szStatus.cx;
                        int iTop = rcSrc.top;
                        int iBottom = iTop + szStatus.cy;
                        m_sDisabledImage.Format(_T("res='%s' restype='%s' dest='%d,%d,%d,%d' source='%d,%d,%d,%d'"), info.sImageName.GetData(), info.sResType.GetData(), info.rcDest.left, info.rcDest.top, info.rcDest.right, info.rcDest.bottom, iLeft, iTop, iRight, iBottom);
                    }
                }
            }
        }

        if( IsFocused() ) m_uButtonState |= UISTATE_FOCUSED;
        else m_uButtonState &= ~ UISTATE_FOCUSED;
        if( !IsEnabled() ) m_uButtonState |= UISTATE_DISABLED;
        else m_uButtonState &= ~ UISTATE_DISABLED;
        if(!::IsWindowEnabled(m_pManager->GetPaintWindow())) {
            m_uButtonState &= UISTATE_DISABLED;
        }
        if( (m_uButtonState & UISTATE_DISABLED) != 0 ) {
            if( !m_sDisabledImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sDisabledImage) ) {}
                else return;
            }
        }
        else if( (m_uButtonState & UISTATE_PUSHED) != 0 ) {
            if( !m_sPushedImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sPushedImage) ) {}
                else return;
            }
        }
        else if( (m_uButtonState & UISTATE_HOT) != 0 ) {
            if( !m_sHotImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sHotImage) ) {}
                else return;
            }
        }
        else if( (m_uButtonState & UISTATE_FOCUSED) != 0 ) {
            if( !m_sFocusedImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sFocusedImage) ) {}
                else return;
            }
        }

        if( !m_sNormalImage.IsEmpty() ) {
            if( !DrawImage(hDC, (LPCTSTR)m_sNormalImage) ) {}
        }
    }

    void CButtonUI::PaintForeImage(HDC hDC)
    {
        if( (m_uButtonState & UISTATE_PUSHED) != 0 ) {
            if( !m_sPushedForeImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sPushedForeImage) ) {}
                else return;
            }
        }
        else if( (m_uButtonState & UISTATE_HOT) != 0 ) {
            if( !m_sHotForeImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sHotForeImage) ) {}
                else return;
            }
        }
        if(!m_sForeImage.IsEmpty() ) {
            if( !DrawImage(hDC, (LPCTSTR)m_sForeImage) ) {}
        }
    }
}