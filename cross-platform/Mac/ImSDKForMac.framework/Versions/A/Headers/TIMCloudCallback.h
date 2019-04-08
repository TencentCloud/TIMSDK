#ifndef SDK_CLOUD_TIM_CALLBACK_HEADER_
#define SDK_CLOUD_TIM_CALLBACK_HEADER_
#include "TIMCloudDef.h"

#ifdef __cplusplus
extern"C"
{
#endif

/////////////////////////////////////////////////////////////////////////////////
//
//                       SDK事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name SDK事件回调
/// @{
/**
* @brief 新消息回调
*
* @param json_msg_array 新消息数组
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
* 
* @note
* 此回调可以获取新接收的消息数组。注意 消息内的元素也是一个数组。每个元素的定义由 elem_type 字段决定
*
*/
typedef void (*TIMRecvNewMsgCallback)(const char* json_msg_array, const void* user_data);
/***
*
* @example 消息数组解析示例
* Json::Value json_value_msgs; // 解析消息
* Json::Reader reader;
* if (!reader.parse(json_msg_array, json_value_msgs)) {
*     printf("reader parse failure!%s", reader.getFormattedErrorMessages().c_str());
*     return;
* }
* for (Json::ArrayIndex i = 0; i < json_value_msgs.size(); i++) {  // 遍历Message
*     Json::Value& json_value_msg = json_value_msgs[i];
*     Json::Value& elems = json_value_msg[kTIMMsgElemArray];
*     for (Json::ArrayIndex m = 0; m < elems.size(); m++) {   // 遍历Elem
*         Json::Value& elem = elems[i];
*
*         uint32_t elem_type = elem[kTIMElemType].asUInt();
*         if (elem_type == TIMElemType::kTIMElem_Text) {  // 文本
*             
*         } else if (elem_type == TIMElemType::kTIMElem_Sound) {  // 声音
*             
*         } else if (elem_type == TIMElemType::kTIMElem_File) {  // 文件
*             
*         } else if (elem_type == TIMElemType::kTIMElem_Image) { // 图片
*             
*         } else if (elem_type == TIMElemType::kTIMElem_Custom) { // 自定义元素
*             
*         } else if (elem_type == TIMElemType::kTIMElem_GroupTips) { // 群组系统消息
*             
*         } else if (elem_type == TIMElemType::kTIMElem_Face) { // 表情
*             
*         } else if (elem_type == TIMElemType::kTIMElem_Location) { // 位置
*             
*         } else if (elem_type == TIMElemType::kTIMElem_GroupReport) { // 群组系统通知
*             
*         } else if (elem_type == TIMElemType::kTIMElem_Video) { // 视频
*             
*         }
*     }
* }
* 
* @example 返回一个文本消息的Json示例。Json Key请参考[Message](TIMCloudDef.h)、[TextElem](TIMCloudDef.h)
* [
*    {
*       "message_client_time" : 1551080111,
*       "message_conv_id" : "user2",
*       "message_conv_type" : 1,
*       "message_elem_array" : [
*          {
*             "elem_type" : 0,
*             "text_elem_content" : "123213213"
*          }
*       ],
*       "message_is_from_self" : true,
*       "message_is_read" : true,
*       "message_rand" : 2130485001,
*       "message_sender" : "user1",
*       "message_seq" : 1,
*       "message_server_time" : 1551080111,
*       "message_status" : 2
*    }
* ]
*
* @example 返回一个群通知消息的Json示例。Json Key请参考[Message](TIMCloudDef.h)、[GroupReportElem](TIMCloudDef.h)
* [
*    {
*       "message_client_time" : 1551344977,
*       "message_conv_id" : "",
*       "message_conv_type" : 3,
*       "message_elem_array" : [
*          {
*             "elem_type" : 9,
*             "group_report_elem_group_id" : "first group id",
*             "group_report_elem_group_name" : "first group name",
*             "group_report_elem_msg" : "",
*             "group_report_elem_op_group_memberinfo" : {
*                "group_member_info_custom_info" : {},
*                "group_member_info_identifier" : "user1",
*                "group_member_info_join_time" : 0,
*                "group_member_info_member_role" : 0,
*                "group_member_info_msg_flag" : 0,
*                "group_member_info_msg_seq" : 0,
*                "group_member_info_name_card" : "",
*                "group_member_info_shutup_time" : 0
*             },
*             "group_report_elem_op_user" : "",
*             "group_report_elem_platform" : "Windows",
*             "group_report_elem_report_type" : 6,
*             "group_report_elem_user_data" : ""
*          }
*       ],
*       "message_is_from_self" : false,
*       "message_is_read" : true,
*       "message_rand" : 2207687390,
*       "message_sender" : "@TIM#SYSTEM",
*       "message_seq" : 1,
*       "message_server_time" : 1551344977,
*       "message_status" : 2
*    }
* ]
* 
* @example 返回一个群提示消息的Json示例。Json Key请参考[Message](TIMCloudDef.h)、[GroupTipsElem](TIMCloudDef.h)
* [
*    {
*       "message_client_time" : 1551412814,
*       "message_conv_id" : "first group id",
*       "message_conv_type" : 2,
*       "message_elem_array" : [
*          {
*             "elem_type" : 6,
*             "group_tips_elem_changed_group_memberinfo_array" : [],
*             "group_tips_elem_group_change_info_array" : [
*                {
*                   "group_tips_group_change_info_flag" : 10,
*                   "group_tips_group_change_info_value" : "first group name to other name"
*                }
*             ],
*             "group_tips_elem_group_id" : "first group id",
*             "group_tips_elem_group_name" : "first group name to other name",
*             "group_tips_elem_member_change_info_array" : [],
*             "group_tips_elem_member_num" : 0,
*             "group_tips_elem_op_group_memberinfo" : {
*                "group_member_info_custom_info" : {},
*                "group_member_info_identifier" : "user1",
*                "group_member_info_join_time" : 0,
*                "group_member_info_member_role" : 0,
*                "group_member_info_msg_flag" : 0,
*                "group_member_info_msg_seq" : 0,
*                "group_member_info_name_card" : "",
*                "group_member_info_shutup_time" : 0
*             },
*             "group_tips_elem_op_user" : "user1",
*             "group_tips_elem_platform" : "Windows",
*             "group_tips_elem_time" : 0,
*             "group_tips_elem_tip_type" : 6,
*             "group_tips_elem_user_array" : []
*          }
*       ],
*       "message_is_from_self" : false,
*       "message_is_read" : true,
*       "message_rand" : 1,
*       "message_sender" : "@TIM#SYSTEM",
*       "message_seq" : 1,
*       "message_server_time" : 1551412814,
*       "message_status" : 2
*    },
* ]
**/


/**
* @brief 新消息回调
*
* @param json_msg_readed_receipt_array 消息已读回执数组
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
*
* @example
* void MsgReadedReceiptCallback(const char* json_msg_readed_receipt_array, const void* user_data) {
*     Json::Value json_value_receipts;
*     Json::Reader reader;
*     if (!reader.parse(json_msg_readed_receipt_array, json_value_receipts)) {
*         // Json 解析失败
*         return;
*     }
*     
*     for (Json::ArrayIndex i = 0; i < json_value_receipts.size(); i++) {
*         Json::Value& json_value_receipt = json_value_receipts[i];
*     
*         std::string convid = json_value_receipt[kTIMMsgReceiptConvId].asString();
*         uint32_t conv_type = json_value_receipt[kTIMMsgReceiptConvType].asUInt();
*         uint64_t timestamp = json_value_receipt[kTIMMsgReceiptTimeStamp].asUInt64();
*     
*         // 消息已读逻辑
*     }
* }
*/
typedef void (*TIMMsgReadedReceiptCallback)(const char* json_msg_readed_receipt_array, const void* user_data);

/**
* @brief 新消息回调
*
* @param json_msg_locator_array 消息定位符数组
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
* 
* @example
* void MsgRevokeCallback(const char* json_msg_locator_array, const void* user_data) {
*     Json::Value json_value_locators;
*     Json::Reader reader;
*     if (!reader.parse(json_msg_locator_array, json_value_locators)) {
*         // Json 解析失败
*         return;
*     }
*     for (Json::ArrayIndex i = 0; i < json_value_locators.size(); i++) {
*         Json::Value& json_value_locator = json_value_locators[i];
*     
*         std::string convid = json_value_locator[kTIMMsgLocatorConvId].asString();
*         uint32_t conv_type = json_value_locator[kTIMMsgLocatorConvType].asUInt();
*         bool isrevoke      = json_value_locator[kTIMMsgLocatorIsRevoked].asBool();
*         uint64_t time      = json_value_locator[kTIMMsgLocatorTime].asUInt64();
*         uint64_t seq       = json_value_locator[kTIMMsgLocatorSeq].asUInt64();
*         uint64_t rand      = json_value_locator[kTIMMsgLocatorRand].asUInt64();
*         bool isself        = json_value_locator[kTIMMsgLocatorIsSelf].asBool();
*     
*         // 消息撤回逻辑
*     }
* }
* 
*/
typedef void (*TIMMsgRevokeCallback)(const char* json_msg_locator_array, const void* user_data);

/**
* @brief 新消息回调
*
* @param json_msg 新消息
* @param index 上传 Elem 元素在 json_msg 消息的下标
* @param cur_size 上传当前大小
* @param total_size 上传总大小
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
*
* @example
* void MsgElemUploadProgressCallback(const char* json_msg, uint32_t index, uint32_t cur_size, uint32_t total_size, const void* user_data) {
*     Json::Value json_value_msg;
*     Json::Reader reader;
*     if (!reader.parse(json_msg, json_value_msg)) {
*         // Json 解析失败
*         return;
*     }
*     Json::Value& elems = json_value_msg[kTIMMsgElemArray];
*     if (index >= elems.size()) {
*         // index 超过消息元素个数范围
*         return;
*     }
*     uint32_t elem_type = elems[index][kTIMElemType].asUInt();
*     if (kTIMElem_File ==  elem_type) {
* 
*     }
*     else if (kTIMElem_Sound == elem_type) {
* 
*     }
*     else if (kTIMElem_Video == elem_type) {
*
*     }
*     else if (kTIMElem_Image == elem_type) {
*
*     }
*     else {
*         // 其他类型元素不符合上传要求
*     }
* }
*/
typedef void (*TIMMsgElemUploadProgressCallback)(const char* json_msg, uint32_t index, uint32_t cur_size, uint32_t total_size, const void* user_data);



/**
* @brief 群事件回调
*
* @param json_group_tip_array 群提示列表
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
*/
typedef void (*TIMGroupTipsEventCallback)(const char* json_group_tip_array, const void* user_data);

/**
* @brief 会话事件回调
*
* @param conv_event 会话事件类型，请参考[TIMConvEvent](TIMCloudDef.h)
* @param json_conv_array 会话信息列表
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
*
* @example 会话事件回调数据解析
* void ConvEventCallback(TIMConvEvent conv_event, const char* json_conv_array, const void* user_data) {
*     Json::Reader reader;
*     Json::Value json_value;
*     if (!reader.parse(json_conv_array, json_value)) {
*         // Json 解析失败
*         return;
*     }
*     for (Json::ArrayIndex i = 0; i < json_value.size(); i++) { // 遍历会话类别
*         Json::Value& convinfo = json_value[i];
*         // 区分会话事件类型
*         if (conv_event == kTIMConvEvent_Add) {
*
*         }
*         else if (conv_event == kTIMConvEvent_Del) {
*
*         }
*         else if (conv_event == kTIMConvEvent_Update) {
*
*         }
*     }
* }
*/
typedef void (*TIMConvEventCallback)(TIMConvEvent conv_event, const char* json_conv_array, const void* user_data);

/**
* @brief 网络状态回调
*
* @param status 网络状态，请参考[TIMNetworkStatus](TIMCloudDef.h)
* @param code 值为ERR_SUCC表示成功，其他值表示失败。详情请参考 [错误码](https://cloud.tencent.com/document/product/269/1671)
* @param desc 错误描述字符串
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
*/
typedef void (*TIMNetworkStatusListenerCallback)(TIMNetworkStatus status, int32_t code, const char* desc, const void* user_data);
/***
*
* @example 感知网络状态的回调处理
* void NetworkStatusListenerCallback(TIMNetworkStatus status, int32_t code, const char* desc, const void* user_data) {
*     switch(status) {
*     case kTIMConnected: {
*         printf("OnConnected ! user_data:0x%08x", user_data);
*         break;
*     }
*     case kTIMDisconnected:{
*         printf("OnDisconnected ! user_data:0x%08x", user_data);
*         break;
*     }
*     case kTIMConnecting:{
*         printf("OnConnecting ! user_data:0x%08x", user_data);
*         break;
*     }
*     case kTIMConnectFailed:{
*         printf("ConnectFailed code:%u desc:%s ! user_data:0x%08x", code, desc, user_data);
*         break;
*     }
*     }
* }
**/

/**
* @brief 被踢下线回调
*
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
*/
typedef void (*TIMKickedOfflineCallback)(const void* user_data);

/**
* @brief 用户票据过期回调
*
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
*/
typedef void (*TIMUserSigExpiredCallback)(const void* user_data);

/**
* @brief 日志回调
*
* @param level 日志级别,请参考[TIMLogLevel](TIMCloudDef.h)
* @param log 日子字符串
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
*/
typedef void (*TIMLogCallback)(TIMLogLevel level, const char* log, const void* user_data);

/**
* @brief 消息更新回调
*
* @param json_msg_array 更新的消息数组
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
*
* @note
* 请参考 [TIMRecvNewMsgCallback]()
*/
typedef void (*TIMMsgUpdateCallback)(const char* json_msg_array, const void* user_data);
/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                       SDK接口回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name SDK接口回调
/// @{
/**
* @brief 接口回调定义
*
* @param code 值为ERR_SUCC表示成功，其他值表示失败。详情请参考 [错误码](https://cloud.tencent.com/document/product/269/1671)
* @param desc 错误描述字符串
* @param json_params Json字符串，不同的接口，Json字符串不一样
* @param user_data SDK负责透传的用户自定义数据，未做任何处理
*
* @note
* 所有回调均需判断 code 是否等于 ERR_SUC ，若不等于说明接口调用失败了，具体原因可以看 code 的值以及 desc 描述。请参考[错误码](https://cloud.tencent.com/document/product/269/1671)
*/
typedef void (*TIMCommCallback)(int32_t code, const char* desc, const char* json_params, const void* user_data);
/***
* 
* @example 接口[TIMSetConfig](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[SetConfig](TIMCloudDef.h)。
* {
*    "set_config_callback_log_level" : 2,
*    "set_config_is_log_output_console" : true,
*    "set_config_log_level" : 2,
*    "set_config_proxy_info" : {
*       "proxy_info_ip" : "",
*       "proxy_info_port" : 0
*    },
*    "set_config_user_config" : {
*       "user_config_group_getinfo_option" : {
*          "get_info_option_custom_array" : [],
*          "get_info_option_info_flag" : 0xffffffff,
*          "get_info_option_role_flag" : 0
*       },
*       "user_config_group_member_getinfo_option" : {
*          "get_info_option_custom_array" : [],
*          "get_info_option_info_flag" : 0xffffffff,
*          "get_info_option_role_flag" : 0
*       },
*       "user_config_is_ingore_grouptips_unread" : false,
*       "user_config_is_read_receipt" : false,
*       "user_config_is_sync_report" : false
*    }
* }
*
* @example 接口[TIMConvCreate](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[ConvInfo](TIMCloudDef.h)。
* {
*    "conv_active_time" : 1551269275,
*    "conv_id" : "user2",
*    "conv_is_has_draft" : false,
*    "conv_is_has_lastmsg" : true,
*    "conv_last_msg" : {
*       "message_client_time" : 1551101578,
*       "message_conv_id" : "user2",
*       "message_conv_type" : 1,
*       "message_elem_array" : [
*          {
*             "elem_type" : 0,
*             "text_elem_content" : "12"
*          }
*       ],
*       "message_is_from_self" : false,
*       "message_is_read" : true,
*       "message_rand" : 3726251374,
*       "message_sender" : "user2",
*       "message_seq" : 56858,
*       "message_server_time" : 1551101578,
*       "message_status" : 2
*    },
*    "conv_owner" : "",
*    "conv_type" : 1,
*    "conv_unread_num" : 1
* }
* 
* @example 接口[TIMConvGetConvList](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[ConvInfo](TIMCloudDef.h)。
* [
*    {
*       "conv_active_time" : 1551269275,
*       "conv_id" : "user2",
*       "conv_is_has_draft" : false,
*       "conv_is_has_lastmsg" : true,
*       "conv_last_msg" : {
*          "message_client_time" : 1551235066,
*          "message_conv_id" : "user2",
*          "message_conv_type" : 1,
*          "message_elem_array" : [
*             {
*                "elem_type" : 0,
*                "text_elem_content" : "ccccccccccccccccc"
*             }
*          ],
*          "message_is_from_self" : true,
*          "message_is_read" : true,
*          "message_rand" : 1073033786,
*          "message_sender" : "user1",
*          "message_seq" : 16373,
*          "message_server_time" : 1551235067,
*          "message_status" : 2
*       },
*       "conv_owner" : "",
*       "conv_type" : 1,
*       "conv_unread_num" : 0
*    }
* ]
* 
* @example 接口[TIMMsgFindByMsgLocatorList](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[Message](TIMCloudDef.h)。
* [
*    {
*       "message_client_time" : 1551080111,
*       "message_conv_id" : "user2",
*       "message_conv_type" : 1,
*       "message_elem_array" : [
*          {
*             "elem_type" : 0,
*             "text_elem_content" : "123213213"
*          }
*       ],
*       "message_is_from_self" : true,
*       "message_is_read" : true,
*       "message_rand" : 2130485001,
*       "message_sender" : "user1",
*       "message_seq" : 1,
*       "message_server_time" : 1551080111,
*       "message_status" : 2
*    },
*    ...
* ]
* 
* @example 接口[TIMMsgGetMsgList](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[Message](TIMCloudDef.h)。
* [
*    {
*       "message_client_time" : 1551080111,
*       "message_conv_id" : "user2",
*       "message_conv_type" : 1,
*       "message_elem_array" : [
*          {
*             "elem_type" : 0,
*             "text_elem_content" : "123213213"
*          }
*       ],
*       "message_is_from_self" : true,
*       "message_is_read" : true,
*       "message_rand" : 2130485001,
*       "message_sender" : "user1",
*       "message_seq" : 1,
*       "message_server_time" : 1551080111,
*       "message_status" : 2
*    },
*    ...
* ]
*
* @example 接口[TIMMsgDownloadElemToPath](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[MsgDownloadElemResult](TIMCloudDef.h)。
* {
*   "msg_download_elem_result_current_size" : 10,
*   "msg_download_elem_result_total_size" : 100
* }
* 
* @example 接口[TIMMsgBatchSend](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[MsgBatchSendResult](TIMCloudDef.h)。
* [
*    {
*       "msg_batch_send_result_code" : 0,
*       "msg_batch_send_result_desc" : "",
*       "msg_batch_send_result_identifier" : "user3"
*    },
*    {
*       "msg_batch_send_result_code" : 0,
*       "msg_batch_send_result_desc" : "",
*       "msg_batch_send_result_identifier" : "user2"
*    }
* ]
*
* @example 接口[TIMGroupCreate](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[CreateGroupResult](TIMCloudDef.h)。
* {
*    "create_group_result_groupid" : "first group id"
* }
* 
*
* @example 接口[TIMGroupInviteMember](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[GroupInviteMemberResult](TIMCloudDef.h)
* [
*    {
*       "group_invite_member_result_identifier" : "user2",
*       "group_invite_member_result_result" : 1
*    },
*    {
*       "group_invite_member_result_identifier" : "user3",
*       "group_invite_member_result_result" : 1
*    }
* ]
* 
* @example 接口[TIMGroupDeleteMember](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[GroupDeleteMemberResult](TIMCloudDef.h)
* [
*    {
*       "group_delete_member_result_identifier" : "user2",
*       "group_delete_member_result_result" : 1
*    },
*    {
*       "group_delete_member_result_identifier" : "user3",
*       "group_delete_member_result_result" : 1
*    }
* ]
* 
* @example 接口[TIMGroupGetJoinedGroupList](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[GroupBaseInfo](TIMCloudDef.h)
* [
*    {
*       "group_base_info_face_url" : "group face url",
*       "group_base_info_group_id" : "first group id",
*       "group_base_info_group_name" : "first group name",
*       "group_base_info_group_type" : "Public",
*       "group_base_info_info_seq" : 7,
*       "group_base_info_is_shutup_all" : false,
*       "group_base_info_lastest_seq" : 0,
*       "group_base_info_msg_flag" : 0,
*       "group_base_info_readed_seq" : 0,
*       "group_base_info_self_info" : {
*          "group_self_info_join_time" : 1551344977,
*          "group_self_info_msg_flag" : 0,
*          "group_self_info_role" : 400,
*          "group_self_info_unread_num" : 0
*       }
*    }
* ]
*
* @example 接口[TIMGroupGetGroupInfoList](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[GetGroupInfoResult](TIMCloudDef.h)
* [
*    {
*       "get_groups_info_result_code" : 0,
*       "get_groups_info_result_desc" : "",
*       "get_groups_info_result_info" : {
*          "group_detial_info_add_option" : 2,
*          "group_detial_info_create_time" : 1551344977,
*          "group_detial_info_custom_info" : {},
*          "group_detial_info_face_url" : "group face url",
*          "group_detial_info_group_id" : "first group id",
*          "group_detial_info_group_name" : "first group name",
*          "group_detial_info_group_type" : "Public",
*          "group_detial_info_info_seq" : 7,
*          "group_detial_info_introduction" : "group introduction",
*          "group_detial_info_is_shutup_all" : false,
*          "group_detial_info_last_info_time" : 1551344977,
*          "group_detial_info_last_msg_time" : 0,
*          "group_detial_info_max_member_num" : 2000,
*          "group_detial_info_member_num" : 1,
*          "group_detial_info_next_msg_seq" : 0,
*          "group_detial_info_notification" : "group notification",
*          "group_detial_info_online_member_num" : 0,
*          "group_detial_info_owener_identifier" : "user1",
*          "group_detial_info_searchable" : 2,
*          "group_detial_info_visible" : 2
*       }
*    }
* ]
*
* @example 接口[TIMGroupGetMemberInfoList](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[GroupGetMemberInfoListResult](TIMCloudDef.h)
* {
*    "group_get_memeber_info_list_result_info_array" : [
*       {
*          "group_member_info_custom_info" : {},
*          "group_member_info_identifier" : "user1",
*          "group_member_info_join_time" : 1551344977,
*          "group_member_info_member_role" : 400,
*          "group_member_info_msg_flag" : 0,
*          "group_member_info_msg_seq" : 0,
*          "group_member_info_name_card" : "",
*          "group_member_info_shutup_time" : 0
*       }
*    ],
*    "group_get_memeber_info_list_result_next_seq" : 0
* }
* 
* @example 接口[TIMGroupGetPendencyList](TIMCloud.h)的回调TIMCommCallback参数json_params的Json。Json Key请参考[GroupPendencyResult](TIMCloudDef.h) 
* {
*    "group_pendency_result_next_start_time" : 0,
*    "group_pendency_result_pendency_array" : [
*       {
*          "group_pendency_add_time" : 1551414487947,
*          "group_pendency_apply_invite_msg" : "Want Join Group, Thank you",
*          "group_pendency_approval_msg" : "",
*          "group_pendency_form_identifier" : "user2",
*          "group_pendency_form_user_defined_data" : "",
*          "group_pendency_group_id" : "four group id",
*          "group_pendency_handle_result" : 0,
*          "group_pendency_handled" : 0,
*          "group_pendency_pendency_type" : 0,
*          "group_pendency_to_identifier" : "user1",
*          "group_pendency_to_user_defined_data" : ""
*       }
*    ],
*    "group_pendency_result_read_time_seq" : 0,
*    "group_pendency_result_unread_num" : 1
* }
* 
* @note 以下接口的回调TIMCommCallback参数json_params均为空字符串""
* > [TIMLogin](TIMCloud.h) 
* > [TIMLogout](TIMCloud.h) 
* > [TIMMsgSendNewMsg](TIMCloud.h)
* > [TIMMsgSaveMsg](TIMCloud.h)
* > [TIMMsgReportReaded](TIMCloud.h)
* > [TIMMsgRevoke](TIMCloud.h)
* > [TIMMsgImportMsgList](TIMCloud.h)
* > [TIMMsgDelete](TIMCloud.h)
* > [TIMConvDelete](TIMCloud.h)
* > [TIMGroupDelete](TIMCloud.h)
* > [TIMGroupJoin](TIMCloud.h)
* > [TIMGroupQuit](TIMCloud.h)
* > [TIMGroupModifyGroupInfo](TIMCloud.h)
* > [TIMGroupModifyMemberInfo](TIMCloud.h)
* > [TIMGroupReportPendencyReaded](TIMCloud.h)
* > [TIMGroupHandlePendency](TIMCloud.h)
*
**/
/// @}


#ifdef __cplusplus
};
#endif //__cplusplus

#endif //SDK_CLOUD_TIM_CALLBACK_HEADER_
