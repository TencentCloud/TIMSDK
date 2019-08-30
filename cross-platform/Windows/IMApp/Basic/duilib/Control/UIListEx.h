#ifndef __UILISTEX_H__
#define __UILISTEX_H__

#pragma once

#include "Layout/UIVerticalLayout.h"
#include "Layout/UIHorizontalLayout.h"

namespace DuiLib {

    class IListComboCallbackUI
    {
    public:
        virtual void GetItemComboTextArray(CControlUI* pCtrl, int iItem, int iSubItem) = 0;
    };

    class CEditUI;
    class CComboBoxUI;

    class UILIB_API CListExUI : public CListUI, public INotifyUI
    {
        DECLARE_DUICONTROL(CListExUI)

    public:
        CListExUI();

        LPCTSTR GetClass() const;
        UINT GetControlFlags() const;
        LPVOID GetInterface(LPCTSTR pstrName);

    public: 
        virtual void DoEvent(TEventUI& event);

    public:
        void InitListCtrl();

    protected:
        CRichEditUI*        m_pEditUI;
        CComboBoxUI*    m_pComboBoxUI;

    public:
        virtual BOOL CheckColumEditable(int nColum);
        virtual CRichEditUI* GetEditUI();

        virtual BOOL CheckColumComboBoxable(int nColum);
        virtual CComboBoxUI* GetComboBoxUI();

        virtual BOOL CheckColumCheckBoxable(int nColum);

    public:
        virtual void Notify(TNotifyUI& msg);
        BOOL    m_bAddMessageFilter;
        int        m_nRow,m_nColum;
        void    SetEditRowAndColum(int nRow,int nColum) { m_nRow = nRow; m_nColum = nColum; };

    public:
        IListComboCallbackUI* m_pXCallback;
        virtual IListComboCallbackUI* GetTextArrayCallback() const;
        virtual void SetTextArrayCallback(IListComboCallbackUI* pCallback);

    public:
        void OnListItemClicked(int nIndex, int nColum, RECT* lpRCColum, LPCTSTR lpstrText);
        void OnListItemChecked(int nIndex, int nColum, BOOL bChecked);

    public:
        void SetColumItemColor(int nIndex, int nColum, DWORD iBKColor);
        BOOL GetColumItemColor(int nIndex, int nColum, DWORD& iBKColor);

    private:
        void HideEditAndComboCtrl();
    };

    /////////////////////////////////////////////////////////////////////////////////////
    //
    class UILIB_API CListContainerHeaderItemUI : public CHorizontalLayoutUI
    {
        DECLARE_DUICONTROL(CListContainerHeaderItemUI)

    public:
        CListContainerHeaderItemUI();

        LPCTSTR GetClass() const;
        LPVOID GetInterface(LPCTSTR pstrName);
        UINT GetControlFlags() const;

        void SetEnabled(BOOL bEnable = TRUE);

        BOOL IsDragable() const;
        void SetDragable(BOOL bDragable);
        DWORD GetSepWidth() const;
        void SetSepWidth(int iWidth);
        DWORD GetTextStyle() const;
        void SetTextStyle(UINT uStyle);
        DWORD GetTextColor() const;
        void SetTextColor(DWORD dwTextColor);
        void SetTextPadding(RECT rc);
        RECT GetTextPadding() const;
        void SetFont(int index);
        BOOL IsShowHtml();
        void SetShowHtml(BOOL bShowHtml = TRUE);
        LPCTSTR GetNormalImage() const;
        void SetNormalImage(LPCTSTR pStrImage);
        LPCTSTR GetHotImage() const;
        void SetHotImage(LPCTSTR pStrImage);
        LPCTSTR GetPushedImage() const;
        void SetPushedImage(LPCTSTR pStrImage);
        LPCTSTR GetFocusedImage() const;
        void SetFocusedImage(LPCTSTR pStrImage);
        LPCTSTR GetSepImage() const;
        void SetSepImage(LPCTSTR pStrImage);

        void DoEvent(TEventUI& event);
        SIZE EstimateSize(SIZE szAvailable);
        void SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue);
        RECT GetThumbRect() const;

        void PaintText(HDC hDC);
        void PaintStatusImage(HDC hDC);

    protected:
        POINT ptLastMouse;
        BOOL m_bDragable;
        UINT m_uButtonState;
        int m_iSepWidth;
        DWORD m_dwTextColor;
        int m_iFont;
        UINT m_uTextStyle;
        BOOL m_bShowHtml;
        RECT m_rcTextPadding;
        CDuiString m_sNormalImage;
        CDuiString m_sHotImage;
        CDuiString m_sPushedImage;
        CDuiString m_sFocusedImage;
        CDuiString m_sSepImage;
        CDuiString m_sSepImageModify;

        //支持编辑
        BOOL m_bEditable;

        //支持组合框
        BOOL m_bComboable;

        //支持复选框
        BOOL m_bCheckBoxable;

    public:
        BOOL GetColumeEditable();
        void SetColumeEditable(BOOL bEnable);

        BOOL GetColumeComboable();
        void SetColumeComboable(BOOL bEnable);

        BOOL GetColumeCheckable();
        void SetColumeCheckable(BOOL bEnable);

    public:
        void SetCheck(BOOL bCheck);
        BOOL GetCheck();

    private:
        UINT    m_uCheckBoxState;
        BOOL    m_bChecked;

        CDuiString m_sCheckBoxNormalImage;
        CDuiString m_sCheckBoxHotImage;
        CDuiString m_sCheckBoxPushedImage;
        CDuiString m_sCheckBoxFocusedImage;
        CDuiString m_sCheckBoxDisabledImage;

        CDuiString m_sCheckBoxSelectedImage;
        CDuiString m_sCheckBoxForeImage;

        SIZE m_cxyCheckBox;

    public:
        BOOL DrawCheckBoxImage(HDC hDC, LPCTSTR pStrImage, LPCTSTR pStrModify = NULL);
        LPCTSTR GetCheckBoxNormalImage();
        void SetCheckBoxNormalImage(LPCTSTR pStrImage);
        LPCTSTR GetCheckBoxHotImage();
        void SetCheckBoxHotImage(LPCTSTR pStrImage);
        LPCTSTR GetCheckBoxPushedImage();
        void SetCheckBoxPushedImage(LPCTSTR pStrImage);
        LPCTSTR GetCheckBoxFocusedImage();
        void SetCheckBoxFocusedImage(LPCTSTR pStrImage);
        LPCTSTR GetCheckBoxDisabledImage();
        void SetCheckBoxDisabledImage(LPCTSTR pStrImage);

        LPCTSTR GetCheckBoxSelectedImage();
        void SetCheckBoxSelectedImage(LPCTSTR pStrImage);
        LPCTSTR GetCheckBoxForeImage();
        void SetCheckBoxForeImage(LPCTSTR pStrImage);

        void GetCheckBoxRect(RECT &rc);    

        int GetCheckBoxWidth() const;       // 实际大小位置使用GetPos获取，这里得到的是预设的参考值
        void SetCheckBoxWidth(int cx);      // 预设的参考值
        int GetCheckBoxHeight() const;      // 实际大小位置使用GetPos获取，这里得到的是预设的参考值
        void SetCheckBoxHeight(int cy);     // 预设的参考值


    public:
        CContainerUI* m_pOwner;
        void SetOwner(CContainerUI* pOwner);
        CContainerUI* GetOwner();
    };

    /////////////////////////////////////////////////////////////////////////////////////
    //

    class UILIB_API CListTextExtElementUI : public CListLabelElementUI
    {
        DECLARE_DUICONTROL(CListTextExtElementUI)

    public:
        CListTextExtElementUI();
        ~CListTextExtElementUI();

        LPCTSTR GetClass() const;
        LPVOID GetInterface(LPCTSTR pstrName);
        UINT GetControlFlags() const;

        LPCTSTR GetText(int iIndex) const;
        void SetText(int iIndex, LPCTSTR pstrText);

        void SetOwner(CControlUI* pOwner);
        CDuiString* GetLinkContent(int iIndex);

        void DoEvent(TEventUI& event);
        SIZE EstimateSize(SIZE szAvailable);

        void DrawItemText(HDC hDC, const RECT& rcItem);

    protected:
        enum { MAX_LINK = 8 };
        int m_nLinks;
        RECT m_rcLinks[MAX_LINK];
        CDuiString m_sLinks[MAX_LINK];
        int m_nHoverLink;
        CListUI* m_pOwner;
        CStdPtrArray m_aTexts;

    private:
        UINT    m_uCheckBoxState;
        BOOL    m_bChecked;

        CDuiString m_sCheckBoxNormalImage;
        CDuiString m_sCheckBoxHotImage;
        CDuiString m_sCheckBoxPushedImage;
        CDuiString m_sCheckBoxFocusedImage;
        CDuiString m_sCheckBoxDisabledImage;

        CDuiString m_sCheckBoxSelectedImage;
        CDuiString m_sCheckBoxForeImage;

        SIZE m_cxyCheckBox;

    public:
        virtual bool DoPaint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl);
        virtual void SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue);
        virtual void PaintStatusImage(HDC hDC);
        BOOL DrawCheckBoxImage(HDC hDC, LPCTSTR pStrImage, LPCTSTR pStrModify, RECT& rcCheckBox);
        LPCTSTR GetCheckBoxNormalImage();
        void SetCheckBoxNormalImage(LPCTSTR pStrImage);
        LPCTSTR GetCheckBoxHotImage();
        void SetCheckBoxHotImage(LPCTSTR pStrImage);
        LPCTSTR GetCheckBoxPushedImage();
        void SetCheckBoxPushedImage(LPCTSTR pStrImage);
        LPCTSTR GetCheckBoxFocusedImage();
        void SetCheckBoxFocusedImage(LPCTSTR pStrImage);
        LPCTSTR GetCheckBoxDisabledImage();
        void SetCheckBoxDisabledImage(LPCTSTR pStrImage);

        LPCTSTR GetCheckBoxSelectedImage();
        void SetCheckBoxSelectedImage(LPCTSTR pStrImage);
        LPCTSTR GetCheckBoxForeImage();
        void SetCheckBoxForeImage(LPCTSTR pStrImage);

        void GetCheckBoxRect(int nIndex, RECT &rc);    
        void GetColumRect(int nColum, RECT &rc);

        int GetCheckBoxWidth() const;       // 实际大小位置使用GetPos获取，这里得到的是预设的参考值
        void SetCheckBoxWidth(int cx);      // 预设的参考值
        int GetCheckBoxHeight() const;      // 实际大小位置使用GetPos获取，这里得到的是预设的参考值
        void SetCheckBoxHeight(int cy);     // 预设的参考值

        void SetCheck(BOOL bCheck);
        BOOL GetCheck() const;

    public:
        int HitTestColum(POINT ptMouse);
        BOOL CheckColumEditable(int nColum);

    private:
        typedef struct tagColumColorNode
        {
            BOOL  bEnable;
            DWORD iTextColor;
            DWORD iBKColor;
        }COLUMCOLORNODE;

        COLUMCOLORNODE ColumCorlorArray[UILIST_MAX_COLUMNS];

    public:
        void SetColumItemColor(int nColum, DWORD iBKColor);
        BOOL GetColumItemColor(int nColum, DWORD& iBKColor);

    };
} // namespace DuiLib

#endif // __UILISTEX_H__
