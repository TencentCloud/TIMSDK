
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
#import "TUIFaceView.h"
#import "TUIDefine.h"
#import "TUITool.h"
#import "TUILogin.h"
#import "NSString+TUIUtil.h"
#import "TUIMessageProgressManager.h"

#define MaxDateMessageDelay 5 * 60 /// 消息上方的日期时间间隔, 单位秒 , default is (5 * 60)
#define MaxReEditMessageDelay 2 * 60 /// 消息撤回后最大可编辑时间 , default is (2 * 60)

static NSArray *customMessageInfo = nil;

@interface TUIMessageDataProvider ()<V2TIMAdvancedMsgListener, TUIMessageProgressManagerDelegate>
@property (nonatomic) TUIChatConversationModel *conversationModel;
@property (nonatomic) NSMutableArray<TUIMessageCellData *> *uiMsgs_;
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
    ];
}

+ (NSArray *)getCustomMessageInfo {
    return customMessageInfo;
}

- (instancetype)initWithConversationModel:(TUIChatConversationModel *)conversationModel {
    self = [super init];
    if (self) {
        _conversationModel = conversationModel;
        _uiMsgs_ = [NSMutableArray arrayWithCapacity:10];
        _heightCache_ = [NSMutableDictionary dictionaryWithCapacity:10];
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
/// 收到新消息
- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    // immsg -> uimsg
    NSMutableArray *cellDataList = [self transUIMsgFromIMMsg:@[msg]];
    if (cellDataList.count == 0) {
        return;
    }
    @weakify(self)
    [self preProcessReplyMessage:cellDataList callback:^{
        @strongify(self)
        // 更新数据, 刷新页面
        [self.dataSource dataProviderDataSourceWillChange:self];
        for (TUIMessageCellData *uiMsg in cellDataList) {
            [self addUIMsg:uiMsg];
            [self.dataSource dataProviderDataSourceChange:self
                                                 withType:TUIMessageDataProviderDataSourceChangeTypeInsert
                                                  atIndex:(self.uiMsgs_.count - 1)
                                                animation:YES];
        }
        [self.dataSource dataProviderDataSourceDidChange:self];
        
        // 抛出收到新消息事件
        if ([self.dataSource respondsToSelector:@selector(dataProvider:ReceiveNewUIMsg:)]) {
            // 注意这里不能去 firstObject，firstObject 有可能是展示系统时间的 SystemMessageCellData
            [self.dataSource dataProvider:self ReceiveNewUIMsg:cellDataList.lastObject];
        }        
    }];
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs {
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = msgs.count - 1; k >= 0; --k) {
        V2TIMMessage *msg = msgs[k];
        // 不是当前会话的消息，直接忽略
        if (![msg.userID isEqualToString:self.conversationModel.userID] && ![msg.groupID isEqualToString:self.conversationModel.groupID]) {
            continue;
        }
        
        TUIMessageCellData *cellData = nil;
        // 判断是否为外部的自定义消息
        if ([self.dataSource respondsToSelector:@selector(dataProvider:CustomCellDataFromNewIMMessage:)]) {
            cellData = [self.dataSource dataProvider:self CustomCellDataFromNewIMMessage:msg];
        }
        // 判断是否为组件内部消息
        if (!cellData) {
            cellData = [TUIMessageDataProvider getCellData:msg];
        }
        if (cellData) {
            TUISystemMessageCellData *dateMsg = [self getSystemMsgFromDate:msg.timestamp];
            if (dateMsg) {
                // 更新日期消息
                self.msgForDate = msg;
                [uiMsgs addObject:dateMsg];
            }
            [uiMsgs addObject:cellData];
        }
    }
    return uiMsgs;
}

/// 收到消息已读回执（仅单聊有效）
- (void)onRecvC2CReadReceipt:(NSArray<V2TIMMessageReceipt *> *)receiptList {
    
    if (!receiptList.count) {
        NSLog(@"Receipt Data Error");
        return;
    }
    V2TIMMessageReceipt *receipt = receiptList.firstObject;
    if (receipt && [self.dataSource respondsToSelector:@selector(dataProvider:ReceiveReadMsgWithUserID:Time:)]) {
        [self.dataSource dataProvider:self ReceiveReadMsgWithUserID:receipt.userID Time:receipt.timestamp];
    }
}

/// 收到消息撤回
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
        // 抛出收到消息撤回事件
        if ([self.dataSource respondsToSelector:@selector(dataProvider:ReceiveRevokeUIMsg:)]) {
            [self.dataSource dataProvider:self ReceiveRevokeUIMsg:uiMsg];
        }
    }];
}

/// 消息内容被修改（第三方服务回调修改了消息内容）
- (void)onRecvMessageModified:(V2TIMMessage *)msg {
    V2TIMMessage *imMsg = msg;
    if (imMsg == nil || ![imMsg isKindOfClass:V2TIMMessage.class]) {
        return;
    }
    
    // 更新消息
    @weakify(self)
    for (TUIMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.msgID isEqualToString:imMsg.msgID]) {
            NSMutableArray *cellDataList = [self transUIMsgFromIMMsg:@[imMsg]];
            [self preProcessReplyMessage:cellDataList callback:^{
                @strongify(self)
                if (cellDataList.count > 0) {
                    TUIMessageCellData *cellData =cellDataList.firstObject;
                    [self.dataSource dataProviderDataSourceWillChange:self];
                    NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
                    [self replaceUIMsg:cellData atIndex:index];
                    [self.dataSource dataProviderDataSourceChange:self
                                                         withType:TUIMessageDataProviderDataSourceChangeTypeReload
                                                          atIndex:index
                                                        animation:YES];
                    [self.dataSource dataProviderDataSourceDidChange:self];
                }
            }];
            return;
        }
    }
}

#pragma mark - Msgs
- (void)loadMessageSucceedBlock:(void (^)(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> *newMsgs))SucceedBlock FailBlock:(V2TIMFail)FailBlock
{
    if(self.isLoadingData || self.isNoMoreMsg) {
        FailBlock(ERR_SUCC, @"正在刷新中");
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
    [self preProcessReplyMessage:uiMsgs callback:^{
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

- (void)preProcessReplyMessage:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void(^)(void))callback
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

- (void)sendUIMsg:(TUIMessageCellData *)uiMsg
   toConversation:(TUIChatConversationModel *)conversationData
    willSendBlock:(void(^)(BOOL isReSend, TUIMessageCellData *dateUIMsg))willSendBlock
        SuccBlock:(nullable V2TIMSucc)succ
        FailBlock:(nullable V2TIMFail)fail
{
    [self preProcessReplyMessage:@[uiMsg] callback:^{
        [TUITool dispatchMainAsync:^{
            V2TIMMessage *imMsg = uiMsg.innerMessage;
            TUIMessageCellData *dateMsg = nil;
            BOOL isReSent = NO;
            if (uiMsg.status == Msg_Status_Init) {
                //新消息
                dateMsg = [self getSystemMsgFromDate:imMsg.timestamp];
            } else if (imMsg) {
                //重发
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
            
            // 更新发送状态
            uiMsg.status = Msg_Status_Sending;
            
            // 处理数据
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
            
            // 更新日期消息
            if (dateMsg) {
                self.msgForDate = imMsg;
            }
            
            // 发送请求
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
            // !!!innerMessage.faceURL在sendMessage内部赋值,所以需要放在最后面. TUIMessageCell内部监听了avatarUrl的变更,所以不需要再次刷新
            uiMsg.avatarUrl = [NSURL URLWithString:[uiMsg.innerMessage faceURL]];
            //发送消息需要携带【identifier】，否则再次发送消息，点击【我】的头像会导致无法进入的个人信息页面
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
            }
            else if ([self isLiveMessage:message]) {
                data = [self getLiveCellData:message];
            }
            else {
                data = [self getCustomCellData:message];
            }
        }
            break;

        default:
            break;
    }

    // 判断是否为「回复消息」
    if (message.cloudCustomData) {
        TUIMessageCellData *replyData = [TUIReplyMessageCellData getCellData:message];
        if (replyData) {
            data = replyData;
        }
    }
    
    if (data) {
        data.innerMessage = message;
        data.msgID = message.msgID;
        data.direction = message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
        data.identifier = message.sender;
        data.name = [TUIMessageDataProvider getShowName:message];
        data.avatarUrl = [NSURL URLWithString:message.faceURL];
        // 满足 -> 1、群消息 2、非自己的消息 3、非系统消息 ->展示 showName
        if (message.groupID.length > 0 && !message.isSelf
           && ![data isKindOfClass:[TUISystemMessageCellData class]]) {
            data.showName = YES;
        }
        // 更新消息状态
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
        
        // 更新消息的上传/下载进度
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

+ (TUIMessageCellData *)getCustomCellData:(V2TIMMessage *)message{
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
            if (cls && [cls respondsToSelector:@selector(getCellData:)]) {
                TUIMessageCellData *data = [cls getCellData:message];
                data.reuseId = businessID;
                return data;
            }
        }
    }
    return nil;
}

+ (TUISystemMessageCellData *) getSystemCellData:(V2TIMMessage *)message{
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
        //其他群Tips消息正常处理
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
        revoke.content = TUIKitLocalizableString(TUIKitMessageTipsYouRecallMessage); // @"你撤回了一条消息";
        revoke.innerMessage = message;
        return revoke;
    } else if (message.userID.length > 0){
        revoke.content = TUIKitLocalizableString(TUIkitMessageTipsOthersRecallMessage); // @"对方撤回了一条消息";
        revoke.innerMessage = message;
        return revoke;
    } else if (message.groupID.length > 0) {
        //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
        NSString *userName = [TUIMessageDataProvider getShowName:message];
        TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName]; //  @"\"%@\"撤回了一条消息"
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
            [userNameList addObject:info.userID];
        }
    }
    return userNameList;
}

+ (NSMutableArray *)getUserIDList:(NSArray<V2TIMGroupMemberInfo *> *)infoList{
    NSMutableArray<NSString *> *userIDList = [NSMutableArray array];
    for (V2TIMGroupMemberInfo *info in infoList) {
        [userIDList addObject:info.userID];
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
    NSAssert(userID || groupID, @"目标会话至少需要一个");
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
    
    return [V2TIMManager.sharedInstance sendMessage:message
                                           receiver:userID
                                            groupID:groupID
                                           priority:priority
                                     onlineUserOnly:isOnlineUserOnly
                                    offlinePushInfo:pushInfo
                                           progress:progress
                                               succ:succ
                                               fail:fail];
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
                    str = TUIKitLocalizableString(TUIKitMessageTipsUnsupportCustomMessage); // 不支持的自定义消息;
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
        str = TUIKitLocalizableString(TUIKitMessageTipsYouRecallMessage); // @"你撤回了一条消息";
    }
    else if(message.groupID != nil){
        //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
        NSString *userString = message.nameCard;;
        if(userString.length == 0){
            userString = message.nickName;
        }
        if (userString.length == 0) {
            userString = message.sender;
        }
        str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsRecallMessageFormat), userString]; // "\"%@\"撤回了一条消息";
    }
    else if(message.userID != nil){
        str = TUIKitLocalizableString(TUIkitMessageTipsOthersRecallMessage);   // @"对方撤回了一条消息";
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
                        str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsJoinGroupFormat), opUser]; // @"\"%@\"加入群组
                    } else {
                        NSString *users = [userList componentsJoinedByString:@"、"];
                        str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsInviteJoinGroupFormat), opUser, users]; // \"%@\"邀请\"%@\"加入群组
                    }
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_INVITE:
            {
                if (userList.count > 0) {
                    NSString *users = [userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsInviteJoinGroupFormat), opUser, users]; // \"%@\"邀请\"%@\"加入群组
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_QUIT:
            {
                if (opUser.length > 0) {
                    str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsLeaveGroupFormat), opUser]; // \"%@\"退出了群聊
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_KICKED:
            {
                if (userList.count > 0) {
                    NSString *users = [userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsKickoffGroupFormat), opUser, users]; // \"%@\"将\"%@\"踢出群组
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_SET_ADMIN:
            {
                if (userList.count > 0) {
                    NSString *users = [userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsSettAdminFormat), users]; // \"%@\"被设置管理员
                }
            }
                break;
            case V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN:
            {
                if (userList.count > 0) {
                    NSString *users = [userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsCancelAdminFormat), users]; // \"%@\"被取消管理员
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
                            str = [NSString stringWithFormat:TUIKitLocalizableString(TUIkitMessageTipsEditGroupNameFormat), str, info.value]; // %@修改群名为\"%@\"、
                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION:
                        {
                            str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupIntroFormat), str, info.value]; // %@修改群简介为\"%@\"、
                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION:
                        {
                            if (info.value.length) {
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupAnnounceFormat), str, info.value]; // %@修改群公告为\"%@\"、
                            } else {
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsDeleteGroupAnnounceFormat), str]; 
                            }
                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_FACE:
                        {
                            str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupAvatarFormat), str]; // %@修改群头像、
                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER:
                        {
                            // %@修改群主为\"%@\"、
                            if (userList.count) {
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupOwnerFormat), str, userList.firstObject];
                            } else {
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupOwnerFormat), str, info.value];
                            }

                        }
                            break;
                        case V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL:
                        {
                            // 全员禁言
                            if (info.boolValue) {
                                // 开启
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitSetShutupAllFormat), opUser];
                            } else {
                                // 取消
                                str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitCancelShutupAllFormat), opUser];
                            }
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
                    str = [NSString stringWithFormat:@"%@ %@", [userId isEqualToString:myId] ? TUIKitLocalizableString(You) : userId, muteTime == 0 ? TUIKitLocalizableString(TUIKitMessageTipsUnmute): TUIKitLocalizableString(TUIKitMessageTipsMute)];
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
