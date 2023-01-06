
#import <Foundation/Foundation.h>
#import "TUIChatConversationModel.h"
#import "TUIMessageCellData.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TUIMessageBaseDataProviderDataSourceChangeType) {
    TUIMessageBaseDataProviderDataSourceChangeTypeInsert,
    TUIMessageBaseDataProviderDataSourceChangeTypeDelete,
    TUIMessageBaseDataProviderDataSourceChangeTypeReload,
};

@class TUIMessageBaseDataProvider;
@protocol TUIMessageBaseDataProviderDataSource <NSObject>

@required
- (void)dataProviderDataSourceWillChange:(TUIMessageBaseDataProvider *)dataProvider;
- (void)dataProviderDataSourceChange:(TUIMessageBaseDataProvider *)dataProvider
                            withType:(TUIMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation;
- (void)dataProviderDataSourceDidChange:(TUIMessageBaseDataProvider *)dataProvider;

@optional
/**
 * 消息已读事件
 *
 * @param userId C2C 消息接收对象
 * @param timestamp 已读回执时间，这个时间戳之前的消息都可以认为对方已读
 */
/**
 * Message read event
 *
 * @param userID recevier of one-to-one message
 * @param timestamp Read receipt time, messages before this timestamp can be considered read by the other party
 */
- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider
ReceiveReadMsgWithUserID:(NSString *)userId
                Time:(time_t)timestamp;

/**
 * 群消息已读事件
 *
 * @param groupID 群 ID
 * @param msgID 消息 ID
 * @param readCount 消息已读数
 * @param unreadCount 消息未读数
 */

/**
 * Group message read event
 *
 * @param groupID Group ID
 * @param msgID Message idenetifier
 * @param readCount Count of read message
 * @param unreadCount Count of unread message
 */
- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider
ReceiveReadMsgWithGroupID:(NSString *)groupID
               msgID:(NSString *)msgID
           readCount:(NSUInteger)readCount
         unreadCount:(NSUInteger)unreadCount;

/**
 * 收到一条新消息, 数据的更改, 刷新, 内部已经处理, 可以在这个方法中做后续的处理
 *
 * @param uiMsg 新消息
 */
/**
 * A new message is received, the data has been changed, refreshed, it has been processed internally, and subsequent processing can be done in this method
 *
 * @param uiMsg The new message
 */
- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider
     ReceiveNewUIMsg:(TUIMessageCellData *)uiMsg;

/**
 * 收到一条撤回消息
 * Reveived a recalled message
 */
- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider
     ReceiveRevokeUIMsg:(TUIMessageCellData *)uiMsg;

/**
 * 在请求新消息完成后、收到新消息时, 会触发该事件
 * 外部可以通过该方法来实现修改要展示的CellData、加入消息(如时间消息)、自定义消息
 *
 * This event is fired when a new message is received after the request for a new message is completed
 * External can use this method to modify the CellData to be displayed, add messages (such as time messages), and customize messages
 */
- (nullable TUIMessageCellData *)dataProvider:(TUIMessageBaseDataProvider *)dataProvider
               CustomCellDataFromNewIMMessage:(V2TIMMessage *)msg;

/// The translationData of MessageCellData changed.
- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider didChangeTranslationData:(TUIMessageCellData *)data;

@end

/**
 * 【模块名称】聊天消息列表视图模型（TUIMessageDataProvider）
 *
 * 【功能说明】负责实现聊天页面中的消息列表的数据处理和业务逻辑
 *  1、视图模型能够通过 IM SDK 提供的接口从服务端拉取消息列表数据，并将数据加载。
 *  2、视图模型能够在用户需要删除会话列表时，同步移除消息列表的数据。
 *
 * 【Module name】Chat message list view model (TUIMessageDataProvider)
 * 【Function description】Responsible for implementing the data processing and business logic of the message list in the chat page
 *  1. The view model can pull the message list data from the server through the interface provided by the IM SDK, and load the data.
 *  2. The view model can synchronously remove the message list data when the user needs to delete the session list.
 */
@interface TUIMessageBaseDataProvider : NSObject

@property (nonatomic, weak) id<TUIMessageBaseDataProviderDataSource>     dataSource;

@property (nonatomic, strong, readonly) NSArray<TUIMessageCellData *> *uiMsgs;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSNumber *> *heightCache;
@property (nonatomic, assign, readonly) BOOL isLoadingData;
@property (nonatomic, assign, readonly) BOOL isNoMoreMsg;
@property (nonatomic, assign, readonly) BOOL isFirstLoad;

/**
 * loadMessage 请求的分页大小, default is 20
 *
 * Count of per page, default is 20.
 */
@property (nonatomic, assign) NSInteger pageCount;

- (instancetype)initWithConversationModel:(TUIChatConversationModel *)conversationModel;

- (void)loadMessageSucceedBlock:(void (^)(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> *newMsgs))SucceedBlock FailBlock:(V2TIMFail)FailBlock;

- (void)sendUIMsg:(TUIMessageCellData *)uiMsg
   toConversation:(TUIChatConversationModel *)conversationData
    willSendBlock:(void(^)(BOOL isReSend, TUIMessageCellData *dateUIMsg))willSendBlock
        SuccBlock:(nullable V2TIMSucc)succ
        FailBlock:(nullable V2TIMFail)fail;

- (void)revokeUIMsg:(TUIMessageCellData *)uiMsg
          SuccBlock:(nullable V2TIMSucc)succ
          FailBlock:(nullable V2TIMFail)fail;

- (void)deleteUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs
           SuccBlock:(nullable V2TIMSucc)succ
           FailBlock:(nullable V2TIMFail)fail;

- (void)addUIMsg:(TUIMessageCellData *)cellData;

- (void)removeUIMsg:(TUIMessageCellData *)cellData;

- (void)insertUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs atIndexes:(NSIndexSet *)indexes;

- (void)addUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs;

- (void)replaceUIMsg:(TUIMessageCellData *)cellData atIndex:(NSUInteger)index;

- (BOOL)removeHeightCache:(NSUInteger)index;
- (BOOL)removeHeightCacheOfData:(TUIMessageCellData *)data;

- (CGFloat)getCellDataHeightAtIndex:(NSUInteger)index Width:(CGFloat)width;

- (CGFloat)getEstimatedHeightForRowAtIndex:(NSUInteger)index;

/**
 * 预处理互动消息、回复消息(异步加载原始消息以及下载对应的缩略图)
 * Preprocessing interactive messages, reply messages (asynchronously loading original messages and downloading corresponding thumbnails)
 */
- (void)preProcessMessage:(NSArray<TUIMessageCellData *> *)uiMsgs
                 callback:(void(^)(void))callback;

/**
 * 发送最新消息的已读回执
 * Send read receipts for latest messages
 */
- (void)sendLatestMessageReadReceipt;

/**
 * 发送指定 index 消息的已读回执
 * Send a read receipt for the specified index message
 */
- (void)sendMessageReadReceiptAtIndexes:(NSArray *)indexes;

/**
 * 通过 msgID 获取到 message 的 index
 * Get the index of the message in the mesage data through msgID
 */
- (NSInteger)getIndexOfMessage:(NSString *)msgID;

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs;

- (void)clearUIMsgList;

- (void)preProcessReplyMessageV2:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void(^)(void))callback; // subclass override required
@end

@interface TUIMessageBaseDataProvider (IMSDK)
/// imsdk interface call
+ (NSString *)sendMessage:(V2TIMMessage *)message
           toConversation:(TUIChatConversationModel *)conversationData
           isSendPushInfo:(BOOL)isSendPushInfo
         isOnlineUserOnly:(BOOL)isOnlineUserOnly
                 priority:(V2TIMMessagePriority)priority
                 Progress:(nullable V2TIMProgress)progress
                SuccBlock:(nullable V2TIMSucc)succ
                FailBlock:(nullable V2TIMFail)fail;

+ (void)markC2CMessageAsRead:(NSString *)userID
                        succ:(nullable V2TIMSucc)succ
                        fail:(nullable V2TIMFail)fail;

+ (void)markGroupMessageAsRead:(NSString *)groupID
                          succ:(nullable V2TIMSucc)succ
                          fail:(nullable V2TIMFail)fail;

+ (void)markConversationAsUndead:(NSArray<NSString *> *)conversationIDList
                      enableMark:(BOOL)enableMark;

+ (void)revokeMessage:(V2TIMMessage *)msg
                 succ:(nullable V2TIMSucc)succ
                 fail:(nullable V2TIMFail)fail;

+ (void)deleteMessages:(NSArray<V2TIMMessage *>*)msgList
                  succ:(nullable V2TIMSucc)succ
                  fail:(nullable V2TIMFail)fail;


+ (void)modifyMessage:(V2TIMMessage *)msg
           completion:(V2TIMMessageModifyCompletion)completion;

/**
 * 发送消息已读回执
 * Send message read receipts
 */
+ (void)sendMessageReadReceipts:(NSArray *)msgs;

/**
 * 获取群消息已读、未读成员列表
 * Getting the list of read and unread members of group messages
 */
+ (void)getReadMembersOfMessage:(V2TIMMessage *)msg
                         filter:(V2TIMGroupMessageReadMembersFilter)filter
                        nextSeq:(NSUInteger)nextSeq
                     completion:(void (^)(int code, NSString *desc, NSArray *members, NSUInteger nextSeq, BOOL isFinished))block;

/**
 * 获取消息的阅读信息回执
 * Getting the read receipt of the message
 */
+ (void)getMessageReadReceipt:(NSArray *)messages
                         succ:(nullable V2TIMMessageReadReceiptsSucc)succ
                         fail:(nullable V2TIMFail)fail;

/// message -> cellData
+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message;
+ (nullable TUIMessageCellData *)getSystemMsgFromDate:(NSDate *)date;
+ (TUIMessageCellData *)getRevokeCellData:(V2TIMMessage *)message;

/// message -> displayString
+ (NSString *)getDisplayString:(V2TIMMessage *)message;
+ (NSString *)getRevokeDispayString:(V2TIMMessage *)message;
+ (NSString *)getGroupTipsDisplayString:(V2TIMMessage *)message;

/// message <-> info
+ (V2TIMMessage *)getCustomMessageWithJsonData:(NSData *)data;
+ (NSMutableArray *)getUserIDList:(NSArray<V2TIMGroupMemberInfo *> *)infoList;
+ (NSString *)getShowName:(V2TIMMessage *)message;
+ (NSString *)getOpUserName:(V2TIMGroupMemberInfo *)info;
+ (NSMutableArray *)getUserNameList:(NSArray<V2TIMGroupMemberInfo *> *)infoList;
+ (NSString *)getUserName:(V2TIMGroupTipsElem *)tips with:(NSString *)userId;

/// translate
- (void)translateCellData:(TUIMessageCellData *)data
           containerWidth:(float)containerWidth;

@end

NS_ASSUME_NONNULL_END
