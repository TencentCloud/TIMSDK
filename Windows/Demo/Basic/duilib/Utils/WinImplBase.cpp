#include "StdAfx.h"
#include <algorithm>
namespace DuiLib
{
    //////////////////////////////////////////////////////////////////////////
    //
    DUI_BEGIN_MESSAGE_MAP(WindowImplBase, CNotifyPump)
        DUI_ON_MSGTYPE(DUI_MSGTYPE_CLICK,OnClick)
    DUI_END_MESSAGE_MAP()

    void WindowImplBase::OnFinalMessage( HWND hWnd )
    {
        m_pm.RemovePreMessageFilter(this);
        m_pm.RemoveNotifier(this);
        m_pm.ReapObjects(m_pm.GetRoot());
    }

    LRESULT WindowImplBase::ResponseDefaultKeyEvent(WPARAM wParam)
    {
        if (wParam == VK_RETURN)
        {
            return FALSE;
        }
        else if (wParam == VK_ESCAPE)
        {
            return TRUE;
        }

        return FALSE;
    }

    UINT WindowImplBase::GetClassStyle() const
    {
        return CS_DBLCLKS;
    }

    CControlUI* WindowImplBase::CreateControl(LPCTSTR pstrClass)
    {
        return NULL;
    }

    LPCTSTR WindowImplBase::QueryControlText(LPCTSTR lpstrId, LPCTSTR lpstrType)
    {
        return NULL;
    }

    LRESULT WindowImplBase::MessageHandler(UINT uMsg, WPARAM wParam, LPARAM /*lParam*/, bool& /*bHandled*/)
    {
        if (uMsg == WM_KEYDOWN)
        {
            switch (wParam)
            {
            case VK_RETURN:
            case VK_ESCAPE:
                return ResponseDefaultKeyEvent(wParam);
            default:
                break;
            }
        }
        return FALSE;
    }

    LRESULT WindowImplBase::OnClose(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

    LRESULT WindowImplBase::OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

#if defined(WIN32) && !defined(UNDER_CE)
    LRESULT WindowImplBase::OnNcActivate(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
    {
        if( ::IsIconic(*this) ) bHandled = FALSE;
        return (wParam == 0) ? TRUE : FALSE;
    }

    LRESULT WindowImplBase::OnNcCalcSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        return 0;
    }

    LRESULT WindowImplBase::OnNcPaint(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
    {
        return 0;
    }


    BOOL WindowImplBase::IsInStaticControl(CControlUI *pControl)
    {
        BOOL bRet = FALSE;
        if (!pControl)
        {
            return bRet;
        }

        CDuiString strClassName;
        std::vector<CDuiString> vctStaticName;

        strClassName = pControl->GetClass();
        strClassName.MakeLower();
        vctStaticName.push_back(_T("controlui"));
        vctStaticName.push_back(_T("textui"));
        vctStaticName.push_back(_T("labelui"));
        vctStaticName.push_back(_T("containerui"));
        vctStaticName.push_back(_T("horizontallayoutui"));
        vctStaticName.push_back(_T("verticallayoutui"));
        vctStaticName.push_back(_T("tablayoutui"));
        vctStaticName.push_back(_T("childlayoutui"));
        vctStaticName.push_back(_T("dialoglayoutui"));
        vctStaticName.push_back(_T("progresscontainerui"));
        std::vector<CDuiString>::iterator it = std::find(vctStaticName.begin(), vctStaticName.end(), strClassName);
        if (vctStaticName.end() != it)
        {
            CControlUI* pParent = pControl->GetParent();
            while (pParent)
            {
                strClassName = pParent->GetClass();
                strClassName.MakeLower();
                it = std::find(vctStaticName.begin(), vctStaticName.end(), strClassName);
                if (vctStaticName.end() == it)
                {
                    return bRet;
                }

                pParent = pParent->GetParent();
            }

            bRet = TRUE;
        }

        return bRet;
    }

    LRESULT WindowImplBase::OnNcHitTest(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        POINT pt; pt.x = GET_X_LPARAM(lParam); pt.y = GET_Y_LPARAM(lParam);
        ::ScreenToClient(*this, &pt);

        RECT rcClient;
        ::GetClientRect(*this, &rcClient);

        if (!::IsZoomed(*this))
        {
            RECT rcSizeBox = m_pm.GetSizeBox();
            if (pt.y < rcClient.top + rcSizeBox.top)
            {
                if (pt.x < rcClient.left + rcSizeBox.left) return HTTOPLEFT;
                if (pt.x > rcClient.right - rcSizeBox.right) return HTTOPRIGHT;
                return HTTOP;
            }
            else if (pt.y > rcClient.bottom - rcSizeBox.bottom)
            {
                if (pt.x < rcClient.left + rcSizeBox.left) return HTBOTTOMLEFT;
                if (pt.x > rcClient.right - rcSizeBox.right) return HTBOTTOMRIGHT;
                return HTBOTTOM;
            }

            if (pt.x < rcClient.left + rcSizeBox.left) return HTLEFT;
            if (pt.x > rcClient.right - rcSizeBox.right) return HTRIGHT;
        }

        RECT rcCaption = m_pm.GetCaptionRect();
        if (-1 == rcCaption.bottom)
        {
            rcCaption.bottom = rcClient.bottom;
        }

        if (pt.x >= rcClient.left + rcCaption.left && pt.x < rcClient.right - rcCaption.right
            && pt.y >= rcCaption.top && pt.y < rcCaption.bottom)
        {
            CControlUI* pControl = m_pm.FindControl(pt);
            if (IsInStaticControl(pControl))
            {
                return HTCAPTION;
            }
        }

        return HTCLIENT;
    }

    LRESULT WindowImplBase::OnGetMinMaxInfo(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        MONITORINFO Monitor = {};
        Monitor.cbSize = sizeof(Monitor);
        ::GetMonitorInfo(::MonitorFromWindow(m_hWnd, MONITOR_DEFAULTTOPRIMARY), &Monitor);
        RECT rcWork = Monitor.rcWork;
        if( Monitor.dwFlags != MONITORINFOF_PRIMARY ) {
            ::OffsetRect(&rcWork, -rcWork.left, -rcWork.top);
        }

        LPMINMAXINFO lpMMI = (LPMINMAXINFO) lParam;
        lpMMI->ptMaxPosition.x    = rcWork.left;
        lpMMI->ptMaxPosition.y    = rcWork.top;
        lpMMI->ptMaxSize.x = rcWork.right - rcWork.left;
        lpMMI->ptMaxSize.y = rcWork.bottom - rcWork.top;
        lpMMI->ptMaxTrackSize.x = m_pm.GetMaxInfo().cx == 0?rcWork.right - rcWork.left:m_pm.GetMaxInfo().cx;
        lpMMI->ptMaxTrackSize.y = m_pm.GetMaxInfo().cy == 0?rcWork.bottom - rcWork.top:m_pm.GetMaxInfo().cy;
        lpMMI->ptMinTrackSize.x = m_pm.GetMinInfo().cx;
        lpMMI->ptMinTrackSize.y = m_pm.GetMinInfo().cy;

        bHandled = TRUE;
        return 0;
    }

    LRESULT WindowImplBase::OnMouseWheel(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

    LRESULT WindowImplBase::OnMouseHover(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }
#endif

    LRESULT WindowImplBase::OnSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        SIZE szRoundCorner = m_pm.GetRoundCorner();
#if defined(WIN32) && !defined(UNDER_CE)
        if( !::IsIconic(*this) ) {
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

    LRESULT WindowImplBase::OnChar(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

    LRESULT WindowImplBase::OnSysCommand(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        if (wParam == SC_CLOSE)
        {
            bHandled = TRUE;
            SendMessage(WM_CLOSE);
            return 0;
        }
#if defined(WIN32) && !defined(UNDER_CE)
        BOOL bZoomed = ::IsZoomed(*this);
        LRESULT lRes = CWindowWnd::HandleMessage(uMsg, wParam, lParam);
        if( ::IsZoomed(*this) != bZoomed ) {
            if( !bZoomed ) {
                CControlUI* pControl = static_cast<CControlUI*>(m_pm.FindControl(_T("maxbtn")));
                if( pControl ) pControl->SetVisible(false);
                pControl = static_cast<CControlUI*>(m_pm.FindControl(_T("restorebtn")));
                if( pControl ) pControl->SetVisible(true);
            }
            else {
                CControlUI* pControl = static_cast<CControlUI*>(m_pm.FindControl(_T("maxbtn")));
                if( pControl ) pControl->SetVisible(true);
                pControl = static_cast<CControlUI*>(m_pm.FindControl(_T("restorebtn")));
                if( pControl ) pControl->SetVisible(false);
            }
        }
#else
        LRESULT lRes = CWindowWnd::HandleMessage(uMsg, wParam, lParam);
#endif
        return lRes;
    }

    LRESULT WindowImplBase::OnCreate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        // 调整窗口样式
        LONG styleValue = ::GetWindowLong(*this, GWL_STYLE);
        styleValue &= ~WS_CAPTION;
        ::SetWindowLong(*this, GWL_STYLE, styleValue | WS_CLIPSIBLINGS | WS_CLIPCHILDREN);

        RECT rcClient;
        ::GetClientRect(*this, &rcClient);
        ::SetWindowPos(*this, NULL, rcClient.left, rcClient.top, rcClient.right - rcClient.left, \
            rcClient.bottom - rcClient.top, SWP_FRAMECHANGED);

        // 关联UI管理器
        m_pm.Init(m_hWnd, GetManagerName());
        // 注册PreMessage回调
        m_pm.AddPreMessageFilter(this);

        // 创建主窗口
        CDialogBuilder builder;
        if (m_pm.GetResourcePath().IsEmpty())
        {    // 允许更灵活的资源路径定义
            CDuiString strResourcePath = m_pm.GetInstancePath();
            strResourcePath += GetSkinFolder().GetData();
            m_pm.SetResourcePath(strResourcePath.GetData());
        }

        switch (GetResourceType())
        {
        case UILIB_ZIP:
            m_pm.SetResourceZip(GetZIPFileName().GetData(), true);
            break;
        case UILIB_ZIPRESOURCE:
        {
            HRSRC hResource = ::FindResource(m_pm.GetResourceDll(), GetResourceID(), _T("ZIPRES"));
            if (hResource == NULL)
                return 0L;
            DWORD dwSize = 0;
            HGLOBAL hGlobal = ::LoadResource(m_pm.GetResourceDll(), hResource);
            if (hGlobal == NULL)
            {
#if defined(WIN32) && !defined(UNDER_CE)
                ::FreeResource(hResource);
#endif
                return 0L;
            }
            dwSize = ::SizeofResource(m_pm.GetResourceDll(), hResource);
            if (dwSize == 0)
                return 0L;

            m_pm.SetResourceZip((LPBYTE)::LockResource(hGlobal), dwSize);

#if defined(WIN32) && !defined(UNDER_CE)
            ::FreeResource(hResource);
#endif
        }
        break;
        }

        CControlUI* pRoot = NULL;
        if (GetResourceType() == UILIB_RESOURCE)
        {
            STRINGorID xml(_ttoi(GetSkinFile().GetData()));
            pRoot = builder.Create(xml, _T("xml"), this, &m_pm);
        }
        else {
            pRoot = builder.Create(GetSkinFile().GetData(), (UINT)0, this, &m_pm);
        }
        ASSERT(pRoot);
        if (pRoot == NULL)
        {
            MessageBox(NULL, _T("加载资源文件失败"), _T("Duilib"), MB_OK | MB_ICONERROR);
            ExitProcess(1);
            return 0;
        }
        m_pm.AttachDialog(pRoot);
        // 添加Notify事件接口
        m_pm.AddNotifier(this);
        // 窗口初始化完毕
        InitWindow();
        return 0;
    }

    LRESULT WindowImplBase::OnKeyDown(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

    LRESULT WindowImplBase::OnKillFocus(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

    LRESULT WindowImplBase::OnSetFocus(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

    LRESULT WindowImplBase::OnLButtonDown(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

    LRESULT WindowImplBase::OnLButtonUp(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

    LRESULT WindowImplBase::OnMouseMove(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

    LRESULT WindowImplBase::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
    {
        LRESULT lRes = 0;
        BOOL bHandled = TRUE;
        switch (uMsg)
        {
        case WM_CREATE:            lRes = OnCreate(uMsg, wParam, lParam, bHandled); break;
        case WM_CLOSE:            lRes = OnClose(uMsg, wParam, lParam, bHandled); break;
        case WM_DESTROY:        lRes = OnDestroy(uMsg, wParam, lParam, bHandled); break;
#if defined(WIN32) && !defined(UNDER_CE)
        case WM_NCACTIVATE:        lRes = OnNcActivate(uMsg, wParam, lParam, bHandled); break;
        case WM_NCCALCSIZE:        lRes = OnNcCalcSize(uMsg, wParam, lParam, bHandled); break;
        case WM_NCPAINT:        lRes = OnNcPaint(uMsg, wParam, lParam, bHandled); break;
        case WM_NCHITTEST:        lRes = OnNcHitTest(uMsg, wParam, lParam, bHandled); break;
        case WM_GETMINMAXINFO:    lRes = OnGetMinMaxInfo(uMsg, wParam, lParam, bHandled); break;
        case WM_MOUSEWHEEL:        lRes = OnMouseWheel(uMsg, wParam, lParam, bHandled); break;
#endif
        case WM_SIZE:            lRes = OnSize(uMsg, wParam, lParam, bHandled); break;
        case WM_CHAR:        lRes = OnChar(uMsg, wParam, lParam, bHandled); break;
        case WM_SYSCOMMAND:        lRes = OnSysCommand(uMsg, wParam, lParam, bHandled); break;
        case WM_KEYDOWN:        lRes = OnKeyDown(uMsg, wParam, lParam, bHandled); break;
        case WM_KILLFOCUS:        lRes = OnKillFocus(uMsg, wParam, lParam, bHandled); break;
        case WM_SETFOCUS:        lRes = OnSetFocus(uMsg, wParam, lParam, bHandled); break;
        case WM_LBUTTONUP:        lRes = OnLButtonUp(uMsg, wParam, lParam, bHandled); break;
        case WM_LBUTTONDOWN:    lRes = OnLButtonDown(uMsg, wParam, lParam, bHandled); break;
        case WM_MOUSEMOVE:        lRes = OnMouseMove(uMsg, wParam, lParam, bHandled); break;
        case WM_MOUSEHOVER:    lRes = OnMouseHover(uMsg, wParam, lParam, bHandled); break;
        default:                bHandled = FALSE; break;
        }
        if (bHandled) return lRes;

        lRes = HandleCustomMessage(uMsg, wParam, lParam, bHandled);
        if (bHandled) return lRes;

        if (m_pm.MessageHandler(uMsg, wParam, lParam, lRes))
            return lRes;
        return CWindowWnd::HandleMessage(uMsg, wParam, lParam);
    }

    LRESULT WindowImplBase::HandleCustomMessage(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        bHandled = FALSE;
        return 0;
    }

    LONG WindowImplBase::GetStyle()
    {
        LONG styleValue = ::GetWindowLong(*this, GWL_STYLE);
        styleValue &= ~WS_CAPTION;

        return styleValue;
    }

    const TCHAR kWndBaseBackGround[] = _T("background"); //背景。图片 设置图片或颜色
    const TCHAR kWndBaseCloseBtn[] = _T("closebtn");
    const TCHAR kWndBaseMinBtn[] = _T("minbtn");
    const TCHAR kWndBaseMinRestoreBtn[] = _T("minrestorebtn");
    const TCHAR kWndBaseMaxBtn[] = _T("maxbtn");
    const TCHAR kWndBaseMaxRestoreBtn[] = _T("maxrestorebtn");

    void WindowImplBase::OnClick(TNotifyUI& msg)
    {
        CControlUI *p = NULL;
        CDuiString sCtrlName = msg.pSender->GetName();
        if (sCtrlName == kWndBaseCloseBtn)
        {
            SendMessage(WM_SYSCOMMAND, SC_CLOSE, 0);  //发送一个 SYSCOMMAND 事件，让子类判断是否退出程序
            //::PostMessage(m_hWnd, WM_QUIT, 0, 0);
        }
        else if (sCtrlName == kWndBaseMinBtn)
        {
            SendMessage(WM_SYSCOMMAND, SC_MINIMIZE, 0);
            if (m_pm.FindControl(kWndBaseMinRestoreBtn))
            {
                SetControlVisible(kWndBaseMinRestoreBtn);
                SetControlVisible(kWndBaseMinBtn, false);
            }
        }
        else if (sCtrlName == kWndBaseMaxBtn)
        {
            SendMessage(WM_SYSCOMMAND, SC_MAXIMIZE, 0);
            if (m_pm.FindControl(kWndBaseMaxRestoreBtn))
            {
                SetControlVisible(kWndBaseMaxRestoreBtn);
                SetControlVisible(kWndBaseMaxBtn, false);
            }
        }
        else if (sCtrlName == kWndBaseMaxRestoreBtn)
        {
            SendMessage(WM_SYSCOMMAND, SC_RESTORE, 0);
            if (m_pm.FindControl(TEXT("maxbtn")))
            {
                SetControlVisible(kWndBaseMaxBtn);
                SetControlVisible(kWndBaseMaxRestoreBtn, false);
            }
        }
        else if (sCtrlName == kWndBaseMinRestoreBtn)
        {
            SendMessage(WM_SYSCOMMAND, SC_RESTORE, 0);
            if (m_pm.FindControl(kWndBaseMinBtn))
            {
                SetControlVisible(kWndBaseMinBtn);
                SetControlVisible(kWndBaseMinRestoreBtn, false);
            }
        }
    }

    void WindowImplBase::Notify(TNotifyUI& msg)
    {
        if (msg.sType == _T("windowinit"))
        {
            OnPrepare();
            return;
        }
        return CNotifyPump::NotifyPump(msg);
    }

    BOOL WindowImplBase::IsOptionChecked(CDuiString contorlName)
    {
        BOOL ret = FALSE;
        COptionUI * p = static_cast<COptionUI*>(m_pm.FindControl(contorlName));
        if (p && _tcscmp(p->GetClass(), _T("OptionUI")) == 0)
        {
            ret = p->IsSelected();
        }
        return ret;
    }

    BOOL WindowImplBase::IsCheckBoxChecked(CDuiString contorlName)
    {
        BOOL ret = FALSE;
        COptionUI * p = static_cast<COptionUI*>(m_pm.FindControl(contorlName));
        if (p && _tcscmp(p->GetClass(), _T("CheckBoxUI")) == 0)
        {
            ret = p->IsSelected();
        }
        return ret;
    }

    void WindowImplBase::SetControlVisible(CDuiString contorlName, bool flag)
    {
        CControlUI *p = m_pm.FindControl(contorlName);
        if (p)
        {
            p->SetVisible(flag);
        }
    }

    void WindowImplBase::ListContorlRemoveAll(CDuiString contorlName)
    {
        CControlUI * p = (m_pm.FindControl(contorlName));
        if (p)
        {
            if (_tcscmp(p->GetClass(), _T("ComboUI")) == 0)
            {
                (static_cast<CComboBoxUI*>(p))->RemoveAll();
            }
            if (_tcscmp(p->GetClass(), _T("ListUI")) == 0)
            {
                (static_cast<CListUI*>(p))->RemoveAll();

            }
        }
    }
    void WindowImplBase::SetControlEnabled(CDuiString contorlName, bool flag)
    {
        CControlUI *p = m_pm.FindControl(contorlName);
        if (p)
        {
            p->SetEnabled(flag);
        }
    }

    void WindowImplBase::ComboBoxAdd(CDuiString contorlName, CDuiString addText)
    {
        CComboBoxUI * p = static_cast<CComboBoxUI*>(m_pm.FindControl(contorlName));
        if (p)
        {
            if (_tcscmp(p->GetClass(), _T("ComboUI")) == 0)
            {
                CListLabelElementUI *ele = new CListLabelElementUI();
                ele->SetText(addText);
                p->Add(ele);
            }
        }
    }
    void WindowImplBase::ComboBoxClear(CDuiString contorlName) {
        CComboBoxUI * p = static_cast<CComboBoxUI*>(m_pm.FindControl(contorlName));
        if (p) {
            if (_tcscmp(p->GetClass(), _T("ComboUI")) == 0) {
                p->RemoveAll();
            }
        }
    }
    void WindowImplBase::ComboBoxDel(CDuiString contorlName, CDuiString delText) {
        CComboBoxUI * p = static_cast<CComboBoxUI*>(m_pm.FindControl(contorlName));
        if (p)
        {
            if (_tcscmp(p->GetClass(), _T("ComboUI")) == 0)
            {
                for (int i = 0; i < p->GetCount(); i++) {
                    if (p->GetItemAt(i)->GetText() == delText) {
                        p->RemoveAt(i);
                        break;
                    }
                }
            }
        }
    }

    //设置Combo控件选中子项 CComboBoxUI
    void WindowImplBase::ComboBoxSelect(CDuiString contorlName, CDuiString selectText)
    {
        CComboBoxUI * p = static_cast<CComboBoxUI*>(m_pm.FindControl(contorlName));
        if (p && _tcscmp(p->GetClass(), _T("ComboUI")) == 0)
        {
            for (int i = 0; i < p->GetCount(); i++)
            {
                if (p->GetItemAt(i)->GetText() == selectText) { p->SelectItem(i); break; }
            }
        }
    }

    void WindowImplBase::ComboBoxSelect(CDuiString contorlName, UINT_PTR tag) {
        CComboBoxUI * p = static_cast<CComboBoxUI*>(m_pm.FindControl(contorlName));
        if (p && _tcscmp(p->GetClass(), _T("ComboUI")) == 0) {
            for (int i = 0; i < p->GetCount(); i++) {
                if (p->GetItemAt(i)->GetTag() == tag) {
                    p->SelectItem(i);
                    break;
                }
            }
        }
    }

    void WindowImplBase::SetOptionChecked(CDuiString contorlName, bool flag)
    {
        COptionUI * p = static_cast<COptionUI*>(m_pm.FindControl(contorlName));
        if (p && _tcscmp(p->GetClass(), _T("OptionUI")) == 0)
        {
            p->Selected(flag);
        }
    }

    void WindowImplBase::SetCheckBoxChecked(CDuiString contorlName, bool flag/* = true*/)
    {
        COptionUI * p = static_cast<COptionUI*>(m_pm.FindControl(contorlName));
        if (p && _tcscmp(p->GetClass(), _T("CheckBoxUI")) == 0)
        {
            p->Selected(flag);
        }
    }

    CDuiString WindowImplBase::GetControlText(CDuiString contorlName)
    {
        CDuiString st = _T("");
        CControlUI *p = m_pm.FindControl(contorlName);
        if (p)
        {
            st = p->GetText();
        }
        return st;
    }

    void WindowImplBase::SetControlText(CDuiString contorlName, CDuiString contorlText)
    {
        CControlUI *p = m_pm.FindControl(contorlName);
        if (p)
        {
            p->SetText(contorlText);
        }
    }

    DWORD WindowImplBase::GetBkColor3() const
    {
        CControlUI* background = m_pm.FindControl(kWndBaseBackGround);
        if (background)
        {
            background->GetBkColor3();
        }
        return 0;
    }

    DWORD WindowImplBase::GetBkColor2() const
    {
        CControlUI* background = m_pm.FindControl(kWndBaseBackGround);
        if (background)
        {
            background->GetBkColor2();
        }
        return 0;
    }

    DWORD WindowImplBase::GetBkColor() const
    {
        CControlUI* background = m_pm.FindControl(kWndBaseBackGround);
        if (background)
        {
            background->GetBkColor();
        }
        return 0;
    }

    void WindowImplBase::SetBKColor2(DWORD dwBkColor2)
    {
        CControlUI* background = m_pm.FindControl(kWndBaseBackGround);
        if (background)
        {
            background->SetBkImage(_T(""));
            background->SetBkColor2(dwBkColor2);
            background->NeedUpdate();
        }
    }

    void WindowImplBase::SetBKColor3(DWORD dwBkColor3)
    {
        CControlUI* background = m_pm.FindControl(kWndBaseBackGround);
        if (background)
        {
            background->SetBkImage(_T(""));
            background->SetBkColor3(dwBkColor3);
            background->NeedUpdate();
        }
    }

    void WindowImplBase::SetBkColor(DWORD dwBackColor)
    {
        CControlUI* background = m_pm.FindControl(kWndBaseBackGround);
        if (background)
        {
            background->SetBkImage(_T(""));
            background->SetBkColor(dwBackColor);
            background->NeedUpdate();
        }
    }

    void WindowImplBase::SetBkImage(CDuiString strBkImage)
    {
        CControlUI* background = m_pm.FindControl(kWndBaseBackGround);
        if (background)
        {
            background->SetBkImage(strBkImage.GetData());
        }
    }

    LPCTSTR WindowImplBase::GetBkImage()
    {
        CControlUI* background = m_pm.FindControl(kWndBaseBackGround);
        if (background)
        {
            return background->GetBkImage();
        }
        return _T("");
    }

    CControlUI * WindowImplBase::GetBkControlUI()
    {
        return m_pm.FindControl(kWndBaseBackGround);
    }

    void WindowImplBase::SetTrans(int nValue)
    {
        //m_pm.settr .SetTransparent(255 - nValue);
    }

}