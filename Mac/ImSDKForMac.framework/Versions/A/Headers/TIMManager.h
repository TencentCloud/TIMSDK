//
//  TIMManager.h
//  ImSDK
//
//  Created by bodeng on 28/1/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMManager_h
#define ImSDK_TIMManager_h

#import "TIMComm.h"
#import "TIMCallback.h"

@class TIMGroupManager;
@class TIMFriendshipManager;

/////////////////////////////////////////////////////////
///  Tencent 开放 SDK API
/////////////////////////////////////////////////////////

/**
 *  通讯管理
 */
@interface TIMManager : NSObject
	
/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）初始化相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 初始化相关接口
/// @{
/**
 *  1.1 获取管理器实例 TIMManager
 *
 *  @return 管理器实例
 */
+ (TIMManager*)sharedInstance;

/**
 *  1.2 初始化 SDK，设置全局配置信息
 *
 *  初始化 SDK 需要设置 TIMSdkConfig 信息，TIMSdkConfig 主要包含 sdkAppId 和 accountType 设置、Log 相关逻辑设置、数据库存储路径设置、网络监听设置等，其中 sdkAppId 和 accountType 的获取请参考官网文档 [跑通Demo(iOS与Mac)](https://cloud.tencent.com/document/product/269/32674)。
 *
 *  @param config 配置信息，全局有效，详情请参考 TIMComm.h 中的 TIMSdkConfig 定义
 *
 *  @return 0：成功；1：失败，config 为 nil
 */
- (int)initSdk:(TIMSdkConfig*)config;

/**
 *  1.3 获取全局配置信息
 *
 *  获取初始化 SDK 时候设置的 TIMSdkConfig，方便客户在上层做相关业务逻辑。
 *
 *  @return 全局配置，详情请参考 TIMComm.h 中的 TIMSdkConfig 定义
 */
- (TIMSdkConfig*)getGlobalConfig;

/**
 *  1.4 设置用户配置信息
 *
 *  1. setUserConfig 要在 initSdk 之后，login 之前，主要用来开启/关闭自动已读上报和已读回执，设置默认拉取的群组资料，群成员资料字段，监听用户登录状态、会话刷新、消息已读回执、文件上传进度、群组事件通知。
 *  2. 自动已读上报默认是开启的，当客户端收到一条未读消息后，Server 默认会删除这条未读消息，切换终端以后无法看到之前终端已经拉回的未读消息，如果需要多终端情况下仍然会有未读，请设置 TIMUserConfig 中的 disableAutoReport 为 YES，一旦禁用自动上报，开发者需要显式调用 setReadMessage,详情请参考官方文档 [未读消息计数](https://cloud.tencent.com/document/product/269/9151)。
 *  3. C2C 已读回执默认是关闭的，如果需要开启，请设置 TIMUserConfig 中的 enableReadReceipt 为 YES，收到消息的用户需要显式调用 setReadMessage，发消息的用户才能通过 TIMMessageReceiptListener 监听到消息的已读回执。
 *  4. 当您获取群资料的时候，默认只能拉取内置字段，如果想要拉取自定义字段，首先要通过 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 群维度自定义字段 配置相关的 key 和权限，然后把生成的 key 设置在 IMGroupInfoOption 里面的 groupCustom 字段。需要注意的是，只有对自定义字段 value 做了赋值或则修改，才能拉取到自定义字段。
 *  5. 当您获取群成员资料的时候，默认只能拉取内置字段，如果想要拉取自定义字段，首先要通过 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 群成员维度自定义字段配置相关的 key 和权限，然后把生成的 key 设置在 TIMGroupMemberInfoOption 里面的 memberCustom 字段。需要注意的是，只有对自定义字段的 value 做了赋值或则修改，才能拉取到自定义字段。
 *
 *  @param config 配置信息，对当前 TIMManager 有效，详情请参考 TIMComm.h 中的 TIMUserConfig 定义
 *
 *  @return 0:成功；1:失败，config 为 nil
 */
- (int)setUserConfig:(TIMUserConfig*)config;

/**
 *  1.5 获取用户配置信息
 *
 *  获取设置的用户配置信息 TIMSdkConfig，方便客户在上层做相关业务逻辑。
 *
 *  @return 当前 manager 绑定用户的配置，详情请参考 TIMComm.h 中的 TIMUserConfig 定义
 */
- (TIMUserConfig*)getUserConfig;

/**
 *  1.6 添加消息监听（重复添加无效）
 *
 *  添加消息监听后，会在 TIMMessageListener 的 onNewMessage 收到回调消息，消息内容通过参数 TIMMessage 传递，通过 TIMMessage 可以获取消息和相关会话的详细信息，如消息文本，语音数据，图片等。详细可参阅 [消息解析](https://cloud.tencent.com/document/product/269/9150#.E6.B6.88.E6.81.AF.E8.A7.A3.E6.9E.90) 部分。
 *
 *  @param listener 回调，详情请参考 TIMCallback.h 中的 TIMMessageListener 定义
 *
 *  @return 0:成功；1:失败，listener 为 nil
 */
- (int)addMessageListener:(id<TIMMessageListener>)listener;

/**
 *  1.7 移除消息监听
 *
 *  @param listener 回调，详情请参考 TIMCallback.h 中的 TIMMessageListener 定义
 *
 *  @return 0:成功；1:失败，listener 为 nil
 */
- (int)removeMessageListener:(id<TIMMessageListener>)listener;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）登录相关接口
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 登录相关接口
/// @{
/**
 *  2.1 登录
 *
 *  1. 登录需要设置用户名 identifier 和用户签名 userSig，userSig 的生成请参考官网文档 [UserSig 后台 API](https://cloud.tencent.com/document/product/269/32688)。
 *  2. 如果 userSig 过期，登录会返回 ERR_USER_SIG_EXPIRED：6206 错误码，收到错误码后请生成新的 userSig 重新登录。
 *  3. 用户在线情况下被踢，会在 TIMUserConfig 里面配置的 TIMUserStatusListener 监听器获取 onForceOffline 回调，收到回调后可以选择重新登录。
 *  4. 用户离线状态下被踢，由于此时用户不在线，无法感知此事件，为了显式提醒用户，用户重新登录时，会返回 ERR_IMSDK_KICKED_BY_OTHERS：6208 错误码，表明之前被踢，如果需要把对方踢下线，再次调用 login 强制上线，更多详情请参考 [用户状态变更](https://cloud.tencent.com/document/product/269/9148#5.-.E7.94.A8.E6.88.B7.E7.8A.B6.E6.80.81.E5.8F.98.E6.9B.B4)。
 *
 *  @param param 登陆参数，详情请参考 TIMComm.h 中的 TIMLoginParam 定义
 *  @param succ  成功回调，详情请参考 TIMComm.h 中的 TIMLoginSucc 定义
 *  @param fail  失败回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败，请检查 param 参数是否正常
 */
- (int)login: (TIMLoginParam*)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  2.2 自动登录
 *
 *  1. 首次登陆之后，SDK 会把登陆信息存在在本地，下次登陆即可调用自动登录
 *  2. 如果用户之前没有登录过，或则 APP 被卸载过，自动登录会报 ERR_NO_PREVIOUS_LOGIN：6026 错误，这个时候请调用 login 接口重新登录。
 *
 *  @param param 登陆参数（ userSig 不用填），详情请参考 TIMComm.h 中的 TIMLoginParam 定义
 *  @param succ  成功回调，详情请参考 TIMComm.h 中的 TIMLoginSucc 定义
 *  @param fail  失败回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败，请检查 param 参数是否正常
 */
- (int)autoLogin:(TIMLoginParam*)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  2.3 登出
 *
 *  退出登录，如果切换账号，需要 logout 回调成功或者失败后才能再次 login，否则 login 可能会失败。
 *
 *  @param succ 成功回调，登出成功
 *  @param fail 失败回调，返回错误吗和错误信息
 *
 *  @return 0：发送登出包成功，等待回调；1：失败
 */
- (int)logout:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  2.4 获取当前登陆的用户
 *
 *  @return 如果登陆返回用户的 identifier，如果未登录返回 nil
 */
- (NSString*)getLoginUser;

/**
 *  2.5 获取当前登录状态
 *
 *  @return 登录状态，详情请参考 TIMComm.h 中的 TIMLoginStatus 定义
 */
- (TIMLoginStatus)getLoginStatus;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）获取会话管理器
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 获取会话管理器
/// @{
/**
 *  获取会话管理器
 *
 *  TIMConversation 负责会话相关操作，包含发送消息、获取会话消息缓存、获取未读计数等。
 *
 *  @param type 会话类型，TIM_C2C：单聊；TIM_GROUP：群聊；TIM_SYSTEM：系统会话
 *  @param receiver 会话接收者，C2C：为对方用户；identifier；GROUP：群组 Id；SYSTEM：@""
 *
 *  @return 会话对象，详情请参考 TIMConversation.h 里面的 TIMConversation 定义
 */
- (TIMConversation*)getConversation:(TIMConversationType)type receiver:(NSString*)receiver;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）获取群管理器
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 获取群管理器
/// @{
/**
 *  获取群管理器
 *
 *  TIMGroupManager 负责创建群、增删成员、以及修改群资料等
 *
 *  @return 群管理器，详情请参考 TIMGroupManager.h 中的 TIMGroupManager 定义
 */
- (TIMGroupManager*)groupManager;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）获取好友管理器
//
/////////////////////////////////////////////////////////////////////////////////
///@name 获取好友管理器
/// @{
/**
 *  获取好友管理器
 *
 *  TIMFriendshipManager 负责加好友，删除好友，查询好友列表等
 *
 *  @return 好友管理器，详情请参考 TIMFriendshipManager.h 中的 TIMFriendshipManager 定义
 */
- (TIMFriendshipManager*)friendshipManager;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）设置 APNs 推送
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 设置 APNs 推送
/// @{
/**
 *  6.1. 设置客户端 Token 和证书 busiId
 *
 *  1. token 是向苹果后台请求 DeviceToken，具体实现请参考 appdelegate.h 里面的 registNotification。
 *  2. busiId 是向 IM 控制台上传 iOS 证书（p.12）生成的，具体步骤请参考 [离线推送](https://cloud.tencent.com/document/product/269/9154)。
 *
 *  @param token 详情请参考 TIMComm.h 中的 TIMTokenParam 定义
 *  @param succ 成功回调，详情请参考 TIMComm.h 中的 TIMSucc 定义
 *  @param fail 失败回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败，token 参数异常
 */
- (int)setToken:(TIMTokenParam*)token succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  6.2. 设置推送声音
 *
 *  不同用户可能想使用不同的推送声音，TIMAPNSConfig 提供了设置用户声音的字段，可实现单聊声音、群组声音的设置，也可在用户级别设置是否开启推送。
 *
 *  @param config APNS 配置，详情请参考 TIMComm.h 中的 TIMAPNSConfig 定义
 *  @param succ   成功回调，详情请参考 TIMComm.h 中的 TIMSucc 定义
 *  @param fail   失败回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败，config 参数异常
 */
- (int)setAPNS:(TIMAPNSConfig*)config succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  6.3. 获取推送声音设置
 *
 *  @param succ 成功回调，返回配置信息，详情请参考 TIMComm.h 中的 TIMAPNSConfigSucc 定义
 *  @param fail 失败回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败
 */
- (int)getAPNSConfig:(TIMAPNSConfigSucc)succ fail:(TIMFail)fail;

/**
 *  6.4. APP 进后台
 *
 *  APP 进后台的时候需要主动调用 doBackground ，这个时候后台知道 APP 的状态，之后的消息会下发推送通知。
 *
 *  @param param 上报参数，详情请参考 TIMComm.h 中的 TIMBackgroundParam 定义
 *  @param succ  成功时回调，详情请参考 TIMComm.h 中的 TIMSucc 定义
 *  @param fail  失败时回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败
 */
- (int)doBackground:(TIMBackgroundParam*)param succ:(TIMSucc)succ fail:(TIMFail)fail;


/**
 *  6.5. APP 进后台
 *
 *  APP 进前台的时候需要主动调用 doForeground。
 *
 *  @param succ  成功时回调，详情请参考 TIMComm.h 中的 TIMSucc 定义
 *  @param fail  失败时回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败
 */
- (int)doForeground:(TIMSucc)succ fail:(TIMFail)fail;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （七）多账号登录接口
//
/////////////////////////////////////////////////////////////////////////////////
///@name 多账号登录接口
/// @{
/**
 *  创建新的管理器类型（多用户登陆时使用，否则可直接调用 sharedInstance）
 *
 *  @return 管理器实例
 */
+ (TIMManager*)newManager;

/**
 *  获取管理器类型（多用户登陆时使用，否则可直接调用 sharedInstance）
 *
 *  @param identifier 用户 identifier
 *
 *  @return 对应管理器类型，如果没有创建过，返回 nil
 */
+ (TIMManager*)getManager:(NSString*)identifier;

/**
 *  销毁管理器（多用户登陆时使用，否则可直接调用 sharedInstance）
 *
 *  @param manager 需要销毁的管理器
 */
+ (void)deleteManager:(TIMManager*)manager;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （八）调试相关接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 调试相关接口
/// @{
/**
 * 获取网络状态
 *
 * @return 网络状态，详情请参考 TIMComm.h 中的 TIMNetworkStatus 定义
 */
- (TIMNetworkStatus)networkStatus;

/**
 *  设置环境（暂未实现）
 *
 *  在 InitSdk 之前调用，注意：除非是 IM 工作人员指定要求设置，否则不需要调用此接口
 *
 *  @param env 0:正式环境（默认）；1:测试环境
 *
 */
- (void)setEnv:(int)env;

/**
 *  获取环境类型（暂未实现）
 *
 *  @return env 0:正式环境（默认）；1:测试环境
 *
 */
- (int)getEnv;

/**
 *  获取版本号
 *
 *  @return 返回版本号，字符串表示，例如 v1.1.1
 */
- (NSString*)GetVersion;

/**
 *  打印日志，通过 ImSDK 提供的日志功能打印日志
 *
 *  @param level 日志级别，详情请参考 TIMComm.h 中的 TIMLogLevel 定义
 *  @param tag   模块 tag
 *  @param msg   要输出的日志内容
 */
- (void)log:(TIMLogLevel)level tag:(NSString*)tag msg:(NSString*)msg;

/**
 * 获取日志文件路径
 */
- (NSString*)getLogPath;

/**
 * 是否开启 sdk 日志打印
 *
 * @return YES:允许 log 打印；NO:不允许 log 打印
 */
- (BOOL)getIsLogPrintEnabled;

/**
 *  获取日志级别
 *
 *  @return 返回日志级别，详情请参考 TIMComm.h 中的 TIMLogLevel 定义
 */
-(TIMLogLevel) getLogLevel;

///@}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （九）废弃接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 废弃接口
/// @{
/**
 *  获取联网SDK的版本号 (方法已废弃, SDK 不再依赖 QAL 库)
 *
 *  @return 返回版本号
 */
- (NSString*)GetQALVersion;

///@}
@end
#endif
