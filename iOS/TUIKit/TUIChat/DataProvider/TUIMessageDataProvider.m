
#import <AVFoundation/AVFoundation.h>

#import "TUIMessageDataProvider.h"
#import "TUIMessageDataProvider+Call.h"
#import "TUIMessageDataProvider+Live.h"
#import "TUIMessageDataProvider+MessageDeal.h"
#import "TUITextMessageCellData.h"
#import "TUISystemMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIFaceMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIMergeMessageCellData.h"
#import "TUIFaceMessageCellData.h"
#import "TUIJoinGroupMessageCellData.h"
#import "TUIReplyMessageCellData.h"
#import "TUITypingStatusCellData.h"
#import "TUIFaceView.h"
#import "TUIDefine.h"
#import "TUITool.h"
#import "TUILogin.h"
#import "NSString+TUIUtil.h"
#import "TUIMessageProgressManager.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIChatConfig.h"

/**
 * 消息上方的日期时间间隔, 单位秒 , default is (5 * 60)
 * Date time interval above the message in the UIMessageCell, in seconds, default is (5 * 60)
 */
#define MaxDateMessageDelay 5 * 60

/**
 * 消息撤回后最大可编辑时间 , default is (2 * 60)
 * The maximum editable time after the message is recalled, default is (2 * 60)
 */
#define MaxReEditMessageDelay 2 * 60

static NSArray *customMessageInfo = nil;

@interface TUIMessageDataProvider ()<V2TIMAdvancedMsgListener, TUIMessageProgressManagerDelegate>
@property (nonatomic) TUIChatConversationModel *conversationModel;
@property (nonatomic) NSMutableArray<TUIMessageCellData *> *uiMsgs_;
@property (nonatomic) NSMutableSet<NSString *> *sentReadGroupMsgSet;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *heightCache_;
@property (nonatomic) BOOL isLoadingData;
@property (nonatomic) BOOL isNoMoreMsg;
@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic) V2TIMMessage *msgForDate;
@property (nonatomic) V2TIMMessage *lastMsg;

@end

@implementation TUIMessageDataProvider

+ (void)load {
    customMessageInfo = @[@{BussinessID : BussinessID_TextLink,
                            TMessageCell_Name : @"TUILinkCell",
                            TMessageCell_Data_Name : @"TUILinkCellData"
                          },
                          @{BussinessID : BussinessID_GroupCreate,
                            TMessageCell_Name : @"TUIGroupCreatedCell",
                            TMessageCell_Data_Name : @"TUIGroupCreatedCellData"
                          },
                          @{BussinessID : BussinessID_Evaluation,
                            TMessageCell_Name : @"TUIEvaluationCell",
                            TMessageCell_Data_Name : @"TUIEvaluationCellData"
                          },
                          @{BussinessID : BussinessID_Order,
                            TMessageCell_Name : @"TUIOrderCell",
                            TMessageCell_Data_Name : @"TUIOrderCellData"
                          },
                          @{BussinessID : BussinessID_Typing,
                            TMessageCell_Name : @"TUIMessageCell",
                            TMessageCell_Data_Name : @"TUITypingStatusCellData"
                          }
    ];
}

+ (NSArray *)getCustomMessageInfo {
    return customMessageInfo;
}

- (instancetype)initWithConversationModel:(TUIChatConversationModel *)conversationModel {
    self = [super init];
    if (self) {
        _conversationModel = conversationModel;
        _isLoadingData = NO;
        _isNoMoreMsg = NO;
        _pageCount = 20;
        _isFirstLoad = YES;
        [self registerTUIKitNotification];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableSet<NSString *> *)sentReadGroupMsgSet {
    if (_sentReadGroupMsgSet == nil) {
        _sentReadGroupMsgSet = [NSMutableSet setWithCapacity:10];
    }
    return _sentReadGroupMsgSet;
}

- (NSMutableArray<TUIMessageCellData *> *)uiMsgs_ {
    if (_uiMsgs_ == nil) {
        _uiMsgs_ = [NSMutableArray arrayWithCapacity:10];
    }
    return _uiMsgs_;
}

- (NSMutableDictionary<NSString *,NSNumber *> *)heightCache_ {
    if (_heightCache_ == nil) {
        _heightCache_ = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _heightCache_;
}

- (NSArray<TUIMessageCellData *> *)uiMsgs {
    return _uiMsgs_;
}
- (NSDictionary<NSString *,NSNumber *> *)heightCache {
    return _heightCache_;
}

#pragma mark - TUIKitNotification
- (void)registerTUIKitNotification {
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageStatusChanged:) name:TUIKitNotification_onMessageStatusChanged object:nil];
}

- (void)onMessageStatusChanged:(NSNotification *)notification
{
    NSString *msgId = notification.object;
    TUIMessageCellData *uiMsg = nil;
    for (uiMsg in self.uiMsgs) {
        if ([uiMsg.msgID isEqualToString:msgId]) {
            [self.dataSource dataProviderDataSourceWillChange:self];
            NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
            [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageDataProviderDataSourceChangeTypeReload atIndex:index animation:YES];
            [self.dataSource dataProviderDataSourceDidChange:self];
            return;
        }
    }
}

#pragma mark - V2TIMAdvancedMsgListener
- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    // immsg -> uimsg
    NSMutableArray *cellDataList = [self transUIMsgFromIMMsg:@[msg]];
    if (cellDataList.count == 0) {
        return;
    }
    
    TUIMessageCellData *lastObj = cellDataList.lastObject;
    
    if ([lastObj isKindOfClass:TUITypingStatusCellData.class]) {
        
        if (![TUIChatConfig defaultConfig].enableTypingStatus) {
            return;
        }
        
        TUITypingStatusCellData * stastusData = (TUITypingStatusCellData *)lastObj;
 
        if (!NSThread.isMainThread) {
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self dealTypingByStatusCellData:stastusData];
            });
            return;
        }
        else {
            [self dealTypingByStatusCellData:stastusData];
        }
        
        return;
    }
    
    @weakify(self)
    [self preProcessMessage:cellDataList callback:^{
        @strongify(self)
        [self.dataSource dataProviderDataSourceWillChange:self];
        for (TUIMessageCellData *uiMsg in cellDataList) {
            [self addUIMsg:uiMsg];
            [self.dataSource dataProviderDataSourceChange:self
                                                 withType:TUIMessageDataProviderDataSourceChangeTypeInsert
                                                  atIndex:(self.uiMsgs_.count - 1)
                                                animation:YES];
        }
        [self.dataSource dataProviderDataSourceDidChange:self];
        
        if ([self.dataSource respondsToSelector:@selector(dataProvider:ReceiveNewUIMsg:)]) {
            /**
             * 注意这里不能取 firstObject，firstObject 有可能是展示系统时间的 SystemMessageCellData
             * Note that firstObject cannot be taken here, firstObject may be SystemMessageCellData that displays system time
             */
            [self.dataSource dataProvider:self ReceiveNewUIMsg:cellDataList.lastObject];
        }
    }];
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs {
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = msgs.count - 1; k >= 0; --k) {
        V2TIMMessage *msg = msgs[k];
        /**
         * 不是当前会话的消息，直接忽略
         * Messages that are not the current session, ignore them directly
         */
        if (![msg.userID isEqualToString:self.conversationModel.userID] && ![msg.groupID isEqualToString:self.conversationModel.groupID]) {
            continue;
        }
        
        TUIMessageCellData *cellData = nil;
        /**
         * 判断是否为外部的自定义消息
         * Determine whether it is a custom message outside the component
         */
        if ([self.dataSource respondsToSelector:@selector(dataProvider:CustomCellDataFromNewIMMessage:)]) {
            cellData = [self.dataSource dataProvider:self CustomCellDataFromNewIMMessage:msg];
        }
        
        /**
         * 判断是否为组件内部消息
         * Determine whether it is a component internal message
         */
        if (!cellData) {
            cellData = [TUIMessageDataProvider getCellData:msg];
        }
        if (cellData) {
            TUISystemMessageCellData *dateMsg = [self getSystemMsgFromDate:msg.timestamp];
            if (dateMsg) {
                self.msgForDate = msg;
                [uiMsgs addObject:dateMsg];
            }
            [uiMsgs addObject:cellData];
        }
    }
    return uiMsgs;
}

/// Received message read receipts, both in group and c2c conversation.
- (void)onRecvMessageReadReceipts:(NSArray<V2TIMMessageReceipt *> *)receiptList {
    if (receiptList.count == 0) {
        NSLog(@"group receipt data is empty, ignore");
        return;
    }
    if (![self.dataSource respondsToSelector:@selector(dataProvider:ReceiveReadMsgWithGroupID:msgID:readCount:unreadCount:)]) {
        NSLog(@"data source can not respond to protocol, ignore");
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (V2TIMMessageReceipt *receipt in receiptList) {
        [dict setObject:receipt forKey:receipt.msgID];
    }
    // update TUIMessageCellData readCount/unreadCount
    for (TUIMessageCellData *data in self.uiMsgs) {
        if ([dict.allKeys containsObject:data.innerMessage.msgID]) {
            V2TIMMessageReceipt *receipt = dict[data.innerMessage.msgID];
            data.messageReceipt = receipt;
            if ([self.dataSource respondsToSelector:@selector(dataProvider:ReceiveReadMsgWithGroupID:msgID:readCount:unreadCount:)]){
                [self.dataSource dataProvider:self ReceiveReadMsgWithGroupID:receipt.groupID msgID:receipt.msgID readCount:receipt.readCount unreadCount:receipt.unreadCount];
            }
        }
    }
}

- (void)onRecvMessageRevoked:(NSString *)msgID {
    @weakify(self)
    [TUITool dispatchMainAsync:^{
        @strongify(self)
        TUIMessageCellData *uiMsg = nil;
        for (uiMsg in self.uiMsgs) {
            if ([uiMsg.msgID isEqualToString:msgID]) {
                [self.dataSource dataProviderDataSourceWillChange:self];
                NSUInteger index = [self.uiMsgs indexOfObject:uiMsg];
                TUISystemMessageCellData *revokeCellData = [TUIMessageDataProvider getRevokeCellData:uiMsg.innerMessage];
                [self replaceUIMsg:revokeCellData atIndex:index];
                [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageDataProviderDataSourceChangeTypeReload atIndex:index animation:YES];
                [self.dataSource dataProviderDataSourceDidChange:self];
                break;
            }
        }
        
        if ([self.dataSource respondsToSelector:@selector(dataProvider:ReceiveRevokeUIMsg:)]) {
            [self.dataSource dataProvider:self ReceiveRevokeUIMsg:uiMsg];
        }
    }];
}

- (void)onRecvMessageModified:(V2TIMMessage *)msg {
    V2TIMMessage *imMsg = msg;
    if (imMsg == nil || ![imMsg isKindOfClass:V2TIMMessage.class]) {
        return;
    }
    
    @weakify(self)
    for (TUIMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.msgID isEqualToString:imMsg.msgID]) {
            NSMutableArray *cellDataList = [self transUIMsgFromIMMsg:@[imMsg]];
            for (TUIMessageCellData *cellData in cellDataList) {
                if ([cellData.msgID isEqualToString:imMsg.msgID]) {
                    cellData.messageReceipt = uiMsg.messageReceipt;
                    break;
                }
            }
            [self preProcessMessage:cellDataList callback:^{
                @strongify(self)
                if (cellDataList.count > 0) {
                    /**
                     * 注意这里不能取 firstObject，firstObject 有可能是展示系统时间的 SystemMessageCellData
                     * Note that firstObject cannot be taken here, firstObject may be SystemMessageCellData that displays system time
                     */
                    TUIMessageCellData *cellData = cellDataList.lastObject;
                    NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
                    if (index < self.uiMsgs.count) {
                        [self.dataSource dataProviderDataSourceWillChange:self];
                        [self replaceUIMsg:cellData atIndex:index];
                        [self.dataSource dataProviderDataSourceChange:self
                                                             withType:TUIMessageDataProviderDataSourceChangeTypeReload
                                                              atIndex:index
                                                            animation:YES];
                        [self.dataSource dataProviderDataSourceDidChange:self];
                    }
                }
            }];
            return;
        }
    }
}
- (void)dealTypingByStatusCellData:(TUITypingStatusCellData *)stastusData {
    
    if (1 == stastusData.typingStatus) {
        //再次收到对方输入中的通知 则重新计时
        //The timer is retimed upon receipt of the notification from the other party's input
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetTypingStatus) object:nil];

        self.conversationModel.otherSideTyping = YES;
        self.conversationModel.title = [NSString stringWithFormat:@"%@...",TUIKitLocalizableString(TUIKitTyping)];
        
        //如果对方没有继续输入，每隔5秒结束状态
        //If the other party does not continue typing, end the status every 5 seconds
        [self performSelector:@selector(resetTypingStatus) withObject:nil afterDelay:5.0];
    }
    else {
        self.conversationModel.otherSideTyping = NO;
    }
}
- (void)resetTypingStatus {
    self.conversationModel.otherSideTyping = NO;
}
#pragma mark - Msgs
- (void)loadMessageSucceedBlock:(void (^)(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> *newMsgs))SucceedBlock FailBlock:(V2TIMFail)FailBlock
{
    if(self.isLoadingData || self.isNoMoreMsg) {
        FailBlock(ERR_SUCC, @"refreshing");
        return;
    }
    self.isLoadingData = YES;

    @weakify(self)
    if (self.conversationModel.userID.length > 0) {
        
        [[V2TIMManager sharedInstance] getC2CHistoryMessageList:self.conversationModel.userID
                                                          count:self.pageCount
                                                        lastMsg:self.lastMsg
                                                           succ:^(NSArray<V2TIMMessage *> *msgs) {
            @strongify(self);
            if(msgs.count != 0){
                self.lastMsg = msgs[msgs.count - 1];
            }
            [self loadMessages:msgs SucceedBlock:SucceedBlock];
        }
                                                           fail:^(int code, NSString *desc) {
            @strongify(self)
            self.isLoadingData = NO;
            if (FailBlock) {
                FailBlock(code, desc);
            }
        }];
    }
    else if (self.conversationModel.groupID.length > 0) {
        
        [[V2TIMManager sharedInstance] getGroupHistoryMessageList:self.conversationModel.groupID
                                                            count:self.pageCount
                                                          lastMsg:self.lastMsg
                                                             succ:^(NSArray<V2TIMMessage *> *msgs) {
            @strongify(self);
            if(msgs.count != 0) {
                self.lastMsg = msgs[msgs.count - 1];
            }
            [self loadMessages:msgs SucceedBlock:SucceedBlock];
        }
                                                             fail:^(int code, NSString *desc) {
            @strongify(self)
            self.isLoadingData = NO;
            if (FailBlock) {
                FailBlock(code, desc);
            }
        }];
    }
}

- (void)loadMessages:(NSArray<V2TIMMessage *> *)msgs
       SucceedBlock:(void (^)(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> *newMsgs))SucceedBlock
{
    NSMutableArray<TUIMessageCellData *> *uiMsgs = [self transUIMsgFromIMMsg:msgs];
    @weakify(self)
    [self preProcessMessage:uiMsgs callback:^{
        @strongify(self)
        if(msgs.count < self.pageCount) {
            self.isNoMoreMsg = YES;
        }
        if(uiMsgs.count != 0) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
            [self.uiMsgs_ insertObjects:uiMsgs atIndexes:indexSet];
        }
        
        self.isLoadingData = NO;
        if (SucceedBlock) {
            SucceedBlock(self.isFirstLoad, self.isNoMoreMsg, uiMsgs);
        }
        self.isFirstLoad = NO;
    }];
}

- (void)preProcessMessage:(NSArray<TUIMessageCellData *> *)uiMsgs
            callback:(void(^)(void))callback   {
    @weakify(self)
    [self preProcessReactMessage:uiMsgs reactCallback:^{
        @strongify(self)
        [self preProcessReplyMessageV2:uiMsgs callback:callback];
    }];

}

- (void)preProcessReactMessage:(NSArray<TUIMessageCellData *> *)uiMsgs reactCallback:(void(^)(void))reactCallback
{
    if (uiMsgs.count == 0) {
        if (reactCallback) {
            reactCallback();
        }
        return;
    }
    dispatch_group_t group = dispatch_group_create();
    NSArray *arrayWithoutDuplicates = [self getIDsAboutWhoUseReactMessage:uiMsgs];
    NSMutableDictionary * reactUserMap = [NSMutableDictionary dictionaryWithCapacity:3];
    
    dispatch_group_enter(group);
    if (self.conversationModel.groupID.length>0 && arrayWithoutDuplicates.count > 0) {
        [[V2TIMManager sharedInstance] getGroupMembersInfo:self.conversationModel.groupID  memberList:arrayWithoutDuplicates succ:^(NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
            [memberList enumerateObjectsUsingBlock:^(V2TIMGroupMemberFullInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    TUITagsUserModel * userModel = [[TUITagsUserModel alloc] init];
                    userModel.userID = obj.userID;
                    userModel.friendRemark = obj.friendRemark;
                    userModel.nameCard = obj.nameCard;
                    userModel.nickName = obj.nickName;
                if (userModel && userModel.userID.length >0 ) {
                    [reactUserMap setObject:userModel forKey:userModel.userID];
                }
            }];
            dispatch_group_leave(group);
        } fail:^(int code, NSString *desc) {
            dispatch_group_leave(group);
        }];
    }
    else  {
        [[V2TIMManager sharedInstance] getFriendsInfo:arrayWithoutDuplicates succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
            [resultList enumerateObjectsUsingBlock:^(V2TIMFriendInfoResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TUITagsUserModel * userModel = [[TUITagsUserModel alloc] init];
                userModel.userID = obj.friendInfo.userID;
                userModel.nickName = obj.friendInfo.userFullInfo.nickName;
                userModel.friendRemark = obj.friendInfo.friendRemark;
                if (userModel && userModel.userID.length >0 ) {
                    [reactUserMap setObject:userModel forKey:userModel.userID];
                }
            }];
            
            dispatch_group_leave(group);

        } fail:^(int code, NSString *desc) {
            dispatch_group_leave(group);

        }];
        
    }

    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        for (TUIMessageCellData *cellData in uiMsgs) {
            TUIMessageCellData *myData = (TUIMessageCellData *)cellData;
            __weak typeof(myData) weakMyData = myData;
            TUIMessageCell * cell = [[TUIMessageCell alloc] initWithFrame:CGRectZero];
            if ([myData.messageModifyReacts isKindOfClass:NSDictionary.class] && [myData.messageModifyReacts allKeys].count >0 ) {
                myData.messageModifyReactUsers = reactUserMap;
                [cell prepareReactTagUI:cell.container];
                [cell fillWithData:myData];
                [cell layoutIfNeeded];
                [cell.tagView layoutIfNeeded];
                [cell.tagView updateView];
                weakMyData.messageModifyReactsSize = cell.tagView.frame.size;
            }
        }
        
        if (reactCallback) {
            reactCallback();
        }
    });
}
- (void)preProcessReplyMessageV2:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void(^)(void))callback
{
    if (uiMsgs.count == 0) {
        if (callback) {
            callback();
        }
        return;
    }
    
    @weakify(self)
    dispatch_group_t group = dispatch_group_create();
    for (TUIMessageCellData *cellData in uiMsgs) {
        if (![cellData isKindOfClass:TUIReplyMessageCellData.class]) {
            continue;
        }
        
        TUIReplyMessageCellData *myData = (TUIReplyMessageCellData *)cellData;
        __weak typeof(myData) weakMyData = myData;
        myData.onFinish = ^{
            @strongify(self)
            [self.dataSource dataProviderDataSourceWillChange:self];
            NSUInteger index = [self.uiMsgs indexOfObject:weakMyData];
            [self.dataSource dataProviderDataSourceChange:self
                                                 withType:TUIMessageDataProviderDataSourceChangeTypeReload
                                                  atIndex:index
                                                animation:NO];
            [self.dataSource dataProviderDataSourceDidChange:self];
        };
        dispatch_group_enter(group);
        [self loadOriginMessageFromReplyData:myData dealCallback:^{
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (callback) {
            callback();
        }
    });
}

// Find all ids that who use React Emoji
- (NSArray *)getIDsAboutWhoUseReactMessage:(NSArray<TUIMessageCellData *> *)uiMsgs {
    NSMutableArray *hasReactArray = [NSMutableArray arrayWithCapacity:3];

    for (TUIMessageCellData *cellData in uiMsgs) {
        TUIMessageCellData *myData = (TUIMessageCellData *)cellData;
        if ([myData.messageModifyReacts isKindOfClass:NSDictionary.class] && [myData.messageModifyReacts allKeys].count >0 ) {
            [myData.messageModifyReacts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                
                if (obj &&[obj isKindOfClass:NSArray.class] ) {
                    NSArray *arr = (NSArray *)obj;
                    if (arr.count >0) {
                        [hasReactArray addObjectsFromArray:obj];
                    }
                }
            }];
        }
    }
    
    NSSet *set = [NSSet setWithArray:hasReactArray];
    NSArray *arrayWithoutOrder = [set allObjects];
    return arrayWithoutOrder;
}
- (void)sendUIMsg:(TUIMessageCellData *)uiMsg
   toConversation:(TUIChatConversationModel *)conversationData
    willSendBlock:(void(^)(BOOL isReSend, TUIMessageCellData *dateUIMsg))willSendBlock
        SuccBlock:(nullable V2TIMSucc)succ
        FailBlock:(nullable V2TIMFail)fail
{
    [self preProcessMessage:@[uiMsg] callback:^{
        [TUITool dispatchMainAsync:^{
            V2TIMMessage *imMsg = uiMsg.innerMessage;
            TUIMessageCellData *dateMsg = nil;
            BOOL isReSent = NO;
            if (uiMsg.status == Msg_Status_Init) {
                // New message
                dateMsg = [self getSystemMsgFromDate:imMsg.timestamp];
            } else if (imMsg) {
                // Re-sent
                isReSent = YES;
                dateMsg = [self getSystemMsgFromDate:[NSDate date]];
            } else {
                if (fail) {
                    fail(ERR_INVALID_PARAMETERS, @"Unknown message state");
                }
                return;
            }
            
            imMsg.isExcludedFromUnreadCount = [TUIConfig defaultConfig].isExcludedFromUnreadCount;
            imMsg.isExcludedFromLastMessage = [TUIConfig defaultConfig].isExcludedFromLastMessage;
            
            // Update send status
            uiMsg.status = Msg_Status_Sending;
            
            // Handle data
            [self.dataSource dataProviderDataSourceWillChange:self];
            if (isReSent) {
                NSInteger row = [self.uiMsgs indexOfObject:uiMsg];
                [self removeUImsgAtIndex:row];
                [self.dataSource dataProviderDataSourceChange:self
                                                     withType:TUIMessageDataProviderDataSourceChangeTypeDelete
                                                      atIndex:row
                                                    animation:YES];
            }
            if (dateMsg) {
                [self addUIMsg:dateMsg];
                [self.dataSource dataProviderDataSourceChange:self
                                                     withType:TUIMessageDataProviderDataSourceChangeTypeInsert
                                                      atIndex:(self.uiMsgs.count - 1)
                                                    animation:YES];
            }
            [self addUIMsg:uiMsg];
            [self.dataSource dataProviderDataSourceChange:self
                                                 withType:TUIMessageDataProviderDataSourceChangeTypeInsert
                                                  atIndex:(self.uiMsgs.count - 1)
                                                animation:self];
            [self.dataSource dataProviderDataSourceDidChange:self];
            
            if (willSendBlock) {
                willSendBlock(isReSent, dateMsg);
            }
            
            if (dateMsg) {
                self.msgForDate = imMsg;
            }

            uiMsg.msgID = [TUIMessageDataProvider sendMessage:imMsg
                                               toConversation:conversationData
                                               isSendPushInfo:YES
                                             isOnlineUserOnly:NO
                                                     priority:V2TIM_PRIORITY_NORMAL
                                                     Progress:^(uint32_t progress) {
                [TUIMessageProgressManager.shareManager appendProgress:uiMsg.msgID progress:progress];
            }
                                                    SuccBlock:succ
                                                    FailBlock:fail];
            uiMsg.name = [TUIMessageDataProvider getShowName:uiMsg.innerMessage];
            
            /**
             * 注意：innerMessage.faceURL 在sendMessage 内部赋值，所以需要放在最后面。 TUIMessageCell 内部监听了 avatarUrl 的变更,所以不需要再次刷新。
             * Notes: innerMessage.faceURL is assigned inside sendMessage, so it needs to be last. TUIMessageCell internally monitors changes to avatarUrl, so it doesn't need to be refreshed again.
             */
            uiMsg.avatarUrl = [NSURL URLWithString:[uiMsg.innerMessage faceURL]];
            
            /**
             * 发送消息需要携带【identifier】，否则再次发送消息，点击【我】的头像会导致无法进入的个人信息页面
             * Sending a message needs to carry [identifier], otherwise sending the message again, clicking on the avatar of [Me] will result in an inaccessible personal information page
             */
            uiMsg.identifier = [uiMsg.innerMessage sender];
        }];
    }];
}

- (void)revokeUIMsg:(TUIMessageCellData *)uiMsg
          SuccBlock:(nullable V2TIMSucc)succ
          FailBlock:(nullable V2TIMFail)fail {
    V2TIMMessage *imMsg = uiMsg.innerMessage;
    if (imMsg == nil) {
        if (fail) {
            fail(ERR_INVALID_PARAMETERS, @"cellData.innerMessage is nil");
        }
        return;
    }
    NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
    if (index == NSNotFound) {
        if (fail) {
            fail(ERR_INVALID_PARAMETERS, @"not found cellData in uiMsgs");
        }
        return;
    }
    
    @weakify(self);
    [TUIMessageDataProvider revokeMessage:imMsg succ:^{
        @strongify(self);
        [self onRecvMessageRevoked:imMsg.msgID];
        if (succ) {
            succ();
        }
    } fail:fail];
}

- (void)deleteUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs
           SuccBlock:(nullable V2TIMSucc)succ
           FailBlock:(nullable V2TIMFail)fail {
    NSMutableArray *uiMsgList = [NSMutableArray array];
    NSMutableArray *imMsgList = [NSMutableArray array];
    for (TUIMessageCellData *uiMsg in uiMsgs) {
        if ([self.uiMsgs containsObject:uiMsg]) {
            [uiMsgList addObject:uiMsg];
            [imMsgList addObject:uiMsg.innerMessage];
        }
    }
    
    if (imMsgList.count == 0) {
        if (fail) {
            fail(ERR_INVALID_PARAMETERS, @"not found uiMsgs");
        }
        return;
    }
    
    @weakify(self);
    [TUIMessageDataProvider deleteMessages:imMsgList succ:^{
        @strongify(self);
        [self.dataSource dataProviderDataSourceWillChange:self];
        for (TUIMessageCellData *uiMsg in uiMsgList) {
            NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
            [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageDataProviderDataSourceChangeTypeDelete atIndex:index animation:YES];
        }
        [self removeUIMsgList:uiMsgList];
        
        [self.dataSource dataProviderDataSourceDidChange:self];
        if (succ) {
            succ();
        }
    } fail:fail];
}


- (void)addUIMsg:(TUIMessageCellData *)cellData {
    [self.uiMsgs_ addObject:cellData];
}
- (void)removeUIMsg:(TUIMessageCellData *)cellData {
    if (cellData) {
        [self.uiMsgs_ removeObject:cellData];
        [self.heightCache_ removeObjectForKey:[self heightCacheKeyFromMsg:cellData]];
    }
}
- (void)removeUIMsgList:(NSArray<TUIMessageCellData *> *)cellDatas {
    for (TUIMessageCellData *uiMsg in cellDatas) {
        [self removeUIMsg:uiMsg];
    }
}
- (void)removeUImsgAtIndex:(NSUInteger)index {
    if (index < self.uiMsgs.count) {
        TUIMessageCellData *msg = self.uiMsgs[index];
        [self removeUIMsg:msg];
    }
}
- (void)clearUIMsgList {
    NSArray *clearArray = [NSArray arrayWithArray:self.uiMsgs];
    [self removeUIMsgList:clearArray];
    self.msgForDate = nil;
    self.uiMsgs_ = nil;
}
- (void)replaceUIMsg:(TUIMessageCellData *)cellData atIndex:(NSUInteger)index {
    if (index < self.uiMsgs.count) {
        TUIMessageCellData *oldMsg = self.uiMsgs[index];
        [self.heightCache_ removeObjectForKey:[self heightCacheKeyFromMsg:oldMsg]];
        [self.uiMsgs_ replaceObjectAtIndex:index withObject:cellData];
    } else {
        [self addUIMsg:cellData];
    }
}
- (CGFloat)getCellDataHeightAtIndex:(NSUInteger)index Width:(CGFloat)width {
    TUIMessageCellData *msg = nil;
    if (index < self.uiMsgs.count) {
        msg = self.uiMsgs[index];
    }
    if (!msg) {
        return 0;
    }
    
    CGFloat height = 0;
    if(self.heightCache.count > index) {
        height = self.heightCache_[msg.msgID].floatValue;
    }
    if (height) {
        return height;
    }
    height = [msg heightOfWidth:width];
    [self.heightCache_ setObject:@(height) forKey:[self heightCacheKeyFromMsg:msg]];
    return height;
}

- (NSString *)heightCacheKeyFromMsg:(TUIMessageCellData *)msg {
    return msg.msgID ?: [NSString stringWithFormat:@"%p", msg];
}

- (void)sendLatestMessageReadReceipt {
    [self sendMessageReadReceiptAtIndexes:@[@(self.uiMsgs.count - 1)]];
}

- (void)sendMessageReadReceiptAtIndexes:(NSArray *)indexes {
    if (indexes.count == 0) {
        NSLog(@"sendMessageReadReceipt, but indexes is empty, ignore");
        return;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (NSNumber *i in indexes) {
        if ([i intValue] < 0 || [i intValue] >= self.uiMsgs_.count) {
            continue;
        }
        TUIMessageCellData *data = self.uiMsgs_[[i intValue]];
        if (data.innerMessage.isSelf) {
            continue;
        }
        if (data.innerMessage == nil) {
            continue;
        }
        // Use Set to avoid sending duplicate element to SDK
        if (data.msgID.length > 0) {
            if ([self.sentReadGroupMsgSet containsObject:data.msgID]) {
                continue;
            } else {
                [self.sentReadGroupMsgSet addObject:data.msgID];
            }
        }
        // If needReadReceipt is NO, receiver won't send message read receipt
        if (!data.innerMessage.needReadReceipt) {
            continue;
        }
        [array addObject:data.innerMessage];
    }
    if (array.count == 0) {
        return;
    }
    [TUIMessageDataProvider sendMessageReadReceipts:array];
}

- (NSInteger)getIndexOfMessage:(NSString *)msgID {
    if (msgID.length == 0){
        return -1;
    }
    for (int i = 0; i < self.uiMsgs.count; i++) {
        TUIMessageCellData *data = self.uiMsgs[i];
        if ([data.msgID isEqualToString:msgID]) {
            return i;
        }
    }
    return -1;
}

+ (void)getReadMembersOfMessage:(V2TIMMessage *)msg
                         filter:(V2TIMGroupMessageReadMembersFilter)filter
                        nextSeq:(NSUInteger)nextSeq
                     completion:(void (^)(int code, NSString *desc, NSArray *members, NSUInteger nextSeq, BOOL isFinished))block {
    [[V2TIMManager sharedInstance] getGroupMessageReadMemberList:msg
                                                          filter:filter
                                                         nextSeq:nextSeq
                                                           count:100
                                                            succ:^(NSMutableArray<V2TIMGroupMemberInfo *> *members, uint64_t nextSeq, BOOL isFinished) {
        if (block) {
            block(0, nil, members, nextSeq, isFinished);
        }
    } fail:^(int code, NSString *desc) {
        if (block) {
            block(code, desc, nil, 0, NO);
        }
    }];
}

+ (void)getMessageReadReceipt:(NSArray *)messages
                         succ:(nullable V2TIMMessageReadReceiptsSucc)succ
                         fail:(nullable V2TIMFail)fail {
    if (messages.count == 0) {
        return;
    }
    [[V2TIMManager sharedInstance] getMessageReadReceipts:messages succ:succ fail:fail];
}

+ (BOOL)isEvaluationCustomMessage:(V2TIMMessage *)message {
    NSArray *evaluations = @[@"evaluate", @"evaluation"];
    return [evaluations containsObject:[self dataParsedFromWebCustomData:message]];
}

+ (BOOL)isOrderCustomMessage:(V2TIMMessage *)message {
    NSArray *orders = @[@"order"];
    return [orders containsObject:[self dataParsedFromWebCustomData:message]];
}

+ (NSString *)dataParsedFromWebCustomData:(V2TIMMessage *)message {
    NSError *error;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"parse customElem data error: %@", error);
        return nil;
    }
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return data[@"businessID"];
}

#pragma mark - CellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    if (message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        return [TUIMessageDataProvider getRevokeCellData:message];
    }
    
    TUIMessageCellData *data = nil;
    switch (message.elemType) { 
        case V2TIM_ELEM_TYPE_TEXT:
        {
            data = [TUITextMessageCellData getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_IMAGE:
        {
            data = [TUIImageMessageCellData getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_SOUND:
        {
            data = [TUIVoiceMessageCellData getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_VIDEO:
        {
            data = [TUIVideoMessageCellData getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_FILE:
        {
            data = [TUIFileMessageCellData getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_FACE:
        {
            data = [TUIFaceMessageCellData getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_GROUP_TIPS:
        {
            data = [self getSystemCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_MERGER:
        {
            data = [TUIMergeMessageCellData getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_CUSTOM:
        {
            if ([self isCallMessage:message]) {
                data = [self getCallCellData:message];
            } else if ([self isLiveMessage:message]) {
                data = [self getLiveCellData:message];
            } else if ([self isEvaluationCustomMessage:message]) {
                data = [self getEvalutionCustomCellData:message];
            } else if ([self isOrderCustomMessage:message]) {
                data = [self getOrderCustomCellData:message];
            } else {
                data = [self getNativeCustomCellData:message];
            }
        }
            break;

        default:
            break;
    }

    if (!data) {
        TUITextMessageCellData *cantSupportCellData = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
        cantSupportCellData.content = TUIKitLocalizableString(TUIKitNotSupportThisMessage);
        data = cantSupportCellData;
        data.reuseId = TTextMessageCell_ReuseId;
    }
    
    /**
     * 判断是否包含「云自定义消息」
     * Determine whether contains cloud custom data
     */
    if (message.cloudCustomData) {
        /**
         * 判断是否包含「回复消息」
         * Determine whether to include "reply-message"
         */
        if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReply]) {
            TUIMessageCellData *replyData = [TUIReplyMessageCellData getCellData:message];
            if (replyData) {
                data = replyData;
            }
        }
        
        /**
         * 判断是否包含「引用消息」
         * Determine whether to include "quote-message"
         */
        if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReference]) {
            TUIMessageCellData *referenceData = [TUIReferenceMessageCellData getCellData:message];
            if (referenceData) {
                data = referenceData;
            }
        }
        
        /**
         * 判断是否包含「消息响应」
         * Determine whether to include "react-message"
         */
        if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReact]) {
            [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReact callback:^(BOOL isContains, id obj) {
                if (isContains) {
                    if(obj && [obj isKindOfClass:NSDictionary.class]) {
                        NSDictionary * dic =  (NSDictionary *)obj;
                        if ([dic isKindOfClass:NSDictionary.class]) {
                            data.messageModifyReacts = dic.copy;
                        }
                    }
                }
            }];
            
        }
        
        /**
         * 判断是否包含「消息回复数」
         * Determine whether to include "replies-message"
         */
        if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReplies]) {
            [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReplies callback:^(BOOL isContains, id obj) {
                if (isContains) {
                    data.showMessageModifyReplies = YES;
                    if(obj && [obj isKindOfClass:NSDictionary.class]) {
                        NSDictionary * dic =  (NSDictionary *)obj;
                        NSString * typeStr =  [TUICloudCustomDataTypeCenter convertType2String:TUICloudCustomDataType_MessageReplies];
                        NSDictionary *messageReplies = [dic valueForKey:typeStr];
                        NSArray *repliesArr = [messageReplies valueForKey:@"replies"];
                        if ([repliesArr isKindOfClass:NSArray.class]) {
                            data.messageModifyReplies = repliesArr.copy;
                        }
                    }
                }
            }];
        }
    }
    
    if (data) {
        data.innerMessage = message;
        data.msgID = message.msgID;
        data.direction = message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
        data.identifier = message.sender;
        data.name = [TUIMessageDataProvider getShowName:message];
        data.avatarUrl = [NSURL URLWithString:message.faceURL];

        /**
         * 展示 showName 字段的条件：
         * 1. 当前消息是群消息
         * 2. 当前消息并非自己发送的消息
         * 3. 当前消息不是系统消息
         *
         * Conditions to display the showName field:
         * 1. The current message is a group message
         * 2. The current message is not a message sent by yourself
         * 3. The current message is not a system message
         */
        if (message.groupID.length > 0 && !message.isSelf
           && ![data isKindOfClass:[TUISystemMessageCellData class]]) {
            data.showName = YES;
        }
        
        /**
         * 更新消息状态
         * Update message status
         */
        switch (message.status) {
            case V2TIM_MSG_STATUS_SEND_SUCC:
                data.status = Msg_Status_Succ;
                break;
            case V2TIM_MSG_STATUS_SEND_FAIL:
                data.status = Msg_Status_Fail;
                break;
            case V2TIM_MSG_STATUS_SENDING:
                data.status = Msg_Status_Sending_2;
                break;
            default:
                break;
        }
        
        /**
         * 更新消息的上传/下载进度
         * Update progress of message uploading/downloading
         */
        {
            NSInteger progress = [TUIMessageProgressManager.shareManager progressForMessage:message.msgID];
            if ([data conformsToProtocol:@protocol(TUIMessageCellDataFileUploadProtocol)]) {
                ((id<TUIMessageCellDataFileUploadProtocol>)data).uploadProgress = progress;
            }
            if ([data conformsToProtocol:@protocol(TUIMessageCellDataFileDownloadProtocol)]) {
                ((id<TUIMessageCellDataFileDownloadProtocol>)data).downladProgress = progress;
                ((id<TUIMessageCellDataFileDownloadProtocol>)data).isDownloading = (progress != 0) && (progress != 100);
            }
        }
    }
    return data;
}

+ (TUIMessageCellData *)getNativeCustomCellData:(V2TIMMessage *)message {
    NSError *error;
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"parse customElem data error: %@", error);
        return nil;
    }
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *businessID = param[BussinessID];
    if (!businessID || ![businessID isKindOfClass:[NSString class]]) {
        return nil;
    }
    for (NSDictionary *messageInfo in customMessageInfo) {
        if ([businessID isEqualToString:messageInfo[BussinessID]]) {
            NSString *cellDataName = messageInfo[TMessageCell_Data_Name];
            Class cls = NSClassFromString(cellDataName);
            if (cls && [cls respondsToSelector:@selector(getCellData:)]) {
                TUIMessageCellData *data = [cls getCellData:message];
                data.reuseId = businessID;
                return data;
            }
        }
    }
    return nil;
}

+ (TUIMessageCellData *)getEvalutionCustomCellData:(V2TIMMessage *)message {
    return [self getWebCustomCellData:message businessID:BussinessID_Evaluation];
}

+ (TUIMessageCellData *)getOrderCustomCellData:(V2TIMMessage *)message {
    return [self getWebCustomCellData:message businessID:BussinessID_Order];
}

+ (TUIMessageCellData *)getWebCustomCellData:(V2TIMMessage *)message businessID:(NSString *)businessID {
    for (NSDictionary *messageInfo in customMessageInfo) {
        if ([businessID isEqualToString:messageInfo[BussinessID]]) {
            NSString *cellDataName = messageInfo[TMessageCell_Data_Name];
            Class cls = NSClassFromString(cellDataName);
            if (cls && [cls respondsToSelector:@selector(getCellData:)]) {
                TUIMessageCellData *data = [cls getCellData:message];
                data.reuseId = businessID;
                return data;
            }
        }
    }
    return nil;
}

+ (TUISystemMessageCellData *)getSystemCellData:(V2TIMMessage *)message {
    V2TIMGroupTipsElem *tip = message.groupTipsElem;
    NSString *opUserName = [self getOpUserName:tip.opMember];
    NSMutableArray<NSString *> *userNameList = [self getUserNameList:tip.memberList];
    NSMutableArray<NSString *> *userIDList = [self getUserIDList:tip.memberList];
    if(tip.type == V2TIM_GROUP_TIPS_TYPE_JOIN || tip.type == V2TIM_GROUP_TIPS_TYPE_INVITE || tip.type == V2TIM_GROUP_TIPS_TYPE_KICKED || tip.type == V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE || tip.type == V2TIM_GROUP_TIPS_TYPE_QUIT){
        TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [self getDisplayString:message];
        joinGroupData.opUserName = opUserName;
        joinGroupData.opUserID = tip.opMember.userID;
        joinGroupData.userNameList = userNameList;
        joinGroupData.userIDList = userIDList;
        joinGroupData.reuseId = TJoinGroupMessageCell_ReuseId;
        return joinGroupData;
    } else {
        TUISystemMessageCellData *sysdata = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        sysdata.content = [self getDisplayString:message];
        sysdata.reuseId = TSystemMessageCell_ReuseId;
        if (sysdata.content.length) {
            return sysdata;
        }
    }
    return nil;
}

#pragma mark - UITextViewDelegate

+ (TUISystemMessageCellData *)getRevokeCellData:(V2TIMMessage *)message{

    TUISystemMessageCellData *revoke = [[TUISystemMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    revoke.reuseId = TSystemMessageCell_ReuseId;
    if(message.isSelf){
        if (message.elemType == V2TIM_ELEM_TYPE_TEXT && fabs([[NSDate date] timeIntervalSinceDate:message.timestamp]) < MaxReEditMessageDelay) {
            revoke.supportReEdit = YES;
        }
        revoke.content = TUIKitLocalizableString(TUIKitMessageTipsYouRecallMessage);
        revoke.innerMessage = message;
        return revoke;
    } else if (message.userID.length > 0){
        revoke.content = TUIKitLocalizableString(TUIkitMessageTipsOthersRecallMessage);
        revoke.innerMessage = message;
        return revoke;
    } else if (message.groupID.length > 0) {
        /**
         * 对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
         * For the name display of group messages, the group business card is displayed first, the nickname has the second priority, and the user ID has the lowest priority.
         */
        NSString *userName = [TUIMessageDataProvider getShowName:message];
        TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
        joinGroupData.opUserID = message.sender;
        joinGroupData.opUserName = userName;
        joinGroupData.reuseId = TJoinGroupMessageCell_ReuseId;
        return joinGroupData;
    }
    return nil;
}

- (nullable TUISystemMessageCellData *)getSystemMsgFromDate:(NSDate *)date {
    if (self.msgForDate == nil
       || fabs([date timeIntervalSinceDate:self.msgForDate.timestamp]) > MaxDateMessageDelay) {
        TUISystemMessageCellData *system = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
        system.content = [TUITool convertDateToStr:date];
        system.reuseId = TSystemMessageCell_ReuseId;
        return system;
    }
    return nil;
}

+ (NSString *)getOpUserName:(V2TIMGroupMemberInfo *)info{
    NSString *opUser;
    if (info.nameCard.length > 0){
        opUser = info.nameCard;
    } else if (info.nickName.length > 0) {
        opUser = info.nickName;
    } else {
        opUser = info.userID;
    }
    return opUser;
}

+ (NSMutableArray *)getUserNameList:(NSArray<V2TIMGroupMemberInfo *> *)infoList{
    NSMutableArray<NSString *> *userNameList = [NSMutableArray array];
    for (V2TIMGroupMemberInfo *info in infoList) {
        if(info.nameCard.length > 0) {
            [userNameList addObject:info.nameCard];
        } else if (info.nickName.length > 0){
            [userNameList addObject:info.nickName];
        }else{
            if (info.userID.length > 0) {
                [userNameList addObject:info.userID];
            }
        }
    }
    return userNameList;
}

+ (NSMutableArray *)getUserIDList:(NSArray<V2TIMGroupMemberInfo *> *)infoList{
    NSMutableArray<NSString *> *userIDList = [NSMutableArray array];
    for (V2TIMGroupMemberInfo *info in infoList) {
        if (info.userID.length > 0) {
            [userIDList addObject:info.userID];
        }
    }
    return userIDList;
}

@end


@implementation TUIMessageDataProvider (IMSDK)

+ (NSString *)sendMessage:(V2TIMMessage *)message
           toConversation:(TUIChatConversationModel *)conversationData
           isSendPushInfo:(BOOL)isSendPushInfo
         isOnlineUserOnly:(BOOL)isOnlineUserOnly
                 priority:(V2TIMMessagePriority)priority
                 Progress:(nullable V2TIMProgress)progress
                SuccBlock:(nullable V2TIMSucc)succ
                FailBlock:(nullable V2TIMFail)fail
{
    NSString *userID = conversationData.userID;
    NSString *groupID = conversationData.groupID;
    NSAssert(userID || groupID, @"userID and groupID cannot be null at same time");
    NSString *conversationID = @"";
    
    if (IS_NOT_EMPTY_NSSTRING(userID)) {
        conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
    }
    
    if (IS_NOT_EMPTY_NSSTRING(groupID)) {
        conversationID = [NSString stringWithFormat:@"group_%@",groupID];
    }
    
    if (IS_NOT_EMPTY_NSSTRING(conversationData.conversationID)) {
        conversationID = conversationData.conversationID;
    }
    
    NSParameterAssert(message);
    
    V2TIMOfflinePushInfo *pushInfo = nil;
    if (isSendPushInfo) {
        pushInfo = [[V2TIMOfflinePushInfo alloc] init];
        BOOL isGroup = groupID.length > 0;
        NSString *senderId = isGroup ? (groupID) : ([TUILogin getUserID]);
        senderId = senderId?:@"";
        NSString *nickName = isGroup ? (conversationData.title) : ([TUILogin getNickName]?:[TUILogin getUserID]);
        nickName = nickName ?: @"";
        NSDictionary *ext = @{
            @"entity": @{
                    @"action": @1,
                    @"content": [self getDisplayString:message],
                    @"sender": senderId,
                    @"nickname": nickName,
                    @"faceUrl": [TUILogin getFaceUrl]?:@"",
                    @"chatType": isGroup?@(V2TIM_GROUP):@(V2TIM_C2C)
            }
        };
        NSData *data = [NSJSONSerialization dataWithJSONObject:ext options:NSJSONWritingPrettyPrinted error:nil];
        pushInfo.ext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        pushInfo.AndroidOPPOChannelID = @"tuikit";
        pushInfo.AndroidSound = TUIConfig.defaultConfig.enableCustomRing ? @"private_ring" : nil;
    }
    if ([TUIMessageDataProvider isGroupCommunity:conversationData.groupType groupID:conversationData.groupID] ||
        [TUIMessageDataProvider isGroupAVChatRoom:conversationData.groupType]) {
        message.needReadReceipt = NO;
    }
    
    // 被隐藏的会话从通讯录入口唤起聊天页面-发送消息，需要清空被隐藏标记
    // Hidden conversation evokes the chat page from the address book entry - to send a message, the hidden flag needs to be cleared
    if (conversationID.length>0) {
        [V2TIMManager.sharedInstance markConversation:@[conversationID] markType:@(V2TIM_CONVERSATION_MARK_TYPE_HIDE) enableMark:NO succ:nil fail:nil];
    }
    
    if (conversationData.userID.length > 0) {
        //C2C
        NSDictionary * cloudCustomDataDic = @{
                @"needTyping":@1,
                @"version":@1,
        };
        [message setCloudCustomData:cloudCustomDataDic forType:messageFeature];
    }
    
    return [V2TIMManager.sharedInstance sendMessage:message
                                           receiver:userID
                                            groupID:groupID
                                           priority:priority
                                     onlineUserOnly:isOnlineUserOnly
                                    offlinePushInfo:pushInfo
                                           progress:progress
                                               succ:^{
        succ();
    }
                                               fail:^(int code, NSString *desc) {
        if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
            [TUITool postUnsupportNotificationOfService:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceMessageRead)];
        }
        fail(code, desc);
    }];
}

+ (BOOL)isGroupCommunity:(NSString *)groupType groupID:(NSString *)groupID {
    return [groupType isEqualToString:@"Community"] || [groupID startsWith:@"@TGS#_@TGS#"];
}

+ (BOOL)isGroupAVChatRoom:(NSString *)groupType {
    return [groupType isEqualToString:@"AVChatRoom"];
}


+ (void)markConversationAsUndead:(NSArray<NSString *> *)conversationIDList enableMark:(BOOL)enableMark  {
    [V2TIMManager.sharedInstance markConversation:conversationIDList markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD) enableMark:enableMark succ:nil fail:nil];
}

+ (void)markC2CMessageAsRead:(NSString *)userID
                        succ:(nullable V2TIMSucc)succ
                        fail:(nullable V2TIMFail)fail {
    [[V2TIMManager sharedInstance] markC2CMessageAsRead:userID succ:succ fail:fail];
}

+ (void)markGroupMessageAsRead:(NSString *)groupID
                          succ:(nullable V2TIMSucc)succ
                          fail:(nullable V2TIMFail)fail {
    [[V2TIMManager sharedInstance] markGroupMessageAsRead:groupID succ:succ fail:fail];
}

+ (void)sendMessageReadReceipts:(NSArray *)msgs {
    [[V2TIMManager sharedInstance] sendMessageReadReceipts:msgs succ:^{
    } fail:^(int code, NSString *desc) {
        if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
            [TUITool postUnsupportNotificationOfService:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceMessageRead)];
        }
    }];
}

+ (void)modifyMessage:(V2TIMMessage *)msg
           completion:(V2TIMMessageModifyCompletion)completion {
    [[V2TIMManager sharedInstance] modifyMessage:msg completion:completion];
}
+ (void)revokeMessage:(V2TIMMessage *)msg
                 succ:(nullable V2TIMSucc)succ
                 fail:(nullable V2TIMFail)fail {
    [[V2TIMManager sharedInstance] revokeMessage:msg succ:succ fail:fail];
}

+ (void)deleteMessages:(NSArray<V2TIMMessage *>*)msgList
                  succ:(nullable V2TIMSucc)succ
                  fail:(nullable V2TIMFail)fail{
    [[V2TIMManager sharedInstance] deleteMessages:msgList succ:succ fail:fail];
}

+ (V2TIMMessage *)getCustomMessageWithJsonData:(NSData *)data {
    return [[V2TIMManager sharedInstance] createCustomMessage:data];
}

+ (V2TIMMessage *)getVideoMessageWithURL:(NSURL *)url {
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", TUIKit_Video_Path, [TUITool genVideoName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:videoPath contents:videoData attributes:nil];
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset =  [AVURLAsset URLAssetWithURL:url options:opts];
    NSInteger duration = (NSInteger)urlAsset.duration.value / urlAsset.duration.timescale;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(192, 192);
    NSError *error = nil;
    CMTime actualTime;
    CMTime time = CMTimeMakeWithSeconds(0.5, 30);
    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imagePath = [TUIKit_Video_Path stringByAppendingString:[TUITool genSnapshotName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createVideoMessage:videoPath type:url.pathExtension duration:duration snapshotPath:imagePath];
    return message;
}

+ (NSString *)getShowName:(V2TIMMessage *)message {
    NSString *showName = message.sender;
    if (message.nameCard.length > 0) {
        showName = message.nameCard;
    } else if (message.friendRemark.length > 0) {
        showName = message.friendRemark;
    } else if (message.nickName.length > 0) {
        showName = message.nickName;
    }
    return showName;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message
{
    NSString *str;
    if(message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED){
        str = [self getRevokeDispayString:message];
    } else {
        switch (message.elemType) {
            case V2TIM_ELEM_TYPE_TEXT:
            {
                str = [TUITextMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_IMAGE:
            {
                str = [TUIImageMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_SOUND:
            {
                str = [TUIVoiceMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_VIDEO:
            {
                str = [TUIVideoMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_FILE:
            {
                str = [TUIFileMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_FACE:
            {
                str = [TUIFaceMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_MERGER:
            {
                str = [TUIMergeMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_GROUP_TIPS:
            {
                str = [self getGroupTipsDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_CUSTOM:
            {
                if ([self isCallMessage:message]) {
                    str = [self getCallMessageDisplayString:message];
                }
                else if ([self isLiveMessage:message]) {
                    str = [self getLiveMessageDisplayString:message];
                }
                else {
                    str = [self getCustomDisplayString:message];
                }
                if (!str) {
                    str = TUIKitLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
                }
            }
                break;
            default:
                break;
        }
    }
    return str;
}

+ (NSString *)getRevokeDispayString:(V2TIMMessage *)message {
    NSString *str = nil;
    if(message.isSelf){
        str = TUIKitLocalizableString(TUIKitMessageTipsYouRecallMessage);
    }
    else if(message.groupID != nil){
        NSString *userString = message.nameCard;;
        if(userString.length == 0){
            userString = message.nickName;
        }
        if (userString.length == 0) {
            userString = message.sender;
        }
        str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsRecallMessageFormat), userString];
    }
    else if(message.userID != nil){
        str = TUIKitLocalizableString(TUIkitMessageTipsOthersRecallMessage);
    }
    return str;
}

+ (NSString *)getGroupTipsDisplayString:(V2TIMMessage *)message {
    V2TIMGroupTipsElem *tips = message.groupTipsElem;
    NSString *opUser = [self getOpUserName:tips.opMember];
    NSMutableArray<NSString *> *userList = [self getUserNameList:tips.memberList];
    NSString *str = nil;
    switch (tips.type) {
            case V2TIM_GROUP_TIPS_TYPE_JOIN:
            {
                if (opUser.length > 0) {
                    if ((userList.count == 0) ||
                        (userList.count == 1 && [opUser isEqualToString:userList.firstObject])) {
                        str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsJoinGroupFormat), opUser];
                    } else {
                        NSString *users = [userList componentsJoinedByString:@"、"];
                        str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsInviteJoinGroupFormat), opUser, users];
                    }
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_INVITE:
            {
                if (userList.count > 0) {
                    NSString *users = [userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsInviteJoinGroupFormat), opUser, users];
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_QUIT:
            {
                if (opUser.length > 0) {
                    str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsLeaveGroupFormat), opUser];
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_KICKED:
            {
                if (userList.count > 0) {
                    NSString *users = [userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsKickoffGroupFormat), opUser, users];
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_SET_ADMIN:
            {
                if (userList.count > 0) {
                    NSString *users = [userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsSettAdminFormat), users];
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN:
            {
                if (userList.count > 0) {
                    NSString *users = [userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsCancelAdminFormat), users];
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE:
            {
                str = [NSString stringWithFormat:@"\"%@\"", opUser];
                for (V2TIMGroupChangeInfo *info in tips.groupChangeInfoList) {
                    switch (info.type) {
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_NAME:
                        {
                            str = [NSString stringWithFormat:TUIKitLocalizableString(TUIkitMessageTipsEditGroupNameFormat), str, info.value];
                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION:
                        {
                            str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupIntroFormat), str, info.value];
                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION:
                        {
                            if (info.value.length) {
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupAnnounceFormat), str, info.value];
                            } else {
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsDeleteGroupAnnounceFormat), str]; 
                            }
                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_FACE:
                        {
                            str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupAvatarFormat), str];
                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER:
                        {
                            if (userList.count) {
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupOwnerFormat), str, userList.firstObject];
                            } else {
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupOwnerFormat), str, info.value];
                            }

                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL:
                        {
                            if (info.boolValue) {
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitSetShutupAllFormat), opUser];
                            } else {
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitCancelShutupAllFormat), opUser];
                            }
                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT:
                        {
                            uint32_t addOpt = info.intValue;
                            NSString *addOptDesc = @"unknown";
                            if (addOpt == V2TIM_GROUP_ADD_FORBID) {
                                addOptDesc = TUIKitLocalizableString(TUIKitGroupProfileJoinDisable);
                            } else if (addOpt == V2TIM_GROUP_ADD_AUTH) {
                                addOptDesc = TUIKitLocalizableString(TUIKitGroupProfileAdminApprove);
                            } else if (addOpt == V2TIM_GROUP_ADD_ANY) {
                                addOptDesc = TUIKitLocalizableString(TUIKitGroupProfileAutoApproval);
                            }
                            str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupAddOptFormat), str, addOptDesc];
                        }
                            break;
                        default:
                            break;
                    }
                }
                if (str.length > 0) {
                    str = [str substringToIndex:str.length - 1];
                }
            }
                break;
        case V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE:
        {
            for (V2TIMGroupChangeInfo *info in tips.memberChangeInfoList) {
                if ([info isKindOfClass:V2TIMGroupMemberChangeInfo.class]) {
                    NSString *userId = [(V2TIMGroupMemberChangeInfo *)info userID];
                    int32_t muteTime = [(V2TIMGroupMemberChangeInfo *)info muteTime];
                    NSString *myId = V2TIMManager.sharedInstance.getLoginUser;
                    NSString *showName = [self.class getUserName:tips with:userId];
                    str = [NSString stringWithFormat:@"%@ %@", [userId isEqualToString:myId] ? TUIKitLocalizableString(You) : showName, muteTime == 0 ? TUIKitLocalizableString(TUIKitMessageTipsUnmute): TUIKitLocalizableString(TUIKitMessageTipsMute)];
                    break;
                }
            }
        }
            break;
            default:
                break;
        }
    return str;
}

+ (NSString *)getUserName:(V2TIMGroupTipsElem *)tips with:(NSString *)userId{
    NSString *str = @"";
    for (V2TIMGroupMemberInfo *info in tips.memberList) {
        if ([info.userID isEqualToString:userId]) {
            if (info.nameCard.length > 0) {
                str = info.nameCard;
            } else if (info.friendRemark.length > 0) {
                str = info.friendRemark;
            } else if (info.nickName.length > 0) {
                str = info.nickName;
            }
            else {
                str = userId;
            }
            break;
        }
  }
  return str;
}
+ (NSString *)getCustomDisplayString:(V2TIMMessage *)message{
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *businessID = param[BussinessID];
    if (!businessID || ![businessID isKindOfClass:[NSString class]]) {
        return nil;
    }
    for (NSDictionary *messageInfo in customMessageInfo) {
        if ([businessID isEqualToString:messageInfo[BussinessID]]) {
            NSString *cellDataName = messageInfo[TMessageCell_Data_Name];
            Class cls = NSClassFromString(cellDataName);
            if (cls && [cls respondsToSelector:@selector(getDisplayString:)]) {
                return [cls getDisplayString:message];
            }
        }
    }
    return nil;
}
@end
