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
//
/////////////////////////////////////////////////////////////////////

#ifndef ImSDK_V2TIMManager_h
#define ImSDK_V2TIMManager_h

#import <Foundation/Foundation.h>
@class V2TIMSDKConfig;
@class V2TIMUserInfo;
@class V2TIMUserFullInfo;
@class V2TIMGroupMemberInfo;
@class V2TIMGroupMemberFullInfo;
@class V2TIMGroupChangeInfo;
@class V2TIMGroupMemberChangeInfo;
@class V2TIMUserReceiveMessageOptInfo;

@protocol V2TIMSDKListener;
@protocol V2TIMSimpleMsgListener;
@protocol V2TIMGroupListener;

extern NSString *const GroupType_Work;
extern NSString *const GroupType_Public;
extern NSString *const GroupType_Meeting;
extern NSString *const GroupType_AVChatRoom;
extern NSString *const GroupType_Community;

/////////////////////////////////////////////////////////////////////////////////
//
//                           V2TIMManager
//
//       IMSDK 主核心类，负责 IMSDK 的初始化、登录、消息收发，建群退群等功能
//
/////////////////////////////////////////////////////////////////////////////////


@interface V2TIMManager : NSObject

/// 成功通用回调
typedef void (^V2TIMSucc)(void);
/// 失败通用回调
typedef void (^V2TIMFail)(int code, NSString * desc);
/// 创建群组成功回调
typedef void (^V2TIMCreateGroupSucc)(NSString * groupID);
/// 获取用户资料成功回调
typedef void (^V2TIMUserFullInfoListSucc)(NSArray <V2TIMUserFullInfo *> * infoList);
/// 实验性 API 接口成功回调
typedef void (^V2TIMCallExperimentalAPISucc)(NSObject *result);

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

/// 日志回调
typedef void (^V2TIMLogListener)(V2TIMLogLevel logLevel, NSString * logContent);

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
- (void)addIMSDKListener:(id<V2TIMSDKListener>)listener;

/**
 *  1.4 移除 IM 监听
 */
- (void)removeIMSDKListener:(id<V2TIMSDKListener>)listener;

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
 *  @return 服务器时间时间戳，单位 s
 */
- (uint64_t)getServerTime;

/**
 *  初始化 SDK（待废弃接口，请使用 initSDK 和 addIMSDKListener 接口）
 */
- (BOOL)initSDK:(int)sdkAppID config:(V2TIMSDKConfig*)config listener:(id<V2TIMSDKListener>)listener __attribute__((deprecated("use initSDK:config: and addIMSDKListener: instead")));

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
 */
- (void)login:(NSString *)userID userSig:(NSString *)userSig succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.2 登出
 *
 *  退出登录，如果切换账号，需要 logout 回调成功或者失败后才能再次 login，否则 login 可能会失败。
 */
- (void)logout:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.3 获取登录用户
 */
- (NSString *)getLoginUser;

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
 *  3.3 发送单聊普通文本消息（最大支持 8KB）
 *
 *  文本消息支持云端的脏词过滤，如果用户发送的消息中有敏感词，V2TIMFail 回调将会返回 80001 错误码。
 *  @return 返回消息的唯一标识 ID
 *
 *  @note 该接口发送的消息默认会推送（前提是在 V2TIMManager+APNS.h 开启了推送），如果需要自定义推送（自定义推送声音，推送 Title 等），请调用 V2TIMManager+Message.h -> sendMessage 接口。
 */
- (NSString*)sendC2CTextMessage:(NSString *)text to:(NSString *)userID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.4 发送单聊自定义（信令）消息（最大支持 8KB）
 *
 *  自定义消息本质就是一端二进制 buffer，您可以在其上自由组织自己的消息格式（常用于发送信令），但是自定义消息不支持云端敏感词过滤。
 *  @return 返回消息的唯一标识 ID
 *
 *  @note 该接口发送的消息默认不会推送，如果需要推送，请调用 V2TIMManager+Message.h -> sendMessage 接口。
 */
- (NSString*)sendC2CCustomMessage:(NSData *)customData to:(NSString *)userID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.5 发送群聊普通文本消息（最大支持 8KB）
 *
 *  @param priority 设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
 *      - HIGH ：云端会优先传输，适用于在群里发送重要消息，比如主播发送的文本消息等。
 *      - NORMAL ：云端按默认优先级传输，适用于在群里发送普通消息，比如观众发送的弹幕消息等。
 *  @return 返回消息的唯一标识 ID
 *
 *  @note 该接口发送的消息默认会推送（前提是在 V2TIMManager+APNS.h 开启了推送），如果需要自定义推送（自定义推送声音，推送 Title 等），请调用 V2TIMManager+Message.h -> sendMessage 接口。
 */
- (NSString*)sendGroupTextMessage:(NSString *)text to:(NSString *)groupID priority:(V2TIMMessagePriority)priority succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.6 发送群聊自定义（信令）消息（最大支持 8KB）
 *
 *  @param priority 设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
 *      - HIGH ：云端会优先传输，适用于在群里发送重要信令，比如连麦邀请，PK邀请、礼物赠送等关键性信令。
 *      - NORMAL ：云端按默认优先级传输，适用于在群里发送非重要信令，比如观众的点赞提醒等等。
 *  @return 返回消息的唯一标识 ID
 *
 *  @note 该接口发送的消息默认不会推送，如果需要推送，请调用 V2TIMManager+Message.h -> sendMessage 接口。
 */
- (NSString*)sendGroupCustomMessage:(NSData *)customData to:(NSString *)groupID priority:(V2TIMMessagePriority)priority succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

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
 *  @param groupName 群名称，不能为 nil，最长30字节
 *
 *  @note 请注意如下特殊逻辑:
 *  - 不支持在同一个 SDKAPPID 下创建两个相同 groupID 的群
 */
- (void)createGroup:(NSString *)groupType groupID:(NSString*)groupID groupName:(NSString *)groupName succ:(V2TIMCreateGroupSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.4 加入群组
 *
 *  @note 请注意如下特殊逻辑:
 *  - 工作群（Work）：不能主动入群，只能通过群成员调用 V2TIMManager+Group.h -> inviteUserToGroup 接口邀请入群。
 *  - 公开群（Public）：申请入群后，需要管理员审批，管理员在收到 V2TIMGroupListener -> onReceiveJoinApplication 回调后调用 V2TIMManager+Group.h -> getGroupApplicationList 接口处理加群请求。
 *  - 其他群：可以直接入群。
 */
- (void)joinGroup:(NSString*)groupID msg:(NSString*)msg succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.5 退出群组
 *
 *  @note 在公开群（Public）、会议（Meeting）和直播群（AVChatRoom）中，群主是不可以退群的，群主只能调用 dismissGroup 解散群组。
 */
- (void)quitGroup:(NSString*)groupID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.6 解散群组
 *
 *  @note 请注意如下特殊逻辑:
 *  - 好友工作群（Work）的解散最为严格，即使群主也不能随意解散，只能由您的业务服务器调用 [解散群组 REST API](https://cloud.tencent.com/document/product/269/1624) 解散。
 *  - 其他类型群的群主可以解散群组。
 */
- (void)dismissGroup:(NSString*)groupID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

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
 *  @note 请注意:
 *  - 获取自己的资料，传入自己的 ID 即可。
 *  - userIDList 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
 */
- (void)getUsersInfo:(NSArray<NSString *> *)userIDList succ:(V2TIMUserFullInfoListSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.2 修改个人资料
 */
- (void)setSelfInfo:(V2TIMUserFullInfo *)Info succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

//  5.5 更多功能，详见 V2TIMManager+Friendship.h

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
                      param:(NSObject *)param
                       succ:(V2TIMCallExperimentalAPISucc)succ
                       fail:(V2TIMFail)fail;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//       IMSDK 主核心回调，帮助您时刻关注 IMSDK 的在线状态
//
/////////////////////////////////////////////////////////////////////////////////
/// IMSDK 主核心回调
@protocol V2TIMSDKListener <NSObject>
@optional
/// SDK 正在连接到服务器
- (void)onConnecting;

/// SDK 已经成功连接到服务器
- (void)onConnectSuccess;

/// SDK 连接服务器失败
- (void)onConnectFailed:(int)code err:(NSString*)err;

/// 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onKickedOffline;

/// 在线时票据过期：此时您需要生成新的 userSig 并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onUserSigExpired;

/// 当前用户的资料发生了更新
- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//       IMSDK 基本消息回调 （高级消息请参考 V2TIMManager+Message.h -> V2TIMAdvancedMsgListener）
//
/////////////////////////////////////////////////////////////////////////////////
/// IMSDK 基本消息回调
@protocol V2TIMSimpleMsgListener <NSObject>
@optional

/// 收到 C2C 文本消息
- (void)onRecvC2CTextMessage:(NSString *)msgID  sender:(V2TIMUserInfo *)info text:(NSString *)text;

/// 收到 C2C 自定义（信令）消息
- (void)onRecvC2CCustomMessage:(NSString *)msgID  sender:(V2TIMUserInfo *)info customData:(NSData *)data;

/// 收到群文本消息
- (void)onRecvGroupTextMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info text:(NSString *)text;

/// 收到群自定义（信令）消息
- (void)onRecvGroupCustomMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info customData:(NSData *)data;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//       IMSDK 群组事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/// IMSDK 群组事件回调
@protocol V2TIMGroupListener <NSObject>
@optional

/////////////////////////////////////////////////////////////////////////////////
//        群成员相关通知
/////////////////////////////////////////////////////////////////////////////////

/// 有新成员加入群（该群所有的成员都能收到，会议群（Meeting）默认无此回调，如需回调请提交工单配置）
- (void)onMemberEnter:(NSString *)groupID memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList;

/// 有成员离开群（该群所有的成员都能收到，会议群（Meeting）默认无此回调，如需回调请提交工单配置）
- (void)onMemberLeave:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member;

/// 某成员被拉入某群（该群所有的成员都能收到）
- (void)onMemberInvited:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList;

/// 有成员被踢出某群（该群所有的成员都能收到）
- (void)onMemberKicked:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList;

/// 某成员信息发生变更（该群所有的成员都能收到）。会议群（Meeting）和直播群（AVChatRoom）默认无此回调，如需回调请提交工单配置
- (void)onMemberInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupMemberChangeInfo *> *)changeInfoList;

/////////////////////////////////////////////////////////////////////////////////
//        群生命周期相关通知
/////////////////////////////////////////////////////////////////////////////////

/// 有新的群创建（创建者能收到，应用于多端消息同步的场景）
- (void)onGroupCreated:(NSString *)groupID;

/// 某个已加入的群被解散了（该群所有的成员都能收到）
- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser;

/// 某个已加入的群被回收了（该群所有的成员都能收到）
- (void)onGroupRecycled:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser;

/// 某个已加入的群的信息被修改了（该群所有的成员都能收到）
- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupChangeInfo *> *)changeInfoList;

/// 某个已加入的群的属性被修改了，会返回所在群组的所有属性（该群所有的成员都能收到）
- (void)onGroupAttributeChanged:(NSString *)groupID attributes:(NSMutableDictionary<NSString *,NSString *> *)attributes;

/////////////////////////////////////////////////////////////////////////////////
//        加群申请相关通知
/////////////////////////////////////////////////////////////////////////////////

/// 有新的加群请求（只有群主和管理员会收到）
- (void)onReceiveJoinApplication:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member opReason:(NSString *)opReason;

/// 加群请求已经被群主或管理员处理了（只有申请人能够收到）
- (void)onApplicationProcessed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser opResult:(BOOL)isAgreeJoin opReason:(NSString *)opReason;

/////////////////////////////////////////////////////////////////////////////////
//        其他相关通知
/////////////////////////////////////////////////////////////////////////////////

/// 指定管理员身份
- (void)onGrantAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList;

/// 取消管理员身份
- (void)onRevokeAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList;

/// 自己主动退出群组（主要用于多端同步，直播群（AVChatRoom）不支持）
- (void)onQuitFromGroup:(NSString *)groupID;

/// 收到 RESTAPI 下发的自定义系统消息
- (void)onReceiveRESTCustomData:(NSString *)groupID data:(NSData *)data;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         用户资料
//
/////////////////////////////////////////////////////////////////////////////////
/// 用户基本资料
@interface V2TIMUserInfo : NSObject
/// 用户 ID
@property(nonatomic,strong,readonly) NSString* userID;

/// 用户昵称
@property(nonatomic,strong) NSString* nickName;

/// 用户头像
@property(nonatomic,strong) NSString* faceURL;
@end

/// 用户详细资料
@interface V2TIMUserFullInfo : V2TIMUserInfo

/// 用户签名
@property(nonatomic,strong) NSString *selfSignature;

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
@property(nonatomic,strong) NSDictionary<NSString *,NSData *> * customInfo;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                        群成员资料
//
/////////////////////////////////////////////////////////////////////////////////
/// 群成员基本资料
@interface V2TIMGroupMemberInfo : NSObject
/// 用户 ID
@property(nonatomic,strong) NSString* userID;

/// 用户昵称
@property(nonatomic,strong,readonly) NSString* nickName;

/// 用户好友备注
@property(nonatomic,strong,readonly) NSString* friendRemark;

/// 群成员名片
@property(nonatomic,strong) NSString* nameCard;

/// 用户头像
@property(nonatomic,strong,readonly) NSString* faceURL;

@end

/// 群成员详细资料
@interface V2TIMGroupMemberFullInfo : V2TIMGroupMemberInfo
/// 群成员自定义字段
/// 首先要在 [控制台](https://console.cloud.tencent.com/im) (功能配置 -> 群成员自定义字段) 配置用户自定义字段，然后再调用该接口进行设置。
@property(nonatomic,strong) NSDictionary<NSString *,NSData *> * customInfo;

/// 群成员角色(V2TIMGroupMemberRole),修改群成员角色请调用 V2TIMManager+Group.h -> setGroupMemberRole 接口
@property(nonatomic,assign,readonly) uint32_t role;

/// 群成员禁言结束时间戳，禁言用户请调用 V2TIMManager+Group.h -> muteGroupMember 接口
@property(nonatomic,assign,readonly) uint32_t muteUntil;

/// 群成员入群时间，自动生成，不可修改
@property(nonatomic,assign,readonly) time_t joinTime;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//       SDK 配置参数表
//
/////////////////////////////////////////////////////////////////////////////////

@interface V2TIMSDKConfig : NSObject

/// 本地写 log 文件的等级，默认 DEBUG 等级， IMSDK 的日志默认存储于 /Library/Caches/ 目录下
@property(nonatomic,assign) V2TIMLogLevel logLevel;

/// log 监听回调（回调在主线程，日志回调可能比较频繁，请注意不要在回调里面同步处理太多耗时任务，可能会堵塞主线程）
@property(nonatomic,copy) V2TIMLogListener logListener;

@end

#endif
