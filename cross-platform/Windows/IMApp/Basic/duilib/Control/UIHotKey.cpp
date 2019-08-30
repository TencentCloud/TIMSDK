#include "stdafx.h"
#include "UIHotKey.h"
namespace DuiLib{
    CHotKeyWnd::CHotKeyWnd(void) : m_pOwner(NULL), m_hBkBrush(NULL), m_bInit(false)
    {
    }
    void CHotKeyWnd::Init(CHotKeyUI * pOwner)
    {
        m_pOwner = pOwner;
        do  {
            if (NULL == m_pOwner) {
                break;
            }
            RECT rcPos = CalPos();
            UINT uStyle = WS_CHILD | ES_AUTOHSCROLL;
            HWND hWnd = Create(m_pOwner->GetManager()->GetPaintWindow(), NULL, uStyle, 0, rcPos);
            if (!IsWindow(hWnd)) {
                break;
            }
            SetWindowFont(m_hWnd, m_pOwner->GetManager()->GetFontInfo(m_pOwner->GetFont())->hFont, TRUE);
            SetHotKey(m_pOwner->m_wVirtualKeyCode, m_pOwner->m_wModifiers);
            m_pOwner->m_sText = GetHotKeyName();
            ::EnableWindow(m_hWnd, m_pOwner->IsEnabled() == true);
            ::ShowWindow(m_hWnd, SW_SHOWNOACTIVATE);
            ::SetFocus(m_hWnd);
            m_bInit = true;   
        } while (0); 
    }


    RECT CHotKeyWnd::CalPos()
    {
        CDuiRect rcPos = m_pOwner->GetPos();
        RECT rcInset = m_pOwner->GetTextPadding();
        rcPos.left += rcInset.left;
        rcPos.top += rcInset.top;
        rcPos.right -= rcInset.right;
        rcPos.bottom -= rcInset.bottom;
        LONG lHeight = m_pOwner->GetManager()->GetFontInfo(m_pOwner->GetFont())->tm.tmHeight;
        if( lHeight < rcPos.GetHeight() ) {
            rcPos.top += (rcPos.GetHeight() - lHeight) / 2;
            rcPos.bottom = rcPos.top + lHeight;
        }
        return rcPos;
    }


    LPCTSTR CHotKeyWnd::GetWindowClassName() const
    {
        return _T("HotKeyClass");
    }

    void CHotKeyWnd::OnFinalMessage(HWND /*hWnd*/)
    {
        // Clear reference and die
        if( m_hBkBrush != NULL ) ::DeleteObject(m_hBkBrush);
        m_pOwner->m_pWindow = NULL;
        delete this;
    }

    LRESULT CHotKeyWnd::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
    {
        LRESULT lRes = 0;
        BOOL bHandled = TRUE;
        if( uMsg == WM_KILLFOCUS ) lRes = OnKillFocus(uMsg, wParam, lParam, bHandled);
        else if( uMsg == OCM_COMMAND ) {
            if( GET_WM_COMMAND_CMD(wParam, lParam) == EN_CHANGE ) lRes = OnEditChanged(uMsg, wParam, lParam, bHandled);
            else if( GET_WM_COMMAND_CMD(wParam, lParam) == EN_UPDATE ) {
                RECT rcClient;
                ::GetClientRect(m_hWnd, &rcClient);
                ::InvalidateRect(m_hWnd, &rcClient, FALSE);
            }
        }
        else if( uMsg == WM_KEYDOWN && TCHAR(wParam) == VK_RETURN ) {
            m_pOwner->GetManager()->SendNotify(m_pOwner, _T("return"));
        }
        else if ( (uMsg == WM_NCACTIVATE) || (uMsg == WM_NCACTIVATE) || (uMsg == WM_NCCALCSIZE) )
        {
            return 0;
        }
        else if (uMsg == WM_PAINT)
        {
            PAINTSTRUCT ps = { 0 };
            HDC hDC = ::BeginPaint(m_hWnd, &ps);
            DWORD dwTextColor = m_pOwner->GetTextColor();
            DWORD dwBkColor = m_pOwner->GetNativeBkColor();
            CDuiString strText = GetHotKeyName();
            ::RECT rect;
            ::GetClientRect(m_hWnd, &rect);
            ::SetBkMode(hDC, TRANSPARENT);
            ::SetTextColor(hDC, RGB(GetBValue(dwTextColor), GetGValue(dwTextColor), GetRValue(dwTextColor)));
            HBRUSH hBrush =  CreateSolidBrush( RGB(GetBValue(dwBkColor), GetGValue(dwBkColor), GetRValue(dwBkColor)) );
            ::FillRect(hDC, &rect, hBrush);
            ::DeleteObject(hBrush);
            HFONT hOldFont = (HFONT)SelectObject(hDC, GetWindowFont(m_hWnd));
            ::SIZE size = { 0 };
            ::GetTextExtentPoint32(hDC, strText.GetData(), strText.GetLength(), &size) ;
            ::DrawText(hDC, strText.GetData(), -1, &rect, DT_LEFT|DT_SINGLELINE|DT_END_ELLIPSIS|DT_NOPREFIX);
            ::SelectObject(hDC, hOldFont);
            ::SetCaretPos(size.cx, 0);
            ::EndPaint(m_hWnd, &ps);
            bHandled = TRUE;
        }
        else bHandled = FALSE;
        if( !bHandled ) return CWindowWnd::HandleMessage(uMsg, wParam, lParam);
        return lRes;
    }


    LPCTSTR CHotKeyWnd::GetSuperClassName() const
    {
        return HOTKEY_CLASS;
    }


    LRESULT CHotKeyWnd::OnKillFocus(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        LRESULT lRes = ::DefWindowProc(m_hWnd, uMsg, wParam, lParam);
        ::SendMessage(m_hWnd, WM_CLOSE, 0, 0);
        return lRes;
    }


    LRESULT CHotKeyWnd::OnEditChanged(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        if( !m_bInit ) return 0;
        if( m_pOwner == NULL ) return 0;
        GetHotKey(m_pOwner->m_wVirtualKeyCode, m_pOwner->m_wModifiers);
        if (m_pOwner->m_wVirtualKeyCode == 0) {
            m_pOwner->m_sText = _T("нч");
            m_pOwner->m_wModifiers = 0;
        }
        else {
            m_pOwner->m_sText = GetHotKeyName();
        }
        m_pOwner->GetManager()->SendNotify(m_pOwner, _T("textchanged"));
        return 0;
    }


    void CHotKeyWnd::SetHotKey(WORD wVirtualKeyCode, WORD wModifiers)
    {
        ASSERT(::IsWindow(m_hWnd));  
        ::SendMessage(m_hWnd, HKM_SETHOTKEY, MAKEWORD(wVirtualKeyCode, wModifiers), 0L);
    }

    DWORD CHotKeyWnd::GetHotKey() const
    {
        ASSERT(::IsWindow(m_hWnd));
        return (::SendMessage(m_hWnd, HKM_GETHOTKEY, 0, 0L));
    }

    void CHotKeyWnd::GetHotKey(WORD &wVirtualKeyCode, WORD &wModifiers) const
    {
        DWORD dw = GetHotKey();
        wVirtualKeyCode = LOBYTE(LOWORD(dw));
        wModifiers = HIBYTE(LOWORD(dw));
    }

    void CHotKeyWnd::SetRules(WORD wInvalidComb, WORD wModifiers)
    { 
        ASSERT(::IsWindow(m_hWnd));  
        ::SendMessage(m_hWnd, HKM_SETRULES, wInvalidComb, MAKELPARAM(wModifiers, 0)); 
    }


    CDuiString CHotKeyWnd::GetKeyName(UINT vk, BOOL fExtended)
    {
        UINT nScanCode = ::MapVirtualKeyEx( vk, 0, ::GetKeyboardLayout( 0 ) );
        switch( vk )
        {
            // Keys which are "extended" (except for Return which is Numeric Enter as extended)
        case VK_INSERT:
        case VK_DELETE:
        case VK_HOME:
        case VK_END:
        case VK_NEXT: // Page down
        case VK_PRIOR: // Page up
        case VK_LEFT:
        case VK_RIGHT:
        case VK_UP:
        case VK_DOWN:
            nScanCode |= 0x100; // Add extended bit
        }
        if (fExtended)
            nScanCode |= 0x01000000L;

        TCHAR szStr[ MAX_PATH ] = {0};
        ::GetKeyNameText( nScanCode << 16, szStr, MAX_PATH );

        return CDuiString(szStr);
    }


    CDuiString CHotKeyWnd::GetHotKeyName()
    {
        ASSERT(::IsWindow(m_hWnd));

        CDuiString strKeyName;
        WORD wCode = 0;
        WORD wModifiers = 0;
        const TCHAR szPlus[] = _T(" + ");

        GetHotKey(wCode, wModifiers);
        if (wCode != 0 || wModifiers != 0)
        {
            if (wModifiers & HOTKEYF_CONTROL)
            {
                strKeyName += GetKeyName(VK_CONTROL, FALSE);
                strKeyName += szPlus;
            }


            if (wModifiers & HOTKEYF_SHIFT)
            {
                strKeyName += GetKeyName(VK_SHIFT, FALSE);
                strKeyName += szPlus;
            }


            if (wModifiers & HOTKEYF_ALT)
            {
                strKeyName += GetKeyName(VK_MENU, FALSE);
                strKeyName += szPlus;
            }


            strKeyName += GetKeyName(wCode, wModifiers & HOTKEYF_EXT);
        }

        return strKeyName;
    }


    //////////////////////////////////////////////////////////////////////////
    IMPLEMENT_DUICONTROL(CHotKeyUI)

    CHotKeyUI::CHotKeyUI() : m_pWindow(NULL), m_wVirtualKeyCode(0), m_wModifiers(0), m_uButtonState(0), m_dwHotKeybkColor(0xFFFFFFFF)
    {
        SetTextPadding(CDuiRect(4, 3, 4, 3));
        SetBkColor(0xFFFFFFFF);
    }

    LPCTSTR CHotKeyUI::GetClass() const
    {
        return _T("HotKeyUI");
    }

    LPVOID CHotKeyUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcscmp(pstrName, _T("HotKey")) == 0 ) return static_cast<CHotKeyUI *>(this);
        return CLabelUI::GetInterface(pstrName);
    }

    UINT CHotKeyUI::GetControlFlags() const
    {
        if( !IsEnabled() ) return CControlUI::GetControlFlags();

        return UIFLAG_SETCURSOR | UIFLAG_TABSTOP;
    }

    void CHotKeyUI::DoEvent(TEventUI& event)
    {
        if( !IsMouseEnabled() && event.Type > UIEVENT__MOUSEBEGIN && event.Type < UIEVENT__MOUSEEND ) {
            if( m_pParent != NULL ) m_pParent->DoEvent(event);
            else CLabelUI::DoEvent(event);
            return;
        }

        if( event.Type == UIEVENT_SETCURSOR && IsEnabled() )
        {
            ::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(IDC_IBEAM)));
            return;
        }
        if( event.Type == UIEVENT_WINDOWSIZE )
        {
            if( m_pWindow != NULL ) m_pManager->SetFocusNeeded(this);
        }
        if( event.Type == UIEVENT_SCROLLWHEEL )
        {
            if( m_pWindow != NULL ) return;
        }
        if( event.Type == UIEVENT_SETFOCUS && IsEnabled() ) 
        {
            if( m_pWindow ) return;
            m_pWindow = new CHotKeyWnd();
            ASSERT(m_pWindow);
            m_pWindow->Init(this);
            Invalidate();
        }

        if( event.Type == UIEVENT_KILLFOCUS && IsEnabled() ) 
        {
            Invalidate();
        }

        if( event.Type == UIEVENT_BUTTONDOWN || event.Type == UIEVENT_DBLCLICK || event.Type == UIEVENT_RBUTTONDOWN) 
        {
            if( IsEnabled() ) {
                GetManager()->ReleaseCapture();
                if( IsFocused() && m_pWindow == NULL ) {
                    m_pWindow = new CHotKeyWnd();
                    ASSERT(m_pWindow);
                    m_pWindow->Init(this);
                }
            }
            return;
        }
        if( event.Type == UIEVENT_MOUSEMOVE ) 
        {
            return;
        }
        if( event.Type == UIEVENT_BUTTONUP ) 
        {
            return;
        }
        if( event.Type == UIEVENT_CONTEXTMENU )
        {
            return;
        }
        if( event.Type == UIEVENT_MOUSEENTER )
        {
            if( IsEnabled() ) {
                m_uButtonState |= UISTATE_HOT;
                Invalidate();
            }
            return;
        }
        if( event.Type == UIEVENT_MOUSELEAVE )
        {
            if( IsEnabled() ) {
                m_uButtonState &= ~UISTATE_HOT;
                Invalidate();
            }
            return;
        }
        CLabelUI::DoEvent(event);
    }

    void CHotKeyUI::SetEnabled(bool bEnable)
    {
        CControlUI::SetEnabled(bEnable);
        if( !IsEnabled() ) {
            m_uButtonState = 0;
        }
    }

    void CHotKeyUI::SetText(LPCTSTR pstrText)
    {
        m_sText = pstrText;
        if( m_pWindow != NULL ) Edit_SetText(*m_pWindow, m_sText);
        Invalidate();
    }

    LPCTSTR CHotKeyUI::GetNormalImage()
    {
        return m_sNormalImage;
    }

    void CHotKeyUI::SetNormalImage(LPCTSTR pStrImage)
    {
        m_sNormalImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CHotKeyUI::GetHotImage()
    {
        return m_sHotImage;
    }

    void CHotKeyUI::SetHotImage(LPCTSTR pStrImage)
    {
        m_sHotImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CHotKeyUI::GetFocusedImage()
    {
        return m_sFocusedImage;
    }

    void CHotKeyUI::SetFocusedImage(LPCTSTR pStrImage)
    {
        m_sFocusedImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CHotKeyUI::GetDisabledImage()
    {
        return m_sDisabledImage;
    }

    void CHotKeyUI::SetDisabledImage(LPCTSTR pStrImage)
    {
        m_sDisabledImage = pStrImage;
        Invalidate();
    }

    void CHotKeyUI::SetNativeBkColor(DWORD dwBkColor)
    {
        m_dwHotKeybkColor = dwBkColor;
    }

    DWORD CHotKeyUI::GetNativeBkColor() const
    {
        return m_dwHotKeybkColor;
    }

    void CHotKeyUI::SetPos(RECT rc)
    {
        CControlUI::SetPos(rc);
        if( m_pWindow != NULL ) {
            RECT rcPos = m_pWindow->CalPos();
            ::SetWindowPos(m_pWindow->GetHWND(), NULL, rcPos.left, rcPos.top, rcPos.right - rcPos.left, 
                rcPos.bottom - rcPos.top, SWP_NOZORDER | SWP_NOACTIVATE);        
        }
    }

    void CHotKeyUI::SetVisible(bool bVisible)
    {
        CControlUI::SetVisible(bVisible);
        if( !IsVisible() && m_pWindow != NULL ) m_pManager->SetFocus(NULL);
    }

    void CHotKeyUI::SetInternVisible(bool bVisible)
    {
        if( !IsVisible() && m_pWindow != NULL ) m_pManager->SetFocus(NULL);
    }

    SIZE CHotKeyUI::EstimateSize(SIZE szAvailable)
    {
        if( m_cxyFixed.cy == 0 ) return CDuiSize(m_cxyFixed.cx, m_pManager->GetFontInfo(GetFont())->tm.tmHeight + 6);
        return CControlUI::EstimateSize(szAvailable);
    }

    void CHotKeyUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if( _tcscmp(pstrName, _T("normalimage")) == 0 ) SetNormalImage(pstrValue);
        else if( _tcscmp(pstrName, _T("hotimage")) == 0 ) SetHotImage(pstrValue);
        else if( _tcscmp(pstrName, _T("focusedimage")) == 0 ) SetFocusedImage(pstrValue);
        else if( _tcscmp(pstrName, _T("disabledimage")) == 0 ) SetDisabledImage(pstrValue);
        else if( _tcscmp(pstrName, _T("nativebkcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetNativeBkColor(clrColor);
        }
        else CLabelUI::SetAttribute(pstrName, pstrValue);
    }

    void CHotKeyUI::PaintStatusImage(HDC hDC)
    {
        if( IsFocused() ) m_uButtonState |= UISTATE_FOCUSED;
        else m_uButtonState &= ~ UISTATE_FOCUSED;
        if( !IsEnabled() ) m_uButtonState |= UISTATE_DISABLED;
        else m_uButtonState &= ~ UISTATE_DISABLED;

        if( (m_uButtonState & UISTATE_DISABLED) != 0 ) {
            if( !m_sDisabledImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sDisabledImage) ) {}
                else return;
            }
        }
        else if( (m_uButtonState & UISTATE_FOCUSED) != 0 ) {
            if( !m_sFocusedImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sFocusedImage) ) {}
                else return;
            }
        }
        else if( (m_uButtonState & UISTATE_HOT) != 0 ) {
            if( !m_sHotImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sHotImage) ) {}
                else return;
            }
        }

        if( !m_sNormalImage.IsEmpty() ) {
            if( !DrawImage(hDC, (LPCTSTR)m_sNormalImage) ) {}
            else return;
        }
    }

    void CHotKeyUI::PaintText(HDC hDC)
    {
        if( m_dwTextColor == 0 ) m_dwTextColor = m_pManager->GetDefaultFontColor();
        if( m_dwDisabledTextColor == 0 ) m_dwDisabledTextColor = m_pManager->GetDefaultDisabledColor();
        if( m_sText.IsEmpty() ) return;
        CDuiString sText = m_sText;
        RECT rc = m_rcItem;
        rc.left += m_rcTextPadding.left;
        rc.right -= m_rcTextPadding.right;
        rc.top += m_rcTextPadding.top;
        rc.bottom -= m_rcTextPadding.bottom;
        DWORD dwTextColor = m_dwTextColor;
        if(!IsEnabled())dwTextColor = m_dwDisabledTextColor;

        CRenderEngine::DrawText(hDC, m_pManager, rc, sText, dwTextColor, m_iFont, DT_SINGLELINE | m_uTextStyle);
    }

    DWORD CHotKeyUI::GetHotKey() const
    {
        return (MAKEWORD(m_wVirtualKeyCode, m_wModifiers));
    }

    void CHotKeyUI::GetHotKey(WORD &wVirtualKeyCode, WORD &wModifiers) const
    {
        wVirtualKeyCode = m_wVirtualKeyCode;
        wModifiers = m_wModifiers;
    }

    void CHotKeyUI::SetHotKey(WORD wVirtualKeyCode, WORD wModifiers)
    {
        m_wVirtualKeyCode = wVirtualKeyCode;
        m_wModifiers = wModifiers;

        if( m_pWindow ) return;
        m_pWindow = new CHotKeyWnd();
        ASSERT(m_pWindow);
        m_pWindow->Init(this);
        Invalidate();
    }

}// Duilib