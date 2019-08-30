#include "StdAfx.h"

namespace DuiLib {

    /////////////////////////////////////////////////////////////////////////////////////
    //
    //
    IMPLEMENT_DUICONTROL(CListUI)

    CListUI::CListUI() : m_pCallback(NULL), m_bScrollSelect(false), m_iCurSel(-1), m_iExpandedItem(-1), m_bMultiSel(false)
    {
        m_bFixedScrollbar = false;
        m_pList = new CListBodyUI(this);
        m_pHeader = new CListHeaderUI;

        Add(m_pHeader);
        CVerticalLayoutUI::Add(m_pList);

        m_ListInfo.nColumns = 0;
        m_ListInfo.nFont = -1;
        m_ListInfo.uTextStyle = DT_VCENTER | DT_SINGLELINE;
        m_ListInfo.dwTextColor = 0xFF000000;
        m_ListInfo.dwBkColor = 0;
        m_ListInfo.bAlternateBk = false;
        m_ListInfo.dwSelectedTextColor = 0xFF000000;
        m_ListInfo.dwSelectedBkColor = 0xFFC1E3FF;
        m_ListInfo.dwHotTextColor = 0xFF000000;
        m_ListInfo.dwHotBkColor = 0xFFE9F5FF;
        m_ListInfo.dwDisabledTextColor = 0xFFCCCCCC;
        m_ListInfo.dwDisabledBkColor = 0xFFFFFFFF;
        m_ListInfo.dwLineColor = 0;
        m_ListInfo.bShowRowLine = false;
        m_ListInfo.bShowColumnLine = false;
        m_ListInfo.bShowHtml = false;
        m_ListInfo.bMultiExpandable = false;
        m_ListInfo.bRSelected = false;
        ::ZeroMemory(&m_ListInfo.rcTextPadding, sizeof(m_ListInfo.rcTextPadding));
        ::ZeroMemory(&m_ListInfo.rcColumn, sizeof(m_ListInfo.rcColumn));
    }

    LPCTSTR CListUI::GetClass() const
    {
        return _T("ListUI");
    }

    UINT CListUI::GetControlFlags() const
    {
        return UIFLAG_TABSTOP;
    }

    LPVOID CListUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_LIST) == 0 ) return static_cast<CListUI*>(this);
        if( _tcsicmp(pstrName, _T("IList")) == 0 ) return static_cast<IListUI*>(this);
        if( _tcsicmp(pstrName, _T("IListOwner")) == 0 ) return static_cast<IListOwnerUI*>(this);
        return CVerticalLayoutUI::GetInterface(pstrName);
    }

    CControlUI* CListUI::GetItemAt(int iIndex) const
    {
        return m_pList->GetItemAt(iIndex);
    }

    int CListUI::GetItemIndex(CControlUI* pControl) const
    {
        if( pControl->GetInterface(_T("ListHeader")) != NULL ) return CVerticalLayoutUI::GetItemIndex(pControl);
        // We also need to recognize header sub-items
        if( _tcsstr(pControl->GetClass(), _T("ListHeaderItemUI")) != NULL ) return m_pHeader->GetItemIndex(pControl);

        return m_pList->GetItemIndex(pControl);
    }

    bool CListUI::SetItemIndex(CControlUI* pControl, int iIndex)
    {
        if( pControl->GetInterface(_T("ListHeader")) != NULL ) return CVerticalLayoutUI::SetItemIndex(pControl, iIndex);
        // We also need to recognize header sub-items
        if( _tcsstr(pControl->GetClass(), _T("ListHeaderItemUI")) != NULL ) return m_pHeader->SetItemIndex(pControl, iIndex);

        int iOrginIndex = m_pList->GetItemIndex(pControl);
        if( iOrginIndex == -1 ) return false;
        if( iOrginIndex == iIndex ) return true;

        IListItemUI* pSelectedListItem = NULL;
        if( m_iCurSel >= 0 ) pSelectedListItem = 
            static_cast<IListItemUI*>(GetItemAt(m_iCurSel)->GetInterface(_T("ListItem")));
        if( !m_pList->SetItemIndex(pControl, iIndex) ) return false;
        int iMinIndex = min(iOrginIndex, iIndex);
        int iMaxIndex = max(iOrginIndex, iIndex);
        for(int i = iMinIndex; i < iMaxIndex + 1; ++i) {
            CControlUI* p = m_pList->GetItemAt(i);
            IListItemUI* pListItem = static_cast<IListItemUI*>(p->GetInterface(_T("ListItem")));
            if( pListItem != NULL ) {
                pListItem->SetIndex(i);
            }
        }
        if( m_iCurSel >= 0 && pSelectedListItem != NULL ) m_iCurSel = pSelectedListItem->GetIndex();
        return true;
    }

    int CListUI::GetCount() const
    {
        return m_pList->GetCount();
    }

    bool CListUI::Add(CControlUI* pControl)
    {
        // Override the Add() method so we can add items specifically to
        // the intended widgets. Headers are assumed to be
        // answer the correct interface so we can add multiple list headers.
        if( pControl->GetInterface(_T("ListHeader")) != NULL ) {
            if( m_pHeader != pControl && m_pHeader->GetCount() == 0 ) {
                CVerticalLayoutUI::Remove(m_pHeader);
                m_pHeader = static_cast<CListHeaderUI*>(pControl);
            }
            m_ListInfo.nColumns = MIN(m_pHeader->GetCount(), UILIST_MAX_COLUMNS);
            return CVerticalLayoutUI::AddAt(pControl, 0);
        }
        // We also need to recognize header sub-items
        if( _tcsstr(pControl->GetClass(), _T("ListHeaderItemUI")) != NULL ) {
            bool ret = m_pHeader->Add(pControl);
            m_ListInfo.nColumns = MIN(m_pHeader->GetCount(), UILIST_MAX_COLUMNS);
            return ret;
        }
        // The list items should know about us
        IListItemUI* pListItem = static_cast<IListItemUI*>(pControl->GetInterface(_T("ListItem")));
        if( pListItem != NULL ) {
            pListItem->SetOwner(this);
            pListItem->SetIndex(GetCount());
            return m_pList->Add(pControl);
        }
        return CVerticalLayoutUI::Add(pControl);
    }

    bool CListUI::AddAt(CControlUI* pControl, int iIndex)
    {
        // Override the AddAt() method so we can add items specifically to
        // the intended widgets. Headers and are assumed to be
        // answer the correct interface so we can add multiple list headers.
        if( pControl->GetInterface(_T("ListHeader")) != NULL ) {
            if( m_pHeader != pControl && m_pHeader->GetCount() == 0 ) {
                CVerticalLayoutUI::Remove(m_pHeader);
                m_pHeader = static_cast<CListHeaderUI*>(pControl);
            }
            m_ListInfo.nColumns = MIN(m_pHeader->GetCount(), UILIST_MAX_COLUMNS);
            return CVerticalLayoutUI::AddAt(pControl, 0);
        }
        // We also need to recognize header sub-items
        if( _tcsstr(pControl->GetClass(), _T("ListHeaderItemUI")) != NULL ) {
            bool ret = m_pHeader->AddAt(pControl, iIndex);
            m_ListInfo.nColumns = MIN(m_pHeader->GetCount(), UILIST_MAX_COLUMNS);
            return ret;
        }
        if (!m_pList->AddAt(pControl, iIndex)) return false;

        // The list items should know about us
        IListItemUI* pListItem = static_cast<IListItemUI*>(pControl->GetInterface(_T("ListItem")));
        if( pListItem != NULL ) {
            pListItem->SetOwner(this);
            pListItem->SetIndex(iIndex);
        }

        for(int i = iIndex + 1; i < m_pList->GetCount(); ++i) {
            CControlUI* p = m_pList->GetItemAt(i);
            pListItem = static_cast<IListItemUI*>(p->GetInterface(_T("ListItem")));
            if( pListItem != NULL ) {
                pListItem->SetIndex(i);
            }
        }
        if( m_iCurSel >= iIndex ) m_iCurSel += 1;
        return true;
    }

    bool CListUI::Remove(CControlUI* pControl)
    {
        if( pControl->GetInterface(_T("ListHeader")) != NULL ) return CVerticalLayoutUI::Remove(pControl);
        // We also need to recognize header sub-items
        if( _tcsstr(pControl->GetClass(), _T("ListHeaderItemUI")) != NULL ) return m_pHeader->Remove(pControl);

        int iIndex = m_pList->GetItemIndex(pControl);
        if (iIndex == -1) return false;

        if (!m_pList->RemoveAt(iIndex)) return false;

        for(int i = iIndex; i < m_pList->GetCount(); ++i) {
            CControlUI* p = m_pList->GetItemAt(i);
            IListItemUI* pListItem = static_cast<IListItemUI*>(p->GetInterface(_T("ListItem")));
            if( pListItem != NULL ) {
                pListItem->SetIndex(i);
            }
        }

        if( iIndex == m_iCurSel && m_iCurSel >= 0 ) {
            int iSel = m_iCurSel;
            m_iCurSel = -1;
            SelectItem(FindSelectable(iSel, false));
        }
        else if( iIndex < m_iCurSel ) m_iCurSel -= 1;
        return true;
    }

    bool CListUI::RemoveAt(int iIndex)
    {
        if (!m_pList->RemoveAt(iIndex)) return false;

        for(int i = iIndex; i < m_pList->GetCount(); ++i) {
            CControlUI* p = m_pList->GetItemAt(i);
            IListItemUI* pListItem = static_cast<IListItemUI*>(p->GetInterface(_T("ListItem")));
            if( pListItem != NULL ) pListItem->SetIndex(i);
        }

        if( iIndex == m_iCurSel && m_iCurSel >= 0 ) {
            int iSel = m_iCurSel;
            m_iCurSel = -1;
            SelectItem(FindSelectable(iSel, false));
        }
        else if( iIndex < m_iCurSel ) m_iCurSel -= 1;
        return true;
    }

    void CListUI::RemoveAll()
    {
        m_iCurSel = -1;
        m_iExpandedItem = -1;
        m_aSelItems.Empty();
        m_pList->RemoveAll();
    }

    void CListUI::SetPos(RECT rc, bool bNeedInvalidate)
    {
        CVerticalLayoutUI::SetPos(rc, bNeedInvalidate);

        if( m_pHeader == NULL ) return;
        // Determine general list information and the size of header columns
        m_ListInfo.nColumns = MIN(m_pHeader->GetCount(), UILIST_MAX_COLUMNS);
        // The header/columns may or may not be visible at runtime. In either case
        // we should determine the correct dimensions...

        if( !m_pHeader->IsVisible() ) {
            for( int it = 0; it < m_pHeader->GetCount(); it++ ) {
                static_cast<CControlUI*>(m_pHeader->GetItemAt(it))->SetInternVisible(true);
            }
            m_pHeader->SetPos(CDuiRect(rc.left, 0, rc.right, 0), bNeedInvalidate);
        }

        for( int i = 0; i < m_ListInfo.nColumns; i++ ) {
            CControlUI* pControl = static_cast<CControlUI*>(m_pHeader->GetItemAt(i));
            if( !pControl->IsVisible() ) continue;
            if( pControl->IsFloat() ) continue;
            RECT rcPos = pControl->GetPos();
            m_ListInfo.rcColumn[i] = pControl->GetPos();
        }
        if( !m_pHeader->IsVisible() ) {
            for( int it = 0; it < m_pHeader->GetCount(); it++ ) {
                static_cast<CControlUI*>(m_pHeader->GetItemAt(it))->SetInternVisible(false);
            }
        }
        m_pList->SetPos(m_pList->GetPos(), bNeedInvalidate);
    }

    void CListUI::Move(SIZE szOffset, bool bNeedInvalidate)
    {
        CVerticalLayoutUI::Move(szOffset, bNeedInvalidate);
        if( !m_pHeader->IsVisible() ) m_pHeader->Move(szOffset, false);
    }

    int CListUI::GetMinSelItemIndex()
    {
        if (m_aSelItems.GetSize() <= 0)
            return -1;
        int min = (int)m_aSelItems.GetAt(0);
        int index;
        for (int i = 0; i < m_aSelItems.GetSize(); ++i)
        {
            index = (int)m_aSelItems.GetAt(i);
            if (min > index)
                min = index;
        }
        return min;
    }

    int CListUI::GetMaxSelItemIndex()
    {
        if (m_aSelItems.GetSize() <= 0)
            return -1;
        int max = (int)m_aSelItems.GetAt(0);
        int index;
        for (int i = 0; i < m_aSelItems.GetSize(); ++i)
        {
            index = (int)m_aSelItems.GetAt(i);
            if (max < index)
                max = index;
        }
        return max;
    }

    void CListUI::DoEvent(TEventUI& event)
    {
        if( !IsMouseEnabled() && event.Type > UIEVENT__MOUSEBEGIN && event.Type < UIEVENT__MOUSEEND ) {
            if( m_pParent != NULL ) m_pParent->DoEvent(event);
            else CVerticalLayoutUI::DoEvent(event);
            return;
        }

        if( event.Type == UIEVENT_SETFOCUS ) 
        {
            m_bFocused = true;
            return;
        }
        if( event.Type == UIEVENT_KILLFOCUS ) 
        {
            m_bFocused = false;
            return;
        }

        switch( event.Type ) {
        case UIEVENT_KEYDOWN:
            switch( event.chKey ) {
            case VK_UP:
                {
                    if (m_aSelItems.GetSize() > 0) {                    
                        int index = GetMinSelItemIndex() - 1;
                        UnSelectAllItems();
                        index > 0 ? SelectItem(index, true) : SelectItem(0, true);                    
                    }
                }            
                return;
            case VK_DOWN:            
                {
                    if (m_aSelItems.GetSize() > 0) {                    
                        int index = GetMaxSelItemIndex() + 1;
                        UnSelectAllItems();
                        index + 1 > m_pList->GetCount() ? SelectItem(GetCount() - 1, true) : SelectItem(index, true);                    
                    }
                }
                return;
            case VK_PRIOR:
                PageUp();
                return;
            case VK_NEXT:
                PageDown();
                return;
            case VK_HOME:
                SelectItem(FindSelectable(0, false), true);
                return;
            case VK_END:
                SelectItem(FindSelectable(GetCount() - 1, true), true);
                return;
            case VK_RETURN:
                if( m_iCurSel != -1 ) GetItemAt(m_iCurSel)->Activate();
                return;
            case 0x41:// Ctrl+A
                {
                    if (IsMultiSelect() && (GetKeyState(VK_CONTROL) & 0x8000)) {
                        SelectAllItems();
                    }
                    return;
                }
            }
            break;
        case UIEVENT_SCROLLWHEEL:
            {
                switch( LOWORD(event.wParam) ) {
                case SB_LINEUP:
                    if( m_bScrollSelect && !IsMultiSelect() ) SelectItem(FindSelectable(m_iCurSel - 1, false), true);
                    else LineUp();
                    return;
                case SB_LINEDOWN:
                    if( m_bScrollSelect && !IsMultiSelect() ) SelectItem(FindSelectable(m_iCurSel + 1, true), true);
                    else LineDown();
                    return;
                }
            }
            break;
        }
        CVerticalLayoutUI::DoEvent(event);
    }

    bool CListUI::IsFixedScrollbar()
    {
        return m_bFixedScrollbar;
    }

    void CListUI::SetFixedScrollbar(bool bFixed)
    {
        m_bFixedScrollbar = bFixed;
        Invalidate();
    }

    CListHeaderUI* CListUI::GetHeader() const
    {
        return m_pHeader;
    }

    CContainerUI* CListUI::GetList() const
    {
        return m_pList;
    }

    bool CListUI::GetScrollSelect()
    {
        return m_bScrollSelect;
    }

    void CListUI::SetScrollSelect(bool bScrollSelect)
    {
        m_bScrollSelect = bScrollSelect;
    }

    int CListUI::GetCurSelActivate() const
    {
        return m_iCurSelActivate;
    }

    bool CListUI::SelectItemActivate(int iIndex)
    {
        if (!SelectItem(iIndex, true)){
            return false;
        }

        m_iCurSelActivate = iIndex;
        return true;
    }

    int CListUI::GetCurSel() const
    {    
        if (m_aSelItems.GetSize() <= 0) {
            return -1;
        }
        else {
            return (int)m_aSelItems.GetAt(0);
        }

        return -1;
    }

    bool CListUI::SelectItem(int iIndex, bool bTakeFocus)
    {
        // 取消所有选择项
        UnSelectAllItems();
        // 判断是否合法列表项
        if( iIndex < 0 ) return false;
        CControlUI* pControl = GetItemAt(iIndex);
        if( pControl == NULL ) return false;
        IListItemUI* pListItem = static_cast<IListItemUI*>(pControl->GetInterface(_T("ListItem")));
        if( pListItem == NULL ) return false;
        if( !pListItem->Select(true) ) {
            return false;
        }
        int iLastSel = m_iCurSel;
        m_iCurSel = iIndex;
        m_aSelItems.Add((LPVOID)iIndex);
        EnsureVisible(iIndex);
        if( bTakeFocus ) pControl->SetFocus();
        if( m_pManager != NULL && iLastSel != m_iCurSel) {
            m_pManager->SendNotify(this, DUI_MSGTYPE_ITEMSELECT, iIndex);
        }

        return true;
    }

    bool CListUI::SelectMultiItem(int iIndex, bool bTakeFocus)
    {
        if(!IsMultiSelect()) return SelectItem(iIndex, bTakeFocus);

        if( iIndex < 0 ) return false;
        CControlUI* pControl = GetItemAt(iIndex);
        if( pControl == NULL ) return false;
        IListItemUI* pListItem = static_cast<IListItemUI*>(pControl->GetInterface(_T("ListItem")));
        if( pListItem == NULL ) return false;
        if(m_aSelItems.Find((LPVOID)iIndex) >= 0) return false;
        if(!pListItem->SelectMulti(true)) return false;

        m_iCurSel = iIndex;
        m_aSelItems.Add((LPVOID)iIndex);
        EnsureVisible(iIndex);
        if( bTakeFocus ) pControl->SetFocus();
        if( m_pManager != NULL ) {
            m_pManager->SendNotify(this, DUI_MSGTYPE_ITEMSELECT, iIndex);
        }
        return true;
    }

    void CListUI::SetMultiSelect(bool bMultiSel)
    {
        m_bMultiSel = bMultiSel;
        if(!bMultiSel) UnSelectAllItems();
    }

    bool CListUI::IsMultiSelect() const
    {
        return m_bMultiSel;
    }

    bool CListUI::UnSelectItem(int iIndex, bool bOthers)
    {
        if(!IsMultiSelect()) return false;
        if(bOthers) {
            for (int i = m_aSelItems.GetSize() - 1; i >= 0; --i) {
                int iSelIndex = (int)m_aSelItems.GetAt(i);
                if(iSelIndex == iIndex) continue;
                CControlUI* pControl = GetItemAt(iSelIndex);
                if(pControl == NULL) continue;
                if(!pControl->IsEnabled()) continue;
                IListItemUI* pSelListItem = static_cast<IListItemUI*>(pControl->GetInterface(_T("ListItem")));
                if( pSelListItem == NULL ) continue;
                if( !pSelListItem->SelectMulti(false) ) continue;
                m_aSelItems.Remove(i);
            }
        }
        else {
            if( iIndex < 0 ) return false;
            CControlUI* pControl = GetItemAt(iIndex);
            if( pControl == NULL ) return false;
            if( !pControl->IsEnabled() ) return false;
            IListItemUI* pListItem = static_cast<IListItemUI*>(pControl->GetInterface(_T("ListItem")));
            if( pListItem == NULL ) return false;
            int aIndex = m_aSelItems.Find((LPVOID)iIndex);
            if (aIndex < 0) return false;
            if( !pListItem->SelectMulti(false) ) return false;
            if(m_iCurSel == iIndex) m_iCurSel = -1;
            m_aSelItems.Remove(aIndex);
        }
        return true;
    }

    void CListUI::SelectAllItems()
    {
        for (int i = 0; i < GetCount(); ++i) {
            CControlUI* pControl = GetItemAt(i);
            if(pControl == NULL) continue;
            if(!pControl->IsVisible()) continue;
            if(!pControl->IsEnabled()) continue;
            IListItemUI* pListItem = static_cast<IListItemUI*>(pControl->GetInterface(_T("ListItem")));
            if(pListItem == NULL) continue;
            if(!pListItem->SelectMulti(true)) continue;

            m_aSelItems.Add((LPVOID)i);
            m_iCurSel = i;
        }
    }

    void CListUI::UnSelectAllItems()
    {
        for (int i = 0; i < m_aSelItems.GetSize(); ++i) {
            int iSelIndex = (int)m_aSelItems.GetAt(i);
            CControlUI* pControl = GetItemAt(iSelIndex);
            if(pControl == NULL) continue;
            if(!pControl->IsEnabled()) continue;
            IListItemUI* pListItem = static_cast<IListItemUI*>(pControl->GetInterface(_T("ListItem")));
            if( pListItem == NULL ) continue;
            if( !pListItem->SelectMulti(false) ) continue;        
        }
        m_aSelItems.Empty();
        m_iCurSel = -1;
    }

    int CListUI::GetSelectItemCount() const
    {
        return m_aSelItems.GetSize();
    }

    int CListUI::GetNextSelItem(int nItem) const
    {
        if (m_aSelItems.GetSize() <= 0)
            return -1;

        if (nItem < 0) {
            return (int)m_aSelItems.GetAt(0);
        }
        int aIndex = m_aSelItems.Find((LPVOID)nItem);
        if (aIndex < 0) return -1;
        if (aIndex + 1 > m_aSelItems.GetSize() - 1)
            return -1;
        return (int)m_aSelItems.GetAt(aIndex + 1);
    }

    UINT CListUI::GetListType()
    {
        return LT_LIST;
    }

    TListInfoUI* CListUI::GetListInfo()
    {
        return &m_ListInfo;
    }

    bool CListUI::IsDelayedDestroy() const
    {
        return m_pList->IsDelayedDestroy();
    }

    void CListUI::SetDelayedDestroy(bool bDelayed)
    {
        m_pList->SetDelayedDestroy(bDelayed);
    }

    int CListUI::GetChildPadding() const
    {
        return m_pList->GetChildPadding();
    }

    void CListUI::SetChildPadding(int iPadding)
    {
        m_pList->SetChildPadding(iPadding);
    }

    void CListUI::SetItemFont(int index)
    {
        m_ListInfo.nFont = index;
        NeedUpdate();
    }

    void CListUI::SetItemTextStyle(UINT uStyle)
    {
        m_ListInfo.uTextStyle = uStyle;
        NeedUpdate();
    }

    void CListUI::SetItemTextPadding(RECT rc)
    {
        m_ListInfo.rcTextPadding = rc;
        NeedUpdate();
    }

    RECT CListUI::GetItemTextPadding() const
    {
        RECT rect = m_ListInfo.rcTextPadding;
        GetManager()->GetDPIObj()->Scale(&rect);
        return rect;
    }

    void CListUI::SetItemTextColor(DWORD dwTextColor)
    {
        m_ListInfo.dwTextColor = dwTextColor;
        Invalidate();
    }

    void CListUI::SetItemBkColor(DWORD dwBkColor)
    {
        m_ListInfo.dwBkColor = dwBkColor;
        Invalidate();
    }

    void CListUI::SetItemBkImage(LPCTSTR pStrImage)
    {
        m_ListInfo.sBkImage = pStrImage;
        Invalidate();
    }

    void CListUI::SetAlternateBk(bool bAlternateBk)
    {
        m_ListInfo.bAlternateBk = bAlternateBk;
        Invalidate();
    }

    DWORD CListUI::GetItemTextColor() const
    {
        return m_ListInfo.dwTextColor;
    }

    DWORD CListUI::GetItemBkColor() const
    {
        return m_ListInfo.dwBkColor;
    }

    LPCTSTR CListUI::GetItemBkImage() const
    {
        return m_ListInfo.sBkImage;
    }

    bool CListUI::IsAlternateBk() const
    {
        return m_ListInfo.bAlternateBk;
    }

    void CListUI::SetSelectedItemTextColor(DWORD dwTextColor)
    {
        m_ListInfo.dwSelectedTextColor = dwTextColor;
        Invalidate();
    }

    void CListUI::SetSelectedItemBkColor(DWORD dwBkColor)
    {
        m_ListInfo.dwSelectedBkColor = dwBkColor;
        Invalidate();
    }

    void CListUI::SetSelectedItemImage(LPCTSTR pStrImage)
    {
        m_ListInfo.sSelectedImage = pStrImage;
        Invalidate();
    }

    DWORD CListUI::GetSelectedItemTextColor() const
    {
        return m_ListInfo.dwSelectedTextColor;
    }

    DWORD CListUI::GetSelectedItemBkColor() const
    {
        return m_ListInfo.dwSelectedBkColor;
    }

    LPCTSTR CListUI::GetSelectedItemImage() const
    {
        return m_ListInfo.sSelectedImage;
    }

    void CListUI::SetHotItemTextColor(DWORD dwTextColor)
    {
        m_ListInfo.dwHotTextColor = dwTextColor;
        Invalidate();
    }

    void CListUI::SetHotItemBkColor(DWORD dwBkColor)
    {
        m_ListInfo.dwHotBkColor = dwBkColor;
        Invalidate();
    }

    void CListUI::SetHotItemImage(LPCTSTR pStrImage)
    {
        m_ListInfo.sHotImage = pStrImage;
        Invalidate();
    }

    DWORD CListUI::GetHotItemTextColor() const
    {
        return m_ListInfo.dwHotTextColor;
    }
    DWORD CListUI::GetHotItemBkColor() const
    {
        return m_ListInfo.dwHotBkColor;
    }

    LPCTSTR CListUI::GetHotItemImage() const
    {
        return m_ListInfo.sHotImage;
    }

    void CListUI::SetDisabledItemTextColor(DWORD dwTextColor)
    {
        m_ListInfo.dwDisabledTextColor = dwTextColor;
        Invalidate();
    }

    void CListUI::SetDisabledItemBkColor(DWORD dwBkColor)
    {
        m_ListInfo.dwDisabledBkColor = dwBkColor;
        Invalidate();
    }

    void CListUI::SetDisabledItemImage(LPCTSTR pStrImage)
    {
        m_ListInfo.sDisabledImage = pStrImage;
        Invalidate();
    }

    DWORD CListUI::GetDisabledItemTextColor() const
    {
        return m_ListInfo.dwDisabledTextColor;
    }

    DWORD CListUI::GetDisabledItemBkColor() const
    {
        return m_ListInfo.dwDisabledBkColor;
    }

    LPCTSTR CListUI::GetDisabledItemImage() const
    {
        return m_ListInfo.sDisabledImage;
    }

    DWORD CListUI::GetItemLineColor() const
    {
        return m_ListInfo.dwLineColor;
    }

    void CListUI::SetItemLineColor(DWORD dwLineColor)
    {
        m_ListInfo.dwLineColor = dwLineColor;
        Invalidate();
    }
    void CListUI::SetItemShowRowLine(bool bShowLine)
    {
        m_ListInfo.bShowRowLine = bShowLine;
        Invalidate();
    }
    void CListUI::SetItemShowColumnLine(bool bShowLine)
    {
        m_ListInfo.bShowColumnLine = bShowLine;
        Invalidate();
    }
    bool CListUI::IsItemShowHtml()
    {
        return m_ListInfo.bShowHtml;
    }

    void CListUI::SetItemShowHtml(bool bShowHtml)
    {
        if( m_ListInfo.bShowHtml == bShowHtml ) return;

        m_ListInfo.bShowHtml = bShowHtml;
        NeedUpdate();
    }

    bool CListUI::IsItemRSelected()
    {
        return m_ListInfo.bRSelected;
    }

    void CListUI::SetItemRSelected(bool bSelected)
    {
        if( m_ListInfo.bRSelected == bSelected ) return;

        m_ListInfo.bRSelected = bSelected;
        NeedUpdate();
    }

    void CListUI::SetMultiExpanding(bool bMultiExpandable)
    {
        m_ListInfo.bMultiExpandable = bMultiExpandable;
    }

    bool CListUI::ExpandItem(int iIndex, bool bExpand /*= true*/)
    {
        if( m_iExpandedItem >= 0 && !m_ListInfo.bMultiExpandable) {
            CControlUI* pControl = GetItemAt(m_iExpandedItem);
            if( pControl != NULL ) {
                IListItemUI* pItem = static_cast<IListItemUI*>(pControl->GetInterface(_T("ListItem")));
                if( pItem != NULL ) pItem->Expand(false);
            }
            m_iExpandedItem = -1;
        }
        if( bExpand ) {
            CControlUI* pControl = GetItemAt(iIndex);
            if( pControl == NULL ) return false;
            if( !pControl->IsVisible() ) return false;
            IListItemUI* pItem = static_cast<IListItemUI*>(pControl->GetInterface(_T("ListItem")));
            if( pItem == NULL ) return false;
            m_iExpandedItem = iIndex;
            if( !pItem->Expand(true) ) {
                m_iExpandedItem = -1;
                return false;
            }
        }
        NeedUpdate();
        return true;
    }

    int CListUI::GetExpandedItem() const
    {
        return m_iExpandedItem;
    }

    void CListUI::EnsureVisible(int iIndex)
    {
        if( m_iCurSel < 0 ) return;
        RECT rcItem = m_pList->GetItemAt(iIndex)->GetPos();
        RECT rcList = m_pList->GetPos();
        RECT rcListInset = m_pList->GetInset();

        rcList.left += rcListInset.left;
        rcList.top += rcListInset.top;
        rcList.right -= rcListInset.right;
        rcList.bottom -= rcListInset.bottom;

        CScrollBarUI* pHorizontalScrollBar = m_pList->GetHorizontalScrollBar();
        if( pHorizontalScrollBar && pHorizontalScrollBar->IsVisible() ) rcList.bottom -= pHorizontalScrollBar->GetFixedHeight();

        int iPos = m_pList->GetScrollPos().cy;
        if( rcItem.top >= rcList.top && rcItem.bottom < rcList.bottom ) return;
        int dx = 0;
        if( rcItem.top < rcList.top ) dx = rcItem.top - rcList.top;
        if( rcItem.bottom > rcList.bottom ) dx = rcItem.bottom - rcList.bottom;
        Scroll(0, dx);
    }

    void CListUI::Scroll(int dx, int dy)
    {
        if( dx == 0 && dy == 0 ) return;
        SIZE sz = m_pList->GetScrollPos();
        m_pList->SetScrollPos(CDuiSize(sz.cx + dx, sz.cy + dy));
    }

    void CListUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if( _tcsicmp(pstrName, _T("header")) == 0 ) GetHeader()->SetVisible(_tcsicmp(pstrValue, _T("hidden")) != 0);
        else if( _tcsicmp(pstrName, _T("headerbkimage")) == 0 ) GetHeader()->SetBkImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("scrollselect")) == 0 ) SetScrollSelect(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("fixedscrollbar")) == 0 ) SetFixedScrollbar(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("multiexpanding")) == 0 ) SetMultiExpanding(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("itemfont")) == 0 ) m_ListInfo.nFont = _ttoi(pstrValue);
        else if( _tcsicmp(pstrName, _T("itemalign")) == 0 ) {
            if( _tcsstr(pstrValue, _T("left")) != NULL ) {
                m_ListInfo.uTextStyle &= ~(DT_CENTER | DT_RIGHT);
                m_ListInfo.uTextStyle |= DT_LEFT;
            }
            if( _tcsstr(pstrValue, _T("center")) != NULL ) {
                m_ListInfo.uTextStyle &= ~(DT_LEFT | DT_RIGHT);
                m_ListInfo.uTextStyle |= DT_CENTER;
            }
            if( _tcsstr(pstrValue, _T("right")) != NULL ) {
                m_ListInfo.uTextStyle &= ~(DT_LEFT | DT_CENTER);
                m_ListInfo.uTextStyle |= DT_RIGHT;
            }
        }
        else if( _tcsicmp(pstrName, _T("itemvalign")) == 0 ) {
            if( _tcsstr(pstrValue, _T("top")) != NULL ) {
                m_ListInfo.uTextStyle &= ~(DT_VCENTER | DT_BOTTOM);
                m_ListInfo.uTextStyle |= DT_TOP;
            }
            if( _tcsstr(pstrValue, _T("vcenter")) != NULL ) {
                m_ListInfo.uTextStyle &= ~(DT_TOP | DT_BOTTOM | DT_WORDBREAK);
                m_ListInfo.uTextStyle |= DT_VCENTER | DT_SINGLELINE;
            }
            if( _tcsstr(pstrValue, _T("bottom")) != NULL ) {
                m_ListInfo.uTextStyle &= ~(DT_TOP | DT_VCENTER);
                m_ListInfo.uTextStyle |= DT_BOTTOM;
            }
        }
        else if( _tcsicmp(pstrName, _T("itemendellipsis")) == 0 ) {
            if( _tcsicmp(pstrValue, _T("true")) == 0 ) m_ListInfo.uTextStyle |= DT_END_ELLIPSIS;
            else m_ListInfo.uTextStyle &= ~DT_END_ELLIPSIS;
        }    
        else if( _tcsicmp(pstrName, _T("itemtextpadding")) == 0 ) {
            RECT rcTextPadding = { 0 };
            LPTSTR pstr = NULL;
            rcTextPadding.left = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
            rcTextPadding.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
            rcTextPadding.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
            rcTextPadding.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
            SetItemTextPadding(rcTextPadding);
        }
        else if( _tcsicmp(pstrName, _T("itemtextcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetItemTextColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("itembkcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetItemBkColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("itembkimage")) == 0 ) SetItemBkImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("itemaltbk")) == 0 ) SetAlternateBk(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("itemselectedtextcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetSelectedItemTextColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("itemselectedbkcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetSelectedItemBkColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("itemselectedimage")) == 0 ) SetSelectedItemImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("itemhottextcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetHotItemTextColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("itemhotbkcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetHotItemBkColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("itemhotimage")) == 0 ) SetHotItemImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("itemdisabledtextcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetDisabledItemTextColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("itemdisabledbkcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetDisabledItemBkColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("itemdisabledimage")) == 0 ) SetDisabledItemImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("itemlinecolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetItemLineColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("itemshowrowline")) == 0 ) SetItemShowRowLine(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("itemshowcolumnline")) == 0 ) SetItemShowColumnLine(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("itemshowhtml")) == 0 ) SetItemShowHtml(_tcsicmp(pstrValue, _T("true")) == 0);
        else if ( _tcscmp(pstrName, _T("multiselect")) == 0 ) SetMultiSelect(_tcscmp(pstrValue, _T("true")) == 0);
        else if ( _tcscmp(pstrName, _T("itemrselected")) == 0 ) SetItemRSelected(_tcscmp(pstrValue, _T("true")) == 0);
        else CVerticalLayoutUI::SetAttribute(pstrName, pstrValue);
    }

    IListCallbackUI* CListUI::GetTextCallback() const
    {
        return m_pCallback;
    }

    void CListUI::SetTextCallback(IListCallbackUI* pCallback)
    {
        m_pCallback = pCallback;
    }

    SIZE CListUI::GetScrollPos() const
    {
        return m_pList->GetScrollPos();
    }

    SIZE CListUI::GetScrollRange() const
    {
        return m_pList->GetScrollRange();
    }

    void CListUI::SetScrollPos(SIZE szPos, bool bMsg)
    {
        m_pList->SetScrollPos(szPos, bMsg);
    }

    void CListUI::LineUp()
    {
        m_pList->LineUp();
    }

    void CListUI::LineDown()
    {
        m_pList->LineDown();
    }

    void CListUI::PageUp()
    {
        m_pList->PageUp();
    }

    void CListUI::PageDown()
    {
        m_pList->PageDown();
    }

    void CListUI::HomeUp()
    {
        m_pList->HomeUp();
    }

    void CListUI::EndDown()
    {
        m_pList->EndDown();
    }

    void CListUI::LineLeft()
    {
        m_pList->LineLeft();
    }

    void CListUI::LineRight()
    {
        m_pList->LineRight();
    }

    void CListUI::PageLeft()
    {
        m_pList->PageLeft();
    }

    void CListUI::PageRight()
    {
        m_pList->PageRight();
    }

    void CListUI::HomeLeft()
    {
        m_pList->HomeLeft();
    }

    void CListUI::EndRight()
    {
        m_pList->EndRight();
    }

    void CListUI::EnableScrollBar(bool bEnableVertical, bool bEnableHorizontal)
    {
        m_pList->EnableScrollBar(bEnableVertical, bEnableHorizontal);
    }

    CScrollBarUI* CListUI::GetVerticalScrollBar() const
    {
        return m_pList->GetVerticalScrollBar();
    }

    CScrollBarUI* CListUI::GetHorizontalScrollBar() const
    {
        return m_pList->GetHorizontalScrollBar();
    }

    BOOL CListUI::SortItems(PULVCompareFunc pfnCompare, UINT_PTR dwData)
    {
        if (!m_pList)
            return FALSE;
        return m_pList->SortItems(pfnCompare, dwData);    
    }
    /////////////////////////////////////////////////////////////////////////////////////
    //
    //

    CListBodyUI::CListBodyUI(CListUI* pOwner) : m_pOwner(pOwner)
    {
        ASSERT(m_pOwner);
    }

    BOOL CListBodyUI::SortItems(PULVCompareFunc pfnCompare, UINT_PTR dwData)
    {
        if (!pfnCompare)
            return FALSE;
        m_pCompareFunc = pfnCompare;
        m_compareData = dwData;
        CControlUI **pData = (CControlUI **)m_items.GetData();
        qsort_s(m_items.GetData(), m_items.GetSize(), sizeof(CControlUI*), CListBodyUI::ItemComareFunc, this);    
        IListItemUI *pItem = NULL;
        for (int i = 0; i < m_items.GetSize(); ++i)
        {
            pItem = (IListItemUI*)(static_cast<CControlUI*>(m_items[i])->GetInterface(TEXT("ListItem")));
            if (pItem)
            {
                pItem->SetIndex(i);
                pItem->Select(false);
            }
        }
        m_pOwner->SelectItem(-1);
        if (m_pManager)
        {
            SetPos(GetPos());
            Invalidate();
        }

        return TRUE;
    }

    int __cdecl CListBodyUI::ItemComareFunc(void *pvlocale, const void *item1, const void *item2)
    {
        CListBodyUI *pThis = (CListBodyUI*)pvlocale;
        if (!pThis || !item1 || !item2)
            return 0;
        return pThis->ItemComareFunc(item1, item2);
    }

    int __cdecl CListBodyUI::ItemComareFunc(const void *item1, const void *item2)
    {
        CControlUI *pControl1 = *(CControlUI**)item1;
        CControlUI *pControl2 = *(CControlUI**)item2;
        return m_pCompareFunc((UINT_PTR)pControl1, (UINT_PTR)pControl2, m_compareData);
    }

    int CListBodyUI::GetScrollStepSize() const
    {
        if(m_pOwner != NULL) return m_pOwner->GetScrollStepSize();

        return CVerticalLayoutUI::GetScrollStepSize();
    }

    void CListBodyUI::SetScrollPos(SIZE szPos, bool bMsg)
    {
        int cx = 0;
        int cy = 0;
        if( m_pVerticalScrollBar && m_pVerticalScrollBar->IsVisible() ) {
            int iLastScrollPos = m_pVerticalScrollBar->GetScrollPos();
            m_pVerticalScrollBar->SetScrollPos(szPos.cy);
            cy = m_pVerticalScrollBar->GetScrollPos() - iLastScrollPos;
        }

        if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsVisible() ) {
            int iLastScrollPos = m_pHorizontalScrollBar->GetScrollPos();
            m_pHorizontalScrollBar->SetScrollPos(szPos.cx);
            cx = m_pHorizontalScrollBar->GetScrollPos() - iLastScrollPos;
        }

        RECT rcPos;
        for( int it2 = 0; it2 < m_items.GetSize(); it2++ ) {
            CControlUI* pControl = static_cast<CControlUI*>(m_items[it2]);
            if( !pControl->IsVisible() ) continue;
            if( pControl->IsFloat() ) continue;

            rcPos = pControl->GetPos();
            rcPos.left -= cx;
            rcPos.right -= cx;
            rcPos.top -= cy;
            rcPos.bottom -= cy;
            pControl->SetPos(rcPos, true);
        }

        Invalidate();
        if( m_pOwner ) {
            CListHeaderUI* pHeader = m_pOwner->GetHeader();
            if( pHeader == NULL ) return;
            TListInfoUI* pInfo = m_pOwner->GetListInfo();
            pInfo->nColumns = MIN(pHeader->GetCount(), UILIST_MAX_COLUMNS);

            if( !pHeader->IsVisible() ) {
                for( int it = 0; it < pHeader->GetCount(); it++ ) {
                    static_cast<CControlUI*>(pHeader->GetItemAt(it))->SetInternVisible(true);
                }
            }
            for( int i = 0; i < pInfo->nColumns; i++ ) {
                CControlUI* pControl = static_cast<CControlUI*>(pHeader->GetItemAt(i));
                if( !pControl->IsVisible() ) continue;
                if( pControl->IsFloat() ) continue;

                RECT rcPos = pControl->GetPos();
                rcPos.left -= cx;
                rcPos.right -= cx;
                pControl->SetPos(rcPos);
                pInfo->rcColumn[i] = pControl->GetPos();
            }
            if( !pHeader->IsVisible() ) {
                for( int it = 0; it < pHeader->GetCount(); it++ ) {
                    static_cast<CControlUI*>(pHeader->GetItemAt(it))->SetInternVisible(false);
                }
            }
        }
    }

    void CListBodyUI::SetPos(RECT rc, bool bNeedInvalidate)
    {
        CControlUI::SetPos(rc, bNeedInvalidate);
        rc = m_rcItem;

        // Adjust for inset
        rc.left += m_rcInset.left;
        rc.top += m_rcInset.top;
        rc.right -= m_rcInset.right;
        rc.bottom -= m_rcInset.bottom;
        if(m_pOwner->IsFixedScrollbar() && m_pVerticalScrollBar) rc.right -= m_pVerticalScrollBar->GetFixedWidth();
        else if( m_pVerticalScrollBar && m_pVerticalScrollBar->IsVisible() ) rc.right -= m_pVerticalScrollBar->GetFixedWidth();
        if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsVisible() ) rc.bottom -= m_pHorizontalScrollBar->GetFixedHeight();

        // Determine the minimum size
        SIZE szAvailable = { rc.right - rc.left, rc.bottom - rc.top };
        if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsVisible() ) 
            szAvailable.cx += m_pHorizontalScrollBar->GetScrollRange();

        int cxNeeded = 0;
        int nAdjustables = 0;
        int cyFixed = 0;
        int nEstimateNum = 0;
        for( int it1 = 0; it1 < m_items.GetSize(); it1++ ) {
            CControlUI* pControl = static_cast<CControlUI*>(m_items[it1]);
            if( !pControl->IsVisible() ) continue;
            if( pControl->IsFloat() ) continue;
            SIZE sz = pControl->EstimateSize(szAvailable);
            if( sz.cy == 0 ) {
                nAdjustables++;
            }
            else {
                if( sz.cy < pControl->GetMinHeight() ) sz.cy = pControl->GetMinHeight();
                if( sz.cy > pControl->GetMaxHeight() ) sz.cy = pControl->GetMaxHeight();
            }
            cyFixed += sz.cy + pControl->GetPadding().top + pControl->GetPadding().bottom;

            RECT rcPadding = pControl->GetPadding();
            sz.cx = MAX(sz.cx, 0);
            if( sz.cx < pControl->GetMinWidth() ) sz.cx = pControl->GetMinWidth();
            if( sz.cx > pControl->GetMaxWidth() ) sz.cx = pControl->GetMaxWidth();
            cxNeeded = MAX(cxNeeded, sz.cx);
            nEstimateNum++;
        }
        cyFixed += (nEstimateNum - 1) * m_iChildPadding;

        if( m_pOwner ) {
            CListHeaderUI* pHeader = m_pOwner->GetHeader();
            if( pHeader != NULL && pHeader->GetCount() > 0 ) {
                cxNeeded = MAX(0, pHeader->EstimateSize(CDuiSize(rc.right - rc.left, rc.bottom - rc.top)).cx);
                if ( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsVisible())
                {
                    int nOffset = m_pHorizontalScrollBar->GetScrollPos();
                    RECT rcHeader = pHeader->GetPos();
                    rcHeader.left = rc.left - nOffset;
                    pHeader->SetPos(rcHeader);
                }
            }
        }

        // Place elements
        int cyNeeded = 0;
        int cyExpand = 0;
        if( nAdjustables > 0 ) cyExpand = MAX(0, (szAvailable.cy - cyFixed) / nAdjustables);
        // Position the elements
        SIZE szRemaining = szAvailable;
        int iPosY = rc.top;
        if( m_pVerticalScrollBar && m_pVerticalScrollBar->IsVisible() ) {
            iPosY -= m_pVerticalScrollBar->GetScrollPos();
        }
        int iPosX = rc.left;
        if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsVisible() ) {
            iPosX -= m_pHorizontalScrollBar->GetScrollPos();
        }
        int iAdjustable = 0;
        int cyFixedRemaining = cyFixed;
        for( int it2 = 0; it2 < m_items.GetSize(); it2++ ) {
            CControlUI* pControl = static_cast<CControlUI*>(m_items[it2]);
            if( !pControl->IsVisible() ) continue;
            if( pControl->IsFloat() ) {
                SetFloatPos(it2);
                continue;
            }

            RECT rcPadding = pControl->GetPadding();
            szRemaining.cy -= rcPadding.top;
            SIZE sz = pControl->EstimateSize(szRemaining);
            if( sz.cy == 0 ) {
                iAdjustable++;
                sz.cy = cyExpand;
                // Distribute remaining to last element (usually round-off left-overs)
                if( iAdjustable == nAdjustables ) {
                    sz.cy = MAX(0, szRemaining.cy - rcPadding.bottom - cyFixedRemaining);
                } 
                if( sz.cy < pControl->GetMinHeight() ) sz.cy = pControl->GetMinHeight();
                if( sz.cy > pControl->GetMaxHeight() ) sz.cy = pControl->GetMaxHeight();
            }
            else {
                if( sz.cy < pControl->GetMinHeight() ) sz.cy = pControl->GetMinHeight();
                if( sz.cy > pControl->GetMaxHeight() ) sz.cy = pControl->GetMaxHeight();
                cyFixedRemaining -= sz.cy;
            }

            sz.cx = MAX(cxNeeded, szAvailable.cx - rcPadding.left - rcPadding.right);

            if( sz.cx < pControl->GetMinWidth() ) sz.cx = pControl->GetMinWidth();
            if( sz.cx > pControl->GetMaxWidth() ) sz.cx = pControl->GetMaxWidth();

            RECT rcCtrl = { iPosX + rcPadding.left, iPosY + rcPadding.top, iPosX + rcPadding.left + sz.cx, iPosY + sz.cy + rcPadding.top + rcPadding.bottom };
            pControl->SetPos(rcCtrl);

            iPosY += sz.cy + m_iChildPadding + rcPadding.top + rcPadding.bottom;
            cyNeeded += sz.cy + rcPadding.top + rcPadding.bottom;
            szRemaining.cy -= sz.cy + m_iChildPadding + rcPadding.bottom;
        }
        cyNeeded += (nEstimateNum - 1) * m_iChildPadding;

        if( m_pHorizontalScrollBar != NULL ) {
            if( cxNeeded > rc.right - rc.left ) {
                if( m_pHorizontalScrollBar->IsVisible() ) {
                    m_pHorizontalScrollBar->SetScrollRange(cxNeeded - (rc.right - rc.left));
                }
                else {
                    m_pHorizontalScrollBar->SetVisible(true);
                    m_pHorizontalScrollBar->SetScrollRange(cxNeeded - (rc.right - rc.left));
                    m_pHorizontalScrollBar->SetScrollPos(0);
                    rc.bottom -= m_pHorizontalScrollBar->GetFixedHeight();
                }
            }
            else {
                if( m_pHorizontalScrollBar->IsVisible() ) {
                    m_pHorizontalScrollBar->SetVisible(false);
                    m_pHorizontalScrollBar->SetScrollRange(0);
                    m_pHorizontalScrollBar->SetScrollPos(0);
                    rc.bottom += m_pHorizontalScrollBar->GetFixedHeight();
                }
            }
        }
        UINT uListType = m_pOwner->GetListType();
        if(uListType == LT_LIST) {
            // 计算横向尺寸
            int nItemCount = m_items.GetSize();
            if (nItemCount > 0)
            {
                CControlUI* pControl = static_cast<CControlUI*>(m_items[0]);
                int nFixedWidth = pControl->GetFixedWidth();
                if (nFixedWidth > 0)
                {
                    int nRank = (rc.right - rc.left) / nFixedWidth;
                    if (nRank > 0)
                    {
                        cyNeeded = ((nItemCount - 1) / nRank + 1) * pControl->GetFixedHeight();
                    }
                }
            }
        }
        // Process the scrollbar
        ProcessScrollBar(rc, cxNeeded, cyNeeded);
    }

    void CListBodyUI::DoEvent(TEventUI& event)
    {
        if( !IsMouseEnabled() && event.Type > UIEVENT__MOUSEBEGIN && event.Type < UIEVENT__MOUSEEND ) {
            if( m_pOwner != NULL ) m_pOwner->DoEvent(event);
            else CVerticalLayoutUI::DoEvent(event);
            return;
        }

        CVerticalLayoutUI::DoEvent(event);
    }

    /////////////////////////////////////////////////////////////////////////////////////
    //
    //
    IMPLEMENT_DUICONTROL(CListHeaderUI)

    CListHeaderUI::CListHeaderUI():
    m_bIsScaleHeader(false)
    {
    }

    LPCTSTR CListHeaderUI::GetClass() const
    {
        return _T("ListHeaderUI");
    }

    LPVOID CListHeaderUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_LISTHEADER) == 0 ) return this;
        return CHorizontalLayoutUI::GetInterface(pstrName);
    }

    SIZE CListHeaderUI::EstimateSize(SIZE szAvailable)
    {
        SIZE cXY = {0, m_cxyFixed.cy};
        if( cXY.cy == 0 && m_pManager != NULL ) {
            for( int it = 0; it < m_items.GetSize(); it++ ) {
                cXY.cy = MAX(cXY.cy,static_cast<CControlUI*>(m_items[it])->EstimateSize(szAvailable).cy);
            }
            int nMin = m_pManager->GetDefaultFontInfo()->tm.tmHeight + 6;
            cXY.cy = MAX(cXY.cy,nMin);
        }

        for( int it = 0; it < m_items.GetSize(); it++ ) {
            cXY.cx +=  static_cast<CControlUI*>(m_items[it])->EstimateSize(szAvailable).cx;
        }

        return cXY;
    }

    void CListHeaderUI::SetPos(RECT rc, bool bNeedInvalidate)
    {
        CControlUI::SetPos(rc, bNeedInvalidate);
        rc = m_rcItem;

        // Adjust for inset
        rc.left += m_rcInset.left;
        rc.top += m_rcInset.top;
        rc.right -= m_rcInset.right;
        rc.bottom -= m_rcInset.bottom;

        if( m_items.GetSize() == 0) {
            return;
        }


        // Determine the width of elements that are sizeable
        SIZE szAvailable = { rc.right - rc.left, rc.bottom - rc.top };

        int nAdjustables = 0;
        int cxFixed = 0;
        int nEstimateNum = 0;
        for( int it1 = 0; it1 < m_items.GetSize(); it1++ ) {
            CControlUI* pControl = static_cast<CControlUI*>(m_items[it1]);
            if( !pControl->IsVisible() ) continue;
            if( pControl->IsFloat() ) continue;
            SIZE sz = pControl->EstimateSize(szAvailable);
            if( sz.cx == 0 ) {
                nAdjustables++;
            }
            else {
                if( sz.cx < pControl->GetMinWidth() ) sz.cx = pControl->GetMinWidth();
                if( sz.cx > pControl->GetMaxWidth() ) sz.cx = pControl->GetMaxWidth();
            }
            cxFixed += sz.cx +  pControl->GetPadding().left + pControl->GetPadding().right;
            nEstimateNum++;
        }
        cxFixed += (nEstimateNum - 1) * m_iChildPadding;

        int cxExpand = 0;
        int cxNeeded = 0;
        if( nAdjustables > 0 ) cxExpand = MAX(0, (szAvailable.cx - cxFixed) / nAdjustables);
        // Position the elements
        SIZE szRemaining = szAvailable;
        int iPosX = rc.left;

        int iAdjustable = 0;
        int cxFixedRemaining = cxFixed;

        int nHeaderWidth = GetWidth();
        CListUI *pList = static_cast<CListUI*>(GetParent());
        if (pList != NULL)
        {
            CScrollBarUI* pVScroll = pList->GetVerticalScrollBar();
            if (pVScroll != NULL)
                nHeaderWidth -= pVScroll->GetWidth();
        }
        for( int it2 = 0; it2 < m_items.GetSize(); it2++ ) {
            CControlUI* pControl = static_cast<CControlUI*>(m_items[it2]);
            if( !pControl->IsVisible() ) continue;
            if( pControl->IsFloat() ) {
                SetFloatPos(it2);
                continue;
            }
            RECT rcPadding = pControl->GetPadding();
            szRemaining.cx -= rcPadding.left;

            SIZE sz = {0,0};
            if (m_bIsScaleHeader)
            {
                CListHeaderItemUI* pHeaderItem = static_cast<CListHeaderItemUI*>(pControl);
                sz.cx = int(nHeaderWidth * (float)pHeaderItem->GetScale() / 100);
            }
            else
            {
                sz = pControl->EstimateSize(szRemaining);
            }

            if( sz.cx == 0 ) {
                iAdjustable++;
                sz.cx = cxExpand;
                // Distribute remaining to last element (usually round-off left-overs)
                if( iAdjustable == nAdjustables ) {
                    sz.cx = MAX(0, szRemaining.cx - rcPadding.right - cxFixedRemaining);
                }
                if( sz.cx < pControl->GetMinWidth() ) sz.cx = pControl->GetMinWidth();
                if( sz.cx > pControl->GetMaxWidth() ) sz.cx = pControl->GetMaxWidth();
            }
            else {
                if( sz.cx < pControl->GetMinWidth() ) sz.cx = pControl->GetMinWidth();
                if( sz.cx > pControl->GetMaxWidth() ) sz.cx = pControl->GetMaxWidth();

                cxFixedRemaining -= sz.cx;
            }

            sz.cy = pControl->GetFixedHeight();
            if( sz.cy == 0 ) sz.cy = rc.bottom - rc.top - rcPadding.top - rcPadding.bottom;
            if( sz.cy < 0 ) sz.cy = 0;
            if( sz.cy < pControl->GetMinHeight() ) sz.cy = pControl->GetMinHeight();
            if( sz.cy > pControl->GetMaxHeight() ) sz.cy = pControl->GetMaxHeight();

            RECT rcCtrl = { iPosX + rcPadding.left, rc.top + rcPadding.top, iPosX + sz.cx + rcPadding.left + rcPadding.right, rc.top + rcPadding.top + sz.cy};
            pControl->SetPos(rcCtrl);
            iPosX += sz.cx + m_iChildPadding + rcPadding.left + rcPadding.right;
            cxNeeded += sz.cx + rcPadding.left + rcPadding.right;
            szRemaining.cx -= sz.cx + m_iChildPadding + rcPadding.right;
        }
        cxNeeded += (nEstimateNum - 1) * m_iChildPadding;
    }

    void CListHeaderUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if( _tcsicmp(pstrName, _T("scaleheader")) == 0 ) SetScaleHeader(_tcsicmp(pstrValue, _T("true")) == 0);
        else CHorizontalLayoutUI::SetAttribute(pstrName, pstrValue);
    }

    void CListHeaderUI::SetScaleHeader(bool bIsScale)
    {
        m_bIsScaleHeader = bIsScale;
    }

    bool CListHeaderUI::IsScaleHeader() const
    {
        return m_bIsScaleHeader;
    }
    /////////////////////////////////////////////////////////////////////////////////////
    //
    //
    IMPLEMENT_DUICONTROL(CListHeaderItemUI)

        CListHeaderItemUI::CListHeaderItemUI() : m_bDragable(true), m_uButtonState(0), m_iSepWidth(4),
        m_uTextStyle(DT_VCENTER | DT_CENTER | DT_SINGLELINE), m_dwTextColor(0), m_iFont(-1), m_bShowHtml(false),m_nScale(0)
    {
        SetTextPadding(CDuiRect(2, 0, 2, 0));
        ptLastMouse.x = ptLastMouse.y = 0;
        SetMinWidth(16);
    }

    LPCTSTR CListHeaderItemUI::GetClass() const
    {
        return _T("ListHeaderItemUI");
    }

    LPVOID CListHeaderItemUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_LISTHEADERITEM) == 0 ) return this;
        return CContainerUI::GetInterface(pstrName);
    }

    UINT CListHeaderItemUI::GetControlFlags() const
    {
        if( IsEnabled() && m_iSepWidth != 0 ) return UIFLAG_SETCURSOR;
        else return 0;
    }

    void CListHeaderItemUI::SetEnabled(bool bEnable)
    {
        CContainerUI::SetEnabled(bEnable);
        if( !IsEnabled() ) {
            m_uButtonState = 0;
        }
    }

    bool CListHeaderItemUI::IsDragable() const
    {
        return m_bDragable;
    }

    void CListHeaderItemUI::SetDragable(bool bDragable)
    {
        m_bDragable = bDragable;
        if ( !m_bDragable ) m_uButtonState &= ~UISTATE_CAPTURED;
    }

    DWORD CListHeaderItemUI::GetSepWidth() const
    {
        return m_iSepWidth;
    }

    void CListHeaderItemUI::SetSepWidth(int iWidth)
    {
        m_iSepWidth = iWidth;
    }

    DWORD CListHeaderItemUI::GetTextStyle() const
    {
        return m_uTextStyle;
    }

    void CListHeaderItemUI::SetTextStyle(UINT uStyle)
    {
        m_uTextStyle = uStyle;
        Invalidate();
    }

    DWORD CListHeaderItemUI::GetTextColor() const
    {
        return m_dwTextColor;
    }


    void CListHeaderItemUI::SetTextColor(DWORD dwTextColor)
    {
        m_dwTextColor = dwTextColor;
    }

    RECT CListHeaderItemUI::GetTextPadding() const
    {
        return m_rcTextPadding;
    }

    void CListHeaderItemUI::SetTextPadding(RECT rc)
    {
        m_rcTextPadding = rc;
        Invalidate();
    }

    void CListHeaderItemUI::SetFont(int index)
    {
        m_iFont = index;
    }

    bool CListHeaderItemUI::IsShowHtml()
    {
        return m_bShowHtml;
    }

    void CListHeaderItemUI::SetShowHtml(bool bShowHtml)
    {
        if( m_bShowHtml == bShowHtml ) return;

        m_bShowHtml = bShowHtml;
        Invalidate();
    }

    LPCTSTR CListHeaderItemUI::GetNormalImage() const
    {
        return m_sNormalImage;
    }

    void CListHeaderItemUI::SetNormalImage(LPCTSTR pStrImage)
    {
        m_sNormalImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CListHeaderItemUI::GetHotImage() const
    {
        return m_sHotImage;
    }

    void CListHeaderItemUI::SetHotImage(LPCTSTR pStrImage)
    {
        m_sHotImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CListHeaderItemUI::GetPushedImage() const
    {
        return m_sPushedImage;
    }

    void CListHeaderItemUI::SetPushedImage(LPCTSTR pStrImage)
    {
        m_sPushedImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CListHeaderItemUI::GetFocusedImage() const
    {
        return m_sFocusedImage;
    }

    void CListHeaderItemUI::SetFocusedImage(LPCTSTR pStrImage)
    {
        m_sFocusedImage = pStrImage;
        Invalidate();
    }

    LPCTSTR CListHeaderItemUI::GetSepImage() const
    {
        return m_sSepImage;
    }

    void CListHeaderItemUI::SetSepImage(LPCTSTR pStrImage)
    {
        m_sSepImage = pStrImage;
        Invalidate();
    }

    void CListHeaderItemUI::SetScale(int nScale)
    {
        m_nScale = nScale;
    }

    int CListHeaderItemUI::GetScale() const
    {
        return m_nScale;
    }

    void CListHeaderItemUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if( _tcsicmp(pstrName, _T("dragable")) == 0 ) SetDragable(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("sepwidth")) == 0 ) SetSepWidth(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("align")) == 0 ) {
            if( _tcsstr(pstrValue, _T("left")) != NULL ) {
                m_uTextStyle &= ~(DT_CENTER | DT_RIGHT);
                m_uTextStyle |= DT_LEFT;
            }
            if( _tcsstr(pstrValue, _T("center")) != NULL ) {
                m_uTextStyle &= ~(DT_LEFT | DT_RIGHT);
                m_uTextStyle |= DT_CENTER;
            }
            if( _tcsstr(pstrValue, _T("right")) != NULL ) {
                m_uTextStyle &= ~(DT_LEFT | DT_CENTER);
                m_uTextStyle |= DT_RIGHT;
            }
        }
        else if( _tcsicmp(pstrName, _T("endellipsis")) == 0 ) {
            if( _tcsicmp(pstrValue, _T("true")) == 0 ) m_uTextStyle |= DT_END_ELLIPSIS;
            else m_uTextStyle &= ~DT_END_ELLIPSIS;
        }    
        else if( _tcsicmp(pstrName, _T("font")) == 0 ) SetFont(_ttoi(pstrValue));
        else if( _tcsicmp(pstrName, _T("textcolor")) == 0 ) {
            if( *pstrValue == _T('#')) pstrValue = ::CharNext(pstrValue);
            LPTSTR pstr = NULL;
            DWORD clrColor = _tcstoul(pstrValue, &pstr, 16);
            SetTextColor(clrColor);
        }
        else if( _tcsicmp(pstrName, _T("textpadding")) == 0 ) {
            RECT rcTextPadding = { 0 };
            LPTSTR pstr = NULL;
            rcTextPadding.left = _tcstol(pstrValue, &pstr, 10);  ASSERT(pstr);    
            rcTextPadding.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
            rcTextPadding.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
            rcTextPadding.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
            SetTextPadding(rcTextPadding);
        }
        else if( _tcsicmp(pstrName, _T("showhtml")) == 0 ) SetShowHtml(_tcsicmp(pstrValue, _T("true")) == 0);
        else if( _tcsicmp(pstrName, _T("normalimage")) == 0 ) SetNormalImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("hotimage")) == 0 ) SetHotImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("pushedimage")) == 0 ) SetPushedImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("focusedimage")) == 0 ) SetFocusedImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("sepimage")) == 0 ) SetSepImage(pstrValue);
        else if( _tcsicmp(pstrName, _T("scale")) == 0 ) {
            LPTSTR pstr = NULL;
            SetScale(_tcstol(pstrValue, &pstr, 10)); 

        }
        else CContainerUI::SetAttribute(pstrName, pstrValue);
    }

    void CListHeaderItemUI::DoEvent(TEventUI& event)
    {
        if( !IsMouseEnabled() && event.Type > UIEVENT__MOUSEBEGIN && event.Type < UIEVENT__MOUSEEND ) {
            if( m_pParent != NULL ) m_pParent->DoEvent(event);
            else CContainerUI::DoEvent(event);
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
        if( event.Type == UIEVENT_BUTTONDOWN || event.Type == UIEVENT_DBLCLICK )
        {
            if( !IsEnabled() ) return;
            RECT rcSeparator = GetThumbRect();
            if (m_iSepWidth>=0)
                rcSeparator.left-=4;
            else
                rcSeparator.right+=4;
            if( ::PtInRect(&rcSeparator, event.ptMouse) ) {
                if( m_bDragable ) {
                    m_uButtonState |= UISTATE_CAPTURED;
                    ptLastMouse = event.ptMouse;
                }
            }
            else {
                m_uButtonState |= UISTATE_PUSHED;
                m_pManager->SendNotify(this, DUI_MSGTYPE_HEADERCLICK);
                Invalidate();
            }
            return;
        }
        if( event.Type == UIEVENT_BUTTONUP )
        {
            if( (m_uButtonState & UISTATE_CAPTURED) != 0 ) {
                m_uButtonState &= ~UISTATE_CAPTURED;
                if( GetParent() ) 
                    GetParent()->NeedParentUpdate();
            }
            else if( (m_uButtonState & UISTATE_PUSHED) != 0 ) {
                m_uButtonState &= ~UISTATE_PUSHED;
                Invalidate();
            }
            return;
        }
        if( event.Type == UIEVENT_MOUSEMOVE )
        {
            if( (m_uButtonState & UISTATE_CAPTURED) != 0 ) {
                RECT rc = m_rcItem;
                if( m_iSepWidth >= 0 ) {
                    rc.right -= ptLastMouse.x - event.ptMouse.x;
                }
                else {
                    rc.left -= ptLastMouse.x - event.ptMouse.x;
                }

                if( rc.right - rc.left > GetMinWidth() ) {
                    m_cxyFixed.cx = rc.right - rc.left;
                    ptLastMouse = event.ptMouse;
                    if( GetParent() ) 
                        GetParent()->NeedParentUpdate();
                }
            }
            return;
        }
        if( event.Type == UIEVENT_SETCURSOR )
        {
            RECT rcSeparator = GetThumbRect();
            if (m_iSepWidth>=0)
                rcSeparator.left-=4;
            else
                rcSeparator.right+=4;
            if( IsEnabled() && m_bDragable && ::PtInRect(&rcSeparator, event.ptMouse) ) {
                ::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(IDC_SIZEWE)));
                return;
            }
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
        CContainerUI::DoEvent(event);
    }

    SIZE CListHeaderItemUI::EstimateSize(SIZE szAvailable)
    {
        if( m_cxyFixed.cy == 0 ) return CDuiSize(m_cxyFixed.cx, m_pManager->GetDefaultFontInfo()->tm.tmHeight + 14);
        return CContainerUI::EstimateSize(szAvailable);
    }

    RECT CListHeaderItemUI::GetThumbRect() const
    {
        if( m_iSepWidth >= 0 ) return CDuiRect(m_rcItem.right - m_iSepWidth, m_rcItem.top, m_rcItem.right, m_rcItem.bottom);
        else return CDuiRect(m_rcItem.left, m_rcItem.top, m_rcItem.left - m_iSepWidth, m_rcItem.bottom);
    }

    void CListHeaderItemUI::PaintStatusImage(HDC hDC)
    {
        if( IsFocused() ) m_uButtonState |= UISTATE_FOCUSED;
        else m_uButtonState &= ~ UISTATE_FOCUSED;

        if( (m_uButtonState & UISTATE_PUSHED) != 0 ) {
            if( m_sPushedImage.IsEmpty() && !m_sNormalImage.IsEmpty() ) DrawImage(hDC, (LPCTSTR)m_sNormalImage);
            if( !DrawImage(hDC, (LPCTSTR)m_sPushedImage) ) {}
        }
        else if( (m_uButtonState & UISTATE_HOT) != 0 ) {
            if( m_sHotImage.IsEmpty() && !m_sNormalImage.IsEmpty() ) DrawImage(hDC, (LPCTSTR)m_sNormalImage);
            if( !DrawImage(hDC, (LPCTSTR)m_sHotImage) ) {}
        }
        else if( (m_uButtonState & UISTATE_FOCUSED) != 0 ) {
            if( m_sFocusedImage.IsEmpty() && !m_sNormalImage.IsEmpty() ) DrawImage(hDC, (LPCTSTR)m_sNormalImage);
            if( !DrawImage(hDC, (LPCTSTR)m_sFocusedImage) ) {}
        }
        else {
            if( !m_sNormalImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sNormalImage) ) {}
            }
        }

        if( !m_sSepImage.IsEmpty() ) {
            RECT rcThumb = GetThumbRect();
            rcThumb.left -= m_rcItem.left;
            rcThumb.top -= m_rcItem.top;
            rcThumb.right -= m_rcItem.left;
            rcThumb.bottom -= m_rcItem.top;

            m_sSepImageModify.Empty();
            m_sSepImageModify.SmallFormat(_T("dest='%d,%d,%d,%d'"), rcThumb.left, rcThumb.top, rcThumb.right, rcThumb.bottom);
            if( !DrawImage(hDC, (LPCTSTR)m_sSepImage, (LPCTSTR)m_sSepImageModify) ) {}
        }
    }

    void CListHeaderItemUI::PaintText(HDC hDC)
    {
        if( m_dwTextColor == 0 ) m_dwTextColor = m_pManager->GetDefaultFontColor();

        RECT rcText = m_rcItem;
        rcText.left += m_rcTextPadding.left;
        rcText.top += m_rcTextPadding.top;
        rcText.right -= m_rcTextPadding.right;
        rcText.bottom -= m_rcTextPadding.bottom;

        CDuiString sText = GetText();
        if( sText.IsEmpty() ) return;
        int nLinks = 0;
        if( m_bShowHtml )
            CRenderEngine::DrawHtmlText(hDC, m_pManager, rcText, sText, m_dwTextColor, \
            NULL, NULL, nLinks, m_iFont, m_uTextStyle);
        else
            CRenderEngine::DrawText(hDC, m_pManager, rcText, sText, m_dwTextColor, \
            m_iFont, m_uTextStyle);
    }

    /////////////////////////////////////////////////////////////////////////////////////
    //
    //
        CListElementUI::CListElementUI() : m_iIndex(-1),
        m_pOwner(NULL), 
        m_bSelected(false),
        m_uButtonState(0)
    {
    }

    LPCTSTR CListElementUI::GetClass() const
    {
        return _T("ListElementUI");
    }

    UINT CListElementUI::GetControlFlags() const
    {
        return UIFLAG_WANTRETURN;
    }

    LPVOID CListElementUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_LISTITEM) == 0 ) return static_cast<IListItemUI*>(this);
        if( _tcsicmp(pstrName, DUI_CTR_LISTELEMENT) == 0 ) return static_cast<CListElementUI*>(this);
        return CControlUI::GetInterface(pstrName);
    }

    IListOwnerUI* CListElementUI::GetOwner()
    {
        return m_pOwner;
    }

    void CListElementUI::SetOwner(CControlUI* pOwner)
    {
        m_pOwner = static_cast<IListOwnerUI*>(pOwner->GetInterface(_T("IListOwner")));
    }

    void CListElementUI::SetVisible(bool bVisible)
    {
        CControlUI::SetVisible(bVisible);
        if( !IsVisible() && m_bSelected)
        {
            m_bSelected = false;
            if( m_pOwner != NULL ) m_pOwner->SelectItem(-1);
        }
    }

    void CListElementUI::SetEnabled(bool bEnable)
    {
        CControlUI::SetEnabled(bEnable);
        if( !IsEnabled() ) {
            m_uButtonState = 0;
        }
    }

    int CListElementUI::GetIndex() const
    {
        return m_iIndex;
    }

    void CListElementUI::SetIndex(int iIndex)
    {
        m_iIndex = iIndex;
    }

    void CListElementUI::Invalidate()
    {
        if( !IsVisible() ) return;

        if( GetParent() ) {
            CContainerUI* pParentContainer = static_cast<CContainerUI*>(GetParent()->GetInterface(_T("Container")));
            if( pParentContainer ) {
                RECT rc = pParentContainer->GetPos();
                RECT rcInset = pParentContainer->GetInset();
                rc.left += rcInset.left;
                rc.top += rcInset.top;
                rc.right -= rcInset.right;
                rc.bottom -= rcInset.bottom;
                CScrollBarUI* pVerticalScrollBar = pParentContainer->GetVerticalScrollBar();
                if( pVerticalScrollBar && pVerticalScrollBar->IsVisible() ) rc.right -= pVerticalScrollBar->GetFixedWidth();
                CScrollBarUI* pHorizontalScrollBar = pParentContainer->GetHorizontalScrollBar();
                if( pHorizontalScrollBar && pHorizontalScrollBar->IsVisible() ) rc.bottom -= pHorizontalScrollBar->GetFixedHeight();

                RECT invalidateRc = m_rcItem;
                if( !::IntersectRect(&invalidateRc, &m_rcItem, &rc) ) 
                {
                    return;
                }

                CControlUI* pParent = GetParent();
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
            else {
                CControlUI::Invalidate();
            }
        }
        else {
            CControlUI::Invalidate();
        }
    }

    bool CListElementUI::Activate()
    {
        if( !CControlUI::Activate() ) return false;
        if( m_pManager != NULL ) m_pManager->SendNotify(this, DUI_MSGTYPE_ITEMACTIVATE);
        return true;
    }

    bool CListElementUI::IsSelected() const
    {
        return m_bSelected;
    }

    bool CListElementUI::Select(bool bSelect)
    {
        if( !IsEnabled() ) return false;
        if( m_pOwner != NULL && m_bSelected ) m_pOwner->UnSelectItem(m_iIndex, true);
        if( bSelect == m_bSelected ) return true;
        m_bSelected = bSelect;
        if( bSelect && m_pOwner != NULL ) m_pOwner->SelectItem(m_iIndex);
        Invalidate();

        return true;
    }

    bool CListElementUI::SelectMulti(bool bSelect)
    {
        if( !IsEnabled() ) return false;
        if( bSelect == m_bSelected ) return true;

        m_bSelected = bSelect;
        if( bSelect && m_pOwner != NULL ) m_pOwner->SelectMultiItem(m_iIndex);
        Invalidate();
        return true;
    }

    bool CListElementUI::IsExpanded() const
    {
        return false;
    }

    bool CListElementUI::Expand(bool /*bExpand = true*/)
    {
        return false;
    }

    void CListElementUI::DoEvent(TEventUI& event)
    {
        if( !IsMouseEnabled() && event.Type > UIEVENT__MOUSEBEGIN && event.Type < UIEVENT__MOUSEEND ) {
            if( m_pOwner != NULL ) m_pOwner->DoEvent(event);
            else CControlUI::DoEvent(event);
            return;
        }

        if( event.Type == UIEVENT_DBLCLICK )
        {
            if( IsEnabled() ) {
                Activate();
                Invalidate();
            }
            return;
        }
        if( event.Type == UIEVENT_KEYDOWN && IsEnabled() )
        {
            if( event.chKey == VK_RETURN ) {
                Activate();
                Invalidate();
                return;
            }
        }
        // An important twist: The list-item will send the event not to its immediate
        // parent but to the "attached" list. A list may actually embed several components
        // in its path to the item, but key-presses etc. needs to go to the actual list.
        if( m_pOwner != NULL ) m_pOwner->DoEvent(event); else CControlUI::DoEvent(event);
    }

    void CListElementUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if( _tcsicmp(pstrName, _T("selected")) == 0 ) Select();
        else CControlUI::SetAttribute(pstrName, pstrValue);
    }

    void CListElementUI::DrawItemBk(HDC hDC, const RECT& rcItem)
    {
        ASSERT(m_pOwner);
        if( m_pOwner == NULL ) return;
        TListInfoUI* pInfo = m_pOwner->GetListInfo();
        DWORD iBackColor = 0;
        if( !pInfo->bAlternateBk || m_iIndex % 2 == 0 ) iBackColor = pInfo->dwBkColor;
        if( (m_uButtonState & UISTATE_HOT) != 0 && pInfo->dwHotBkColor > 0) {
            iBackColor = pInfo->dwHotBkColor;
        }
        if( IsSelected() && pInfo->dwSelectedBkColor > 0) {
            iBackColor = pInfo->dwSelectedBkColor;
        }
        if( !IsEnabled() && pInfo->dwDisabledBkColor > 0) {
            iBackColor = pInfo->dwDisabledBkColor;
        }

        if ( iBackColor != 0 ) {
            CRenderEngine::DrawColor(hDC, m_rcItem, GetAdjustColor(iBackColor));
        }

        if( !IsEnabled() ) {
            if( !pInfo->sDisabledImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)pInfo->sDisabledImage) ) {}
                else return;
            }
        }
        if( IsSelected() ) {
            if( !pInfo->sSelectedImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)pInfo->sSelectedImage) ) {}
                else return;
            }
        }
        if( (m_uButtonState & UISTATE_HOT) != 0 ) {
            if( !pInfo->sHotImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)pInfo->sHotImage) ) {}
                else return;
            }
        }

        if( !m_sBkImage.IsEmpty() ) {
            if( !pInfo->bAlternateBk || m_iIndex % 2 == 0 ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sBkImage) ) {}
            }
        }

        if( m_sBkImage.IsEmpty() ) {
            if( !pInfo->sBkImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)pInfo->sBkImage) ) {}
                else return;
            }
        }

        if ( pInfo->dwLineColor != 0 ) {
            if(pInfo->bShowRowLine) {
                RECT rcLine = { m_rcItem.left, m_rcItem.bottom - 1, m_rcItem.right, m_rcItem.bottom - 1 };
                CRenderEngine::DrawLine(hDC, rcLine, 1, GetAdjustColor(pInfo->dwLineColor));
            }
            if(pInfo->bShowColumnLine) {
                for( int i = 0; i < pInfo->nColumns; i++ ) {
                    RECT rcLine = { pInfo->rcColumn[i].right-1, m_rcItem.top, pInfo->rcColumn[i].right-1, m_rcItem.bottom };
                    CRenderEngine::DrawLine(hDC, rcLine, 1, GetAdjustColor(pInfo->dwLineColor));
                }
            }
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////
    //
    //
    IMPLEMENT_DUICONTROL(CListLabelElementUI)

        CListLabelElementUI::CListLabelElementUI()
    {
    }

    LPCTSTR CListLabelElementUI::GetClass() const
    {
        return _T("ListLabelElementUI");
    }

    LPVOID CListLabelElementUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_LISTLABELELEMENT) == 0 ) return static_cast<CListLabelElementUI*>(this);
        return CListElementUI::GetInterface(pstrName);
    }

    void CListLabelElementUI::DoEvent(TEventUI& event)
    {
        if( !IsMouseEnabled() && event.Type > UIEVENT__MOUSEBEGIN && event.Type < UIEVENT__MOUSEEND ) {
            if( m_pOwner != NULL ) m_pOwner->DoEvent(event);
            else CListElementUI::DoEvent(event);
            return;
        }

        // 右键选择
        if(m_pOwner != NULL)
        {
            if( m_pOwner->GetListInfo()->bRSelected && event.Type == UIEVENT_RBUTTONDOWN )
            {
                if( IsEnabled() ){
                    if((GetKeyState(VK_CONTROL) & 0x8000)) {
                        SelectMulti(!IsSelected());
                    }
                    else Select();
                }
                return;
            }
        }

        if( event.Type == UIEVENT_BUTTONDOWN )
        {
            if( IsEnabled() ){
                if((GetKeyState(VK_CONTROL) & 0x8000)) {
                    SelectMulti(!IsSelected());
                }
                else {
                    Select();
                }
            }
            return;
        }
        if( event.Type == UIEVENT_BUTTONUP ) 
        {
            if( IsEnabled() ){
                m_pManager->SendNotify(this, DUI_MSGTYPE_ITEMCLICK);
            }
            return;
        }

        if( event.Type == UIEVENT_MOUSEMOVE ) 
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
            if( (m_uButtonState & UISTATE_HOT) != 0 ) {
                m_uButtonState &= ~UISTATE_HOT;
                Invalidate();
            }
            return;
        }
        CListElementUI::DoEvent(event);
    }

    SIZE CListLabelElementUI::EstimateSize(SIZE szAvailable)
    {
        if( m_pOwner == NULL ) return CDuiSize(0, 0);
        CDuiString sText = GetText();

        TListInfoUI* pInfo = m_pOwner->GetListInfo();
        SIZE cXY = m_cxyFixed;
        if( cXY.cy == 0 && m_pManager != NULL ) {
            cXY.cy = m_pManager->GetFontInfo(pInfo->nFont)->tm.tmHeight + 8;
            cXY.cy += pInfo->rcTextPadding.top + pInfo->rcTextPadding.bottom;
        }

        if( cXY.cx == 0 && m_pManager != NULL ) {
            RECT rcText = { 0, 0, 9999, cXY.cy };
            if( pInfo->bShowHtml ) {
                int nLinks = 0;
                CRenderEngine::DrawHtmlText(m_pManager->GetPaintDC(), m_pManager, rcText, sText, 0, NULL, NULL, nLinks, pInfo->nFont, DT_SINGLELINE | DT_CALCRECT | pInfo->uTextStyle & ~DT_RIGHT & ~DT_CENTER);
            }
            else {
                CRenderEngine::DrawText(m_pManager->GetPaintDC(), m_pManager, rcText, sText, 0, pInfo->nFont, DT_SINGLELINE | DT_CALCRECT | pInfo->uTextStyle & ~DT_RIGHT & ~DT_CENTER);
            }
            cXY.cx = rcText.right - rcText.left + pInfo->rcTextPadding.left + pInfo->rcTextPadding.right;        
        }

        return cXY;
    }

    bool CListLabelElementUI::DoPaint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl)
    {
        DrawItemBk(hDC, m_rcItem);
        DrawItemText(hDC, m_rcItem);
        return true;
    }

    void CListLabelElementUI::DrawItemText(HDC hDC, const RECT& rcItem)
    {
        CDuiString sText = GetText();
        if( sText.IsEmpty() ) return;

        if( m_pOwner == NULL ) return;
        TListInfoUI* pInfo = m_pOwner->GetListInfo();
        DWORD iTextColor = pInfo->dwTextColor;
        if( (m_uButtonState & UISTATE_HOT) != 0 ) {
            iTextColor = pInfo->dwHotTextColor;
        }
        if( IsSelected() ) {
            iTextColor = pInfo->dwSelectedTextColor;
        }
        if( !IsEnabled() ) {
            iTextColor = pInfo->dwDisabledTextColor;
        }
        int nLinks = 0;
        RECT rcText = rcItem;
        rcText.left += pInfo->rcTextPadding.left;
        rcText.right -= pInfo->rcTextPadding.right;
        rcText.top += pInfo->rcTextPadding.top;
        rcText.bottom -= pInfo->rcTextPadding.bottom;

        if( pInfo->bShowHtml )
            CRenderEngine::DrawHtmlText(hDC, m_pManager, rcText, sText, iTextColor, \
            NULL, NULL, nLinks, pInfo->nFont, pInfo->uTextStyle);
        else
            CRenderEngine::DrawText(hDC, m_pManager, rcText, sText, iTextColor, \
            pInfo->nFont, pInfo->uTextStyle);
    }


    /////////////////////////////////////////////////////////////////////////////////////
    //
    //
    IMPLEMENT_DUICONTROL(CListTextElementUI)

    CListTextElementUI::CListTextElementUI() : m_nLinks(0), m_nHoverLink(-1), m_pOwner(NULL)
    {
        ::ZeroMemory(&m_rcLinks, sizeof(m_rcLinks));
    }

    CListTextElementUI::~CListTextElementUI()
    {
        CDuiString* pText;
        for( int it = 0; it < m_aTexts.GetSize(); it++ ) {
            pText = static_cast<CDuiString*>(m_aTexts[it]);
            if( pText ) delete pText;
        }
        m_aTexts.Empty();
    }

    LPCTSTR CListTextElementUI::GetClass() const
    {
        return _T("ListTextElementUI");
    }

    LPVOID CListTextElementUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_LISTTEXTELEMENT) == 0 ) return static_cast<CListTextElementUI*>(this);
        return CListLabelElementUI::GetInterface(pstrName);
    }

    UINT CListTextElementUI::GetControlFlags() const
    {
        return UIFLAG_WANTRETURN | ( (IsEnabled() && m_nLinks > 0) ? UIFLAG_SETCURSOR : 0);
    }

    LPCTSTR CListTextElementUI::GetText(int iIndex) const
    {
        CDuiString* pText = static_cast<CDuiString*>(m_aTexts.GetAt(iIndex));
        if( pText ) {
            if (!IsResourceText()) 
                return pText->GetData();
            return CResourceManager::GetInstance()->GetText(*pText);
        }
        return NULL;
    }

    void CListTextElementUI::SetText(int iIndex, LPCTSTR pstrText)
    {
        if( m_pOwner == NULL ) return;

        TListInfoUI* pInfo = m_pOwner->GetListInfo();
        if( iIndex < 0 || iIndex >= pInfo->nColumns ) return;
        while( m_aTexts.GetSize() < pInfo->nColumns ) { m_aTexts.Add(NULL); }

        CDuiString* pText = static_cast<CDuiString*>(m_aTexts[iIndex]);
        if( (pText == NULL && pstrText == NULL) || (pText && *pText == pstrText) ) return;

        if ( pText ) {delete pText; pText = NULL;}
        m_aTexts.SetAt(iIndex, new CDuiString(pstrText));

        Invalidate();
    }

    void CListTextElementUI::SetOwner(CControlUI* pOwner)
    {
        CListElementUI::SetOwner(pOwner);
        m_pOwner = static_cast<IListUI*>(pOwner->GetInterface(_T("IList")));
    }

    CDuiString* CListTextElementUI::GetLinkContent(int iIndex)
    {
        if( iIndex >= 0 && iIndex < m_nLinks ) return &m_sLinks[iIndex];
        return NULL;
    }

    void CListTextElementUI::DoEvent(TEventUI& event)
    {
        if( !IsMouseEnabled() && event.Type > UIEVENT__MOUSEBEGIN && event.Type < UIEVENT__MOUSEEND ) {
            if( m_pOwner != NULL ) m_pOwner->DoEvent(event);
            else CListLabelElementUI::DoEvent(event);
            return;
        }

        // When you hover over a link
        if( event.Type == UIEVENT_SETCURSOR ) {
            for( int i = 0; i < m_nLinks; i++ ) {
                if( ::PtInRect(&m_rcLinks[i], event.ptMouse) ) {
                    ::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(IDC_HAND)));
                    return;
                }
            }      
        }
        if( event.Type == UIEVENT_BUTTONUP && IsEnabled() ) {
            for( int i = 0; i < m_nLinks; i++ ) {
                if( ::PtInRect(&m_rcLinks[i], event.ptMouse) ) {
                    m_pManager->SendNotify(this, DUI_MSGTYPE_LINK, i);
                    return;
                }
            }
        }
        if( m_nLinks > 0 && event.Type == UIEVENT_MOUSEMOVE ) {
            int nHoverLink = -1;
            for( int i = 0; i < m_nLinks; i++ ) {
                if( ::PtInRect(&m_rcLinks[i], event.ptMouse) ) {
                    nHoverLink = i;
                    break;
                }
            }

            if(m_nHoverLink != nHoverLink) {
                Invalidate();
                m_nHoverLink = nHoverLink;
            }
        }
        if( m_nLinks > 0 && event.Type == UIEVENT_MOUSELEAVE ) {
            if(m_nHoverLink != -1) {
                Invalidate();
                m_nHoverLink = -1;
            }
        }
        CListLabelElementUI::DoEvent(event);
    }

    SIZE CListTextElementUI::EstimateSize(SIZE szAvailable)
    {
        TListInfoUI* pInfo = NULL;
        if( m_pOwner ) pInfo = m_pOwner->GetListInfo();

        SIZE cXY = m_cxyFixed;
        if( cXY.cy == 0 && m_pManager != NULL ) {
            cXY.cy = m_pManager->GetFontInfo(pInfo->nFont)->tm.tmHeight + 8;
            if( pInfo ) cXY.cy += pInfo->rcTextPadding.top + pInfo->rcTextPadding.bottom;
        }

        return cXY;
    }

    void CListTextElementUI::DrawItemText(HDC hDC, const RECT& rcItem)
    {
        if( m_pOwner == NULL ) return;
        TListInfoUI* pInfo = m_pOwner->GetListInfo();
        DWORD iTextColor = pInfo->dwTextColor;

        if( (m_uButtonState & UISTATE_HOT) != 0 ) {
            iTextColor = pInfo->dwHotTextColor;
        }
        if( IsSelected() ) {
            iTextColor = pInfo->dwSelectedTextColor;
        }
        if( !IsEnabled() ) {
            iTextColor = pInfo->dwDisabledTextColor;
        }
        IListCallbackUI* pCallback = m_pOwner->GetTextCallback();

        m_nLinks = 0;
        int nLinks = lengthof(m_rcLinks);
        for( int i = 0; i < pInfo->nColumns; i++ )
        {
            RECT rcItem = { pInfo->rcColumn[i].left, m_rcItem.top, pInfo->rcColumn[i].right, m_rcItem.bottom };
            rcItem.left += pInfo->rcTextPadding.left;
            rcItem.right -= pInfo->rcTextPadding.right;
            rcItem.top += pInfo->rcTextPadding.top;
            rcItem.bottom -= pInfo->rcTextPadding.bottom;

            CDuiString strText;
            if( pCallback ) strText = pCallback->GetItemText(this, m_iIndex, i);
            else strText.Assign(GetText(i));

            if( pInfo->bShowHtml )
                CRenderEngine::DrawHtmlText(hDC, m_pManager, rcItem, strText.GetData(), iTextColor, \
                &m_rcLinks[m_nLinks], &m_sLinks[m_nLinks], nLinks, pInfo->nFont, pInfo->uTextStyle);
            else
                CRenderEngine::DrawText(hDC, m_pManager, rcItem, strText.GetData(), iTextColor, \
                pInfo->nFont, pInfo->uTextStyle);

            m_nLinks += nLinks;
            nLinks = lengthof(m_rcLinks) - m_nLinks; 
        }
        for( int i = m_nLinks; i < lengthof(m_rcLinks); i++ ) {
            ::ZeroMemory(m_rcLinks + i, sizeof(RECT));
            ((CDuiString*)(m_sLinks + i))->Empty();
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////
    //
    //
    IMPLEMENT_DUICONTROL(CListContainerElementUI)

    CListContainerElementUI::CListContainerElementUI() : 
        m_iIndex(-1),
        m_pOwner(NULL), 
        m_bSelected(false),
        m_uButtonState(0)
    {
    }

    LPCTSTR CListContainerElementUI::GetClass() const
    {
        return _T("ListContainerElementUI");
    }

    UINT CListContainerElementUI::GetControlFlags() const
    {
        return UIFLAG_WANTRETURN;
    }

    LPVOID CListContainerElementUI::GetInterface(LPCTSTR pstrName)
    {
        if( _tcsicmp(pstrName, DUI_CTR_LISTITEM) == 0 ) return static_cast<IListItemUI*>(this);
        if( _tcsicmp(pstrName, DUI_CTR_LISTCONTAINERELEMENT) == 0 ) return static_cast<CListContainerElementUI*>(this);
        return CContainerUI::GetInterface(pstrName);
    }

    IListOwnerUI* CListContainerElementUI::GetOwner()
    {
        return m_pOwner;
    }

    void CListContainerElementUI::SetOwner(CControlUI* pOwner)
    {
        m_pOwner = static_cast<IListOwnerUI*>(pOwner->GetInterface(_T("IListOwner")));
    }

    void CListContainerElementUI::SetVisible(bool bVisible)
    {
        CContainerUI::SetVisible(bVisible);
        if( !IsVisible() && m_bSelected)
        {
            m_bSelected = false;
            if( m_pOwner != NULL ) m_pOwner->SelectItem(-1);
        }
    }

    void CListContainerElementUI::SetEnabled(bool bEnable)
    {
        CControlUI::SetEnabled(bEnable);
        if( !IsEnabled() ) {
            m_uButtonState = 0;
        }
    }

    int CListContainerElementUI::GetIndex() const
    {
        return m_iIndex;
    }

    void CListContainerElementUI::SetIndex(int iIndex)
    {
        m_iIndex = iIndex;
    }

    void CListContainerElementUI::Invalidate()
    {
        if( !IsVisible() ) return;

        if( GetParent() ) {
            CContainerUI* pParentContainer = static_cast<CContainerUI*>(GetParent()->GetInterface(_T("Container")));
            if( pParentContainer ) {
                RECT rc = pParentContainer->GetPos();
                RECT rcInset = pParentContainer->GetInset();
                rc.left += rcInset.left;
                rc.top += rcInset.top;
                rc.right -= rcInset.right;
                rc.bottom -= rcInset.bottom;
                CScrollBarUI* pVerticalScrollBar = pParentContainer->GetVerticalScrollBar();
                if( pVerticalScrollBar && pVerticalScrollBar->IsVisible() ) rc.right -= pVerticalScrollBar->GetFixedWidth();
                CScrollBarUI* pHorizontalScrollBar = pParentContainer->GetHorizontalScrollBar();
                if( pHorizontalScrollBar && pHorizontalScrollBar->IsVisible() ) rc.bottom -= pHorizontalScrollBar->GetFixedHeight();

                RECT invalidateRc = m_rcItem;
                if( !::IntersectRect(&invalidateRc, &m_rcItem, &rc) ) 
                {
                    return;
                }

                CControlUI* pParent = GetParent();
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
            else {
                CContainerUI::Invalidate();
            }
        }
        else {
            CContainerUI::Invalidate();
        }
    }

    bool CListContainerElementUI::Activate()
    {
        if( !CContainerUI::Activate() ) return false;
        if( m_pManager != NULL ) m_pManager->SendNotify(this, DUI_MSGTYPE_ITEMACTIVATE);
        return true;
    }

    bool CListContainerElementUI::IsSelected() const
    {
        return m_bSelected;
    }

    bool CListContainerElementUI::Select(bool bSelect)
    {
        if( !IsEnabled() ) return false;
        if( m_pOwner != NULL && m_bSelected ) m_pOwner->UnSelectItem(m_iIndex, true);
        if( bSelect == m_bSelected ) return true;
        m_bSelected = bSelect;
        if( bSelect && m_pOwner != NULL ) m_pOwner->SelectItem(m_iIndex);
        Invalidate();

        return true;
    }

    bool CListContainerElementUI::SelectMulti(bool bSelect)
    {
        if( !IsEnabled() ) return false;
        if( bSelect == m_bSelected ) return true;

        m_bSelected = bSelect;
        if( bSelect && m_pOwner != NULL ) m_pOwner->SelectMultiItem(m_iIndex);
        Invalidate();
        return true;
    }

    bool CListContainerElementUI::IsExpanded() const
    {
        return false;
    }

    bool CListContainerElementUI::Expand(bool /*bExpand = true*/)
    {
        return false;
    }

    void CListContainerElementUI::DoEvent(TEventUI& event)
    {
        if( !IsMouseEnabled() && event.Type > UIEVENT__MOUSEBEGIN && event.Type < UIEVENT__MOUSEEND ) {
            if( m_pOwner != NULL ) m_pOwner->DoEvent(event);
            else CContainerUI::DoEvent(event);
            return;
        }

        if( event.Type == UIEVENT_DBLCLICK )
        {
            if( IsEnabled() ) {
                Activate();
                Invalidate();
            }
            return;
        }
        if( event.Type == UIEVENT_KEYDOWN && IsEnabled() )
        {
            if( event.chKey == VK_RETURN ) {
                Activate();
                Invalidate();
                return;
            }
        }
        if( event.Type == UIEVENT_BUTTONDOWN )
        {
            if( IsEnabled() ){
                if((GetKeyState(VK_CONTROL) & 0x8000)) {
                    SelectMulti(!IsSelected());
                }
                else Select();
            }
            return;
        }
        // 右键选择
        if(m_pOwner != NULL)
        {
            if( m_pOwner->GetListInfo()->bRSelected && event.Type == UIEVENT_RBUTTONDOWN )
            {
                if( IsEnabled() ){
                    if((GetKeyState(VK_CONTROL) & 0x8000)) {
                        SelectMulti(!IsSelected());
                    }
                    else Select();
                }
                return;
            }
        }

        if( event.Type == UIEVENT_BUTTONUP ) 
        {
            if( IsEnabled() ){
                m_pManager->SendNotify(this, DUI_MSGTYPE_ITEMCLICK);
            }
            return;
        }
        if( event.Type == UIEVENT_MOUSEMOVE )
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
            if( (m_uButtonState & UISTATE_HOT) != 0 ) {
                m_uButtonState &= ~UISTATE_HOT;
                Invalidate();
            }
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
        // An important twist: The list-item will send the event not to its immediate
        // parent but to the "attached" list. A list may actually embed several components
        // in its path to the item, but key-presses etc. needs to go to the actual list.
        if( m_pOwner != NULL ) m_pOwner->DoEvent(event); else CControlUI::DoEvent(event);
    }

    void CListContainerElementUI::SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue)
    {
        if( _tcsicmp(pstrName, _T("selected")) == 0 ) Select();
        //else if( _tcscmp(pstrName, _T("expandable")) == 0 ) SetExpandable(_tcscmp(pstrValue, _T("true")) == 0);
        else CContainerUI::SetAttribute(pstrName, pstrValue);
    }

    bool CListContainerElementUI::DoPaint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl)
    {
        DrawItemBk(hDC, m_rcItem);
        return CContainerUI::DoPaint(hDC, rcPaint, pStopControl);
    }

    void CListContainerElementUI::DrawItemText(HDC hDC, const RECT& rcItem)
    {
        return;
    }

    void CListContainerElementUI::DrawItemBk(HDC hDC, const RECT& rcItem)
    {
        ASSERT(m_pOwner);
        if( m_pOwner == NULL ) return;
        TListInfoUI* pInfo = m_pOwner->GetListInfo();
        DWORD iBackColor = 0;
        if( !pInfo->bAlternateBk || m_iIndex % 2 == 0 ) iBackColor = pInfo->dwBkColor;

        if( (m_uButtonState & UISTATE_HOT) != 0 && pInfo->dwHotBkColor > 0) {
            iBackColor = pInfo->dwHotBkColor;
        }
        if( IsSelected() && pInfo->dwSelectedBkColor > 0) {
            iBackColor = pInfo->dwSelectedBkColor;
        }
        if( !IsEnabled() && pInfo->dwDisabledBkColor > 0) {
            iBackColor = pInfo->dwDisabledBkColor;
        }
        if ( iBackColor != 0 ) {
            CRenderEngine::DrawColor(hDC, m_rcItem, GetAdjustColor(iBackColor));
        }

        if( !IsEnabled() ) {
            if( !pInfo->sDisabledImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)pInfo->sDisabledImage) ) {}
                else return;
            }
        }
        if( IsSelected() ) {
            if( !pInfo->sSelectedImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)pInfo->sSelectedImage) ) {}
                else return;
            }
        }
        if( (m_uButtonState & UISTATE_HOT) != 0 ) {
            if( !pInfo->sHotImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)pInfo->sHotImage) ) {}
                else return;
            }
        }
        if( !m_sBkImage.IsEmpty() ) {
            if( !pInfo->bAlternateBk || m_iIndex % 2 == 0 ) {
                if( !DrawImage(hDC, (LPCTSTR)m_sBkImage) ) {}
            }
        }

        if( m_sBkImage.IsEmpty() ) {
            if( !pInfo->sBkImage.IsEmpty() ) {
                if( !DrawImage(hDC, (LPCTSTR)pInfo->sBkImage) ) {}
                else return;
            }
        }

        if ( pInfo->dwLineColor != 0 ) {
            if(pInfo->bShowRowLine) {
                RECT rcLine = { m_rcItem.left, m_rcItem.bottom - 1, m_rcItem.right, m_rcItem.bottom - 1 };
                CRenderEngine::DrawLine(hDC, rcLine, 1, GetAdjustColor(pInfo->dwLineColor));
            }
            if(pInfo->bShowColumnLine) {
                for( int i = 0; i < pInfo->nColumns; i++ ) {
                    RECT rcLine = { pInfo->rcColumn[i].right-1, m_rcItem.top, pInfo->rcColumn[i].right-1, m_rcItem.bottom };
                    CRenderEngine::DrawLine(hDC, rcLine, 1, GetAdjustColor(pInfo->dwLineColor));
                }
            }
        }
    }

    void CListContainerElementUI::SetPos(RECT rc, bool bNeedInvalidate)
    {
        if( m_pOwner == NULL ) return;

        UINT uListType = m_pOwner->GetListType();
        if(uListType == LT_LIST) {
            int nFixedWidth = GetFixedWidth();
            if (nFixedWidth > 0)
            {
                int nRank = (rc.right - rc.left) / nFixedWidth;
                if (nRank > 0)
                {
                    int nIndex = GetIndex();
                    int nfloor = nIndex / nRank;
                    int nHeight = rc.bottom - rc.top;

                    rc.top = rc.top - nHeight * (nIndex - nfloor);
                    rc.left = rc.left + nFixedWidth * (nIndex % nRank);
                    rc.right = rc.left + nFixedWidth;
                    rc.bottom = nHeight + rc.top;
                }
            }
        }
        CHorizontalLayoutUI::SetPos(rc, bNeedInvalidate);

        if(uListType != LT_LIST && uListType != LT_TREE) return;
        CListUI* pList = static_cast<CListUI*>(m_pOwner);
         if (uListType == LT_TREE)
         {
             pList = (CListUI*)pList->CControlUI::GetInterface(_T("List"));
            if (pList == NULL) return;
         }

        CListHeaderUI *pHeader = pList->GetHeader();
        if (pHeader == NULL || !pHeader->IsVisible()) return;
        int nCount = m_items.GetSize();
        for (int i = 0; i < nCount; i++)
        {
            CControlUI *pListItem = static_cast<CControlUI*>(m_items[i]);
            CControlUI *pHeaderItem = pHeader->GetItemAt(i);
            if (pHeaderItem == NULL) return;
            RECT rcHeaderItem = pHeaderItem->GetPos();
            if (pListItem != NULL && !(rcHeaderItem.left ==0 && rcHeaderItem.right ==0) )
            {
                RECT rt = pListItem->GetPos();
                rt.left = rcHeaderItem.left;
                rt.right = rcHeaderItem.right;
                pListItem->SetPos(rt);
            }
        }
    }
} // namespace DuiLib
