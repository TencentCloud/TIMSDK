#ifndef __UICOMBO_H__
#define __UICOMBO_H__

#pragma once

namespace DuiLib {
    /////////////////////////////////////////////////////////////////////////////////////
    //

    class CComboWnd;

    class UILIB_API CComboUI : public CContainerUI, public IListOwnerUI
    {
        DECLARE_DUICONTROL(CComboUI)
        friend class CComboWnd;
    public:
        CComboUI();

        LPCTSTR GetClass() const;
        LPVOID GetInterface(LPCTSTR pstrName);

        void DoInit();
        UINT GetControlFlags() const;

        CDuiString GetText() const;
        void SetEnabled(bool bEnable = true);

        void SetTextStyle(UINT uStyle);
        UINT GetTextStyle() const;
        void SetTextColor(DWORD dwTextColor);
        DWORD GetTextColor() const;
        void SetDisabledTextColor(DWORD dwTextColor);
        DWORD GetDisabledTextColor() const;
        void SetFont(int index);
        int GetFont() const;
        RECT GetTextPadding() const;
        void SetTextPadding(RECT rc);
        bool IsShowHtml();
        void SetShowHtml(bool bShowHtml = true);
        bool IsShowShadow();
        void SetShowShadow(bool bShow = true);

        CDuiString GetDropBoxAttributeList();
        void SetDropBoxAttributeList(LPCTSTR pstrList);
        SIZE GetDropBoxSize() const;
        void SetDropBoxSize(SIZE szDropBox);

        UINT GetListType();
        TListInfoUI* GetListInfo();
        int GetCurSel() const;  
        bool SelectItem(int iIndex, bool bTakeFocus = false);
        bool SelectMultiItem(int iIndex, bool bTakeFocus = false);
        bool UnSelectItem(int iIndex, bool bOthers = false);
        bool SetItemIndex(CControlUI* pControl, int iIndex);

        bool Add(CControlUI* pControl);
        bool AddAt(CControlUI* pControl, int iIndex);
        bool Remove(CControlUI* pControl);
        bool RemoveAt(int iIndex);
        void RemoveAll();

        bool Activate();

        LPCTSTR GetNormalImage() const;
        void SetNormalImage(LPCTSTR pStrImage);
        LPCTSTR GetHotImage() const;
        void SetHotImage(LPCTSTR pStrImage);
        LPCTSTR GetPushedImage() const;
        void SetPushedImage(LPCTSTR pStrImage);
        LPCTSTR GetFocusedImage() const;
        void SetFocusedImage(LPCTSTR pStrImage);
        LPCTSTR GetDisabledImage() const;
        void SetDisabledImage(LPCTSTR pStrImage);

        bool GetScrollSelect();
        void SetScrollSelect(bool bScrollSelect);

        void SetItemFont(int index);
        void SetItemTextStyle(UINT uStyle);
        RECT GetItemTextPadding() const;
        void SetItemTextPadding(RECT rc);
        DWORD GetItemTextColor() const;
        void SetItemTextColor(DWORD dwTextColor);
        DWORD GetItemBkColor() const;
        void SetItemBkColor(DWORD dwBkColor);
        LPCTSTR GetItemBkImage() const;
        void SetItemBkImage(LPCTSTR pStrImage);
        bool IsAlternateBk() const;
        void SetAlternateBk(bool bAlternateBk);
        DWORD GetSelectedItemTextColor() const;
        void SetSelectedItemTextColor(DWORD dwTextColor);
        DWORD GetSelectedItemBkColor() const;
        void SetSelectedItemBkColor(DWORD dwBkColor);
        LPCTSTR GetSelectedItemImage() const;
        void SetSelectedItemImage(LPCTSTR pStrImage);
        DWORD GetHotItemTextColor() const;
        void SetHotItemTextColor(DWORD dwTextColor);
        DWORD GetHotItemBkColor() const;
        void SetHotItemBkColor(DWORD dwBkColor);
        LPCTSTR GetHotItemImage() const;
        void SetHotItemImage(LPCTSTR pStrImage);
        DWORD GetDisabledItemTextColor() const;
        void SetDisabledItemTextColor(DWORD dwTextColor);
        DWORD GetDisabledItemBkColor() const;
        void SetDisabledItemBkColor(DWORD dwBkColor);
        LPCTSTR GetDisabledItemImage() const;
        void SetDisabledItemImage(LPCTSTR pStrImage);
        DWORD GetItemLineColor() const;
        void SetItemLineColor(DWORD dwLineColor);
        bool IsItemShowHtml();
        void SetItemShowHtml(bool bShowHtml = true);

        SIZE EstimateSize(SIZE szAvailable);
        void SetPos(RECT rc, bool bNeedInvalidate = true);
        void Move(SIZE szOffset, bool bNeedInvalidate = true);
        void DoEvent(TEventUI& event);
        void SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue);

        bool DoPaint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl);
        void PaintText(HDC hDC);
        void PaintStatusImage(HDC hDC);

    protected:
        CComboWnd* m_pWindow;

        int m_iCurSel;
        DWORD    m_dwTextColor;
        DWORD    m_dwDisabledTextColor;
        int        m_iFont;
        UINT    m_uTextStyle;
        RECT    m_rcTextPadding;
        bool    m_bShowHtml;
        bool    m_bShowShadow;
        CDuiString m_sDropBoxAttributes;
        SIZE m_szDropBox;
        UINT m_uButtonState;

        CDuiString m_sNormalImage;
        CDuiString m_sHotImage;
        CDuiString m_sPushedImage;
        CDuiString m_sFocusedImage;
        CDuiString m_sDisabledImage;

        bool m_bScrollSelect;
        TListInfoUI m_ListInfo;
    };

} // namespace DuiLib

#endif // __UICOMBO_H__
