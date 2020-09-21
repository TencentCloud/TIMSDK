/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：V2TIMManager+Group
//
//  群组高级接口，里面包含了群组的高级功能，比如群成员邀请、非群成员申请进群等操作接口。
//
/////////////////////////////////////////////////////////////////////

#import "V2TIMManager.h"
@class V2TIMGroupMemberOperationResult;
@class V2TIMGroupApplicationResult;
@class V2TIMCreateGroupMemberInfo;
@class V2TIMGroupInfo;
@class V2TIMGroupInfoResult;
@class V2TIMGroupApplication;

/////////////////////////////////////////////////////////////////////////////////
//
//                         群相关的高级接口
//
/////////////////////////////////////////////////////////////////////////////////

@interface V2TIMManager (Group)

/// 获取已加入群列表成功回调
typedef void (^V2TIMGroupInfoListSucc)(NSArray<V2TIMGroupInfo *> *groupList);
/// 获取指定群列表成功回调
typedef void (^V2TIMGroupInfoResultListSucc)(NSArray<V2TIMGroupInfoResult *> *groupResultList);
/// 获取群属性列表成功回调
typedef void (^V2TIMGroupAttributeListSucc)(NSMutableDictionary<NSString *,NSString *> *groupAttributeList);
/// 获取群成员列表成功回调
typedef void (^V2TIMGroupMemberInfoListSucc)(NSArray<V2TIMGroupMemberFullInfo *> *memberList);
/// 获取指定群成员列表成功回调
typedef void (^V2TIMGroupMemberInfoResultSucc)(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> * memberList);
/// 群成员操作成功回调
typedef void (^V2TIMGroupMemberOperationResultListSucc)(NSArray<V2TIMGroupMemberOperationResult*> * resultList);
/// 获取好友申请列表成功回调
typedef void (^V2TIMGroupApplicationResultSucc)(V2TIMGroupApplicationResult *result);

/// 加群选项
typedef NS_ENUM(NSInteger, V2TIMGroupAddOpt) {
    V2TIM_GROUP_ADD_FORBID                 = 0,  ///< 禁止加群
    V2TIM_GROUP_ADD_AUTH                   = 1,  ///< 需要管理员审批
    V2TIM_GROUP_ADD_ANY                    = 2,  ///< 任何人可以加入
};

///  群组操作结果
typedef NS_ENUM(NSInteger, V2TIMGroupMemberResult) {
    V2TIM_GROUP_MEMBER_RESULT_FAIL         = 0,  ///< 操作失败
    V2TIM_GROUP_MEMBER_RESULT_SUCC         = 1,  ///< 操作成功
    V2TIM_GROUP_MEMBER_RESULT_INVALID      = 2,  ///< 无效操作，加群时已经是群成员，移除群组时不在群内
    V2TIM_GROUP_MEMBER_RESULT_PENDING      = 3,  ///< 等待处理，邀请入群时等待对方处理
};

/// 群消息接受选项
typedef NS_ENUM(NSInteger, V2TIMGroupReceiveMessageOpt) {
    V2TIM_GROUP_RECEIVE_MESSAGE            = 0,  ///< 在线正常接收消息，离线时会进行 APNs 推送
    V2TIM_GROUP_NOT_RECEIVE_MESSAGE        = 1,  ///< 不会接收到群消息
    V2TIM_GROUP_RECEIVE_NOT_NOTIFY_MESSAGE = 2,  ///< 在线正常接收消息，离线不会有推送通知
};

/// 群成员角色过滤方式
typedef NS_ENUM(NSInteger, V2TIMGroupMemberFilter) {
    V2TIM_GROUP_MEMBER_FILTER_ALL          = 0x00,  ///< 全部成员
    V2TIM_GROUP_MEMBER_FILTER_OWNER        = 0x01,  ///< 群主
    V2TIM_GROUP_MEMBER_FILTER_ADMIN        = 0x02,  ///< 管理员
    V2TIM_GROUP_MEMBER_FILTER_COMMON       = 0x04,  ///< 普通成员
};

/// 群组未决请求类型
typedef NS_ENUM(NSInteger, V2TIMGroupApplicationGetType) {
    V2TIM_GROUP_APPLICATION_GET_TYPE_JOIN   = 0x0,  ///< 申请入群
    V2TIM_GROUP_APPLICATION_GET_TYPE_INVITE = 0x1,  ///< 邀请入群
};

/// 群组已决标志
typedef NS_ENUM(NSInteger, V2TIMGroupApplicationHandleStatus) {
    V2TIM_GROUP_APPLICATION_HANDLE_STATUS_UNHANDLED           = 0,  ///< 未处理
    V2TIM_GROUP_APPLICATION_HANDLE_STATUS_HANDLED_BY_OTHER    = 1,  ///< 被他人处理
    V2TIM_GROUP_APPLICATION_HANDLE_STATUS_HANDLED_BY_SELF     = 2,  ///< 自己已处理
};

/// 群组已决结果
typedef NS_ENUM(NSInteger, V2TIMGroupApplicationHandleResult) {
    V2TIM_GROUP_APPLICATION_HANDLE_RESULT_REFUSE = 0,  ///< 拒绝申请
    V2TIM_GROUP_APPLICATION_HANDLE_RESULT_AGREE  = 1,  ///< 同意申请
};

/////////////////////////////////////////////////////////////////////////////////
//                         群管理
/////////////////////////////////////////////////////////////////////////////////

/**
 *  1.1 创建自定义群组（高级版本：可以指定初始的群成员）
 *
 *  @param info 自定义群组信息，可以设置 groupID | groupType | groupName | notification | introduction | faceURL 字段
 *  @param memberList 指定初始的群成员（直播群 AVChatRoom 不支持指定初始群成员，memberList 请传 nil）
 *
 *  @note 其他限制请参考 V2TIMManager.h -> createGroup 注释
 */
- (void)createGroup:(V2TIMGroupInfo*)info memberList:(NSArray<V2TIMCreateGroupMemberInfo *>*) memberList succ:(V2TIMCreateGroupSucc)succ fail:(V2TIMFail)fail;

/**
 *  1.2 获取当前用户已经加入的群列表
 *  @note 直播群（AVChatRoom）不支持该 API
 */
- (void)getJoinedGroupList:(V2TIMGroupInfoListSucc)succ fail:(V2TIMFail)fail;

/////////////////////////////////////////////////////////////////////////////////
//                         群资料管理
/////////////////////////////////////////////////////////////////////////////////

/**
 *  2.1 拉取群资料
 *
 *  @param groupIDList 群组 ID 列表
 */
- (void)getGroupsInfo:(NSArray<NSString *> *)groupIDList succ:(V2TIMGroupInfoResultListSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.2 修改群资料
 */
- (void)setGroupInfo:(V2TIMGroupInfo *)info succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.3 修改群消息接收选项
 */
- (void)setReceiveMessageOpt:(NSString*)groupID opt:(V2TIMGroupReceiveMessageOpt)opt succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.4 初始化群属性，会清空原有的群属性列表
 *
 * @note
 * attributes 的使用限制如下：
 *  - 目前只支持 AVChatRoom
 *  - key 最多支持16个，长度限制为32字节
 *  - value 长度限制为4k
 *  - 总的 attributes（包括 key 和 value）限制为16k
 *  - initGroupAttributes、setGroupAttributes、deleteGroupAttributes 接口合并计算， SDK 限制为5秒10次，超过后回调8511错误码；后台限制1秒5次，超过后返回10049错误码
 *  - getGroupAttributes 接口 SDK 限制5秒20次
 */
- (void)initGroupAttributes:(NSString*)groupID attributes:(NSDictionary<NSString *,NSString *> *)attributes succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.5 设置群属性，已有该群属性则更新其 value 值，没有该群属性则添加该群属性。
 */
- (void)setGroupAttributes:(NSString*)groupID attributes:(NSDictionary<NSString *,NSString *> *)attributes succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.6 删除群指定属性，keys 传 nil 则清空所有群属性。
 */
- (void)deleteGroupAttributes:(NSString*)groupID keys:(NSArray<NSString *> *)keys succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.7 获取群指定属性，keys 传 nil 则获取所有群属性。
 */
- (void)getGroupAttributes:(NSString*)groupID keys:(NSArray<NSString *> *)keys succ:(V2TIMGroupAttributeListSucc)succ fail:(V2TIMFail)fail;


/////////////////////////////////////////////////////////////////////////////////
//                         群成员管理
/////////////////////////////////////////////////////////////////////////////////
/**
 *  3.1 获取群成员列表
 *
 *  @param filter   指定群成员类型
 *  @param nextSeq  分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为 0。
 *
 *  @note 直播群（AVChatRoom）的特殊限制：
 *  - 不支持管理员角色的拉取，群成员个数最大只支持 31 个（新进来的成员会排前面），用户每次登录后，都需要重新加入群组，否则拉取群成员会报 10007 错误码。
 *  - 群成员资料信息仅支持 userID | nickName | faceURL | role 字段。
 *  - role 字段不支持管理员角色，如果您的业务逻辑依赖于管理员角色，可以使用群自定义字段 groupAttributes 管理该角色。
 */
- (void)getGroupMemberList:(NSString*)groupID filter:(V2TIMGroupMemberFilter)filter nextSeq:(uint64_t)nextSeq succ:(V2TIMGroupMemberInfoResultSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.2 指定的群成员资料
 */
- (void)getGroupMembersInfo:(NSString*)groupID memberList:(NSArray<NSString*>*)memberList succ:(V2TIMGroupMemberInfoListSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.3 修改指定的群成员资料
 */
- (void)setGroupMemberInfo:(NSString*)groupID info:(V2TIMGroupMemberFullInfo *)info succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.4 禁言（只有管理员或群主能够调用）
 */
- (void)muteGroupMember:(NSString*)groupID member:(NSString*)userID muteTime:(uint32_t)seconds succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.5 邀请他人入群
 *
 *  @note 请注意不同类型的群有如下限制：
 *  - 工作群（Work）：群里的任何人都可以邀请其他人进群。
 *  - 会议群（Meeting）和公开群（Public）：只有通过rest api 使用 App 管理员身份才可以邀请其他人进群。
 *  - 直播群（AVChatRoom）：不支持此功能。
 */
- (void)inviteUserToGroup:(NSString*)groupID userList:(NSArray<NSString *>*)userList succ:(V2TIMGroupMemberOperationResultListSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.6 踢人
 *
 *  @note 请注意不同类型的群有如下限制：
 * - 工作群（Work）：只有群主或 APP 管理员可以踢人。
 * - 公开群（Public）、会议群（Meeting）：群主、管理员和 APP 管理员可以踢人
 * - 直播群（AVChatRoom）：只支持禁言（muteGroupMember），不支持踢人。
 */
- (void)kickGroupMember:(NSString*)groupID memberList:(NSArray<NSString *>*)memberList reason:(NSString*)reason succ:(V2TIMGroupMemberOperationResultListSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.7 切换群成员的角色
 *
 *  @note 请注意不同类型的群有如下限制：
 *  - 公开群（Public）和会议群（Meeting）：只有群主才能对群成员进行普通成员和管理员之间的角色切换。
 *  - 其他群不支持设置群成员角色。
 *  - 转让群组请调用 transferGroupOwner 接口。
 */
- (void)setGroupMemberRole:(NSString*)groupID member:(NSString *)userID newRole:(V2TIMGroupMemberRole)role succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.8 转让群主
 *
 *  @note 请注意不同类型的群有如下限制：
 *  - 普通类型的群（Work、Public、Meeting）：只有群主才有权限进行群转让操作。
 *  - 直播群（AVChatRoom）：不支持转让群主。
 */
- (void)transferGroupOwner:(NSString*)groupID member:(NSString*)userID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;


/////////////////////////////////////////////////////////////////////////////////
//                         加群申请
/////////////////////////////////////////////////////////////////////////////////

/**
 *  4.1 获取加群的申请列表
 */
- (void)getGroupApplicationList:(V2TIMGroupApplicationResultSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.2 同意某一条加群申请
 */
- (void)acceptGroupApplication:(V2TIMGroupApplication *)application reason:(NSString*)reason succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.3 拒绝某一条加群申请
 */
- (void)refuseGroupApplication:(V2TIMGroupApplication *)application reason:(NSString*)reason succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.4 标记申请列表为已读
 */
- (void)setGroupApplicationRead:(V2TIMSucc)succ fail:(V2TIMFail)fail;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//             群基本资料（可以通过 getGroupInfo 获取，不支持由客户自行创建）
//
/////////////////////////////////////////////////////////////////////////////////
/// 群资料
@interface V2TIMGroupInfo : NSObject

/// 群组 ID
@property(nonatomic,strong) NSString* groupID;

/// 群类型
@property(nonatomic,strong) NSString* groupType;

/// 群名称
@property(nonatomic,strong) NSString* groupName;

/// 群公告
@property(nonatomic,strong) NSString* notification;

/// 群简介
@property(nonatomic,strong) NSString* introduction;

/// 群头像
@property(nonatomic,strong) NSString* faceURL;

/// 是否全员禁言
@property(nonatomic,assign) BOOL allMuted;

/// 群创建人/管理员
@property(nonatomic,strong,readonly) NSString *owner;

/// 群创建时间
@property(nonatomic,assign,readonly) uint32_t createTime;

/// 加群是否需要管理员审批，工作群（Work）不能主动加入，不支持此设置项
@property(nonatomic,assign) V2TIMGroupAddOpt groupAddOpt;

/// 群最近一次群资料修改时间
@property(nonatomic,assign,readonly) uint32_t lastInfoTime;

/// 群最近一次发消息时间
@property(nonatomic,assign,readonly) uint32_t lastMessageTime;

/// 群成员总数量
@property(nonatomic,assign,readonly) uint32_t memberCount;

/// 在线成员数量
@property(nonatomic,assign,readonly) uint32_t onlineCount;

/// 当前用户在此群组中的角色，切换角色请调用 setGroupMemberRole 接口
@property(nonatomic,assign,readonly) V2TIMGroupMemberRole role;

/// 当前用户在此群组中的消息接收选项,修改群消息接收选项请调用 setReceiveMessageOpt 接口
@property(nonatomic,assign,readonly) V2TIMGroupReceiveMessageOpt recvOpt;

/// 当前用户在此群中的加入时间，不支持设置，系统自动生成
@property(nonatomic,assign,readonly) uint32_t joinTime;
@end

/// 获取群组资料结果
@interface V2TIMGroupInfoResult : NSObject

/// 结果 0：成功；非0：失败
@property(nonatomic,assign,readonly) int resultCode;

/// 如果获取失败，会返回错误信息
@property(nonatomic,strong,readonly) NSString *resultMsg;

/// 如果获取成功，会返回对应的 info
@property(nonatomic,strong,readonly) V2TIMGroupInfo *info;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//          群申请信息（可以通过 getGroupApplicationList 获取，不支持由客户自行创建）
//
/////////////////////////////////////////////////////////////////////////////////
/// 群申请信息
@interface V2TIMGroupApplication : NSObject

/// 群组 ID
@property(nonatomic,strong,readonly) NSString* groupID;

/// 请求者 userID
@property(nonatomic,strong,readonly) NSString* fromUser;

/// 请求者昵称
@property(nonatomic,strong,readonly) NSString* fromUserNickName;

/// 请求者头像
@property(nonatomic,strong,readonly) NSString* fromUserFaceUrl;

/// 判决者id，有人请求加群:0，邀请其他人加群:被邀请人用户 ID
@property(nonatomic,strong,readonly) NSString* toUser;

/// 申请时间
@property(nonatomic,assign,readonly) uint64_t addTime;

/// 申请或邀请附加信息
@property(nonatomic,strong,readonly) NSString* requestMsg;

/// 审批信息：同意或拒绝信息
@property(nonatomic,strong,readonly) NSString* handledMsg;

/// 请求类型
@property(nonatomic,assign,readonly) V2TIMGroupApplicationGetType getType;

/// 处理标志
@property(nonatomic,assign,readonly) V2TIMGroupApplicationHandleStatus handleStatus;

/// 处理结果
@property(nonatomic,assign,readonly) V2TIMGroupApplicationHandleResult handleResult;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                        邀请其他人入群的操作结果
//
/////////////////////////////////////////////////////////////////////////////////
/// 邀请其他人入群的操作结果
@interface V2TIMGroupMemberOperationResult : NSObject

/// 被操作成员
@property(nonatomic,strong,readonly) NSString* userID;

/// 返回状态
@property(nonatomic,assign,readonly) V2TIMGroupMemberResult result;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                        创建群时指定群成员
//
/////////////////////////////////////////////////////////////////////////////////
/// 创建群时指定群成员
@interface V2TIMCreateGroupMemberInfo : NSObject

/// 被操作成员
@property(nonatomic,strong) NSString* userID;

/** 群成员类型，需要注意一下事项：
 * 1. role 不设置或则设置为 V2TIM_GROUP_MEMBER_UNDEFINED，进群后默认为群成员。
 * 2. 工作群（Work）不支持设置 role 为管理员。
 * 3. 所有的群都不支持设置 role 为群主。
 */
@property(nonatomic,assign) V2TIMGroupMemberRole role;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                        加群申请列表（包含已处理和待处理的）
//
/////////////////////////////////////////////////////////////////////////////////
/// 加群申请列表
@interface V2TIMGroupApplicationResult : NSObject

/// 未读的申请数量
@property(nonatomic,assign,readonly) uint64_t unreadCount;

/// 加群申请的列表
@property(nonatomic,strong,readonly) NSMutableArray<V2TIMGroupApplication *> * applicationList;
@end
