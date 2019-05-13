//
//  TIMComm.h
//  ImSDK
//
//  Created by bodeng on 29/1/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMComm_h
#define ImSDK_TIMComm_h

#import <Foundation/Foundation.h>

#define ERR_IMSDK_KICKED_BY_OTHERS      6208

@protocol TIMConnListener;
@protocol TIMUserStatusListener;
@protocol TIMRefreshListener;
@protocol TIMMessageReceiptListener;
@protocol TIMMessageUpdateListener;
@protocol TIMMessageRevokeListener;
@protocol TIMUploadProgressListener;
@protocol TIMGroupEventListener;
@protocol TIMFriendshipListener;
//@protocol TIMGroupListener;
@class TIMMessage;
@class TIMImageElem;
@class TIMConversation;
@class TIMAPNSConfig;
@class TIMUserProfile;
@class TIMFriend;
@class TIMGroupInfoOption;
@class TIMGroupMemberInfoOption;
@class TIMFriendProfileOption;
@class TIMFriendResult;

#pragma mark - 枚举类型

/**
 * 网络连接状态
 */
typedef NS_ENUM(NSInteger, TIMNetworkStatus) {
    /**
     * 已连接
     */
    TIM_NETWORK_STATUS_CONNECTED             = 1,
    /**
     * 链接断开
     */
    TIM_NETWORK_STATUS_DISCONNECTED          = 2,
};


/**
 * 日志级别
 */
typedef NS_ENUM(NSInteger, TIMLogLevel) {
    /**
     *  不输出任何 sdk log
     */
    TIM_LOG_NONE                = 0,
    /**
     *  输出 DEBUG，INFO，WARNING，ERROR 级别的 log
     */
    TIM_LOG_DEBUG               = 3,
    /**
     *  输出 INFO，WARNING，ERROR 级别的 log
     */
    TIM_LOG_INFO                = 4,
    /**
     *  输出 WARNING，ERROR 级别的 log
     */
    TIM_LOG_WARN                = 5,
    /**
     *  输出 ERROR 级别的 log
     */
    TIM_LOG_ERROR               = 6,
};

/**
 * 会话类型：
 *      C2C     双人聊天
 *      GROUP   群聊
 */
typedef NS_ENUM(NSInteger, TIMConversationType) {
    /**
     *  C2C 类型
     */
    TIM_C2C              = 1,
    
    /**
     *  群聊 类型
     */
    TIM_GROUP            = 2,
    
    /**
     *  系统消息
     */
    TIM_SYSTEM           = 3,
};

/**
 *  消息状态
 */
typedef NS_ENUM(NSInteger, TIMMessageStatus){
    /**
     *  消息发送中
     */
    TIM_MSG_STATUS_SENDING              = 1,
    /**
     *  消息发送成功
     */
    TIM_MSG_STATUS_SEND_SUCC            = 2,
    /**
     *  消息发送失败
     */
    TIM_MSG_STATUS_SEND_FAIL            = 3,
    /**
     *  消息被删除
     */
    TIM_MSG_STATUS_HAS_DELETED          = 4,
    /**
     *  导入到本地的消息
     */
    TIM_MSG_STATUS_LOCAL_STORED         = 5,
    /**
     *  被撤销的消息
     */
    TIM_MSG_STATUS_LOCAL_REVOKED        = 6,
};

/**
 *  消息优先级标识
 */
typedef NS_ENUM(NSInteger, TIMMessagePriority) {
    /**
     *  高优先级，一般为红包或者礼物消息
     */
    TIM_MSG_PRIORITY_HIGH               = 1,
    /**
     *  普通优先级，普通消息
     */
    TIM_MSG_PRIORITY_NORMAL             = 2,
    /**
     *  低优先级，一般为点赞消息
     */
    TIM_MSG_PRIORITY_LOW                = 3,
    /**
     *  最低优先级，一般为后台下发的成员进退群通知
     */
    TIM_MSG_PRIORITY_LOWEST             = 4,
};

/**
 *  图片压缩选项
 */
typedef NS_ENUM(NSInteger, TIM_IMAGE_COMPRESS_TYPE){
    /**
     *  原图(不压缩）
     */
    TIM_IMAGE_COMPRESS_ORIGIN              = 0x00,
    /**
     *  高压缩率：图片较小，默认值
     */
    TIM_IMAGE_COMPRESS_HIGH                = 0x01,
    /**
     *  低压缩：高清图发送(图片较大)
     */
    TIM_IMAGE_COMPRESS_LOW                 = 0x02,
};

/**
 *  图片类型
 */
typedef NS_ENUM(NSInteger, TIM_IMAGE_TYPE){
    /**
     *  原图
     */
    TIM_IMAGE_TYPE_ORIGIN              = 0x01,
    /**
     *  缩略图
     */
    TIM_IMAGE_TYPE_THUMB               = 0x02,
    /**
     *  大图
     */
    TIM_IMAGE_TYPE_LARGE               = 0x04,
};

/**
 *  图片格式
 */
typedef NS_ENUM(NSInteger, TIM_IMAGE_FORMAT){
    /**
     *  JPG 格式
     */
    TIM_IMAGE_FORMAT_JPG            = 0x1,
    /**
     *  GIF 格式
     */
    TIM_IMAGE_FORMAT_GIF            = 0x2,
    /**
     *  PNG 格式
     */
    TIM_IMAGE_FORMAT_PNG            = 0x3,
    /**
     *  BMP 格式
     */
    TIM_IMAGE_FORMAT_BMP            = 0x4,
    /**
     *  未知格式
     */
    TIM_IMAGE_FORMAT_UNKNOWN        = 0xff,
};

/**
 *  登录状态
 */
typedef NS_ENUM(NSInteger, TIMLoginStatus) {
    /**
     *  已登陆
     */
    TIM_STATUS_LOGINED             = 1,
    
    /**
     *  登陆中
     */
    TIM_STATUS_LOGINING            = 2,
    
    /**
     *  无登陆
     */
    TIM_STATUS_LOGOUT              = 3,
};

/**
 *  群组成员是否可见
 */
typedef NS_ENUM(NSInteger, TIMGroupMemberVisibleType) {
    /**
     *  未知
     */
    TIM_GROUP_MEMBER_VISIBLE_UNKNOWN          = 0x00,
    /**
     *  群组成员不可见
     */
    TIM_GROUP_MEMBER_VISIBLE_NO               = 0x01,
    /**
     *  群组成员可见
     */
    TIM_GROUP_MEMBER_VISIBLE_YES              = 0x02,
};

/**
 *  群组是否能被搜到
 */
typedef NS_ENUM(NSInteger, TIMGroupSearchableType) {
    /**
     *  未知
     */
    TIM_GROUP_SEARCHABLE_UNKNOWN              = 0x00,
    /**
     *  群组不能被搜到
     */
    TIM_GROUP_SEARCHABLE_NO                   = 0x01,
    /**
     *  群组能被搜到
     */
    TIM_GROUP_SEARCHABLE_YES                  = 0x02,
};

/**
 * 加群选项
 */
typedef NS_ENUM(NSInteger, TIMGroupAddOpt) {
    /**
     *  禁止加群
     */
    TIM_GROUP_ADD_FORBID                    = 0,
    
    /**
     *  需要管理员审批
     */
    TIM_GROUP_ADD_AUTH                      = 1,
    
    /**
     *  任何人可以加入
     */
    TIM_GROUP_ADD_ANY                       = 2,
};

/**
 *  群组提示类型
 */
typedef NS_ENUM(NSInteger, TIMGroupTipsType){
    /**
     *  成员加入
     */
    TIM_GROUP_TIPS_JOIN              = 1,
    /**
     *  成员离开
     */
    TIM_GROUP_TIPS_QUIT              = 2,
    /**
     *  成员被踢
     */
    TIM_GROUP_TIPS_KICK              = 3,
    /**
     *  成员设置管理员
     */
    TIM_GROUP_TIPS_SET_ADMIN         = 4,
    /**
     *  成员取消管理员
     */
    TIM_GROUP_TIPS_CANCEL_ADMIN      = 5,
};

/**
 * 群消息接受选项
 */
typedef NS_ENUM(NSInteger, TIMGroupReceiveMessageOpt) {
    /**
     *  接收消息
     */
    TIM_GROUP_RECEIVE_MESSAGE                       = 0,
    /**
     *  不接收消息，服务器不进行转发
     */
    TIM_GROUP_NOT_RECEIVE_MESSAGE                   = 1,
    /**
     *  接受消息，不进行 iOS APNs 推送
     */
    TIM_GROUP_RECEIVE_NOT_NOTIFY_MESSAGE            = 2,
};

/**
 *  群 Tips 类型
 */
typedef NS_ENUM(NSInteger, TIM_GROUP_TIPS_TYPE){
    /**
     *  邀请加入群 (opUser & groupName & userList)
     */
    TIM_GROUP_TIPS_TYPE_INVITE              = 0x01,
    /**
     *  退出群 (opUser & groupName & userList)
     */
    TIM_GROUP_TIPS_TYPE_QUIT_GRP            = 0x02,
    /**
     *  踢出群 (opUser & groupName & userList)
     */
    TIM_GROUP_TIPS_TYPE_KICKED              = 0x03,
    /**
     *  设置管理员 (opUser & groupName & userList)
     */
    TIM_GROUP_TIPS_TYPE_SET_ADMIN           = 0x04,
    /**
     *  取消管理员 (opUser & groupName & userList)
     */
    TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN        = 0x05,
    /**
     *  群资料变更 (opUser & groupName & introduction & notification & faceUrl & owner)
     */
    TIM_GROUP_TIPS_TYPE_INFO_CHANGE         = 0x06,
    /**
     *  群成员资料变更 (opUser & groupName & memberInfoList)
     */
    TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE         = 0x07,
};

/**
 *  群变更信息 Tips 类型
 */
typedef NS_ENUM(NSInteger, TIM_GROUP_INFO_CHANGE_TYPE){
    /**
     *  群名修改
     */
    TIM_GROUP_INFO_CHANGE_GROUP_NAME                    = 0x01,
    /**
     *  群简介修改
     */
    TIM_GROUP_INFO_CHANGE_GROUP_INTRODUCTION            = 0x02,
    /**
     *  群公告修改
     */
    TIM_GROUP_INFO_CHANGE_GROUP_NOTIFICATION            = 0x03,
    /**
     *  群头像修改
     */
    TIM_GROUP_INFO_CHANGE_GROUP_FACE                    = 0x04,
    /**
     *  群主变更
     */
    TIM_GROUP_INFO_CHANGE_GROUP_OWNER                   = 0x05,
};

/**
 *  群系统消息类型
 */
typedef NS_ENUM(NSInteger, TIM_GROUP_SYSTEM_TYPE){
    /**
     *  申请加群请求（只有管理员会收到）
     */
    TIM_GROUP_SYSTEM_ADD_GROUP_REQUEST_TYPE              = 0x01,
    /**
     *  申请加群被同意（只有申请人能够收到）
     */
    TIM_GROUP_SYSTEM_ADD_GROUP_ACCEPT_TYPE               = 0x02,
    /**
     *  申请加群被拒绝（只有申请人能够收到）
     */
    TIM_GROUP_SYSTEM_ADD_GROUP_REFUSE_TYPE               = 0x03,
    /**
     *  被管理员踢出群（只有被踢的人能够收到）
     */
    TIM_GROUP_SYSTEM_KICK_OFF_FROM_GROUP_TYPE            = 0x04,
    /**
     *  群被解散（全员能够收到）
     */
    TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE                   = 0x05,
    /**
     *  创建群消息（创建者能够收到）
     */
    TIM_GROUP_SYSTEM_CREATE_GROUP_TYPE                   = 0x06,
    /**
     *  邀请入群通知(被邀请者能够收到)
     */
    TIM_GROUP_SYSTEM_INVITED_TO_GROUP_TYPE               = 0x07,
    /**
     *  主动退群（主动退群者能够收到）
     */
    TIM_GROUP_SYSTEM_QUIT_GROUP_TYPE                     = 0x08,
    /**
     *  设置管理员(被设置者接收)
     */
    TIM_GROUP_SYSTEM_GRANT_ADMIN_TYPE                    = 0x09,
    /**
     *  取消管理员(被取消者接收)
     */
    TIM_GROUP_SYSTEM_CANCEL_ADMIN_TYPE                   = 0x0a,
    /**
     *  群已被回收(全员接收)
     */
    TIM_GROUP_SYSTEM_REVOKE_GROUP_TYPE                   = 0x0b,
    /**
     *  邀请入群请求(被邀请者接收)
     */
    TIM_GROUP_SYSTEM_INVITE_TO_GROUP_REQUEST_TYPE        = 0x0c,
    /**
     *  邀请加群被同意(只有发出邀请者会接收到)
     */
    TIM_GROUP_SYSTEM_INVITE_TO_GROUP_ACCEPT_TYPE         = 0x0d,
    /**
     *  邀请加群被拒绝(只有发出邀请者会接收到)
     */
    TIM_GROUP_SYSTEM_INVITE_TO_GROUP_REFUSE_TYPE         = 0x0e,
    /**
     *  用户自定义通知(默认全员接收)
     */
    TIM_GROUP_SYSTEM_CUSTOM_INFO                         = 0xff,
};

/**
 *  推送规则
 */
typedef NS_ENUM(NSInteger, TIMOfflinePushFlag) {
    /**
     *  按照默认规则进行推送
     */
    TIM_OFFLINE_PUSH_DEFAULT    = 0,
    /**
     *  不进行推送
     */
    TIM_OFFLINE_PUSH_NO_PUSH    = 1,
};

/**
 *  安卓离线推送模式
 */
typedef NS_ENUM(NSInteger, TIMAndroidOfflinePushNotifyMode) {
    /**
     *  通知栏消息
     */
    TIM_ANDROID_OFFLINE_PUSH_NOTIFY_MODE_NOTIFICATION = 0x00,
    /**
     *  不弹窗，由应用自行处理
     */
    TIM_ANDROID_OFFLINE_PUSH_NOTIFY_MODE_CUSTOM = 0x01,
};

/**
 * 群成员角色
 */
typedef NS_ENUM(NSInteger, TIMGroupMemberRole) {
    /**
     *  未定义（没有获取该字段）
     */
    TIM_GROUP_MEMBER_UNDEFINED              = 0,
    
    /**
     *  群成员
     */
    TIM_GROUP_MEMBER_ROLE_MEMBER              = 200,
    
    /**
     *  群管理员
     */
    TIM_GROUP_MEMBER_ROLE_ADMIN               = 300,
    
    /**
     *  群主
     */
    TIM_GROUP_MEMBER_ROLE_SUPER               = 400,
};

/**
 * 好友验证方式
 */
typedef NS_ENUM(NSInteger, TIMFriendAllowType) {
    /**
     *  同意任何用户加好友
     */
    TIM_FRIEND_ALLOW_ANY                    = 0,
    
    /**
     *  需要验证
     */
    TIM_FRIEND_NEED_CONFIRM                 = 1,
    
    /**
     *  拒绝任何人加好友
     */
    TIM_FRIEND_DENY_ANY                     = 2,
};

/**
 * 性别
 */
typedef NS_ENUM(NSInteger, TIMGender) {
    /**
     *  未知性别
     */
    TIM_GENDER_UNKNOWN      = 0,
    /**
     *  男性
     */
    TIM_GENDER_MALE         = 1,
    /**
     *  女性
     */
    TIM_GENDER_FEMALE       = 2,
    
};


#pragma mark - block 回调

/**
 *  获取消息回调
 *
 *  @param msgs 消息列表
 */
typedef void (^TIMGetMsgSucc)(NSArray * msgs);

/**
 *  一般操作成功回调
 */
typedef void (^TIMSucc)(void);

/**
 *  操作失败回调
 *
 *  @param code 错误码
 *  @param msg  错误描述，配合错误码使用，如果问题建议打印信息定位
 */
typedef void (^TIMFail)(int code, NSString * msg);

/**
 *  进度毁掉
 *
 *  @param curSize 已下载大小
 *  @param totalSize  总大小
 */
typedef void (^TIMProgress)(NSInteger curSize, NSInteger totalSize);

/**
 *  登陆成功回调
 */
typedef void (^TIMLoginSucc)(void);

/**
 *  获取资源
 *
 *  @param data 资源二进制
 */
typedef void (^TIMGetResourceSucc)(NSData * data);

/**
 *  日志回调
 *
 *  @param lvl      输出的日志级别
 *  @param msg 日志内容
 */
typedef void (^TIMLogFunc)(TIMLogLevel lvl, NSString * msg);

/**
 *  上传图片成功回调
 *
 *  @param elem 上传图片成功后 elem
 */
typedef void (^TIMUploadImageSucc)(TIMImageElem * elem);

/**
 *  APNs 推送配置更新成功回调
 *
 *  @param config 配置
 */
typedef void (^TIMAPNSConfigSucc)(TIMAPNSConfig* config);

/**
 *  群创建成功
 *
 *  @param groupId 群组 Id
 */
typedef void (^TIMCreateGroupSucc)(NSString * groupId);

/**
 *  好友列表
 *
 *  @param friends 好友列表
 */
typedef void (^TIMFriendArraySucc)(NSArray<TIMFriend *> *friends);

/**
 *  获取资料回调
 *
 *  @param profile 资料
 */
typedef void (^TIMGetProfileSucc)(TIMUserProfile * profile);

/**
 *  获取资料回调
 *
 *  @param profiles 资料
 */
typedef void (^TIMUserProfileArraySucc)(NSArray<TIMUserProfile *> *profiles);

/**
 *  好友操作回调
 *
 *  @param result 资料
 */
typedef void (^TIMFriendResultSucc)(TIMFriendResult *result);

/**
 *  好友操作回调
 *
 *  @param results 资料
 */
typedef void (^TIMFriendResultArraySucc)(NSArray<TIMFriendResult *> *results);

#pragma mark - 基本类型

/// 实现 NSCoding 协议
@interface TIMCodingModel : NSObject <NSCoding>

///读取实例变量，并把这些数据写到 coder 中去，序列化数据
- (void)encodeWithCoder:(NSCoder *)encoder;

///从 coder 中读取数据，保存到相应的变量中，即反序列化数据
- (id)initWithCoder:(NSCoder *)decoder;

@end

/// 初始化 SDK 配置信息
@interface TIMSdkConfig : NSObject

///用户标识接入 SDK 的应用 ID，必填
@property(nonatomic,assign) int sdkAppId;

///用户的账号类型，必填
@property(nonatomic,strong) NSString * accountType;

///禁用 crash 上报，默认上报 (方法已废弃，客户需要自己集成 Crash 上报逻辑)
@property(nonatomic,assign) BOOL disableCrashReport DEPRECATED_ATTRIBUTE;

///禁止在控制台打印 log
@property(nonatomic,assign) BOOL disableLogPrint;

///本地写 log 文件的等级，默认 DEBUG 等级
@property(nonatomic,assign) TIMLogLevel logLevel;

///log 文件路径，不设置时为默认路径
@property(nonatomic,strong) NSString * logPath;

///回调给 log 函数的 log 等级，默认 DEBUG 等级
@property(nonatomic,assign) TIMLogLevel logFuncLevel;

///log 监听函数
@property(nonatomic,copy) TIMLogFunc logFunc;

///消息数据库路径，不设置时为默认路径
@property(nonatomic,strong) NSString * dbPath;

///网络监听器
@property(nonatomic,strong) id<TIMConnListener> connListener;

@end

/// 设置用户配置信息
@interface TIMUserConfig : NSObject

///禁用本地存储（暂未实现）
//@property(nonatomic,assign) BOOL disableStorage;

///禁止消息已读自动上报,一旦禁用自动上报，需要开发者显式调用 setReadMessage ，详情请参考官网文档 [未读消息计数](https://cloud.tencent.com/document/product/269/9151)
@property(nonatomic,assign) BOOL disableAutoReport;

///开启 C2C 已读回执，只针对 C2C 消息生效，用户开启已读回执功能后，对方调用 setReadMessage 时会同步已读信息到本客户端，您可以在 TIMMessageReceiptListener 监听消息已读回执
@property(nonatomic,assign) BOOL enableReadReceipt;

///不开启最近联系人（暂未实现）
//@property(nonatomic,assign) BOOL disableRecnetContact;

///不通过 onNewMessage: 抛出最近联系人的最后一条消息（暂未实现）
//@property(nonatomic,assign) BOOL disableRecentContactNotify;

///设置默认拉取的群组资料
@property(nonatomic,strong) TIMGroupInfoOption * groupInfoOpt;

///设置默认拉取的群成员资料
@property(nonatomic,strong) TIMGroupMemberInfoOption * groupMemberInfoOpt;

///关系链参数
@property(nonatomic,strong) TIMFriendProfileOption * friendProfileOpt;

///用户登录状态监听器
@property(nonatomic,strong) id<TIMUserStatusListener> userStatusListener;

///会话刷新监听器（未读计数、已读同步）
@property(nonatomic,strong) id<TIMRefreshListener> refreshListener;

///消息已读回执监听器
@property(nonatomic,strong) id<TIMMessageReceiptListener> messageReceiptListener;

///消息 svr 重写监听器
@property(nonatomic,strong) id<TIMMessageUpdateListener> messageUpdateListener;

///消息撤回监听器
@property(nonatomic,strong) id<TIMMessageRevokeListener> messageRevokeListener;

///文件上传进度监听器
@property(nonatomic,strong) id<TIMUploadProgressListener> uploadProgressListener;

///群组事件通知监听器
@property(nonatomic,strong) id<TIMGroupEventListener> groupEventListener;

///关系链数据本地缓存监听器
@property(nonatomic,strong) id<TIMFriendshipListener> friendshipListener;

@end

/// 登陆参数
@interface TIMLoginParam : NSObject

///用户名
@property(nonatomic,strong) NSString* identifier;

///鉴权 Token
@property(nonatomic,strong) NSString* userSig;

///App 用户使用 OAuth 授权体系分配的 Appid
@property(nonatomic,strong) NSString* appidAt3rd;


@end

/// APNs 配置
@interface TIMAPNSConfig : NSObject

///是否开启推送：0-不进行设置 1-开启推送 2-关闭推送
@property(nonatomic,assign) uint32_t openPush;

///C2C 消息声音,不设置传入 nil
@property(nonatomic,strong) NSString * c2cSound;

///Group 消息声音,不设置传入 nil
@property(nonatomic,strong) NSString * groupSound;

///Video 音视频邀请声音,不设置传入 nil (暂不支持)
@property(nonatomic,strong) NSString * videoSound;

@end

/// SetToken 参数
@interface TIMTokenParam : NSObject

///获取的客户端 Token 信息
@property(nonatomic,strong) NSData* token;

///业务 ID，传递证书时分配
@property(nonatomic,assign) uint32_t busiId;

@end

/// 切后台参数
@interface TIMBackgroundParam : NSObject

///C2C 未读计数
@property(nonatomic,assign) int c2cUnread;

///群未读计数
@property(nonatomic,assign) int groupUnread;

@end

/// 消息定位
@interface TIMMessageLocator : NSObject

///所属会话的 id
@property(nonatomic,strong) NSString * sessId;

///所属会话的类型
@property(nonatomic,assign) TIMConversationType sessType;

///消息序列号
@property(nonatomic,assign) uint64_t seq;

///消息随机码
@property(nonatomic,assign) uint64_t rand;

///消息时间戳
@property(nonatomic,assign) time_t time;

///是否本人消息
@property(nonatomic,assign) BOOL isSelf;

///是否来自撤销通知
@property(nonatomic,assign) BOOL isFromRevokeNotify;

@end

/// 已读回执
@interface TIMMessageReceipt : NSObject

///已读回执对应的会话（目前只支持 C2C 会话）
@property(nonatomic,strong) TIMConversation * conversation;

///收到已读回执时，这个时间戳之前的消息都已读
@property(nonatomic,assign) time_t timestamp;
@end

/// Android 离线推送配置
@interface TIMAndroidOfflinePushConfig : NSObject

///离线推送时展示标签
@property(nonatomic,strong) NSString * title;

///Android 离线 Push 时声音字段信息
@property(nonatomic,strong) NSString * sound;

///离线推送时通知形式
@property(nonatomic,assign) TIMAndroidOfflinePushNotifyMode notifyMode;

@end

/// iOS 离线推送配置
@interface TIMIOSOfflinePushConfig : NSObject

///离线 Push 时声音字段信息
@property(nonatomic,strong) NSString * sound;

///忽略 badge 计数
@property(nonatomic,assign) BOOL ignoreBadge;

@end

/// 群组内的本人信息
@interface TIMGroupSelfInfo : NSObject

///加入群组时间
@property(nonatomic,assign) uint32_t joinTime;

///群组中的角色
@property(nonatomic,assign) TIMGroupMemberRole role;

///群组消息接收选项
@property(nonatomic,assign) TIMGroupReceiveMessageOpt recvOpt;

///群组中的未读消息数
@property(nonatomic,assign) uint32_t unReadMessageNum;

@end

/// 群资料信息
@interface TIMGroupInfo : TIMCodingModel

///群组 Id
@property(nonatomic,strong) NSString* group;

///群名
@property(nonatomic,strong) NSString* groupName;

///群创建人/管理员
@property(nonatomic,strong) NSString * owner;

///群类型：Private,Public,ChatRoom
@property(nonatomic,strong) NSString* groupType;

///群创建时间
@property(nonatomic,assign) uint32_t createTime;

///最近一次群资料修改时间
@property(nonatomic,assign) uint32_t lastInfoTime;

///最近一次发消息时间
@property(nonatomic,assign) uint32_t lastMsgTime;

///最大成员数
@property(nonatomic,assign) uint32_t maxMemberNum;

///群成员数量
@property(nonatomic,assign) uint32_t memberNum;

///入群类型
@property(nonatomic,assign) TIMGroupAddOpt addOpt;

///群公告
@property(nonatomic,strong) NSString* notification;

///群简介
@property(nonatomic,strong) NSString* introduction;

///群头像
@property(nonatomic,strong) NSString* faceURL;

///最后一条消息
@property(nonatomic,strong) TIMMessage* lastMsg;

///在线成员数量
@property(nonatomic,assign) uint32_t onlineMemberNum;

///群组是否被搜索类型
@property(nonatomic,assign) TIMGroupSearchableType isSearchable;

///群组成员可见类型
@property(nonatomic,assign) TIMGroupMemberVisibleType isMemberVisible;

///是否全员禁言
@property(nonatomic,assign) BOOL allShutup;

///群组中的本人信息
@property(nonatomic,strong) TIMGroupSelfInfo* selfInfo;

///自定义字段集合,key 是 NSString* 类型,value 是 NSData* 类型
@property(nonatomic,strong) NSDictionary* customInfo;

@end

/// 事件上报信息
@interface TIMEventReportItem : NSObject

///事件 id
@property(nonatomic,assign) uint32_t event;

///错误码
@property(nonatomic,assign) uint32_t code;

///错误描述
@property(nonatomic,strong) NSString * desc;

///事件延迟（单位 ms）
@property(nonatomic,assign) uint32_t delay;

@end

/// 获取某个群组资料
@interface TIMGroupInfoOption : NSObject

///需要获取的群组信息标志（TIMGetGroupBaseInfoFlag）,默认为0xffffff
@property(nonatomic,assign) uint64_t groupFlags;

///需要获取群组资料的自定义信息（NSString*）列表
@property(nonatomic,strong) NSArray * groupCustom;

@end

/// 需要某个群成员资料
@interface TIMGroupMemberInfoOption : NSObject

///需要获取的群成员标志（TIMGetGroupMemInfoFlag）,默认为0xffffff
@property(nonatomic,assign) uint64_t memberFlags;

///需要获取群成员资料的自定义信息（NSString*）列表
@property(nonatomic,strong) NSArray * memberCustom;

@end

/// 群成员资料
@interface TIMGroupMemberInfo : TIMCodingModel

///成员
@property(nonatomic,strong) NSString* member;

///群名片
@property(nonatomic,strong) NSString* nameCard;

///加入群组时间
@property(nonatomic,assign) time_t joinTime;

///成员类型
@property(nonatomic,assign) TIMGroupMemberRole role;

///禁言结束时间（时间戳）
@property(nonatomic,assign) uint32_t silentUntil;

///自定义字段集合,key 是 NSString*类型,value 是 NSData*类型
@property(nonatomic,strong) NSDictionary* customInfo;

@end

///资料与关系链
@interface TIMFriendProfileOption : NSObject

///关系链最大缓存时间(默认缓存一天；获取资料和关系链超过缓存时间，将自动向服务器发起请求)
@property NSInteger expiredSeconds;

@end

///用户资料
@interface TIMUserProfile : TIMCodingModel

/**
 *  用户 identifier
 */
@property(nonatomic,strong) NSString* identifier;

/**
 *  用户昵称
 */
@property(nonatomic,strong) NSString* nickname;

/**
 *  好友验证方式
 */
@property(nonatomic,assign) TIMFriendAllowType allowType;

/**
 * 用户头像
 */
@property(nonatomic,strong) NSString* faceURL;

/**
 *  用户签名
 */
@property(nonatomic,strong) NSData* selfSignature;

/**
 *  用户性别
 */
@property(nonatomic,assign) TIMGender gender;

/**
 *  用户生日
 */
@property(nonatomic,assign) uint32_t birthday;

/**
 *  用户区域
 */
@property(nonatomic,strong) NSData* location;

/**
 *  用户语言
 */
@property(nonatomic,assign) uint32_t language;

/**
 *  等级
 */
@property(nonatomic,assign) uint32_t level;

/**
 *  角色
 */
@property(nonatomic,assign) uint32_t role;

/**
 *  自定义字段集合,key是NSString类型,value是NSData类型或者NSNumber类型
 *  key值按照后台配置的字符串传入,不包括 TIMProfileTypeKey_Custom_Prefix 前缀
 */
@property(nonatomic,strong) NSDictionary* customInfo;

@end

typedef void(^ProfileCallBack) (TIMUserProfile * proflie);

/**
 *  好友
 */
@interface TIMFriend : TIMCodingModel

/**
 *  好友identifier
 */
@property(nonatomic,strong) NSString *identifier;

/**
 *  好友备注（最大96字节，获取自己资料时，该字段为空）
 */
@property(nonatomic,strong) NSString *remark;

/**
 *  分组名称 NSString* 列表
 */
@property(nonatomic,strong) NSArray *groups;

/**
 *  申请时的添加理由
 */
@property(nonatomic,strong) NSString *addWording;

/**
 *  申请时的添加来源
 */
@property(nonatomic,strong) NSString *addSource;

/**
 * 添加时间
 */
@property(nonatomic,assign) uint64_t addTime;

/**
 *  自定义字段集合,key是NSString类型,value是NSData类型或者NSNumber类型
 *  key值按照后台配置的字符串传入,不包括 TIMFriendTypeKey_Custom_Prefix 前缀
 */
@property(nonatomic,strong) NSDictionary* customInfo;

/**
 * 好友资料
 */
@property(nonatomic,strong) TIMUserProfile *profile;

@end

#endif
