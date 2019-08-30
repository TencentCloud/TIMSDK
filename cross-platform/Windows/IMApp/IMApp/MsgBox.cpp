#include "MsgBox.h"

const TCHAR wMessageBoxCaption[] = _T("MessageBox_Caption");
const TCHAR wMessageBoxIcon[] = _T("MessageBox_Icon");
const TCHAR wMessageBoxText[] = _T("MessageBox_Text");
const TCHAR wMessageBoxTextLayout[] = _T("MessageBox_TextLayout");
const TCHAR wMessageBoxIconLayout[] = _T("MessageBox_IconLayout");


CMsgBox::CMsgBox() :
    m_pButtonCancel(NULL)
{
}

CMsgBox::~CMsgBox()
{

}

LPCTSTR CMsgBox::GetWindowClassName() const 
{ 
    return _T("UIMessageDialog");
}

UINT CMsgBox::GetClassStyle() const 
{ 
    return CS_DBLCLKS;
}


void CMsgBox::OnFinalMessage(HWND /*hWnd*/) 
{ 
    return;
}

void CMsgBox::InitWindow()
{
    m_pButtonCancel = static_cast<CButtonUI*>(m_pm.FindControl(_T("cancelbtn")));
    //SetBkColor(m_dwBKColor);
    //SetBkImage(m_stBKImage);
}

void CMsgBox::Notify(TNotifyUI& msg)
{
    if( msg.sType == _T("click") ) 
    {
        if( msg.pSender->GetName() == _T("closebtn")) {
            Close(IDOK);
            return; 
        }
        else if( msg.pSender->GetName() == _T("cancelbtn")) {
            Close(IDCANCEL);
            return; 
        }
    }

}

LRESULT CMsgBox::OnCreate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
    LONG styleValue = ::GetWindowLong(*this, GWL_STYLE);
//    styleValue &= ~WS_CAPTION;
    ::SetWindowLong(*this, GWL_STYLE, styleValue | WS_CLIPSIBLINGS | WS_CLIPCHILDREN);

    return __super::OnCreate(uMsg, wParam, lParam, bHandled);
}

LRESULT CMsgBox::OnClose(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
    bHandled = FALSE;
    return 0;
}

LRESULT CMsgBox::OnDestroy(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
    bHandled = FALSE;
    return 0;
}

LRESULT CMsgBox::OnNcActivate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
    if( ::IsIconic(*this) ) bHandled = FALSE;
    return (wParam == 0) ? TRUE : FALSE;
}

LRESULT CMsgBox::OnNcCalcSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
    return 0;
}

LRESULT CMsgBox::OnNcPaint(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
    return 0;
}

LRESULT CMsgBox::OnNcHitTest(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
    POINT pt; pt.x = GET_X_LPARAM(lParam); pt.y = GET_Y_LPARAM(lParam);
    ::ScreenToClient(*this, &pt);

    RECT rcClient;
    ::GetClientRect(*this, &rcClient);

    RECT rcCaption = m_pm.GetCaptionRect();
    if( pt.x >= rcClient.left + rcCaption.left && pt.x < rcClient.right - rcCaption.right \
        && pt.y >= rcCaption.top && pt.y < rcCaption.bottom ) {
            CControlUI* pControl = static_cast<CControlUI*>(m_pm.FindControl(pt));
            if( pControl && _tcscmp(pControl->GetClass(), _T("ButtonUI")) != 0 && 
                _tcscmp(pControl->GetClass(), _T("OptionUI")) != 0 &&
                _tcscmp(pControl->GetClass(), _T("TextUI")) != 0 )
                return HTCAPTION;
    }

    return HTCLIENT;
}

LRESULT CMsgBox::OnSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
    SIZE szRoundCorner = m_pm.GetRoundCorner();
#if defined(WIN32) && !defined(UNDER_CE)
    if( !::IsIconic(*this) /*&& (szRoundCorner.cx != 0 || szRoundCorner.cy != 0)*/ ) {
        CDuiRect rcWnd;
        ::GetWindowRect(*this, &rcWnd);
        rcWnd.Offset(-rcWnd.left, -rcWnd.top);
        rcWnd.right++; rcWnd.bottom++;
        HRGN hRgn = ::CreateRoundRectRgn(rcWnd.left, rcWnd.top, rcWnd.right, rcWnd.bottom, szRoundCorner.cx, szRoundCorner.cy);
        ::SetWindowRgn(*this, hRgn, TRUE);
        ::DeleteObject(hRgn);
    }
#endif
    bHandled = FALSE;
    return 0;
}

LRESULT CMsgBox::OnGetMinMaxInfo(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
    MONITORINFO oMonitor = {};
    oMonitor.cbSize = sizeof(oMonitor);
    ::GetMonitorInfo(::MonitorFromWindow(*this, MONITOR_DEFAULTTOPRIMARY), &oMonitor);
    CDuiRect rcWork = oMonitor.rcWork;
    rcWork.Offset(-oMonitor.rcMonitor.left, -oMonitor.rcMonitor.top);

    LPMINMAXINFO lpMMI = (LPMINMAXINFO) lParam;
    lpMMI->ptMaxPosition.x    = rcWork.left;
    lpMMI->ptMaxPosition.y    = rcWork.top;
    lpMMI->ptMaxSize.x        = rcWork.right;
    lpMMI->ptMaxSize.y        = rcWork.bottom;

    bHandled = FALSE;
    return 0;
}

LRESULT CMsgBox::OnSysCommand(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
    // 有时会在收到WM_NCDESTROY后收到wParam为SC_CLOSE的WM_SYSCOMMAND
    if( wParam == SC_CLOSE ) {
        bHandled = TRUE;
        SendMessage(WM_CLOSE);
        return 0;
    }
    BOOL bZoomed = ::IsZoomed(*this);
    LRESULT lRes = CWindowWnd::HandleMessage(uMsg, wParam, lParam);
    if( ::IsZoomed(*this) != bZoomed ) {
    }
    return lRes;
}

LRESULT CMsgBox::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    LRESULT lRes = 0;
    BOOL bHandled = TRUE;
    switch( uMsg ) {
    case WM_CREATE:        lRes = OnCreate(uMsg, wParam, lParam, bHandled); break;
    case WM_CLOSE:         lRes = OnClose(uMsg, wParam, lParam, bHandled); break;
    case WM_DESTROY:       lRes = OnDestroy(uMsg, wParam, lParam, bHandled); break;
    case WM_NCACTIVATE:    lRes = OnNcActivate(uMsg, wParam, lParam, bHandled); break;
    case WM_NCCALCSIZE:    lRes = OnNcCalcSize(uMsg, wParam, lParam, bHandled); break;
    case WM_NCPAINT:       lRes = OnNcPaint(uMsg, wParam, lParam, bHandled); break;
    case WM_NCHITTEST:     lRes = OnNcHitTest(uMsg, wParam, lParam, bHandled); break;
    case WM_SIZE:          lRes = OnSize(uMsg, wParam, lParam, bHandled); break;
    case WM_GETMINMAXINFO: lRes = OnGetMinMaxInfo(uMsg, wParam, lParam, bHandled); break;
    case WM_SYSCOMMAND:    lRes = OnSysCommand(uMsg, wParam, lParam, bHandled); break;
    default:
    bHandled = FALSE;
    }
    if( bHandled ) return lRes;
    if( m_pm.MessageHandler(uMsg, wParam, lParam, lRes) ) return lRes;
    return CWindowWnd::HandleMessage(uMsg, wParam, lParam);
}


UINT CMsgBox::DuiMessageBox(WindowImplBase *pWnd, LPCTSTR lpText, LPCTSTR lpCaption, UINT uIcon, BOOL bOk)
{
    m_SkilFile = "msgbox.xml";
    Create(pWnd ? pWnd->GetHWND() : NULL, _T(""), UI_WNDSTYLE_DIALOG, WS_EX_WINDOWEDGE);

    if (bOk && m_pButtonCancel != NULL)  m_pButtonCancel->SetVisible(false);

    CButtonUI *pButton = static_cast<CButtonUI*>(m_pm.FindControl(wMessageBoxIcon));;
    CContainerUI* pIconLayout = static_cast<CContainerUI*>(m_pm.FindControl(wMessageBoxIconLayout));
    CDuiString stImage;
    if (pButton != NULL)
    {
        switch(uIcon)
        {
        case MESSAGE_SUCCEED:
            break;
        case MESSAGE_QUESTION:
            break;
        case MESSAGE_WARNING:
            break;
        case MESSAGE_ERROR:
            break;
        case MESSAGE_INFO:
            break;    
        case MESSAGE_ABOUT:
            break;
        }
        if (stImage.GetLength() != 0)
        {
            pButton->SetBkImage(stImage);
        }
        else{
            pIconLayout->SetVisible(false);
        }
    }

    CTextUI* pCaption_control = static_cast<CTextUI*>(m_pm.FindControl(wMessageBoxCaption));
    if (pCaption_control != NULL)    pCaption_control->SetText(lpCaption);

    CContainerUI* pTextLayout = static_cast<CContainerUI*>(m_pm.FindControl(wMessageBoxTextLayout));
    CTextUI* pText_control = static_cast<CTextUI*>(m_pm.FindControl(wMessageBoxText));
    if (pText_control != NULL && pTextLayout != NULL)
    {
        pText_control->SetText(lpText); //设置文本
        RECT T = pText_control->GetPos();
        SIZE m_szClient = m_pm.GetClientSize();
        int nCTextUIWidth = m_szClient.cx - pTextLayout->GetChildPadding() - pTextLayout->GetInset().left - 15;
        CDuiString stMax;
        int nLines = GetStringLines(lpText, stMax);
        SIZE szSpace = { 0 };
        HFONT hOldFont = (HFONT)::SelectObject(m_pm.GetPaintDC(), m_pm.GetFont(0));
        ::GetTextExtentPoint32(m_pm.GetPaintDC(), stMax, stMax.GetLength(), &szSpace);
        ::SelectObject(m_pm.GetPaintDC(), (HGDIOBJ)hOldFont);

        szSpace.cy = (szSpace.cy) * nLines + 80;
        if (pIconLayout->IsVisible())  szSpace.cx = szSpace.cx + 100;
        else szSpace.cx = szSpace.cx + 65;

        //计算 文本大小
        RECT rect;
        GetClientRect(m_hWnd, &rect);
        rect.right = szSpace.cx + rect.left;
        rect.bottom = rect.top + szSpace.cy;
        SetWindowPos (m_hWnd, NULL, rect.left, rect.top, rect.right , rect.bottom, SWP_SHOWWINDOW );
    }

    CenterWindow();
    UINT uRet = ShowModal();
    return uRet;
}


int CMsgBox::GetStringLines(CDuiString st, CDuiString &stMax)
{
    stMax = _T("");
    CDuiString stTmp;
    int nCount = 1;
    for (int i = 0; i < st.GetLength() ; i++)
    {
        if (st[i] == _T('\n'))
        {
            if (stTmp.GetLength() > stMax.GetLength())   stMax = stTmp;
            stTmp = _T("");
            nCount++;
        }else if (st[i] == _T('\r') && ((i + 1) < st.GetLength()) && st[i + 1] == _T('\n'))
        {
            if (stTmp.GetLength() > stMax.GetLength())   stMax = stTmp;
            stTmp = _T("");
            nCount++;  
            i++;
        }
        else
        {
            stTmp += st[i];
        }
    }
    if (stTmp.GetLength() > stMax.GetLength()) {
        stMax = stTmp;
    }
    return nCount;
}

