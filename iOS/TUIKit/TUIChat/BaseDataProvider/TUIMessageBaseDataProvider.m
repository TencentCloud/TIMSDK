
#import <AVFoundation/AVFoundation.h>

#import "TUIMessageBaseDataProvider.h"
#import "TUIMessageCell.h"
#import "TUITypingStatusCellData.h"
#import "TUITagsModel.h"
#import "TUIDefine.h"
#import "TUITool.h"
#import "TUILogin.h"
#import "NSString+TUIUtil.h"
#import "TUIMessageProgressManager.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIChatConfig.h"
#import "NSString+TUIEmoji.h"

/**
 * 消息上方的日期时间间隔, 单位秒 , default is (5 * 60)
 * Date time interval above the message in the UIMessageCell, in seconds, default is (5 * 60)
 */
#define MaxDateMessageDelay 5 * 60

@interface TUIMessageBaseDataProvider ()<V2TIMAdvancedMsgListener, TUIMessageProgressManagerDelegate>
@property (nonatomic, strong) TUIChatConversationModel *conversationModel;
@property (nonatomic, strong) NSMutableArray<TUIMessageCellData *> *uiMsgs_;
@property (nonatomic, strong) NSMutableSet<NSString *> *sentReadGroupMsgSet;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *heightCache_;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) BOOL isNoMoreMsg;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, strong) V2TIMMessage *lastMsg;
@property (nonatomic, strong) V2TIMMessage *msgForDate;
@end

@implementation TUIMessageBaseDataProvider

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
        _uiMsgs_ = [NSMutableArray array];
    }
    return _uiMsgs_;
}

- (NSMutableDictionary<NSString *,NSNumber *> *)heightCache_ {
    if (_heightCache_ == nil) {
        _heightCache_ = [NSMutableDictionary dictionary];
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
            [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageBaseDataProviderDataSourceChangeTypeReload atIndex:index animation:YES];
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
        @autoreleasepool {        
            for (TUIMessageCellData *uiMsg in cellDataList) {
                [self addUIMsg:uiMsg];
                [self.dataSource dataProviderDataSourceChange:self
                                                     withType:TUIMessageBaseDataProviderDataSourceChangeTypeInsert
                                                      atIndex:(self.uiMsgs_.count - 1)
                                                    animation:YES];
            }
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
            cellData = [self.class getCellData:msg];
        }
        if (cellData) {
            TUIMessageCellData *dateMsg = [self getSystemMsgFromDate:msg.timestamp];
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
                TUIMessageCellData *revokeCellData = [self.class getRevokeCellData:uiMsg.innerMessage];
                [self replaceUIMsg:revokeCellData atIndex:index];
                [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageBaseDataProviderDataSourceChangeTypeReload atIndex:index animation:YES];
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
                                                             withType:TUIMessageBaseDataProviderDataSourceChangeTypeReload
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
            [self insertUIMsgs:uiMsgs atIndexes:indexSet];
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
    NSArray *arrayWithoutDuplicates = [self getIDsAboutWhoUseModifyMessage:uiMsgs];
    NSMutableDictionary * modifyUserMap = [NSMutableDictionary dictionaryWithCapacity:3];
    
    dispatch_group_enter(group);
    if (self.conversationModel.groupID.length>0 && arrayWithoutDuplicates.count > 0) {
        [[V2TIMManager sharedInstance] getGroupMembersInfo:self.conversationModel.groupID  memberList:arrayWithoutDuplicates succ:^(NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
            [memberList enumerateObjectsUsingBlock:^(V2TIMGroupMemberFullInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TUITagsUserModel * userModel = [[TUITagsUserModel alloc] init];
                userModel.userID = obj.userID;
                userModel.friendRemark = obj.friendRemark;
                userModel.nameCard = obj.nameCard;
                userModel.nickName = obj.nickName;
                userModel.faceURL = obj.faceURL;
                if (userModel && userModel.userID.length >0 ) {
                    [modifyUserMap setObject:userModel forKey:userModel.userID];
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
                userModel.faceURL = obj.friendInfo.userFullInfo.faceURL;
                if (userModel && userModel.userID.length >0 ) {
                    [modifyUserMap setObject:userModel forKey:userModel.userID];
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
            
            if([modifyUserMap allKeys].count > 0) {
                myData.messageModifyUserInfos = modifyUserMap;
            }
            
            __weak typeof(myData) weakMyData = myData;
            static TUIMessageCell * cell = nil;
            if (cell == nil) {
                cell = [[TUIMessageCell alloc] initWithFrame:CGRectZero];
            }
            if ([myData.messageModifyReacts isKindOfClass:NSDictionary.class] && [myData.messageModifyReacts allKeys].count >0 ) {
                [cell prepareReactTagUI:cell.container];
                [cell fillWithData:myData];
                [cell layoutIfNeeded];
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
    return;
}

// Find all ids that who use React Emoji / reply
- (NSArray *)getIDsAboutWhoUseModifyMessage:(NSArray<TUIMessageCellData *> *)uiMsgs {
    NSMutableArray *hasReactArray = [NSMutableArray arrayWithCapacity:3];
    
    for (TUIMessageCellData *cellData in uiMsgs) {
        TUIMessageCellData *myData = (TUIMessageCellData *)cellData;
        
        // Emoji React
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
        
        // Replies
        if ([myData.messageModifyReplies isKindOfClass:NSArray.class] && myData.messageModifyReplies.count >0 ) {
            [myData.messageModifyReplies enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj &&[obj isKindOfClass:NSDictionary.class] ) {
                    NSDictionary *dic = (NSDictionary *)obj;
                    if (IS_NOT_EMPTY_NSSTRING(dic[@"messageSender"])) {
                        [hasReactArray addObject:dic[@"messageSender"]];
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
            
            // Update sender
            uiMsg.identifier = [TUILogin getUserID];
            
            [self.dataSource dataProviderDataSourceWillChange:self];
            
            // Handle data
            if (isReSent) {
                NSInteger row = [self.uiMsgs indexOfObject:uiMsg];
                [self removeUImsgAtIndex:row];
                [self.dataSource dataProviderDataSourceChange:self
                                                     withType:TUIMessageBaseDataProviderDataSourceChangeTypeDelete
                                                      atIndex:row
                                                    animation:YES];
            }
            if (dateMsg) {
                [self addUIMsg:dateMsg];
                [self.dataSource dataProviderDataSourceChange:self
                                                     withType:TUIMessageBaseDataProviderDataSourceChangeTypeInsert
                                                      atIndex:(self.uiMsgs.count - 1)
                                                    animation:YES];
            }
            [self addUIMsg:uiMsg];
            [self.dataSource dataProviderDataSourceChange:self
                                                 withType:TUIMessageBaseDataProviderDataSourceChangeTypeInsert
                                                  atIndex:(self.uiMsgs.count - 1)
                                                animation:self];
            
            [self.dataSource dataProviderDataSourceDidChange:self];
            
            if (willSendBlock) {
                willSendBlock(isReSent, dateMsg);
            }
            
            if (dateMsg) {
                self.msgForDate = imMsg;
            }
            
            uiMsg.msgID = [self.class sendMessage:imMsg
                                    toConversation:conversationData
                                    isSendPushInfo:YES
                                   isOnlineUserOnly:NO
                                           priority:V2TIM_PRIORITY_NORMAL
                                           Progress:^(uint32_t progress) {
                [TUIMessageProgressManager.shareManager appendProgress:uiMsg.msgID progress:progress];
            }
                                        
                                        SuccBlock:^{
                                                        if (succ) {
                                                            succ();
                                                        }
                                                        [TUIMessageProgressManager.shareManager notifyMessageSendingResult:uiMsg.msgID
                                                                                                                    result:TUIMessageSendingResultTypeSucc];
                                                    } FailBlock:^(int code, NSString *desc) {
                                                        if (fail) {
                                                            fail(code, desc);
                                                        }
                                                        [TUIMessageProgressManager.shareManager notifyMessageSendingResult:uiMsg.msgID
                                                                                                                    result:TUIMessageSendingResultTypeFail];
                                                    }];
            uiMsg.name = [self.class getShowName:uiMsg.innerMessage];
            
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
    [self.class revokeMessage:imMsg succ:^{
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

- (void)insertUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs atIndexes:(NSIndexSet *)indexes {
    [self.uiMsgs_ insertObjects:uiMsgs atIndexes:indexes];
}

- (void)addUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs {
    [self.uiMsgs_ addObjectsFromArray:uiMsgs];
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

- (BOOL)removeHeightCache:(NSUInteger)index {
    if (index < self.uiMsgs.count) {
        TUIMessageCellData *oldMsg = self.uiMsgs[index];
        NSString *key = [self heightCacheKeyFromMsg:oldMsg];
        if ([self.heightCache_ objectForKey:key]) {
            [self.heightCache_ removeObjectForKey:key];
            return YES;
        }
    }
    return NO;
}

- (BOOL)removeHeightCacheOfData:(TUIMessageCellData *)data {
    for (TUIMessageCellData *cellData in self.uiMsgs) {
        if (data != nil && cellData == data) {
            NSString *key = [self heightCacheKeyFromMsg:data];
            if ([self.heightCache_ objectForKey:key]) {
                [self.heightCache_ removeObjectForKey:key];
                return YES;
            }
        }
    }
    return NO;
}

- (CGFloat)getCellDataHeightAtIndex:(NSUInteger)index Width:(CGFloat)width {
    CGFloat height = 0;
    @autoreleasepool {
        if (index < self.uiMsgs_.count) {
            TUIMessageCellData *msg = self.uiMsgs_[index];
            NSString *key = [self heightCacheKeyFromMsg:msg];
            height = [[self.heightCache_ objectForKey:key] floatValue];
            if (height == 0) {
                height = [msg heightOfWidth:width];
                [self.heightCache_ setObject:@(height) forKey:key];
            }
        }
    }
    return height;
}

- (NSString *)heightCacheKeyFromMsg:(TUIMessageCellData *)msg {
    return msg.msgID.length == 0 ? [NSString stringWithFormat:@"%p", msg] : msg.msgID;
}

- (CGFloat)getEstimatedHeightForRowAtIndex:(NSUInteger)index {
    @autoreleasepool {
        if (index < self.uiMsgs_.count) {
            TUIMessageCellData *msg = self.uiMsgs_[index];
            CGFloat height = [[self.heightCache_ objectForKey:[self heightCacheKeyFromMsg:msg]] floatValue];
            if (height == 0) {
                height = [msg estimatedHeight];
            }
            return height;
        } else {
            return 60;
        }
    }
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
    [self.class sendMessageReadReceipts:array];
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

- (nullable TUIMessageCellData *)getSystemMsgFromDate:(NSDate *)date {
    if (self.msgForDate == nil
       || fabs([date timeIntervalSinceDate:self.msgForDate.timestamp]) > MaxDateMessageDelay) {
        TUIMessageCellData *system = [self.class getSystemMsgFromDate:date];
        return system;
    }
    return nil;
}

@end


@implementation TUIMessageBaseDataProvider (IMSDK)

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
                    @"content": [self getDisplayString:message]?:@"",
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
        pushInfo.AndroidHuaWeiCategory = @"IM";
    }
    if ([self isGroupCommunity:conversationData.groupType groupID:conversationData.groupID] ||
        [self isGroupAVChatRoom:conversationData.groupType]) {
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

+ (void)markConversationAsUndead:(NSArray<NSString *> *)conversationIDList enableMark:(BOOL)enableMark  {
    [V2TIMManager.sharedInstance markConversation:conversationIDList markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD) enableMark:enableMark succ:nil fail:nil];
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

+ (void)modifyMessage:(V2TIMMessage *)msg
           completion:(V2TIMMessageModifyCompletion)completion {
    [[V2TIMManager sharedInstance] modifyMessage:msg completion:completion];
}

+ (void)sendMessageReadReceipts:(NSArray *)msgs {
    [[V2TIMManager sharedInstance] sendMessageReadReceipts:msgs succ:^{
    } fail:^(int code, NSString *desc) {
        if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
            [TUITool postUnsupportNotificationOfService:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceMessageRead)];
        }
    }];
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
        if (fail) {
            fail(-1, @"messages empty");
        }
        return;
    }
    [[V2TIMManager sharedInstance] getMessageReadReceipts:messages succ:succ fail:fail];
}

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    // subclass override required
    return nil;
}

+ (nullable TUIMessageCellData *)getSystemMsgFromDate:(NSDate *)date {
    // subclass override required
    return nil;
}

+ (TUIMessageCellData *)getRevokeCellData:(V2TIMMessage *)message {
    // subclass override required
    return nil;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    // subclass override required
    return nil;
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


+ (V2TIMMessage *)getCustomMessageWithJsonData:(NSData *)data {
    return [[V2TIMManager sharedInstance] createCustomMessage:data];
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

#pragma mark -- Translate
- (void)translateCellData:(TUIMessageCellData *)data
           containerWidth:(float)containerWidth {
    if (data.innerMessage.elemType != V2TIM_ELEM_TYPE_TEXT) {
        return;
    }
    V2TIMTextElem *textElem = data.innerMessage.textElem;
    if (textElem == nil) {
        return;
    }
    if (![data respondsToSelector:@selector(canTranslate)] ||
        ![data canTranslate]) {
        return;
    }
    
    /// Get at user's nickname by userID
    NSMutableArray *atUserIDs = [data.innerMessage.groupAtUserList mutableCopy];
    if (atUserIDs.count == 0) {
        /// There's no any @user info.
        [self translateData:data atUsers:nil containerWidth:containerWidth];
        return;
    }
    
    /// Find @All info.
    NSMutableArray *atUserIDsExcludingAtAll = [NSMutableArray new];
    NSMutableIndexSet *atAllIndex = [NSMutableIndexSet new];
    for (int i = 0; i < atUserIDs.count; i++) {
        NSString *userID = atUserIDs[i];
        if (![userID isEqualToString:kImSDK_MesssageAtALL]) {
            /// Exclude @All.
            [atUserIDsExcludingAtAll addObject:userID];
        } else {
            /// Record @All's location for later restore.
            [atAllIndex addIndex:i];
        }
    }
    if (atUserIDsExcludingAtAll.count == 0) {
        /// There's only @All info.
        NSMutableArray *atAllNames = [NSMutableArray new];
        for (int i = 0; i < atAllIndex.count; i++) {
            [atAllNames addObject:TUIKitLocalizableString(All)];
        }
        [self translateData:data atUsers:atAllNames containerWidth:containerWidth];
        return;
    }
    [[V2TIMManager sharedInstance] getUsersInfo:atUserIDsExcludingAtAll
                                           succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        NSMutableArray *atUserNames = [NSMutableArray new];
        for (NSString *userID in atUserIDsExcludingAtAll) {
            for (V2TIMUserFullInfo *user in infoList) {
                if ([userID isEqualToString:user.userID]) {
                    [atUserNames addObject:user.nickName ? : user.userID];
                    break;
                }
            }
        }
        
        // Restore @All.
        if (atAllIndex.count > 0) {
            [atAllIndex enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [atUserNames insertObject:TUIKitLocalizableString(All) atIndex:idx];
            }];
        }
        [self translateData:data atUsers:atUserNames containerWidth:containerWidth];
    } fail:^(int code, NSString *desc) {
        [self translateData:data atUsers:atUserIDs containerWidth:containerWidth];
    }];
}

- (void)translateData:(TUIMessageCellData *)data
              atUsers:(NSArray *)atUsers
       containerWidth:(float)containerWidth {
    V2TIMTextElem *textElem = data.innerMessage.textElem;
    [data.translationViewData setContainerWidth:containerWidth];
    [self removeHeightCacheOfData:data];
    
    NSString *target = [self targetLanguage];
    NSDictionary *splitResult = [textElem.text splitTextByEmojiAndAtUsers:atUsers];
    NSArray *textArray = splitResult[kSplitStringTextKey];
    
    if (textArray.count == 0) {
        /// Nothing need to be translated.
        data.translationViewData.text = textElem.text;
        data.translationViewData.status = TUITranslationViewStatusShown;
        if ([self.dataSource respondsToSelector:@selector(dataProvider:didChangeTranslationData:)]) {
            [self.dataSource dataProvider:self didChangeTranslationData:data];
        }
        return;
    }
    
    if (data.translationViewData.text.length > 0) {
        data.translationViewData.status = TUITranslationViewStatusShown;
        if ([self.dataSource respondsToSelector:@selector(dataProvider:didChangeTranslationData:)]) {
            [self.dataSource dataProvider:self didChangeTranslationData:data];
        }
        return;
    } else {
        data.translationViewData.status = TUITranslationViewStatusLoading;
        if ([self.dataSource respondsToSelector:@selector(dataProvider:didChangeTranslationData:)]) {
            [self.dataSource dataProvider:self didChangeTranslationData:data];
        }
    }
    
    /// Send translate request.
    @weakify(self);
    [[V2TIMManager sharedInstance] translateText:textArray
                                  sourceLanguage:nil
                                  targetLanguage:target
                                      completion:^(int code, NSString *desc, NSDictionary<NSString *,NSString *> *result) {
        @strongify(self);
        [self removeHeightCacheOfData:data];
        
        /// Translate failed.
        if (code != 0 || result.count == 0) {
            if (self) {
                [TUITool makeToastError:code msg:desc];
            }
            data.translationViewData.status = TUITranslationViewStatusHidden;
            if ([self.dataSource respondsToSelector:@selector(dataProvider:didChangeTranslationData:)]) {
                [self.dataSource dataProvider:self didChangeTranslationData:data];
            }
            return;
        }

        /// Translate succeeded.
        NSString *text = [NSString replacedStringWithArray:splitResult[kSplitStringResultKey]
                                                     index:splitResult[kSplitStringTextIndexKey]
                                               replaceDict:result];
        data.translationViewData.text = text;
        data.translationViewData.status = TUITranslationViewStatusShown;
        if ([self.dataSource respondsToSelector:@selector(dataProvider:didChangeTranslationData:)]) {
            [self.dataSource dataProvider:self didChangeTranslationData:data];
        }
    }];
}

- (NSString *)targetLanguage {
    NSString *target = nil;
    NSString *curAppLang = [TUIGlobalization tk_localizableLanguageKey];
    if ([curAppLang isEqualToString:@"zh-Hans"] || [curAppLang isEqualToString:@"zh-Hant"]) {
        target = @"zh";
    } else {
        target = @"en";
    }
    return target;
}

@end
