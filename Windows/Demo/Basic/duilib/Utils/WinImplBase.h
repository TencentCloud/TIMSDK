#include "StdAfx.h"

#ifndef WIN_IMPL_BASE_HPP
#define WIN_IMPL_BASE_HPP

namespace DuiLib
{

    class UILIB_API WindowImplBase
        : public CWindowWnd
        , public CNotifyPump
        , public INotifyUI
        , public IMessageFilterUI
        , public IDialogBuilderCallback
        , public IQueryControlText
    {
    public:
        WindowImplBase() {
            m_ResourceType = UILIB_FILE; // UILIB_RESOURCE; // 
            m_SkilFolder = TEXT("");
            m_SkilFile = TEXT("none.xml");
            m_WindowsClassName = TEXT("WindowImplBase");
            memset(&m_ParentRect, 0, sizeof(RECT));
        };
        virtual ~WindowImplBase(){};
        // 只需主窗口重写（初始化资源与多语言接口）
        virtual void InitResource(){};
        // 每个窗口都可以重写
        virtual void InitWindow(){};
        virtual void OnFinalMessage( HWND hWnd );
        virtual void Notify(TNotifyUI& msg);

        virtual void OnPrepare() { };  //windowinit消息 时调用

        CDuiString m_SkilFolder, m_SkilFile, m_WindowsClassName; // 资源路劲，以及文件名
        UILIB_RESTYPE m_ResourceType;
        RECT m_ParentRect; //指定初始化移动到的区域大小

        //用于判断指定控件是否选中，不存在则返回FALSE。COptionUI
        BOOL IsOptionChecked(CDuiString contorlName);
        //设置Option控件的选择状态。COptionUI
        void SetOptionChecked(CDuiString contorlName, bool flag = true);

        //CheckBoxUI
        BOOL IsCheckBoxChecked(CDuiString contorlName);
        void SetCheckBoxChecked(CDuiString contorlName, bool flag = true);

        //删除控件中所有的子元素。 CComboBoxUI、ListUI
        void ListContorlRemoveAll(CDuiString contorlName);

        //设置Combo控件的子元素  CComboBoxUI
        void ComboBoxAdd(CDuiString contorlName, CDuiString addText);
        void ComboBoxDel(CDuiString contorlName, CDuiString delText);
        void ComboBoxClear(CDuiString contorlName);
        //设置Combo控件选中子项 CComboBoxUI
        void ComboBoxSelect(CDuiString contorlName, CDuiString selectText);
        void ComboBoxSelect(CDuiString contorlName, UINT_PTR tag);

        //两个控件可见与不可见状态互换
        void ChangeControlState(CDuiString st1, CDuiString st2);

        //设置控件是否可见
        void SetControlVisible(CDuiString contorlName, bool flag = true);
        //设置控件是否可用
        void SetControlEnabled(CDuiString contorlName, bool flag = true);

        //获取控件的text
        CDuiString GetControlText(CDuiString contorlName);
        //设置控件的text
        void SetControlText(CDuiString contorlName, CDuiString contorlText);

        virtual void SetBKColor2(DWORD dwBkColor2);
        virtual void SetBKColor3(DWORD dwBkColor3);
        virtual void SetBkColor(DWORD dwBackColor);

        virtual DWORD GetBkColor3() const;
        virtual DWORD GetBkColor2() const;
        virtual DWORD GetBkColor() const;
        virtual void SetBkImage(CDuiString strBkImage);
        virtual LPCTSTR GetBkImage();
        CControlUI * GetBkControlUI();

        void SetTrans(int nValue);


        DUI_DECLARE_MESSAGE_MAP()
        virtual void OnClick(TNotifyUI& msg);
        virtual BOOL IsInStaticControl(CControlUI *pControl);

    protected:
        virtual CDuiString GetSkinFile() { 
            return m_SkilFile; 
        };
        virtual CDuiString GetSkinFolder() { 
            return m_SkilFolder; };
        virtual UILIB_RESTYPE GetResourceType() const {
            return m_ResourceType;
        }

        virtual CDuiString GetZIPFileName() const {
            return _T("");
        }
        virtual LPCTSTR GetResourceID() const {
            return _T("");
        }

        virtual LPCTSTR GetWindowClassName(void) const = 0 ;
        virtual LPCTSTR GetManagerName() { return NULL; }
        virtual LRESULT ResponseDefaultKeyEvent(WPARAM wParam);
        CPaintManagerUI m_pm;

    public:
        virtual UINT GetClassStyle() const;
        virtual CControlUI* CreateControl(LPCTSTR pstrClass);
        virtual LPCTSTR QueryControlText(LPCTSTR lpstrId, LPCTSTR lpstrType);

        virtual LRESULT MessageHandler(UINT uMsg, WPARAM wParam, LPARAM /*lParam*/, bool& /*bHandled*/);
        virtual LRESULT OnClose(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
        virtual LRESULT OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);

#if defined(WIN32) && !defined(UNDER_CE)
        virtual LRESULT OnNcActivate(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled);
        virtual LRESULT OnNcCalcSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
        virtual LRESULT OnNcPaint(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/);
        virtual LRESULT OnNcHitTest(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
        virtual LRESULT OnGetMinMaxInfo(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
        virtual LRESULT OnMouseWheel(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
        virtual LRESULT OnMouseHover(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
#endif
        virtual LRESULT OnSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
        virtual LRESULT OnChar(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
        virtual LRESULT OnSysCommand(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
        virtual LRESULT OnCreate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
        virtual LRESULT OnKeyDown(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
        virtual LRESULT OnKillFocus(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
        virtual LRESULT OnSetFocus(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
        virtual LRESULT OnLButtonDown(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
        virtual LRESULT OnLButtonUp(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
        virtual LRESULT OnMouseMove(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
        virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);
        virtual LRESULT HandleCustomMessage(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
        virtual LONG GetStyle();
    };
}

#endif // WIN_IMPL_BASE_HPP
