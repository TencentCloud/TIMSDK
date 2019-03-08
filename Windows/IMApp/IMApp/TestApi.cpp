#include "TestApi.h"
#include "json.h"
#include "IMWnd.h"
#include <time.h>
//批量发送
void Test_TIMMsgBatchSend() {
    //构造消息文本元素
    Json::Value json_value_elem;
    json_value_elem[kTIMElemType] = TIMElemType::kTIMElem_Text;
    json_value_elem[kTIMTextElemContent] = "this is batch send msgs";
    //构造消息
    Json::Value json_value_msg;
    json_value_msg[kTIMMsgSender] = CIMWnd::GetInst().login_id;
    json_value_msg[kTIMMsgClientTime] = time(NULL);
    json_value_msg[kTIMMsgServerTime] = time(NULL);
    json_value_msg[kTIMMsgElemArray].append(json_value_elem);

    // 构造批量发送ID数组列表
    Json::Value json_value_ids(Json::arrayValue);
    json_value_ids.append("user2");
    json_value_ids.append("user3");
    // 构造批量发送接口参数
    Json::Value json_value_batchsend;
    json_value_batchsend[kTIMMsgBatchSendParamIdentifierArray] = json_value_ids;
    json_value_batchsend[kTIMMsgBatchSendParamMsg] = json_value_msg;

    int ret = TIMMsgBatchSend(json_value_batchsend.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        if (code != ERR_SUCC) { // 批量发送成功
            CIMWnd::GetInst().Logf("TESTAPI", kTIMLog_Error, "TIMMsgBatchSend cb code:%u desc:%s", code, desc);
            return;
        }
        Json::Value json_result;
        Json::Reader reader;
        if (!reader.parse(json_param, json_result)) {
            CIMWnd::GetInst().Logf("TESTAPI", kTIMLog_Error, "TIMMsgBatchSend result parse Failure!%s",reader.getFormattedErrorMessages().c_str());
            return;
        }
        for (Json::ArrayIndex i = 0; i < json_result.size(); i++) {
            Json::Value& res = json_result[i];
            std::string id = res[kTIMMsgBatchSendResultIdentifier].asString();
            int sub_code = res[kTIMMsgBatchSendResultCode].asInt();
            std::string sub_desc = res[kTIMMsgBatchSendResultDesc].asString();
            
            if (code != ERR_SUCC) {
                CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMMsgBatchSend to id:%s Failure! code:%u desc:%s", id.c_str(), sub_code, sub_desc.c_str());
            }
            else {
                CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "TIMMsgBatchSend to id:%s Success!", id.c_str());
            }
        }
    }, nullptr);
    if (TIM_SUCC != ret) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMMsgBatchSend Failure!ret %d", ret);
    }
}

void Test_MsgFind() {
    Json::Value json_msg_locator;  // 一条消息对应一个消息定位符(精准定位)
    json_msg_locator[kTIMMsgLocatorIsRevoked] = false; //消息是否被撤回
    json_msg_locator[kTIMMsgLocatorTime] = 123; //填入消息的时间
    json_msg_locator[kTIMMsgLocatorSeq] = 1;    
    json_msg_locator[kTIMMsgLocatorIsSelf] = false;
    json_msg_locator[kTIMMsgLocatorRand] = 12345678;

    Json::Value json_msg_locators;
    json_msg_locators.append(json_msg_locator);
    TIMMsgFindByMsgLocatorList("user2", kTIMConv_C2C, json_msg_locators.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        if (code != ERR_SUCC) { 
            CIMWnd::GetInst().Logf("TESTAPI", kTIMLog_Error, "TIMMsgBatchSend cb code:%u desc:%s", code, desc);
            return;
        }
    }, nullptr);
}


void Test_MsgImport() {
    Json::Value json_value_elem; //构造消息文本元素
    json_value_elem[kTIMElemType] = TIMElemType::kTIMElem_Text;
    json_value_elem[kTIMTextElemContent] = "this is import msg";
    
    Json::Value json_value_msg; //构造消息
    json_value_msg[kTIMMsgSender] = CIMWnd::GetInst().login_id;
    json_value_msg[kTIMMsgClientTime] = time(NULL);
    json_value_msg[kTIMMsgServerTime] = time(NULL);
    json_value_msg[kTIMMsgElemArray].append(json_value_elem);

    Json::Value json_value_msgs;  //消息数组
    json_value_msgs.append(json_value_msg);

    TIMMsgImportMsgList("user3", kTIMConv_C2C, json_value_msgs.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        if (code != ERR_SUCC) {
            CIMWnd::GetInst().Logf("TESTAPI", kTIMLog_Error, "TIMMsgBatchSend cb code:%u desc:%s", code, desc);
            return;
        }
    }, nullptr);
}

void Test_MsgDelete() {
    Json::Value json_value_msg(Json::objectValue);

    Json::Value json_value_msgdelete;
    json_value_msgdelete[kTIMMsgDeleteParamIsRamble] = false;
    json_value_msgdelete[kTIMMsgDeleteParamMsg] = json_value_msg;
    TIMMsgDelete("user2", kTIMConv_C2C, json_value_msgdelete.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        if (code != ERR_SUCC) {
            CIMWnd::GetInst().Logf("TESTAPI", kTIMLog_Error, "TIMMsgBatchSend cb code:%u desc:%s", code, desc);
            return;
        }
    }, nullptr);
}

void Test_SetGroupInfo() {
    //*修改群组名称和群通知
    Json::Value json_value_setgroupinfo;
    json_value_setgroupinfo[kTIMGroupModifyInfoParamGroupId] = "first group id";
    json_value_setgroupinfo[kTIMGroupModifyInfoParamModifyFlag] = kTIMGroupModifyInfoFlag_Name | kTIMGroupModifyInfoFlag_Notification;
    json_value_setgroupinfo[kTIMGroupModifyInfoParamGroupName] = "first group name to other name";
    json_value_setgroupinfo[kTIMGroupModifyInfoParamNotification] = "first group notification";
    //*/

    /* 修改群主
    Json::Value json_value_setgroupinfo;
    json_value_setgroupinfo[kTIMGroupModifyInfoParamGroupId] = "first group id";
    json_value_setgroupinfo[kTIMGroupModifyInfoParamModifyFlag] = kTIMGroupModifyInfoFlag_Owner;
    json_value_setgroupinfo[kTIMGroupModifyInfoParamOwner] = "user2";
    //*/
    int ret = TIMGroupModifyGroupInfo(json_value_setgroupinfo.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        if (code != ERR_SUCC) { 
            CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupModifyGroupInfo cb code:%u desc:%s", code, desc);
            return;
        }
        
    }, nullptr);
    if (TIM_SUCC != ret) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupSetGroupInfo Failure!ret %d", ret);
    }
}

void Test_SetGroupMemberInfo() {
    // 设置 成员为管理员
    Json::Value json_value_setgroupmeminfo;
    json_value_setgroupmeminfo[kTIMGroupModifyMemberInfoParamGroupId] = "third group id";
    json_value_setgroupmeminfo[kTIMGroupModifyMemberInfoParamIdentifier] = "user2";
    json_value_setgroupmeminfo[kTIMGroupModifyMemberInfoParamModifyFlag] = kTIMGroupMemberModifyFlag_MemberRole | kTIMGroupMemberModifyFlag_NameCard;
    json_value_setgroupmeminfo[kTIMGroupModifyMemberInfoParamMemberRole] = kTIMMemberRole_Admin;
    json_value_setgroupmeminfo[kTIMGroupModifyMemberInfoParamNameCard] = "change name card";

    int ret = TIMGroupModifyMemberInfo(json_value_setgroupmeminfo.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        if (code != ERR_SUCC) { 
            CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupSetMemberInfo cb code:%u desc:%s", code, desc);
            return;
        }

    }, nullptr);
    if (TIM_SUCC != ret) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupSetMemberInfo Failure!ret %d", ret);
    }
}

//  获取未决信息 并处理
void Test_GroupGetPendencyList() {
    Json::Value get_pendency_option;
    get_pendency_option[kTIMGroupPendencyOptionStartTime] = 0;
    get_pendency_option[kTIMGroupPendencyOptionMaxLimited] = 0;

    int ret = TIMGroupGetPendencyList(get_pendency_option.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
        if (code != ERR_SUCC) { 
            CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupGetPendencyList cb code:%u desc:%s", code, desc);
            return;
        }
        Json::Value group_pendency_result;
        Json::Reader reader;
        if (!reader.parse(json_param, group_pendency_result)) {
            CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupGetPendencyList Json Parse Failure!%s", reader.getFormattedErrorMessages().c_str());
            return;
        }

        Json::Value& group_pendency_array = group_pendency_result[kTIMGroupPendencyResultPendencyArray];
        for (Json::ArrayIndex i = 0; i < group_pendency_array.size(); i++) {

            /* 上报未决消息已读
            uint64_t timestamp = group_pendency_array[i][kTIMGroupPendencyAddTime].asUInt64();
            int ret = TIMGroupReportPendencyReaded(timestamp, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
                if (code != ERR_SUCC) { // 
                    CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupHandlePendency cb code:%u desc:%s", code, desc);
                    return;
                }
            }, nullptr);
            if (TIM_SUCC != ret) {
                CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupHandlePendency Failure!ret %d", ret);
            }
            //*/

            //* 处理 每一个pendency 为accept 
            Json::Value pendency; //构造 GroupPendency

            Json::Value handle_pendency;
            handle_pendency[kTIMGroupHandlePendencyParamIsAccept] = true;
            handle_pendency[kTIMGroupHandlePendencyParamHandleMsg] = "I accept this pendency";
            handle_pendency[kTIMGroupHandlePendencyParamPendency] = pendency;
            int ret = TIMGroupHandlePendency(handle_pendency.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
                if (code != ERR_SUCC) { // 
                    CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupHandlePendency cb code:%u desc:%s", code, desc);
                    return;
                }
            }, nullptr);
            if (TIM_SUCC != ret) {
                CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupHandlePendency Failure!ret %d", ret);
            }
            //*/
        }

        // HandlePendency
    }, nullptr);
    if (TIM_SUCC != ret) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Error, "TIMGroupGetPendencyList Failure!ret %d", ret);
    }
}


// 此函数用于测试各个API功能
void TestApi() {
    const void* user_data = nullptr;
    //TIMSetRecvNewMsgCallback(RecvNewMsgCallback, user_data);
    //Test_MsgImport();
//Json::Value identifiers(Json::arrayValue);
    //...
    //    Json::Value customs(Json::arrayValue);
    //...
    //    Json::Value option;
    //option[kTIMGroupMemberGetInfoOptionInfoFlag] = kTIMGroupMemberInfoFlag_None;
    //option[kTIMGroupMemberGetInfoOptionRoleFlag] = kTIMGroupMemberRoleFlag_All;
    //option[kTIMGroupMemberGetInfoOptionCustomArray] = customs;
    //Json::Value getmeminfo_opt;
    //getmeminfo_opt[kTIMGroupGetMemberInfoListParamGroupId] = groupid;
    //getmeminfo_opt[kTIMGroupGetMemberInfoListParamIdentifierArray] = identifiers;
    //getmeminfo_opt[kTIMGroupGetMemberInfoListParamOption] = option;
    //getmeminfo_opt[kTIMGroupGetMemberInfoListParamNextSeq] = 0;

    //int ret = TIMGroupGetMemberInfoList(getmeminfo_opt.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {

    //}, this);
}
    
    Test_MsgImport();
}