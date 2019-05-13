#ifndef SDK_CLOUD_TIM_HEADER_
#define SDK_CLOUD_TIM_HEADER_
#include "TIMCloudDef.h"
#include "TIMCloudCallback.h"

#ifdef __cplusplus
extern"C"
{
#endif

/// @overview TIMCloud
/// @overbrief 腾讯云通信的跨平台C接口(API)
/*
* @brief 各个平台的下载链接
* > windows平台[ImSDK](https://github.com/tencentyun/TIMSDK/tree/master/cross-platform/Windows), 暂不支持64位编译
* >> Windows快速开始[集成SDK](https://cloud.tencent.com/document/product/269/33489)和[跑通demo](https://cloud.tencent.com/document/product/269/33488)
* > iOS平台[ImSDK](https://github.com/tencentyun/TIMSDK/tree/master/cross-platform/iOS)
* > Mac平台[ImSDK](https://github.com/tencentyun/TIMSDK/tree/master/cross-platform/Mac)
* > Android平台[ImSDK](https://github.com/tencentyun/TIMSDK/tree/master/cross-platform/Android)
*
* @note 关于回调的说明
* > 回调分两种，一种是指调用接口的异步返回，另外一种指后台推送的通知。回调在ImSDK内部的逻辑线程触发，跟调用接口的线程可能不是同一线程
* > 在Windows平台，如果调用[TIMInit]()接口进行初始化Imsdk之前，已创建了UI的消息循环，且调用[TIMInit]()接口的线程为主UI线程，则ImSDK内部会将回调抛到主UI线程调用
*
*/

/////////////////////////////////////////////////////////////////////////////////
//
//  注册SDK回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 事件回调接口
/// @{
/**
* @brief 设置接收新消息回调
* @param cb 新消息回调函数，请参考[TIMRecvNewMsgCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* 如果用户是登录状态，ImSDK收到新消息会通过此接口设置的回调抛出，另外需要注意，抛出的消息不一定是未读的消息，
* 只是本地曾经没有过的消息（例如在另外一个终端已读，拉取最近联系人消息时可以获取会话最后一条消息，如果本地没有，会通过此方法抛出）。
* 在用户登录之后，ImSDK会拉取离线消息，为了不漏掉消息通知，需要在登录之前注册新消息通知。
*/
TIM_DECL void TIMSetRecvNewMsgCallback(TIMRecvNewMsgCallback cb, const void* user_data);

/**
* @brief 设置消息已读回执回调
* @param cb 消息已读回执回调，请参考[TIMMsgReadedReceiptCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* 发送方发送消息，接收方调用接口[TIMMsgReportReaded]()上报该消息已读，发送方 ImSDK会通过此接口设置的回调抛出。
*/
TIM_DECL void TIMSetMsgReadedReceiptCallback(TIMMsgReadedReceiptCallback cb, const void* user_data);

/**
* @brief 设置接收的消息被撤回回调
* @param cb 消息撤回通知回调,请参考[TIMMsgRevokeCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* 发送方发送消息，接收方收到消息。此时发送方调用接口[TIMMsgRevoke]()撤回该消息，接收方的ImSDK会通过此接口设置的回调抛出。
*/
TIM_DECL void TIMSetMsgRevokeCallback(TIMMsgRevokeCallback cb, const void* user_data);

/**
* @brief 设置消息内元素相关文件上传进度回调
* @param cb 文件上传进度回调，请参考[TIMMsgElemUploadProgressCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note
* 设置消息元素上传进度回调。当消息内包含图片、声音、文件、视频元素时，ImSDK会上传这些文件，并触发此接口设置的回调，用户可以根据回调感知上传的进度
*/
TIM_DECL void TIMSetMsgElemUploadProgressCallback(TIMMsgElemUploadProgressCallback cb, const void* user_data);

/**
* @brief 设置群组系统消息回调
* @param cb 群消息回调，请参考[TIMGroupTipsEventCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* 群组系统消息事件包括 加入群、退出群、踢出群、设置管理员、取消管理员、群资料变更、群成员资料变更。此消息是针对所有群组成员下发的
*/
TIM_DECL void TIMSetGroupTipsEventCallback(TIMGroupTipsEventCallback cb, const void* user_data);

/**
* @brief 设置会话事件回调
* @param cb 会话事件回调，请参考[TIMConvEventCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* > 会话事件包括：
* >> 会话新增
* >> 会话删除
* >> 会话更新。
* > 任何产生一个新会话的操作都会触发会话新增事件，比如调用接口[TIMConvCreate]()创建会话，接收到未知会话的第一条消息等。
* 任何已有会话变化的操作都会触发会话更新事件，比如收到会话新消息，消息撤回，已读上报等。
* 调用接口[TIMConvDelete]()删除会话成功时会触发会话删除事件。
*/
TIM_DECL void TIMSetConvEventCallback(TIMConvEventCallback cb, const void* user_data);

/**
* @brief 设置网络连接状态监听回调
* @param cb 连接事件回调，请参考[TIMNetworkStatusListenerCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note
* > 当调用接口 [TIMInit]() 时，ImSDK会去连接云后台。此接口设置的回调用于监听网络连接的状态。
* > 网络连接状态包含四个：正在连接、连接失败、连接成功、已连接。这里的网络事件不表示用户本地网络状态，仅指明 SDK 是否与 IM 云 Server 连接状态。
* > 可选设置，如果要用户感知是否已经连接服务器，需要设置此回调，用于通知调用者跟通讯后台链接的连接和断开事件，另外，如果断开网络，等网络恢复后会自动重连，自动拉取消息通知用户，用户无需关心网络状态，仅作通知之用
* > 只要用户处于登录状态，ImSDK内部会进行断网重连，用户无需关心。
*/
TIM_DECL void TIMSetNetworkStatusListenerCallback(TIMNetworkStatusListenerCallback cb, const void* user_data);

/**
* @brief 设置被踢下线通知回调
* @param cb 踢下线回调，请参考[TIMKickedOfflineCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note
* > 用户如果在其他终端登录，会被踢下线，这时会收到用户被踢下线的通知，出现这种情况常规的做法是提示用户进行操作（退出，或者再次把对方踢下线）。
* > 用户如果在离线状态下被踢，下次登录将会失败，可以给用户一个非常强的提醒（登录错误码 ERR_IMSDK_KICKED_BY_OTHERS：6208），开发者也可以选择忽略这次错误，再次登录即可。
* > 用户在线情况下的互踢情况：
* +  用户在设备1登录，保持在线状态下，该用户又在设备2登录，这时用户会在设备1上强制下线，收到 TIMKickedOfflineCallback 回调。
*    用户在设备1上收到回调后，提示用户，可继续调用login上线，强制设备2下线。这里是在线情况下互踢过程。
* > 用户离线状态互踢:
* +  用户在设备1登录，没有进行logout情况下进程退出。该用户在设备2登录，此时由于用户不在线，无法感知此事件，
*    为了显式提醒用户，避免无感知的互踢，用户在设备1重新登录时，会返回（ERR_IMSDK_KICKED_BY_OTHERS：6208）错误码，表明之前被踢，是否需要把对方踢下线。
*    如果需要，则再次调用login强制上线，设备2的登录的实例将会收到 TIMKickedOfflineCallback 回调。
*/
TIM_DECL void TIMSetKickedOfflineCallback(TIMKickedOfflineCallback cb, const void* user_data);

/**
* @brief 设置票据过期回调
* @param cb 票据过期回调，请参考[TIMUserSigExpiredCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* 用户票据，可能会存在过期的情况，如果用户票据过期，此接口设置的回调会调用。
* [TIMLogin]()也将会返回70001错误码。开发者可根据错误码或者票据过期回调进行票据更换
*/
TIM_DECL void TIMSetUserSigExpiredCallback(TIMUserSigExpiredCallback cb, const void* user_data);

/**
* @brief 设置日志回调
* @param cb 日志回调，请参考[TIMLogCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* 设置日志监听的回调之后，ImSDK内部的日志会回传到此接口设置的回调。
* 客户可以通过接口[TIMSetConfig]()配置哪些日志级别的日志回传到回调函数。
*/
TIM_DECL void TIMSetLogCallback(TIMLogCallback cb, const void* user_data);

/**
* @brief 设置消息在云端被修改后回传回来的消息更新通知回调
* @param cb 消息更新回调，请参考[TIMMsgUpdateCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* > 当您发送的消息在服务端被修改后，ImSDK会通过该回调通知给您 
* > 您可以在您自己的服务器上拦截所有IM消息 [发单聊消息之前回调](https://cloud.tencent.com/document/product/269/1632)
* > 设置成功之后，腾讯云IM服务器会将您的用户发送的每条消息都同步地通知给您的业务服务器。
* > 您的业务服务器可以对该条消息进行修改（比如过滤敏感词），如果您的服务器对消息进行了修改，ImSDK就会通过此回调通知您。
*/
TIM_DECL void TIMSetMsgUpdateCallback(TIMMsgUpdateCallback cb, const void* user_data);
/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                       SDK初始化
//
/////////////////////////////////////////////////////////////////////////////////
/// @name SDK初始化相关接口
/// @{
/**
* @brief ImSDK初始化
*
* @param sdk_app_id 官网申请的 SDKAppid
* @param json_sdk_config SDK配置选项Json字符串,详情请参考[SdkConfig](TIMCloudDef.h)
* @return int 返回TIM_SUCC表示接口调用成功，其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @example
* Json::Value json_value_init;
* json_value_init[kTIMSdkConfigLogFilePath] = "D:\\";
* json_value_init[kTIMSdkConfigConfigFilePath] = "D:\\";
* json_value_init[kTIMSdkConfigAccountType] = "107";
* 
* uint64_t sdk_app_id = 1234567890;
* if (TIM_SUCC != TIMInit(sdk_app_id, json_value_init.toStyledString().c_str())) {
*     // TIMInit 接口调用错误，ImSDK初始化失败   
* }
* 
* // json_value_init.toStyledString() 得到 json_sdk_config JSON 字符串如下
* {
*    "sdk_config_account_type" : "107",
*    "sdk_config_config_file_path" : "D:\\",
*    "sdk_config_log_file_path" : "D:\\"
* }
* 
* @note 
* > 在使用ImSDK进一步操作之前，需要先初始化ImSDK
* > json_sdk_config 可以为 NULL 或者""空字符串，在此情况下SdkConfig均为默认值。
* > json_sdk_config 里面的每个Json key都是选填的，详情请参考[SdkConfig](TIMCloudDef.h)
* 
*/
TIM_DECL int TIMInit(uint64_t sdk_app_id, const char* json_sdk_config);

/**
* @brief  ImSDK卸载
* @return int 返回TIM_SUCC表示接口调用成功，其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @example
* if (TIM_SUCC != TIMUninit()) {
*     // ImSDK卸载失败  
* }
* @note
* 卸载DLL或退出进程前需此接口卸载ImSDK，清理ImSDK相关资源
*
*/
TIM_DECL int TIMUninit(void);

/**
* @brief  获取ImSDK版本号
* @return const char* 返回ImSDK的版本号
*/
TIM_DECL const char* const TIMGetSDKVersion(void);

/**
* @brief  设置额外的用户配置
* @param json_config 其他配置选项
* @param cb 返回设置配置之后所有配置的回调，此回调cb可为空，表示不获取所有配置信息。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_user_config;
* json_user_config[kTIMUserConfigIsReadReceipt] = true;  // 开启已读回执
* Json::Value json_config;
* json_config[kTIMSetConfigUserConfig] = json_user_config;
*
* if (TIM_SUCC != TIMSetConfig(json_config.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     // 回调内部
* }, this)) {
*     //TIMSetConfig接口调用失败
* } 
*
* // json_config.toStyledString().c_str() 得到 json_config JSON 字符串如下
* {
*    "set_config_user_config" : {
*       "user_config_is_read_receipt" : true
*    }
* }
* 
* @note 
* 目前支持设置的配置有代理的IP和端口、输出日志的级别、获取群信息/群成员信息的默认选项、是否接受消息已读回执事件等。
* 每项配置可以单独设置、也可以一起配置,详情请参考 [SetConfig](TIMCloudDef.h)
*/
TIM_DECL int TIMSetConfig(const char* json_config, TIMCommCallback cb, const void* user_data);
/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                       登录/登出
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 登录登出相关接口
/// @{
/**
* @brief 登录
*
* @param user_id 用户的indentifier
* @param user_sig 用户的 sig
* @param cb 登录成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note 
* 用户登录腾讯后台服务器后才能正常收发消息，登录需要用户提供identifier、userSig等信息，具体含义请参考
* [登录鉴权](https://cloud.tencent.com/document/product/269/31999)
*/
TIM_DECL int TIMLogin(const char* user_id, const char* user_sig, TIMCommCallback cb, const void* user_data);

/**
* @brief  登出
*
* @param cb 登出成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* 如用户主动登出或需要进行用户的切换，则需要调用登出操作
*/
TIM_DECL int TIMLogout(TIMCommCallback cb, const void* user_data);
/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                       会话相关接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 会话相关接口
/*
* @brief
* ImSDK中会话（Conversation）分为两种
* > C2C会话，表示单聊情况自己与对方建立的对话，读取消息和发送消息都是通过会话完成
* > 群会话，表示群聊情况下，群内成员组成的会话，群会话内发送消息群成员都可接收到。
*/
/// @{
/**
* @brief 创建会话
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param cb 创建会话的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example 获取对方 identifier 为Windows-02的单聊会话示例：
* const void* user_data = nullptr; // 回调函数回传
* const char* userid = "Windows-02";
* int ret = TIMConvCreate(userid, kTIMConv_C2C, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     if (ERR_SUCC != code) {
*         return;
*     }
*     // 回调返回会话的具体信息
* }, user_data);
* if (ret != TIM_SUCC) {
*     // 调用 TIMConvCreate 接口失败
* }
* 
* @example 获取群组ID为Windows-Group-01的群聊会话示例：
* const void* user_data = nullptr; // 回调函数回传
* const char* userid = "Windows-Group-01";
* int ret = TIMConvCreate(userid, kTIMConv_Group, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     if (ERR_SUCC != code) {
*         return;
*     }
*     // 回调返回会话的具体信息
* }, user_data);
* if (ret != TIM_SUCC) {
*     // 调用 TIMConvCreate 接口失败
* }
* 
* @note
* > 会话是指面向一个人或者一个群组的对话，通过与单个人或群组之间会话收发消息
* > 此接口创建或者获取会话信息，需要指定会话类型（群组或者单聊），以及会话对方标志（对方帐号或者群号）。会话信息通过cb回传。
*/
TIM_DECL int TIMConvCreate(const char* conv_id, enum TIMConvType conv_type, TIMCommCallback cb, const void* user_data); 

/**
* @brief 删除会话
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param cb 删除会话成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* 此接口用于删除会话，删除会话是否成功通过回调返回。
*/
TIM_DECL int TIMConvDelete(const char* conv_id, enum TIMConvType conv_type, TIMCommCallback cb, const void* user_data);

/**
* @brief 获取本地缓存的会话列表
* 
* @param cb 获取会话缓存列表的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
*/
TIM_DECL int TIMConvGetConvList(TIMCommCallback cb, const void* user_data);

/**
* @brief 设置指定会话的草稿
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_draft_param 被设置的草稿Json字符串
* @return int 返回TIM_SUCC表示接口调用成功，其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @example
* Json::Value json_value_text;  // 构造消息
* json_value_text[kTIMElemType] = kTIMElem_Text;
* json_value_text[kTIMTextElemContent] = "this draft";
* Json::Value json_value_msg;
* json_value_msg[kTIMMsgElemArray].append(json_value_text);
* 
* Json::Value json_value_draft; // 构造草稿
* json_value_draft[kTIMDraftEditTime] = time(NULL);
* json_value_draft[kTIMDraftUserDefine] = "this is userdefine";
* json_value_draft[kTIMDraftMsg] = json_value_msg;
* 
* if (TIM_SUCC != TIMConvSetDraft(userid.c_str(), TIMConvType::kTIMConv_C2C, json_value_draft.toStyledString().c_str())) {
*     // TIMConvSetDraft 接口调用失败
* } 
*
* // json_value_draft.toStyledString().c_str() 得到 json_draft_param JSON 字符串如下
* {
*    "draft_edit_time" : 1551271429,
*    "draft_msg" : {
*       "message_elem_array" : [
*          {
*             "elem_type" : 0,
*             "text_elem_content" : "this draft"
*          }
*       ]
*    },
*    "draft_user_define" : "this is userdefine"
* }
*
* @note
* 会话草稿一般用在保存用户当前输入的未发送的消息。
*/
TIM_DECL int TIMConvSetDraft(const char* conv_id, enum TIMConvType conv_type, const char* json_draft_param);

/**
* @brief 删除指定会话的草稿
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @return int 返回TIM_SUCC表示接口调用成功，其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
*/
TIM_DECL int TIMConvCancelDraft(const char* conv_id, enum TIMConvType conv_type);
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                       消息相关接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 消息相关接口
/// @brief 消息介绍请参考 [单聊消息](https://cloud.tencent.com/document/product/269/3662)、[群组消息](https://cloud.tencent.com/document/product/269/3663)和[消息格式描述](https://cloud.tencent.com/document/product/269/2720)
/// @{
/**
* @brief 发送新消息
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_param  消息json字符串
* @param cb 发送新消息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example 
* Json::Value json_value_text;
* json_value_text[kTIMElemType] = kTIMElem_Text;
* json_value_text[kTIMTextElemContent] = "send text";
* Json::Value json_value_msg;
* json_value_msg[kTIMMsgElemArray].append(json_value_text);
* json_value_msg[kTIMMsgSender] = login_id;
* json_value_msg[kTIMMsgClientTime] = time(NULL);
* json_value_msg[kTIMMsgServerTime] = time(NULL);
*
* int ret = TIMMsgSendNewMsg(conv.id.c_str(), kTIMConv_C2C, json_value_msg.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     if (ERR_SUCC != code) {
*         // 消息发送失败
*         return;
*     }
*     // 消息发送成功
* }, this);
*
* // json_value_msg.toStyledString().c_str()得到 json_msg_param JSON 字符串如下
* {
*    "message_client_time" : 1551446728,
*    "message_elem_array" : [
*       {
*          "elem_type" : 0,
*          "text_elem_content" : "send text"
*       }
*    ],
*    "message_sender" : "user1",
*    "message_server_time" : 1551446728
* }
* @note
* >  发送新消息，单聊消息和群消息的发送均采用此接口。
* >> 发送单聊消息时 conv_id 为对方的 identifier， conv_type 为 kTIMConv_C2C 
* >> 发送群聊消息时 conv_id 为群ID， conv_type 为 kTIMConv_Group 。
* >  发送消息时不能发送 kTIMElem_GroupTips 、 kTIMElem_GroupReport ，他们由为后台下发，用于更新(通知)群的信息。可以的发送消息内元素
* >>   文本消息元素，请参考 [TextElem](TIMCloudDef.h)
* >>   表情消息元素，请参考 [FaceElem](TIMCloudDef.h)
* >>   位置消息元素，请参考 [LocationElem](TIMCloudDef.h)
* >>   图片消息元素，请参考 [ImageElem](TIMCloudDef.h)
* >>   声音消息元素，请参考 [SoundElem](TIMCloudDef.h)
* >>   自定义消息元素，请参考 [CustomElem](TIMCloudDef.h)
* >>   文件消息元素，请参考 [FileElem](TIMCloudDef.h)
* >>   视频消息元素，请参考 [VideoElem](TIMCloudDef.h)
*/
TIM_DECL int TIMMsgSendNewMsg(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 消息上报已读
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_param  消息json字符串
* @param cb 消息上报已读成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* 上报此消息已读状态，最好用接收新消息获取的消息数组里面的消息Json 或者用消息定位符查找到的消息 Json，避免重复构造消息 Json
*/
TIM_DECL int TIMMsgReportReaded(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 消息撤回
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_param  消息json字符串
* @param cb 消息撤回成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* 消息撤回。使用保存的消息Json或者用消息定位符查找到的消息Json，避免重复构造消息Json.
*/
TIM_DECL int TIMMsgRevoke(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 根据消息定位精准查找指定会话的消息
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_Locator_array  消息定位符数组
* @param cb 根据消息定位精准查找指定会话的消息成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* @example
* Json::Value json_msg_locator;                      //一条消息对应一个消息定位符(精准定位)
* json_msg_locator[kTIMMsgLocatorIsRevoked] = false; //消息是否被撤回
* json_msg_locator[kTIMMsgLocatorTime] = 123;        //填入消息的时间
* json_msg_locator[kTIMMsgLocatorSeq] = 1;           
* json_msg_locator[kTIMMsgLocatorIsSelf] = false;    
* json_msg_locator[kTIMMsgLocatorRand] = 12345678;   
* 
* Json::Value json_msg_locators;
* json_msg_locators.append(json_msg_locator);
* TIMMsgFindByMsgLocatorList("user2", kTIMConv_C2C, json_msg_locators.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     
* }, nullptr);
* 
* // json_msg_locators.toStyledString().c_str() 的到 json_msg_Locator_array JSON 字符串如下
* [
*    {
*       "message_locator_is_revoked" : false,
*       "message_locator_is_self" : false,
*       "message_locator_rand" : 12345678,
*       "message_locator_seq" : 1,
*       "message_locator_time" : 123
*    }
* ]
* 
* @note
* > 此接口根据消息定位符精准查找指定会话的消息，该功能一般用于消息撤回时查找指定消息等
* > 一个消息定位符对应一条消息
*/
TIM_DECL int TIMMsgFindByMsgLocatorList(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_Locator_array, TIMCommCallback cb, const void* user_data);

/**
* @brief 导入消息列表到指定会话
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_array  消息数组
* @param cb 导入消息列表到指定会话成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_value_elem; //构造消息文本元素
* json_value_elem[kTIMElemType] = TIMElemType::kTIMElem_Text;
* json_value_elem[kTIMTextElemContent] = "this is import msg";
* 
* Json::Value json_value_msg; //构造消息
* json_value_msg[kTIMMsgSender] = login_id;
* json_value_msg[kTIMMsgClientTime] = time(NULL);
* json_value_msg[kTIMMsgServerTime] = time(NULL);
* json_value_msg[kTIMMsgElemArray].append(json_value_elem);
*
* Json::Value json_value_msgs;  //消息数组
* json_value_msgs.append(json_value_msg);
*
* TIMMsgImportMsgList("user2", kTIMConv_C2C, json_value_msgs.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     
* }, nullptr);
*
* // json_value_msgs.toStyledString().c_str()得到的json_msg_array JSON 字符串如下
* [
*    {
*       "message_client_time" : 1551446728,
*       "message_elem_array" : [
*          {
*             "elem_type" : 0,
*             "text_elem_content" : "this is import msg"
*          }
*       ],
*       "message_sender" : "user1",
*       "message_server_time" : 1551446728
*    }
* ]
* 
* @note
* 批量导入消息，可以自己构造消息去导入。也可以将之前要导入的消息数组 Json 保存，然后导入的时候直接调用接口，避免构造消息数组
*/
TIM_DECL int TIMMsgImportMsgList(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_array, TIMCommCallback cb, const void* user_data);

/**
* @brief 保存自定义消息
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_param  消息json字符串
* @param cb 保存自定义消息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @note
* 消息保存接口，一般是自己构造一个消息Json字符串，然后保存到指定会话
*/
TIM_DECL int TIMMsgSaveMsg(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 获取指定会话的消息列表
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_get_msg_param 消息获取参数
* @param cb 获取指定会话的消息列表成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example 给C2C会话 Windows-02、kTIMConv_C2C导入消息列表
* Json::Value json_msg(Json::objectValue); // 构造Message
* Json::Value json_get_msg_param;
* json_get_msg_param[kTIMMsgGetMsgListParamLastMsg] = json_msg;
* json_get_msg_param[kTIMMsgGetMsgListParamIsRamble] = false;
* json_get_msg_param[kTIMMsgGetMsgListParamIsForward] = true;
* json_get_msg_param[kTIMMsgGetMsgListParamCount] = 100;
*
* int ret = TIMMsgGetMsgList("Windows-02", kTIMConv_C2C, json_get_msg_param.toStyledString().c_str(), type, json.c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
* }, this);
* 
* // json_get_msg_param.toStyledString().c_str()得到 json_get_msg_param JSON 字符串如下
* {
*    "msg_getmsglist_param_count" : 100,
*    "msg_getmsglist_param_is_forward" : true,
*    "msg_getmsglist_param_is_remble" : false,
*    "msg_getmsglist_param_last_msg" : {}
* }
*   
* @note
* 从 kTIMMsgGetMsgListParamLastMsg 指定的消息开始获取本地消息列表，kTIMMsgGetMsgListParamCount 为要获取的消息数目。
* 若指定 kTIMMsgGetMsgListParamIsRamble 为true则本地消息获取不够指定数目时，则会去获取云端漫游消息。kTIMMsgGetMsgListParamIsForward 指定向前获取还是向后获取
*/
TIM_DECL int TIMMsgGetMsgList(const char* conv_id, enum TIMConvType conv_type, const char* json_get_msg_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 删除指定会话的消息
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msgdel_param 消息获取参数
* @param cb 删除指定会话的消息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @example 
* Json::Value json_value_msg(Json::objectValue);
* Json::Value json_value_msgdelete;
* json_value_msgdelete[kTIMMsgDeleteParamIsRamble] = false;
* json_value_msgdelete[kTIMMsgDeleteParamMsg] = json_value_msg;
* TIMMsgDelete("user2", kTIMConv_C2C, json_value_msgdelete.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
* 
* }, nullptr);
* 
* // json_value_msgdelete.toStyledString().c_str()得到 json_msgdel_param JSON 字符串如下
* {
*   "msg_delete_param_is_remble" : false,
*   "msg_delete_param_msg" : {}
* }
*
* @note 
* > 当设置 kTIMMsgDeleteParamMsg 时，在会话中删除指定本地消息
* > 当未设置 kTIMMsgDeleteParamMsg 时， kTIMMsgDeleteParamIsRamble 为false表示删除会话所有本地消息，true 表示删除会话所有漫游消息(删除漫游消息暂时不支持)
* > 一般直接使用保存的消息 Json，或者通过消息定位符查找得到的 Json。不用删除的时候构造消息 Json
*/
TIM_DECL int TIMMsgDelete(const char* conv_id, enum TIMConvType conv_type, const char* json_msgdel_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 下载消息内元素到指定文件路径(图片、视频、音频、文件)
*
* @param json_download_elem_param  下载的参数Json字符串
* @param path 下载文件保存路径
* @param cb 下载成功与否的回调以及下载进度回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value download_param;
* download_param[kTIMMsgDownloadElemParamFlag] = flag;
* download_param[kTIMMsgDownloadElemParamType] = type;
* download_param[kTIMMsgDownloadElemParamId] = id;
* download_param[kTIMMsgDownloadElemParamBusinessId] = business_id;
* download_param[kTIMMsgDownloadElemParamUrl] = url;
*
* TIMMsgDownloadElemToPath(download_param.toStyledString().c_str(), (path_ + "\\" + name).c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, this);
* 
* @note
* 此接口用于下载消息内图片、文件、声音、视频等元素。下载的参数 kTIMMsgDownloadElemParamFlag、kTIMMsgDownloadElemParamId、kTIMMsgDownloadElemParamBusinessId、kTIMMsgDownloadElemParamUrl 均可以
* 在相应元素内找到。其中 kTIMMsgDownloadElemParamType 为下载文件类型 [TIMDownloadType](TIMCloudDef.h)
*/
TIM_DECL int TIMMsgDownloadElemToPath(const char* json_download_elem_param, const char* path, TIMCommCallback cb, const void* user_data);

/**
* @brief 群发消息
*
* @param json_batch_send_param  群发消息json字符串
* @param cb 群发消息成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example 
* //构造消息文本元素
* Json::Value json_value_elem;
* json_value_elem[kTIMElemType] = TIMElemType::kTIMElem_Text;
* json_value_elem[kTIMTextElemContent] = "this is batch send msg";
* //构造消息
* Json::Value json_value_msg;
* json_value_msg[kTIMMsgSender] = login_id;
* json_value_msg[kTIMMsgClientTime] = time(NULL);
* json_value_msg[kTIMMsgServerTime] = time(NULL);
* json_value_msg[kTIMMsgElemArray].append(json_value_elem);
*
* // 构造批量发送ID数组列表
* Json::Value json_value_ids(Json::arrayValue);
* json_value_ids.append("user2");
* json_value_ids.append("user3");
* // 构造批量发送接口参数
* Json::Value json_value_batchsend;
* json_value_batchsend[kTIMMsgBatchSendParamIdentifierArray] = json_value_ids;
* json_value_batchsend[kTIMMsgBatchSendParamMsg] = json_value_msg;
* int ret = TIMMsgBatchSend(json_value_batchsend.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
* }, nullptr);
* 
* // json_value_batchsend.toStyledString().c_str()得到 json_batch_send_param JSON 字符串如下
* {
*    "msg_batch_send_param_identifier_array" : [ "user2", "user3" ],
*    "msg_batch_send_param_msg" : {
*       "message_client_time" : 1551340614,
*       "message_elem_array" : [
*          {
*             "elem_type" : 0,
*             "text_elem_content" : "this is batch send msg"
*          }
*       ],
*       "message_sender" : "user1",
*       "message_server_time" : 1551340614
*    }
* }
*
* @note
* 批量发送消息的接口，每个 identifier 发送成功与否，通过回调cb返回。
*/
TIM_DECL int TIMMsgBatchSend(const char* json_batch_send_param, TIMCommCallback cb, const void* user_data);
/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                       群组相关接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 群组相关接口
/// @brief 群组相关介绍请参考 [群组系统](https://cloud.tencent.com/document/product/269/1502)、[群组管理](https://cloud.tencent.com/document/product/269/3661)和 [群组自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
/// @{
/**
* @brief 创建群组
*
* @param json_group_create_param 创建群组的参数Json字符串
* @param cb 创建群组成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
*
* Json::Value json_group_member_array(Json::arrayValue);
*
* Json::Value json_value_param;
* json_value_param[kTIMCreateGroupParamGroupId] = "first group id";
* json_value_param[kTIMCreateGroupParamGroupType] = kTIMGroup_Public;
* json_value_param[kTIMCreateGroupParamGroupName] = "first group name";
* json_value_param[kTIMCreateGroupParamGroupMemberArray] = json_group_member_array;
* 
* json_value_param[kTIMCreateGroupParamNotification] = "group notification";
* json_value_param[kTIMCreateGroupParamIntroduction] = "group introduction";
* json_value_param[kTIMCreateGroupParamFaceUrl] = "group face url";
* json_value_param[kTIMCreateGroupParamMaxMemberCount] = 2000;
* json_value_param[kTIMCreateGroupParamAddOption] = kTIMGroupAddOpt_Any;
*
* const void* user_data = nullptr; // 回调函数回传
* int ret = TIMGroupCreate(json_value_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*    if (ERR_SUCC != code) { 
*         // 创建群组失败
*         return;
*     }
*     
*     // 创建群组成功 解析Json获取创建后的GroupID
* }, user_data);
* if (TIM_SUCC != ret) {
*     // TIMGroupCreate 接口调用失败
* }
*
* // json_value_param.toStyledString().c_str() 得到 json_group_create_param JSON 字符串如下
* {
*    "create_group_param_add_option" : 2,
*    "create_group_param_face_url" : "group face url",
*    "create_group_param_group_id" : "first group id",
*    "create_group_param_group_member_array" : [],
*    "create_group_param_group_name" : "first group name",
*    "create_group_param_group_type" : 0,
*    "create_group_param_introduction" : "group introduction",
*    "create_group_param_max_member_num" : 2000,
*    "create_group_param_notification" : "group notification"
* }
*
* @note
* > 创建群组时可以指定群ID，若未指定时IM 通讯云服务器会生成一个唯一的 ID，以便后续操作，群组ID通过创建群组时传入的回调返回
* > 创建群参数的Json Key详情请参考[CreateGroupParam](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupCreate(const char* json_group_create_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 删除(解散)群组
*
* @param group_id 要删除的群组ID
* @param cb 删除群组成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* > 权限说明：
* >>   对于私有群，任何人都无法解散群组。
* >>   对于公开群、聊天室和直播大群，群主可以解散群组。
* > 删除指定群组 group_id 的接口，删除成功与否可根据回调cb的参数判断。
*/
TIM_DECL int TIMGroupDelete(const char* group_id, TIMCommCallback cb, const void* user_data);

/**
* @brief 申请加入群组
*
* @param group_id 要加入的群组ID
* @param hello_msg 申请理由（选填）
* @param cb 申请加入群组成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* > 权限说明：
* >> 私有群不能由用户主动申请入群。
* >> 公开群和聊天室可以主动申请进入。
* +  如果群组设置为需要审核，申请后管理员和群主会受到申请入群系统消息，需要等待管理员或者群主审核，如果群主设置为任何人可加入，则直接入群成功。
*    直播大群可以任意加入群组。
* > 申请加入指定群组 group_id 的接口，申请加入的操作成功与否可根据回调cb的参数判断。
*/
TIM_DECL int TIMGroupJoin(const char* group_id, const char* hello_msg, TIMCommCallback cb, const void* user_data);

/**
* @brief 退出群组
*
* @param group_id 要退出的群组ID
* @param cb 退出群组成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* > 权限说明：
* >>   对于私有群，全员可退出群组。
* >>   对于公开群、聊天室和直播大群，群主不能退出。
* > 退出指定群组 group_id 的接口，退出成功与否可根据回调cb的参数判断。
*/
TIM_DECL int TIMGroupQuit(const char* group_id, TIMCommCallback cb, const void* user_data);

/**
* @brief 邀请加入群组
*
* @param json_group_invite_param 邀请加入群组的Json字符串
* @param cb 邀请加入群组成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_value_invite;
* json_value_invite[kTIMGroupInviteMemberParamGroupId] = groupid;
* json_value_invite[kTIMGroupInviteMemberParamUserData] = "userdata";
* json_value_invite[kTIMGroupInviteMemberParamIdentifierArray].append("user1");
* json_value_invite[kTIMGroupInviteMemberParamIdentifierArray].append("user2");
*
* const void* user_data = nullptr; // 回调函数回传;
* int ret = TIMGroupInviteMember(json_value_invite.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     if (ERR_SUCC != code) { 
*         // 邀请成员列表失败
*         return;
*     }
*     // 邀请成员列表成功，解析JSON获取每个成员邀请结果
* }, user_data);
* if (TIM_SUCC != ret) {
*     // TIMGroupInviteMember 接口调用失败
* }
* 
* // json_value_invite.toStyledString().c_str() 得到 json_group_invite_param JSON 字符串如下
* {
*    "group_invite_member_param_group_id" : "first group id",
*    "group_invite_member_param_identifier_array" : [ "user1", "user2" ],
*    "group_invite_member_param_user_data" : "userdata"
* }
* @note
* > 权限说明:
* >>   只有私有群可以拉用户入群
* >>   公开群、聊天室邀请用户入群
* >>   需要用户同意；直播大群不能邀请用户入群。
* > 此接口支持批量邀请成员加入群组,Json Key详情请参考[GroupInviteMemberParam](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupInviteMember(const char* json_group_invite_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 删除群组成员
*
* @param json_group_delete_param 删除群组成员的Json字符串
* @param cb 删除群组成员成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_value_delete;
* json_value_delete[kTIMGroupDeleteMemberParamGroupId] = groupid;
* json_value_delete[kTIMGroupDeleteMemberParamUserData] = "reason";
* json_value_delete[kTIMGroupDeleteMemberParamIdentifierArray].append("user1");
* json_value_delete[kTIMGroupDeleteMemberParamIdentifierArray].append("user2");
*
* int ret = TIMGroupDeleteMember(json_value_delete.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*       
* }, this));
* 
* // json_value_delete.toStyledString().c_str() 得到 json_group_delete_param JSON 字符串如下
* {
*   "group_delete_member_param_group_id" : "third group id",
*   "group_delete_member_param_identifier_array" : [ "user2", "user3" ],
*   "group_delete_member_param_user_data" : "reason"
* }
* 
* @note
* > 权限说明：
* >>   对于私有群：只有创建者可删除群组成员。
* >>   对于公开群和聊天室：只有管理员和群主可以踢人。
* >>   对于直播大群：不能踢人。
* > 此接口支持批量删除群成员,Json Key详情请参考[GroupDeleteMemberParam](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupDeleteMember(const char* json_group_delete_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 获取已加入群组列表
*
* @param cb 获取已加入群组列表成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* > 权限说明：
* >>   此接口可以获取自己所加入的群列表
* >>   此接口只能获得加入的部分直播大的列表。
* > 此接口用于获取当前用户已加入的群组列表，返回群组的基础信息。具体返回的群组基本信息字段参考[GroupBaseInfo](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupGetJoinedGroupList(TIMCommCallback cb, const void* user_data);

/**
* @brief 获取群组信息列表
*
* @param json_group_getinfo_param 获取群组信息列表参数的Json字符串
* @param cb 获取群组信息列表成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value groupids;
* groupids.append("third group id");
* groupids.append("second group id");
* groupids.append("first group id");
* int ret = TIMGroupGetGroupInfoList(groupids.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, this);
*
* // groupids.toStyledString().c_str()得到的 json_group_getinfo_param 如下
* [ "third group id", "second group id", "first group id" ]
*
* @note
* 此接口用于获取指定群ID列表的群详细信息。具体返回的群组详细信息字段参考[GroupDetailInfo](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupGetGroupInfoList(const char* json_group_getinfo_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 修改群信息
*
* @param json_group_modifyinfo_param 设置群信息参数的Json字符串Json字符串
* @param cb 设置群信息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example 设置群所有者
* Json::Value json_value_modifygroupinfo;
* json_value_modifygroupinfo[kTIMGroupModifyInfoParamGroupId] = "first group id";
* json_value_modifygroupinfo[kTIMGroupModifyInfoParamModifyFlag] = kTIMGroupModifyInfoFlag_Owner;
* json_value_modifygroupinfo[kTIMGroupModifyInfoParamOwner] = "user2";
* 
* int ret = TIMGroupModifyGroupInfo(json_value_modifygroupinfo.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, nullptr);
*
* // json_value_modifygroupinfo.toStyledString().c_str()得到的 json_group_modifyinfo_param JSON 字符串如下
* {
*   "group_modify_info_param_group_id" : "first group id",
*   "group_modify_info_param_modify_flag" : -2147483648,
*   "group_modify_info_param_owner" : "user2"
* }
*
* @example 设置群名称和群通知
* Json::Value json_value_modifygroupinfo;
* json_value_modifygroupinfo[kTIMGroupModifyInfoParamGroupId] = "first group id";
* json_value_modifygroupinfo[kTIMGroupModifyInfoParamModifyFlag] = kTIMGroupModifyInfoFlag_Name | kTIMGroupModifyInfoFlag_Notification;
* json_value_modifygroupinfo[kTIMGroupModifyInfoParamGroupName] = "first group name to other name";
* json_value_modifygroupinfo[kTIMGroupModifyInfoParamNotification] = "first group notification";
* 
* int ret = TIMGroupModifyGroupInfo(json_value_modifygroupinfo.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, nullptr);
* 
* // json_value_modifygroupinfo.toStyledString().c_str()得到的 json_group_modifyinfo_param JSON 字符串如下
* {
*    "group_modify_info_param_group_id" : "first group id",
*    "group_modify_info_param_group_name" : "first group name to other name",
*    "group_modify_info_param_modify_flag" : 3,
*    "group_modify_info_param_notification" : "first group notification"
* }
*
* @note
* > 修改群主（群转让）的权限说明：
* >>   只有群主才有权限进行群转让操作。
* >>   直播大群不能进行群转让操作。
* > 修改群其他信息的权限说明:
* >>   对于公开群、聊天室和直播大群，只有群主或者管理员可以修改群简介。
* >>   对于私有群，任何人可修改群简介。
* > kTIMGroupModifyInfoParamModifyFlag 可以按位或设置多个值。不同的flag设置不同的键,详情请参考[GroupSetInfoParam](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupModifyGroupInfo(const char* json_group_modifyinfo_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 获取群成员信息列表
*
* @param json_group_getmeminfos_param 获取群成员信息列表参数的Json字符串
* @param cb 获取群成员信息列表成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value identifiers(Json::arrayValue); 
* ...
* Json::Value customs(Json::arrayValue);
* ...
* Json::Value option;
* option[kTIMGroupMemberGetInfoOptionInfoFlag] = kTIMGroupMemberInfoFlag_None;
* option[kTIMGroupMemberGetInfoOptionRoleFlag] = kTIMGroupMemberRoleFlag_All;
* option[kTIMGroupMemberGetInfoOptionCustomArray] = customs;
* Json::Value getmeminfo_opt;
* getmeminfo_opt[kTIMGroupGetMemberInfoListParamGroupId] = groupid;
* getmeminfo_opt[kTIMGroupGetMemberInfoListParamIdentifierArray] = identifiers;
* getmeminfo_opt[kTIMGroupGetMemberInfoListParamOption] = option;
* getmeminfo_opt[kTIMGroupGetMemberInfoListParamNextSeq] = 0;
* 
* int ret = TIMGroupGetMemberInfoList(getmeminfo_opt.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
* 
* }, this);
*
* // getmeminfo_opt.toStyledString().c_str()得到的 json_group_getmeminfos_param JSON 字符串如下
* {
*    "group_get_members_info_list_param_group_id" : "first group id",
*    "group_get_members_info_list_param_identifier_array" : [],
*    "group_get_members_info_list_param_next_seq" : 0,
*    "group_get_members_info_list_param_option" : {
*       "group_member_get_info_option_custom_array" : [],
*       "group_member_get_info_option_info_flag" : 0,
*       "group_member_get_info_option_role_flag" : 0
*    }
* }
*
* @note
* > 权限说明：
* >>   任何群组类型都可以获取成员列表。
* >>   直播大群只能拉取部分成员列表：包括群主、管理员和部分成员。
* > 根据不同的选项，获取群成员信息列表。成员信息的各个字段含义请参考[GroupMemberInfo](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupGetMemberInfoList(const char* json_group_getmeminfos_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 修改群成员信息
*
* @param json_group_modifymeminfo_param 设置群信息参数的Json字符串
* @param cb 设置群成员信息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_value_setgroupmeminfo;
* json_value_setgroupmeminfo[kTIMGroupModifyMemberInfoParamGroupId] = "third group id";
* json_value_setgroupmeminfo[kTIMGroupModifyMemberInfoParamIdentifier] = "user2";
* json_value_setgroupmeminfo[kTIMGroupModifyMemberInfoParamModifyFlag] = kTIMGroupMemberModifyFlag_MemberRole | kTIMGroupMemberModifyFlag_NameCard;
* json_value_setgroupmeminfo[kTIMGroupModifyMemberInfoParamMemberRole] = kTIMMemberRole_Admin;
* json_value_setgroupmeminfo[kTIMGroupModifyMemberInfoParamNameCard] = "change name card";
*
* int ret = TIMGroupModifyMemberInfo(json_value_setgroupmeminfo.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*   
* }, nullptr);
* 
* // json_value_modifygroupmeminfo.toStyledString().c_str() 得到的 json_group_modifymeminfo_param JSON 字符串如下
* {
*    "group_modify_member_info_group_id" : "third group id",
*    "group_modify_member_info_identifier" : "user2",
*    "group_modify_member_info_member_role" : 1,
*    "group_modify_member_info_modify_flag" : 10,
*    "group_modify_member_info_name_card" : "change name card"
* }
* 
* @note
* > 权限说明：
* >> 只有群主或者管理员可以进行对群成员的身份进行修改。
* >> 直播大群不支持修改用户群内身份。
* >> 只有群主或者管理员可以进行对群成员进行禁言。 
* > kTIMGroupModifyMemberInfoParamModifyFlag 可以按位或设置多个值，不同的flag设置不同的键。请参考[GroupSetMemberInfoParam](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupModifyMemberInfo(const char* json_group_modifymeminfo_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 获取群未决信息列表
*        群未决信息是指还没有处理的操作，例如，邀请加群或者请求加群操作还没有被处理，称之为群未决信息
*
* @param json_group_getpendence_list_param 设置群未决信息参数的Json字符串
* @param cb 获取群未决信息列表成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value get_pendency_option;
* get_pendency_option[kTIMGroupPendencyOptionStartTime] = 0;
* get_pendency_option[kTIMGroupPendencyOptionMaxLimited] = 0;
* int ret = TIMGroupGetPendencyList(get_pendency_option.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     if (ERR_SUCC != code) { 
*         // 获取群未决信息失败
*         return;
*     }
* }, nullptr);
* 
* // get_pendency_option.toStyledString().c_str() 得到的 json_group_getpendence_list_param JSON 字符串如下
* {
*    "group_pendency_option_max_limited" : 0,
*    "group_pendency_option_start_time" : 0
* }
*
* @note 
* > 此处的群未决消息泛指所有需要审批的群相关的操作。例如：加群待审批，拉人入群待审批等等。即便审核通过或者拒绝后，该条信息也可通过此接口拉回，拉回的信息中有已决标志。
* > UserA申请加入群GroupA，则群管理员可获取此未决相关信息，UserA 因为没有审批权限，不需要获取此未决信息。
* > 如果AdminA拉UserA进去GroupA，则UserA可以拉取此未决相关信息，因为该未决信息待 UserA 审批
* > 权限说明：
* >> 只有审批人有权限拉取相关未决信息。
* > kTIMGroupPendencyOptionStartTime 设置拉取时间戳,第一次请求填0,后边根据server返回的 [GroupPendencyResult](TIMCloudDef.h) 键 kTIMGroupPendencyResultNextStartTime 指定的时间戳进行填写。
* > kTIMGroupPendencyOptionMaxLimited 拉取的建议数量, server 可根据需要返回或多或少,不能作为完成与否的标志
*/
TIM_DECL int TIMGroupGetPendencyList(const char* json_group_getpendence_list_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 上报群未决信息已读
*
* @param time_stamp 已读时间戳(单位秒)。与[GroupPendency](TIMCloudDef.h)键 kTIMGroupPendencyAddTime 指定的时间比较
* @param cb 上报群未决信息已读成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* 时间戳time_stamp以前的群未决请求都将置为已读。上报已读后，仍然可以拉取到这些未决信息，但可通过对已读时戳的判断判定未决信息是否已读。
*/
TIM_DECL int TIMGroupReportPendencyReaded(uint64_t time_stamp, TIMCommCallback cb, const void* user_data);

/**
* @brief 处理群未决信息
*
* @param json_group_handle_pendency_param 处理群未决信息参数的Json字符串
* @param cb 处理群未决信息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example 
* Json::Value pendency; //构造 GroupPendency
* ...
* Json::Value handle_pendency;
* handle_pendency[kTIMGroupHandlePendencyParamIsAccept] = true;
* handle_pendency[kTIMGroupHandlePendencyParamHandleMsg] = "I accept this pendency";
* handle_pendency[kTIMGroupHandlePendencyParamPendency] = pendency;
* int ret = TIMGroupHandlePendency(handle_pendency.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     if (ERR_SUCC != code) {
*         // 上报群未决信息已读失败
*         return;
*     }
* }, nullptr);
*
* // handle_pendency.toStyledString().c_str() 都到的json_group_handle_pendency_param JSON 字符串如下
* {
*    "group_handle_pendency_param_handle_msg" : "I accept this pendency",
*    "group_handle_pendency_param_is_accept" : true,
*    "group_handle_pendency_param_pendency" : {
*       "group_pendency_add_time" : 1551414487947,
*       "group_pendency_apply_invite_msg" : "Want Join Group, Thank you",
*       "group_pendency_approval_msg" : "",
*       "group_pendency_form_identifier" : "user2",
*       "group_pendency_form_user_defined_data" : "",
*       "group_pendency_group_id" : "four group id",
*       "group_pendency_handle_result" : 0,
*       "group_pendency_handled" : 0,
*       "group_pendency_pendency_type" : 0,
*       "group_pendency_to_identifier" : "user1",
*       "group_pendency_to_user_defined_data" : ""
*    }
* }
* 
* @note 
* > 对于群的未决信息，SDK 增加了处理接口。审批人可以选择对单条信息进行同意或者拒绝。已处理成功过的未决信息不能再次处理。
* > 处理未决信息时需要带一个未决信息[GroupPendency](TIMCloudDef.h)，可以在接口[TIMGroupGetPendencyList]()返回的未决信息列表将未决信息保存下来，
*   在处理未决信息的时候将[GroupPendency](TIMCloudDef.h)传入键 kTIMGroupHandlePendencyParamPendency 。
*/
TIM_DECL int TIMGroupHandlePendency(const char* json_group_handle_pendency_param, TIMCommCallback cb, const void* user_data);
/// @}


#ifdef __cplusplus
};
#endif //__cplusplus

#endif //SDK_CLOUD_TIM_HEADER_
