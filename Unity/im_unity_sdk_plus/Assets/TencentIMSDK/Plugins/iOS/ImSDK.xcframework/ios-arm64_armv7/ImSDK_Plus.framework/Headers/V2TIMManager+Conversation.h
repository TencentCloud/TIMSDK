/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：V2TIMManager+Conversation
//
//  会话接口，里面包含了会话的获取，删除，更新的逻辑
//
/////////////////////////////////////////////////////////////////////

#import "V2TIMManager.h"
#import "V2TIMManager+Group.h"
#import "V2TIMManager+Message.h"

@protocol V2TIMConversationListener;
@class V2TIMConversation;
@class V2TIMGroupAtInfo;

/////////////////////////////////////////////////////////////////////////////////
//
//                         消息会话相关接口
//
/////////////////////////////////////////////////////////////////////////////////

@interface V2TIMManager (Conversation)

/// 获取会话列表成功的回调，nextSeq：下一次分页拉取的游标 isFinished：会话列表是否已经拉取完毕
typedef void(^V2TIMConversationResultSucc)(NSArray<V2TIMConversation *>*list, uint64_t nextSeq, BOOL isFinished);
/// 获取单个会话成功回调
typedef void(^V2TIMConversationSucc)(V2TIMConversation *conv);
/// 搜索会话列表成功回调
typedef void(^V2TIMConversationListSucc)(NSArray<V2TIMConversation *>*list);
/// 获取会话总未读数回调
typedef void(^V2TIMTotalUnreadMessageCountSucc)(UInt64 totalCount);

/// 会话类型
typedef NS_ENUM(NSInteger, V2TIMConversationType) {
    V2TIM_C2C                             = 1,  ///< 单聊
    V2TIM_GROUP                           = 2,  ///< 群聊
};

/// @ 类型
typedef NS_ENUM(NSInteger, V2TIMGroupAtType) {
    V2TIM_AT_ME                           = 1,  ///< @ 我
    V2TIM_AT_ALL                          = 2,  ///< @ 群里所有人
    V2TIM_AT_ALL_AT_ME                    = 3,  ///< @ 群里所有人并且单独 @ 我
};

/**
 * 1.1 添加会话监听器
 */
- (void)addConversationListener:(id<V2TIMConversationListener>)listener NS_SWIFT_NAME(addConversationListener(listener:));

/**
 * 1.2 移除会话监听器
 */
- (void)removeConversationListener:(id<V2TIMConversationListener>)listener NS_SWIFT_NAME(removeConversationListener(listener:));

/**
 * 1.3 获取会话列表
 *
 * - 一个会话对应一个聊天窗口，比如跟一个好友的 1v1 聊天，或者一个聊天群，都是一个会话。
 * - 由于历史的会话数量可能很多，所以该接口希望您采用分页查询的方式进行调用，每次分页拉取的个数建议为 100 个。
 * - 该接口拉取的是本地缓存的会话，如果服务器会话有更新，SDK 内部会自动同步，然后在 @ref V2TIMConversationListener 回调告知客户。
 * - 如果会话全部拉取完毕，成功回调里面 V2TIMConversationResult 中的 isFinished 获取字段值为 YES。
 *
 * @note 会话排序规则
 * - 5.5.892 及以后版本, 该接口获取的会话列表默认已经按照会话 orderKey 做了排序，orderKey 值越大，代表该会话排序越靠前。
 * - 5.5.892 以前版本，该接口获取的会话列表默认已经按照会话 lastMessage -> timestamp 做了排序，timestamp 越大，会话越靠前。
 *
 * @param nextSeq   分页拉取的游标，第一次默认取传 0，后续分页拉传上一次分页拉取成功回调里的 nextSeq
 * @param count    分页拉取的个数，一次分页拉取不宜太多，会影响拉取的速度，建议每次拉取 100 个会话
 */
- (void)getConversationList:(uint64_t)nextSeq count:(int)count succ:(V2TIMConversationResultSucc)succ fail:(V2TIMFail)fail;


/**
 * 1.4 获取单个会话
 *
 * @param conversationID  会话唯一 ID, C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 */
- (void)getConversation:(NSString *)conversationID succ:(V2TIMConversationSucc)succ fail:(V2TIMFail)fail;

/**
 * 1.5 获取指定会话列表
 *
 * @param conversationIDList 会话唯一 ID 列表，C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 */
- (void)getConversationList:(NSArray<NSString *> *)conversationIDList succ:(V2TIMConversationListSucc)succ fail:(V2TIMFail)fail;

/**
 *  1.6 删除会话以及该会话中的历史消息
 *
 * @param conversationID 会话唯一 ID，C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 *
 * @note 请注意:
 * - 该会话以及会话中的历史消息，会被 SDK 从本地和服务端一同删除掉，并且不可恢复。
 */
- (void)deleteConversation:(NSString *)conversationID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  1.7 设置会话草稿
 *
 *  @param conversationID 会话唯一 ID，C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 *
 *  只在本地保存，不会存储 Server，不能多端同步，程序卸载重装会失效。
 */
- (void)setConversationDraft:(NSString *)conversationID draftText:(NSString *)draftText succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  1.8 设置会话置顶（5.3.425 及以上版本支持）
 *
 * @param conversationID  会话唯一 ID，C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 * @param isPinned 是否置顶
 */
- (void)pinConversation:(NSString *)conversationID isPinned:(BOOL)isPinned succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  1.9 获取所有会话的未读消息总数（5.3.425 及以上版本支持）
 * @note
 *  - 未读总数会减去设置为免打扰的会话的未读数，即消息接收选项设置为 V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE 或 V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE 的会话。
 */
- (void)getTotalUnreadMessageCount:(V2TIMTotalUnreadMessageCountSucc)succ fail:(V2TIMFail)fail;

/**
 * 设置会话监听器（待废弃接口，请使用 addConversationListener 和 removeConversationListener 接口）
 */
- (void)setConversationListener:(id<V2TIMConversationListener>)listener __attribute__((deprecated("use addConversationListener: instead")));

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         会话变更监听器
//
/////////////////////////////////////////////////////////////////////////////////

@protocol V2TIMConversationListener <NSObject>
@optional
/**
 * 同步服务器会话开始，SDK 会在登录成功或者断网重连后自动同步服务器会话，您可以监听这个事件做一些 UI 进度展示操作。
 */
- (void)onSyncServerStart;

/**
 * 同步服务器会话完成，如果会话有变更，会通过 onNewConversation | onConversationChanged 回调告知客户
 */
- (void)onSyncServerFinish;

/**
 * 同步服务器会话失败
 */
- (void)onSyncServerFailed;

/**
 * 有新的会话（比如收到一个新同事发来的单聊消息、或者被拉入了一个新的群组中），可以根据会话的 lastMessage -> timestamp 重新对会话列表做排序。
 */
- (void)onNewConversation:(NSArray<V2TIMConversation*> *) conversationList;

/**
 * 某些会话的关键信息发生变化（未读计数发生变化、最后一条消息被更新等等），可以根据会话的 lastMessage -> timestamp 重新对会话列表做排序。
 */
- (void)onConversationChanged:(NSArray<V2TIMConversation*> *) conversationList;

/**
 * 会话未读总数变更通知（5.3.425 及以上版本支持）
 * @note
 *  - 未读总数会减去设置为免打扰的会话的未读数，即消息接收选项设置为 V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE 或 V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE 的会话。
 */
- (void)onTotalUnreadMessageCountChanged:(UInt64) totalUnreadCount;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         会话对象 V2TIMConversation
//
/////////////////////////////////////////////////////////////////////////////////
/// 会话对象
@interface V2TIMConversation : NSObject

/// 会话类型
@property(nonatomic,assign,readonly) V2TIMConversationType type;

/// 会话唯一 ID，如果是 C2C 单聊，组成方式为 c2c_userID，如果是群聊，组成方式为 group_groupID
@property(nonatomic,strong,readonly) NSString *conversationID;

/// 如果会话类型为 C2C 单聊，userID 会存储对方的用户ID，否则为 nil
@property(nonatomic,strong,readonly) NSString *userID;

/// 如果会话类型为群聊，groupID 会存储当前群的群 ID，否则为 nil
@property(nonatomic,strong,readonly) NSString *groupID;

/// 如果会话类型为群聊，groupType 为当前群类型，否则为 nil
@property(nonatomic,strong,readonly) NSString *groupType;

/// 会话展示名称（群组：群名称 >> 群 ID；C2C：对方好友备注 >> 对方昵称 >> 对方的 userID）
@property(nonatomic,strong,readonly) NSString *showName;

/// 会话展示头像（群组：群头像；C2C：对方头像）
@property(nonatomic,strong,readonly) NSString *faceUrl;

/// 会话未读消息数量,直播群（AVChatRoom）不支持未读计数，默认为 0
@property(nonatomic,assign,readonly) int unreadCount;

/// 消息接收选项（接收 | 接收但不提醒 | 不接收）
@property(nonatomic,assign,readonly) V2TIMReceiveMessageOpt recvOpt;

/**
 * 会话最后一条消息
 * @note 5.5.892 以前版本，请您使用 lastMessage -> timestamp 对会话做排序，timestamp 越大，会话越靠前
 */
@property(nonatomic,strong,readonly) V2TIMMessage *lastMessage;

/// 群会话 @ 信息列表，用于展示 “有人@我” 或 “@所有人” 这两种提醒状态
@property(nonatomic,strong,readonly) NSArray<V2TIMGroupAtInfo *> *groupAtInfolist;

/// 草稿信息，设置草稿信息请调用 setConversationDraft() 接口
@property(nonatomic,strong,readonly) NSString *draftText;

/// 草稿编辑时间，草稿设置的时候自动生成
@property(nonatomic,strong,readonly) NSDate *draftTimestamp;

/// 是否置顶
@property(nonatomic,assign,readonly) BOOL isPinned;

/**
 * 排序字段（5.5.892 及以后版本支持）
 * @note
 * - 排序字段 orderKey 是按照会话的激活时间线性递增的一个数字（注意：不是时间戳，因为同一时刻可能会有多个会话被同时激活）
 * - 5.5.892 及其以后版本，推荐您使用该字段对所有会话进行排序，orderKey 值越大，代表该会话排序越靠前
 * - 当您 “清空会话所有消息” 或者 “逐个删除会话的所有消息” 之后，会话的 lastMessage 变为空，但会话的 orderKey 不会改变；如果想保持会话的排序位置不变，可以使用该字段对所有会话进行排序
 */
@property(nonatomic,assign,readonly) NSUInteger orderKey;

@end

/// @ 信息
@interface V2TIMGroupAtInfo : NSObject
/// @ 消息序列号，即带有 “@我” 或者 “@所有人” 标记的消息的序列号
@property(nonatomic,assign,readonly) uint64_t seq;

/// @ 提醒类型，分成 “@我” 、“@所有人” 以及 “@我并@所有人” 三类
@property(nonatomic,assign,readonly) V2TIMGroupAtType atType;

@end
