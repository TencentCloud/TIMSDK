#ifndef __UIEDIT_H__
#define __UIEDIT_H__

#pragma once

namespace DuiLib
{
    class CEditWnd;

    class UILIB_API CEditUI : public CLabelUI
    {
        DECLARE_DUICONTROL(CEditUI)
        friend class CEditWnd;
    public:
        CEditUI();

        LPCTSTR GetClass() const;
        LPVOID GetInterface(LPCTSTR pstrName);
        UINT GetControlFlags() const;

        void SetEnabled(bool bEnable = true);
        void SetText(LPCTSTR pstrText);
        void SetMaxChar(UINT uMax);
        UINT GetMaxChar();
        void SetReadOnly(bool bReadOnly);
        bool IsReadOnly() const;
        void SetPasswordMode(bool bPasswordMode);
        bool IsPasswordMode() const;
        void SetPasswordChar(TCHAR cPasswordChar);
        TCHAR GetPasswordChar() const;
        void SetNumberOnly(bool bNumberOnly);
        bool IsNumberOnly() const;
        int GetWindowStyls() const;

        LPCTSTR GetNormalImage();
        void SetNormalImage(LPCTSTR pStrImage);
        LPCTSTR GetHotImage();
        void SetHotImage(LPCTSTR pStrImage);
        LPCTSTR GetFocusedImage();
        void SetFocusedImage(LPCTSTR pStrImage);
        LPCTSTR GetDisabledImage();
        void SetDisabledImage(LPCTSTR pStrImage);
        void SetNativeEditBkColor(DWORD dwBkColor);
        DWORD GetNativeEditBkColor() const;
        void SetNativeEditTextColor( LPCTSTR pStrColor );
        DWORD GetNativeEditTextColor() const;

        bool IsAutoSelAll();
        void SetAutoSelAll(bool bAutoSelAll);
        void SetSel(long nStartChar, long nEndChar);
        void SetSelAll();
        void SetReplaceSel(LPCTSTR lpszReplace);

        void SetTipValue(LPCTSTR pStrTipValue);
        LPCTSTR GetTipValue();
        void SetTipValueColor(LPCTSTR pStrColor);
        DWORD GetTipValueColor();

        void SetPos(RECT rc, bool bNeedInvalidate = true);
        void Move(SIZE szOffset, bool bNeedInvalidate = true);
        void SetVisible(bool bVisible = true);
        void SetInternVisible(bool bVisible = true);
        SIZE EstimateSize(SIZE szAvailable);
        void DoEvent(TEventUI& event);
        void SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue);

        void PaintStatusImage(HDC hDC);
        void PaintText(HDC hDC);

    protected:
        CEditWnd* m_pWindow;

        UINT m_uMaxChar;
        bool m_bReadOnly;
        bool m_bPasswordMode;
        bool m_bAutoSelAll;
        TCHAR m_cPasswordChar;
        UINT m_uButtonState;
        CDuiString m_sNormalImage;
        CDuiString m_sHotImage;
        CDuiString m_sFocusedImage;
        CDuiString m_sDisabledImage;
        CDuiString m_sTipValue;
        DWORD m_dwTipValueColor;
        DWORD m_dwEditbkColor;
        DWORD m_dwEditTextColor;
        int m_iWindowStyls;
    };
}
#endif // __UIEDIT_H__