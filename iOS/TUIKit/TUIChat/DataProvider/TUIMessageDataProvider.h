
#import <Foundation/Foundation.h>
#import "TUIChatConversationModel.h"
#import "TUIDefine.h"
#import "TUIMessageCellData.h"

//@class TUIMessageCellData;
@class TUITextMessageCellData;
@class TUIFaceMessageCellData;
@class TUIImageMessageCellData;
@class TUIVoiceMessageCellData;
@class TUIVideoMessageCellData;
@class TUIFileMessageCellData;
@class TUISystemMessageCellData;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TUIMessageDataProviderDataSourceChangeType) {
    TUIMessageDataProviderDataSourceChangeTypeInsert,
    TUIMessageDataProviderDataSourceChangeTypeDelete,
    TUIMessageDataProviderDataSourceChangeTypeReload,
};

@class TUIMessageDataProvider;
@protocol TUIMessageDataProviderDataSource <NSObject>

@required
- (void)dataProviderDataSourceWillChange:(TUIMessageDataProvider *)dataProvider;
- (void)dataProviderDataSourceChange:(TUIMessageDataProvider *)dataProvider
                            withType:(TUIMessageDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation;
- (void)dataProviderDataSourceDidChange:(TUIMessageDataProvider *)dataProvider;

@optional
/**
 * 消息已读事件
 * @param userId C2C 消息接收对象
 * @param timestamp 已读回执时间，这个时间戳之前的消息都可以认为对方已读
 */
- (void)dataProvider:(TUIMessageDataProvider *)dataProvider
ReceiveReadMsgWithUserID:(NSString *)userId
                Time:(time_t)timestamp;

/**
 * 群消息已读事件
 * @param groupID 群 ID
 * @param msgID 消息 ID
 * @param readCount 消息已读数
 * @param unreadCount 消息未读数
 */
- (void)dataProvider:(TUIMessageDataProvider *)dataProvider
ReceiveReadMsgWithGroupID:(NSString *)groupID
               msgID:(NSString *)msgID
           readCount:(NSUInteger)readCount
         unreadCount:(NSUInteger)unreadCount;

/**
 * 收到一条新消息, 数据的更改, 刷新, 内部已经处理, 可以在这个方法中做后续的处理
 * @param uiMsg 新消息
 */
- (void)dataProvider:(TUIMessageDataProvider *)dataProvider
     ReceiveNewUIMsg:(TUIMessageCellData *)uiMsg;

/**
 * 收到一条撤回消息
 * @param uiMsg 撤回消息
 */
- (void)dataProvider:(TUIMessageDataProvider *)dataProvider
     ReceiveRevokeUIMsg:(TUIMessageCellData *)uiMsg;

/**
 * 在请求新消息完成后、收到新消息时, 会触发该事件
 * 外部可以通过该方法来实现修改要展示的CellData、加入消息(如时间消息)、自定义消息
 * @param msg 原始的IM消息
 */
- (nullable TUIMessageCellData *)dataProvider:(TUIMessageDataProvider *)dataProvider
               CustomCellDataFromNewIMMessage:(V2TIMMessage *)msg;
@end

/**
 * 【模块名称】聊天消息列表视图模型（TUIMessageDataProvider）
 *
 * 【功能说明】负责实现聊天页面中的消息列表的数据处理和业务逻辑
 *  1、视图模型能够通过 IM SDK 提供的接口从服务端拉取会话列表数据，并将数据加载。
 *  2、视图模型能够在用户需要删除会话列表时，同步移除会话列表的数据。
 */
@interface TUIMessageDataProvider : NSObject

@property (nonatomic, weak) id<TUIMessageDataProviderDataSource>     dataSource;

@property (nonatomic, readonly) NSArray<TUIMessageCellData *> *uiMsgs;
@property (nonatomic, readonly) NSDictionary<NSString *, NSNumber *> *heightCache;
@property (nonatomic, readonly) BOOL isLoadingData;
@property (nonatomic, readonly) BOOL isNoMoreMsg;
@property (nonatomic, readonly) BOOL isFirstLoad;
/// loadMessage请求的分页大小, default is 20
@property (nonatomic) int pageCount;

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

- (CGFloat)getCellDataHeightAtIndex:(NSUInteger)index Width:(CGFloat)width;

+ (NSArray *)getCustomMessageInfo;

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message;

// 预处理互动消息、回复消息(异步加载原始消息以及下载对应的缩略图)
//Preprocessing interactive messages, reply messages (asynchronously loading original messages and downloading corresponding thumbnails)
- (void)preProcessMessage:(NSArray<TUIMessageCellData *> *)uiMsgs
                 callback:(void(^)(void))callback;

// 发送最新消息的已读回执
- (void)sendLatestMessageReadReceipt;

// 发送指定 index 消息的已读回执
- (void)sendMessageReadReceiptAtIndexes:(NSArray *)indexes;

// 通过 msgID 获取到 message 的 index
- (NSInteger)getIndexOfMessage:(NSString *)msgID;

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs;

@end

@interface TUIMessageDataProvider (IMSDK)

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

+ (void)revokeMessage:(V2TIMMessage *)msg
                 succ:(nullable V2TIMSucc)succ
                 fail:(nullable V2TIMFail)fail;

+ (void)deleteMessages:(NSArray<V2TIMMessage *>*)msgList
                  succ:(nullable V2TIMSucc)succ
                  fail:(nullable V2TIMFail)fail;

+ (void)modifyMessage:(V2TIMMessage *)msg
           completion:(V2TIMMessageModifyCompletion)completion;

+ (V2TIMMessage *)getCustomMessageWithJsonData:(NSData *)data;

+ (V2TIMMessage *)getVideoMessageWithURL:(NSURL *)url;

+ (NSString *)getShowName:(V2TIMMessage *)message;

+ (NSString *)getDisplayString:(V2TIMMessage *)message;

+ (void)sendMessageReadReceipts:(NSArray *)msgs;

// 获取群消息已读、未读成员列表
+ (void)getReadMembersOfMessage:(V2TIMMessage *)msg
                         filter:(V2TIMGroupMessageReadMembersFilter)filter
                        nextSeq:(NSUInteger)nextSeq
                     completion:(void (^)(int code, NSString *desc, NSArray *members, NSUInteger nextSeq, BOOL isFinished))block;

// 获取消息的阅读信息回执
+ (void)getMessageReadReceipt:(NSArray *)messages
                         succ:(nullable V2TIMMessageReadReceiptsSucc)succ
                         fail:(nullable V2TIMFail)fail;

@end

NS_ASSUME_NONNULL_END
