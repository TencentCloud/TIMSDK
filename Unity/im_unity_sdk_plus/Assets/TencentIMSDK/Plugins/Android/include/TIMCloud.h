// Copyright (c) 2021 Tencent. All rights reserved.

#ifndef SRC_PLATFORM_CROSS_PLATFORM_INCLUDE_TIM_CLOUD_H_
#define SRC_PLATFORM_CROSS_PLATFORM_INCLUDE_TIM_CLOUD_H_

#include "TIMCloudDef.h"
#include "TIMCloudCallback.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @overview TIMCloud
/// @overbrief 腾讯即时通信IM的跨平台C接口(API)
/*
* @brief 各个平台的下载链接：
* > Windows平台[ImSDK](https://github.com/tencentyun/TIMSDK/tree/master/Windows/IMSDK),Windows快速开始[集成ImSDK](https://cloud.tencent.com/document/product/269/33489)和[一分钟跑通Demo](https://cloud.tencent.com/document/product/269/36838).支持32位/64位系统。
* > iOS平台[ImSDK](https://github.com/tencentyun/TIMSDK/tree/master/iOS/IMSDK).
* > Mac平台[ImSDK](https://github.com/tencentyun/TIMSDK/tree/master/Mac/IMSDK).
* > Android平台[ImSDK](https://github.com/tencentyun/TIMSDK/tree/master/Android/IMSDK).
*
* @brief 关于回调的说明
* > 回调分两种，一种是指调用接口的异步返回，另外一种指后台推送的通知。回调在ImSDK内部的逻辑线程触发，跟调用接口的线程可能不是同一线程
* > 在Windows平台，如果调用[TIMInit]()接口进行初始化ImSDK之前，已创建了UI的消息循环，且调用[TIMInit]()接口的线程为主UI线程，则ImSDK内部会将回调抛到主UI线程调用
*
* @brief 注意
* > 如果接口的参数字符串包含非英文的字符，请使用UTF-8编码
*/

/////////////////////////////////////////////////////////////////////////////////
//
//  注册SDK回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 1.1 事件回调接口
/// @{
/**
* @brief 添加接收新消息回调
* @param cb 新消息回调函数，请参考[TIMRecvNewMsgCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* 如果用户是登录状态，ImSDK收到新消息会通过此接口设置的回调抛出，另外需要注意，抛出的消息不一定是未读的消息，
* 只是本地曾经没有过的消息（例如在另外一个终端已读，拉取最近联系人消息时可以获取会话最后一条消息，如果本地没有，会通过此方法抛出）。
* 在用户登录之后，ImSDK会拉取离线消息，为了不漏掉消息通知，需要在登录之前注册新消息通知。
*/
TIM_DECL void TIMAddRecvNewMsgCallback(TIMRecvNewMsgCallback cb, const void* user_data);

/**
* @brief 1.2 删除接收新消息回调
* @param cb 新消息回调函数，请参考[TIMRecvNewMsgCallback](TIMCloudCallback.h)
*
* @note
* 参数cb需要跟[TIMAddRecvNewMsgCallback]()传入的cb一致，否则删除回调失败
*/
TIM_DECL void TIMRemoveRecvNewMsgCallback(TIMRecvNewMsgCallback cb);

/**
* @brief 1.3 设置消息已读回执回调
* @param cb 消息已读回执回调，请参考[TIMMsgReadedReceiptCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* 发送方发送消息，接收方调用接口[TIMMsgReportReaded]()上报该消息已读，发送方ImSDK会通过此接口设置的回调抛出。
*/
TIM_DECL void TIMSetMsgReadedReceiptCallback(TIMMsgReadedReceiptCallback cb, const void* user_data);

/**
* @brief 1.4 设置接收的消息被撤回回调
* @param cb 消息撤回通知回调,请参考[TIMMsgRevokeCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* 发送方发送消息，接收方收到消息。此时发送方调用接口[TIMMsgRevoke]()撤回该消息，接收方的ImSDK会通过此接口设置的回调抛出。
*/
TIM_DECL void TIMSetMsgRevokeCallback(TIMMsgRevokeCallback cb, const void* user_data);

/**
* @brief 1.5 设置消息内元素相关文件上传进度回调
* @param cb 文件上传进度回调，请参考[TIMMsgElemUploadProgressCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note
* 设置消息元素上传进度回调。当消息内包含图片、声音、文件、视频元素时，ImSDK会上传这些文件，并触发此接口设置的回调，用户可以根据回调感知上传的进度
*/
TIM_DECL void TIMSetMsgElemUploadProgressCallback(TIMMsgElemUploadProgressCallback cb, const void* user_data);

/**
* @brief 1.6 设置群组系统消息回调
* @param cb 群消息回调，请参考[TIMGroupTipsEventCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* 群组系统消息事件包括 加入群、退出群、踢出群、设置管理员、取消管理员、群资料变更、群成员资料变更。此消息是针对所有群组成员下发的
*/
TIM_DECL void TIMSetGroupTipsEventCallback(TIMGroupTipsEventCallback cb, const void* user_data);


/**
* @brief 1.7 设置群组属性变更回调
* @param cb 群组属性变更回调，请参考[TIMGroupAttributeChangedCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* 某个已加入的群的属性被修改了，会返回所在群组的所有属性（该群所有的成员都能收到）
*/
TIM_DECL void TIMSetGroupAttributeChangedCallback(TIMGroupAttributeChangedCallback cb, const void* user_data);


/**
* @brief 1.8 设置会话事件回调
* @param cb 会话事件回调，请参考[TIMConvEventCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* > 会话事件包括：
* >> 会话新增
* >> 会话删除
* >> 会话更新。
* >> 会话开始
* >> 会话结束
* > 任何产生一个新会话的操作都会触发会话新增事件，例如调用接口[TIMConvCreate]()创建会话，接收到未知会话的第一条消息等。
* 任何已有会话变化的操作都会触发会话更新事件，例如收到会话新消息，消息撤回，已读上报等。
* 调用接口[TIMConvDelete]()删除会话成功时会触发会话删除事件。
*/
TIM_DECL void TIMSetConvEventCallback(TIMConvEventCallback cb, const void* user_data);


/**
* @brief 1.9 设置会话未读消息总数变更的回调
* @param cb 会话未读消息总数变更的回调，请参考[TIMConvTotalUnreadMessageCountChangedCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
*/
TIM_DECL void TIMSetConvTotalUnreadMessageCountChangedCallback(TIMConvTotalUnreadMessageCountChangedCallback cb, const void* user_data);

/**
* @brief 1.10 设置网络连接状态监听回调
* @param cb 连接事件回调，请参考[TIMNetworkStatusListenerCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note
* > 当调用接口 [TIMInit]() 时，ImSDK会去连接云后台。此接口设置的回调用于监听网络连接的状态。
* > 网络连接状态包含四个：正在连接、连接失败、连接成功、已连接。这里的网络事件不表示用户本地网络状态，仅指明ImSDK是否与即时通信IM云Server连接状态。
* > 可选设置，如果要用户感知是否已经连接服务器，需要设置此回调，用于通知调用者跟通讯后台链接的连接和断开事件，另外，如果断开网络，等网络恢复后会自动重连，自动拉取消息通知用户，用户无需关心网络状态，仅作通知之用
* > 只要用户处于登录状态，ImSDK内部会进行断网重连，用户无需关心。
*/
TIM_DECL void TIMSetNetworkStatusListenerCallback(TIMNetworkStatusListenerCallback cb, const void* user_data);

/**
* @brief 1.11 设置被踢下线通知回调
* @param cb 踢下线回调，请参考[TIMKickedOfflineCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note
* > 用户如果在其他终端登录，会被踢下线，这时会收到用户被踢下线的通知，出现这种情况常规的做法是提示用户进行操作（退出，或者再次把对方踢下线）。
* > 用户如果在离线状态下被踢，下次登录将会失败，可以给用户一个非常强的提醒（登录错误码ERR_IMSDK_KICKED_BY_OTHERS：6208），开发者也可以选择忽略这次错误，再次登录即可。
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
* @brief 1.12 设置票据过期回调
* @param cb 票据过期回调，请参考[TIMUserSigExpiredCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* 用户票据，可能会存在过期的情况，如果用户票据过期，此接口设置的回调会调用。
* [TIMLogin]()也将会返回70001错误码。开发者可根据错误码或者票据过期回调进行票据更换
*/
TIM_DECL void TIMSetUserSigExpiredCallback(TIMUserSigExpiredCallback cb, const void* user_data);

/**
* @brief 1.13 设置添加好友的回调
* @param cb 添加好友回调，请参考[TIMOnAddFriendCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* 此回调为了多终端同步。例如A设备、B设备都登录了同一帐号的ImSDK，A设备添加了好友，B设备ImSDK会收到添加好友的推送，ImSDK通过此回调告知开发者。
*/
TIM_DECL void TIMSetOnAddFriendCallback(TIMOnAddFriendCallback cb, const void* user_data);

/**
* @brief 1.14 设置删除好友的回调
* @param cb 删除好友回调，请参考[TIMOnDeleteFriendCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* 此回调为了多终端同步。例如A设备、B设备都登录了同一帐号的ImSDK，A设备删除了好友，B设备ImSDK会收到删除好友的推送，ImSDK通过此回调告知开发者。
*/
TIM_DECL void TIMSetOnDeleteFriendCallback(TIMOnDeleteFriendCallback cb, const void* user_data);

/**
* @brief 1.15 设置更新好友资料的回调
* @param cb 更新好友资料回调，请参考[TIMUpdateFriendProfileCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* 此回调为了多终端同步。例如A设备、B设备都登录了同一帐号的ImSDK，A设备更新了好友资料，B设备ImSDK会收到更新好友资料的推送，ImSDK通过此回调告知开发者。
*/
TIM_DECL void TIMSetUpdateFriendProfileCallback(TIMUpdateFriendProfileCallback cb, const void* user_data);

/**
* @brief 1.16 设置好友添加请求的回调
* @param cb 好友添加请求回调，请参考[TIMFriendAddRequestCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* 当前登入用户设置添加好友需要确认时，如果有用户请求加当前登入用户为好友，会收到好友添加请求的回调，ImSDK通过此回调告知开发者。如果多终端登入同一帐号，每个终端都会收到这个回调。
*/
TIM_DECL void TIMSetFriendAddRequestCallback(TIMFriendAddRequestCallback cb, const void* user_data);

/**
* @brief 1.17 设置好友申请被删除的回调
* @param cb 好友申请删除回调，请参考[TIMFriendApplicationListDeletedCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note 
*  1. 主动删除好友申请
*  2. 拒绝好友申请
*  3. 同意好友申请
*  4. 申请加别人好友被拒绝
*/
TIM_DECL void TIMSetFriendApplicationListDeletedCallback(TIMFriendApplicationListDeletedCallback cb, const void* user_data);

/**
* @brief 1.18 设置好友申请已读的回调
* @param cb 好友申请已读回调，请参考[TIMFriendApplicationListReadCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* 如果调用 setFriendApplicationRead 设置好友申请列表已读，会收到这个回调（主要用于多端同步）
*/
TIM_DECL void TIMSetFriendApplicationListReadCallback(TIMFriendApplicationListReadCallback cb, const void* user_data);

/**
* @brief 1.19 设置黑名单新增的回调
* @param cb 黑名单新增的回调，请参考[TIMFriendBlackListAddedCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
*/
TIM_DECL void TIMSetFriendBlackListAddedCallback(TIMFriendBlackListAddedCallback cb, const void* user_data);

/**
* @brief  1.20 设置黑名单删除的回调
* @param cb 黑名单删除的回调，请参考[TIMFriendBlackListDeletedCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
*/
TIM_DECL void TIMSetFriendBlackListDeletedCallback(TIMFriendBlackListDeletedCallback cb, const void* user_data);


/**
* @brief 1.21 设置日志回调
* @param cb 日志回调，请参考[TIMLogCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
*
* @note
* 设置日志监听的回调之后，ImSDK内部的日志会回传到此接口设置的回调。
* 开发者可以通过接口[TIMSetConfig]()配置哪些日志级别的日志回传到回调函数。
*/
TIM_DECL void TIMSetLogCallback(TIMLogCallback cb, const void* user_data);

/**
* @brief 1.22 设置消息在云端被修改后回传回来的消息更新通知回调
* @param cb 消息更新回调，请参考[TIMMsgUpdateCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* 
* @note 
* > 当您发送的消息在服务端被修改后，ImSDK会通过该回调通知给您 
* > 您可以在您自己的服务器上拦截所有即时通信IM消息 [发单聊消息之前回调](https://cloud.tencent.com/document/product/269/1632)
* > 设置成功之后，即时通信IM服务器会将您的用户发送的每条消息都同步地通知给您的业务服务器。
* > 您的业务服务器可以对该条消息进行修改（例如过滤敏感词），如果您的服务器对消息进行了修改，ImSDK就会通过此回调通知您。
*/
TIM_DECL void TIMSetMsgUpdateCallback(TIMMsgUpdateCallback cb, const void* user_data);
/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                                  ImSDK初始化
//
/////////////////////////////////////////////////////////////////////////////////
/// @name ImSDK初始化相关接口
/// @{
/**
* @brief 2.1 ImSDK初始化
*
* @param sdk_app_id 官网申请的SDKAppid
* @param json_sdk_config ImSDK配置选项Json字符串,详情请参考[SdkConfig](TIMCloudDef.h)
* @return int 返回TIM_SUCC表示接口调用成功，其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @example
* Json::Value json_value_init;
* json_value_init[kTIMSdkConfigLogFilePath] = "D:\\";
* json_value_init[kTIMSdkConfigConfigFilePath] = "D:\\";
* 
* uint64_t sdk_app_id = 1234567890;
* if (TIM_SUCC != TIMInit(sdk_app_id, json_value_init.toStyledString().c_str())) {
*     // TIMInit 接口调用错误，ImSDK初始化失败   
* }
* 
* // json_value_init.toStyledString() 得到 json_sdk_config JSON 字符串如下
* {
*    "sdk_config_config_file_path" : "D:\\",
*    "sdk_config_log_file_path" : "D:\\"
* }
* 
* @note 
* > 在使用ImSDK进一步操作之前，需要先初始化ImSDK
* > json_sdk_config 可以为 NULL 空字符串指针或者""空字符串，在此情况下SdkConfig均为默认值。
* > json_sdk_config 里面的每个Json key都是选填的，详情请参考[SdkConfig](TIMCloudDef.h)
* > kTIMSdkConfigLogFilePath 和 kTIMSdkConfigConfigFilePath 的值要求是 UTF-8 编码
* 
*/
TIM_DECL int TIMInit(uint64_t sdk_app_id, const char* json_sdk_config);

/**
* @brief  2.2 ImSDK卸载
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
* @brief  2.3 获取ImSDK版本号
* @return const char* 返回ImSDK的版本号
*/
TIM_DECL const char* TIMGetSDKVersion(void);

/**
* @brief  设置额外的用户配置
* @param json_config 配置选项
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
* @example 设置Http代理
* Json::Value json_http_proxy;
* json_http_proxy[kTIMHttpProxyInfoIp] = "http://http-proxy.xxxxx.com";
* json_http_proxy[kTIMHttpProxyInfoPort] = 8888;
* json_http_proxy[kTIMHttpProxyInfoUserName] = "User-01";
* json_http_proxy[kTIMHttpProxyInfoPassword] = "123456";
* Json::Value json_config;
* json_config[kTIMSetConfigHttpProxyInfo] = json_http_proxy;
*
* if (TIM_SUCC != TIMSetConfig(json_config.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     // 回调内部
* }, this)) {
*     // TIMSetConfig接口调用失败
* }
*
* @example 取消Http代理
* Json::Value json_http_proxy;
* json_http_proxy[kTIMHttpProxyInfoIp] = "";
* json_http_proxy[kTIMHttpProxyInfoPort] = 0;
* json_http_proxy[kTIMHttpProxyInfoUserName] = "";
* json_http_proxy[kTIMHttpProxyInfoPassword] = "";
* Json::Value json_config;
* json_config[kTIMSetConfigHttpProxyInfo] = json_http_proxy;
*
* if (TIM_SUCC != TIMSetConfig(json_config.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     // 回调内部
* }, this)) {
*     // TIMSetConfig接口调用失败
* }
*
* @example 设置socks5代理
* Json::Value json_socks5_value;
* json_socks5_value[kTIMSocks5ProxyInfoIp] = "111.222.333.444";
* json_socks5_value[kTIMSocks5ProxyInfoPort] = 8888;
* json_socks5_value[kTIMSocks5ProxyInfoUserName] = "";
* json_socks5_value[kTIMSocks5ProxyInfoPassword] = "";
* Json::Value json_config;
* json_config[kTIMSetConfigSocks5ProxyInfo] = json_socks5_value;
*
* if (TIM_SUCC != TIMSetConfig(json_config.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     // 回调内部
* }, this)) {
*     //TIMSetConfig接口调用失败
* }
*
* @example 取消socks5代理
* Json::Value json_socks5_value;
* json_socks5_value[kTIMSocks5ProxyInfoIp] = "";
* json_socks5_value[kTIMSocks5ProxyInfoPort] = 0;
* json_socks5_value[kTIMSocks5ProxyInfoUserName] = "";
* json_socks5_value[kTIMSocks5ProxyInfoPassword] = "";
* Json::Value json_config;
* json_config[kTIMSetConfigSocks5ProxyInfo] = json_socks5_value;
*
* if (TIM_SUCC != TIMSetConfig(json_config.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     // 回调内部
* }, this)) {
*     //TIMSetConfig接口调用失败
* }
*
* @note
* 目前支持设置的配置有http代理的IP和端口、socks5代理的IP和端口、输出日志的级别、获取群信息/群成员信息的默认选项、是否接受消息已读回执事件等。
* http代理的IP和端口、socks5代理的IP和端口建议调用[TIMInit]()之前配置。
* 每项配置可以单独设置，也可以一起配置,详情请参考 [SetConfig](TIMCloudDef.h)。
*/
TIM_DECL int TIMSetConfig(const char* json_config, TIMCommCallback cb, const void* user_data);
/// @}

/**
* @brief  2.4 获取服务器当前时间
* @return uint64_t 服务器时间，单位 s
*
* @note
* 可用于信令离线推送场景下超时判断
*/
TIM_DECL uint64_t TIMGetServerTime();
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                       登录/登出
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 登录登出相关接口
/// @{
/**
* @brief 3.1 登录
*
* @param user_id 用户的UserID
* @param user_sig 用户的UserSig
* @param cb 登录成功与否的回调。票据过期会返回 ERR_USER_SIG_EXPIRED（6206）或者 ERR_SVR_ACCOUNT_USERSIG_EXPIRED（70001） 错误码，此时请您生成新的 userSig 重新登录。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note 
* 用户登录腾讯后台服务器后才能正常收发消息，登录需要用户提供UserID、UserSig等信息，具体含义请参考[登录鉴权](https://cloud.tencent.com/document/product/269/31999)
*/
TIM_DECL int TIMLogin(const char* user_id, const char* user_sig, TIMCommCallback cb, const void* user_data);

/**
* @brief  3.2 登出
*
* @param cb 登出成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* 如用户主动登出或需要进行用户的切换，则需要调用登出操作
*/
TIM_DECL int TIMLogout(TIMCommCallback cb, const void* user_data);

/**
* @brief  3.3 获取登录状态
*
* @return TIMLoginStatus 每个返回值的定义请参考 [TIMLoginStatus](TIMCloudDef.h)
*
* @note
*  如果用户已经处于已登录和登录中状态，请勿再频繁调用登录接口登录
*/
TIM_DECL TIMLoginStatus TIMGetLoginStatus();

/**
* @brief  3.4 获取登陆用户的 userID
*
* @param user_id_buffer 用户 ID ，出参，分配内存大小不能低于 128 字节，调用接口后，可以读取到以 '\0' 结尾的字符串
* @return int 返回TIM_SUCC表示接口调用成功，其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* const size_t kUserIDLength = 128;
* char user_id_buffer[kUserIDLength] = {0};
* TIMGetLoginUserID(user_id_buffer);
*
*/
TIM_DECL int TIMGetLoginUserID(char* user_id_buffer);
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
* @brief 4.2 删除会话
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
* @brief 4.3 获取最近联系人的会话列表
* 
* @param cb 获取最近联系人会话列表的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
*/
TIM_DECL int TIMConvGetConvList(TIMCommCallback cb, const void* user_data);

/**
* @brief  4.4 查询一组会话列表
*
* @param json_get_conv_list_param   会话 ID 和会话类型的列表
* @param cb 会话列表的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功，其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Object json_obj;
* json_obj[kTIMGetConversationListParamConvId] = "98826";
* json_obj[kTIMGetConversationListParamConvType] = kTIMConv_C2C;
*
* Json::Array json_arry;
* json_arry.append(json_obj);
*
* TIMConvGetConvInfo(json_arry.toStyledString().c_str(),
*    [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*    printf("TIMConvGetConvInfo|code:%d|desc:%s\n", code, desc);
* }, nullptr);
*
* // json_params 示例。 具体请参考 [ConvInfo](TIMCloudDef.h)
* [{
*   "conv_active_time": 5,
*   "conv_id": "98826",
*   "conv_is_has_draft": false,
*   "conv_is_has_lastmsg": true,
*   "conv_is_pinned": false,
*   "conv_last_msg": {
*       "message_client_time": 1620877708,
*       "message_conv_id": "98826",
*       "message_conv_type": 1,
*       "message_custom_int": 0,
*       "message_custom_str": "",
*       "message_elem_array": [{
*           "elem_type": 0,
*           "text_elem_content": "11111"
*   }],
*       "message_is_from_self": false,
*       "message_is_online_msg": false,
*       "message_is_peer_read": false,
*       "message_is_read": false,
*       "message_msg_id": "144115233874815003-1620877708-1038050731",
*       "message_platform": 0,
*       "message_priority": 1,
*       "message_rand": 1038050731,
*       "message_sender": "98826",
*       "message_sender_profile": {
*           "user_profile_add_permission": 1,
*           "user_profile_birthday": 0,
*           "user_profile_custom_string_array": [],
*           "user_profile_face_url": "test1-www.google.com",
*           "user_profile_gender": 0,
*           "user_profile_identifier": "98826",
*           "user_profile_language": 0,
*           "user_profile_level": 0,
*           "user_profile_location": "",
*           "user_profile_nick_name": "test change8888",
*           "user_profile_role": 0,
*           "user_profile_self_signature": ""
        },
*       "message_seq": 15840,
*       "message_server_time": 1620877708,
*       "message_status": 2,
*       "message_unique_id": 6961616747713488299
*    },
*    "conv_type": 1,
*    "conv_unread_num": 1
* }]
*/
TIM_DECL int TIMConvGetConvInfo(const char* json_get_conv_list_param, TIMCommCallback cb, const void* user_data);
/// @}

/**
* @brief 4.5 设置指定会话的草稿
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
* @brief 4.6 删除指定会话的草稿
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @return int 返回TIM_SUCC表示接口调用成功，其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
*/
TIM_DECL int TIMConvCancelDraft(const char* conv_id, enum TIMConvType conv_type);
/// @}

/**
* @brief  4.7 设置会话置顶
*
* @param conv_id   会话 ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param is_pinned 是否置顶会话
* @param cb 设置会话置顶回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回 TIM_SUCC 表示接口调用成功（接口只有返回 TIM_SUCC，回调 cb 才会被调用）。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @example
* // json_param 返回值为空字符串， 直接判断 code 即可
* TIMConvPinConversation(
*      [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*      printf("TIMConvPinConversation|code:%d|desc:%s\n", code, desc);
* }, nullptr);
*
*/
TIM_DECL int TIMConvPinConversation(const char* conv_id, TIMConvType conv_type, bool is_pinned, TIMCommCallback cb, const void* user_data);
/// @}

/**
* @brief  4.8 获取所有会话总的未读消息数
* 
* @param cb 获取所有会话总的未读消息数回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回 TIM_SUCC 表示接口调用成功（接口只有返回 TIM_SUCC，回调 cb 才会被调用）。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @example
*  TIMConvGetTotalUnreadMessageCount(
*       [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*       printf("TIMConvGetTotalUnreadMessageCount|code:%d|desc:%s\n", code, desc);
*  }, nullptr);
*
*  json_params 的示例。 json key 请参考 [GetTotalUnreadNumberResult](TIMCloudDef.h)
* {"conv_get_total_unread_message_count_result_unread_count":4}
*/
TIM_DECL int TIMConvGetTotalUnreadMessageCount(TIMCommCallback cb, const void* user_data);
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
* @brief 5.1 发送新消息
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_param  消息json字符串
* @param message_id 消息 ID ，分配内存大小不能低于 128 字节，如果不需要，可传入 nullptr，调用接口后，可以读取到以 '\0' 结尾的字符串
* @param cb 发送新消息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数 cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调 cb 才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
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
* const size_t kMessageIDLength = 128;
* char message_id_buffer[kMessageIDLength] = {0};
* int ret = TIMMsgSendMessage(conv_id.c_str(), kTIMConv_C2C, json_value_msg.toStyledString().c_str(), message_id_buffer, 
*     [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     if (ERR_SUCC != code) {
*         // 消息发送失败
*         return;
*     }
*     // 消息发送成功
* }, nullptr);
*
* // json_value_msg.toStyledString().c_str() 得到 json_msg_param JSON 字符串如下
* {
*    "message_id" : "14400111550110000_1551446728_45598731"
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
*
* @note
* >  发送新消息，单聊消息和群消息的发送均采用此接口。
* >> 发送单聊消息时 conv_id 为对方的UserID， conv_type 为 kTIMConv_C2C 
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
TIM_DECL int TIMMsgSendMessage(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_param, char* message_id_buffer, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.2 根据消息 messageID 取消发送中的消息
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param message_id  消息 ID
* @param cb 取消结果的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* TIMMsgCancelSend("test_win_03", kTIMConv_C2C, "message_id_1", [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, nullptr);
*
*/
TIM_DECL int TIMMsgCancelSend(const char* conv_id, enum TIMConvType conv_type, const char* message_id, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.3 根据消息 messageID 查询本地的消息列表
*
* @param json_message_id_array  消息 ID 列表
* @param cb 根据消息定位精准查找指定会话的消息成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* @example
* Json::Value json_message_id_1("id_clienttime_rand_1");
* Json::Value json_message_id_2("id_clienttime_rand_2");
*
* Json::Value json_message_id_array;
* json_message_id_array.append(json_message_id_1);
* json_message_id_array.append(json_message_id_2);
* TIMMsgFindMessages(json_message_id_array.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, nullptr);
*
* // json_message_id_array.toStyledString().c_str() 的到 json_message_id_array JSON 字符串如下
* [
*    "id_clienttime_rand_1",
*    "id_clienttime_rand_2",
* ]
*
*/
TIM_DECL int TIMMsgFindMessages(const char* json_message_id_array, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.4 消息上报已读
*
* @param conv_id   会话的ID，从 5.8 版本开始，当 conv_id 为 NULL 空字符串指针或者""空字符串时，标记 conv_type 表示的所有单聊消息或者群组消息为已读状态
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_param  消息json字符串
* @param cb 消息上报已读成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* json_msg_param 可以填 NULL 空字符串指针或者""空字符串，此时以会话当前最新消息的时间戳（如果会话存在最新消息）或当前时间为已读时间戳上报.当要指定消息时，则以该指定消息的时间戳为已读时间戳上报，最好用接收新消息获取的消息数组里面的消息Json或者用消息定位符查找到的消息Json，避免重复构造消息Json。
*/
TIM_DECL int TIMMsgReportReaded(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.5 标记所有消息为已读（5.8及其以上版本支持）
*
* @param cb 成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
*/
TIM_DECL int TIMMsgMarkAllMessageAsRead(TIMCommCallback cb, const void* user_data);

/**
* @brief 5.6 消息撤回
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_param  消息json字符串
* @param cb 消息撤回成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_value_text;
* json_value_text[kTIMElemType] = kTIMElem_Text;
* json_value_text[kTIMTextElemContent] = "send text";
* Json::Value json_value_msg;
* json_value_msg[kTIMMsgElemArray].append(json_value_text);
*
* int ret = TIMMsgSendNewMsg("test_win_03", kTIMConv_C2C, json_value_msg.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     if (ERR_SUCC != code) {
*         // 消息发送失败
*         return;
*     }
*     // 消息发送成功 json_param 返回发送后的消息json字符串
*     TIMMsgRevoke("test_win_03", kTIMConv_C2C, json_param, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*         if (ERR_SUCC != code) {
*             // 消息撤回失败
*             return;
*         }
*         // 消息撤回成功
*
*     }, user_data);
* }, this);
*
* @note
* 消息撤回。使用保存的消息Json或者用消息定位符查找到的消息Json，避免重复构造消息Json.
*/
TIM_DECL int TIMMsgRevoke(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.7 根据消息定位精准查找指定会话的消息
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
* @brief 5.8 导入消息列表到指定会话
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
* // json_value_msgs.toStyledString().c_str() 得到json_msg_array JSON 字符串如下
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
* 批量导入消息，可以自己构造消息去导入。也可以将之前要导入的消息数组Json保存，然后导入的时候直接调用接口，避免构造消息数组
*/
TIM_DECL int TIMMsgImportMsgList(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_array, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.9 保存自定义消息
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
* @brief 5.10 获取指定会话的消息列表
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_get_msg_param 消息获取参数
* @param cb 获取指定会话的消息列表成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example 获取C2C会话 Windows-02 消息列表
* Json::Value json_msg(Json::objectValue); // 构造Message
* Json::Value json_get_msg_param;
* json_get_msg_param[kTIMMsgGetMsgListParamLastMsg] = json_msg;
* json_get_msg_param[kTIMMsgGetMsgListParamIsRamble] = false;
* json_get_msg_param[kTIMMsgGetMsgListParamIsForward] = true;
* json_get_msg_param[kTIMMsgGetMsgListParamCount] = 100;
*
* int ret = TIMMsgGetMsgList("Windows-02", kTIMConv_C2C, json_get_msg_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
* }, this);
* 
* // json_get_msg_param.toStyledString().c_str() 得到 json_get_msg_param JSON 字符串如下
* {
*    "msg_getmsglist_param_count" : 100,
*    "msg_getmsglist_param_is_forward" : true,
*    "msg_getmsglist_param_is_remble" : false,
*    "msg_getmsglist_param_last_msg" : {}
* }
*   
* @note
* 从 kTIMMsgGetMsgListParamLastMsg 指定的消息开始获取本地消息列表，kTIMMsgGetMsgListParamCount 为要获取的消息数目。kTIMMsgGetMsgListParamLastMsg 可以不指定，不指定时表示以会话最新的消息为 LastMsg 。
* 若指定 kTIMMsgGetMsgListParamIsRamble 为true则本地消息获取不够指定数目时，会去获取云端漫游消息。
* kTIMMsgGetMsgListParamIsForward 为true时表示获取比 kTIMMsgGetMsgListParamLastMsg 新的消息，为false时表示获取比 kTIMMsgGetMsgListParamLastMsg 旧的消息
*
* 拉取 kTIMConv_C2C 消息时，只能使用 kTIMMsgGetMsgListParamLastMsg 作为消息的拉取起点；如果没有指定 kTIMMsgGetMsgListParamLastMsg，默认使用会话的最新消息作为拉取起点
* 拉取 kTIMConv_Group 消息时，除了可以使用 kTIMMsgGetMsgListParamLastMsg 作为消息的拉取起点外，也可以使用 kTIMMsgGetMsgListParamLastMsgSeq 来指定消息的拉取起点，二者的区别在于：
* 使用 kTIMMsgGetMsgListParamLastMsg 作为消息的拉取起点时，返回的消息列表里不包含 kTIMMsgGetMsgListParamLastMsg；
* 使用 kTIMMsgGetMsgListParamLastMsgSeq 作为消息拉取起点时，返回的消息列表里包含 kTIMMsgGetMsgListParamLastMsgSeq 所表示的消息；
*
* 在拉取 kTIMConv_Group 消息时
* 如果同时指定了 kTIMMsgGetMsgListParamLastMsg 和 kTIMMsgGetMsgListParamLastMsgSeq，SDK 优先使用 kTIMMsgGetMsgListParamLastMsg 作为消息的拉取起点
* 如果 kTIMMsgGetMsgListParamLastMsg 和 kTIMMsgGetMsgListParamLastMsgSeq，SDK 都未指定，消息的拉取起点分为如下两种情况：
* 如果设置了拉取的时间范围，SDK 会根据 kTIMMsgGetMsgListParamTimeBegin 所描述的时间点作为拉取起点
* 如果未设置拉取的时间范围，SDK 默认使用会话的最新消息作为拉取起点
*
*/
TIM_DECL int TIMMsgGetMsgList(const char* conv_id, enum TIMConvType conv_type, const char* json_get_msg_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.11 删除指定会话的消息
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msgdel_param 删除消息的参数
* @param cb 删除指定会话的消息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example 
* Json::Value json_value_msg(Json::objectValue);
* Json::Value json_value_msgdelete;
* json_value_msgdelete[kTIMMsgDeleteParamMsg] = json_value_msg;
* TIMMsgDelete("user2", kTIMConv_C2C, json_value_msgdelete.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
* 
* }, nullptr);
* 
* // json_value_msgdelete.toStyledString().c_str() 得到 json_msgdel_param JSON 字符串如下
* {
*   "msg_delete_param_is_remble" : false,
*   "msg_delete_param_msg" : {}
* }
*
*/
TIM_DECL int TIMMsgDelete(const char* conv_id, enum TIMConvType conv_type, const char* json_msgdel_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.12 删除指定会话的本地及漫游消息列表
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_array 消息数组
* @param cb 删除消息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
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
* TIMMsgListDelete("user2", kTIMConv_C2C, json_value_msgs.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, nullptr);
*
* // json_value_msgs.toStyledString().c_str() 得到json_msg_array JSON 字符串如下
* [
*    {
*       "message_client_time" : 1551446728,
*       "message_elem_array" : [
*          {
*             "elem_type" : 0,
*             "text_elem_content" : "I will be deleted"
*          }
*       ],
*       "message_sender" : "user1",
*       "message_server_time" : 1551446728
*    }
* ]
*
* @note
* 本接口会在删除本地消息的同时也会删除漫游消息。需要注意以下几点：
* > 建议将之前的消息数组Json保存，然后删除的时候直接调用接口，避免构造消息数组。
* > 一次最多只能删除 30 条消息。
* > 一秒钟最多只能调用一次该接口。
* > 如果该账号在其他设备上拉取过这些消息，那么调用该接口删除后，这些消息仍然会保存在那些设备上，即删除消息不支持多端同步。
*/
TIM_DECL int TIMMsgListDelete(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_array, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.13 清空指定会话的消息
*
* @param conv_id 会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param cb 清空成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @example 
* TIMMsgClearHistoryMessage("user2", kTIMConv_C2C, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
* 
* }, nullptr);
*
*/
TIM_DECL int TIMMsgClearHistoryMessage(const char* conv_id, enum TIMConvType conv_type, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.14 设置针对某个用户的 C2C 消息接收选项（支持批量设置）
*
* @param json_identifier_array 用户 ID 列表
* @param opt 消息接收选项，请参考[TIMReceiveMessageOpt](TIMCloudDef.h)
* @param cb 设置成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_identifier_array(Json::arrayValue);
* json_identifier_array.append("user1");
* json_identifier_array.append("user2");
*
* TIMMsgSetC2CReceiveMessageOpt(json_identifier_array.toStyledString().c_str(), kTIMRecvMsgOpt_Receive, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, this);
* 
* @note
* > 该接口支持批量设置，您可以通过参数 userIDList 设置一批用户，但一次最大允许设置 30 个用户。
* > 该接口调用频率被限制为1秒内最多调用5次。
*/
TIM_DECL int TIMMsgSetC2CReceiveMessageOpt(const char* json_identifier_array, TIMReceiveMessageOpt opt, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.15 查询针对某个用户的 C2C 消息接收选项
*
* @param json_identifier_array 用户 ID 列表
* @param cb 查询结果的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_identifier_array(Json::arrayValue);
* json_identifier_array.append("user1");
* json_identifier_array.append("user2");
*
* TIMMsgGetC2CReceiveMessageOpt(json_identifier_array.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, this);
* 
* // 回调的 json_param 示例。Json Key请参考[GetC2CRecvMsgOptResult](TIMCloudDef.h)
* [
*    {
*       "msg_recv_msg_opt_result_identifier" : "user1",
*       "msg_recv_msg_opt_result_opt" : 0,
*    },
*    {
*       "msg_recv_msg_opt_result_identifier" : "user2",
*       "msg_recv_msg_opt_result_opt" : 1,
*    }
* ]
*
*/
TIM_DECL int TIMMsgGetC2CReceiveMessageOpt(const char* json_identifier_array, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.16 设置群消息的接收选项
*
* @param group_id 群 ID
* @param opt 消息接收选项，请参考[TIMReceiveMessageOpt](TIMCloudDef.h)
* @param cb 设置成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* TIMMsgSetGroupReceiveMessageOpt("group_id", kTIMRecvMsgOpt_Receive, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, this);
* 
* @note
* > 查询群消息的接收选项：您可以在群资料（GroupBaseInfo）中获得这个信息
*/
TIM_DECL int TIMMsgSetGroupReceiveMessageOpt(const char* group_id, TIMReceiveMessageOpt opt, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.17 下载消息内元素到指定文件路径(图片、视频、音频、文件)
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
* 在相应元素内找到。其中 kTIMMsgDownloadElemParamType 为下载文件类型 [TIMDownloadType](TIMCloudDef.h)，参数 path 要求是 UTF-8 编码
*/
TIM_DECL int TIMMsgDownloadElemToPath(const char* json_download_elem_param, const char* path, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.18 下载合并消息
*
* @param json_single_msg  单条消息的 JSON 字符串，接收消息、查找消息或查询历史消息时获取到的消息
* @param cb 下载成功与否的回调以及下载进度回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* // 接收一条消息 json_single_msg 
* TIMMsgDownloadMergerMessage(json_single_msg, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
* }, this);
* 
*/
TIM_DECL int TIMMsgDownloadMergerMessage(const char* json_single_msg, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.19 群发消息，该接口不支持向群组发送消息。
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
* // json_value_batchsend.toStyledString().c_str() 得到 json_batch_send_param JSON 字符串如下
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
* 批量发送消息的接口，每个UserID发送成功与否，通过回调cb返回。
*/
TIM_DECL int TIMMsgBatchSend(const char* json_batch_send_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 5.20 搜索本地消息（5.4.666 及以上版本支持，需要您购买旗舰版套餐）
*
* @param json_search_message_param 消息搜索参数
* @param cb 搜索成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example 搜索本地消息
* Json::Value json_search_message_param;
* json_search_message_param[kTIMMsgSearchParamKeywordArray].append("keyword1");
* json_search_message_param[kTIMMsgSearchParamKeywordArray].append("keyword2");
* json_search_message_param[kTIMMsgSearchParamMessageTypeArray].append(kTIMElem_Text);
* json_search_message_param[kTIMMsgSearchParamMessageTypeArray].append(kTIMElem_Image);
* json_search_message_param[kTIMMsgSearchParamConvId] = "xxxxx";
* json_search_message_param[kTIMMsgSearchParamConvType] = kTIMConv_Group;
* json_search_message_param[kTIMMsgSearchParamPageIndex] = 0;
* json_search_message_param[kTIMMsgSearchParamPageSize] = 10;
*
* int ret = TIMMsgSearchLocalMessages(json_search_message_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
* 
* }, this);
* 
* // json_search_message_param.toStyledString().c_str() 得到 json_search_message_param JSON 字符串如下
* {
*    "msg_search_param_keyword_array" : ["keyword1", "keyword2"],
*    "msg_search_param_message_type_array" : [0, 1],
*    "msg_search_param_page_index" : 0,
*    "msg_search_param_page_size" : 10
* }
* 
*/
TIM_DECL int TIMMsgSearchLocalMessages(const char* json_search_message_param, TIMCommCallback cb, const void* user_data);
/// @}

/**
* @brief 5.21 设置消息自定义数据（本地保存，不会发送到对端，程序卸载重装后失效）
* 
* @param json_msg_param  消息json字符串
* @param cb 保存自定义消息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* @example
*   Json::Value json_parameters;
*   json_parameters[kTIMMsgGetMsgListParamIsRamble] = true;
*   json_parameters[kTIMMsgGetMsgListParamIsForward] = false;
*   json_parameters[kTIMMsgGetMsgListParamCount] = 1;
*    TIMMsgGetMsgList("98826", kTIMConv_C2C, json_parameters.toStyledString().c_str(),
*       [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
            Json::Reader json_reader;
*           json::Array json_message_array;
            json_reader.parse(json_params, json_message_array);
*           if (json_message_array.size() > 0) {
*               Json::Value json_obj_msg = json_message_array[0];
*               json_obj_msg[kTIMMsgCustomStr] = "custom Str";
*               json_obj_msg[kTIMMsgCustomInt] = "custom int";
*               TIMMsgSetLocalCustomData(json_obj_msg.toStyledString().c_str(),
*                   [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*                       printf("TIMMsgSetLocalCustomData complete|code:%d|desc:%s\n", code, desc);
*                   }, nullptr);
*           }
*   }, nullptr);
*/ 
TIM_DECL int TIMMsgSetLocalCustomData(const char* json_msg_param, TIMCommCallback cb, const void* user_data);


/////////////////////////////////////////////////////////////////////////////////
//
//                       群组相关接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 群组相关接口
/// @brief 群组相关介绍请参考 [群组系统](https://cloud.tencent.com/document/product/269/1502)、[群组管理](https://cloud.tencent.com/document/product/269/3661)和 [群组自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
/// @{
/**
* @brief 6.1 创建群组
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
* > 创建群组时可以指定群ID，若未指定时IM通讯云服务器会生成一个唯一的ID，以便后续操作，群组ID通过创建群组时传入的回调返回
* > 创建群参数的Json Key详情请参考[CreateGroupParam](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupCreate(const char* json_group_create_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 6.2 删除(解散)群组
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
* > 删除指定群组group_id的接口，删除成功与否可根据回调cb的参数判断。
*/
TIM_DECL int TIMGroupDelete(const char* group_id, TIMCommCallback cb, const void* user_data);

/**
* @brief 6.3 申请加入群组
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
* > 申请加入指定群组group_id的接口，申请加入的操作成功与否可根据回调cb的参数判断。
*/
TIM_DECL int TIMGroupJoin(const char* group_id, const char* hello_msg, TIMCommCallback cb, const void* user_data);

/**
* @brief 6.4 退出群组
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
* > 退出指定群组group_id的接口，退出成功与否可根据回调cb的参数判断。
*/
TIM_DECL int TIMGroupQuit(const char* group_id, TIMCommCallback cb, const void* user_data);

/**
* @brief 6.5 邀请加入群组
*
* @param json_group_invite_param 邀请加入群组的Json字符串
* @param cb 邀请加入群组成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_value_invite;
* json_value_invite[kTIMGroupInviteMemberParamGroupId] = group_id;
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
* @brief 6.6 删除群组成员
*
* @param json_group_delete_param 删除群组成员的Json字符串
* @param cb 删除群组成员成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_value_delete;
* json_value_delete[kTIMGroupDeleteMemberParamGroupId] = group_id;
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
* @brief 6.7 获取已加入群组列表
*
* @param cb 获取已加入群组列表成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* > 权限说明：
* >>   此接口可以获取自己所加入的群列表
* >>   此接口只能获得加入的部分直播大群的列表。
* > 此接口用于获取当前用户已加入的群组列表，返回群组的基础信息。具体返回的群组信息字段参考[GroupBaseInfo,GroupDetailInfo](TIMCloudDef.h)和[GroupDetailInfo](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupGetJoinedGroupList(TIMCommCallback cb, const void* user_data);

/**
* @brief 6.8 获取群组信息列表
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
* // groupids.toStyledString().c_str() 得到json_group_getinfo_param如下
* [ "third group id", "second group id", "first group id" ]
*
* @note
* 此接口用于获取指定群ID列表的群详细信息。具体返回的群组详细信息字段参考[GroupDetailInfo,GroupBaseInfo](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupGetGroupInfoList(const char* json_group_getinfo_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 6.9 修改群信息
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
* // json_value_modifygroupinfo.toStyledString().c_str() 得到json_group_modifyinfo_param JSON 字符串如下
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
* // json_value_modifygroupinfo.toStyledString().c_str() 得到json_group_modifyinfo_param JSON 字符串如下
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
* > kTIMGroupModifyInfoParamModifyFlag 可以按位或设置多个值。不同的flag设置不同的键,详情请参考[GroupModifyInfoParam](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupModifyGroupInfo(const char* json_group_modifyinfo_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 6.10 获取群成员信息列表
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
* getmeminfo_opt[kTIMGroupGetMemberInfoListParamGroupId] = group_id;
* getmeminfo_opt[kTIMGroupGetMemberInfoListParamIdentifierArray] = identifiers;
* getmeminfo_opt[kTIMGroupGetMemberInfoListParamOption] = option;
* getmeminfo_opt[kTIMGroupGetMemberInfoListParamNextSeq] = 0;
* 
* int ret = TIMGroupGetMemberInfoList(getmeminfo_opt.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
* 
* }, this);
*
* // getmeminfo_opt.toStyledString().c_str() 得到json_group_getmeminfos_param JSON 字符串如下
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
* @brief 6.11 修改群成员信息
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
* // json_value_modifygroupmeminfo.toStyledString().c_str() 得到json_group_modifymeminfo_param JSON 字符串如下
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
* > kTIMGroupModifyMemberInfoParamModifyFlag 可以按位或设置多个值，不同的flag设置不同的键。请参考[GroupModifyMemberInfoParam](TIMCloudDef.h)
*/
TIM_DECL int TIMGroupModifyMemberInfo(const char* json_group_modifymeminfo_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 6.12 获取群未决信息列表
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
* // get_pendency_option.toStyledString().c_str() 得到json_group_getpendence_list_param JSON 字符串如下
* {
*    "group_pendency_option_max_limited" : 0,
*    "group_pendency_option_start_time" : 0
* }
*
* @note 
* > 此处的群未决消息泛指所有需要审批的群相关的操作。例如：加群待审批，拉人入群待审批等等。即便审核通过或者拒绝后，该条信息也可通过此接口拉回，拉回的信息中有已决标志。
* > UserA申请加入群GroupA，则群管理员可获取此未决相关信息，UserA因为没有审批权限，不需要获取此未决信息。
* > 如果AdminA拉UserA进去GroupA，则UserA可以拉取此未决相关信息，因为该未决信息待UserA审批
* > 权限说明：
* >> 只有审批人有权限拉取相关未决信息。
* > kTIMGroupPendencyOptionStartTime 设置拉取时间戳,第一次请求填0,后边根据server返回的 [GroupPendencyResult](TIMCloudDef.h) 键 kTIMGroupPendencyResultNextStartTime 指定的时间戳进行填写。
* > kTIMGroupPendencyOptionMaxLimited 拉取的建议数量,server可根据需要返回或多或少,不能作为完成与否的标志
*/
TIM_DECL int TIMGroupGetPendencyList(const char* json_group_getpendence_list_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 6.13 上报群未决信息已读
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
* @brief 6.14 处理群未决信息
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
* // handle_pendency.toStyledString().c_str() 得到json_group_handle_pendency_param JSON 字符串如下
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
* > 对于群的未决信息，ImSDK增加了处理接口。审批人可以选择对单条信息进行同意或者拒绝。已处理成功过的未决信息不能再次处理。
* > 处理未决信息时需要带一个未决信息[GroupPendency](TIMCloudDef.h)，可以在接口[TIMGroupGetPendencyList]()返回的未决信息列表将未决信息保存下来，
*   在处理未决信息的时候将[GroupPendency](TIMCloudDef.h)传入键 kTIMGroupHandlePendencyParamPendency 。
*/
TIM_DECL int TIMGroupHandlePendency(const char* json_group_handle_pendency_param, TIMCommCallback cb, const void* user_data);
/// @}


/**
* @brief 6.15 获取指定群在线人数
*
* @param group_id 群 ID
* @param cb 获取指定群在线人数的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h
*
* @note 请注意
 * - 目前只支持：直播群（ AVChatRoom）。
 * - 该接口有频限检测，SDK 限制调用频率为60秒1次
* @example
* TIMGroupGetOnlineMemberCount("lamarzhang_group_public", [](int32_t code, const char* desc, const char* json_param, const void* user_data) {

*  }, nullptr);
*
* json_param 的示例。 json key 请参考 [GroupGetOnlineMemberCountResult](TIMCloudCallback.h)
* {"group_get_online_member_count_result":0}
*
* @note
*/
TIM_DECL int TIMGroupGetOnlineMemberCount(const char* group_id, TIMCommCallback cb, const void* user_data);
/// @}

/**
* @brief 6.16 搜索群资料（5.4.666 及以上版本支持，需要您购买旗舰版套餐）
*
* @param json_group_search_groups_param  群列表的参数 array ，具体参考 [GroupSearchParam](TIMCloudCallback.h)
* @param cb 搜索群列表回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* @note 
*  SDK 会搜索群名称包含于关键字列表 keywordList 的所有群并返回群信息列表。关键字列表最多支持5个。
* @example
*    Json::Array json_keyword_list;
*    json_keyword_list.append("lamarzhang_group_public");
*
*    Json::Array json_field_list;
*    json_field_list.appned(kTIMGroupSearchFieldKey_GroupId);
*
*    Json::Object json_obj;
*    json_obj[TIMGroupSearchParamKeywordList] = json_keyword_list;
*    json_obj[TIMGroupSearchParamFieldList] = json_field_list;
*   TIMGroupSearchGroups(json_array.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {

*   }, nullptr);
*
*   回调的 json_param 示例。 json key 请参考 [GroupDetailInfo](TIMCloudDef.h)
*[{
*   "group_detial_info_add_option": 1,
*   "group_detial_info_create_time": 0,
*   "group_detial_info_custom_info": [{
*       "group_info_custom_string_info_key": "custom_public",
*       "group_info_custom_string_info_value": ""
*   }, {
*       "group_info_custom_string_info_key": "custom_public2",
*       "group_info_custom_string_info_value": ""
*   }, {
*       "group_info_custom_string_info_key": "group_info",
*       "group_info_custom_string_info_value": ""
*   }, {
*       "group_info_custom_string_info_key": "group_test",
*       "group_info_custom_string_info_value": ""
*   }],
*   "group_detial_info_face_url": "",
*   "group_detial_info_group_id": "lamarzhang_group_public",
*   "group_detial_info_group_name": "lamarzhang_group_public",
*   "group_detial_info_group_type": 0,
*   "group_detial_info_info_seq": 9,
*   "group_detial_info_introduction": "Instroduction",
*   "group_detial_info_is_shutup_all": false,
*   "group_detial_info_last_info_time": 1620810613,
*   "group_detial_info_last_msg_time": 1620810613,
*   "group_detial_info_max_member_num": 1000,
*   "group_detial_info_member_num": 2,
*   "group_detial_info_next_msg_seq": 2,
*   "group_detial_info_notification": "Notification",
*   "group_detial_info_online_member_num": 0,
*   "group_detial_info_owener_identifier": "lamarzhang",
*   "group_detial_info_searchable": true,
*   "group_detial_info_visible": true
}]
*/
TIM_DECL int TIMGroupSearchGroups(const char *json_group_search_groups_param, TIMCommCallback cb, const void* user_data);


/**
* @brief 6.17 搜索群成员（5.4.666 及以上版本支持，需要您购买旗舰版套餐）
*
* @param json_group_search_group_members_param 群成员列表的参数 array ，具体参考 [GroupMemberSearchParam](TIMCloudCallback.h)
* @param cb 搜索群成员列表的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* @note 
* SDK 会在本地搜索指定群 ID 列表中，群成员信息（名片、好友备注、昵称、userID）包含于关键字列表 keywordList 的所有群成员并返回群 ID 和群成员列表的 map，关键字列表最多支持5个。
* @example

*   Json::Array json_groupid_list;
*   json_groupid_list.append("lamarzhang_group_public");

*   Json::Array json_keyword_list;
*   json_keyword_list.append("98826");
*
*   Json::Array json_field_list;
*   json_field_list.appned(kTIMGroupMemberSearchFieldKey_Identifier);
*   Json::Object json_obj;
*   json_obj[TIMGroupMemberSearchParamGroupidList ] = json_groupid_list;
*   json_obj[TIMGroupMemberSearchParamKeywordList ] = json_keyword_list;
*   json_obj[TIMGroupMemberSearchParamFieldList ] = json_field_list;
*   TIMGroupSearchGroupMembers(json_obj.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {

*   }, nullptr);
*
* 回调的 json_param 示例。 json key 请参考 [GroupGetOnlineMemberCountResult](TIMCloudDef.h)
* [{
*   "group_search_member_result_groupid": "lamarzhang_group_public",
*   "group_search_member_result_menber_info_list": [{
*       "group_member_info_custom_info": [{
*           "group_info_custom_string_info_key": "group_member_p",
*           "group_info_custom_string_info_value": ""
*       }, {
*           "group_info_custom_string_info_key": "group_member_p2",
*           "group_info_custom_string_info_value": ""
*       }],
*       "group_member_info_identifier": "98826",
*       "group_member_info_join_time": 1620810613,
*       "group_member_info_member_role": 4,
*       "group_member_info_msg_flag": 0,
*       "group_member_info_msg_seq": 0,
*       "group_member_info_name_card": "",
*       "group_member_info_shutup_time": 0
*   }]
* }]
*/
TIM_DECL int TIMGroupSearchGroupMembers(const char *json_group_search_group_members_param, TIMCommCallback cb, const void* user_data);


/**
* @brief 6.18 初始化群属性，会清空原有的群属性列表
*
* @param group_id  群 ID
* @param json_group_atrributes array [GroupAttributes] 群属性列表的参数，具体参考 [GroupAttributes] (TIMCloudCallback.h)
* @param cb  初始化群属性的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
*    Json::Object json_obj;
*    json_obj[TIMGroupAttributeKey] = "atrribute_key1";
*    json_obj[TIMGroupAttributeValue] = "atrribute_value1";

*   Json::Array json_array;
*   json_array.append(json_obj);
*   TIMGroupInitGroupAttributes("lamarzhang_group_public", json_array.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
*   }, nullptr);
*
*   json_param 为空字符串，判断 code 即可
*/
TIM_DECL int TIMGroupInitGroupAttributes(const char *group_id, const char *json_group_atrributes, TIMCommCallback cb, const void* user_data);

/**
* @brief 6.19 设置群属性，已有该群属性则更新其 value 值，没有该群属性则添加该群属性
*
* @param group_id 群 ID
* @param json_group_atrributes array [GroupAttributes] 群属性列表的参数，具体请参考 [GroupAttributes] (TIMCloudCallback.h)
* @param cb 设置群属性的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
*    Json::Object json_obj;
*    json_obj[TIMGroupAttributeKey] = "atrribute_key1";
*    json_obj[TIMGroupAttributeValue] = "atrribute_value2";
*
*    Json::Array json_array;
*    json_array.append(json_obj);
*    TIMGroupSetGroupAttributes("lamarzhang_group_public", json_array.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {

*    }, nullptr);
*
*   json_param 为空字符串，判断 code 即可
*  
*/
TIM_DECL int TIMGroupSetGroupAttributes(const char *group_id, const char *json_group_atrributes, TIMCommCallback cb, const void* user_data);

/**
* @brief 6.20 删除群属性
* @param group_id 群 ID
* @param json_keys string array 群属性的 key
* @param cb 删除群属性的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* @note 
* @example
*    Json::Array json_array;
*    json_array.append("atrribute_key1");
*
*    TIMGroupDeleteGroupAttributes("lamarzhang_group_public", json_array.toStyledString().c_str() ,[](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*        printf("InitGroupAttributes code:%d|desc:%s|json_param %s\r\n", code, desc, json_param);
*    }, nullptr);
*   json_param 无json 字符串带回，判断 code 即可
*/
TIM_DECL int TIMGroupDeleteGroupAttributes(const char *group_id, const char *json_keys, TIMCommCallback cb, const void* user_data);

/**
* @brief  6.21 获取群指定属性，keys 传 nil 则获取所有群属性。
*
* @param group_id 群 ID
* @param json_keys string array, 群属性的 key json_keys 传空的字符串则获取所有属性列表
* @param cb 获取群指定属性的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @example
*   Json::Array json_array;
*   json_array.append("atrribute_key1");
*   
*   TIMGroupGetGroupAttributes("lamarzhang_group_public", json_array.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*       printf("InitGroupAttributes code:%d|desc:%s|json_param %s\r\n", code, desc, json_param);
*   }, nullptr);
*
*   回调的 json_param 示例。 json key 请参考 [GroupAttributes](TIMCloudDef.h)
*   [{
*       "group_atrribute_key": "atrribute_key1",
*       "group_atrribute_value": "atrribute_value1"
*   }]
*/
TIM_DECL int TIMGroupGetGroupAttributes(const char *group_id, const char *json_keys, TIMCommCallback cb, const void* user_data);


/////////////////////////////////////////////////////////////////////////////////
//
//                      用户资料相关接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 用户资料相关接口
/// @brief 用户资料介绍请参考 [资料系统简介](https://cloud.tencent.com/document/product/269/1500#.E8.B5.84.E6.96.99.E7.B3.BB.E7.BB.9F.E7.AE.80.E4.BB.8B)
/// @{
/**
* @brief 7.1 获取指定用户列表的个人资料
*
* @param json_get_user_profile_list_param 获取指定用户列表的用户资料接口参数的Json字符串
* @param cb 获取指定用户列表的用户资料成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_get_user_profile_list_param;
* json_get_user_profile_list_param[kTIMFriendShipGetProfileListParamForceUpdate] = false;
* json_get_user_profile_list_param[kTIMFriendShipGetProfileListParamIdentifierArray].append("user1");
* json_get_user_profile_list_param[kTIMFriendShipGetProfileListParamIdentifierArray].append("user2");
* 
* int ret = TIMProfileGetUserProfileList(json_get_user_profile_list_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     if (ERR_SUCC != code) {
*         // 获取资料列表失败
*         return;
*     }
* }, nullptr);
* 
* @note
* 可以通过该接口获取任何人的个人资料，包括自己的个人资料。
*/
TIM_DECL int TIMProfileGetUserProfileList(const char* json_get_user_profile_list_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 7.2 修改自己的个人资料
*
* @param json_modify_self_user_profile_param 修改自己的资料接口参数的Json字符串
* @param cb 修改自己的资料成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value modify_item;
* modify_item[kTIMUserProfileItemNickName] = "change my nick name"; // 修改昵称
* modify_item[kTIMUserProfileItemGender] = kTIMGenderType_Female;  // 修改性别
* modify_item[kTIMUserProfileItemAddPermission] = kTIMProfileAddPermission_NeedConfirm;  // 修改添加好友权限
*
* Json::Value json_user_profile_item_custom;
* json_user_profile_item_custom[kTIMUserProfileCustemStringInfoKey] = "Str";  // 修改个人资料自定义字段 "Str" 的值
* json_user_profile_item_custom[kTIMUserProfileCustemStringInfoValue] = "my define data";
* modify_item[kTIMUserProfileItemCustomStringArray].append(json_user_profile_item_custom);
* int ret = TIMProfileModifySelfUserProfile(modify_item.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     if (ERR_SUCC != code) {
*         // 修改自己的个人资料失败
*         return;
*     }
* }, nullptr);
*
* @note
* 修改自己的资料时，目前支持修改的字段请参考[UserProfileItem](TIMCloudDef.h)，一次可更新多个字段。修改自定义字段时填入的key值可以添加 Tag_Profile_Custom_ 前缀，也可以不添加 Tag_Profile_Custom_ 前缀，当不添加时，SDK内部会自动添加该前缀。
*/
TIM_DECL int TIMProfileModifySelfUserProfile(const char* json_modify_self_user_profile_param, TIMCommCallback cb, const void* user_data);
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      关系链相关接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 关系链相关接口
/// @brief 关系链介绍请参考 [关系链系统简介](https://cloud.tencent.com/document/product/269/1501#.E5.85.B3.E7.B3.BB.E9.93.BE.E7.B3.BB.E7.BB.9F.E7.AE.80.E4.BB.8B)
/// @{
/**
* @brief 8.1 获取好友列表
*
* @param cb 获取好友列表成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @note
* 此接口通过回调返回所有好友资料[FriendProfile](TIMCloudDef.h).
*/
TIM_DECL int TIMFriendshipGetFriendProfileList(TIMCommCallback cb, const void* user_data);

/**
* @brief 8.2 添加好友
*
* @param json_add_friend_param 添加好友接口参数的Json字符串
* @param cb 添加好友成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_add_friend_param;
* json_add_friend_param[kTIMFriendshipAddFriendParamIdentifier] = "user4";
* json_add_friend_param[kTIMFriendshipAddFriendParamFriendType] = FriendTypeBoth;
* json_add_friend_param[kTIMFriendshipAddFriendParamAddSource] = "Windows";
* json_add_friend_param[kTIMFriendshipAddFriendParamAddWording] = "I am Iron Man";
* int ret = TIMFriendshipAddFriend(json_add_friend_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     if (ERR_SUCC != code) {
*         // 添加好友失败
*         return;
*     }
* }, nullptr);
*
* @note
* 好友关系有单向和双向好友之分。详情请参考[添加好友](https://cloud.tencent.com/document/product/269/1501#.E6.B7.BB.E5.8A.A0.E5.A5.BD.E5.8F.8B).
*/
TIM_DECL int TIMFriendshipAddFriend(const char* json_add_friend_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 8.3 处理好友请求
*
* @param json_handle_friend_add_param 处理好友请求接口参数的Json字符串
* @param cb 处理好友请求成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_handle_friend_add_param;
* json_handle_friend_add_param[kTIMFriendResponeIdentifier] = "user1";
* json_handle_friend_add_param[kTIMFriendResponeAction] = ResponseActionAgreeAndAdd;
* json_handle_friend_add_param[kTIMFriendResponeRemark] = "I am Captain China";
* json_handle_friend_add_param[kTIMFriendResponeGroupName] = "schoolmate";
* int ret = TIMFriendshipHandleFriendAddRequest(json_handle_friend_add_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*
* }, nullptr);
*
* @note
* 当自己的个人资料的加好友权限 kTIMUserProfileAddPermission 设置为 kTIMProfileAddPermission_NeedConfirm 时，别人添加自己为好友时会收到一个加好友的请求，可通过此接口处理加好友的请求。
*/
TIM_DECL int TIMFriendshipHandleFriendAddRequest(const char* json_handle_friend_add_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 8.4 更新好友资料(备注等)
*
* @param json_modify_friend_info_param 更新好友资料接口参数的Json字符串
* @param cb 更新好友资料成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_modify_friend_profile_item;
* json_modify_friend_profile_item[kTIMFriendProfileItemRemark] = "xxxx yyyy";  // 修改备注
* json_modify_friend_profile_item[kTIMFriendProfileItemGroupNameArray].append("group1"); // 修改好友所在分组
* json_modify_friend_profile_item[kTIMFriendProfileItemGroupNameArray].append("group2");
*
* Json::Value json_modify_friend_profilie_custom;
* json_modify_friend_profilie_custom[kTIMFriendProfileCustemStringInfoKey] = "Str";
* json_modify_friend_profilie_custom[kTIMFriendProfileCustemStringInfoValue] = "this is changed value";
* json_modify_friend_profile_item[kTIMFriendProfileItemCustomStringArray].append(json_modify_friend_profilie_custom); // 修改好友资料自定义字段 "Str" 的值

* Json::Value json_modify_friend_info_param;
* json_modify_friend_info_param[kTIMFriendshipModifyFriendProfileParamIdentifier] = "user4";
* json_modify_friend_info_param[kTIMFriendshipModifyFriendProfileParamItem] = json_modify_friend_profile_item;
* int ret = TIMFriendshipModifyFriendProfile(json_modify_friend_info_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
* 
* }, nullptr);
*
* @note
* 修改好友资料，目前支持修改的字段请参考[FriendProfileItem](TIMCloudDef.h)，一次可修改多个字段。修改自定义字段时填入的key值可以添加 Tag_SNS_Custom_ 前缀，也可以不添加 Tag_SNS_Custom_ 前缀，当不添加时，SDK内部会自动添加该前缀。
*/
TIM_DECL int TIMFriendshipModifyFriendProfile(const char* json_modify_friend_info_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 8.5 删除好友
*
* @param json_delete_friend_param 删除好友接口参数的Json字符串
* @param cb 删除好友成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_delete_friend_param;
* json_delete_friend_param[kTIMFriendshipDeleteFriendParamIdentifierArray].append("user4");
* json_delete_friend_param[kTIMFriendshipDeleteFriendParamFriendType] = FriendTypeSignle;
* int ret = TIMFriendshipDeleteFriend(json_delete_friend_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     if (ERR_SUCC != code) {
*         // 删除好友失败
*         return;
*     }
* }, nullptr);
*
* @note
* 删除好友也有删除单向好友还是双向好友之分，[删除好友](https://cloud.tencent.com/document/product/269/1501#.E5.88.A0.E9.99.A4.E5.A5.BD.E5.8F.8B).
*/
TIM_DECL int TIMFriendshipDeleteFriend(const char* json_delete_friend_param, TIMCommCallback cb, const void* user_data);


/**
* @brief 8.6 检测好友类型(单向或双向)
*
* @param json_check_friend_list_param 检测好友接口参数的Json字符串
* @param cb 检测好友成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_check_friend_list_param;
* json_check_friend_list_param[kTIMFriendshipCheckFriendTypeParamCheckType] = FriendTypeBoth;
* json_check_friend_list_param[kTIMFriendshipCheckFriendTypeParamIdentifierArray].append("user4");
* int ret = TIMFriendshipCheckFriendType(json_check_friend_list_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*
* }, nullptr);
*
* @note
* 开发者可以通过此接口检测给定的 UserID 列表跟当前账户的好友关系，检测好友相关内容请参考 [检测好友](https://cloud.tencent.com/document/product/269/1501#.E6.A0.A1.E9.AA.8C.E5.A5.BD.E5.8F.8B)。
*/
TIM_DECL int TIMFriendshipCheckFriendType(const char* json_check_friend_list_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 8.7 创建好友分组
*
* @param json_create_friend_group_param 创建好友分组接口参数的Json字符串
* @param cb 创建好友分组成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_create_friend_group_param;
* json_create_friend_group_param[kTIMFriendshipCreateFriendGroupParamNameArray].append("Group123");
* json_create_friend_group_param[kTIMFriendshipCreateFriendGroupParamIdentifierArray].append("user4");
* json_create_friend_group_param[kTIMFriendshipCreateFriendGroupParamIdentifierArray].append("user10");
* int ret = TIMFriendshipCreateFriendGroup(json_create_friend_group_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     
* }, nullptr);
*
* @note
* 不能创建已存在的分组。
*/
TIM_DECL int TIMFriendshipCreateFriendGroup(const char* json_create_friend_group_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 8.8 获取指定好友分组的分组信息
*
* @param json_get_friend_group_list_param 获取好友分组信息接口参数的Json字符串
* @param cb 获取好友分组信息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_get_friend_group_list_param;
* json_get_friend_group_list_param.append("Group123");
* int ret = TIMFriendshipGetFriendGroupList(json_get_friend_group_list_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     
* }, nullptr);
*
*/
TIM_DECL int TIMFriendshipGetFriendGroupList(const char* json_get_friend_group_list_param, TIMCommCallback cb, const void* user_data);


/**
* @brief 8.9 修改好友分组
*
* @param json_modify_friend_group_param 修改好友分组接口参数的Json字符串
* @param cb 修改好友分组成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_modify_friend_group_param;
* json_modify_friend_group_param[kTIMFriendshipModifyFriendGroupParamName] = "Group123";
* json_modify_friend_group_param[kTIMFriendshipModifyFriendGroupParamNewName] = "GroupNewName";
* json_modify_friend_group_param[kTIMFriendshipModifyFriendGroupParamDeleteIdentifierArray].append("user4");
* json_modify_friend_group_param[kTIMFriendshipModifyFriendGroupParamAddIdentifierArray].append("user9");
* json_modify_friend_group_param[kTIMFriendshipModifyFriendGroupParamAddIdentifierArray].append("user5");
* int ret = TIMFriendshipModifyFriendGroup(json_modify_friend_group_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     
* }, nullptr);
*
*/
TIM_DECL int TIMFriendshipModifyFriendGroup(const char* json_modify_friend_group_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 8.10 删除好友分组
*
* @param json_delete_friend_group_param 删除好友分组接口参数的Json字符串
* @param cb 删除好友分组成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_delete_friend_group_param;
* json_delete_friend_group_param.append("GroupNewName");
* int ret = TIMFriendshipDeleteFriendGroup(json_delete_friend_group_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     
* }, nullptr);
*
*/
TIM_DECL int TIMFriendshipDeleteFriendGroup(const char* json_delete_friend_group_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 8.11 添加指定用户到黑名单
*
* @param json_add_to_blacklist_param 添加指定用户到黑名单接口参数的Json字符串
* @param cb 添加指定用户到黑名单成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_add_to_blacklist_param;
* json_add_to_blacklist_param.append("user5");
* json_add_to_blacklist_param.append("user10");
* int ret = TIMFriendshipAddToBlackList(json_add_to_blacklist_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     
* }, nullptr);
*
*/
TIM_DECL int TIMFriendshipAddToBlackList(const char* json_add_to_blacklist_param, TIMCommCallback cb, const void* user_data);


/**
* @brief 8.12 获取黑名单列表
*
* @param cb 获取黑名单列表成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
*/
TIM_DECL int TIMFriendshipGetBlackList(TIMCommCallback cb, const void* user_data);

/**
* @brief 8.13 从黑名单中删除指定用户列表
*
* @param json_delete_from_blacklist_param 从黑名单中删除指定用户接口参数的Json字符串
* @param cb 从黑名单中删除指定用户成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_delete_from_blacklist_param;
* json_delete_from_blacklist_param.append("user5");
* json_delete_from_blacklist_param.append("user10");
* int ret = TIMFriendshipDeleteFromBlackList(json_delete_from_blacklist_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     
* }, nullptr);
*
*/
TIM_DECL int TIMFriendshipDeleteFromBlackList(const char* json_delete_from_blacklist_param, TIMCommCallback cb, const void* user_data);


/**
* @brief 8.14 获取好友添加请求未决信息列表
*
* @param json_get_pendency_list_param 获取未决列表接口参数的Json字符串
* @param cb 获取未决列表成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_get_pendency_list_param;
* json_get_pendency_list_param[kTIMFriendshipGetPendencyListParamType] = FriendPendencyTypeBoth;
* json_get_pendency_list_param[kTIMFriendshipGetPendencyListParamStartSeq] = 0;
* int ret = TIMFriendshipGetPendencyList(json_get_pendency_list_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     
* }, nullptr);
*
* @note
* 好友添加请求未决信息是指好友添加请求未处理的操作。例如，开发者添加对方为好友，对方还没有处理；或者有人添加开发者为好友，开发者还没有处理，称之为好友添加请求未决信息
*/
TIM_DECL int TIMFriendshipGetPendencyList(const char* json_get_pendency_list_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 8.15 删除指定好友添加请求未决信息
*
* @param json_delete_pendency_param 删除指定未决信息接口参数的Json字符串
* @param cb 删除指定未决信息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
* Json::Value json_delete_pendency_param;
* json_delete_pendency_param[kTIMFriendshipDeletePendencyParamType] = FriendPendencyTypeComeIn;
* json_delete_pendency_param[kTIMFriendshipDeletePendencyParamIdentifierArray].append("user1");
* int ret = TIMFriendshipDeletePendency(json_delete_pendency_param.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_params, const void* user_data) {
*     
* }, nullptr);
*
*/
TIM_DECL int TIMFriendshipDeletePendency(const char* json_delete_pendency_param, TIMCommCallback cb, const void* user_data);

/**
* @brief 8.16 上报好友添加请求未决信息已读
*
* @param time_stamp 上报未决信息已读时间戳(单位秒)，填 0 默认会获取当前的时间戳
* @param cb 上报未决信息已读用户成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
* 
* @example
*  TIMFriendshipReportPendencyReaded(0, [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
*  }, nullptr);
*
*  json_param 为空字符串，判断 code 确认结果即可
*/
TIM_DECL int TIMFriendshipReportPendencyReaded(uint64_t time_stamp, TIMCommCallback cb, const void* user_data);
/// @}

/**
* @brief 8.17 搜索好友（5.4.666 及以上版本支持，需要您购买旗舰版套餐）
*
* @param json_search_friends_param 搜索好友的关键字和域，请参考 [FriendSearchParam](TIMCloudDef.h)
* @param cb 搜索好友的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
*   Json::Object json_obj;
*
*   Json::Array json_keyword_list;
*   Json_keyword_list.push_back("98826");
*   json_obj[kTIMFriendshipSearchParamKeywordList] = json_keyword_list;
*
*   json::Array json_search_field_list;
*   json_search_field_list.push_back(kTIMFriendshipSearchFieldKey_Identifier);
*   json_obj[kTIMFriendshipSearchParamSearchFieldList] = json_search_field_list;
*   TIMFriendshipSearchFriends(json_obj.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*
*   }, nullptr);
*
*   json_obj.toStyledString().c_str() 得到 JSON 字符串如下:
*   {
*       "friendship_search_param_keyword_list": ["98826"],
*       "friendship_search_param_search_field_list": [1]
*   }
*
*   // 回调的 json_param 示例。 json key 请参考 [FriendProfile](TIMCloudDef.h)
*   [{
*  "friend_profile_add_source": "AddSource_Type_contact",
*   "friend_profile_add_time": 1620786162,
*   "friend_profile_add_wording": "work together",
*   "friend_profile_custom_string_array": [{
*       "friend_profile_custom_string_info_key": "Tag_Profile_Custom_Str",
*       "friend_profile_custom_string_info_value": "test3-lamar-value"
*   }],
*   "friend_profile_group_name_array": ["friend1"],
*   "friend_profile_identifier": "98826",
*   "friend_profile_remark": "shoujihao",
*   "friend_profile_user_profile": {
*       "user_profile_add_permission": 1,
*       "user_profile_birthday": 2000,
*       "user_profile_custom_string_array": [{
*           "user_profile_custom_string_info_key": "Tag_Profile_Custom_Str",
*           "user_profile_custom_string_info_value": "test3-lamar-value"
*       }],
*       "user_profile_face_url": "test1-www.google.com",
*       "user_profile_gender": 2,
*       "user_profile_identifier": "98826",
*       "user_profile_language": 1000,
*       "user_profile_level": 3000,
*       "user_profile_location": "深圳",
*       "user_profile_nick_name": "test change8888",
*       "user_profile_role": 4000,
*       "user_profile_self_signature": "1111111"
*	}
}]
*/
TIM_DECL int TIMFriendshipSearchFriends(const char *json_search_friends_param, TIMCommCallback cb, const void* user_data);
/// @}

/**
* @brief 8.18 获取好友信息
*
* @param json_get_friends_info_param string array 获取好友的 userid 列表
* @param cb 获取好友信息的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example
*   Json::Array json_array;
*   Json_array.append("98826"); 
*   TIMFriendshipGetFriendsInfo(json_array.toStyledString().c_str(), [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*       printf("GetFriendsInfo code:%d|desc:%s|json_param %s\r\n", code, desc, json_param);
*   }, nullptr);
*
*   json_array.toStyledString().c_str() 得到 JSON 字符串如下:
*   ["98826"]
*
*   回调的 json_param 示例。 json key 请参考 [FriendInfoGetResult](TIMCloudDef.h)
*
*   [{
*   "friendship_friend_info_get_result_error_code": 0,
*   "friendship_friend_info_get_result_error_message": "OK",
*   "friendship_friend_info_get_result_field_info": {
*       "friend_profile_add_source": "AddSource_Type_contact",
*       "friend_profile_add_time": 1620786162,
*       "friend_profile_add_wording": "work together",
*       "friend_profile_custom_string_array": [{
*           "friend_profile_custom_string_info_key": "Tag_Profile_Custom_Str",
*           "friend_profile_custom_string_info_value": "test3-lamar-value"
*       }],
*       "friend_profile_group_name_array": ["friend1"],
*       "friend_profile_identifier": "98826",
*       "friend_profile_remark": "shoujihao",
*       "friend_profile_user_profile": {
*           "user_profile_add_permission": 1,
*           "user_profile_birthday": 2000,
*           "user_profile_custom_string_array": [{
*               "user_profile_custom_string_info_key": "Tag_Profile_Custom_Str",
*               "user_profile_custom_string_info_value": "test3-lamar-value"
*           }],
*           "user_profile_face_url": "test1-www.google.com",
*           "user_profile_gender": 2,
*           "user_profile_identifier": "98826",
*           "user_profile_language": 1000,
*           "user_profile_level": 3000,
*           "user_profile_location": "shenzhen",
*           "user_profile_nick_name": "test change8888",
*           "user_profile_role": 4000,
*           "user_profile_self_signature": "1111111"
*       }
*   },
*   "friendship_friend_info_get_result_relation_type": 3,
*   "friendship_friend_info_get_result_userid": "98826"
* }]
*/
TIM_DECL int TIMFriendshipGetFriendsInfo(const char *json_get_friends_info_param,  TIMCommCallback cb, const void* user_data);
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      实验性接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 实验性接口
/// @brief 实验性接口
/// @{
/**
 * @brief 9.1 实验性接口
 * 
 */
TIM_DECL int callExperimentalAPI(const char* json_param, TIMCommCallback cb, const void* user_data);
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      废弃接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 废弃接口
/// @brief 废弃接口
/// @{
/**
* @brief 4.1 创建会话
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param cb 创建会话的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
* @return int 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](TIMCloudDef.h)
*
* @example 获取对方UserID为Windows-02的单聊会话示例
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
* @example 获取群组ID为Windows-Group-01的群聊会话示例
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
* int ret = TIMMsgSendNewMsg(conv_id.c_str(), kTIMConv_C2C, json_value_msg.toStyledString().c_str(),
*     [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*     if (ERR_SUCC != code) {
*         // 消息发送失败
*         return;
*     }
*     // 消息发送成功
* }, this);
*
    * // json_value_msg.toStyledString().c_str() 得到 json_msg_param JSON 字符串如下
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
* >> 发送单聊消息时 conv_id 为对方的UserID， conv_type 为 kTIMConv_C2C 
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
* @brief 发送新消息
*
* @param conv_id   会话的ID
* @param conv_type 会话类型，请参考[TIMConvType](TIMCloudDef.h)
* @param json_msg_param  消息json字符串
* @param msgid_cb 返回消息 ID 的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
* @param res_cb 发送新消息成功与否的回调。回调函数定义请参考 [TIMCommCallback](TIMCloudCallback.h)
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
* int ret = TIMMsgSendNewMsgEx(conv_id.c_str(), kTIMConv_C2C, json_value_msg.toStyledString().c_str(), 
*    [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*         // 从 json_param 读取消息 ID
*    },
*    [](int32_t code, const char* desc, const char* json_param, const void* user_data) {
*         if (ERR_SUCC != code) {
*             // 消息发送失败
*             return;
*         }
*         // 消息发送成功
*     }，
* }, this);
*
* // json_value_msg.toStyledString().c_str() 得到 json_msg_param JSON 字符串如下
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
* >> 发送单聊消息时 conv_id 为对方的UserID， conv_type 为 kTIMConv_C2C 
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
TIM_DECL int TIMMsgSendNewMsgEx(const char* conv_id, enum TIMConvType conv_type, const char* json_msg_param, TIMCommCallback msgid_cb, TIMCommCallback res_cb, const void* user_data);
/// @}

#ifdef __cplusplus
}
#endif //__cplusplus

#endif //SRC_PLATFORM_CROSS_PLATFORM_INCLUDE_TIM_CLOUD_H_
