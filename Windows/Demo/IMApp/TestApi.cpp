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

void Test_GetMsgList()
{
    Json::Value json_elem(Json::objectValue);
    json_elem[kTIMElemType] = 0;
    json_elem[kTIMTextElemContent] = "2";

    Json::Value json_elem_array(Json::arrayValue);
    json_elem_array.append(json_elem);

    Json::Value json_msg(Json::objectValue);
    json_msg[kTIMMsgClientTime] = 1652039330;
    json_msg[kTIMMsgConvId] = "user2";
    json_msg[kTIMMsgConvType] = 1;
    json_msg[kTIMMsgElemArray] = json_elem_array;
    json_msg[kTIMMsgIsFormSelf] = true;
    json_msg[kTIMMsgIsRead] = true;
    json_msg[kTIMMsgRand] = 3984852732LL;
    json_msg[kTIMMsgSender] = "user1";
    json_msg[kTIMMsgSeq] = 1;
    json_msg[kTIMMsgServerTime] = 1652039330;
    json_msg[kTIMMsgStatus] = 2;

    Json::Value json_msgget_param;
    json_msgget_param[kTIMMsgGetMsgListParamLastMsg] = json_msg;
    json_msgget_param[kTIMMsgGetMsgListParamIsRamble] = false;
    json_msgget_param[kTIMMsgGetMsgListParamIsForward] = false;
    json_msgget_param[kTIMMsgGetMsgListParamCount] = 100;
    std::string json = json_msgget_param.toStyledString();
    int ret = TIMMsgGetMsgList("user2", kTIMConv_C2C, json.c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "TIMMsgGetMsgList cb code:%u desc:%s", code, desc);
    }, nullptr);
}

//****************** 好友关系链接口使用**********************/
void TestFriendshipGetProfileList() {
    Json::Value json_get_profile_list_param;
    json_get_profile_list_param[kTIMFriendShipGetProfileListParamForceUpdate] = false;
    json_get_profile_list_param[kTIMFriendShipGetProfileListParamIdentifierArray].append("user1");
    json_get_profile_list_param[kTIMFriendShipGetProfileListParamIdentifierArray].append("user2");
    json_get_profile_list_param[kTIMFriendShipGetProfileListParamIdentifierArray].append("user4");

    TIMProfileGetUserProfileList(json_get_profile_list_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "GetProfileList cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestFriendshipModifySelfProfile() {
    Json::Value modify_item;
    modify_item[kTIMUserProfileItemNickName] = "change my nick name"; // 修改昵称
    modify_item[kTIMUserProfileItemGender] = kTIMGenderType_Female;  // 修改性别
    modify_item[kTIMUserProfileItemAddPermission] = kTIMProfileAddPermission_NeedConfirm;  // 修改添加好友权限

    Json::Value json_user_profile_item_custom;
    json_user_profile_item_custom[kTIMUserProfileCustemStringInfoKey] = "Str";
    json_user_profile_item_custom[kTIMUserProfileCustemStringInfoValue] = "my define data";
    modify_item[kTIMUserProfileItemCustomStringArray].append(json_user_profile_item_custom);
    int ret = TIMProfileModifySelfUserProfile(modify_item.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "GetProfileList cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestFriendshipGetFriendProfileList() {
    int ret = TIMFriendshipGetFriendProfileList([](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "GetProfileList cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestFriendshipAddFriend() {
    Json::Value json_add_friend_param;
    json_add_friend_param[kTIMFriendshipAddFriendParamIdentifier] = "user4";
    json_add_friend_param[kTIMFriendshipAddFriendParamFriendType] = FriendTypeBoth;
    json_add_friend_param[kTIMFriendshipAddFriendParamAddSource] = "Windows";
    json_add_friend_param[kTIMFriendshipAddFriendParamAddWording] = "I am Iron Man";
    int ret = TIMFriendshipAddFriend(json_add_friend_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, " cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipDeleteFriend() {
    Json::Value json_delete_friend_param;
    json_delete_friend_param[kTIMFriendshipDeleteFriendParamIdentifierArray].append("user4");
    json_delete_friend_param[kTIMFriendshipDeleteFriendParamFriendType] = FriendTypeBoth;
    int ret = TIMFriendshipDeleteFriend(json_delete_friend_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}
void TestTIMFriendshipGetPendencyList() {
    Json::Value json_get_pendency_list_param;
    json_get_pendency_list_param[kTIMFriendshipGetPendencyListParamType] = FriendPendencyTypeBoth;
    json_get_pendency_list_param[kTIMFriendshipGetPendencyListParamStartSeq] = 0;
    int ret = TIMFriendshipGetPendencyList(json_get_pendency_list_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipReportPendencyReaded() {
    uint64_t time_stamp = 1563026447;
    int ret = TIMFriendshipReportPendencyReaded(time_stamp, [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipDeletePendency() {
    Json::Value json_delete_pendency_param;
    json_delete_pendency_param[kTIMFriendshipDeletePendencyParamType] = FriendPendencyTypeSendOut;
    json_delete_pendency_param[kTIMFriendshipDeletePendencyParamIdentifierArray].append("user4");
    int ret = TIMFriendshipDeletePendency(json_delete_pendency_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipHandleFriendAddRequest() {
    Json::Value json_handle_friend_add_param;
    json_handle_friend_add_param[kTIMFriendResponeIdentifier] = "user1";
    json_handle_friend_add_param[kTIMFriendResponeAction] = ResponseActionAgreeAndAdd;
    json_handle_friend_add_param[kTIMFriendResponeRemark] = "I am Captain China";
    json_handle_friend_add_param[kTIMFriendResponeGroupName] = "schoolmate";
    int ret = TIMFriendshipHandleFriendAddRequest(json_handle_friend_add_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipModifyFriendProfile() {
    Json::Value json_modify_friend_profile_item;
    json_modify_friend_profile_item[kTIMFriendProfileItemRemark] = "xxxx yyyy";  // 修改备注
    json_modify_friend_profile_item[kTIMFriendProfileItemGroupNameArray].append("group1"); // 修改好友所在分组
    json_modify_friend_profile_item[kTIMFriendProfileItemGroupNameArray].append("group2");
    Json::Value json_modify_friend_profilie_custom;
    json_modify_friend_profilie_custom[kTIMFriendProfileCustemStringInfoKey] = "Str";
    json_modify_friend_profilie_custom[kTIMFriendProfileCustemStringInfoValue] = "this is changed value";
    json_modify_friend_profile_item[kTIMFriendProfileItemCustomStringArray].append(json_modify_friend_profilie_custom);

    Json::Value json_modify_friend_info_param;
    json_modify_friend_info_param[kTIMFriendshipModifyFriendProfileParamIdentifier] = "user4";
    json_modify_friend_info_param[kTIMFriendshipModifyFriendProfileParamItem] = json_modify_friend_profile_item;
    int ret = TIMFriendshipModifyFriendProfile(json_modify_friend_info_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipCheckFriendType() {
    Json::Value json_check_friend_list_param;
    json_check_friend_list_param[kTIMFriendshipCheckFriendTypeParamCheckType] = FriendTypeBoth;
    json_check_friend_list_param[kTIMFriendshipCheckFriendTypeParamIdentifierArray].append("user4");
    int ret = TIMFriendshipCheckFriendType(json_check_friend_list_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipCreateFriendGroup() {
    Json::Value json_create_friend_group_param;
    json_create_friend_group_param[kTIMFriendshipCreateFriendGroupParamNameArray].append("Group123");
    json_create_friend_group_param[kTIMFriendshipCreateFriendGroupParamNameArray].append("Group321");
    json_create_friend_group_param[kTIMFriendshipCreateFriendGroupParamIdentifierArray].append("user4");
    json_create_friend_group_param[kTIMFriendshipCreateFriendGroupParamIdentifierArray].append("user10");
    int ret = TIMFriendshipCreateFriendGroup(json_create_friend_group_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}
void TestTIMFriendshipGetFriendGroupList() {
    Json::Value json_get_friend_group_list_param;
    json_get_friend_group_list_param.append("Group123");
    //json_get_friend_group_list_param.append("Group1");
    //json_get_friend_group_list_param.append("Group2");
    int ret = TIMFriendshipGetFriendGroupList(json_get_friend_group_list_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}
void TestTIMFriendshipModifyFriendGroup() {
    Json::Value json_modify_friend_group_param;
    json_modify_friend_group_param[kTIMFriendshipModifyFriendGroupParamName] = "Group123";
    json_modify_friend_group_param[kTIMFriendshipModifyFriendGroupParamNewName] = "GroupNewName";
    json_modify_friend_group_param[kTIMFriendshipModifyFriendGroupParamDeleteIdentifierArray].append("user4");
    json_modify_friend_group_param[kTIMFriendshipModifyFriendGroupParamAddIdentifierArray].append("user9");
    json_modify_friend_group_param[kTIMFriendshipModifyFriendGroupParamAddIdentifierArray].append("user5");
    int ret = TIMFriendshipModifyFriendGroup(json_modify_friend_group_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipDeleteFriendGroup() {
    Json::Value json_delete_friend_group_param;
    json_delete_friend_group_param.append("GroupNewName");
    int ret = TIMFriendshipDeleteFriendGroup(json_delete_friend_group_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipAddToBlackList() {
    Json::Value json_add_to_blacklist_param;
    json_add_to_blacklist_param.append("user5");
    json_add_to_blacklist_param.append("user10");
    int ret = TIMFriendshipAddToBlackList(json_add_to_blacklist_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipGetBlackList() {
    int ret = TIMFriendshipGetBlackList([](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

void TestTIMFriendshipDeleteFromBlackList() {
    Json::Value json_delete_from_blacklist_param;
    json_delete_from_blacklist_param.append("user5");
    json_delete_from_blacklist_param.append("user10");
    int ret = TIMFriendshipDeleteFromBlackList(json_delete_from_blacklist_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "cb code:%u desc:%s", code, desc);
        CIMWnd::GetInst().Logf("TestApi", kTIMLog_Info, "json_params:%s", json_params);
    }, nullptr);
}

// 此函数用于测试各个API功能
void TestApi() {
    const void* user_data = nullptr;
    Json::Value modify_item;

    //TestFriendshipGetProfileList();
    //TestFriendshipModifySelfProfile();

    //TestTIMFriendshipDeleteFriend();
    //TestFriendshipAddFriend();

    //TestFriendshipGetFriendProfileList();

    TestTIMFriendshipModifyFriendProfile();

    //TestTIMFriendshipGetPendencyList();
    //TestTIMFriendshipReportPendencyReaded();
    //TestTIMFriendshipDeletePendency();
    //TestTIMFriendshipHandleFriendAddRequest();

    //TestTIMFriendshipCheckFriendType();

    //TestTIMFriendshipCreateFriendGroup();
    //TestTIMFriendshipGetFriendGroupList();
    //TestTIMFriendshipModifyFriendGroup();
    //TestTIMFriendshipDeleteFriendGroup();

    //TestTIMFriendshipAddToBlackList();
    //TestTIMFriendshipGetBlackList();
    //TestTIMFriendshipDeleteFromBlackList();

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

    //Test_GetMsgList();
}