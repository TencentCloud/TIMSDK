/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：V2TIMManager+Friendship
//
//  关系链接口，里面包含了好友的添加、删除，黑名单的添加、删除等逻辑
//
/////////////////////////////////////////////////////////////////////
#import "V2TIMManager.h"

@protocol V2TIMFriendshipListener;
@class V2TIMFriendOperationResult;
@class V2TIMFriendInfoResult;
@class V2TIMFriendInfo;
@class V2TIMFriendCheckResult;
@class V2TIMFriendApplicationResult;
@class V2TIMFriendAddApplication;
@class V2TIMFriendApplication;
@class V2TIMFriendGroup;

@interface V2TIMManager (Friendship)

/// 获取好友列表成功回调
typedef void (^V2TIMFriendInfoListSucc)(NSArray<V2TIMFriendInfo *> *infoList);
/// 获取指定好友信息成功回调
typedef void (^V2TIMFriendInfoResultListSucc)(NSArray<V2TIMFriendInfoResult *> *resultList);
/// 好友操作成功回调
typedef void (^V2TIMFriendOperationResultSucc)(V2TIMFriendOperationResult *result);
/// 好友列表操作成功回调
typedef void (^V2TIMFriendOperationResultListSucc)(NSArray<V2TIMFriendOperationResult *> *resultList);
/// 好友检查成功回调
typedef void (^V2TIMFriendCheckResultSucc)(V2TIMFriendCheckResult *result);
/// 获取群分组列表成功回调
typedef void (^V2TIMFriendGroupListSucc)(NSArray<V2TIMFriendGroup *> * groups);
/// 获取好友申请列表成功回调
typedef void (^V2TIMFriendApplicationResultSucc)(V2TIMFriendApplicationResult *result);

/// 好友申请类型
typedef NS_ENUM(NSInteger, V2TIMFriendApplicationType) {
    V2TIM_FRIEND_APPLICATION_COME_IN        = 1,  ///< 别人发给我的
    V2TIM_FRIEND_APPLICATION_SEND_OUT       = 2,  ///< 我发给别人的
    V2TIM_FRIEND_APPLICATION_BOTH           = 3,  ///< 别人发给我的 和 我发给别人的。仅拉取时有效
};

/// 好友类型
typedef NS_ENUM(NSInteger, V2TIMFriendType) {
    V2TIM_FRIEND_TYPE_SINGLE                = 1,  ///< 单向好友
    V2TIM_FRIEND_TYPE_BOTH                  = 2,  ///< 双向好友
};

/// 好友关系类型
typedef NS_ENUM(NSInteger, V2TIMFriendRelationType) {
    V2TIM_FRIEND_RELATION_TYPE_NONE                   = 0x0,  ///< 不是好友
    V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST      = 0x1,  ///< 对方在我的好友列表中
    V2TIM_FRIEND_RELATION_TYPE_IN_OTHER_FRIEND_LIST   = 0x2,  ///< 我在对方的好友列表中
    V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY               = 0x3,  ///< 互为好友
};

/// 好友申请接受类型
typedef NS_ENUM(NSInteger, V2TIMFriendAcceptType) {
    V2TIM_FRIEND_ACCEPT_AGREE             = 0,  ///< 接受加好友（建立单向好友）
    V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD     = 1,  ///< 接受加好友并加对方为好友（建立双向好友）
};

/////////////////////////////////////////////////////////////////////////////////
//
//                         关系链和用户资料监听器
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  1.1 设置关系链监听器
 */
- (void)setFriendListener:(id<V2TIMFriendshipListener>)listener;

/////////////////////////////////////////////////////////////////////////////////
//
//                       好友添加、删除、列表获取、资料设置相关接口
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  2.1 获取好友列表
 */
- (void)getFriendList:(V2TIMFriendInfoListSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.2 获取指定好友资料
 *  @param userIDList 好友 userID 列表
 *                   - ID 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
 */
- (void)getFriendsInfo:(NSArray<NSString *> *)userIDList succ:(V2TIMFriendInfoResultListSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.3 设置指定好友资料
 */
- (void)setFriendInfo:(V2TIMFriendInfo *)info succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.4 添加好友
 */
- (void)addFriend:(V2TIMFriendAddApplication *)application succ:(V2TIMFriendOperationResultSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.5 删除好友
 *  @param userIDList 要删除的好友 userID 列表
 *                   - ID 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
 *  @param deleteType 删除类型（单向好友、双向好友）
 */
- (void)deleteFromFriendList:(NSArray *)userIDList deleteType:(V2TIMFriendType)deleteType succ:(V2TIMFriendOperationResultListSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.6 检查指定用户的好友关系
 */
- (void)checkFriend:(NSString *)userID succ:(V2TIMFriendCheckResultSucc)succ fail:(V2TIMFail)fail;

/////////////////////////////////////////////////////////////////////////////////
//
//                          好友申请、删除相关逻辑
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  3.1 获取好友申请列表
 */
- (void)getFriendApplicationList:(V2TIMFriendApplicationResultSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.2 同意好友申请
 *
 *  @param application 好友申请信息，getFriendApplicationList 成功后会返回
 *  @param acceptType 建立单向/双向好友关系
 */
- (void)acceptFriendApplication:(V2TIMFriendApplication *)application type:(V2TIMFriendAcceptType)acceptType succ:(V2TIMFriendOperationResultSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.3 拒绝好友申请
 *
 *  @param application 好友申请信息，getFriendApplicationList 成功后会返回
 */
- (void)refuseFriendApplication:(V2TIMFriendApplication *)application succ:(V2TIMFriendOperationResultSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.4 删除好友申请
 *
 *  @param application 好友申请信息，getFriendApplicationList 成功后会返回
 */
- (void)deleteFriendApplication:(V2TIMFriendApplication *)application succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.5 设置好友申请已读
 */
- (void)setFriendApplicationRead:(V2TIMSucc)succ fail:(V2TIMFail)fail;


/////////////////////////////////////////////////////////////////////////////////
//
//                          黑名单
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  4.1 添加用户到黑名单
 */
- (void)addToBlackList:(NSArray *)userIDList succ:(V2TIMFriendOperationResultListSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.2 把用户从黑名单中删除
 */
- (void)deleteFromBlackList:(NSArray *)userIDList succ:(V2TIMFriendOperationResultListSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.3 获取黑名单列表
 */
- (void)getBlackList:(V2TIMFriendInfoListSucc)succ fail:(V2TIMFail)fail;


/////////////////////////////////////////////////////////////////////////////////
//
//                          好友分组
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  5.1 新建好友分组
 *
 *  @param groupName  分组名称
 *  @param userIDList 要添加到分组中的好友
 */
- (void)createFriendGroup:(NSString *)groupName userIDList:(NSArray *)userIDList succ:(V2TIMFriendOperationResultSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.2 获取分组信息
 *
 *  @param groupNameList  要获取信息的好友分组名称列表,传入 nil 获得所有分组信息
 */
- (void)getFriendGroupList:(NSArray *)groupNameList succ:(V2TIMFriendGroupListSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.3 删除好友分组
 */
- (void)deleteFriendGroup:(NSArray *)groupNameList succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.4 修改好友分组的名称
 */
- (void)renameFriendGroup:(NSString*)oldName newName:(NSString*)newName succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.5 添加好友到一个好友分组
 */
- (void)addFriendsToFriendGroup:(NSString *)groupName userIDList:(NSArray *)userIDList succ:(V2TIMFriendOperationResultListSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.6 从好友分组中删除好友
 */
- (void)deleteFriendsFromFriendGroup:(NSString *)groupName userIDList:(NSArray *)userIDList succ:(V2TIMFriendOperationResultListSucc)succ fail:(V2TIMFail)fail;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      资料关系链回调
//
/////////////////////////////////////////////////////////////////////////////////
/// 资料关系链回调
@protocol V2TIMFriendshipListener <NSObject>
@optional
/**
 *  好友申请新增通知,两种情况会收到这个回调：
 *  1. 自己申请加别人好友
 *  2. 别人申请加自己好友
 */
- (void)onFriendApplicationListAdded:(NSArray<V2TIMFriendApplication *> *)applicationList;

/**
 *  好友申请删除通知，四种情况会收到这个回调：
 *  1. 调用 deleteFriendApplication 主动删除好友申请
 *  2. 调用 refuseFriendApplication 拒绝好友申请
 *  3. 调用 acceptFriendApplication 同意好友申请
 *  4. 申请加别人好友被拒绝
 */
- (void)onFriendApplicationListDeleted:(NSArray *)userIDList;

/**
 *  好友申请已读通知，如果调用 setFriendApplicationRead 设置好友申请列表已读，会收到这个回调（主要用于多端同步）
 */
- (void)onFriendApplicationListRead;

/**
 *  好友新增通知
 */
- (void)onFriendListAdded:(NSArray<V2TIMFriendInfo *>*)infoList;

/**
 *  好友删除通知，两种情况会收到这个回调：
 *  1. 自己删除好友（单向和双向删除都会收到回调）
 *  2. 好友把自己删除（双向删除会收到）
 */
- (void)onFriendListDeleted:(NSArray*)userIDList;

/**
 *  黑名单新增通知
 */
- (void)onBlackListAdded:(NSArray<V2TIMFriendInfo *>*)infoList;

/**
 *  黑名单删除通知
 */
- (void)onBlackListDeleted:(NSArray*)userIDList;

/**
 *  好友资料变更通知
 */
- (void)onFriendProfileChanged:(NSArray<V2TIMFriendInfo *> *)infoList;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      好友资料获取结果
//
/////////////////////////////////////////////////////////////////////////////////
/// 好友资料获取结果
@interface V2TIMFriendInfoResult : NSObject

/// 返回码
@property(nonatomic,assign) int resultCode;

/// 返结果表述
@property(nonatomic,strong) NSString *resultInfo;

/// 好友类型
@property(nonatomic,assign) V2TIMFriendRelationType relation;

/// 好友个人资料，如果不是好友，除了 userID 字段，其他字段都为空
@property(nonatomic,strong) V2TIMFriendInfo *friendInfo;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      好友资料
//
/////////////////////////////////////////////////////////////////////////////////
/// 好友资料
@interface V2TIMFriendInfo : NSObject

/// 好友 ID
@property(nonatomic,strong) NSString *userID;

/// 好友备注
@property(nonatomic,strong) NSString *friendRemark;

/// 好友自定义字段
/// 首先要在 [控制台](https://console.cloud.tencent.com/im) (功能配置 -> 好友自定义字段) 配置好友自定义字段，然后再调用该接口进行设置，key 值不需要加 Tag_SNS_Custom_ 前缀。
@property(nonatomic,strong) NSDictionary<NSString *,NSData *> *friendCustomInfo;

/// 好友所在分组列表
@property(nonatomic,strong,readonly) NSArray *friendGroups;

/// 好友个人资料
@property(nonatomic,strong,readonly) V2TIMUserFullInfo *userFullInfo;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      好友申请相关对象
//
/////////////////////////////////////////////////////////////////////////////////

/// 加好友
@interface V2TIMFriendAddApplication : NSObject

/// 用户 userID（必填）
@property (nonatomic,strong) NSString* userID;

/// 备注（备注最大96字节）
@property (nonatomic,strong) NSString* friendRemark;

/// 请求说明（最大120字节）
@property (nonatomic,strong) NSString* addWording;

/// 添加来源
@property (nonatomic,strong) NSString* addSource;

/// 加好友方式
@property (nonatomic,assign) V2TIMFriendType addType;

@end

/// 好友申请列表
@interface V2TIMFriendApplicationResult : NSObject

/// 好友申请未读数量
@property(nonatomic,assign,readonly) uint64_t unreadCount;

/// 好友申请列表
@property(nonatomic,strong,readonly) NSMutableArray<V2TIMFriendApplication *> * applicationList;

@end

/// 好友申请
@interface V2TIMFriendApplication : NSObject

/// 用户标识
@property(nonatomic,strong,readonly) NSString* userID;

/// 用户昵称
@property(nonatomic,strong,readonly) NSString* nickName;

/// 用户头像
@property(nonatomic,strong,readonly) NSString* faceUrl;

/// 添加时间
@property(nonatomic,assign,readonly) uint64_t addTime;

/// 来源
@property(nonatomic,strong,readonly) NSString* addSource;

/// 加好友附言
@property(nonatomic,strong,readonly) NSString* addWording;

/// 好友申请类型
@property(nonatomic,assign,readonly) V2TIMFriendApplicationType type;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                    好友关系链检查结果
//
/////////////////////////////////////////////////////////////////////////////////
/// 好友关系链检查结果
@interface V2TIMFriendCheckResult : NSObject

/// 用户id
@property(nonatomic,strong) NSString* userID;

/// 返回码
@property(nonatomic,assign) NSInteger resultCode;

/// 返回信息
@property(nonatomic,strong) NSString *resultInfo;

/// 检查结果
@property(nonatomic,assign) V2TIMFriendRelationType relationType;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                 好友操作结果（添加、删除、加黑名单、添加分组等）
//
/////////////////////////////////////////////////////////////////////////////////
/// 好友操作结果（添加、删除、加黑名单、添加分组等）
@interface V2TIMFriendOperationResult : NSObject

/// 用户Id
@property(nonatomic,strong) NSString* userID;

/// 返回码
@property(nonatomic,assign) NSInteger resultCode;

/// 返回信息
@property(nonatomic,strong) NSString *resultInfo;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                    好友分组
//
/////////////////////////////////////////////////////////////////////////////////
/// 好友分组
@interface V2TIMFriendGroup : NSObject
/// 好友分组名称
@property(nonatomic,strong) NSString* groupName;

/// 分组成员数量
@property(nonatomic,assign) uint64_t userCount;

/// 分组成员列表
@property(nonatomic,strong) NSArray* friendList;

@end
