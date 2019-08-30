#ifndef __UICONTROL_H__
#define __UICONTROL_H__

#pragma once

namespace DuiLib {

    /////////////////////////////////////////////////////////////////////////////////////
    //

    typedef CControlUI* (CALLBACK* FINDCONTROLPROC)(CControlUI*, LPVOID);

    class UILIB_API CControlUI
    {
        DECLARE_DUICONTROL(CControlUI)
    public:
        CControlUI();
        virtual ~CControlUI();

    public:
        virtual CDuiString GetName() const;
        virtual void SetName(LPCTSTR pstrName);
        virtual LPCTSTR GetClass() const;
        virtual LPVOID GetInterface(LPCTSTR pstrName);
        virtual UINT GetControlFlags() const;

        virtual bool Activate();
        virtual CPaintManagerUI* GetManager() const;
        virtual void SetManager(CPaintManagerUI* pManager, CControlUI* pParent, bool bInit = true);
        virtual CControlUI* GetParent() const;
        void setInstance(HINSTANCE instance = NULL) {m_instance = instance;};

        // 定时器
        bool SetTimer(UINT nTimerID, UINT nElapse);
        void KillTimer(UINT nTimerID);

        // 文本相关
        virtual CDuiString GetText() const;
        virtual void SetText(LPCTSTR pstrText);

        virtual bool IsResourceText() const;
        virtual void SetResourceText(bool bResource);

        virtual bool IsDragEnabled() const;
        virtual void SetDragEnable(bool bDrag);

        virtual bool IsDropEnabled() const;
        virtual void SetDropEnable(bool bDrop);

        // 图形相关
        LPCTSTR GetGradient();
        void SetGradient(LPCTSTR pStrImage);
        DWORD GetBkColor() const;
        void SetBkColor(DWORD dwBackColor);
        DWORD GetBkColor2() const;
        void SetBkColor2(DWORD dwBackColor);
        DWORD GetBkColor3() const;
        void SetBkColor3(DWORD dwBackColor);
        DWORD GetForeColor() const;
        void SetForeColor(DWORD dwForeColor);
        LPCTSTR GetBkImage();
        void SetBkImage(LPCTSTR pStrImage);
        LPCTSTR GetForeImage() const;
        void SetForeImage(LPCTSTR pStrImage);

        DWORD GetFocusBorderColor() const;
        void SetFocusBorderColor(DWORD dwBorderColor);
        bool IsColorHSL() const;
        void SetColorHSL(bool bColorHSL);
        SIZE GetBorderRound() const;
        void SetBorderRound(SIZE cxyRound);
        bool DrawImage(HDC hDC, LPCTSTR pStrImage, LPCTSTR pStrModify = NULL);

        //边框相关
        int GetBorderSize() const;
        void SetBorderSize(int nSize);
        DWORD GetBorderColor() const;
        void SetBorderColor(DWORD dwBorderColor);
        void SetBorderSize(RECT rc);
        int GetLeftBorderSize() const;
        void SetLeftBorderSize(int nSize);
        int GetTopBorderSize() const;
        void SetTopBorderSize(int nSize);
        int GetRightBorderSize() const;
        void SetRightBorderSize(int nSize);
        int GetBottomBorderSize() const;
        void SetBottomBorderSize(int nSize);
        int GetBorderStyle() const;
        void SetBorderStyle(int nStyle);

        // 位置相关
        virtual RECT GetRelativePos() const; // 相对(父控件)位置
        virtual RECT GetClientPos() const; // 客户区域（除去scrollbar和inset）
        virtual const RECT& GetPos() const;
        virtual void SetPos(RECT rc, bool bNeedInvalidate = true);
        virtual void Move(SIZE szOffset, bool bNeedInvalidate = true);
        virtual int GetWidth() const;
        virtual int GetHeight() const;
        virtual int GetX() const;
        virtual int GetY() const;
        virtual RECT GetPadding() const;
        virtual void SetPadding(RECT rcPadding); // 设置外边距，由上层窗口绘制
        virtual SIZE GetFixedXY() const;         // 实际大小位置使用GetPos获取，这里得到的是预设的参考值
        virtual void SetFixedXY(SIZE szXY);      // 仅float为true时有效
        virtual int GetFixedWidth() const;       // 实际大小位置使用GetPos获取，这里得到的是预设的参考值
        virtual void SetFixedWidth(int cx);      // 预设的参考值
        virtual int GetFixedHeight() const;      // 实际大小位置使用GetPos获取，这里得到的是预设的参考值
        virtual void SetFixedHeight(int cy);     // 预设的参考值
        virtual int GetMinWidth() const;
        virtual void SetMinWidth(int cx);
        virtual int GetMaxWidth() const;
        virtual void SetMaxWidth(int cx);
        virtual int GetMinHeight() const;
        virtual void SetMinHeight(int cy);
        virtual int GetMaxHeight() const;
        virtual void SetMaxHeight(int cy);
        virtual TPercentInfo GetFloatPercent() const;
        virtual void SetFloatPercent(TPercentInfo piFloatPercent);
        virtual void SetFloatAlign(UINT uAlign);
        virtual UINT GetFloatAlign() const;
        // 鼠标提示
        virtual CDuiString GetToolTip() const;
        virtual void SetToolTip(LPCTSTR pstrText);
        virtual void SetToolTipWidth(int nWidth);
        virtual int      GetToolTipWidth(void);    // 多行ToolTip单行最长宽度

        // 光标
        virtual WORD GetCursor();
        virtual void SetCursor(WORD wCursor);

        // 快捷键
        virtual TCHAR GetShortcut() const;
        virtual void SetShortcut(TCHAR ch);

        // 菜单
        virtual bool IsContextMenuUsed() const;
        virtual void SetContextMenuUsed(bool bMenuUsed);

        // 用户属性
        virtual const CDuiString& GetUserData(); // 辅助函数，供用户使用
        virtual void SetUserData(LPCTSTR pstrText); // 辅助函数，供用户使用
        virtual UINT_PTR GetTag() const; // 辅助函数，供用户使用
        virtual void SetTag(UINT_PTR pTag); // 辅助函数，供用户使用

        // 一些重要的属性
        virtual bool IsVisible() const;
        virtual void SetVisible(bool bVisible = true);
        virtual void SetInternVisible(bool bVisible = true); // 仅供内部调用，有些UI拥有窗口句柄，需要重写此函数
        virtual bool IsEnabled() const;
        virtual void SetEnabled(bool bEnable = true);
        virtual bool IsMouseEnabled() const;
        virtual void SetMouseEnabled(bool bEnable = true);
        virtual bool IsKeyboardEnabled() const;
        virtual void SetKeyboardEnabled(bool bEnable = true);
        virtual bool IsFocused() const;
        virtual void SetFocus();
        virtual bool IsFloat() const;
        virtual void SetFloat(bool bFloat = true);

        virtual CControlUI* FindControl(FINDCONTROLPROC Proc, LPVOID pData, UINT uFlags);

        void Invalidate();
        bool IsUpdateNeeded() const;
        void NeedUpdate();
        void NeedParentUpdate();
        DWORD GetAdjustColor(DWORD dwColor);

        virtual void Init();
        virtual void DoInit();

        virtual void Event(TEventUI& event);
        virtual void DoEvent(TEventUI& event);

        // 自定义(未处理的)属性
        void AddCustomAttribute(LPCTSTR pstrName, LPCTSTR pstrAttr);
        LPCTSTR GetCustomAttribute(LPCTSTR pstrName) const;
        bool RemoveCustomAttribute(LPCTSTR pstrName);
        void RemoveAllCustomAttribute();

        virtual void SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue);
        CControlUI* ApplyAttributeList(LPCTSTR pstrList);

        virtual SIZE EstimateSize(SIZE szAvailable);
        virtual bool Paint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl = NULL); // 返回要不要继续绘制
        virtual bool DoPaint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl);
        virtual void PaintBkColor(HDC hDC);
        virtual void PaintBkImage(HDC hDC);
        virtual void PaintStatusImage(HDC hDC);
        virtual void PaintForeColor(HDC hDC);
        virtual void PaintForeImage(HDC hDC);
        virtual void PaintText(HDC hDC);
        virtual void PaintBorder(HDC hDC);

        virtual void DoPostPaint(HDC hDC, const RECT& rcPaint);

        //虚拟窗口参数
        void SetVirtualWnd(LPCTSTR pstrValue);
        CDuiString GetVirtualWnd() const;

    public:
        CEventSource OnInit;
        CEventSource OnDestroy;
        CEventSource OnSize;
        CEventSource OnEvent;
        CEventSource OnNotify;

    protected:
        CPaintManagerUI* m_pManager;
        CControlUI* m_pParent;
        CDuiString m_sVirtualWnd;
        CDuiString m_sName;
        bool m_bUpdateNeeded;
        bool m_bMenuUsed;
        RECT m_rcItem;
        RECT m_rcPadding;
        SIZE m_cXY;
        SIZE m_cxyFixed;
        SIZE m_cxyMin;
        SIZE m_cxyMax;
        bool m_bVisible;
        bool m_bInternVisible;
        bool m_bEnabled;
        bool m_bMouseEnabled;
        bool m_bKeyboardEnabled ;
        bool m_bFocused;
        bool m_bFloat;
        TPercentInfo m_piFloatPercent;
        UINT m_uFloatAlign;
        bool m_bSetPos; // 防止SetPos循环调用

        bool m_bDragEnabled;
        bool m_bDropEnabled;

        bool m_bResourceText;
        CDuiString m_sText;
        CDuiString m_sToolTip;
        TCHAR m_chShortcut;
        CDuiString m_sUserData;
        UINT_PTR m_pTag;

        CDuiString m_sGradient;
        DWORD m_dwBackColor;
        DWORD m_dwBackColor2;
        DWORD m_dwBackColor3;
        DWORD m_dwForeColor;
        CDuiString m_sBkImage;
        CDuiString m_sForeImage;
        DWORD m_dwBorderColor;
        DWORD m_dwFocusBorderColor;
        bool m_bColorHSL;
        int m_nBorderSize;
        int m_nBorderStyle;
        int m_nTooltipWidth;
        WORD m_wCursor;
        SIZE m_cxyBorderRound;
        RECT m_rcPaint;
        RECT m_rcBorderSize;
        HINSTANCE m_instance;

        CStdStringPtrMap m_mCustomAttrHash;
    };

} // namespace DuiLib

#endif // __UICONTROL_H__
