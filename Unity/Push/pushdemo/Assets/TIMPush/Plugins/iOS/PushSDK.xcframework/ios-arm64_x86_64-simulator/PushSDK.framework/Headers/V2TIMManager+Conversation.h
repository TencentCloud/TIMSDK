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

V2TIM_EXPORT @protocol V2TIMConversationListener;
@class V2TIMConversation;
@class V2TIMConversationListFilter;
@class V2TIMConversationOperationResult;
@class V2TIMGroupAtInfo;

/////////////////////////////////////////////////////////////////////////////////
//
//                         消息会话相关接口
//
/////////////////////////////////////////////////////////////////////////////////

V2TIM_EXPORT @interface V2TIMManager (Conversation)

/// 获取会话列表成功的回调，nextSeq：下一次分页拉取的游标 isFinished：会话列表是否已经拉取完毕
typedef void(^V2TIMConversationResultSucc)(NSArray<V2TIMConversation *>* list, uint64_t nextSeq, BOOL isFinished);
/// 获取单个会话成功回调
typedef void(^V2TIMConversationSucc)(V2TIMConversation *conv);
/// 搜索会话列表成功回调
typedef void(^V2TIMConversationListSucc)(NSArray<V2TIMConversation *>*list);
/// 获取会话总未读数回调
typedef void(^V2TIMTotalUnreadMessageCountSucc)(UInt64 totalUnreadCount);
/// 获取会话分组列表成功回调
typedef void (^V2TIMConversationGroupListSucc)(NSArray<NSString *> * groupList);
/// 会话操作成功回调
typedef void (^V2TIMConversationOperationResultSucc)(NSArray<V2TIMConversationOperationResult *> *result);

/// 会话类型
typedef NS_ENUM(NSInteger, V2TIMConversationType) {
    V2TIM_UNKNOWN                         = 0,  ///< 未知
    V2TIM_C2C                             = 1,  ///< 单聊
    V2TIM_GROUP                           = 2,  ///< 群聊
};

/// @ 类型
typedef NS_ENUM(NSInteger, V2TIMGroupAtType) {
    V2TIM_AT_ME                           = 1,  ///< @ 我
    V2TIM_AT_ALL                          = 2,  ///< @ 群里所有人
    V2TIM_AT_ALL_AT_ME                    = 3,  ///< @ 群里所有人并且单独 @ 我
};

/// 会话标记类型
typedef NS_ENUM(NSUInteger, V2TIMConversationMarkType) {
    V2TIM_CONVERSATION_MARK_TYPE_STAR     = 0x1,       ///< 会话标星
    V2TIM_CONVERSATION_MARK_TYPE_UNREAD   = 0x1 << 1,  ///< 会话标记未读（重要会话）
    V2TIM_CONVERSATION_MARK_TYPE_FOLD     = 0x1 << 2,  ///< 会话折叠
    V2TIM_CONVERSATION_MARK_TYPE_HIDE     = 0x1 << 3,  ///< 会话隐藏
};

/////////////////////////////////////////////////////////////////////////////////
//
//                         会话基础接口
//
/////////////////////////////////////////////////////////////////////////////////
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
- (void)getConversationList:(uint64_t)nextSeq count:(int)count succ:(V2TIMConversationResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getConversationList(nextSeq:count:succ:fail:));

/**
 * 1.4 获取单个会话
 *
 * @param conversationID  会话唯一 ID, C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 */
- (void)getConversation:(NSString *)conversationID succ:(V2TIMConversationSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getConversation(conversationID:succ:fail:));

/**
 * 1.5 获取指定会话列表
 *
 * @param conversationIDList 会话唯一 ID 列表，C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 */
- (void)getConversationList:(NSArray<NSString *> *)conversationIDList succ:(V2TIMConversationListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getConversationList(conversationIDList:succ:fail:));

/**
 *  1.6 获取会话列表高级接口（从 6.5 版本开始支持）
 *
 * @param filter 会话 filter
 * @param nextSeq 分页拉取的游标
 * @param count 分页拉取的个数
 *
 */
- (void)getConversationListByFilter:(V2TIMConversationListFilter *)filter nextSeq:(uint64_t)seq count:(uint32_t)count succ:(V2TIMConversationResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getConversationListByFilter(filter:nextSeq:count:succ:fail:));

/**
 *  1.7 删除会话以及该会话中的历史消息
 *
 * @param conversationID 会话唯一 ID，C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 *
 * @note
 * - 该会话以及会话中的历史消息，会被 SDK 从本地和服务端一同删除掉，并且不可恢复。
 */
- (void)deleteConversation:(NSString *)conversationID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(deleteConversation(conversation:succ:fail:));

/**
 *  1.8 删除会话列表（7.1 及以上版本支持）
 *
 * @param conversationIDList 会话唯一 ID 列表，C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 * @param clearMessage 是否删除会话中的消息；设置为 NO 时，保留会话消息；设置为 YES 时，本地和服务器的消息会一起删除，并且不可恢复
 *
 * @note 每次最多支持删除 100 个会话
 */
- (void)deleteConversationList:(NSArray<NSString *> *)conversationIDList clearMessage:(BOOL)clearMessage succ:(V2TIMConversationOperationResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(deleteConversationList(conversationIDList:clearMessage:succ:fail:));

/**
 *  1.9 设置会话草稿
 *
 *  @param conversationID 会话唯一 ID，C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 *
 *  只在本地保存，不会存储 Server，不能多端同步，程序卸载重装会失效。
 */
- (void)setConversationDraft:(NSString *)conversationID draftText:(NSString * _Nullable)draftText succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setConversationDraft(conversationID:draftText:succ:fail:));

/**
 * 1.10 设置会话自定义数据（从 6.5 版本开始支持）
 *
 * @param customData 自定义数据，最大支持 256 bytes
 */
- (void)setConversationCustomData:(NSArray<NSString *> *)conversationIDList customData:(NSData * _Nullable)customData succ:(V2TIMConversationOperationResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(setConversationCustomData(conversationIDList:customData:succ:fail:));

/**
 *  1.11 设置会话置顶（5.3.425 及以上版本支持）
 *
 * @param conversationID  会话唯一 ID，C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 * @param isPinned 是否置顶
 */
- (void)pinConversation:(NSString *)conversationID isPinned:(BOOL)isPinned succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(pinConversation(conversationID:isPinned:succ:fail:));

/**
 * 1.12 标记会话（从 6.5 版本开始支持，需要您购买旗舰版套餐）
 *
 * @param conversationIDList 会话列表
 * @param markType 会话标记类型，取值详见 @V2TIMConversationMarkType。
 * @param enableMark YES：设置标记 NO：取消标记
 *
 * 如果已有标记不能满足您的需求，您可以自定义扩展标记，扩展标记需要满足以下两个条件：
 * 1、扩展标记值不能和 V2TIMConversationMarkType 已有的标记值冲突
 * 2、扩展标记值必须是 0x1LL << n 的位移值（32 <= n < 64，即 n 必须大于等于 32 并且小于 64），比如扩展标记值 0x1LL << 32 表示 "iPhone 在线"
 *
 * @note: 扩展标记值不能设置为 0x1 << 32，要设置为 0x1LL << 32，明确告诉编译器是 64 位的整型常量。
 *
 */
- (void)markConversation:(NSArray<NSString *> *)conversationIDList markType:(NSNumber *)markType enableMark:(BOOL)enableMark succ:(V2TIMConversationOperationResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(markConversation(conversationIDList:markType:enableMark:succ:fail:));

/**
 *  1.13 获取所有会话的未读消息总数（5.3.425 及以上版本支持）
 * @note
 *  - 调用该接口以后，任意会话的未读数发生变化时，SDK 都会给您抛 onTotalUnreadMessageCountChanged 回调。
 *  - 未读总数会减去设置为免打扰的会话的未读数，即消息接收选项设置为 V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE 或 V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE 或 V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE_EXCEPT_AT 的会话。
 */
- (void)getTotalUnreadMessageCount:(V2TIMTotalUnreadMessageCountSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getTotalUnreadMessageCount(succ:fail:));

/**
 *  1.14 获取根据 filter 过滤的会话未读总数（7.0 及以上版本支持）
 *
 * @param filter 会话 filter
 *
 * @note
 *  - 未读总数会减去设置为免打扰的会话的未读数，即消息接收选项设置为 V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE 或 V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE 或 V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE_EXCEPT_AT 的会话。
 */
- (void)getUnreadMessageCountByFilter:(V2TIMConversationListFilter *)filter succ:(V2TIMTotalUnreadMessageCountSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getUnreadMessageCountByFilter(filter:succ:fail:));

/**
 *  1.15 注册监听指定 filter 的会话未读总数变化（7.0 及以上版本支持）
 *
 * @param filter 会话 filter
 *
 * @note
 *  - 当您调用这个接口以后，该 filter 下的未读数发生变化时，SDK 会给您抛 onUnreadMessageCountChangedByFilter 回调。
 */
- (void)subscribeUnreadMessageCountByFilter:(V2TIMConversationListFilter *)filter NS_SWIFT_NAME(subscribeUnreadMessageCountByFilter(filter:));

/**
 *  1.16 取消监听指定 filter 的会话未读总数变化（7.0 及以上版本支持）
 *
 * @param filter 会话 filter
 *
 */
- (void)unsubscribeUnreadMessageCountByFilter:(V2TIMConversationListFilter *)filter NS_SWIFT_NAME(unsubscribeUnreadMessageCountByFilter(filter:));

/**
 *  1.17 清理会话的未读消息计数（7.1 及以上版本支持）
 *
 * @param conversationID  会话唯一 ID， C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 * @param cleanTimestamp  清理时间戳，单位为秒，仅对单聊会话生效，指定清理哪一个 timestamp 之前的未读消息计数；当传入为 0 时，对应会话所有的未读消息将被清理，会话的未读数会清 0
 * @param cleanSequence  清理 sequence，仅对群聊会话生效，指定清理哪一个 sequence 之前的未读消息计数；当传入为 0 时，对应会话所有的未读消息将被清理，会话的未读数会清 0
 *
 * @note
 *  - 当您想清理所有单聊会话的未读消息计数，conversationID 请传入 @"c2c"，即不指定具体的 userID；
 *  - 当您想清理所有群聊会话的未读消息计数，conversationID 请传入 @"group"，即不指定具体的 groupID；
 *  - 当您想清理所有会话的未读消息计数，conversationID 请传入 @“”  或者 nil；
 *  - 该接口调用成功后，SDK 会通过 onConversationChanged 回调将对应会话的最新未读数通知给您。
 */
- (void)cleanConversationUnreadMessageCount:(NSString * _Nullable)conversationID cleanTimestamp:(uint64_t)cleanTimestamp cleanSequence:(uint64_t)cleanSequence succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(cleanConversationUnreadMessageCount(conversationID:cleanTimestamp:cleanSequence:succ:fail:));

/**
 * 1.18 设置会话监听器（待废弃接口，请使用 addConversationListener 和 removeConversationListener 接口）
 */
- (void)setConversationListener:(id<V2TIMConversationListener>)listener NS_SWIFT_NAME(setConversationListener(listener:)) __attribute__((deprecated("use addConversationListener: instead")));


/////////////////////////////////////////////////////////////////////////////////
//
//           会话分组相关接口 （从 6.5 版本开始支持，需要您购买旗舰版套餐）
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 2.1 创建会话分组
 *
 * @param groupName 分组名（必填参数，长度要 > 0，最大支持 32 bytes）
 * @param conversationIDList 会话 ID 列表（必填参数，不能为空）
 *
 * @note 会话分组最大支持 20 个，不再使用的分组请及时删除。
 */
- (void)createConversationGroup:(NSString *)groupName conversationIDList:(NSArray<NSString *> *)conversationIDList succ:(V2TIMConversationOperationResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(createConversationGroup(groupName:conversationIDList:succ:fail:));

/**
 * 2.2 获取会话分组列表
 *
 * @note 该接口获取的是本地缓存的会话分组，建议在 onSyncServerFinish 之后调用。
 */
- (void)getConversationGroupList:(V2TIMConversationGroupListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getConversationGroupList(succ:fail:));

/**
 * 2.3 删除会话分组
 */
- (void)deleteConversationGroup:(NSString *)groupName succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(deleteConversationGroup(groupName:succ:fail:));

/**
 * 2.4 重命名会话分组
 */
- (void)renameConversationGroup:(NSString*)oldName newName:(NSString*)newName succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(renameConversationGroup(oldName:newName:succ:fail:));

/**
 * 2.5 添加会话到一个会话分组
 */
- (void)addConversationsToGroup:(NSString *)groupName conversationIDList:(NSArray<NSString *> *)conversationIDList succ:(V2TIMConversationOperationResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(addConversationsToGroup(groupName:conversationIDList:succ:fail:));

/**
 * 2.6 从一个会话分组中删除会话
 */
- (void)deleteConversationsFromGroup:(NSString *)groupName conversationIDList:(NSArray<NSString *> *)conversationIDList succ:(V2TIMConversationOperationResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(deleteConversationsFromGroup(groupName:conversationIDList:succ:fail:));

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         会话变更监听器
//
/////////////////////////////////////////////////////////////////////////////////

V2TIM_EXPORT @protocol V2TIMConversationListener <NSObject>
@optional
/////////////////////////////////////////////////////////////////////////////////
//        会话基础通知
/////////////////////////////////////////////////////////////////////////////////
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
 * 有新的会话（比如收到一个新同事发来的单聊消息、或者被拉入了一个新的群组中），可以根据会话的 orderKey 重新对会话列表做排序。
 */
- (void)onNewConversation:(NSArray<V2TIMConversation*> *) conversationList NS_SWIFT_NAME(onNewConversation(conversationList:));

/**
 * 某些会话的关键信息发生变化（未读计数发生变化、最后一条消息被更新等等），可以根据会话的 orderKey 重新对会话列表做排序。
 */
- (void)onConversationChanged:(NSArray<V2TIMConversation*> *) conversationList NS_SWIFT_NAME(onConversationChanged(conversationList:));

/**
 * 会话被删除的通知（7.2 及以上版本支持）
 *
 * @note
 * conversationIDList 表示被删除的会话唯一 ID 列表。C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 */
- (void)onConversationDeleted:(NSArray<NSString *> *)conversationIDList NS_SWIFT_NAME(onConversationDeleted(conversationIDList:));

/**
 * 全部会话未读总数变更的通知（5.3.425 及以上版本支持）
 * @note
 *  - 当您调用 getTotalUnreadMessageCount 获取全部会话未读总数以后，任意会话的未读数发生变化时，SDK 都会通过该回调把最新的未读总数通知给您。
 *  - 未读总数会减去设置为免打扰的会话的未读数，即消息接收选项设置为 V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE 或 V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE 或 V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE_EXCEPT_AT 的会话。
 */
- (void)onTotalUnreadMessageCountChanged:(UInt64)totalUnreadCount NS_SWIFT_NAME(onTotalUnreadMessageCountChanged(totalUnreadCount:));

/**
 * 根据 filter 过滤的未读消息总数变更通知（7.0 及以上版本支持）
 * @note
 *  - 您可以调用 subscribeUnreadMessageCountByFilter 注册监听指定 filter 下的未读总数变化，SDK 通过这个回调把最新的未读总数通知给您。
 *  - 您可以注册监听多个不同 filter 下的未读总数变化，这个回调的 filter 参数就是注册监听时指定的 filter，该 filter 携带了 conversationType、conversationGroup 和 markType 三个字段，通过判断这三字段是不是都相同，来区分出不同的 filter。
 *  - 未读总数会减去设置为免打扰的会话的未读数，即消息接收选项设置为 V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE 或 V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE 或 V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE_EXCEPT_AT 的会话。
 */
- (void)onUnreadMessageCountChangedByFilter:(V2TIMConversationListFilter *)filter totalUnreadCount:(UInt64)totalUnreadCount NS_SWIFT_NAME(onUnreadMessageCountChangedByFilter(filter:totalUnreadCount:));

/////////////////////////////////////////////////////////////////////////////////
//        会话分组相关通知（从 6.5 版本开始支持）
/////////////////////////////////////////////////////////////////////////////////
/**
 * 会话分组被创建
 */
- (void)onConversationGroupCreated:(NSString * _Nullable)groupName conversationList:(NSArray<V2TIMConversation *> *)conversationList NS_SWIFT_NAME(onConversationGroupCreated(groupName:conversationList:));

/**
 * 会话分组被删除
 */
- (void)onConversationGroupDeleted:(NSString * _Nullable)groupName NS_SWIFT_NAME(onConversationGroupDeleted(groupName:));

/**
 * 会话分组名变更
 */
- (void)onConversationGroupNameChanged:(NSString * _Nullable)oldName newName:(NSString * _Nullable)newName NS_SWIFT_NAME(onConversationGroupNameChanged(oldName:newName:));

/**
 * 会话分组新增会话
 */
- (void)onConversationsAddedToGroup:(NSString * _Nullable)groupName conversationList:(NSArray<V2TIMConversation *> *)conversationList NS_SWIFT_NAME(onConversationsAddedToGroup(groupName:conversationList:));

/**
 * 会话分组删除会话
 * @note
 * - reason 表示会话从所在分组删除的原因，其取值有：
 * - 当 reason 为 0 时，表示由用户主动调用 deleteConversationsFromGroup 触发
 * - 当 reason 为 1 时，表示添加到分组的会话数量超过 1000，最早添加进分组的会话被淘汰
 */
- (void)onConversationsDeletedFromGroup:(NSString * _Nullable)groupName conversationList:(NSArray<V2TIMConversation *> *)conversationList reason:(uint32_t)reason NS_SWIFT_NAME(onConversationsDeletedFromGroup(groupName:conversationList:reason:));

/**
 * 会话分组删除会话（待废弃接口，请使用 onConversationsDeletedFromGroup:conversationList:reason: 接口）
 */
- (void)onConversationsDeletedFromGroup:(NSString * _Nullable)groupName conversationList:(NSArray<V2TIMConversation *> *)conversationList NS_SWIFT_NAME(onConversationsDeletedFromGroup(groupName:conversationList:)) __attribute__((deprecated("use onConversationsDeletedFromGroup:conversationList:reason: instead")));
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         会话对象 V2TIMConversation
//
/////////////////////////////////////////////////////////////////////////////////
/// 会话对象
V2TIM_EXPORT @interface V2TIMConversation : NSObject

/// 会话类型
@property(nonatomic,assign,readonly) V2TIMConversationType type;

/// 会话唯一 ID，如果是 C2C 单聊，组成方式为 c2c_userID，如果是群聊，组成方式为 group_groupID
@property(nonatomic,strong,readonly,nullable) NSString *conversationID;

/// 如果会话类型为 C2C 单聊，userID 会存储对方的用户ID，否则为 nil
@property(nonatomic,strong,readonly,nullable) NSString *userID;

/// 如果会话类型为群聊，groupID 会存储当前群的群 ID，否则为 nil
@property(nonatomic,strong,readonly,nullable) NSString *groupID;

/// 如果会话类型为群聊，groupType 为当前群类型，否则为 nil
@property(nonatomic,strong,readonly,nullable) NSString *groupType;

/// 会话展示名称（群组：群名称 >> 群 ID；C2C：对方好友备注 >> 对方昵称 >> 对方的 userID）
@property(nonatomic,strong,readonly,nullable) NSString *showName;

/// 会话展示头像（群组：群头像；C2C：对方头像）
@property(nonatomic,strong,readonly,nullable) NSString *faceUrl;

/// 会话未读消息数量,直播群（AVChatRoom）不支持未读计数，默认为 0
@property(nonatomic,assign,readonly) int unreadCount;

/// 消息接收选项（接收 | 接收但不提醒 | 不接收）
@property(nonatomic,assign,readonly) V2TIMReceiveMessageOpt recvOpt;

/**
 * 会话最后一条消息
 * @note 5.5.892 以前版本，请您使用 lastMessage -> timestamp 对会话做排序，timestamp 越大，会话越靠前
 */
@property(nonatomic,strong,readonly,nullable) V2TIMMessage *lastMessage;

/// 群会话 @ 信息列表，用于展示 "有人@我" 或 "@所有人" 这两种提醒状态
@property(nonatomic,strong,readonly,nullable) NSArray<V2TIMGroupAtInfo *> *groupAtInfolist;

/// 草稿信息，设置草稿信息请调用 setConversationDraft() 接口
@property(nonatomic,strong,readonly,nullable) NSString *draftText;

/// 上次设置草稿时的 UTC 时间戳
@property(nonatomic,strong,readonly,nullable) NSDate *draftTimestamp;

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

/// 会话标记列表，取值详见 @V2TIMConversationMarkType（从 6.5 版本开始支持）
@property(nonatomic,strong,readonly,nullable) NSArray<NSNumber *> * markList;

/// 会话自定义数据（从 6.5 版本开始支持）
@property(nonatomic,strong,readonly,nullable) NSData *customData;

/// 会话所属分组列表（从 6.5 版本开始支持）
@property(nonatomic,strong,readonly,nullable) NSArray<NSString *> *conversationGroupList;

/// 最新已读消息的 UTC 时间戳，仅对单聊会话生效（从 7.1 版本开始支持）
@property(nonatomic,assign,readonly) NSUInteger c2cReadTimestamp;

/// 已读消息的 sequence，仅对群聊会话生效（从 7.1 版本开始支持）
@property(nonatomic,assign,readonly) NSUInteger groupReadSequence;

@end

/// 会话 filter
V2TIM_EXPORT @interface V2TIMConversationListFilter : NSObject

/// C2C 或群会话(填 0 代表不过滤此项)
@property(nonatomic,assign) V2TIMConversationType type;

/// 会话分组名称
/// 不设置表示不过滤此项，设置为 @"" 代表过滤不属于任何分组的会话
@property(nonatomic,strong,nullable) NSString *conversationGroup;

/// 标记类型，取值详见 @V2TIMConversationMarkType
/// 不设置表示不过滤此项，设置为 0 代表过滤不含任何标记的会话
@property(nonatomic,assign) NSUInteger markType;

/// 会话未读数
/// 不设置表示不过滤此项，设置为 YES 代表过滤含未读数的会话；设置为 NO 代表过滤不含未读数的会话
@property(nonatomic,assign) BOOL hasUnreadCount;

/// 会话 @ 信息
/// 不设置表示不过滤此项，设置为 YES 代表过滤含群 @ 消息的会话；设置为 NO 代表过滤不含群 @ 消息的会话
@property(nonatomic,assign) BOOL hasGroupAtInfo;
@end

/// @ 信息
V2TIM_EXPORT @interface V2TIMGroupAtInfo : NSObject
/// @ 消息序列号，即带有 “@我” 或者 “@所有人” 标记的消息的序列号
@property(nonatomic,assign,readonly) uint64_t seq;

/// @ 提醒类型，分成 “@我” 、“@所有人” 以及 “@我并@所有人” 三类
@property(nonatomic,assign,readonly) V2TIMGroupAtType atType;

@end

/// 会话操作结果
V2TIM_EXPORT @interface V2TIMConversationOperationResult : NSObject

/// 会话 ID
@property(nonatomic,strong,nullable) NSString* conversationID;

/// 返回码
@property(nonatomic,assign) NSInteger resultCode;

/// 返回信息
@property(nonatomic,strong,nullable) NSString *resultInfo;

@end

