/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：V2TIMManager
//
//  TIM SDK 2.0 版的接口，相比于 1.0 版本更加简洁易用，接入速度更快，高级特性接口详见：
//  - V2TIMManager+Message.h 消息相关的高级功能接口，比如图片消息，视频消息，消息撤回，消息已读等功能。
//  - V2TIMManager+APNS.h 推送相关的高级功能接口，主要用于开启消息推送功能。
//  - V2TIMManager+Conversation.h 会话相关的高级功能接口，一个会话对应一个聊天窗口。
//  - V2TIMManager+Group.h 群组相关的高级功能接口，比如邀请人进群，处理加群请求等功能。
//  - V2TIMManager+Friendship.h 关系链相关的高级功能接口，比如黑名单，好友列表等功能。
//  - V2TIMManager+Community.h 社群相关的高级功能接口，比如创建话题，话题列表等功能。
//
/////////////////////////////////////////////////////////////////////

#ifndef ImSDK_V2TIMManager_h
#define ImSDK_V2TIMManager_h

#if defined(BUILD_V2TIM_SDK)
#define V2TIM_EXPORT __attribute__((visibility("default")))
#else
#define V2TIM_EXPORT
#endif

#if defined(__cplusplus)
#define V2TIM_EXTERN extern "C" V2TIM_EXPORT
#else
#define V2TIM_EXTERN extern V2TIM_EXPORT
#endif

#import <Foundation/Foundation.h>
@class V2TIMSDKConfig;
@class V2TIMUserInfo;
@class V2TIMUserFullInfo;
@class V2TIMUserSearchParam;
@class V2TIMUserSearchResult;
@class V2TIMGroupMemberInfo;
@class V2TIMGroupMemberFullInfo;
@class V2TIMGroupChangeInfo;
@class V2TIMGroupMemberChangeInfo;
@class V2TIMUserReceiveMessageOptInfo;
@class V2TIMTopicInfo;
@class V2TIMUserStatus;
@class V2TIMReceiveMessageOptInfo;

V2TIM_EXPORT @protocol V2TIMSDKListener;
V2TIM_EXPORT @protocol V2TIMSimpleMsgListener;
V2TIM_EXPORT @protocol V2TIMGroupListener;

V2TIM_EXTERN NSString *const GroupType_Work;
V2TIM_EXTERN NSString *const GroupType_Public;
V2TIM_EXTERN NSString *const GroupType_Meeting;
V2TIM_EXTERN NSString *const GroupType_AVChatRoom;
V2TIM_EXTERN NSString *const GroupType_Community;

/////////////////////////////////////////////////////////////////////////////////
//
//                           V2TIMManager
//
//       IMSDK 主核心类，负责 IMSDK 的初始化、登录、消息收发，建群退群等功能
//
/////////////////////////////////////////////////////////////////////////////////


V2TIM_EXPORT @interface V2TIMManager : NSObject

/// 成功通用回调
typedef void (^V2TIMSucc)(void);
/// 失败通用回调
typedef void (^V2TIMFail)(int code, NSString * _Nullable desc);
/// 创建群组成功回调
typedef void (^V2TIMCreateGroupSucc)(NSString * _Nullable groupID);
/// 获取用户资料成功回调
typedef void (^V2TIMUserFullInfoListSucc)(NSArray <V2TIMUserFullInfo *> *infoList);
/// 搜索云端用户的结果回调
typedef void (^V2TIMUserSearchResultSucc)(V2TIMUserSearchResult *searchResult);
/// 实验性 API 接口成功回调
typedef void (^V2TIMCallExperimentalAPISucc)(NSObject * _Nullable result);
/// 获取用户状态列表成功回调
typedef void (^V2TIMUserStatusListSucc)(NSArray<V2TIMUserStatus *> *result);

/// 登录状态
typedef NS_ENUM(NSInteger, V2TIMLoginStatus) {
    V2TIM_STATUS_LOGINED                   = 1,  ///< 已登录
    V2TIM_STATUS_LOGINING                  = 2,  ///< 登录中
    V2TIM_STATUS_LOGOUT                    = 3,  ///< 无登录
};

/// 日志级别
typedef NS_ENUM(NSInteger, V2TIMLogLevel) {
    V2TIM_LOG_NONE                         = 0,  ///< 不输出任何 sdk log
    V2TIM_LOG_DEBUG                        = 3,  ///< 输出 DEBUG，INFO，WARNING，ERROR 级别的 log
    V2TIM_LOG_INFO                         = 4,  ///< 输出 INFO，WARNING，ERROR 级别的 log
    V2TIM_LOG_WARN                         = 5,  ///< 输出 WARNING，ERROR 级别的 log
    V2TIM_LOG_ERROR                        = 6,  ///< 输出 ERROR 级别的 log
};

/// 消息优先级
typedef NS_ENUM(NSInteger, V2TIMMessagePriority) {
    V2TIM_PRIORITY_DEFAULT                 = 0,  ///< 默认
    V2TIM_PRIORITY_HIGH                    = 1,  ///< 高优先级，一般用于礼物等重要消息
    V2TIM_PRIORITY_NORMAL                  = 2,  ///< 常规优先级，一般用于普通消息
    V2TIM_PRIORITY_LOW                     = 3,  ///< 低优先级，一般用于点赞消息
};

/// 性别
typedef NS_ENUM(NSInteger, V2TIMGender) {
    V2TIM_GENDER_UNKNOWN                   = 0,  ///< 未知性别
    V2TIM_GENDER_MALE                      = 1,  ///< 男性
    V2TIM_GENDER_FEMALE                    = 2,  ///< 女性
};

/// 好友验证方式
typedef NS_ENUM(NSInteger, V2TIMFriendAllowType) {
    V2TIM_FRIEND_ALLOW_ANY                 = 0, ///< 同意任何用户加好友
    V2TIM_FRIEND_NEED_CONFIRM              = 1, ///< 需要验证
    V2TIM_FRIEND_DENY_ANY                  = 2, ///< 拒绝任何人加好友
};

/// 群成员角色
typedef NS_ENUM(NSInteger, V2TIMGroupMemberRole) {
    V2TIM_GROUP_MEMBER_UNDEFINED           = 0,    ///< 未定义（没有获取该字段）
    V2TIM_GROUP_MEMBER_ROLE_MEMBER         = 200,  ///< 群成员
    V2TIM_GROUP_MEMBER_ROLE_ADMIN          = 300,  ///< 群管理员
    V2TIM_GROUP_MEMBER_ROLE_SUPER          = 400,  ///< 群主
};

/// 用户状态类型
typedef NS_ENUM(NSInteger, V2TIMUserStatusType) {
    V2TIM_USER_STATUS_UNKNOWN             = 0,  ///< 未知状态
    V2TIM_USER_STATUS_ONLINE              = 1,  ///< 在线状态
    V2TIM_USER_STATUS_OFFLINE             = 2,  ///< 离线状态
    V2TIM_USER_STATUS_UNLOGINED           = 3,  ///< 未登录（如主动调用 logout 接口，或者账号注册后还未登录）
};

/// 搜索关键字匹配类型
typedef NS_ENUM(NSInteger, V2TIMKeywordListMatchType) {
    V2TIM_KEYWORD_LIST_MATCH_TYPE_OR          = 0,
    V2TIM_KEYWORD_LIST_MATCH_TYPE_AND         = 1
};
    
/// 日志回调
typedef void (^V2TIMLogListener)(V2TIMLogLevel logLevel, NSString * _Nullable logContent);

/////////////////////////////////////////////////////////////////////////////////
//                               初始化
/////////////////////////////////////////////////////////////////////////////////

/**
 *  1.1 获取 V2TIMManager 管理器实例
 */
+ (V2TIMManager*)sharedInstance;
/**
 *  1.2 初始化 SDK
 *
 *  @param sdkAppID 应用 ID，必填项，可以在 [控制台](https://console.cloud.tencent.com/im) 中获取
 *  @param config 配置信息
 *  @return YES：成功；NO：失败
 */
- (BOOL)initSDK:(int)sdkAppID config:(V2TIMSDKConfig*)config;

/**
 *  1.3 添加 IM 监听
 */
- (void)addIMSDKListener:(id<V2TIMSDKListener>)listener NS_SWIFT_NAME(addIMSDKListener(listener:));

/**
 *  1.4 移除 IM 监听
 */
- (void)removeIMSDKListener:(id<V2TIMSDKListener>)listener NS_SWIFT_NAME(removeIMSDKListener(listener:));

/**
 *  1.5 反初始化 SDK
 */
- (void)unInitSDK;

/**
 *  1.6 获取版本号
 *
 *  @return 返回版本号，字符串表示，例如 5.0.10
 */
- (NSString*)getVersion;

/**
 *  1.7 获取服务器时间戳
 *
 *  @return UTC 时间戳，单位 s
 */
- (uint64_t)getServerTime;

/**
 *  初始化 SDK（待废弃接口，请使用 initSDK 和 addIMSDKListener 接口）
 */
- (BOOL)initSDK:(int)sdkAppID config:(V2TIMSDKConfig*)config listener:(_Nullable id<V2TIMSDKListener>)listener __attribute__((deprecated("use initSDK:config: and addIMSDKListener: instead")));

/////////////////////////////////////////////////////////////////////////////////
//                               登录登出
/////////////////////////////////////////////////////////////////////////////////

/**
 *  2.1 登录
 *
 *  登录需要设置用户名 userID 和用户签名 userSig，userSig 生成请参考 [UserSig 后台 API](https://cloud.tencent.com/document/product/269/32688)。
 *
 *  @note 请注意如下特殊逻辑:
 * - 登陆时票据过期：login 函数的 V2TIMFail 会返回 ERR_USER_SIG_EXPIRED（6206）或者 ERR_SVR_ACCOUNT_USERSIG_EXPIRED（70001） 错误码，此时请您生成新的 userSig 重新登录。
 * - 在线时票据过期：用户在线期间也可能收到 V2TIMSDKListener -> onUserSigExpired 回调，此时也是需要您生成新的 userSig 并重新登录。
 * - 在线时被踢下线：用户在线情况下被踢，SDK 会通过 V2TIMSDKListener -> onKickedOffline 回调通知给您，此时可以 UI 提示用户，并再次调用 login() 重新登录。
 * - 同平台多设备在线：该功能为IM旗舰版功能，购买[旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17487)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17224#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)。
 */
- (void)login:(NSString *)userID userSig:(NSString *)userSig succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(login(userID:userSig:succ:fail:));

/**
 *  2.2 登出
 *
 *  退出登录，如果切换账号，需要 logout 回调成功或者失败后才能再次 login，否则 login 可能会失败。
 */
- (void)logout:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(logout(succ:fail:));

/**
 *  2.3 获取登录用户
 */
- (NSString * _Nullable)getLoginUser;

/**
 *  2.4 获取登录状态
 *
 *  如果用户已经处于已登录和登录中状态，请勿再频繁调用登录接口登录。
 */
- (V2TIMLoginStatus)getLoginStatus;

/////////////////////////////////////////////////////////////////////////////////
//                         消息收发
/////////////////////////////////////////////////////////////////////////////////

/**
 *  3.1 设置基本消息（文本消息和自定义消息）的事件监听器
 *
 *  @note 图片消息、视频消息、语音消息等高级消息的监听，请参考 V2TIMManager+Message.h -> addAdvancedMsgListener 接口。
 */
- (void)addSimpleMsgListener:(id<V2TIMSimpleMsgListener>)listener NS_SWIFT_NAME(addSimpleMsgListener(listener:));

/**
 *  3.2 移除基本消息（文本消息和自定义消息）的事件监听器
 */
- (void)removeSimpleMsgListener:(id<V2TIMSimpleMsgListener>)listener NS_SWIFT_NAME(removeSimpleMsgListener(listener:));

/**
 *  3.3 发送单聊普通文本消息（最大支持 12KB）
 *
 *  文本消息支持云端的脏词过滤，如果用户发送的消息中有敏感词，V2TIMFail 回调将会返回 80001 错误码。
 *  @return 返回消息的唯一标识 ID
 *
 *  @note 该接口发送的消息默认会推送（前提是在 V2TIMManager+APNS.h 开启了推送），如果需要自定义推送（自定义推送声音，推送 Title 等），请调用 V2TIMManager+Message.h -> sendMessage 接口。
 */
- (NSString*)sendC2CTextMessage:(NSString *)text to:(NSString *)userID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(sendC2CTextMessage(text:to:succ:fail:));

/**
 *  3.4 发送单聊自定义（信令）消息（最大支持 12KB）
 *
 *  自定义消息本质就是一端二进制 buffer，您可以在其上自由组织自己的消息格式（常用于发送信令），但是自定义消息不支持云端敏感词过滤。
 *  @return 返回消息的唯一标识 ID
 *
 *  @note 该接口发送的消息默认不会推送，如果需要推送，请调用 V2TIMManager+Message.h -> sendMessage 接口。
 */
- (NSString*)sendC2CCustomMessage:(NSData *)customData to:(NSString *)userID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(sendC2CCustomMessage(customData:to:succ:fail:));

/**
 *  3.5 发送群聊普通文本消息（最大支持 12KB）
 *
 *  @param priority 设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
 *      - HIGH ：云端会优先传输，适用于在群里发送重要消息，比如主播发送的文本消息等。
 *      - NORMAL ：云端按默认优先级传输，适用于在群里发送普通消息，比如观众发送的弹幕消息等。
 *  @return 返回消息的唯一标识 ID
 *
 *  @note 该接口发送的消息默认会推送（前提是在 V2TIMManager+APNS.h 开启了推送），如果需要自定义推送（自定义推送声音，推送 Title 等），请调用 V2TIMManager+Message.h -> sendMessage 接口。
 */
- (NSString*)sendGroupTextMessage:(NSString *)text to:(NSString *)groupID priority:(V2TIMMessagePriority)priority succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(sendGroupTextMessage(text:to:priority:succ:fail:));

/**
 *  3.6 发送群聊自定义（信令）消息（最大支持 12KB）
 *
 *  @param priority 设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
 *      - HIGH ：云端会优先传输，适用于在群里发送重要信令，比如连麦邀请，PK邀请、礼物赠送等关键性信令。
 *      - NORMAL ：云端按默认优先级传输，适用于在群里发送非重要信令，比如观众的点赞提醒等等。
 *  @return 返回消息的唯一标识 ID
 *
 *  @note 该接口发送的消息默认不会推送，如果需要推送，请调用 V2TIMManager+Message.h -> sendMessage 接口。
 */
- (NSString*)sendGroupCustomMessage:(NSData *)customData to:(NSString *)groupID priority:(V2TIMMessagePriority)priority succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(sendGroupCustomMessage(customData:to:priority:succ:fail:));

//  3.7 更多功能，详见 V2TIMManager+Message.h

/////////////////////////////////////////////////////////////////////////////////
//                        群相关操作
/////////////////////////////////////////////////////////////////////////////////

/**
 *  4.1 设置群组监听器
 */
- (void)addGroupListener:(id<V2TIMGroupListener>)listener NS_SWIFT_NAME(addGroupListener(listener:));

/**
 *  4.2 设置群组监听器
 */
- (void)removeGroupListener:(id<V2TIMGroupListener>)listener NS_SWIFT_NAME(removeGroupListener(listener:));

/**
 *  4.3 创建群组
 *
 *  @param groupType 群类型，我们为您预定义好了几种常用的群类型，您也可以在控制台定义自己需要的群类型：
 *  - "Work"       ：工作群，成员上限 200  人，不支持由用户主动加入，需要他人邀请入群，适合用于类似微信中随意组建的工作群（对应老版本的 Private 群）。
 *  - "Public"     ：公开群，成员上限 2000 人，任何人都可以申请加群，但加群需群主或管理员审批，适合用于类似 QQ 中由群主管理的兴趣群。
 *  - "Meeting"    ：会议群，成员上限 6000 人，任何人都可以自由进出，且加群无需被审批，适合用于视频会议和在线培训等场景（对应老版本的 ChatRoom 群）。
 *  - "Community"  ：社群，成员上限 100000 人，任何人都可以自由进出，且加群无需被审批，适合用于知识分享和游戏交流等超大社区群聊场景。5.8 版本开始支持，需要您购买旗舰版套餐。
 *  - "AVChatRoom" ：直播群，人数无上限，任何人都可以自由进出，消息吞吐量大，适合用作直播场景中的高并发弹幕聊天室。
 *
 *  @param groupID 自定义群组 ID，可以传 nil。传 nil 时系统会自动分配 groupID，并通过 succ 回调返回。
 *                 "Community" 类型自定义群组 ID 必须以 "@TGS#_" 作为前缀。
 *  @param groupName 群名称，不能为 nil，最长 100 字节，使用 UTF-8 编码，1 个汉字占 3 个字节。
 *
 *  @note 请注意如下特殊逻辑:
 *  - 不支持在同一个 SDKAPPID 下创建两个相同 groupID 的群。
 *  - 社群（Community）功能仅 5.8.1668 增强版及以上版本支持，需[购买旗舰版或企业版套餐包](https://buy.cloud.tencent.com/avc?from=17213)并在 [控制台](https://console.cloud.tencent.com/im) -> 功能配置 -> 群组配置 -> 群功能配置 -> 社群 打开开关后方可使用。
 *  - 直播群（AVChatRoom）：在进程重启或重新登录之后，如果想继续接收直播群的消息，请您调用 joinGroup 重新加入直播群。
 */
- (void)createGroup:(NSString *)groupType groupID:(NSString* _Nullable)groupID groupName:(NSString *)groupName succ:(V2TIMCreateGroupSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(createGroup(groupType:groupID:groupName:succ:fail:));

/**
 *  4.4 加入群组
 *
 *  @note 请注意如下特殊逻辑:
 *  - 工作群（Work）：不能主动入群，只能通过群成员调用 V2TIMManager+Group.h -> inviteUserToGroup 接口邀请入群。
 *  - 公开群（Public）：申请入群后，需要管理员审批，管理员在收到 V2TIMGroupListener -> onReceiveJoinApplication 回调后调用 V2TIMManager+Group.h -> getGroupApplicationList 接口处理加群请求。
 *  - 其他群：可以直接入群。
 *  - 直播群（AVChatRoom）：在进程重启或重新登录之后，如果想继续接收直播群的消息，请您调用 joinGroup 重新加入直播群。
 *  - 直播群（AVChatRoom）：直播群新成员可以查看入群前消息，该功能为 IM 旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17484)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17179#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)
 */
- (void)joinGroup:(NSString*)groupID msg:(NSString* _Nullable)msg succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(joinGroup(groupID:msg:succ:fail:));

/**
 *  4.5 退出群组
 *
 *  @note 在公开群（Public）、会议（Meeting）和直播群（AVChatRoom）中，群主是不可以退群的，群主只能调用 dismissGroup 解散群组。
 */
- (void)quitGroup:(NSString*)groupID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(quitGroup(groupID:succ:fail:));

/**
 *  4.6 解散群组
 *
 *  @note 请注意如下特殊逻辑:
 *  - 好友工作群（Work）的解散最为严格，即使群主也不能随意解散，只能由您的业务服务器调用 [解散群组 REST API](https://cloud.tencent.com/document/product/269/1624) 解散。
 *  - 其他类型群的群主可以解散群组。
 */
- (void)dismissGroup:(NSString*)groupID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(dismissGroup(groupID:succ:fail:));

//  4.7 更多功能，详见 V2TIMManager+Group.h

/**
 *  设置群组监听器（待废弃接口，请使用 addGroupListener 和 removeGroupListener 接口）
 */
- (void)setGroupListener:(id<V2TIMGroupListener>)listener __attribute__((deprecated("use addGroupListener: instead")));

/////////////////////////////////////////////////////////////////////////////////
//                        资料相关操作
/////////////////////////////////////////////////////////////////////////////////

/**
 *  5.1 获取用户资料
 *  @note
 *  - 获取自己的资料，传入自己的 ID 即可。
 *  - userIDList 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
 */
- (void)getUsersInfo:(NSArray<NSString *> *)userIDList succ:(V2TIMUserFullInfoListSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.2 修改个人资料
 */
- (void)setSelfInfo:(V2TIMUserFullInfo *)Info succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setSelfInfo(info:succ:fail:));

/**
 *  5.3 订阅用户资料，从 7.4 版本开始支持
 *
 *  @param userIDList 待订阅的用户 ID
 *
 *  @note
 *   - 该接口用于订阅陌生人的资料变更事件，订阅成功后，当订阅用户资料发生变更，您可以通过监听 onUserInfoChanged 回调来感知
 *   - 订阅列表最多允许订阅 200 个，超过限制后，会自动淘汰最先订阅的用户
 *   - 自己的资料变更通知不需要订阅，默认会通过 onSelfInfoUpdated 回调通知给您
 *   - 好友的资料变更通知不需要订阅，默认会通过 onFriendInfoChange 回调通知给您
 *   - 该功能为 IM 旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17491)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17472#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)。
 */
- (void)subscribeUserInfo:(NSArray *)userIDList succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(subscribeUserInfo(userIDList:succ:fail:));

/**
 *  5.4 取消订阅用户资料，从 7.4 版本开始支持
 *
 *  @param userIDList 需要取消订阅的用户 ID
 * 
 *  @note
 *   - 当 userIDList 为空时，取消当前所有的订阅
 *   - 该功能为 IM 旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17491)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17472#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)。
 */
- (void)unsubscribeUserInfo:(NSArray * _Nullable)userIDList succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(unsubscribeUserInfo(userIDList:succ:fail:));

/**
 *  5.5 搜索云端用户资料（8.4 及以上版本支持）
 * @param searchParam 用户搜索参数，详见 V2TIMUserSearchParam 的定义
 * @note
 * - 该功能为 IM 增值功能，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17176#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)
 * - 如果您没有开通该服务，调用接口会返回 60020 错误码
 * - 该接口返回的是云端存储的用户资料，包括好友和非好友资料，您可以调用 checkFriend 接口来判断是否为好友。
*/
- (void)searchUsers:(V2TIMUserSearchParam *)searchParam succ:(V2TIMUserSearchResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(searchUsers(searchParam:succ:fail:));


/**
 *  5.6 查询用户状态，从 6.3 版本开始支持
 *
 *  @param userIDList 需要获取的用户 ID
 *
 *  @note
 *  - 如果您想查询自己的自定义状态，您只需要传入自己的 userID 即可
 *  - 当您批量查询时，接口只会返回查询成功的用户状态信息；当所有用户均查询失败时，接口会报错
 *  - 查询其他用户状态为 IM 旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17491)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17472#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)。
 */
- (void)getUserStatus:(NSArray *)userIDList succ:(V2TIMUserStatusListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getUserStatus(userIDList:succ:fail:));

/**
 *  5.7 设置自己的状态，从 6.3 版本开始支持
 *
 *  @param status 待设置的自定义状态
 *
 *  @note 该接口只支持设置自己的自定义状态，即 V2TIMUserStatus.customStatus
 */
- (void)setSelfStatus:(V2TIMUserStatus *)status succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setSelfStatus(status:succ:fail:));

/**
 *  5.8 订阅用户状态，从 6.3 版本开始支持
 *
 *  @param userIDList 待订阅的用户 ID
 *
 *  @note
 *   - 当成功订阅用户状态后，当对方的状态（包含在线状态、自定义状态）发生变更后，您可以监听 @onUserStatusChanged 回调来感知
 *   - 如果您需要订阅好友列表的状态，您只需要在控制台上打开开关即可，无需调用该接口
 *   - 该接口不支持订阅自己，您可以通过监听 @onUserStatusChanged 回调来感知自身的自定义状态的变更
 *   - 订阅列表最多允许订阅 200 个，超过限制后，会自动淘汰最先订阅的用户
 *   - 该功能为 IM 旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17491)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17472#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)。
 */
- (void)subscribeUserStatus:(NSArray *)userIDList succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(subscribeUserStatus(userIDList:succ:fail:));

/**
 *  5.9 取消订阅用户状态，从 6.3 版本开始支持
 *
 *  @note
 *   - 当 userIDList 为空或者 nil 时，取消当前所有的订阅
 *   - 该功能为 IM 旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17491)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17472#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)。
 */
- (void)unsubscribeUserStatus:(NSArray * _Nullable)userIDList succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(unsubscribeUserStatus(userIDList:succ:fail:));

//  5.10 更多功能，详见 V2TIMManager+Friendship.h

/////////////////////////////////////////////////////////////////////////////////
//                        扩展接口
/////////////////////////////////////////////////////////////////////////////////

/**
 * 6.1 实验性 API 接口
 *
 * @param api 接口名称
 * @param param 接口参数
 *
 * @note 该接口提供一些实验性功能
 */
- (void)callExperimentalAPI:(NSString *)api
                      param:(NSObject * _Nullable)param
                       succ:(V2TIMCallExperimentalAPISucc)succ
                       fail:(V2TIMFail)fail NS_SWIFT_NAME(callExperimentalAPI(api:param:succ:fail:));
@end

/////////////////////////////////////////////////////////////////////////////////
//
//       IMSDK 主核心回调，帮助您时刻关注 IMSDK 的在线状态
//
/////////////////////////////////////////////////////////////////////////////////
/// IMSDK 主核心回调
V2TIM_EXPORT @protocol V2TIMSDKListener <NSObject>
@optional
/// SDK 正在连接到服务器
- (void)onConnecting;

/// SDK 已经成功连接到服务器
- (void)onConnectSuccess;

/// SDK 连接服务器失败
- (void)onConnectFailed:(int)code err:(NSString* _Nullable)err;

/// 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onKickedOffline;

/// 在线时票据过期：此时您需要生成新的 userSig 并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onUserSigExpired;

/// 当前用户的资料发生了更新
- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info NS_SWIFT_NAME(onSelfInfoUpdated(info:));

/**
 * 用户状态变更通知
 *
 * @note 收到通知的情况：
 * 1. 订阅过的用户发生了状态变更（包括在线状态和自定义状态），会触发该回调
 * 2. 在 IM 控制台打开了好友状态通知开关，即使未主动订阅，当好友状态发生变更时，也会触发该回调
 * 3. 同一个账号多设备登录，当其中一台设备修改了自定义状态，所有设备都会收到该回调
 */
- (void)onUserStatusChanged:(NSArray<V2TIMUserStatus *> *)userStatusList NS_SWIFT_NAME(onUserStatusChanged(userStatusList:));

/**
 * 用户资料变更通知
 * 
 * @note
 * 仅当通过 subscribeUserInfo 成功订阅的用户（仅限非好友用户）的资料发生变更时，才会激活此回调函数
 */
- (void)onUserInfoChanged:(NSArray<V2TIMUserFullInfo *> *)userInfoList NS_SWIFT_NAME(onUserInfoChanged(userInfoList:));

/**
 * 全局消息接收选项变更通知
 */
- (void)onAllReceiveMessageOptChanged:(V2TIMReceiveMessageOptInfo *)receiveMessageOptInfo NS_SWIFT_NAME(onAllReceiveMessageOptChanged(receiveMessageOptInfo:));

/**
 * 实验性事件通知
 */
- (void)onExperimentalNotify:(NSString *)key param:(NSObject * _Nullable)param NS_SWIFT_NAME(onExperimentalNotify(key:param:));
@end

/////////////////////////////////////////////////////////////////////////////////
//
//       IMSDK 基本消息回调 （高级消息请参考 V2TIMManager+Message.h -> V2TIMAdvancedMsgListener）
//
/////////////////////////////////////////////////////////////////////////////////
/// IMSDK 基本消息回调
V2TIM_EXPORT @protocol V2TIMSimpleMsgListener <NSObject>
@optional

/// 收到 C2C 文本消息
- (void)onRecvC2CTextMessage:(NSString *)msgID  sender:(V2TIMUserInfo *)info text:(NSString * _Nullable)text NS_SWIFT_NAME(onRecvC2CTextMessage(msgID:sender:text:));

/// 收到 C2C 自定义（信令）消息
- (void)onRecvC2CCustomMessage:(NSString *)msgID  sender:(V2TIMUserInfo *)info customData:(NSData * _Nullable)data NS_SWIFT_NAME(onRecvC2CCustomMessage(msgID:sender:customData:));

/// 收到群文本消息
- (void)onRecvGroupTextMessage:(NSString *)msgID groupID:(NSString * _Nullable)groupID sender:(V2TIMGroupMemberInfo *)info text:(NSString * _Nullable)text NS_SWIFT_NAME(onRecvGroupTextMessage(msgID:groupID:sender:text:));

/// 收到群自定义（信令）消息
- (void)onRecvGroupCustomMessage:(NSString *)msgID groupID:(NSString * _Nullable)groupID sender:(V2TIMGroupMemberInfo *)info customData:(NSData * _Nullable)data NS_SWIFT_NAME(onRecvGroupCustomMessage(msgID:groupID:sender:customData:));
@end

/////////////////////////////////////////////////////////////////////////////////
//
//       IMSDK 群组事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/// IMSDK 群组事件回调
V2TIM_EXPORT @protocol V2TIMGroupListener <NSObject>
@optional

/////////////////////////////////////////////////////////////////////////////////
//        群成员相关通知
/////////////////////////////////////////////////////////////////////////////////

/// 有新成员加入群（该群所有的成员都能收到)
/// 会议群（Meeting）默认无此回调，如需回调，请前往 [控制台](https://console.cloud.tencent.com/im) (功能配置 -> 群组配置 -> 群系统通知配置 -> 群成员变更通知) 主动配置。
- (void)onMemberEnter:(NSString * _Nullable)groupID memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList NS_SWIFT_NAME(onMemberEnter(groupID:memberList:));

/// 有成员离开群（该群所有的成员都能收到)
/// 会议群（Meeting）默认无此回调，如需回调，请前往 [控制台](https://console.cloud.tencent.com/im) (功能配置 -> 群组配置 -> 群系统通知配置 -> 群成员变更通知) 主动配置。
- (void)onMemberLeave:(NSString * _Nullable)groupID member:(V2TIMGroupMemberInfo *)member NS_SWIFT_NAME(onMemberLeave(groupID:member:));

/// 某成员被拉入某群（该群所有的成员都能收到）
- (void)onMemberInvited:(NSString * _Nullable)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList NS_SWIFT_NAME(onMemberInvited(groupID:opUser:memberList:));

/// 有成员被踢出某群（该群所有的成员都能收到）
- (void)onMemberKicked:(NSString * _Nullable)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList NS_SWIFT_NAME(onMemberKicked(groupID:opUser:memberList:));

/// 某成员信息发生变更（该群所有的成员都能收到）
/// 会议群（Meeting）和直播群（AVChatRoom）默认无此回调，如需回调，请前往 [控制台](https://console.cloud.tencent.com/im) (功能配置 -> 群组配置 -> 群系统通知配置 -> 群成员资料变更通知) 主动配置。
- (void)onMemberInfoChanged:(NSString * _Nullable)groupID changeInfoList:(NSArray <V2TIMGroupMemberChangeInfo *> *)changeInfoList NS_SWIFT_NAME(onMemberInfoChanged(groupID:changeInfoList:));

/// 群组全体成员被禁言/解除禁言了（该群所有的成员都能收到）
/// 需要提前在 [控制台](https://console.cloud.tencent.com/im) 开启通知开关。开关路径：功能配置 -> 群组配置 -> 群系统通知配置 -> 群资料变更通知 -> 群禁言变更通知。
/// 7.5 及以上版本支持。
- (void)onAllGroupMembersMuted:(NSString * _Nullable)groupID isMute:(BOOL)isMute NS_SWIFT_NAME(onAllGroupMembersMuted(groupID:isMute:));

/// 有成员被标记（该群所有的成员都能收到）
/// 仅社群（Community）支持该回调。
/// 7.5 及以上版本支持，需要您购买旗舰版套餐。
- (void)onMemberMarkChanged:(NSString * _Nullable)groupID memberIDList:(NSArray<NSString *> *)memberIDList markType:(int)markType enableMark:(BOOL)enableMark NS_SWIFT_NAME(onMemberMarkChanged(groupID:memberIDList:markType:enableMark:));

/////////////////////////////////////////////////////////////////////////////////
//        群生命周期相关通知
/////////////////////////////////////////////////////////////////////////////////

/// 有新的群创建（创建者能收到，应用于多端消息同步的场景）
- (void)onGroupCreated:(NSString * _Nullable)groupID NS_SWIFT_NAME(onGroupCreated(groupID:));

/// 某个已加入的群被解散了（该群所有的成员都能收到）
- (void)onGroupDismissed:(NSString * _Nullable)groupID opUser:(V2TIMGroupMemberInfo *)opUser NS_SWIFT_NAME(onGroupDismissed(groupID:opUser:));

/// 某个已加入的群被回收了（该群所有的成员都能收到）
- (void)onGroupRecycled:(NSString * _Nullable)groupID opUser:(V2TIMGroupMemberInfo *)opUser NS_SWIFT_NAME(onGroupRecycled(groupID:opUser:));

/// 某个已加入的群的信息被修改了（该群所有的成员都能收到）
/// 以下字段的修改可能会引发该通知 groupName & introduction & notification & faceUrl & owner & allMute & custom
/// 控制指定字段 下发通知/存漫游 请前往 [控制台](https://console.cloud.tencent.com/im) (功能配置 -> 群组配置 -> 群系统通知配置 -> 群资料变更通知) 主动配置。
- (void)onGroupInfoChanged:(NSString * _Nullable)groupID changeInfoList:(NSArray <V2TIMGroupChangeInfo *> *)changeInfoList NS_SWIFT_NAME(onGroupInfoChanged(groupID:changeInfoList:));

/// 某个已加入的群的属性被修改了，会返回所在群组的所有属性（该群所有的成员都能收到）
- (void)onGroupAttributeChanged:(NSString *)groupID attributes:(NSMutableDictionary<NSString *,NSString *> *)attributes;

/// 某个已加入的群的计数器被修改了，会返回当前变更的群计数器（该群所有的成员都能收到）
- (void)onGroupCounterChanged:(NSString * _Nullable)groupID key:(NSString *)key newValue:(NSInteger)newValue NS_SWIFT_NAME(onGroupCounterChanged(groupID:key:newValue:));

/////////////////////////////////////////////////////////////////////////////////
//        加群申请相关通知
/////////////////////////////////////////////////////////////////////////////////

/// 有新的加群请求（只有群主和管理员会收到）
- (void)onReceiveJoinApplication:(NSString * _Nullable)groupID member:(V2TIMGroupMemberInfo *)member opReason:(NSString * _Nullable)opReason NS_SWIFT_NAME(onReceiveJoinApplication(groupID:member:opReason:));

/// 加群或者邀请加群请求已经被群主或管理员处理了（只有申请人能够收到）
- (void)onApplicationProcessed:(NSString * _Nullable)groupID opUser:(V2TIMGroupMemberInfo *)opUser opResult:(BOOL)isAgreeJoin opReason:(NSString * _Nullable)opReason NS_SWIFT_NAME(onApplicationProcessed(groupID:opUser:opResult:opReason:));

/////////////////////////////////////////////////////////////////////////////////
//        其他相关通知
/////////////////////////////////////////////////////////////////////////////////

/// 指定管理员身份
- (void)onGrantAdministrator:(NSString * _Nullable)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList NS_SWIFT_NAME(onGrantAdministrator(groupID:opUser:memberList:));

/// 取消管理员身份
- (void)onRevokeAdministrator:(NSString * _Nullable)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList NS_SWIFT_NAME(onRevokeAdministrator(groupID:opUser:memberList:));

/// 自己主动退出群组（主要用于多端同步）
- (void)onQuitFromGroup:(NSString * _Nullable)groupID NS_SWIFT_NAME(onQuitFromGroup(groupID:));

/// 收到 RESTAPI 下发的自定义系统消息
- (void)onReceiveRESTCustomData:(NSString * _Nullable)groupID data:(NSData * _Nullable)data NS_SWIFT_NAME(onReceiveRESTCustomData(groupID:data:));

/////////////////////////////////////////////////////////////////////////////////
//             话题事件监听回调
/////////////////////////////////////////////////////////////////////////////////
/// 话题创建回调
- (void)onTopicCreated:(NSString * _Nullable)groupID topicID:(NSString * _Nullable)topicID NS_SWIFT_NAME(onTopicCreated(groupID:topicID:));

/// 话题被删除回调
- (void)onTopicDeleted:(NSString * _Nullable)groupID topicIDList:(NSArray<NSString *> *)topicIDList NS_SWIFT_NAME(onTopicDeleted(groupID:topicIDList:));

/// 话题更新回调
- (void)onTopicChanged:(NSString * _Nullable)groupID topicInfo:(V2TIMTopicInfo *)topicInfo NS_SWIFT_NAME(onTopicChanged(groupID:topicInfo:));

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         用户资料
//
/////////////////////////////////////////////////////////////////////////////////
/// 用户基本资料
V2TIM_EXPORT @interface V2TIMUserInfo : NSObject
/// 用户 ID
@property(nonatomic,strong,readonly,nullable) NSString* userID;

/// 用户昵称
@property(nonatomic,strong,nullable) NSString* nickName;

/// 用户头像
@property(nonatomic,strong,nullable) NSString* faceURL;
@end

/// 用户详细资料
V2TIM_EXPORT @interface V2TIMUserFullInfo : V2TIMUserInfo

/// 用户签名
@property(nonatomic,strong,nullable) NSString *selfSignature;

/// 用户性别
@property(nonatomic,assign) V2TIMGender gender;

/// 用户角色
@property(nonatomic,assign) uint32_t role;

/// 用户等级
@property(nonatomic,assign) uint32_t level;

/// 出生日期
@property(nonatomic,assign) uint32_t birthday;

/// 用户好友验证方式
@property(nonatomic,assign) V2TIMFriendAllowType allowType;

/// 用户自定义字段
/// 首先要在 [控制台](https://console.cloud.tencent.com/im) (功能配置 -> 用户自定义字段) 配置用户自定义字段，然后再调用该接口进行设置，key 值不需要加 Tag_Profile_Custom_ 前缀。
@property(nonatomic,strong,nullable) NSDictionary<NSString *,NSData *> * customInfo;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                    用户搜索
//
/////////////////////////////////////////////////////////////////////////////////

V2TIM_EXPORT @interface V2TIMUserSearchParam : NSObject
/// 搜索的关键字列表，关键字列表最多支持 5 个，keyword 会自动匹配用户 ID、昵称。
@property(nonatomic, strong,nullable) NSArray<NSString *> *keywordList;

/// 指定关键字列表匹配类型，可设置为“或”关系搜索或者“与”关系搜索。
/// 取值分别为 V2TIM_KEYWORD_LIST_MATCH_TYPE_OR 和 V2TIM_KEYWORD_LIST_MATCH_TYPE_AND，默认为“或”关系搜索。
@property(nonatomic,assign) V2TIMKeywordListMatchType keywordListMatchType;

/// 用户性别（如果不设置，默认男性和女性都会返回）
@property(nonatomic,assign) V2TIMGender gender;

/// 用户最小生日（如果不设置，默认值为 0）
@property(nonatomic,assign) uint32_t minBirthday;

/// 用户最大生日（如果不设置，默认 birthday >= minBirthday 的用户都会返回）
@property(nonatomic,assign) uint32_t maxBirthday;

/// 每次云端搜索返回结果的条数（必须大于 0，最大支持 100，默认 20）
@property(nonatomic,assign) NSUInteger searchCount;

/// 每次云端搜索的起始位置。第一次填空字符串，续拉时填写 V2TIMUserSearchResult 中的返回值。
@property(nonatomic,strong) NSString *searchCursor;

@end

V2TIM_EXPORT @interface V2TIMUserSearchResult : NSObject
/// 是否已经返回全部满足搜索条件的用户列表
@property(nonatomic,assign) BOOL isFinished;

/// 满足搜索条件的用户总数量
@property(nonatomic,assign) NSUInteger totalCount;

/// 下一次云端搜索的起始位置
@property(nonatomic,strong,nullable) NSString *nextCursor;

/// 当前一次云端搜索返回的用户列表
@property(nonatomic,strong) NSArray<V2TIMUserFullInfo *> *userList;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                    用户状态
//
/////////////////////////////////////////////////////////////////////////////////

V2TIM_EXPORT @interface V2TIMUserStatus : NSObject

/// 用户的 ID
@property (nonatomic, copy, readonly, nullable) NSString *userID;

/// 用户的状态
@property (nonatomic, assign, readonly) V2TIMUserStatusType statusType;

/// 用户的自定义状态, 最大 100 字节
@property (nonatomic, copy, nullable) NSString *customStatus;

/// 用户在线设备列表
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *onlineDevices;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                        群成员资料
//
/////////////////////////////////////////////////////////////////////////////////
/// 群成员基本资料
V2TIM_EXPORT @interface V2TIMGroupMemberInfo : NSObject
/// 用户 ID
@property(nonatomic,strong,nullable) NSString* userID;

/// 用户昵称
@property(nonatomic,strong,readonly,nullable) NSString* nickName;

/// 用户好友备注
@property(nonatomic,strong,readonly,nullable) NSString* friendRemark;

/// 群成员名片
@property(nonatomic,strong,nullable) NSString* nameCard;

/// 用户头像
@property(nonatomic,strong,readonly,nullable) NSString* faceURL;

/// 群成员在线终端列表
@property(nonatomic,strong,readonly) NSMutableArray<NSString*>* onlineDevices;

@end

/// 群成员详细资料
V2TIM_EXPORT @interface V2TIMGroupMemberFullInfo : V2TIMGroupMemberInfo
/// 群成员自定义字段
/// 首先要在 [控制台](https://console.cloud.tencent.com/im) (功能配置 -> 群成员自定义字段) 配置用户自定义字段，然后再调用该接口进行设置。
@property(nonatomic,strong,nullable) NSDictionary<NSString *,NSData *> * customInfo;

/// 群成员角色(V2TIMGroupMemberRole),修改群成员角色请调用 V2TIMManager+Group.h -> setGroupMemberRole 接口
@property(nonatomic,assign,readonly) uint32_t role;

/// 群成员禁言结束时间戳，禁言用户请调用 V2TIMManager+Group.h -> muteGroupMember 接口
@property(nonatomic,assign,readonly) uint32_t muteUntil;

/// 群成员入群时间，自动生成，不可修改
@property(nonatomic,assign,readonly) time_t joinTime;

/// 群成员是否在线
/// @note
/// - 不支持直播群 AVChatRoom；
/// - 该字段仅在调用 - getGroupMemberList:filter:nextSeq:succ:fail: 接口时有效；
/// - 7.3 及其以上版本支持，需要您购买旗舰版套餐。
@property(nonatomic,assign,readonly) BOOL isOnline;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//       SDK 配置参数表
//
/////////////////////////////////////////////////////////////////////////////////

V2TIM_EXPORT @interface V2TIMSDKConfig : NSObject

/// 本地写 log 文件的等级，默认 DEBUG 等级， IMSDK 的日志默认存储于 /Library/Caches/ 目录下
@property(nonatomic,assign) V2TIMLogLevel logLevel;

/// log 监听回调（回调在主线程，日志回调可能比较频繁，请注意不要在回调里面同步处理太多耗时任务，可能会堵塞主线程）
@property(nonatomic,copy,nullable) V2TIMLogListener logListener;

@end

#endif
