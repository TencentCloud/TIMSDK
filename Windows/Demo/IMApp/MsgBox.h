#pragma once
#include "UIlib.h"
using namespace DuiLib;
enum enumMessageIcon {
    MESSAGE_SUCCEED = 0,
    MESSAGE_QUESTION,
    MESSAGE_WARNING,
    MESSAGE_ERROR,
    MESSAGE_INFO,
    MESSAGE_ABOUT,
    MESSAGE_MAX,
};

class CMsgBox : public WindowImplBase
{
public:
    CMsgBox();
    ~CMsgBox();

    LPCTSTR GetWindowClassName() const;
    UINT GetClassStyle() const;
    void OnFinalMessage(HWND /*hWnd*/);


    void InitWindow();
    void Notify(TNotifyUI& msg);

    LRESULT OnCreate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnClose(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnDestroy(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcActivate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcCalcSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcPaint(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcHitTest(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnGetMinMaxInfo(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnSysCommand(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);

    UINT DuiMessageBox(WindowImplBase *pWnd, LPCTSTR lpText, LPCTSTR lpCaption = _T("提示"), UINT uIcon = MESSAGE_INFO, BOOL bOk = TRUE);

    static void MsgBox(std::string title, const char* fmt, ...);
    int GetStringLines(CDuiString st, CDuiString &stMax);
protected:
    CButtonUI *m_pButtonOK;
    CButtonUI *m_pButtonCancel;
    //CFrameMainWnd *m_pMainWnd;
    DWORD m_dwBKColor;
    CDuiString m_stBKImage;
};
