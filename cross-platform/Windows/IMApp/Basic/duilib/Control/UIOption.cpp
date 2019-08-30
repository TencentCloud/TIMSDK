#include "StdAfx.h"
#include "UIOption.h"

namespace DuiLib
{
    IMPLEMENT_DUICONTROL(COptionUI)
    COptionUI::COptionUI() : m_bSelected(false) ,m_iSelectedFont(-1), m_dwSelectedTextColor(0), m_dwSelectedBkColor(0), m_nSelectedStateCount(0)
    {
    }

    COptionUI::~COptionUI()
    {
        if( !m_sGroupName.IsEmpty() && m_pManager ) m_pManager->RemoveOptionGroup(m_sGroupName, this);
    }

    LPCTSTR COptionUI::GetClass() const
    {
        return _T("OptionUI");
    }

    LPVOID COptionUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_OPTION) == 0 ) return static_cast<COptionUI*>(this);
        return CButtonUI::GetInterface(pstrName);
    }

    void COptionUI::SetManager(CPaintManagerUI* pManager, CControlUI* pParent, bool bInit)
    {
        CControlUI::SetManager(pManager, pParent, bInit);
        if( bInit && !m_sGroupName.IsEmpty() ) {
            if (m_pManager) m_pManager->AddOptionGroup(m_sGroupName, this);
        }
    }

    LPCTSTR COptionUI::GetGroup() const
    {
        return m_sGroupName;
    }

    void COptionUI::SetGroup(LPCTSTR pStrGroupName)
    {
        if( pStrGroupName == NULL ) {
            if( m_sGroupName.IsEmpty() ) return;
            m_sGroupName.Empty();
        }
        else {
            if( m_sGroupName == pStrGroupName ) return;
            if (!m_sGroupName.IsEmpty() && m_pManager) m_pManager->RemoveOptionGroup(m_sGroupName, this);
            m_sGroupName = pStrGroupName;
        }

        if( !m_sGroupName.IsEmpty() ) {
            if (m_pManager) m_pManager->AddOptionGroup(m_sGroupName, this);
        }
        else {
            if (m_pManager) m_pManager->RemoveOptionGroup(m_sGroupName, this);
        }

        Selected(m_bSelected);
    }

    bool COptionUI::IsSelected() const
    {
        return m_bSelected;
    }

    void COptionUI::Selected(bool bSelected, bool bMsg/* = true*/)
    {
        if(m_bSelected == bSelected) return;

        m_bSelected = bSelected;
        if( m_bSelected ) m_uButtonState |= UISTATE_SELECTED;
        else m_uButtonState &= ~UISTATE_SELECTED;

        if( m_pManager != NULL ) {
            if( !m_sGroupName.IsEmpty() ) {
                if( m_bSelected ) {
                    CStdPtrArray* aOptionGroup = m_pManager->GetOptionGroup(m_sGroupName);
                    for( int i = 0; i < aOptionGroup->GetSize(); i++ ) {
                        COptionUI* pControl = static_cast<COptionUI*>(aOptionGroup->GetAt(i));
                        if( pControl != this ) {
                            pControl->Selected(false, bMsg);
                        }
                    }
                    if(bMsg) {
                        m_pManager->SendNotify(this, DUI_MSGTYPE_SELECTCHANGED);
                    }
                }
            }
            else {
                if(bMsg) {
                    m_pManager->SendNotify(this, DUI_MSGTYPE_SELECTCHANGED);
                }
            }
        }

        Invalidate();
    }

    bool COptionUI::Activate()
    {
        if( !CButtonUI::Activate() ) return false;
        if( !m_sGroupName.IsEmpty() ) Selected(true);
        else Selected(!m_bSelected);

        return true;
    }

    void COptionUI::SetEnabled(bool bEnable)
    {
        CControlUI::SetEnabled(bEnable);
        if( !IsEnabled() ) {
            if( m_bSelected ) m_uButtonState = UISTATE_SELECTED;
            else m_uButtonState = 0;
        }
    }

    LPCTSTR COptionUI::GetSelectedImage()
    {
        return m_sSelectedImage;
    }

    void COptionUI::SetSelectedImage(LPCTSTR pStrImage)
    {
        m_sSelectedImage = pStrImage;
        Invalidate();
    }

    LPCTSTR COptionUI::GetSelectedHotImage()
    {
        return m_sSelectedHotImage;
    }

    void COptionUI::SetSelectedHotImage( LPCTSTR pStrImage )
    {
        m_sSelectedHotImage = pStrImage;
        Invalidate();
    }

    LPCTSTR COptionUI::GetSelectedPushedImage()
    {
        return m_sSelectedPushedImage;
    }

    void COptionUI::SetSelectedPushedImage(LPCTSTR pStrImage)
    {
        m_sSelectedPushedImage = pStrImage;
        Invalidate();
    }

    void COptionUI::SetSelectedTextColor(DWORD dwTextColor)
    {
        m_dwSelectedTextColor = dwTextColor;
    }

    DWORD COptionUI::GetSelectedTextColor()
    {
        if (m_dwSelectedTextColor == 0) m_dwSelectedTextColor = m_pManager->GetDefaultFontColor();
        return m_dwSelectedTextColor;
    }

    void COptionUI::SetSelectedBkColor( DWORD dwBkColor )
    {
        m_dwSelectedBkColor = dwBkColor;
    }

    DWORD COptionUI::GetSelectBkColor()
    {
        return m_dwSelectedBkColor;
    }

    LPCTSTR COptionUI::GetSelectedForedImage()
    {
        return m_sSelectedForeImage;
    }

    void COptionUI::SetSelectedForedImage(LPCTSTR pStrImage)
    {
        m_sSelectedForeImage = pStrImage;
        Invalidate();
    }

    void COptionUI::SetSelectedStateCount(int nCount)
    {
        m_nSelectedStateCount = nCount;
        Invalidate();
    }

    int COptionUI::GetSelectedStateCount() const
    {
        return m_nSelectedStateCount;
    }

    LPCTSTR COptionUI::GetSelectedStateImage()
    {
        return m_sSelectedStateImage;
    }

    void COptionUI::SetSelectedStateImage( LPCTSTR pStrImage )
    {
        m_sSelectedStateImage = pStrImage;
        Invalidate();
    }
    void COptionUI::SetSelectedFont(int index)
    {
        m_iSelectedFont = index;
        Invalidate();
    }

    int COptionUI::GetSelectedFont() const
    {
        return m_iSelectedFont;
    }
    void COptionUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if( _tcsicmp(pstrName, _T("group")) == 0 ) SetGroup(pstrValue);
        else if( _tcsicmp(pstrName, _T("selected")) == 0 ) Selected(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("selectedimage")) == 0 ) SetSelectedImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("selectedhotimage")) == 0 ) SetSelectedHotImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("selectedpushedimage")) == 0 ) SetSelectedPushedImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("selectedforeimage")) == 0 ) SetSelectedForedImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("selectedstateimage")) == 0 ) SetSelectedStateImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("selectedstatecount")) == 0 ) SetSelectedStateCount(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("selectedbkcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetSelectedBkColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("selectedtextcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetSelectedTextColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("selectedfont")) == 0 ) SetSelectedFont(_ttoi(pstrValue));
        else CButtonUI::SetAttribute(pstrName, pstrValue);
    }

    void COptionUI::PaintBkColor(HDC hDC)
    {
        if(IsSelected()) {
            if(m_dwSelectedBkColor != 0) {
                CRenderEngine::DrawColor(hDC, m_rcPaint, GetAdjustColor(m_dwSelectedBkColor));
            }
        }
        else {
            return CButtonUI::PaintBkColor(hDC);
        }
    }

    void COptionUI::PaintStatusImage(HDC hDC)
    {
        if(IsSelected()) {
            if(!m_sSelectedStateImage.IsEmpty() && m_nSelectedStateCount > 0)
            {
                TDrawInfo info;
                info.Parse(m_sSelectedStateImage, _T(""), m_pManager);
                const TImageInfo* pImage = m_pManager->GetImageEx(info.sImageName, info.sResType, info.dwMask, info.bHSL);
                if(m_sSelectedImage.IsEmpty() && pImage != NULL)
                {
                    SIZE szImage = {pImage->nX, pImage->nY};
                    SIZE szStatus = {pImage->nX / m_nSelectedStateCount, pImage->nY};
                    if( szImage.cx > 0 && szImage.cy > 0 )
                    {
                        RECT rcSrc = {0, 0, szImage.cx, szImage.cy};
                        if(m_nSelectedStateCount > 0) {
                            int iLeft = rcSrc.left + 0 * szStatus.cx;
                            int iRight = iLeft + szStatus.cx;
                            int iTop = rcSrc.top;
                            int iBottom = iTop + szStatus.cy;
                            m_sSelectedImage.Format(_T("res='%s' restype='%s' dest='%d,%d,%d,%d' source='%d,%d,%d,%d'"), info.sImageName.GetData(), info.sResType.GetData(), info.rcDest.left, info.rcDest.top, info.rcDest.right, info.rcDest.bottom, iLeft, iTop, iRight, iBottom);
                        }
                        if(m_nSelectedStateCount > 1) {
                            int iLeft = rcSrc.left + 1 * szStatus.cx;
                            int iRight = iLeft + szStatus.cx;
                            int iTop = rcSrc.top;
                            int iBottom = iTop + szStatus.cy;
                            m_sSelectedHotImage.Format(_T("res='%s' restype='%s' dest='%d,%d,%d,%d' source='%d,%d,%d,%d'"), info.sImageName.GetData(), info.sResType.GetData(), info.rcDest.left, info.rcDest.top, info.rcDest.right, info.rcDest.bottom, iLeft, iTop, iRight, iBottom);
                            m_sSelectedPushedImage.Format(_T("res='%s' restype='%s' dest='%d,%d,%d,%d' source='%d,%d,%d,%d'"), info.sImageName.GetData(), info.sResType.GetData(), info.rcDest.left, info.rcDest.top, info.rcDest.right, info.rcDest.bottom, iLeft, iTop, iRight, iBottom);
                        }
                        if(m_nSelectedStateCount > 2) {
                            int iLeft = rcSrc.left + 2 * szStatus.cx;
                            int iRight = iLeft + szStatus.cx;
                            int iTop = rcSrc.top;
                            int iBottom = iTop + szStatus.cy;
                            m_sSelectedPushedImage.Format(_T("res='%s' restype='%s' dest='%d,%d,%d,%d' source='%d,%d,%d,%d'"), info.sImageName.GetData(), info.sResType.GetData(), info.rcDest.left, info.rcDest.top, info.rcDest.right, info.rcDest.bottom, iLeft, iTop, iRight, iBottom);
                        }
                    }
                }
            }


            if( (m_uButtonState & UISTATE_PUSHED) != 0 && !m_sSelectedPushedImage.IsEmpty()) {
                if( !DrawImage(hDC, (LPCTSTR)m_sSelectedPushedImage) ) {}
                else return;
            }
            else if( (m_uButtonState & UISTATE_HOT) != 0 && !m_sSelectedHotImage.IsEmpty()) {
                if( !DrawImage(hDC, (LPCTSTR)m_sSelectedHotImage) ) {}
                else return;
            }

            if( !m_sSelectedImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sSelectedImage) ) {}
            }
        }
        else {
            CButtonUI::PaintStatusImage(hDC);
        }
    }

    void COptionUI::PaintForeImage(HDC hDC)
    {
        if(IsSelected()) {
            if( !m_sSelectedForeImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sSelectedForeImage) ) {}
                else return;
            }
        }

        return CButtonUI::PaintForeImage(hDC);
    }

    void COptionUI::PaintText(HDC hDC)
    {
        if( (m_uButtonState & UISTATE_SELECTED) != 0 )
        {
            DWORD oldTextColor = m_dwTextColor;
            if( m_dwSelectedTextColor != 0 ) m_dwTextColor = m_dwSelectedTextColor;

            if( m_dwTextColor == 0 ) m_dwTextColor = m_pManager->GetDefaultFontColor();
            if( m_dwDisabledTextColor == 0 ) m_dwDisabledTextColor = m_pManager->GetDefaultDisabledColor();

            int iFont = GetFont();
            if(GetSelectedFont() != -1) {
                iFont = GetSelectedFont();
            }
            CDuiString sText = GetText();
            if( sText.IsEmpty() ) return;
            int nLinks = 0;
            RECT rc = m_rcItem;
            RECT m_rcTextPadding = CButtonUI::m_rcTextPadding;
            GetManager()->GetDPIObj()->Scale(&m_rcTextPadding);
            rc.left += m_rcTextPadding.left;
            rc.right -= m_rcTextPadding.right;
            rc.top += m_rcTextPadding.top;
            rc.bottom -= m_rcTextPadding.bottom;

            if( m_bShowHtml )
                CRenderEngine::DrawHtmlText(hDC, m_pManager, rc, sText, IsEnabled()?m_dwTextColor:m_dwDisabledTextColor, \
                NULL, NULL, nLinks, iFont, m_uTextStyle);
            else
                CRenderEngine::DrawText(hDC, m_pManager, rc, sText, IsEnabled()?m_dwTextColor:m_dwDisabledTextColor, \
                iFont, m_uTextStyle);

            m_dwTextColor = oldTextColor;
        }
        else
            CButtonUI::PaintText(hDC);
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //
    IMPLEMENT_DUICONTROL(CCheckBoxUI)

    CCheckBoxUI::CCheckBoxUI() : m_bAutoCheck(false)
    {

    }

    LPCTSTR CCheckBoxUI::GetClass() const
    {
        return _T("CheckBoxUI");
    }
    LPVOID CCheckBoxUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_CHECKBOX) == 0 ) return static_cast<CCheckBoxUI*>(this);
        return COptionUI::GetInterface(pstrName);
    }

    void CCheckBoxUI::SetCheck(bool bCheck)
    {
        Selected(bCheck);
    }

    bool  CCheckBoxUI::GetCheck() const
    {
        return IsSelected();
    }

    void CCheckBoxUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if( _tcsicmp(pstrName, _T("EnableAutoCheck")) == 0 ) SetAutoCheck(_tcsicmp(pstrValue, _T("true")) == 0);

        COptionUI::SetAttribute(pstrName, pstrValue);
    }

    void CCheckBoxUI::SetAutoCheck(bool bEnable)
    {
        m_bAutoCheck = bEnable;
    }

    void CCheckBoxUI::DoEvent(TEventUI& event)
    {
        if( !IsMouseEnabled() && event.Type > UIEVENT__MOUSEBEGIN && event.Type < UIEVENT__MOUSEEND ) {
            if( m_pParent != NULL ) m_pParent->DoEvent(event);
            else COptionUI::DoEvent(event);
            return;
        }

        if( m_bAutoCheck && (event.Type == UIEVENT_BUTTONDOWN || event.Type == UIEVENT_DBLCLICK)) {
            if( ::PtInRect(&m_rcItem, event.ptMouse) && IsEnabled() ) {
                SetCheck(!GetCheck()); 
                m_pManager->SendNotify(this, DUI_MSGTYPE_CHECKCLICK, 0, 0);
                Invalidate();
            }
            return;
        }
        COptionUI::DoEvent(event);
    }

    void CCheckBoxUI::Selected(bool bSelected, bool bMsg/* = true*/)
    {
        if( m_bSelected == bSelected ) return;

        m_bSelected = bSelected;
        if( m_bSelected ) m_uButtonState |= UISTATE_SELECTED;
        else m_uButtonState &= ~UISTATE_SELECTED;

        if( m_pManager != NULL ) {
            if( !m_sGroupName.IsEmpty() ) {
                if( m_bSelected ) {
                    CStdPtrArray* aOptionGroup = m_pManager->GetOptionGroup(m_sGroupName);
                    for( int i = 0; i < aOptionGroup->GetSize(); i++ ) {
                        COptionUI* pControl = static_cast<COptionUI*>(aOptionGroup->GetAt(i));
                        if( pControl != this ) {
                            pControl->Selected(false, bMsg);
                        }
                    }
                    if(bMsg) {
                        m_pManager->SendNotify(this, DUI_MSGTYPE_SELECTCHANGED, m_bSelected, 0);
                    }
                }
            }
            else {
                if(bMsg) {
                    m_pManager->SendNotify(this, DUI_MSGTYPE_SELECTCHANGED, m_bSelected, 0);
                }
            }
        }

        Invalidate();
    }
}