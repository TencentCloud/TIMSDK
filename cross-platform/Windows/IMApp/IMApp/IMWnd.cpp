/**
* Module:   IMWnd @ imsdk
* Author:   cloud @ 2018/10/1
* Function: IM Demo 窗口
* Modify: 创建 by cloud @ 2019/01/12
*/

#include<time.h>
#include <stdarg.h>
#include "IMWnd.h"
#include "../common/Base.h"
#include "../common/log.h"
#include "../common/imutil.h"
#include "json.h"
#include "resource.h"
#include "MsgBox.h"
#include "TIMCloud.h"
#include "TestApi.h"

CIMWnd::CIMWnd() {
    m_SkilFile = "frame.xml";
}

void CIMWnd::Init(SdkAppInfo &info) {
    info_ = info;
    // 新消息回调时间
    TIMAddRecvNewMsgCallback([](const char* json_msg_array, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        ths->Logf("Message", kTIMLog_Info, "New Message:\n%s", json_msg_array);
        
        ths->ParseMsg(json_msg_array);
    }, this);

    //消息更新回调事件
    TIMSetMsgUpdateCallback([](const char* json_msg_array, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        ths->Logf("Message", kTIMLog_Info, "Update Message:\n%s", json_msg_array);
    }, this);

    //消息已读回执事件
    TIMSetMsgReadedReceiptCallback([](const char* json_msg_readed_receipt_array, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;

        ths->Logf("Message", kTIMLog_Info, "Message ReadedReceipt:\n%s", json_msg_readed_receipt_array);

        Json::Value json_value_receipts;
        Json::Reader reader;
        if (!reader.parse(json_msg_readed_receipt_array, json_value_receipts)) {
            // Json 解析失败
            return;
        }

        for (Json::ArrayIndex i = 0; i < json_value_receipts.size(); i++) {
            Json::Value& json_value_receipt = json_value_receipts[i];

            std::string convid = json_value_receipt[kTIMMsgReceiptConvId].asString();
            uint32_t conv_type = json_value_receipt[kTIMMsgReceiptConvType].asUInt();
            uint64_t timestamp = json_value_receipt[kTIMMsgReceiptTimeStamp].asUInt64();

            // 消息已读逻辑
        }

    }, this);

    TIMSetMsgRevokeCallback([](const char* json_msg_locator_array, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        ths->Logf("Message", kTIMLog_Info, "Message Revoke:\n%s", json_msg_locator_array);
        Json::Value json_value_locators;
        Json::Reader reader;
        if (!reader.parse(json_msg_locator_array, json_value_locators)) {
            // Json 解析失败
            return;
        }
        for (Json::ArrayIndex i = 0; i < json_value_locators.size(); i++) {
            Json::Value& json_value_locator = json_value_locators[i];

            std::string convid = json_value_locator[kTIMMsgLocatorConvId].asString();
            uint32_t conv_type = json_value_locator[kTIMMsgLocatorConvType].asUInt();
            bool isrevoke = json_value_locator[kTIMMsgLocatorIsRevoked].asBool();
            uint64_t time = json_value_locator[kTIMMsgLocatorTime].asUInt64();
            uint64_t seq_ = json_value_locator[kTIMMsgLocatorSeq].asUInt64();
            uint64_t rand_ = json_value_locator[kTIMMsgLocatorRand].asUInt64();
            bool isself = json_value_locator[kTIMMsgLocatorIsSelf].asBool();

            // 编写 消息撤回逻辑
        }
    }, this);

    TIMSetMsgElemUploadProgressCallback([](const char* json_msg, uint32_t index, uint32_t cur_size, uint32_t total_size, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;

        Json::Value json_value_msg;
        Json::Reader reader;
        if (!reader.parse(json_msg, json_value_msg)) {
            // Json 解析失败
            return;
        }
        Json::Value& elems = json_value_msg[kTIMMsgElemArray];
        if (index >= elems.size()) {
            // index 超过消息元素个数范围
            return;
        }
        uint32_t elem_type = elems[index][kTIMElemType].asUInt();
        if (kTIMElem_File ==  elem_type) {

        }
        else if (kTIMElem_Sound == elem_type) {

        }
        else if (kTIMElem_Video == elem_type) {

        }
        else if (kTIMElem_Image == elem_type) {

        }
        else {
            // 其他类型元素不符合上传要求
        }



        ths->Logf("UploadProgress", kTIMLog_Info, "index:%u cur_size:%u total_size:%u", index, cur_size, total_size);
    }, this);

    TIMSetGroupTipsEventCallback([](const char* json_group_tips, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        ths->Logf("GroupTips", kTIMLog_Info, "GroupTips Event:%s", json_group_tips);
    }, this);

    TIMSetConvEventCallback([](TIMConvEvent conv_event, const char* json_conv_array, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        Json::Reader reader;
        Json::Value json_value;
        if (!reader.parse(json_conv_array, json_value)) {
            ths->Logf("ConvEvent", kTIMLog_Error, "Parse Json json_conv_array Failure!error:%s", reader.getFormatedErrorMessages().c_str());
            return;
        }
        for (Json::ArrayIndex i = 0; i < json_value.size(); i++) {
            Json::Value& convinfo = json_value[i];
            std::string conv_id = convinfo[kTIMConvId].asCString();
            uint32_t conv_type = convinfo[kTIMConvType].asUInt();
            ths->Logf("ConvEvent", kTIMLog_Info, "%02u event:%u id:%s type:%u", i, conv_event, conv_id.c_str(), conv_type);
            if (conv_event == kTIMConvEvent_Add) {
                CIMWnd::GetInst().AddConv(conv_id, conv_type);
            }
            else if (conv_event == kTIMConvEvent_Del) {
                CIMWnd::GetInst().DelConv(conv_id, conv_type);
            }
            else if (conv_event == kTIMConvEvent_Update) {
                CIMWnd::GetInst().UpdateConv(conv_id, conv_type);
            }
        }
    }, this);

    TIMSetNetworkStatusListenerCallback([](TIMNetworkStatus status, int32_t code, const char* desc, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        ths->Logf("Network", kTIMLog_Info, "status %u code:%u desc:%s", status, code, desc);
    }, this);

    TIMSetKickedOfflineCallback([](const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        ths->Logf("KickedOff", kTIMLog_Info, "Kicked Offline");
    }, this);

    TIMSetUserSigExpiredCallback([](const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        ths->Logf("UserSig", kTIMLog_Info, "Expired");
    }, this);

    TIMSetLogCallback([](TIMLogLevel level, const char* log, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        //ths->Log("SdkLog", level, log, false);
    }, this);
}

void CIMWnd::Notify(TNotifyUI & msg) {
    if (msg.sType == DUI_MSGTYPE_MENU) {
        if (msg.pSender->GetName() == _T("conv_node")) { //右键菜单 新建会话
            m_CurMenuNode = msg.pSender;
            OnPopupMenu(MENU_CREATE_CONV);
        }
        if (msg.pSender->GetName() == _T("group_node")) { //右键菜单 新建群组或加入群组
            m_CurMenuNode = msg.pSender;
            OnPopupMenu(MENU_CREATEJOIN_GROUP);
        }
        if (msg.pSender->GetName() == _T("conv_node_item")) { //右键菜单 删除会话
            m_CurMenuNode = msg.pSender;
            OnPopupMenu(MENU_DELETE_CONV);
        }
        if (msg.pSender->GetName() == _T("group_node_item")) {  //右键菜单 删除群组 邀请加入 退出群组
            m_CurMenuNode = msg.pSender;
            OnPopupMenu(MENU_DELETE_GROUP);
        }
        if (msg.pSender->GetName() == _T("groupmem_node_item")) {  //右键菜单 删除群成员
            m_CurMenuNode = msg.pSender;
            OnPopupMenu(MENU_DELETE_GROUPMEM);
        }
    }
    if (msg.sType == DUI_MSGTYPE_CLICK) {
        if (msg.pSender->GetName() == _T("login_btn")) { //登入
            OnLoginBtn();
        }
        if (msg.pSender->GetName() == _T("logout_btn")) {
            OnLogoutBtn();
        }
        if (msg.pSender->GetName() == _T("test_btn")) {
            TestApi();
        }
        if (msg.pSender->GetName() == _T("initsdk_btn")) { //初始化SDK
            OnInitSDKBtn();
        }
        if (msg.pSender->GetName() == _T("uninitsdk_btn")) {
            OnUnInitSDKBtn();
        }
        if (msg.pSender->GetName() == _T("create_conv_btn")) {
            OnCreateConvBtn();
        }
        if (msg.pSender->GetName() == _T("delete_conv_btn")) {
            OnDelConvBtn();
        }
        if (msg.pSender->GetName() == _T("create_group_btn")) {
            OnCreateGroupBtn();
        }
        if (msg.pSender->GetName() == _T("delete_group_btn")) {
            OnDelGroupBtn();
        }
        if (msg.pSender->GetName() == _T("join_group_btn")) {
            OnJoinGroupBtn();
        }
        if (msg.pSender->GetName() == _T("quit_group_btn")) {
            OnQuitGroupBtn();
        }
        if (msg.pSender->GetName() == _T("invite_group_btn")) {
            OnInviteGroupBtn();
        }
        if (msg.pSender->GetName() == _T("delmem_group_btn")) {
            OnDelGroupMemBtn();
        }
        if (msg.pSender->GetName() == _T("sendface_bth")) { //选择表情
            OnSendFaceBtn();
        }
        if (msg.pSender->GetName() == _T("sendimage_btn")) { //选择上传图片
            OnSendImageBtn();
        }
        if (msg.pSender->GetName() == _T("sendfile_btn")) { //选择上传文件
            OnSendFileBtn();
        }
        if (msg.pSender->GetName() == _T("sendmsg_btn")) { //消息发送
            OnSendMsgBtn();
        }
        if (msg.pSender->GetName() == _T("conv_groupinfo_add_btn")) {
            m_CurMenuNode = m_CurShowConvNode;
            ChangeNodeView(NODE_INVITE_GROUP);
        }
    }
    if (msg.sType == DUI_MSGTYPE_ITEMCLICK) {
        if (msg.pSender->GetName() == _T("log_node")) {
            ChangeNodeView(NODE_LOG_VIEW);
        }
        //if (msg.pSender->GetName() == _T("sysmsg_node")) {
        //    ChangeNodeView(NODE_SYSMSG_VIEW);
        //}
        if (msg.pSender->GetName() == _T("create_conv_node")) {
            m_CurMenuNode = nullptr;
            ChangeNodeView(NODE_CREATE_CONV);
        }
        if (msg.pSender->GetName() == _T("create_group_node")) {
            m_CurMenuNode = nullptr;
            ChangeNodeView(NODE_CREATE_GROUP);
        }
        if (msg.pSender->GetName() == _T("join_group_node")) {
            m_CurMenuNode = nullptr;
            ChangeNodeView(NODE_JOIN_GROUP);
        }
        if (msg.pSender->GetName() == _T("invite_group_node")) {
            m_CurMenuNode = nullptr;
            ChangeNodeView(NODE_INVITE_GROUP);
        }
        if (msg.pSender->GetName() == _T("delete_conv_node")) {
            m_CurMenuNode = nullptr;
            ChangeNodeView(NODE_DELETE_CONV);
        }
        if (msg.pSender->GetName() == _T("delmem_group_node")) {
            m_CurMenuNode = nullptr;
            ChangeNodeView(NODE_DELMEM_GROUP);
        }
        if (msg.pSender->GetName() == _T("delete_group_node")) {
            m_CurMenuNode = nullptr;
            ChangeNodeView(NODE_DELETE_GROUP);
        }
        if (msg.pSender->GetName() == _T("quit_group_node")) {
            m_CurMenuNode = nullptr;
            ChangeNodeView(NODE_QUIT_GROUP);
        }
        //点击显示会话界面
        if ((msg.pSender->GetName() == _T("conv_node_item")) ||
            (msg.pSender->GetName() == _T("group_node_item"))) {
            m_CurShowConvNode = msg.pSender;   //保存当前会话所属的节点的指针
            ChangeNodeView(NODE_CONV_VIEW);
        }
        //各个菜单功能 切换界面等
        if (msg.pSender->GetName() == _T("create_conv_menu")) {
            ChangeNodeView(NODE_CREATE_CONV);
        }
        if (msg.pSender->GetName() == _T("delete_conv_menu")) {
            ChangeNodeView(NODE_DELETE_CONV);
        }
        if (msg.pSender->GetName() == _T("create_group_menu")) {
            ChangeNodeView(NODE_CREATE_GROUP);
        }
        if (msg.pSender->GetName() == _T("join_group_menu")) {
            ChangeNodeView(NODE_JOIN_GROUP);
        }
        if (msg.pSender->GetName() == _T("invite_group_menu")) {
            ChangeNodeView(NODE_INVITE_GROUP);
        }
        if (msg.pSender->GetName() == _T("delete_group_menu")) {
            ChangeNodeView(NODE_DELETE_GROUP);
        }
        if (msg.pSender->GetName() == _T("delete_groupmem_menu")) {
            ChangeNodeView(NODE_DELMEM_GROUP);
        }
        if (msg.pSender->GetName() == _T("quit_group_menu")) {
            ChangeNodeView(NODE_QUIT_GROUP);
        }
    }
    if (msg.sType == DUI_MSGTYPE_ITEMSELECT) {
        if (msg.pSender->GetName() == _T("create_grouptype_combo")) {
            grouptype_cursel_ = m_GroupType->GetCurSel();
        }
        if (msg.pSender->GetName() == _T("create_groupaddopt_combo")) {
            groupaddopt_cursul_ =  m_GroupAddOpt->GetCurSel();
        }
        if (msg.pSender->GetName() == _T("delmem_groupid_combo")) {  //更新删除是的成员列表
            std::string groupid = TStr2Str(msg.pSender->GetText().GetData());

            
        }
        if (msg.pSender == m_UserIdCombo) { //跟据UserId切换UserSig
            for (std::size_t i = 0; i < info_.accounts.size(); i++) {
                AccountInfo& account = info_.accounts[i];
                std::string userid = m_UserIdCombo->GetText().GetStringA();
                std::string userid2 = msg.pSender->GetText().GetStringA();
                if (account.userid == userid) {
                    m_UserSig->SetText(Str2TStr(account.usersig).c_str());
                    break;
                }
            }
        }
    }
    __super::Notify(msg);
}
DuiLib::CControlUI* CIMWnd::CreateControl(LPCTSTR pstrClass) {
    return nullptr;
}

LRESULT CIMWnd::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam) {
    return WindowImplBase::HandleMessage(uMsg, wParam, lParam);
}
LRESULT CIMWnd::OnClose(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled) {
    OnUnInitSDKBtn();
    return WindowImplBase::OnClose(uMsg, wParam, lParam, bHandled);
}

void CIMWnd::InitWindow() {
    SetIcon(IDR_MAINFRAME);
    m_LogPath = static_cast<CEditUI*>(m_pm.FindControl(_T("logpath_edit")));
    m_UserSig = static_cast<CRichEditUI*>(m_pm.FindControl(_T("usersig_edit")));


    m_InitSdkView = static_cast<CControlUI*>(m_pm.FindControl(_T("initsdk_view")));  //初始化
    m_LoginView = static_cast<CControlUI*>(m_pm.FindControl(_T("login_view")));  //登入
    m_MainLogicView = static_cast<CControlUI*>(m_pm.FindControl(_T("main_logic_view"))); //主逻辑界面
    m_MainLogicTab = static_cast<CTabLayoutUI*>(m_pm.FindControl(_T("main_logic_tab")));

    m_LogData = static_cast<CRichEditUI*>(m_pm.FindControl(_T("logdata_edit")));
    //m_SysMsg = static_cast<CRichEditUI*>(m_pm.FindControl(_T("sysmsgdata_edit")));
    m_ConvMsgData = static_cast<CRichEditUI*>(m_pm.FindControl(_T("convdata_edit")));

    m_ConvUserInfoView = static_cast<CControlUI*>(m_pm.FindControl(_T("conv_userinfo_view")));
    m_ConvGroupInfoView = static_cast<CControlUI*>(m_pm.FindControl(_T("conv_groupinfo_view")));

    m_ConvNode = static_cast<CTreeNodeUI*>(m_pm.FindControl(_T("conv_node"))); 
    m_GroupNode = static_cast<CTreeNodeUI*>(m_pm.FindControl(_T("group_node")));

    m_GroupType = static_cast<CComboUI*>(m_pm.FindControl(_T("create_grouptype_combo")));
    m_GroupAddOpt = static_cast<CComboUI*>(m_pm.FindControl(_T("create_groupaddopt_combo")));

    m_GroupType->SelectItem (0);
    m_GroupAddOpt->SelectItem(0);
    SetControlVisible(_T("logout_btn"), false);
    SetControlVisible(_T("test_btn"), false);
    m_UserSig->SetWordWrap();
    //m_LogData->SetWordWrap();

    m_pm.SetFocus(nullptr);

    TCHAR szTPath[MAX_PATH] = { 0 };
    ::GetModuleFileName(NULL, szTPath, MAX_PATH); //获取工具目录
    int len = _tcslen(szTPath);
    for (int i = len; i >= 0; i--) {
        if ((szTPath[i] == '/') || (szTPath[i] == '\\')) {
            szTPath[i] = 0;
            break;
        }
    }
    m_LogPath->SetText(szTPath);
    path_ = TStr2Str(szTPath);

    m_SdkAppIdCombo = static_cast<CComboUI*>(m_pm.FindControl(_T("sdkappid_combo")));
    CListLabelElementUI* ele = new CListLabelElementUI;
    ele->SetText(Str2TStr(std::to_string(info_.sdkappid)).c_str());
    m_SdkAppIdCombo->Add(ele);
    m_SdkAppIdCombo->SelectItem(0);

    m_UserIdCombo = static_cast<CComboUI*>(m_pm.FindControl(_T("userid_combo")));
    for (std::size_t i = 0; i < info_.accounts.size(); i++) {
        AccountInfo& account = info_.accounts[i];
        ele = new CListLabelElementUI;
        ele->SetText(Str2TStr(account.userid).c_str());
        m_UserIdCombo->Add(ele);
    }
}
void CIMWnd::MsgBox(std::string title, const char* fmt, ...) {
    std::string tmp;
    va_list ap;
    va_start(ap, fmt);
    FmtV(tmp, fmt, ap);
    va_end(ap);

    CMsgBox msgbox;
    msgbox.DuiMessageBox(this, WStr2TStr(UTF82Wide(tmp)).c_str(), WStr2TStr(UTF82Wide(title)).c_str());
}

void CIMWnd::MsgBoxEx(std::string title, const char* fmt, ...) {
    std::string tmp;
    va_list ap;
    va_start(ap, fmt);
    FmtV(tmp, fmt, ap);
    va_end(ap);

    CMsgBox msgbox;
    msgbox.DuiMessageBox(nullptr, Str2TStr(tmp).c_str(), Str2TStr(title).c_str());
}

void CIMWnd::Log(const char* module, TIMLogLevel level, const char* log, bool msgbox) {
    if (!module || !log) {
        return;
    }
    if (msgbox && ((level == kTIMLog_Error) || (level == kTIMLog_Assert))) {
        MsgBox("Error", "module : %s\n %s ", module, log);
    }

    std::vector<std::string> stV;
    std::string str_log = log;
    std::string stSub;
    for (std::string::size_type i = 0; i < str_log.length();) {
        if (str_log[i] == 0) {
            break;
        }
        if (('\r' == str_log[i]) && ('\n' == str_log[i + 1])) {
            stV.push_back(stSub);
            i = i + 2;
            stSub = "";
            continue;
        }
        if ('\n' == str_log[i]) {
            stV.push_back(stSub);
            i = i + 1;
            stSub = "";
            continue;
        }
        stSub.push_back(str_log[i]);
        i = i + 1;
    }
    if (stSub != "") {
        stV.push_back(stSub);
    }
    for (std::size_t i = 0; i < stV.size(); i++) {
        std::string tmp = Fmt("%10s : %s\r\n", module, stV[i].c_str());
        m_LogData->AppendText(WStr2TStr(UTF82Wide(tmp)).c_str());
    }
}

#define STRING_FMT_MAX_LENGHT 0x100000
void CIMWnd::Logf(const char* module, TIMLogLevel level, const char* fmt, ...) {
    std::string tmp(STRING_FMT_MAX_LENGHT, 0);
    va_list ap;
    va_start(ap, fmt);
    _vsnprintf_s((char*)tmp.c_str(), STRING_FMT_MAX_LENGHT - 1, STRING_FMT_MAX_LENGHT, fmt, ap);
    va_end(ap);
    Log(module, level, tmp.c_str());
}

std::string CIMWnd::OpenFile() {
    OPENFILENAME ofn;
    TCHAR szFile[MAX_PATH] = _T("");
    ZeroMemory(&ofn, sizeof(ofn));
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = *this;
    ofn.lpstrFile = szFile;
    ofn.nMaxFile = sizeof(szFile);
    ofn.lpstrFilter = NULL;// tmp.c_str();
    ofn.nFilterIndex = 1;
    ofn.lpstrFileTitle = NULL;
    ofn.nMaxFileTitle = 0;
    ofn.lpstrInitialDir = NULL;
    ofn.Flags = OFN_EXPLORER | OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

    if (GetOpenFileName(&ofn)) {
        return TStr2Str(szFile);
    }
    return "";
}

void CIMWnd::OnInitSDKBtn() { //初始化ImSDK
    //获取配置
    Json::Value json_user_config;
    json_user_config[kTIMUserConfigIsReadReceipt] = true;  // 开启已读回执
    Json::Value json_http_proxy;
    json_http_proxy[kTIMHttpProxyInfoIp] = "http://http-proxy.xxxx.com";
    json_http_proxy[kTIMHttpProxyInfoPort] = 8888;

    Json::Value json_socks5_value;
    json_socks5_value[kTIMSocks5ProxyInfoIp] = "111.222.333.444";
    json_socks5_value[kTIMSocks5ProxyInfoPort] = 8888;
    json_socks5_value[kTIMSocks5ProxyInfoUserName] = "";
    json_socks5_value[kTIMSocks5ProxyInfoPassword] = "";
    Json::Value json_config;
    json_config[kTIMSetConfigUserConfig] = json_user_config;
    //json_config[kTIMSetConfigSocks5ProxyInfo] = json_socks5_value;
    json_config[kTIMSetConfigHttpProxyInfo] = json_http_proxy;
    json_config[kTIMSetConfigUserDefineData] = "1.3.4.5.6.7";

    TIMSetConfig(json_config.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        ths->Logf("config", kTIMLog_Info, json_param);
    }, this);

    // 初始化
    std::string sdkappid = m_SdkAppIdCombo->GetText().GetStringA();
    std::string path = m_LogPath->GetText().GetStringA();
    uint64_t sdk_app_id = atoi(sdkappid.c_str());

    std::string json_init_cfg;

    Json::Value json_value_init;
    json_value_init[kTIMSdkConfigLogFilePath] = path;
    json_value_init[kTIMSdkConfigConfigFilePath] = path;

    TIMInit(sdk_app_id, json_value_init.toStyledString().c_str());
    ChangeMainView(INITSDK_VIEW, LOGIN_VIEW);
    Logf("InitSdk", kTIMLog_Info, "sdkappid:%s Log&Cfg path:%s", sdkappid.c_str(), path.c_str());
}

void CIMWnd::OnUnInitSDKBtn() {
    //卸载ImSDK
    TIMUninit();
    ChangeMainView(LOGIN_VIEW, INITSDK_VIEW);
}
void CIMWnd::OnLoginBtn() { //登入
    std::string userid = m_UserIdCombo->GetText().GetStringA();
    std::string usersig = m_UserSig->GetText().GetStringA();

    login_id = userid;
    TIMLogin(userid.c_str(), usersig.c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        if (code != ERR_SUCC) { // 登入失败
            ths->Logf("Login", kTIMLog_Error, "Failure!code:%d desc", code, desc);
            return;
        }
        //登入成功
        ths->Log("Login", kTIMLog_Info, "Success!");
        ths->ChangeMainView(LOGIN_VIEW, MAIN_LOGIC_VIEW);
        ths->SetControlVisible(_T("logout_btn"), true);
        ths->SetControlVisible(_T("test_btn"), true);

        ths->SetControlVisible(_T("cur_login_info"), true);
        ths->SetControlText(_T("cur_login_info"), Str2TStr(ths->login_id).c_str());
        ths->InitConvList();
        ths->GetGroupJoinedList();
    }, this);

    Logf("Login", kTIMLog_Info, "User Id:%s Sig:%s", userid.c_str(), usersig.c_str());
    SetControlText(_T("cur_loginid_lbl"), Str2TStr(userid).c_str());
}

void CIMWnd::OnLogoutBtn() { //登出
    Logf("Logout", kTIMLog_Info, "User Id : %s", login_id_.c_str());
    TIMLogout([](int32_t code, const char* desc, const char* json_param, const void* user_data) {  //无论登出成功还是失败都跳转到登入界面
        CIMWnd* ths = (CIMWnd*)user_data;
        if (code != ERR_SUCC) { // 登出失败
            ths->Logf("Logout", kTIMLog_Error, "Failure!code:%d desc", code, desc);
            ths->ChangeNodeView(NODE_LOG_VIEW);
            return;
        }
        // 登出成功
        ths->Log("Logout", kTIMLog_Info, "Success!");
        ths->ChangeMainView(MAIN_LOGIC_VIEW, LOGIN_VIEW);
        ths->SetControlVisible(_T("logout_btn"), false);
        ths->SetControlVisible(_T("test_btn"), false);
        ths->SetControlVisible(_T("cur_login_info"), false);
        ths->convs.clear();
        ths->groups.clear();
        ths->msgs.clear();
    }, this);
}

void CIMWnd::InitConvList() { // 获取会话列表
    int ret = TIMConvGetConvList([](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        Json::Value json_conv_list;
        Json::Reader reader;
        if (!reader.parse(json_param, json_conv_list)) {
            CIMWnd::GetInst().Logf("GetConvList", kTIMLog_Error, "Json Parse Conv List Failure! error:%s", reader.getFormattedErrorMessages().c_str());
            return;
        }
        CIMWnd::GetInst().Logf("ConvList", kTIMLog_Info, json_param);
        for (Json::ArrayIndex i = 0; i < json_conv_list.size(); i++) {
            Json::Value& conv = json_conv_list[i];

            std::string id = conv[kTIMConvId].asString();
            uint32_t type = conv[kTIMConvType].asUInt();
            CIMWnd::GetInst().AddConv(id, type);
        }
    }, this);
    Logf("Init", kTIMLog_Info, "TIMConvGetConvList ret %d", ret);
    
}
void CIMWnd::AddConv(std::string id, uint32_t type) {
    if (type == TIMConvType::kTIMConv_C2C) {
        ConvInfo conv;
        conv.id = id;
        for (std::size_t i = 0; i < convs.size(); i++) {
            if (convs[i].id == id) { // 已添加
                return;
            }
        }
        convs.push_back(conv);
        GetConvMsgs(id, (TIMConvType)type);
        UpdateNodeView();
    }
    else if (type == TIMConvType::kTIMConv_Group) {
        GroupInfo group;
        group.id = id;
        for (std::size_t i = 0; i < groups.size(); i++) {
            if (groups[i].id == id) { // 已添加
                return;
            }
        }
        groups.push_back(group);
        GetConvMsgs(id, (TIMConvType)type);
        UpdateNodeView();
    }
    else if (type == TIMConvType::kTIMConv_System) {

    }
}
void CIMWnd::DelConv(std::string id, uint32_t type) {
    if (type == TIMConvType::kTIMConv_C2C) {
        for (std::size_t i = 0; i < CIMWnd::GetInst().convs.size(); i++) {
            if (CIMWnd::GetInst().convs[i].id == id) { // 删除
                CIMWnd::GetInst().convs.erase(CIMWnd::GetInst().convs.begin() + i);
                UpdateNodeView();
                return;
            }
        }
    }
    else if (type == TIMConvType::kTIMConv_Group) {
        GroupInfo group;
        group.id = id;
        for (std::size_t i = 0; i < CIMWnd::GetInst().groups.size(); i++) {
            if (CIMWnd::GetInst().groups[i].id == id) { // 删除
                CIMWnd::GetInst().groups.erase(CIMWnd::GetInst().groups.begin() + i);
                UpdateNodeView();
                return;
            }
        }
    }
    else if (type == TIMConvType::kTIMConv_System) {

    }

}
void CIMWnd::UpdateConv(std::string id, uint32_t type) {
    // todo
}

void CIMWnd::GetGroupJoinedList() { // 已加入群列表
    // 获取群列表
    int ret = TIMGroupGetJoinedGroupList([](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        if (strlen(json_param) == 0) {
            return;
        }
        Json::Value json_group_list;
        Json::Reader reader;
        if (!reader.parse(json_param, json_group_list)) {
            CIMWnd::GetInst().Logf("GetJoinedGroup", kTIMLog_Error, "Json Parse Joined Group List!Failure! error:%s", reader.getFormattedErrorMessages().c_str());
            return;
        }
        CIMWnd::GetInst().Logf("GroupList", kTIMLog_Info, json_param);
        for (Json::ArrayIndex i = 0; i < json_group_list.size(); i++) {
            Json::Value& group = json_group_list[i];

            // 获取已加入群的基本信息
            std::string groupid = group[kTIMGroupBaseInfoGroupId].asString();
            std::string groupName = group[kTIMGroupBaseInfoGroupName].asString();
            bool flag = false;
            for (std::size_t i = 0; i < CIMWnd::GetInst().groups.size(); i++) {
                if (CIMWnd::GetInst().groups[i].id == groupid) {
                    CIMWnd::GetInst().groups[i].name = groupName;
                    flag = true;
                    break;
                }
            }
            if (false == flag) { // 获取群组成员
                GroupInfo group;
                group.id = groupid;
                group.name = groupName;
                CIMWnd::GetInst().groups.push_back(group);
            }
        }
        CIMWnd::GetInst().GetGroupInfoList();
    }, this);
    Logf("Init", kTIMLog_Info, "TIMGroupGetJoinedGroupList ret %d", ret);
}

void CIMWnd::GetGroupInfoList() {
    // 获取群组详细信息
    Json::Value groupids;
    for (std::size_t i = 0; i < CIMWnd::GetInst().groups.size(); i++) {
        GroupInfo& group = CIMWnd::GetInst().groups[i];
        groupids.append(group.id);
    }
    int ret = TIMGroupGetGroupInfoList(groupids.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        Json::Value json_groupmem_list;
        Json::Reader reader;
        if (!reader.parse(json_param, json_groupmem_list)) {
            CIMWnd::GetInst().Logf("GetGroupInfoList", kTIMLog_Error, "Parse Group Info List Failure!error:%s", reader.getFormattedErrorMessages().c_str());
            return;
        }
        //可以获取更加详细的群信息
        for (Json::ArrayIndex i = 0; i < json_groupmem_list.size(); i++) {
            Json::Value& group_detail = json_groupmem_list[i][kTIMGetGroupInfoResultInfo];
            std::string groupid = group_detail[kTIMGroupDetialInfoGroupId].asString();
            CIMWnd::GetInst().GetGroupMemberInfoList(groupid);
        }
        CIMWnd::GetInst().UpdateNodeView();
    }, this);
    Logf("Init", kTIMLog_Info, "TIMGroupGetJoinedGroupList ret %d", ret);
}

void CIMWnd::GetGroupMemberInfoList(std::string groupid) {
    // 获取成员信息
    typedef struct {
        std::string groupid;
        CIMWnd* ths;
    }GetMemberInfoUserData;
    GetMemberInfoUserData* ud = new GetMemberInfoUserData;
    ud->ths = this;;
    ud->groupid = groupid;

    Json::Value json_group_getmeminfos_param;
    json_group_getmeminfos_param[kTIMGroupGetMemberInfoListParamGroupId] = groupid;
    Json::Value identifiers(Json::arrayValue);
    json_group_getmeminfos_param[kTIMGroupGetMemberInfoListParamIdentifierArray] = identifiers;
    Json::Value option;
    option[kTIMGroupMemberGetInfoOptionInfoFlag] = kTIMGroupMemberInfoFlag_None;
    option[kTIMGroupMemberGetInfoOptionRoleFlag] = kTIMGroupMemberRoleFlag_All;
    Json::Value customs(Json::arrayValue);
    option[kTIMGroupMemberGetInfoOptionCustomArray] = customs;
    json_group_getmeminfos_param[kTIMGroupGetMemberInfoListParamOption] = option;
    json_group_getmeminfos_param[kTIMGroupGetMemberInfoListParamNextSeq] = 0;

    int ret = TIMGroupGetMemberInfoList(json_group_getmeminfos_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        GetMemberInfoUserData* ud = (GetMemberInfoUserData*)user_data;
        if (strlen(json_param) == 0) {
            return;
        }
        Json::Value json_groupmem_res;
        Json::Reader reader;
        if (!reader.parse(json_param, json_groupmem_res)) {
            CIMWnd::GetInst().Logf("GetGroupMemberList", kTIMLog_Error, "Parse Group Member Info List Failure!error:%s", reader.getFormattedErrorMessages().c_str());
            delete ud;
            return;
        }
        Json::Value& json_groupmem_list = json_groupmem_res[kTIMGroupGetMemberInfoListResultInfoArray];
        for (std::size_t i = 0; i < CIMWnd::GetInst().groups.size(); i++) { // 查找对应群组
            GroupInfo& group = CIMWnd::GetInst().groups[i];
            if (group.id != ud->groupid) {
                continue;
            }
            for (Json::ArrayIndex m = 0; m < json_groupmem_list.size(); m++) {
                std::string memid = json_groupmem_list[m][kTIMGroupMemberInfoIdentifier].asString();
                GroupMemberInfo info;
                info.id = memid;
                group.mems.push_back(info);
            }
        }
        CIMWnd::GetInst().UpdateNodeView();
        delete ud;
    }, ud);

    Logf("Init", kTIMLog_Info, "TIMGroupGetJoinedGroupList groupid:%s ret %d", groupid.c_str(), ret);
}

void CIMWnd::GetConvMsgs(std::string userid, TIMConvType type) {
    // 创建会话之后，先获取会话消息
    Json::Value json_msg(Json::objectValue);
    Json::Value json_msgget_param;
    json_msgget_param[kTIMMsgGetMsgListParamLastMsg] = json_msg;
    json_msgget_param[kTIMMsgGetMsgListParamIsRamble] = true;
    json_msgget_param[kTIMMsgGetMsgListParamIsForward] = false;
    json_msgget_param[kTIMMsgGetMsgListParamCount] = 100;
    std::string json = json_msgget_param.toStyledString();
    int ret = TIMMsgGetMsgList(userid.c_str(), type, json.c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        if (code != ERR_SUCC) { // 失败
            ths->Logf("Message", kTIMLog_Error, "GetMsg Failure! code:%d desc:%s", code, desc);
            return;
        }
        // 成功
        ths->ParseMsg(json_params);
    }, this);

    if (ret != TIM_SUCC) {
        Logf("Conv", kTIMLog_Error, "Conv Get Msgs %s Failure!ret %d", userid.c_str(), ret);
    }
}

void CIMWnd::OnSendFaceBtn() {  //发送表情
    Json::Value json_value_face;
    json_value_face[kTIMFaceElemIndex] = 0xa;
    json_value_face[kTIMFaceElemBuf] = "123123213";
    json_value_face[kTIMElemType] = kTIMElem_Face;
    Json::Value json_value_msg;
    json_value_msg[kTIMMsgElemArray].append(json_value_face);
    std::string json_msg = json_value_msg.toStyledString();
    if (!SendMsg(json_msg.c_str())) {
        Log("SendMsg", kTIMLog_Error, "SendMessage Failure!");
        return;
    }
}

int64_t file_size(const char* filename) {
    FILE *fp = fopen(filename, "r");
    if (!fp) return -1;
    fseek(fp, 0L, SEEK_END);
    int size = ftell(fp);
    fclose(fp);
    return size;
}

void CIMWnd::OnSendImageBtn() { //发送图片
    std::string path = OpenFile();
    if (path.length() == 0) {
        return;
    }

    Json::Value json_value_image;
    json_value_image[kTIMImageElemOrigPath] = path;
    json_value_image[kTIMElemType] = kTIMElem_Image;
    Json::Value json_value_msg;
    json_value_msg[kTIMMsgElemArray].append(json_value_image);
    std::string json_msg = json_value_msg.toStyledString();
    if (!SendMsg(json_msg.c_str())) {
        Log("SendMsg", kTIMLog_Error, "SendMessage Failure!");
        return;
    }
}

void CIMWnd::OnSendFileBtn() {  //发送文件
    std::string path = OpenFile();
    if (path.length() == 0) {
        return;
    }
    char szPath[MAX_PATH] = { 0 };
    char szName[MAX_PATH] = { 0 };
    char szDrive[MAX_PATH] = { 0 };
    char szDir[MAX_PATH] = { 0 };
    char szFName[MAX_PATH] = { 0 };
    char szExt[MAX_PATH] = { 0 };
    ::_splitpath_s(path.c_str(), szDrive, sizeof(szDrive), szDir, sizeof(szDir), szFName, sizeof(szFName), szExt, sizeof(szExt));
    if (strlen(szExt) != 0) {
        sprintf_s(szName, MAX_PATH, "%s%s", szFName, szExt);
    }
    else {
        sprintf_s(szName, MAX_PATH, "%s", szFName);
    }
    sprintf_s(szPath, MAX_PATH, "%s%s", szDrive, szDir);

    Json::Value json_value_file;
    json_value_file[kTIMElemType] = kTIMElem_File;
    json_value_file[kTIMFileElemFileName] = szName;
    json_value_file[kTIMFileElemFilePath] = path;
    json_value_file[kTIMFileElemFileSize] = 0;
    Json::Value json_value_msg;
    json_value_msg[kTIMMsgElemArray].append(json_value_file);
    std::string json_msg = json_value_msg.toStyledString();
    if (!SendMsg(json_msg.c_str())) {
        Log("SendMsg", kTIMLog_Error, "SendMessage Failure!");
        return;
    }
}

void CIMWnd::OnSendMsgBtn() {   //发送文本
    CDuiString text = GetControlText(_T("msgcontxt_edit"));
    std::string send_text = TStr2Str(text.GetData());

    Json::Value json_value_text;
    json_value_text[kTIMElemType] = kTIMElem_Text;
    json_value_text[kTIMTextElemContent] = send_text;
    Json::Value json_value_msg;
    json_value_msg[kTIMMsgElemArray].append(json_value_text);

    std::string json_msg = json_value_msg.toStyledString();
    if (!SendMsg(json_msg.c_str())) {
        Log("SendMsg", kTIMLog_Error, "SendMessage Failure!");
        return;
    }
    SetControlText(_T("msgcontxt_edit"), _T(""));
}

void CIMWnd::DownloadMessageElem(uint32_t flag, uint32_t type, std::string id, uint32_t business_id, std::string url, std::string name) {
    Json::Value download_param;
    download_param[kTIMMsgDownloadElemParamFlag] = flag;
    download_param[kTIMMsgDownloadElemParamType] = type;
    download_param[kTIMMsgDownloadElemParamId] = id;
    download_param[kTIMMsgDownloadElemParamBusinessId] = business_id;
    download_param[kTIMMsgDownloadElemParamUrl] = url;

    TIMMsgDownloadElemToPath(download_param.toStyledString().c_str(), (path_ + "\\" + name).c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;

    }, this);
}
void CIMWnd::DownloadMessageElem(std::string url, std::string name) {
    Json::Value download_param;
    download_param[kTIMMsgDownloadElemParamUrl] = url;

    TIMMsgDownloadElemToPath(download_param.toStyledString().c_str(), (path_ + "\\" + name).c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;

    }, this);
}
void CIMWnd::OnCreateConvBtn() {  //创建会话 按钮
    CDuiString tmp = GetControlText(_T("conv_userid_edit"));
    std::string userid = TStr2Str(tmp.GetData());

    if (TIM_SUCC != TIMConvCreate(userid.c_str(), kTIMConv_C2C, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        
    }, this)) {
        Logf("Conv", kTIMLog_Error, "创建会话失败!userId:%s", userid.c_str());
        return;
    }
    ConvInfo conv;
    conv.id = userid;
    convs.push_back(conv);

    
    
    Json::Value json_value_text;  // 构造消息
    json_value_text[kTIMElemType] = kTIMElem_Text;
    json_value_text[kTIMTextElemContent] = "this draft";
    Json::Value json_value_msg;
    json_value_msg[kTIMMsgElemArray].append(json_value_text);

    Json::Value json_value_draft; // 构造草稿
    json_value_draft[kTIMDraftEditTime] = time(NULL);
    json_value_draft[kTIMDraftUserDefine] = "this is userdefine";
    json_value_draft[kTIMDraftMsg] = json_value_msg;

    TIMConvSetDraft(userid.c_str(), TIMConvType::kTIMConv_C2C, json_value_draft.toStyledString().c_str());

    UpdateNodeView();
}

void CIMWnd::OnDelConvBtn() { //删除会话 按钮
    CDuiString tmp = GetControlText(_T("delete_conv_combo"));
    std::string userid = TStr2Str(tmp.GetData());
    typedef struct {
        std::string userid;
        CIMWnd* ths;
    }DelConvUserData;
    DelConvUserData* user_data = new DelConvUserData;
    user_data->ths = this;
    user_data->userid = userid;
    if (TIM_SUCC != TIMConvDelete(userid.c_str(), kTIMConv_C2C, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        DelConvUserData* ud = (DelConvUserData*)user_data;
        CIMWnd* ths = ud->ths;
        if (code != ERR_SUCC) { // 失败
            ths->Logf("Conv", kTIMLog_Error, "Del Failure! code:%d desc:%s", code, desc);
            delete ud;
            return;
        }
        // 成功
        for (std::size_t i = 0; i < ths->convs.size(); i++) {
            if (ths->convs[i].id != ud->userid) {
                continue;
            }
            ths->convs.erase(ths->convs.begin() + i);
            ths->Log("Conv", kTIMLog_Info, "Create Success!");
            break;
        }
        delete ud;
    }, user_data)) {
        Logf("Conv", kTIMLog_Error, "删除会话失败!userId:%s", userid.c_str());
        return;
    }
    UpdateNodeView();
}

void CIMWnd::OnCreateGroupBtn() { // 创建群组 按钮
    std::string groupid = GetControlText(_T("create_groupid_edit")).GetStringA();
    CDuiString name = GetControlText(_T("create_groupname_edit"));
    std::string groupname = TStr2Str(name.GetData());
    std::string type = GetControlText(_T("create_grouptype_combo")).GetStringA();
    std::string addopt = GetControlText(_T("create_groupaddopt_combo")).GetStringA();
    
    Json::Value json_group_member_array(Json::arrayValue);

    Json::Value json_value_param;
    json_value_param[kTIMCreateGroupParamGroupId] = groupid;
    if (type == "Public") {
        json_value_param[kTIMCreateGroupParamGroupType] = kTIMGroup_Public;
    }
    else if(type == "Private") {
        json_value_param[kTIMCreateGroupParamGroupType] = kTIMGroup_Private;
    }
    json_value_param[kTIMCreateGroupParamGroupName] = groupname;
    json_value_param[kTIMCreateGroupParamGroupMemberArray] = json_group_member_array;
    
    json_value_param[kTIMCreateGroupParamNotification] = "group notification";
    json_value_param[kTIMCreateGroupParamIntroduction] = "group introduction";
    json_value_param[kTIMCreateGroupParamFaceUrl] = "group face url";
    json_value_param[kTIMCreateGroupParamMaxMemberCount] = 2000;

    if (addopt == "AnyJoin")         json_value_param[kTIMCreateGroupParamAddOption] = kTIMGroupAddOpt_Any;
    else if (addopt == "AuthJoin")   json_value_param[kTIMCreateGroupParamAddOption] = kTIMGroupAddOpt_Auth;
    else if (addopt == "ForbidJoin") json_value_param[kTIMCreateGroupParamAddOption] = kTIMGroupAddOpt_Forbid;

    typedef struct {
        GroupInfo info;
        CIMWnd* ths;
    }CreateGroupUserData;

    CreateGroupUserData* ud = new CreateGroupUserData;
    ud->info.id = groupid;
    ud->info.name = groupname;
    ud->ths = this;
    std::string json_param = json_value_param.toStyledString();
    if (TIM_SUCC != TIMGroupCreate(json_param.c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CreateGroupUserData* ud = (CreateGroupUserData*)user_data;
        CIMWnd* ths = (CIMWnd*)ud->ths;
        Json::Value json_results;
        Json::Reader reader;
        if (!reader.parse(json_params, json_results)) {
            ths->Log("Group", kTIMLog_Error, reader.getFormattedErrorMessages().c_str());
            delete ud;
            return;
        }
        std::string groupid = json_results[kTIMCreateGroupResultGroupId].asString();
        if (code != ERR_SUCC) { // 失败
            ths->Logf("Group", kTIMLog_Error, "Create Failure! code:%u desc:%s! group id:%s", code, desc, groupid.c_str());
            delete ud;
            return;
        }
        // 成功
        ths->groups.push_back(ud->info);
        ths->GetGroupMemberInfoList(ud->info.id);
        ths->Logf("Group", kTIMLog_Info, "Create Group Success!group id:%s", groupid.c_str());
        delete ud;
    }, ud)) {
        Logf("Group", kTIMLog_Error, "创建会话失败!userId:%s", groupid.c_str());
    }
}

void CIMWnd::OnDelGroupBtn() { // 删除群组 按钮 
    std::string groupid = GetControlText(_T("delete_group_combo")).GetStringA();
    typedef struct {
        std::string groupid;
        CIMWnd* ths;
    }DelGroupUserData;
    DelGroupUserData* ud = new DelGroupUserData;
    ud->ths = this;
    ud->groupid = groupid;
    int ret = TIMGroupDelete(groupid.c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        DelGroupUserData* ud = (DelGroupUserData*)user_data;
        if (code != ERR_SUCC) { // 失败
            ud->ths->Logf("Group", kTIMLog_Error, "Del Failure! code:%d desc:%s group id:%s", code, desc, ud->groupid.c_str());
            delete ud;
            return;
        }
        // 成功
        for (std::size_t i = 0; i < ud->ths->groups.size(); i++) {
            if (ud->ths->groups[i].id != ud->groupid) {
                continue;
            }
            ud->ths->groups.erase(ud->ths->groups.begin() + i);
            break;
        }
        ud->ths->Logf("Group", kTIMLog_Info, "Del Group Success!group id:%s", ud->groupid.c_str());
        delete ud;
    }, ud);
    if (ret != TIM_SUCC) {
        Logf("Group", kTIMLog_Error, "删除群组失败!groupId:%s ret:%d", groupid.c_str(), ret);
        return;
    }
}

void CIMWnd::OnJoinGroupBtn() { //加入群组 按钮
    std::string groupid = GetControlText(_T("join_groupid_edit")).GetStringA();
    if (TIM_SUCC != TIMGroupJoin(groupid.c_str(), "Want Join Group, Thank you", [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        if (code != ERR_SUCC) { // 失败
            ths->Logf("Group", kTIMLog_Error, "Join Failure! code:%u desc:%s", code, desc);
        }
        else {
            ths->Log("Group", kTIMLog_Info, "Join Group Success!");
        }
    }, this)) {
        Logf("Group", kTIMLog_Error, "加入群组失败!groupId:%s", groupid.c_str());
        return;
    }
}

void CIMWnd::OnQuitGroupBtn() { //退出群组 按钮
    std::string groupid = GetControlText(_T("quit_groupid_combo")).GetStringA();
    if (TIM_SUCC != TIMGroupQuit(groupid.c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        if (code != ERR_SUCC) { // 失败
            ths->Logf("Group", kTIMLog_Error, "Quit Failure! code:%u desc:%s", code, desc);
        }
        else {
            ths->Log("Group", kTIMLog_Info, "Quit Group Success!");
        }
    }, this)) {
        Logf("Group", kTIMLog_Error, "退出群组失败!groupId:%s", groupid.c_str());
        return;
    }
}

void CIMWnd::OnInviteGroupBtn() { //邀请加入群组 按钮
    std::string groupid = GetControlText(_T("invite_groupid_combo")).GetStringA();
    std::string userids = GetControlText(_T("invite_userid_edit")).GetStringA();
    std::string userdata;

    Json::Value json_value_invite;
    json_value_invite[kTIMGroupInviteMemberParamGroupId] = groupid;
    json_value_invite[kTIMGroupInviteMemberParamUserData] = userdata;
    std::string userid;
    for (std::size_t i = 0; i < userids.size(); i++) {
        if (userids[i] == ',') {
            json_value_invite[kTIMGroupInviteMemberParamIdentifierArray].append(userid);
            userid = "";
            continue;
        }
        if (userids[i] == ' ') {
            continue;
        }
        userid.push_back(userids[i]);
    }
    if (userid.length() != 0) {
        json_value_invite[kTIMGroupInviteMemberParamIdentifierArray].append(userid);
    }
    std::string json_invite = json_value_invite.toStyledString();
    if (TIM_SUCC != TIMGroupInviteMember(json_invite.c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        if (code != ERR_SUCC) { // 失败
            ths->Logf("Group", kTIMLog_Error, "Invite Mems Failure! code:%u desc:%s", code, desc);
            return;
        }
        Json::Value json_results;
        Json::Reader reader;
        if (!reader.parse(json_params, json_results)) {
            ths->Logf("Group", kTIMLog_Error, "Invite Parse Json Failure!%s", reader.getFormattedErrorMessages().c_str());
            return;
        }
        for (Json::ArrayIndex i = 0; i < json_results.size(); i++) {
            std::string id = json_results[i][kTIMGroupInviteMemberResultIdentifier].asString();
            uint32_t res = json_results[i][kTIMGroupInviteMemberResultResult].asUInt();
            ths->Logf("Group", kTIMLog_Info, "Invite Mem %s res : %u", id.c_str(), res);
        }
    }, this)) {
        Logf("Group", kTIMLog_Error, "邀请加入群组失败!groupId:%s mems:%s", groupid.c_str(), userids.c_str());
    }
}

void CIMWnd::OnDelGroupMemBtn() {  //删除群组成员 按钮
    std::string groupid = GetControlText(_T("delmem_groupid_combo")).GetStringA();
    std::string userids = GetControlText(_T("delmem_userid_edit")).GetStringA();
    std::string reason;

    Json::Value json_value_delete;
    json_value_delete[kTIMGroupDeleteMemberParamGroupId] = groupid;
    json_value_delete[kTIMGroupDeleteMemberParamUserData] = reason;

    std::string userid;
    for (std::size_t i = 0; i < userids.size(); i++) {
        if (userids[i] == ',') {
            json_value_delete[kTIMGroupDeleteMemberParamIdentifierArray].append(userid);
            userid = "";
            continue;
        }
        if (userids[i] == ' ') {
            continue;
        }
        userid.push_back(userids[i]);
    }
    if (userid.length() != 0) {
        json_value_delete[kTIMGroupDeleteMemberParamIdentifierArray].append(userid);
    }
    std::string json_delete = json_value_delete.toStyledString();
    if (TIM_SUCC != TIMGroupDeleteMember(json_delete.c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        if (code != ERR_SUCC) { // 失败
            ths->Logf("Group", kTIMLog_Error, "Del Mems Failure! code:%u desc:%s", code, desc);
            return;
        }
        Json::Value json_results;
        Json::Reader reader;
        if (!reader.parse(json_params, json_results)) {
            ths->Logf("Group", kTIMLog_Error, "Del Mems Parse Json Failure!%s", reader.getFormattedErrorMessages().c_str());
            return;
        }
        for (Json::ArrayIndex i = 0; i < json_results.size(); i++) {
            std::string id = json_results[i][kTIMGroupDeleteMemberResultIdentifier].asString();
            uint32_t res = json_results[i][kTIMGroupDeleteMemberResultResult].asUInt();
            ths->Logf("Group", kTIMLog_Info, "Del Mem %s res : %u", id.c_str(), res);
        }
    }, this)) {
        Logf("Group", kTIMLog_Error, "删除群组成员失败!groupId:%s mems:%s", groupid.c_str(), userids.c_str());
    }
}

void CIMWnd::OnPopupMenu(MenuType mt) { //右键弹出菜单
    CDuiPoint point(0, 0);
    GetCursorPos(&point);
    CDuiString xml;
    xml.Format(_T("menu%d.xml"), mt);

    CMenuWnd* pMenu = CMenuWnd::CreateMenu(nullptr, xml.GetData(), point, &m_pm);
}

bool CIMWnd::SendMsg(const char* json_msg) {
    if (!json_msg || !m_CurShowConvNode) {
        Log("SendMsg", kTIMLog_Error, "Err1");
        return false;
    }
    TIMCommCallback commcb = [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        CIMWnd* ths = (CIMWnd*)user_data;
        if (code != ERR_SUCC) { // 失败
            ths->Logf("SendMsg", kTIMLog_Error, "code:%d desc:%s", code, desc);
            return;
        }
        // 成功
        ths->Log("SendMsg", kTIMLog_Info, "SendMsg Success");
        ths->UpdateNodeView();
    };
    Json::Value json_value_msg;
    Json::Reader reader;
    if (!reader.parse(json_msg, json_value_msg)) {
        return false;
    }
    json_value_msg[kTIMMsgSender] = login_id;
    json_value_msg[kTIMMsgClientTime] = time(NULL);
    json_value_msg[kTIMMsgServerTime] = time(NULL);
    UINT_PTR tag = m_CurShowConvNode->GetTag();
    for (std::size_t i = 0; i < convs.size(); i++) {
        ConvInfo& conv = convs[i];
        if (tag != (UINT_PTR)&conv) {
            continue;
        }
        json_value_msg[kTIMMsgConvId] = conv.id;
        json_value_msg[kTIMMsgConvType] = kTIMConv_C2C;
        Json::Value json_value_msgs;
        json_value_msgs.append(json_value_msg);
        msgs.push_back(json_value_msgs.toStyledString());
        return TIMMsgSendNewMsg(conv.id.c_str(), kTIMConv_C2C, json_value_msg.toStyledString().c_str(), commcb, this) == TIM_SUCC;
    }
    for (std::size_t i = 0; i < groups.size(); i++) {
        GroupInfo& group = groups[i];
        if (tag != (UINT_PTR)&group) {
            continue;
        }
        json_value_msg[kTIMMsgConvId] = group.id;
        json_value_msg[kTIMMsgConvType] = kTIMConv_Group;
        Json::Value json_value_msgs;
        json_value_msgs.append(json_value_msg);
        msgs.push_back(json_value_msgs.toStyledString());
        return TIMMsgSendNewMsg(group.id.c_str(), kTIMConv_Group, json_value_msg.toStyledString().c_str(), commcb, this) == TIM_SUCC;
    }
    Log("SendMsg", kTIMLog_Error, "Err2");
    return false;
}

void CIMWnd::ShowMsgs(std::vector<std::string>& msgs, std::string conv_id, TIMConvType conv_type) {
    for (std::size_t i = 0; i < msgs.size(); i++) {
        const char* json_msg_array = msgs[i].c_str();
        // 输出消息是谁发的，时间等信息
        Json::Value json_value_msgs; // 显示消息
        Json::Reader reader;
        if (!reader.parse(json_msg_array, json_value_msgs)) {
            Logf("ShowMsg", kTIMLog_Error, reader.getFormattedErrorMessages().c_str());
            return;
        }
        for (Json::ArrayIndex i = json_value_msgs.size(); i > 0; i--) {  // 遍历Message
            Json::Value& json_value_msg = json_value_msgs[i - 1];

            std::string id = json_value_msg[kTIMMsgConvId].asString();
            TIMConvType type = (TIMConvType)json_value_msg[kTIMMsgConvType].asUInt();
            if ((conv_id != id) || (conv_type != type)) {
                continue;
            }
            time_t time = json_value_msg[kTIMMsgClientTime].asUInt64();
            struct tm local;
            localtime_s(&local, &time);
            std::string sender = json_value_msg[kTIMMsgSender].asString();
            std::string tip = Fmt("%s   %d-%d-%d %02d:%02d:%02d\r\n", sender.c_str(), (local.tm_year + 1900), (local.tm_mon + 1), local.tm_mday, local.tm_hour, local.tm_min, local.tm_sec);
            m_ConvMsgData->AppendText(Str2TStr(tip).c_str());

            Json::Value& json_value_elems = json_value_msg[kTIMMsgElemArray];
            for (Json::ArrayIndex i = 0; i < json_value_elems.size(); i++) { //遍历 elem array
                Json::Value& json_value_elem = json_value_elems[i];
                uint32_t elem_type = json_value_elem[kTIMElemType].asUInt();
                switch (elem_type) {
                case kTIMElem_Text: {
                    std::string content = json_value_elem[kTIMTextElemContent].asString();
                    m_ConvMsgData->AppendText(Str2TStr(content).c_str());
                    break;
                }
                case kTIMElem_Image: {
                    std::string content = json_value_elem[kTIMTextElemContent].asString();
                    m_ConvMsgData->AppendText(Str2TStr(content).c_str());
                    break;
                }
                case kTIMElem_Sound: {
                    std::string content = json_value_elem[kTIMTextElemContent].asString();
                    m_ConvMsgData->AppendText(Str2TStr(content).c_str());
                    break;
                }
                case kTIMElem_Custom: {
                    std::string content = json_value_elem[kTIMTextElemContent].asString();
                    m_ConvMsgData->AppendText(Str2TStr(content).c_str());
                    break;
                }
                case kTIMElem_File: {
                    std::string content = json_value_elem[kTIMTextElemContent].asString();
                    m_ConvMsgData->AppendText(Str2TStr(content).c_str());
                    break;
                }
                case kTIMElem_Face: {
                    std::string content = json_value_elem[kTIMTextElemContent].asString();
                    m_ConvMsgData->AppendText(Str2TStr(content).c_str());
                    break;
                }
                case kTIMElem_Location: {
                    std::string content = json_value_elem[kTIMTextElemContent].asString();
                    m_ConvMsgData->AppendText(Str2TStr(content).c_str());
                    break;
                }
                case kTIMElem_Video: {
                    std::string content = json_value_elem[kTIMTextElemContent].asString();
                    m_ConvMsgData->AppendText(Str2TStr(content).c_str());
                    break;
                }
                case kTIMElem_GroupTips: {
                    std::string content = json_value_elem[kTIMTextElemContent].asString();
                    m_ConvMsgData->AppendText(Str2TStr(content).c_str());
                    break;
                }
                case kTIMElem_GroupReport: {
                    std::string content = json_value_elem[kTIMTextElemContent].asString();
                    m_ConvMsgData->AppendText(Str2TStr(content).c_str());
                    break;
                }
                default:
                    break;
                }
            }
            m_ConvMsgData->AppendText(_T("\r\n"));
        }
    }
}

void CIMWnd::ParseMsg(const char* json_msg_array) {  //解析消息找到对应的会话信息
    if (strlen(json_msg_array) == 0) {
        return;
    }
    msgs.push_back(json_msg_array);

    Json::Value json_value_msgs; // 显示消息
    Json::Reader reader;
    if (!reader.parse(json_msg_array, json_value_msgs)) {
        Logf("Parse", kTIMLog_Error, reader.getFormattedErrorMessages().c_str());
        return;
    }
    for (Json::ArrayIndex i = 0; i < json_value_msgs.size(); i++) {  // 遍历Message
        Json::Value& json_value_msg = json_value_msgs[i];

        std::string id = json_value_msg[kTIMMsgConvId].asString();
        TIMConvType type = (TIMConvType)json_value_msg[kTIMMsgConvType].asUInt();
        if (false == json_value_msg[kTIMMsgIsRead].asBool()) {
            TIMMsgReportReaded(id.c_str(), type, json_value_msg.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
                CIMWnd* ths = (CIMWnd*)user_data;
                
            }, this);
        }
        if (kTIMConv_System != type) {
            continue;
        }
        time_t time = json_value_msg[kTIMMsgClientTime].asUInt64();
        struct tm local;
        localtime_s(&local, &time);
        std::string sender = json_value_msg[kTIMMsgSender].asString();
        std::string tmp = Fmt("%10s : %s %d-%d-%d %02d:%02d:%02d\r\n", "SystemMsg", sender.c_str(), (local.tm_year + 1900), (local.tm_mon + 1), local.tm_mday, local.tm_hour, local.tm_min, local.tm_sec);
        m_LogData->AppendText(WStr2TStr(UTF82Wide(tmp)).c_str());
    }
    UpdateNodeView();
}
void CIMWnd::ChangeMainView(MainViewType before, MainViewType after) { //修改主界面
    RECT rect;
    ::GetWindowRect(GetHWND(), &rect);
    if ((before == INITSDK_VIEW) && (after == LOGIN_VIEW)) {
        m_LoginView->SetVisible(true);
        m_MainLogicView->SetVisible(false);
        m_InitSdkView->SetVisible(false);
        m_UserIdCombo->SelectItem(0);
    }
    if ((before == LOGIN_VIEW) && (after == INITSDK_VIEW)) {
        m_LoginView->SetVisible(false);
        m_MainLogicView->SetVisible(false);
        m_InitSdkView->SetVisible(true);
    }
    if ((before == LOGIN_VIEW) && (after == MAIN_LOGIC_VIEW)) {
        m_InitSdkView->SetVisible(false);
        m_LoginView->SetVisible(false);
        m_MainLogicView->SetVisible(true);
        //::MoveWindow(GetHWND(), rect.left, rect.top, 580, 500, TRUE);
    }
    if ((before == MAIN_LOGIC_VIEW) && (after == LOGIN_VIEW)) {
        m_InitSdkView->SetVisible(false);
        m_LoginView->SetVisible(true);
        m_MainLogicView->SetVisible(false);
        m_ConvNode->RemoveAll();
        m_GroupNode->RemoveAll();
        m_CurMenuNode = nullptr;
        m_CurShowConvNode = nullptr;
        m_LogData->SetText(_T(""));
        //m_SysMsg->SetText(_T(""));
    }
}

void CIMWnd::ChangeNodeView(NodeViewType vt) { //修改view，更新各个控件的状态
    m_MainLogicTab->SelectItem(vt);
    node_type_ = vt;
    UpdateNodeView();
}

void CIMWnd::UpdateGroupCombo(TCHAR * combo_name) { // 更新群组ID combo
    ComboBoxClear(combo_name);
    uint32_t cur = -1;
    for (uint32_t i = 0; i < groups.size(); i++) {
        GroupInfo& group = groups[i];
        ComboBoxAdd(combo_name, Str2TStr(group.id).c_str());
        if (m_CurMenuNode && (m_CurMenuNode->GetTag() == (UINT_PTR)&group)) {
            cur = i;
        }
    }
    if (cur != -1) {
        (static_cast<CComboUI*>(m_pm.FindControl(combo_name)))->SelectItem(cur);
    }
}

void CIMWnd::UpdateNodeView() {
    UINT_PTR Menu_Node_Tag = 0;
    UINT_PTR ShowConv_Node_Tag = 0;
    if (nullptr != m_CurMenuNode) {      // 当前右键点击的Node
        Menu_Node_Tag = m_CurMenuNode->GetTag();
        m_CurMenuNode = nullptr;
    }
    if (nullptr != m_CurShowConvNode) {  // 当前显示的会话的Node
        ShowConv_Node_Tag = m_CurShowConvNode->GetTag();
        m_CurShowConvNode = nullptr;
    }

    m_ConvNode->RemoveAll();  //清空node
    m_GroupNode->RemoveAll();
    for (uint32_t i = 0; i < convs.size(); i++) {  // 显示会话Node列表
        ConvInfo& conv = convs[i];
        CTreeNodeUI* node = new CTreeNodeUI(m_ConvNode);
        if (node == nullptr) {
            continue;
        }
        node->SetName(_T("conv_node_item"));
        node->SetContextMenuUsed(true);
        node->SetTag((UINT_PTR)&conv); //保存会话信息
        node->SetItemText(Str2TStr(conv.id).c_str());
        m_ConvNode->Add(node);
        if (Menu_Node_Tag == (UINT_PTR)&conv) {  //更新当前Node
            m_CurMenuNode = node;
        }
        if (ShowConv_Node_Tag == (UINT_PTR)&conv) {
            m_CurShowConvNode = node;
        }
    }
    m_ConvNode->Invalidate();
    
    for (uint32_t i = 0; i < groups.size(); i++) { // 显示群组Node列表
        GroupInfo& group = groups[i];
        CTreeNodeUI* node = new CTreeNodeUI(m_GroupNode);  //增加群组Node
        if (node == nullptr) {
            continue;;
        }
        node->SetName(_T("group_node_item"));
        node->SetContextMenuUsed(true);
        node->SetTag((UINT_PTR)&group); //保存会话信息
        node->SetItemText(Str2TStr(group.id).c_str());
        m_GroupNode->Add(node);
    
        for (uint32_t i = 0; i < group.mems.size(); i++) {
            GroupMemberInfo& info = group.mems[i];
            
            CTreeNodeUI* memnode = new CTreeNodeUI(node);
            if (memnode == nullptr) {
                continue;
            }
            memnode->SetName(_T("groupmem_node_item"));
            memnode->SetContextMenuUsed(true);
            memnode->SetTag((UINT_PTR)&group); //保存会话信息
            memnode->SetItemText(Str2TStr(info.id).c_str());
            node->Add(memnode);
        }
        if (Menu_Node_Tag == (UINT_PTR)&group) { //更新会话节点
            m_CurMenuNode = node;
        }
        if (ShowConv_Node_Tag == (UINT_PTR)&group) {
            m_CurShowConvNode = node;
        }
    }
    m_GroupNode->Invalidate();
    
    if (node_type_ == NODE_CONV_VIEW) {  //显示和更新会话消息
        m_ConvMsgData->SetText(_T(""));          //首先清空会话消息
        if (m_CurShowConvNode && m_CurShowConvNode->GetTag()) {
            UINT_PTR tag = m_CurShowConvNode->GetTag();
            
            for (uint32_t i = 0; i < groups.size(); i++) { // 显示群组消息
                GroupInfo& group = groups[i];
                if (tag != (UINT_PTR)&group) {
                    continue;
                }
                m_ConvGroupInfoView->SetVisible(true);
                m_ConvUserInfoView->SetVisible(false);
                SetControlText(_T("conv_groupinfo_lab"), Str2TStr(group.id).c_str());  //显示群组相关信息
                ShowMsgs(msgs, group.id, kTIMConv_Group);
            }
            for (uint32_t i = 0; i < convs.size(); i++) {  // 显示会话消息
                ConvInfo& conv = convs[i];
                if (tag != (UINT_PTR)&conv) {
                    continue;
                }
                m_ConvGroupInfoView->SetVisible(false);
                m_ConvUserInfoView->SetVisible(true);
                SetControlText(_T("conv_userinfo_lab"), Str2TStr(conv.id).c_str());  //显示会话名称
                ShowMsgs(msgs, conv.id, kTIMConv_C2C);
            }
        }
    }

    if (node_type_ == NODE_DELETE_CONV) {   //更新删除会话界面
        ComboBoxClear(_T("delete_conv_combo"));
        uint32_t cur = -1;
        for (uint32_t i = 0; i < convs.size(); i++) {
            ConvInfo& conv = convs[i];
            ComboBoxAdd(_T("delete_conv_combo"), Str2TStr(conv.id).c_str());
            if (m_CurMenuNode && (m_CurMenuNode->GetTag() == (UINT_PTR)&conv)) {
                cur = i;
            }
        }
        if (cur != -1) {
            (static_cast<CComboUI*>(m_pm.FindControl(_T("delete_conv_combo"))))->SelectItem(cur);
        }
    }
    if (node_type_ == NODE_CREATE_GROUP) {  //更新创建群组界面
        m_GroupAddOpt->SelectItem(groupaddopt_cursul_);
        m_GroupType->SelectItem(grouptype_cursel_);
    }
    if (node_type_ == NODE_INVITE_GROUP) { // 更新邀请加入群组界面
        UpdateGroupCombo(_T("invite_groupid_combo"));
    }
    if (node_type_ == NODE_DELETE_GROUP) { //更新删除群界面
        UpdateGroupCombo(_T("delete_group_combo"));
    }
    if (node_type_ == NODE_QUIT_GROUP) { //更新退出群组界面
        UpdateGroupCombo(_T("quit_groupid_combo"));
    }
    if (node_type_ == NODE_DELMEM_GROUP) {  //更新删除群成员界面
        UpdateGroupCombo(_T("delmem_groupid_combo"));
    }
}