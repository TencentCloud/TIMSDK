#include "StdAfx.h"

namespace DuiLib {
    IMPLEMENT_DUICONTROL(CControlUI)

        CControlUI::CControlUI()
        :m_pManager(NULL), 
        m_pParent(NULL), 
        m_bUpdateNeeded(true),
        m_bMenuUsed(false),
        m_bVisible(true), 
        m_bInternVisible(true),
        m_bFocused(false),
        m_bEnabled(true),
        m_bMouseEnabled(true),
        m_bKeyboardEnabled(true),
        m_bFloat(false),
        m_uFloatAlign(0),
        m_bSetPos(false),
        m_bDragEnabled(false),
        m_bDropEnabled(false),
        m_bResourceText(false),
        m_chShortcut('\0'),
        m_pTag(NULL),
        m_dwBackColor(0),
        m_dwBackColor2(0),
        m_dwBackColor3(0),
        m_dwForeColor(0),
        m_dwBorderColor(0),
        m_dwFocusBorderColor(0),
        m_bColorHSL(false),
        m_nBorderSize(0),
        m_nBorderStyle(PS_SOLID),
        m_nTooltipWidth(300),
        m_wCursor(0),
        m_instance(NULL)
    {
        m_cXY.cx = m_cXY.cy = 0;
        m_cxyFixed.cx = m_cxyFixed.cy = 0;
        m_cxyMin.cx = m_cxyMin.cy = 0;
        m_cxyMax.cx = m_cxyMax.cy = 9999;
        m_cxyBorderRound.cx = m_cxyBorderRound.cy = 0;

        ::ZeroMemory(&m_rcPadding, sizeof(RECT));
        ::ZeroMemory(&m_rcItem, sizeof(RECT));
        ::ZeroMemory(&m_rcPaint, sizeof(RECT));
        ::ZeroMemory(&m_rcBorderSize,sizeof(RECT));
        m_piFloatPercent.left = m_piFloatPercent.top = m_piFloatPercent.right = m_piFloatPercent.bottom = 0.0f;
    }

    CControlUI::~CControlUI()
    {
        if( OnDestroy ) OnDestroy(this);
        RemoveAllCustomAttribute();    
        if( m_pManager != NULL ) m_pManager->ReapObjects(this);
    }

    CDuiString CControlUI::GetName() const
    {
        return m_sName;
    }

    void CControlUI::SetName(LPCTSTR pstrName)
    {
        m_sName = pstrName;
    }

    LPVOID CControlUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_CONTROL) == 0 ) return this;
        return NULL;
    }

    LPCTSTR CControlUI::GetClass() const
    {
        return _T("ControlUI");
    }

    UINT CControlUI::GetControlFlags() const
    {
        return 0;
    }

    bool CControlUI::Activate()
    {
        if( !IsVisible() ) return false;
        if( !IsEnabled() ) return false;
        return true;
    }

    CPaintManagerUI* CControlUI::GetManager() const
    {
        return m_pManager;
    }

    void CControlUI::SetManager(CPaintManagerUI* pManager, CControlUI* pParent, bool bInit)
    {
        m_pManager = pManager;
        m_pParent = pParent;
        if( bInit && m_pParent ) Init();
    }

    CControlUI* CControlUI::GetParent() const
    {
        return m_pParent;
    }

    bool CControlUI::SetTimer(UINT nTimerID, UINT nElapse)
    {
        if(m_pManager == NULL) return false;

        return m_pManager->SetTimer(this, nTimerID, nElapse);
    }

    void CControlUI::KillTimer(UINT nTimerID)
    {
        if(m_pManager == NULL) return;

        m_pManager->KillTimer(this, nTimerID);
    }

    CDuiString CControlUI::GetText() const
    {
        if (!IsResourceText()) return m_sText;
        return CResourceManager::GetInstance()->GetText(m_sText);
    }

    void CControlUI::SetText(LPCTSTR pstrText)
    {
        if( m_sText == pstrText ) return;

        m_sText = pstrText;
        // 解析xml换行符
        m_sText.Replace(_T("{\\n}"), _T("\n"));
        Invalidate();
    }

    bool CControlUI::IsResourceText() const
    {
        return m_bResourceText;
    }

    void CControlUI::SetResourceText(bool bResource)
    {
        if( m_bResourceText == bResource ) return;
        m_bResourceText = bResource;
        Invalidate();
    }

    bool CControlUI::IsDragEnabled() const
    {
        return m_bDragEnabled;
    }

    void CControlUI::SetDragEnable(bool bDrag)
    {
        m_bDragEnabled = bDrag;
    }

    bool CControlUI::IsDropEnabled() const
    {
        return m_bDropEnabled;
    }

    void CControlUI::SetDropEnable(bool bDrop)
    {
        m_bDropEnabled = bDrop;
    }

    LPCTSTR CControlUI::GetGradient()
    {
        return m_sGradient;
    }

    void CControlUI::SetGradient(LPCTSTR pStrImage)
    {
        if( m_sGradient == pStrImage ) return;

        m_sGradient = pStrImage;
        Invalidate();
    }

    DWORD CControlUI::GetBkColor() const
    {
        return m_dwBackColor;
    }

    void CControlUI::SetBkColor(DWORD dwBackColor)
    {
        if( m_dwBackColor == dwBackColor ) return;

        m_dwBackColor = dwBackColor;
        Invalidate();
    }

    DWORD CControlUI::GetBkColor2() const
    {
        return m_dwBackColor2;
    }

    void CControlUI::SetBkColor2(DWORD dwBackColor)
    {
        if( m_dwBackColor2 == dwBackColor ) return;

        m_dwBackColor2 = dwBackColor;
        Invalidate();
    }

    DWORD CControlUI::GetBkColor3() const
    {
        return m_dwBackColor3;
    }

    void CControlUI::SetBkColor3(DWORD dwBackColor)
    {
        if( m_dwBackColor3 == dwBackColor ) return;

        m_dwBackColor3 = dwBackColor;
        Invalidate();
    }

    DWORD CControlUI::GetForeColor() const
    {
        return m_dwForeColor;
    }

    void CControlUI::SetForeColor(DWORD dwForeColor)
    {
        if( m_dwForeColor == dwForeColor ) return;

        m_dwForeColor = dwForeColor;
        Invalidate();
    }

    LPCTSTR CControlUI::GetBkImage()
    {
        return m_sBkImage;
    }

    void CControlUI::SetBkImage(LPCTSTR pStrImage)
    {
        if(m_pManager) m_pManager->RemoveImage(pStrImage);
        if( m_sBkImage == pStrImage ) return;

        m_sBkImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CControlUI::GetForeImage() const
    {
        return m_sForeImage;
    }

    void CControlUI::SetForeImage(LPCTSTR pStrImage)
    {
        if( m_sForeImage == pStrImage ) return;

        m_sForeImage = pStrImage;
        Invalidate();
    }

    DWORD CControlUI::GetBorderColor() const
    {
        return m_dwBorderColor;
    }

    void CControlUI::SetBorderColor(DWORD dwBorderColor)
    {
        if( m_dwBorderColor == dwBorderColor ) return;

        m_dwBorderColor = dwBorderColor;
        Invalidate();
    }

    DWORD CControlUI::GetFocusBorderColor() const
    {
        return m_dwFocusBorderColor;
    }

    void CControlUI::SetFocusBorderColor(DWORD dwBorderColor)
    {
        if( m_dwFocusBorderColor == dwBorderColor ) return;

        m_dwFocusBorderColor = dwBorderColor;
        Invalidate();
    }

    bool CControlUI::IsColorHSL() const
    {
        return m_bColorHSL;
    }

    void CControlUI::SetColorHSL(bool bColorHSL)
    {
        if( m_bColorHSL == bColorHSL ) return;

        m_bColorHSL = bColorHSL;
        Invalidate();
    }

    int CControlUI::GetBorderSize() const
    {
        if(m_pManager != NULL) return m_pManager->GetDPIObj()->Scale(m_nBorderSize);
        return m_nBorderSize;
    }

    void CControlUI::SetBorderSize(int nSize)
    {
        if( m_nBorderSize == nSize ) return;

        m_nBorderSize = nSize;
        Invalidate();
    }

    void CControlUI::SetBorderSize( RECT rc )
    {
        m_rcBorderSize = rc;
        Invalidate();
    }

    SIZE CControlUI::GetBorderRound() const
    {
        if(m_pManager != NULL) return m_pManager->GetDPIObj()->Scale(m_cxyBorderRound);
        return m_cxyBorderRound;
    }

    void CControlUI::SetBorderRound(SIZE cxyRound)
    {
        m_cxyBorderRound = cxyRound;
        Invalidate();
    }

    bool CControlUI::DrawImage(HDC hDC, LPCTSTR pStrImage, LPCTSTR pStrModify)
    {
        return CRenderEngine::DrawImageString(hDC, m_pManager, m_rcItem, m_rcPaint, pStrImage, pStrModify, m_instance);
    }

    const RECT& CControlUI::GetPos() const
    {
        return m_rcItem;
    }

    RECT CControlUI::GetRelativePos() const
    {
        CControlUI* pParent = GetParent();
        if( pParent != NULL ) {
            RECT rcParentPos = pParent->GetPos();
            CDuiRect rcRelativePos(m_rcItem);
            rcRelativePos.Offset(-rcParentPos.left, -rcParentPos.top);
            return rcRelativePos;
        }
        else {
            return CDuiRect(0, 0, 0, 0);
        }
    }

    RECT CControlUI::GetClientPos() const 
    {
        return m_rcItem;
    }
    void CControlUI::SetPos(RECT rc, bool bNeedInvalidate)
    {
        if( rc.right < rc.left ) rc.right = rc.left;
        if( rc.bottom < rc.top ) rc.bottom = rc.top;

        CDuiRect invalidateRc = m_rcItem;
        if( ::IsRectEmpty(&invalidateRc) ) invalidateRc = rc;

        m_rcItem = rc;
        if( m_pManager == NULL ) return;

        if( !m_bSetPos ) {
            m_bSetPos = true;
            if( OnSize ) OnSize(this);
            m_bSetPos = false;
        }

        m_bUpdateNeeded = false;

        if( bNeedInvalidate && IsVisible() ) {
            invalidateRc.Join(m_rcItem);
            CControlUI* pParent = this;
            RECT rcTemp;
            RECT rcParent;
            while( pParent = pParent->GetParent() ) {
                if( !pParent->IsVisible() ) return;
                rcTemp = invalidateRc;
                rcParent = pParent->GetPos();
                if( !::IntersectRect(&invalidateRc, &rcTemp, &rcParent) ) return;
            }
            m_pManager->Invalidate(invalidateRc);
        }
    }

    void CControlUI::Move(SIZE szOffset, bool bNeedInvalidate)
    {
        m_cXY.cx += szOffset.cx;
        m_cXY.cy += szOffset.cy;
        NeedParentUpdate();
    }

    int CControlUI::GetWidth() const
    {
        return m_rcItem.right - m_rcItem.left;
    }

    int CControlUI::GetHeight() const
    {
        return m_rcItem.bottom - m_rcItem.top;
    }

    int CControlUI::GetX() const
    {
        return m_rcItem.left;
    }

    int CControlUI::GetY() const
    {
        return m_rcItem.top;
    }

    RECT CControlUI::GetPadding() const
    {
        if(m_pManager != NULL) return m_pManager->GetDPIObj()->Scale(m_rcPadding);
        return m_rcPadding;
    }

    void CControlUI::SetPadding(RECT rcPadding)
    {
        m_rcPadding = rcPadding;
        NeedParentUpdate();
    }

    SIZE CControlUI::GetFixedXY() const
    {
        if(m_pManager != NULL) return m_pManager->GetDPIObj()->Scale(m_cXY);
        return m_cXY;
    }

    void CControlUI::SetFixedXY(SIZE szXY)
    {
        m_cXY.cx = szXY.cx;
        m_cXY.cy = szXY.cy;
        NeedParentUpdate();
    }

    int CControlUI::GetFixedWidth() const
    {
        if (m_pManager != NULL) {
            return m_pManager->GetDPIObj()->Scale(m_cxyFixed.cx);
        }

        return m_cxyFixed.cx;
    }

    void CControlUI::SetFixedWidth(int cx)
    {
        if( cx < 0 ) return; 
        m_cxyFixed.cx = cx;
        NeedParentUpdate();
    }

    int CControlUI::GetFixedHeight() const
    {
        if (m_pManager != NULL) {
            return m_pManager->GetDPIObj()->Scale(m_cxyFixed.cy);
        }

        return m_cxyFixed.cy;
    }

    void CControlUI::SetFixedHeight(int cy)
    {
        if( cy < 0 ) return; 
        m_cxyFixed.cy = cy;
        NeedParentUpdate();
    }

    int CControlUI::GetMinWidth() const
    {
        if (m_pManager != NULL) {
            return m_pManager->GetDPIObj()->Scale(m_cxyMin.cx);
        }
        return m_cxyMin.cx;
    }

    void CControlUI::SetMinWidth(int cx)
    {
        if( m_cxyMin.cx == cx ) return;

        if( cx < 0 ) return; 
        m_cxyMin.cx = cx;
        NeedParentUpdate();
    }

    int CControlUI::GetMaxWidth() const
    {
        if (m_pManager != NULL) {
            return m_pManager->GetDPIObj()->Scale(m_cxyMax.cx);
        }
        return m_cxyMax.cx;
    }

    void CControlUI::SetMaxWidth(int cx)
    {
        if( m_cxyMax.cx == cx ) return;

        if( cx < 0 ) return; 
        m_cxyMax.cx = cx;
        NeedParentUpdate();
    }

    int CControlUI::GetMinHeight() const
    {
        if (m_pManager != NULL) {
            return m_pManager->GetDPIObj()->Scale(m_cxyMin.cy);
        }

        return m_cxyMin.cy;
    }

    void CControlUI::SetMinHeight(int cy)
    {
        if( m_cxyMin.cy == cy ) return;

        if( cy < 0 ) return; 
        m_cxyMin.cy = cy;
        NeedParentUpdate();
    }

    int CControlUI::GetMaxHeight() const
    {
        if (m_pManager != NULL) {
            return m_pManager->GetDPIObj()->Scale(m_cxyMax.cy);
        }

        return m_cxyMax.cy;
    }

    void CControlUI::SetMaxHeight(int cy)
    {
        if( m_cxyMax.cy == cy ) return;

        if( cy < 0 ) return; 
        m_cxyMax.cy = cy;
        NeedParentUpdate();
    }

    TPercentInfo CControlUI::GetFloatPercent() const
    {
        return m_piFloatPercent;
    }

    void CControlUI::SetFloatPercent(TPercentInfo piFloatPercent)
    {
        m_piFloatPercent = piFloatPercent;
        NeedParentUpdate();
    }

    void CControlUI::SetFloatAlign(UINT uAlign)
    {
        m_uFloatAlign = uAlign;
        NeedParentUpdate();
    }

    UINT CControlUI::GetFloatAlign() const
    {
        return m_uFloatAlign;
    }

    CDuiString CControlUI::GetToolTip() const
    {
        if (!IsResourceText()) return m_sToolTip;
        return CResourceManager::GetInstance()->GetText(m_sToolTip);
    }

    void CControlUI::SetToolTip(LPCTSTR pstrText)
    {
        CDuiString strTemp(pstrText);
        strTemp.Replace(_T("<n>"),_T("\r\n"));
        m_sToolTip = strTemp;
    }

    void CControlUI::SetToolTipWidth( int nWidth )
    {
        m_nTooltipWidth = nWidth;
    }

    int CControlUI::GetToolTipWidth( void )
    {
        if(m_pManager != NULL) return m_pManager->GetDPIObj()->Scale(m_nTooltipWidth);
        return m_nTooltipWidth;
    }

    WORD CControlUI::GetCursor()
    {
        return m_wCursor;
    }

    void CControlUI::SetCursor(WORD wCursor)
    {
        m_wCursor = wCursor;
        Invalidate();
    }

    TCHAR CControlUI::GetShortcut() const
    {
        return m_chShortcut;
    }

    void CControlUI::SetShortcut(TCHAR ch)
    {
        m_chShortcut = ch;
    }

    bool CControlUI::IsContextMenuUsed() const
    {
        return m_bMenuUsed;
    }

    void CControlUI::SetContextMenuUsed(bool bMenuUsed)
    {
        m_bMenuUsed = bMenuUsed;
    }

    const CDuiString& CControlUI::GetUserData()
    {
        return m_sUserData;
    }

    void CControlUI::SetUserData(LPCTSTR pstrText)
    {
        m_sUserData = pstrText;
    }

    UINT_PTR CControlUI::GetTag() const
    {
        return m_pTag;
    }

    void CControlUI::SetTag(UINT_PTR pTag)
    {
        m_pTag = pTag;
    }

    bool CControlUI::IsVisible() const
    {

        return m_bVisible && m_bInternVisible;
    }

    void CControlUI::SetVisible(bool bVisible)
    {
        if( m_bVisible == bVisible ) return;

        bool v = IsVisible();
        m_bVisible = bVisible;
        if( m_bFocused ) m_bFocused = false;
        if (!bVisible && m_pManager && m_pManager->GetFocus() == this) {
            m_pManager->SetFocus(NULL) ;
        }
        if( IsVisible() != v ) {
            NeedParentUpdate();
        }
    }

    void CControlUI::SetInternVisible(bool bVisible)
    {
        m_bInternVisible = bVisible;
        if (!bVisible && m_pManager && m_pManager->GetFocus() == this) {
            m_pManager->SetFocus(NULL) ;
        }
    }

    bool CControlUI::IsEnabled() const
    {
        return m_bEnabled;
    }

    void CControlUI::SetEnabled(bool bEnabled)
    {
        if( m_bEnabled == bEnabled ) return;

        m_bEnabled = bEnabled;
        Invalidate();
    }

    bool CControlUI::IsMouseEnabled() const
    {
        return m_bMouseEnabled;
    }

    void CControlUI::SetMouseEnabled(bool bEnabled)
    {
        m_bMouseEnabled = bEnabled;
    }

    bool CControlUI::IsKeyboardEnabled() const
    {
        return m_bKeyboardEnabled ;
    }
    void CControlUI::SetKeyboardEnabled(bool bEnabled)
    {
        m_bKeyboardEnabled = bEnabled ; 
    }

    bool CControlUI::IsFocused() const
    {
        return m_bFocused;
    }

    void CControlUI::SetFocus()
    {
        if( m_pManager != NULL ) m_pManager->SetFocus(this);
    }

    bool CControlUI::IsFloat() const
    {
        return m_bFloat;
    }

    void CControlUI::SetFloat(bool bFloat)
    {
        if( m_bFloat == bFloat ) return;

        m_bFloat = bFloat;
        NeedParentUpdate();
    }

    CControlUI* CControlUI::FindControl(FINDCONTROLPROC Proc, LPVOID pData, UINT uFlags)
    {
        if( (uFlags & UIFIND_VISIBLE) != 0 && !IsVisible() ) return NULL;
        if( (uFlags & UIFIND_ENABLED) != 0 && !IsEnabled() ) return NULL;
        if( (uFlags & UIFIND_HITTEST) != 0 && (!m_bMouseEnabled || !::PtInRect(&m_rcItem, * static_cast<LPPOINT>(pData))) ) return NULL;
        return Proc(this, pData);
    }

    void CControlUI::Invalidate()
    {
        if( !IsVisible() ) return;

        RECT invalidateRc = m_rcItem;

        CControlUI* pParent = this;
        RECT rcTemp;
        RECT rcParent;
        while( pParent = pParent->GetParent() )
        {
            rcTemp = invalidateRc;
            rcParent = pParent->GetPos();
            if( !::IntersectRect(&invalidateRc, &rcTemp, &rcParent) ) 
            {
                return;
            }
        }

        if( m_pManager != NULL ) m_pManager->Invalidate(invalidateRc);
    }

    bool CControlUI::IsUpdateNeeded() const
    {
        return m_bUpdateNeeded;
    }

    void CControlUI::NeedUpdate()
    {
        if( !IsVisible() ) return;
        m_bUpdateNeeded = true;
        Invalidate();

        if( m_pManager != NULL ) m_pManager->NeedUpdate();
    }

    void CControlUI::NeedParentUpdate()
    {
        if( GetParent() ) {
            GetParent()->NeedUpdate();
            GetParent()->Invalidate();
        }
        else {
            NeedUpdate();
        }

        if( m_pManager != NULL ) m_pManager->NeedUpdate();
    }

    DWORD CControlUI::GetAdjustColor(DWORD dwColor)
    {
        if( !m_bColorHSL ) return dwColor;
        short H, S, L;
        CPaintManagerUI::GetHSL(&H, &S, &L);
        return CRenderEngine::AdjustColor(dwColor, H, S, L);
    }

    void CControlUI::Init()
    {
        DoInit();
        if( OnInit ) OnInit(this);
    }

    void CControlUI::DoInit()
    {

    }

    void CControlUI::Event(TEventUI& event)
    {
        if( OnEvent(&event) ) DoEvent(event);
    }

    void CControlUI::DoEvent(TEventUI& event)
    {
        if( event.Type == UIEVENT_SETCURSOR ) {
            if( GetCursor() ) {
                ::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(GetCursor())));
            }
            else {
                ::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(IDC_ARROW)));
            }
            return;
        }

        if( event.Type == UIEVENT_SETFOCUS ) 
        {
            m_bFocused = true;
            Invalidate();
            return;
        }
        if( event.Type == UIEVENT_KILLFOCUS ) 
        {
            m_bFocused = false;
            Invalidate();
            return;
        }
        if( event.Type == UIEVENT_TIMER )
        {
            m_pManager->SendNotify(this, DUI_MSGTYPE_TIMER, event.wParam, event.lParam);
            return;
        }
        if( event.Type == UIEVENT_CONTEXTMENU )
        {
            if( IsContextMenuUsed() ) {
                m_pManager->SendNotify(this, DUI_MSGTYPE_MENU, event.wParam, event.lParam);
                return;
            }
        }

        if( m_pParent != NULL ) m_pParent->DoEvent(event);
    }


    void CControlUI::SetVirtualWnd(LPCTSTR pstrValue)
    {
        m_sVirtualWnd = pstrValue;
        m_pManager->UsedVirtualWnd(true);
    }

    CDuiString CControlUI::GetVirtualWnd() const
    {
        CDuiString str;
        if( !m_sVirtualWnd.IsEmpty() ){
            str = m_sVirtualWnd;
        }
        else{
            CControlUI* pParent = GetParent();
            if( pParent != NULL){
                str = pParent->GetVirtualWnd();
            }
            else{
                str = _T("");
            }
        }
        return str;
    }

    void CControlUI::AddCustomAttribute(LPCTSTR pstrName, LPCTSTR pstrAttr)
    {
        if( pstrName == NULL || pstrName[0] == _T('\0') || pstrAttr == NULL || pstrAttr[0] == _T('\0') ) return;
        CDuiString* pCostomAttr = new CDuiString(pstrAttr);
        if (pCostomAttr != NULL) {
            if (m_mCustomAttrHash.Find(pstrName) == NULL)
                m_mCustomAttrHash.Set(pstrName, (LPVOID)pCostomAttr);
            else
                delete pCostomAttr;
        }
    }

    LPCTSTR CControlUI::GetCustomAttribute(LPCTSTR pstrName) const
    {
        if( pstrName == NULL || pstrName[0] == _T('\0') ) return NULL;
        CDuiString* pCostomAttr = static_cast<CDuiString*>(m_mCustomAttrHash.Find(pstrName));
        if( pCostomAttr ) return pCostomAttr->GetData();
        return NULL;
    }

    bool CControlUI::RemoveCustomAttribute(LPCTSTR pstrName)
    {
        if( pstrName == NULL || pstrName[0] == _T('\0') ) return NULL;
        CDuiString* pCostomAttr = static_cast<CDuiString*>(m_mCustomAttrHash.Find(pstrName));
        if( !pCostomAttr ) return false;

        delete pCostomAttr;
        return m_mCustomAttrHash.Remove(pstrName);
    }

    void CControlUI::RemoveAllCustomAttribute()
    {
        CDuiString* pCostomAttr;
        for( int i = 0; i< m_mCustomAttrHash.GetSize(); i++ ) {
            if(LPCTSTR key = m_mCustomAttrHash.GetAt(i)) {
                pCostomAttr = static_cast<CDuiString*>(m_mCustomAttrHash.Find(key));
                delete pCostomAttr;
            }
        }
        m_mCustomAttrHash.Resize();
    }

    void CControlUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        // 是否样式表
        if(m_pManager != NULL) {
            LPCTSTR pStyle = m_pManager->GetStyle(pstrValue);
            if( pStyle != NULL) {
                ApplyAttributeList(pStyle);
                return;
            }
        }
        if( _tcsicmp(pstrName, _T("pos")) == 0 ) {
            RECT rcPos = { 0 };
            LPTSTR pstr = NULL;
            rcPos.left = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
            rcPos.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
            rcPos.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
            rcPos.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
            SIZE szXY = {rcPos.left >= 0 ? rcPos.left : rcPos.right, rcPos.top >= 0 ? rcPos.top : rcPos.bottom};
            SetFixedXY(szXY);
            SetFixedWidth(rcPos.right - rcPos.left);
            SetFixedHeight(rcPos.bottom - rcPos.top);
        }
        else if( _tcsicmp(pstrName, _T("float")) == 0 ) {
            CDuiString nValue = pstrValue;
            // 动态计算相对比例
            if(nValue.Find(',') < 0) {
                SetFloat(_tcsicmp(pstrValue, _T("true")) == 0);
            }
            else {
                TPercentInfo piFloatPercent = { 0 };
                LPTSTR pstr = NULL;
                piFloatPercent.left = _tcstod(pstrValue, &pstr);  ASSERT(pstr);
                piFloatPercent.top = _tcstod(pstr + 1, &pstr);    ASSERT(pstr);
                piFloatPercent.right = _tcstod(pstr + 1, &pstr);  ASSERT(pstr);
                piFloatPercent.bottom = _tcstod(pstr + 1, &pstr); ASSERT(pstr);
                SetFloatPercent(piFloatPercent);
                SetFloat(true);
            }
        }
        else if( _tcsicmp(pstrName, _T("floatalign")) == 0) {
            UINT uAlign = GetFloatAlign();
            // 解析文字属性
            while( *pstrValue != _T('\0') ) {
                CDuiString sValue;
                while( *pstrValue == _T(',') || *pstrValue == _T(' ') ) pstrValue = ::CharNext(pstrValue);

                while( *pstrValue != _T('\0') && *pstrValue != _T(',') && *pstrValue != _T(' ') ) {
                    LPTSTR pstrTemp = ::CharNext(pstrValue);
                    while( pstrValue < pstrTemp) {
                        sValue += *pstrValue++;
                    }
                }
                if(sValue.CompareNoCase(_T("null")) == 0) {
                    uAlign = 0;
                }
                if( sValue.CompareNoCase(_T("left")) == 0 ) {
                    uAlign &= ~(DT_CENTER | DT_RIGHT);
                    uAlign |= DT_LEFT;
                }
                else if( sValue.CompareNoCase(_T("center")) == 0 ) {
                    uAlign &= ~(DT_LEFT | DT_RIGHT);
                    uAlign |= DT_CENTER;
                }
                else if( sValue.CompareNoCase(_T("right")) == 0 ) {
                    uAlign &= ~(DT_LEFT | DT_CENTER);
                    uAlign |= DT_RIGHT;
                }
                else if( sValue.CompareNoCase(_T("top")) == 0 ) {
                    uAlign &= ~(DT_BOTTOM | DT_VCENTER);
                    uAlign |= DT_TOP;
                }
                else if( sValue.CompareNoCase(_T("vcenter")) == 0 ) {
                    uAlign &= ~(DT_TOP | DT_BOTTOM);
                    uAlign |= DT_VCENTER;
                }
                else if( sValue.CompareNoCase(_T("bottom")) == 0 ) {
                    uAlign &= ~(DT_TOP | DT_VCENTER);
                    uAlign |= DT_BOTTOM;
                }
            }
            SetFloatAlign(uAlign);
        }
        else if( _tcsicmp(pstrName, _T("padding")) == 0 ) {
            RECT rcPadding = { 0 };
            LPTSTR pstr = NULL;
            rcPadding.left = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
            rcPadding.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
            rcPadding.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
            rcPadding.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
            SetPadding(rcPadding);
        }
        else if( _tcsicmp(pstrName, _T("gradient")) == 0 ) SetGradient(pstrValue);
        else if( _tcsicmp(pstrName, _T("bkcolor")) == 0 || _tcsicmp(pstrName, _T("bkcolor1")) == 0 ) {
            while( *pstrValue > _T('\0') && *pstrValue <= _T(' ') ) pstrValue = ::CharNext(pstrValue);
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetBkColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("bkcolor2")) == 0 ) {
            while( *pstrValue > _T('\0') && *pstrValue <= _T(' ') ) pstrValue = ::CharNext(pstrValue);
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetBkColor2(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("bkcolor3")) == 0 ) {
            while( *pstrValue > _T('\0') && *pstrValue <= _T(' ') ) pstrValue = ::CharNext(pstrValue);
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetBkColor3(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("forecolor")) == 0 ) {
            while( *pstrValue > _T('\0') && *pstrValue <= _T(' ') ) pstrValue = ::CharNext(pstrValue);
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetForeColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("bordercolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetBorderColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("focusbordercolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetFocusBorderColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("colorhsl")) == 0 ) SetColorHSL(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("bordersize")) == 0 ) {
            CDuiString nValue = pstrValue;
            if(nValue.Find(',') < 0) {
                SetBorderSize(_ttoi(pstrValue));
                RECT rcPadding = {0};
                SetBorderSize(rcPadding);
            }
            else {
                RECT rcPadding = { 0 };
                LPTSTR pstr = NULL;
                rcPadding.left = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);
                rcPadding.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
                rcPadding.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);
                rcPadding.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);
                SetBorderSize(rcPadding);
            }
        }
        else if( _tcsicmp(pstrName, _T("leftbordersize")) == 0 ) SetLeftBorderSize(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("topbordersize")) == 0 ) SetTopBorderSize(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("rightbordersize")) == 0 ) SetRightBorderSize(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("bottombordersize")) == 0 ) SetBottomBorderSize(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("borderstyle")) == 0 ) SetBorderStyle(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("borderround")) == 0 ) {
            SIZE cxyRound = { 0 };
            LPTSTR pstr = NULL;
            cxyRound.cx = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
            cxyRound.cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
            SetBorderRound(cxyRound);
        }
        else if( _tcsicmp(pstrName, _T("bkimage")) == 0 ) SetBkImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("foreimage")) == 0 ) SetForeImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("width")) == 0 ) SetFixedWidth(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("height")) == 0 ) SetFixedHeight(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("minwidth")) == 0 ) SetMinWidth(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("minheight")) == 0 ) SetMinHeight(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("maxwidth")) == 0 ) SetMaxWidth(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("maxheight")) == 0 ) SetMaxHeight(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("name")) == 0 ) SetName(pstrValue);
        else if( _tcsicmp(pstrName, _T("drag")) == 0 ) SetDragEnable(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("drop")) == 0 ) SetDropEnable(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("resourcetext")) == 0 ) SetResourceText(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("text")) == 0 ) SetText(pstrValue);
        else if( _tcsicmp(pstrName, _T("tooltip")) == 0 ) SetToolTip(pstrValue);
        else if( _tcsicmp(pstrName, _T("userdata")) == 0 ) SetUserData(pstrValue);
        else if( _tcsicmp(pstrName, _T("enabled")) == 0 ) SetEnabled(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("mouse")) == 0 ) SetMouseEnabled(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("keyboard")) == 0 ) SetKeyboardEnabled(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("visible")) == 0 ) SetVisible(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("float")) == 0 ) SetFloat(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("shortcut")) == 0 ) SetShortcut(pstrValue[0]);
        else if( _tcsicmp(pstrName, _T("menu")) == 0 ) SetContextMenuUsed(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("cursor")) == 0 && pstrValue) {
            if( _tcsicmp(pstrValue, _T("arrow")) == 0 )            SetCursor(DUI_ARROW);
            else if( _tcsicmp(pstrValue, _T("ibeam")) == 0 )    SetCursor(DUI_IBEAM);
            else if( _tcsicmp(pstrValue, _T("wait")) == 0 )        SetCursor(DUI_WAIT);
            else if( _tcsicmp(pstrValue, _T("cross")) == 0 )    SetCursor(DUI_CROSS);
            else if( _tcsicmp(pstrValue, _T("uparrow")) == 0 )    SetCursor(DUI_UPARROW);
            else if( _tcsicmp(pstrValue, _T("size")) == 0 )        SetCursor(DUI_SIZE);
            else if( _tcsicmp(pstrValue, _T("icon")) == 0 )        SetCursor(DUI_ICON);
            else if( _tcsicmp(pstrValue, _T("sizenwse")) == 0 )    SetCursor(DUI_SIZENWSE);
            else if( _tcsicmp(pstrValue, _T("sizenesw")) == 0 )    SetCursor(DUI_SIZENESW);
            else if( _tcsicmp(pstrValue, _T("sizewe")) == 0 )    SetCursor(DUI_SIZEWE);
            else if( _tcsicmp(pstrValue, _T("sizens")) == 0 )    SetCursor(DUI_SIZENS);
            else if( _tcsicmp(pstrValue, _T("sizeall")) == 0 )    SetCursor(DUI_SIZEALL);
            else if( _tcsicmp(pstrValue, _T("no")) == 0 )        SetCursor(DUI_NO);
            else if( _tcsicmp(pstrValue, _T("hand")) == 0 )        SetCursor(DUI_HAND);
        }
        else if( _tcsicmp(pstrName, _T("virtualwnd")) == 0 ) SetVirtualWnd(pstrValue);
        else if( _tcsicmp(pstrName, _T("innerstyle")) == 0 ) {
            CDuiString sXmlData = pstrValue;
            sXmlData.Replace(_T("&quot;"), _T("\""));
            LPCTSTR pstrList = sXmlData.GetData();
            CDuiString sItem;
            CDuiString sValue;
            while( *pstrList != _T('\0') ) {
                sItem.Empty();
                sValue.Empty();
                while( *pstrList != _T('\0') && *pstrList != _T('=') ) {
                    LPTSTR pstrTemp = ::CharNext(pstrList);
                    while( pstrList < pstrTemp) {
                        sItem += *pstrList++;
                    }
                }
                ASSERT( *pstrList == _T('=') );
                if( *pstrList++ != _T('=') ) return;
                ASSERT( *pstrList == _T('\"') );
                if( *pstrList++ != _T('\"') ) return;
                while( *pstrList != _T('\0') && *pstrList != _T('\"') ) {
                    LPTSTR pstrTemp = ::CharNext(pstrList);
                    while( pstrList < pstrTemp) {
                        sValue += *pstrList++;
                    }
                }
                ASSERT( *pstrList == _T('\"') );
                if( *pstrList++ != _T('\"') ) return;
                SetAttribute(sItem, sValue);
                if( *pstrList++ != _T(' ') && *pstrList++ != _T(',') ) return;
            }
        }
        else {
            AddCustomAttribute(pstrName, pstrValue);
        }
    }

    CControlUI* CControlUI::ApplyAttributeList(LPCTSTR pstrValue)
    {
        // 解析样式表
        if(m_pManager != NULL) {
            LPCTSTR pStyle = m_pManager->GetStyle(pstrValue);
            if( pStyle != NULL) {
                return ApplyAttributeList(pStyle);
            }
        }
        CDuiString sXmlData = pstrValue;
        sXmlData.Replace(_T("&quot;"), _T("\""));
        LPCTSTR pstrList = sXmlData.GetData();
        // 解析样式属性
        CDuiString sItem;
        CDuiString sValue;
        while( *pstrList != _T('\0') ) {
            sItem.Empty();
            sValue.Empty();
            while( *pstrList != _T('\0') && *pstrList != _T('=') ) {
                LPTSTR pstrTemp = ::CharNext(pstrList);
                while( pstrList < pstrTemp) {
                    sItem += *pstrList++;
                }
            }
            ASSERT( *pstrList == _T('=') );
            if( *pstrList++ != _T('=') ) return this;
            ASSERT( *pstrList == _T('\"') );
            if( *pstrList++ != _T('\"') ) return this;
            while( *pstrList != _T('\0') && *pstrList != _T('\"') ) {
                LPTSTR pstrTemp = ::CharNext(pstrList);
                while( pstrList < pstrTemp) {
                    sValue += *pstrList++;
                }
            }
            ASSERT( *pstrList == _T('\"') );
            if( *pstrList++ != _T('\"') ) return this;
            SetAttribute(sItem, sValue);
            if( *pstrList++ != _T(' ') && *pstrList++ != _T(',') ) return this;
        }
        return this;
    }

    SIZE CControlUI::EstimateSize(SIZE szAvailable)
    {
        if(m_pManager != NULL)
            return m_pManager->GetDPIObj()->Scale(m_cxyFixed);
        return m_cxyFixed;
    }

    bool CControlUI::Paint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl)
    {
        if (pStopControl == this) return false;
        if( !::IntersectRect(&m_rcPaint, &rcPaint, &m_rcItem) ) return true;
        //if( OnPaint ) {
        //    if( !OnPaint(this) ) return true;
        //}
        if (!DoPaint(hDC, m_rcPaint, pStopControl)) return false;
        return true;
    }

    bool CControlUI::DoPaint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl)
    {
        // 绘制循序：背景颜色->背景图->状态图->文本->边框
        SIZE cxyBorderRound;
        RECT rcBorderSize;
        if (m_pManager) {
            cxyBorderRound = GetManager()->GetDPIObj()->Scale(m_cxyBorderRound);
            rcBorderSize = GetManager()->GetDPIObj()->Scale(m_rcBorderSize);
        }
        else {
            cxyBorderRound = m_cxyBorderRound;
            rcBorderSize = m_rcBorderSize;
        }

        if( cxyBorderRound.cx > 0 || cxyBorderRound.cy > 0 ) {
            CRenderClip roundClip;
            CRenderClip::GenerateRoundClip(hDC, m_rcPaint,  m_rcItem, cxyBorderRound.cx, cxyBorderRound.cy, roundClip);
            PaintBkColor(hDC);
            PaintBkImage(hDC);
            PaintStatusImage(hDC);
            PaintForeColor(hDC);
            PaintForeImage(hDC);
            PaintText(hDC);
            PaintBorder(hDC);
        }
        else {
            PaintBkColor(hDC);
            PaintBkImage(hDC);
            PaintStatusImage(hDC);
            PaintForeColor(hDC);
            PaintForeImage(hDC);
            PaintText(hDC);
            PaintBorder(hDC);
        }
        return true;
    }

    void CControlUI::PaintBkColor(HDC hDC)
    {
        if( m_dwBackColor != 0 ) {
            bool bVer = (m_sGradient.CompareNoCase(_T("hor")) != 0);
            if( m_dwBackColor2 != 0 ) {
                if( m_dwBackColor3 != 0 ) {
                    RECT rc = m_rcItem;
                    rc.bottom = (rc.bottom + rc.top) / 2;
                    CRenderEngine::DrawGradient(hDC, rc, GetAdjustColor(m_dwBackColor), GetAdjustColor(m_dwBackColor2), bVer, 8);
                    rc.top = rc.bottom;
                    rc.bottom = m_rcItem.bottom;
                    CRenderEngine::DrawGradient(hDC, rc, GetAdjustColor(m_dwBackColor2), GetAdjustColor(m_dwBackColor3), bVer, 8);
                }
                else {
                    CRenderEngine::DrawGradient(hDC, m_rcItem, GetAdjustColor(m_dwBackColor), GetAdjustColor(m_dwBackColor2), bVer, 16);
                }
            }
            else if( m_dwBackColor >= 0xFF000000 ) CRenderEngine::DrawColor(hDC, m_rcPaint, GetAdjustColor(m_dwBackColor));
            else CRenderEngine::DrawColor(hDC, m_rcItem, GetAdjustColor(m_dwBackColor));
        }
    }

    void CControlUI::PaintBkImage(HDC hDC)
    {
        if( m_sBkImage.IsEmpty() ) return;
        if( !DrawImage(hDC, (LPCTSTR)m_sBkImage) ) {}
    }

    void CControlUI::PaintStatusImage(HDC hDC)
    {
        return;
    }

    void CControlUI::PaintForeColor(HDC hDC)
    {
        CRenderEngine::DrawColor(hDC, m_rcItem, GetAdjustColor(m_dwForeColor));
    }

    void CControlUI::PaintForeImage(HDC hDC)
    {
        if( m_sForeImage.IsEmpty() ) return;
        DrawImage(hDC, (LPCTSTR)m_sForeImage);
    }

    void CControlUI::PaintText(HDC hDC)
    {
        return;
    }

    void CControlUI::PaintBorder(HDC hDC)
    {
        int nBorderSize;
        SIZE cxyBorderRound;
        RECT rcBorderSize;
        if (m_pManager) {
            nBorderSize = GetManager()->GetDPIObj()->Scale(m_nBorderSize);
            cxyBorderRound = GetManager()->GetDPIObj()->Scale(m_cxyBorderRound);
            rcBorderSize = GetManager()->GetDPIObj()->Scale(m_rcBorderSize);
        }
        else {
            nBorderSize = m_nBorderSize;
            cxyBorderRound = m_cxyBorderRound;
            rcBorderSize = m_rcBorderSize;
        }

        if(m_dwBorderColor != 0 || m_dwFocusBorderColor != 0) {
            //画圆角边框
            if(nBorderSize > 0 && ( cxyBorderRound.cx > 0 || cxyBorderRound.cy > 0 )) {
                if (IsFocused() && m_dwFocusBorderColor != 0)
                    CRenderEngine::DrawRoundRect(hDC, m_rcItem, nBorderSize, cxyBorderRound.cx, cxyBorderRound.cy, GetAdjustColor(m_dwFocusBorderColor), m_nBorderStyle);
                else
                    CRenderEngine::DrawRoundRect(hDC, m_rcItem, nBorderSize, cxyBorderRound.cx, cxyBorderRound.cy, GetAdjustColor(m_dwBorderColor), m_nBorderStyle);
            }
            else {
                if (IsFocused() && m_dwFocusBorderColor != 0 && nBorderSize > 0) { 
                    CRenderEngine::DrawRect(hDC, m_rcItem, nBorderSize, GetAdjustColor(m_dwFocusBorderColor), m_nBorderStyle);
                }
                else if(rcBorderSize.left > 0 || rcBorderSize.top > 0 || rcBorderSize.right > 0 || rcBorderSize.bottom > 0) {
                    RECT rcBorder;

                    if(rcBorderSize.left > 0){
                        rcBorder        = m_rcItem;
                        rcBorder.right    = rcBorder.left;
                        CRenderEngine::DrawLine(hDC,rcBorder,rcBorderSize.left,GetAdjustColor(m_dwBorderColor),m_nBorderStyle);
                    }
                    if(rcBorderSize.top > 0){
                        rcBorder        = m_rcItem;
                        rcBorder.bottom    = rcBorder.top;
                        CRenderEngine::DrawLine(hDC,rcBorder,rcBorderSize.top,GetAdjustColor(m_dwBorderColor),m_nBorderStyle);
                    }
                    if(rcBorderSize.right > 0){
                        rcBorder        = m_rcItem;
                        rcBorder.right -= 1;
                        rcBorder.left    = rcBorder.right;
                        CRenderEngine::DrawLine(hDC,rcBorder,rcBorderSize.right,GetAdjustColor(m_dwBorderColor),m_nBorderStyle);
                    }
                    if(rcBorderSize.bottom > 0){
                        rcBorder        = m_rcItem;
                        rcBorder.bottom -= 1;
                        rcBorder.top    = rcBorder.bottom;
                        CRenderEngine::DrawLine(hDC,rcBorder,rcBorderSize.bottom,GetAdjustColor(m_dwBorderColor),m_nBorderStyle);
                    }
                }
                else if(nBorderSize > 0) {
                    CRenderEngine::DrawRect(hDC, m_rcItem, nBorderSize, GetAdjustColor(m_dwBorderColor), m_nBorderStyle);
                }
            }
        }
    }

    void CControlUI::DoPostPaint(HDC hDC, const RECT& rcPaint)
    {
        return;
    }

    int CControlUI::GetLeftBorderSize() const
    {
        if(m_pManager != NULL) return m_pManager->GetDPIObj()->Scale(m_rcBorderSize.left);
        return m_rcBorderSize.left;
    }

    void CControlUI::SetLeftBorderSize( int nSize )
    {
        m_rcBorderSize.left = nSize;
        Invalidate();
    }

    int CControlUI::GetTopBorderSize() const
    {
        if(m_pManager != NULL) return m_pManager->GetDPIObj()->Scale(m_rcBorderSize.top);
        return m_rcBorderSize.top;
    }

    void CControlUI::SetTopBorderSize( int nSize )
    {
        m_rcBorderSize.top = nSize;
        Invalidate();
    }

    int CControlUI::GetRightBorderSize() const
    {
        if(m_pManager != NULL) return m_pManager->GetDPIObj()->Scale(m_rcBorderSize.right);
        return m_rcBorderSize.right;
    }

    void CControlUI::SetRightBorderSize( int nSize )
    {
        m_rcBorderSize.right = nSize;
        Invalidate();
    }

    int CControlUI::GetBottomBorderSize() const
    {
        if(m_pManager != NULL) return m_pManager->GetDPIObj()->Scale(m_rcBorderSize.bottom);
        return m_rcBorderSize.bottom;
    }

    void CControlUI::SetBottomBorderSize( int nSize )
    {
        m_rcBorderSize.bottom = nSize;
        Invalidate();
    }

    int CControlUI::GetBorderStyle() const
    {
        return m_nBorderStyle;
    }

    void CControlUI::SetBorderStyle( int nStyle )
    {
        m_nBorderStyle = nStyle;
        Invalidate();
    }

} // namespace DuiLib
