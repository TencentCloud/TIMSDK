/**
* Module:   IMWnd @ liteav
* Author:   cloud @ 2018/10/1
* Function: IM Demo 主窗口
*/
#pragma once
#include <string>
#include "../common/HttpClient.h"
#include "UIlib.h"
#include "TIMCloud.h"

using namespace DuiLib;

typedef enum {
    INITSDK_VIEW,
    LOGIN_VIEW,
    MAIN_LOGIC_VIEW,
}MainViewType;

typedef enum {
    NODE_LOG_VIEW     = 0,
    NODE_CONV_VIEW    = 1,
    NODE_CREATE_CONV  = 2,
    NODE_CREATE_GROUP = 3,
    NODE_JOIN_GROUP   = 4,
    NODE_INVITE_GROUP = 5,
    NODE_DELETE_CONV  = 6,
    NODE_DELETE_GROUP = 7,
    NODE_QUIT_GROUP   = 8,
    NODE_DELMEM_GROUP = 9,
}NodeViewType;

typedef enum {
    MENU_CREATE_CONV,
    MENU_DELETE_CONV,
    MENU_CREATEJOIN_GROUP,
    MENU_DELETE_GROUP,
    MENU_DELETE_GROUPMEM,
}MenuType;

class CIMWnd : public WindowImplBase
{
public: //virture
    CIMWnd();
    ~CIMWnd() { }
    CIMWnd(const CIMWnd&) { }                //防止拷贝构造另一个实例 
    CIMWnd& operator = (const CIMWnd&) { }   //防止赋值构造出另一个实例
    CIMWnd(CIMWnd&&) { }                     //防止移动拷贝拷贝另一个实例
    CIMWnd& operator=(CIMWnd&&) { }          //防止移动赋值出另一个实例

public:
    static CIMWnd& GetInst() {
        static CIMWnd inst;
        return inst;
    }
    void Init();

   //overwrite
    virtual LPCTSTR GetWindowClassName() const { return _T("IM_Frame"); };
    virtual UINT GetClassStyle() const { return /*UI_CLASSSTYLE_FRAME |*/ CS_DBLCLKS; };
    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);
    virtual LRESULT OnClose(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
public: //cb
    virtual void Notify(TNotifyUI& msg);
    virtual CControlUI* CreateControl(LPCTSTR pstrClass);

public:
    virtual void InitWindow();
    void MsgBox(std::string title, const char* fmt, ...);
    static void MsgBoxEx(std::string title, const char* fmt, ...);
    void OnInitSDKBtn();
    void OnUnInitSDKBtn();
    void OnLoginBtn();
    void OnLogoutBtn();

    void Log(const char* module, TIMLogLevel level, const char* log, bool msgbox = true);
    void Logf(const char* module, TIMLogLevel level, const char* fmt, ...);


    void InitConvList();
    void AddConv(std::string id, uint32_t type);
    void DelConv(std::string id, uint32_t type);
    void UpdateConv(std::string id, uint32_t type);
    void GetGroupJoinedList();
    void GetGroupInfoList();
    void GetGroupMemberInfoList(std::string groupid);
    void GetConvMsgs(std::string userid, TIMConvType type);


    void OnSendFaceBtn();
    void OnSendImageBtn();
    void OnSendFileBtn();
    void OnSendMsgBtn();
    void OnCreateConvBtn();
    void OnDelConvBtn();
    void OnCreateGroupBtn();
    void OnDelGroupBtn();
    void OnJoinGroupBtn();
    void OnQuitGroupBtn();
    void OnInviteGroupBtn();
    void OnDelGroupMemBtn();

    std::string OpenFile();
    void DownloadMessageElem(uint32_t flag, uint32_t type, std::string id, uint32_t business_id, std::string url, std::string name);
    void DownloadMessageElem(std::string url, std::string name);
    bool SendMsg(const char* json_msg);
    void ParseMsg(const char* json_msg_array);
    void ShowMsgs(std::vector<std::string>& msgs, std::string conv_id, TIMConvType conv_type);
    void OnPopupMenu(MenuType mt); //新建会话

    void ChangeMainView(MainViewType before, MainViewType after);
    void ChangeNodeView(NodeViewType vt);
    void UpdateNodeView();
    void UpdateGroupCombo(TCHAR * combo_name);

    std::vector<std::string> msgs;

    typedef struct {
        std::string id;
    }ConvInfo;
    std::vector<ConvInfo> convs;

    typedef struct {
        std::string id;
    }GroupMemberInfo;
    typedef struct {
        std::string id;
        std::string name;
        std::vector<GroupMemberInfo> mems;
    }GroupInfo;

    std::vector<GroupInfo> groups;

    std::string login_id;
    std::string path_;
public:
    CEditUI* m_LogPath = nullptr;
    CEditUI* m_UserIdEdit = nullptr;
    CComboUI* m_SdkAppIdCombo = nullptr;

    CControlUI* m_InitSdkView = nullptr;
    CControlUI* m_LoginView = nullptr;
    CControlUI* m_MainLogicView = nullptr;
    CTabLayoutUI* m_MainLogicTab = nullptr;

    CControlUI* m_ConvUserInfoView = nullptr;
    CControlUI* m_ConvGroupInfoView = nullptr;

    CRichEditUI* m_LogData = nullptr;  //日子数据
    CRichEditUI* m_SysMsg = nullptr;   //系统消息数据

    CRichEditUI* m_ConvMsgData = nullptr; //会话消息数据

    CTreeNodeUI* m_ConvNode = nullptr;
    CTreeNodeUI* m_GroupNode = nullptr;

    CComboUI* m_GroupType = nullptr;
    CComboUI* m_GroupAddOpt = nullptr;
    int groupaddopt_cursul_ = 0;
    int grouptype_cursel_ = 0;

    CControlUI* m_CurShowConvNode = nullptr; //点击 显示会话界面的TreeNode控件
    CControlUI* m_CurMenuNode = nullptr; //触发右键菜单的TreeNode控件

    //HttpClient m_http_client;
    NodeViewType node_type_;

private:
    std::string login_id_;
};