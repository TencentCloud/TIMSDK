/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：TIMManager  
//
//  模块功能：IMSDK 主核心模块，负责 IMSDK 的初始化、登录、创建会话、管理推送等功能。
//     
//  (1) 初始化：初始化是使用 TIMSDK 的前提，任何其它 API 的调用都应该在 initSdk 接口之后被调用。
//
//  (2) 登录：需要设置 SDKAppID，userID 和 userSig 才能使用腾讯云服务。
//
//  (3) 会话：一个会话对应一个聊天窗口，比如跟一个好友的 C2C 聊天，或者一个聊天群，都是一个会话。
//
//  (4) 推送：管理和设置 APNS 的相关功能，包括 token 和开关等。
//
/////////////////////////////////////////////////////////////////////


#ifndef ImSDK_TIMManager_h
#define ImSDK_TIMManager_h

#import "TIMComm.h"
#import "TIMCallback.h"

@class TIMGroupManager;
@class TIMFriendshipManager;


/**
 * IMSDK 主核心类，负责 IMSDK 的初始化、登录、创建会话、管理推送等功能。
 */
@interface TIMManager : NSObject

#pragma mark 一，初始化相关接口函数

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
 *  初始化 SDK 需要设置 TIMSdkConfig 信息，TIMSdkConfig 主要包含 sdkAppId 设置、Log 相关逻辑设置、数据库存储路径设置、网络监听设置等，
 *  其中 sdkAppId 的获取请参考官网文档 [跑通Demo(iOS与Mac)](https://cloud.tencent.com/document/product/269/32674)。
 *
 *  @param globalConfig 配置信息，全局有效，详情请参考 TIMComm.h 中的 TIMSdkConfig 定义。
 *  @return 0：成功；1：失败，config 为 nil
 */
- (int)initSdk:(TIMSdkConfig*)globalConfig;

/**
 *  1.3 反初始化
 */
- (void)unInit;

/**
 *  1.4 获取全局配置信息
 *
 *  @return 全局配置，详情请参考 TIMComm.h 中的 TIMSdkConfig 定义
 */
- (TIMSdkConfig*)getGlobalConfig;

/**
 *  1.5 设置用户配置信息
 *
 *  主要用来开启/关闭自动已读上报和已读回执，设置默认拉取的群组资料，群成员资料字段，监听用户登录状态、会话刷新、消息已读回执、文件上传进度、群组事件通知。
 *
 *  1. disableAutoReport 是否开启多终端同步未读提醒，这个选项主要影响多终端登录时的未读消息提醒逻辑。
 *        YES：只有当一个终端调用 setReadMessage() 将消息标记为已读，另一个终端再登录时才不会收到未读提醒；
 *         NO：消息一旦被一个终端接收，另一个终端都不会再次提醒。同理，卸载 APP 再安装也无法再次收到这些未读消息。
 *  2. enableReadReceipt 是否开启被阅回执，接收端设置，发送端才会生效。
 *        YES：接收者查看消息（setReadMessage）后，消息的发送者会收到 TIMMessageReceiptListener 的回调提醒；
 *         NO: 不开启被阅回执，默认不开启。
 *  3. groupInfoOpt 设置拉取群资料中的自定义字段。
 *  4. groupMemberInfoOpt 设置拉群成员资料中的自定义字段。
 *
 *  @note setUserConfig() 要在 initSdk() 之后 和 login() 之前调用。
 *
 *  @param config 配置信息，对当前 TIMManager 有效，详情请参考 TIMComm.h 中的 TIMUserConfig 定义
 *  @return 0:成功；1:失败，config 为 nil
 */
- (int)setUserConfig:(TIMUserConfig*)config;

/**
 *  1.6 获取用户配置信息
 *
 *  @return 当前 manager 绑定用户的配置，详情请参考 TIMComm.h 中的 TIMUserConfig 定义
 */
- (TIMUserConfig*)getUserConfig;

/**
 *  1.7 新消息接收监听
 *
 *  添加消息监听后，会在 TIMMessageListener 的 onNewMessage 收到回调消息，消息内容通过参数 TIMMessage 传递。
 *  消息的解析可参阅 [消息解析](https://cloud.tencent.com/document/product/269/9150#.E6.B6.88.E6.81.AF.E8.A7.A3.E6.9E.90) 。
 *
 *  @param listener 回调，详情请参考 TIMCallback.h 中的 TIMMessageListener 定义
 *  @return 0:成功；1:失败，listener 为 nil
 */
- (int)addMessageListener:(id<TIMMessageListener>)listener;

/**
 *  1.8 移除消息监听
 *
 *  @param listener 回调，详情请参考 TIMCallback.h 中的 TIMMessageListener 定义
 *  @return 0:成功；1:失败，listener 为 nil
 */
- (int)removeMessageListener:(id<TIMMessageListener>)listener;

/// @}

#pragma mark 二，登录相关接口
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
 *  1. 登录需要设置用户名 userID 和用户签名 userSig，userSig 生成请参 [UserSig 后台 API](https://cloud.tencent.com/document/product/269/32688)。
 *  2. 如果 userSig 过期，登录会返回 ERR_USER_SIG_EXPIRED：6206 错误码，收到错误码后请生成新的 userSig 重新登录。
 *  3. 用户在线情况下被踢，会在 TIMUserConfig 里面配置的 TIMUserStatusListener 监听器获取 onForceOffline 回调，收到回调后可以选择重新登录。
 *  4. 用户离线状态下被踢，会在用户重新登录时收到 (ERR_IMSDK_KICKED_BY_OTHERS：6208) 错误码，此时需要再次调用 login() 强制上线。
 *  
 *  更多详情请参考 [用户状态变更](https://cloud.tencent.com/document/product/269/9148#5.-.E7.94.A8.E6.88.B7.E7.8A.B6.E6.80.81.E5.8F.98.E6.9B.B4)。
 *
 *  @param param 登录参数，详情请参考 TIMComm.h 中的 TIMLoginParam 定义
 *  @param succ  成功回调，详情请参考 TIMComm.h 中的 TIMLoginSucc 定义
 *  @param fail  失败回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败，请检查 param 参数是否正常
 */
- (int)login: (TIMLoginParam*)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  2.2 自动登录
 *
 *  自动登录类似“记住密码”的功能，如果上一次已经成功登录，那么一段时间内都只需要传入用户名就可以完成登录。
 *  相比于普通的 login(TIMLoginParam) 接口，该接口可以减少 IM SDK 向您的服务器索要 UserSig 的频率，
 *  既可以加快登录速度，又能减少你的 UserSig 服务器压力，也在一定程度上降低了 UserSig 泄漏的风险。
 *
 *  1. 首次登录之后，SDK 会把登录信息存在在本地，下次登录即可调用自动登录
 *  2. 如果用户之前没有登录过，或则 APP 被卸载过，自动登录会报 ERR_NO_PREVIOUS_LOGIN：6026 错误，这个时候请调用 login 接口重新登录。
 *
 *  @param userID 自动登录用户名
 *  @param succ  成功回调，详情请参考 TIMComm.h 中的 TIMLoginSucc 定义
 *  @param fail  失败回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败，请检查 param 参数是否正常
 */
- (int)autoLogin:(NSString*)userID succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  2.3 登出
 *
 *  退出登录，如果切换账号，需要 logout 回调成功或者失败后才能再次 login，否则 login 可能会失败。
 *
 *  @param succ 成功回调，登出成功
 *  @param fail 失败回调，返回错误码和错误信息
 *
 *  @return 0：发送登出包成功，等待回调；1：失败
 */
- (int)logout:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  2.4 获取当前登录的用户
 *
 *  @return 如果登录返回用户的 userID，如果未登录返回 nil
 */
- (NSString*)getLoginUser;

/**
 *  2.5 获取当前登录状态
 *
 *  @return 登录状态，详情请参考 TIMComm.h 中的 TIMLoginStatus 定义
 */
- (TIMLoginStatus)getLoginStatus;

/// @}

#pragma mark 三，会话管理器
/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）会话管理器
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 会话管理器
/// @{

/**
 *  3.1 获取会话列表
 *
 *  一个会话对应一个聊天窗口，比如跟一个好友的 1v1 聊天，或者一个聊天群，都是一个会话。
 *
 *  @return 会话列表
 */
- (NSArray<TIMConversation *>*)getConversationList;

/**
 *  3.2 获取单个会话
 *
 *  TIMConversation 负责会话相关操作，包含发送消息、获取会话消息缓存、获取未读计数等。
 *
 *  @param type 详情请参考 TIMComm.h 里面的 TIMConversationType 定义
 *  @param conversationId 会话 ID
                          单聊类型（C2C）   ：为对方 userID；
                          群组类型（GROUP） ：为群组 groupId；
                          系统类型（SYSTEM）：为 @""
 *
 *  @return 会话对象，详情请参考 TIMConversation.h 里面的 TIMConversation 定义
 */
- (TIMConversation*)getConversation:(TIMConversationType)type receiver:(NSString*)conversationId;

/**
 *  3.3 删除单个会话
 *
 *  @param type 会话类型，详情请参考 TIMComm.h 里面的 TIMConversationType 定义
 *  @param conversationId 会话 Id
 *                        单聊类型（C2C）   ：为对方 userID；
 *                        群组类型（GROUP） ：为群组 groupId；
 *                        系统类型（SYSTEM）：为 @""
 *
 *  @return YES:删除成功；NO:删除失败
 */
- (BOOL)deleteConversation:(TIMConversationType)type receiver:(NSString*)conversationId;

/**
 *  3.4 删除单个会话和对应的会话消息
 *
 *  本接口与 deleteConversation() 的差异在于，deleteConversation() 只是删除单个会话，而本接口会额外把本地缓存的消息记录也一并删除掉。
 *  
 *  @note 本接口只能删除本地缓存的历史消息，无法删除云端保存的历史消息。
 *  @param type 会话类型，详情请参考 TIMComm.h 里面的 TIMConversationType 定义
 *  @param conversationId 会话 Id
 *                        单聊类型（C2C）   ：为对方 userID；
 *                        群组类型（GROUP） ：为群组 groupId；
 *                        系统类型（SYSTEM）：为 @""
 *
 *  @return YES:删除成功；NO:删除失败
 */
- (BOOL)deleteConversationAndMessages:(TIMConversationType)type receiver:(NSString*)conversationId;

/// @}

#pragma mark 四，设置 APNs 推送
/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）设置 APNs 推送
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 设置 APNs 推送
/// @{

/**
 *  4.1. 设置客户端 Token 和证书 busiId
 *
 *  token 是苹果后台对客户端的唯一标识，需要主动调用系统 API 向苹果请求获取，请求成功后，
 *  可以在 didRegisterForRemoteNotificationsWithDeviceToken 回调收到对应的 token 信息。
 *  具体实现见下面代码示例：
 *
 *  <pre>
 *
 *  //获取 token 代码示例
 *  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
 *    [[UIApplication sharedApplication] registerUserNotificationSettings:
 *        [UIUserNotificationSettings settingsForTypes:
 *            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
 *    [[UIApplication sharedApplication] registerForRemoteNotifications];
 *  }
 *  else{
 *    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
 *        (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
 *  }
 * 
 *  //收到 token 代码示例
 *  -(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
 *    //回调的 deviceToken 就是需要的 token 信息
 *  }
 *
 *  </pre>
 *
 *  busiId 是推送证书 ID，是向 IM 控制台上传 iOS 证书（p.12）生成的，
 *  具体步骤请参考 [离线推送](https://cloud.tencent.com/document/product/269/9154)。
 *
 *  @param token 详情请参考 TIMComm.h 中的 TIMTokenParam 定义
 *  @param succ 成功回调，详情请参考 TIMComm.h 中的 TIMSucc 定义
 *  @param fail 失败回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败，token 参数异常
 */
- (int)setToken:(TIMTokenParam*)token succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  4.2. 设置 APNS
 *
 *  设置 APNS，可设置单聊、群组推送声音，也可以设置是否开启推送。
 *
 *  @param config APNS 配置，详情请参考 TIMComm.h 中的 TIMAPNSConfig 定义
 *  @param succ   成功回调，详情请参考 TIMComm.h 中的 TIMSucc 定义
 *  @param fail   失败回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败，config 参数异常
 */
- (int)setAPNS:(TIMAPNSConfig*)config succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  4.3. 获取 APNS 配置
 *
 *  @param succ 成功回调，返回配置信息，详情请参考 TIMComm.h 中的 TIMAPNSConfigSucc 定义
 *  @param fail 失败回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败
 */
- (int)getAPNSConfig:(TIMAPNSConfigSucc)succ fail:(TIMFail)fail;

/**
 *  4.4. APP 进后台
 *
 *  APP 进后台的时候需要主动调用 doBackground ，这个时候后台知道 APP 的状态，之后的消息会下发推送通知。
 *
 *  <pre>
 *
 *  - (void)applicationDidEnterBackground:(UIApplication *)application {
 *     TIMBackgroundParam  *param = [[TIMBackgroundParam alloc] init];
 *     [param setC2cUnread:unReadCount];
 *     [[TIMManager sharedInstance] doBackground:param succ:^() {
 *        // to do
 *     } fail:^(int code, NSString * err) {
 *        // to do
 *     }];
 *  }
 *
 *  </pre>
 *
 *  @param param 上报参数，详情请参考 TIMComm.h 中的 TIMBackgroundParam 定义
 *  @param succ  成功时回调，详情请参考 TIMComm.h 中的 TIMSucc 定义
 *  @param fail  失败时回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败
 */
- (int)doBackground:(TIMBackgroundParam*)param succ:(TIMSucc)succ fail:(TIMFail)fail;


/**
 *  4.5. APP 进前台
 *
 *  APP 进前台的时候需要主动调用 doForeground，这个时候后台知道 APP 的状态，之后的消息不会下发推送通知。
 *
 *  <pre>
 *
 *  - (void)applicationDidBecomeActive:(UIApplication *)application {
 *     [[TIMManager sharedInstance] doForeground:^() {
 *        //to do
 *     } fail:^(int code, NSString * err) {
 *        //to do
 *     }];
 *  }
 *
 *  </pre>
 *
 *  @param succ  成功时回调，详情请参考 TIMComm.h 中的 TIMSucc 定义
 *  @param fail  失败时回调，详情请参考 TIMComm.h 中的 TIMFail 定义
 *
 *  @return 0:成功；1:失败
 */
- (int)doForeground:(TIMSucc)succ fail:(TIMFail)fail;

/// @}

#pragma mark 五，未登录查看本地会话和消息
/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）未登录查看本地会话和消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 未登录查看本地会话和消息
/// @{

/**
 *  5.1 在未登录的情况下加载本地存储
 *
 *  该接口相当于 login() 函数的无网络版本，适用于在用户没有网络（未登录）的情况下查看用户的本地会话和消息。
 *
 *  @note 如过已经 login() 成功，请不要调用此函数，否则会导致各种异常问题。
 *
 *  @param userID 用户名
 *  @param succ  成功回调，收到回调时，可以获取会话列表和消息
 *  @param fail  失败回调
 *  @return 0：加载成功；1：请求失败
 */
- (int)initStorage:(NSString*)userID succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

///@}

#pragma mark 六，调试相关接口
/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）调试相关接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 调试相关接口
/// @{

/**
 *  6.1 获取版本号
 *
 *  @return 返回版本号，字符串表示，例如 v1.1.1
 */
- (NSString*)GetVersion;

/**
 *  6.2 打印日志
 *
 *  通过 ImSDK 提供的日志功能打印日志
 *
 *  @param level 日志级别，详情请参考 TIMComm.h 中的 TIMLogLevel 定义
 *  @param tag   模块 tag
 *  @param msg   要输出的日志内容
 */
- (void)log:(TIMLogLevel)level tag:(NSString*)tag msg:(NSString*)msg;

/**
 *  6.3 获取日志文件路径
 */
- (NSString*)getLogPath;

/**
 *  6.4 获取日志打印开启状态
 *
 *  您可以在 initSdk -> TIMSdkConfig -> disableLogPrint 设置日志是否打印
 *
 * @return YES:允许 log 打印；NO:不允许 log 打印
 */
- (BOOL)getIsLogPrintEnabled;

/**
 *  6.5 获取日志级别
 *
 *  @return 返回日志级别，详情请参考 TIMComm.h 中的 TIMLogLevel 定义
 */
-(TIMLogLevel) getLogLevel;

///@}

@end
#endif
