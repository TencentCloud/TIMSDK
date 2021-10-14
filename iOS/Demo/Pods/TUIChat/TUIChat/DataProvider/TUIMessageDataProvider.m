
#import <AVFoundation/AVFoundation.h>

#import "TUIMessageDataProvider.h"
#import "TUIMessageDataProvider+Call.h"
#import "TUIMessageDataProvider+Live.h"
#import "TUIMessageDataProvider+Link.h"
#import "TUITextMessageCellData.h"
#import "TUISystemMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIFaceMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIMergeMessageCellData.h"
#import "TUIFaceMessageCellData.h"
#import "TUIFaceView.h"
#import "TUIDefine.h"
#import "TUIJoinGroupMessageCellData.h"
#import "TUITool.h"
#import "TUILogin.h"
#import "NSString+TUIUtil.h"
#import "TUITool.h"

@interface TUIMessageDataProvider ()<V2TIMAdvancedMsgListener>
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
        _maxDateMessageDelay = 5 * 60;
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
            [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageDataProviderDataSourceChangeTypeReload atIndex:index];
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
    // 更新数据, 刷新页面
    [self.dataSource dataProviderDataSourceWillChange:self];
    for (TUIMessageCellData *uiMsg in cellDataList) {
        [self addUIMsg:uiMsg];
        [self.dataSource dataProviderDataSourceChange:self
                                             withType:TUIMessageDataProviderDataSourceChangeTypeInsert
                                              atIndex:(self.uiMsgs_.count - 1)];
    }
    [self.dataSource dataProviderDataSourceDidChange:self];
    
    // 抛出收到新消息事件
    if ([self.dataSource respondsToSelector:@selector(dataProvider:ReceiveNewUIMsg:)]) {
        [self.dataSource dataProvider:self ReceiveNewUIMsg:cellDataList.firstObject];
    }
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
            [TUIMessageDataProvider configCellData:cellData withIMMsg:msg];
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
    TUIMessageCellData *uiMsg = nil;
    for (uiMsg in self.uiMsgs) {
        if ([uiMsg.msgID isEqualToString:msgID]) {
            [self.dataSource dataProviderDataSourceWillChange:self];
            NSUInteger index = [self.uiMsgs indexOfObject:uiMsg];
            TUISystemMessageCellData *revokeCellData = [TUIMessageDataProvider getRevokeCellData:uiMsg.innerMessage];
            [self replaceUIMsg:revokeCellData atIndex:index];
            [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageDataProviderDataSourceChangeTypeReload atIndex:index];
            [self.dataSource dataProviderDataSourceDidChange:self];
            return;
        }
    }
}

/// 消息内容被修改（第三方服务回调修改了消息内容）
- (void)onRecvMessageModified:(V2TIMMessage *)msg {
    V2TIMMessage *imMsg = msg;
    if (imMsg == nil || ![imMsg isKindOfClass:V2TIMMessage.class]) {
        return;
    }
    
    // 更新消息
    for (TUIMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.msgID isEqualToString:imMsg.msgID]) {
            NSMutableArray *cellDataList = [self transUIMsgFromIMMsg:@[imMsg]];
            if (cellDataList.count > 0) {
                TUIMessageCellData *cellData =cellDataList.firstObject;
                [self.dataSource dataProviderDataSourceWillChange:self];
                NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
                [self replaceUIMsg:cellData atIndex:index];
                [self.dataSource dataProviderDataSourceChange:self
                                                     withType:TUIMessageDataProviderDataSourceChangeTypeReload
                                                      atIndex:index];
                [self.dataSource dataProviderDataSourceDidChange:self];
            }
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
}

- (void)sendUIMsg:(TUIMessageCellData *)uiMsg
   toConversation:(TUIChatConversationModel *)conversationData
    willSendBlock:(void(^)(BOOL isReSend, TUIMessageCellData *dateUIMsg))willSendBlock
        SuccBlock:(nullable V2TIMSucc)succ
        FailBlock:(nullable V2TIMFail)fail {
    
    [TUITool dispatchMainAsync:^{
        V2TIMMessage *imMsg = uiMsg.innerMessage;
        TUIMessageCellData *dateMsg = nil;
        BOOL isReSent = NO;
        if (uiMsg.status == Msg_Status_Init) {
            //新消息
            if (!imMsg) {
                imMsg = [TUIMessageDataProvider getIMMsgFromCellData:uiMsg];
            }
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
                                                  atIndex:row];
        }
        if (dateMsg) {
            [self addUIMsg:dateMsg];
            [self.dataSource dataProviderDataSourceChange:self
                                                 withType:TUIMessageDataProviderDataSourceChangeTypeInsert
                                                  atIndex:(self.uiMsgs.count - 1)];
        }
        [self addUIMsg:uiMsg];
        [self.dataSource dataProviderDataSourceChange:self
                                             withType:TUIMessageDataProviderDataSourceChangeTypeInsert
                                              atIndex:(self.uiMsgs.count - 1)];
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
            // 更新上传进度
            [self.uiMsgs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TUIMessageCellData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.innerMessage.msgID isEqualToString:imMsg.msgID]
                    && [obj conformsToProtocol:@protocol(TUIMessageCellDataFileUploadProtocol)]) {
                    ((id<TUIMessageCellDataFileUploadProtocol>)obj).uploadProgress = progress;
                    *stop = YES;
                }
            }];
        }
                                                SuccBlock:succ
                                                FailBlock:fail];
        uiMsg.name = [TUIMessageDataProvider getShowName:uiMsg.innerMessage];
        // !!!innerMessage.faceURL在sendMessage内部赋值,所以需要放在最后面. TUIMessageCell内部监听了avatarUrl的变更,所以不需要再次刷新
        uiMsg.avatarUrl = [NSURL URLWithString:[uiMsg.innerMessage faceURL]];
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
            [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageDataProviderDataSourceChangeTypeDelete atIndex:index];
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
            data = [self getTextCellData:message fromElem:message.textElem];
        }
            break;
        case V2TIM_ELEM_TYPE_IMAGE:
        {
            data = [self getImageCellData:message fromElem:message.imageElem];
        }
            break;
        case V2TIM_ELEM_TYPE_SOUND:
        {
            data = [self getVoiceCellData:message fromElem:message.soundElem];
        }
            break;
        case V2TIM_ELEM_TYPE_VIDEO:
        {
            data = [self getVideoCellData:message fromElem:message.videoElem];
        }
            break;
        case V2TIM_ELEM_TYPE_FILE:
        {
            data = [self getFileCellData:message fromElem:message.fileElem];
        }
            break;
        case V2TIM_ELEM_TYPE_FACE:
        {
            data = [self geTUIFaceCellData:message fromElem:message.faceElem];
        }
            break;
        case V2TIM_ELEM_TYPE_GROUP_TIPS:
        {
            data = [self getSystemCellData:message fromElem:message.groupTipsElem];
        }
            break;
        case V2TIM_ELEM_TYPE_MERGER:
        {
            data = [self getMergerCellData:message fromElem:message.mergerElem];
        }
            break;
        case V2TIM_ELEM_TYPE_CUSTOM:
        {
            // 音视频通话自定义消息
            data = [self getCallCellData:message];
            
            // 群直播自定义消息
            if (!data) {
                data = [self getLiveCellData:message];
            }
            // 点击链接跳转自定义消息
            if (!data) {
                data = [self getLinkCellData:message];
            }
        }
            break;
        default:
            break;
    }
    if (data) {
        data.avatarUrl = [NSURL URLWithString:message.faceURL];
    }
    return data;
}

+ (TUITextMessageCellData *) getTextCellData:(V2TIMMessage *)message  fromElem:(V2TIMTextElem *)elem {
    TUITextMessageCellData *textData = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    textData.content = elem.text;
    return textData;
}

+ (TUIFaceMessageCellData *) geTUIFaceCellData:(V2TIMMessage *)message  fromElem:(V2TIMFaceElem *)elem{
    TUIFaceMessageCellData *faceData = [[TUIFaceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    faceData.groupIndex = elem.index;
    faceData.faceName = [[NSString alloc] initWithData:elem.data encoding:NSUTF8StringEncoding];
    for (TUIFaceGroup *group in [TUIConfig defaultConfig].faceGroups) {
        if(group.groupIndex == faceData.groupIndex){
            NSString *path = [group.groupPath stringByAppendingPathComponent:faceData.faceName];
            faceData.path = path;
            break;
        }
    }
    return faceData;
}

+ (TUIImageMessageCellData *) getImageCellData:(V2TIMMessage *)message fromElem:(V2TIMImageElem *)elem{
    TUIImageMessageCellData *imageData = [[TUIImageMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    imageData.path = [elem.path safePathString];
    imageData.items = [NSMutableArray array];
    for (V2TIMImage *item in elem.imageList) {
        TUIImageItem *itemData = [[TUIImageItem alloc] init];
        itemData.uuid = item.uuid;
        itemData.size = CGSizeMake(item.width, item.height);
//        itemData.url = item.url;
        if(item.type == V2TIM_IMAGE_TYPE_THUMB){
            itemData.type = TImage_Type_Thumb;
        }
        else if(item.type == V2TIM_IMAGE_TYPE_LARGE){
            itemData.type = TImage_Type_Large;
        }
        else if(item.type == V2TIM_IMAGE_TYPE_ORIGIN){
            itemData.type = TImage_Type_Origin;
        }
        [imageData.items addObject:itemData];
    }
    return imageData;
}

+ (TUIVoiceMessageCellData *) getVoiceCellData:(V2TIMMessage *) message fromElem:(V2TIMSoundElem *) elem{
    TUIVoiceMessageCellData *soundData = [[TUIVoiceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    soundData.duration = elem.duration;
    soundData.length = elem.dataSize;
    soundData.uuid = elem.uuid;
    return soundData;
}

+ (TUIVideoMessageCellData *) getVideoCellData:(V2TIMMessage *)message fromElem:(V2TIMVideoElem *) elem{
    TUIVideoMessageCellData *videoData = [[TUIVideoMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    videoData.videoPath = [elem.videoPath safePathString];
    videoData.snapshotPath = [elem.snapshotPath safePathString];

    videoData.videoItem = [[TUIVideoItem alloc] init];
    videoData.videoItem.uuid = elem.videoUUID;
    videoData.videoItem.type = elem.videoType;
    videoData.videoItem.length = elem.videoSize;
    videoData.videoItem.duration = elem.duration;

    videoData.snapshotItem = [[TUISnapshotItem alloc] init];
    videoData.snapshotItem.uuid = elem.snapshotUUID;
//    videoData.snapshotItem.type = elem.snaps;
    videoData.snapshotItem.length = elem.snapshotSize;
    videoData.snapshotItem.size = CGSizeMake(elem.snapshotWidth, elem.snapshotHeight);

    return videoData;
}

+ (TUIFileMessageCellData *) getFileCellData:(V2TIMMessage *)message fromElem:(V2TIMFileElem *)elem{
    TUIFileMessageCellData *fileData = [[TUIFileMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    fileData.path = [elem.path safePathString];
    fileData.fileName = elem.filename;
    fileData.length = elem.fileSize;
    fileData.uuid = elem.uuid;
    return fileData;
}

+ (TUIMessageCellData *)getMergerCellData:(V2TIMMessage *)message fromElem:(V2TIMMergerElem *)elem {
    
    if (elem.layersOverLimit) {
        TUITextMessageCellData *limitCell = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
        limitCell.content = TUIKitLocalizableString(TUIKitRelayLayerLimitTips);
        return limitCell;
    }
    
    TUIMergeMessageCellData *relayData = [[TUIMergeMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    relayData.title = elem.title;
    relayData.abstractList = [NSArray arrayWithArray:elem.abstractList];
    relayData.mergerElem = elem;
    return relayData;
}

+ (TUISystemMessageCellData *) getSystemCellData:(V2TIMMessage *)message fromElem:(V2TIMGroupTipsElem *)elem{
    V2TIMGroupTipsElem *tip = (V2TIMGroupTipsElem *)elem;
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
        return joinGroupData;
    } else {
        //其他群Tips消息正常处理
        TUISystemMessageCellData *sysdata = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        sysdata.content = [self getDisplayString:message];
        if (sysdata.content.length) {
            return sysdata;
        }
    }
    return nil;
}

+ (TUISystemMessageCellData *) getRevokeCellData:(V2TIMMessage *)message{

    TUISystemMessageCellData *revoke = [[TUISystemMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    if(message.isSelf){
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
        return joinGroupData;
    }
    return nil;
}

+ (TUIVideoMessageCellData *)getVideoCellDataWithURL:(NSURL *)url {
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
    CMTime time = CMTimeMakeWithSeconds(0.0, 10);
    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imagePath = [TUIKit_Video_Path stringByAppendingString:[TUITool genSnapshotName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    
    TUIVideoMessageCellData *uiVideo = [[TUIVideoMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    uiVideo.snapshotPath = imagePath;
    uiVideo.snapshotItem = [[TUISnapshotItem alloc] init];
    UIImage *snapshot = [UIImage imageWithContentsOfFile:imagePath];
    uiVideo.snapshotItem.size = snapshot.size;
    uiVideo.snapshotItem.length = imageData.length;
    uiVideo.videoPath = videoPath;
    uiVideo.videoItem = [[TUIVideoItem alloc] init];
    uiVideo.videoItem.duration = duration;
    uiVideo.videoItem.length = videoData.length;
    uiVideo.videoItem.type = url.pathExtension;
    uiVideo.uploadProgress = 0;
    return uiVideo;
}

- (nullable TUISystemMessageCellData *)getSystemMsgFromDate:(NSDate *)date {
    if (self.msgForDate == nil
       || fabs([date timeIntervalSinceDate:self.msgForDate.timestamp]) > self.maxDateMessageDelay) {
        TUISystemMessageCellData *system = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
        system.content = [TUITool convertDateToStr:date];
        system.reuseId = TSystemMessageCell_ReuseId;
        return system;
    }
    return nil;
}

+ (void)configCellData:(TUIMessageCellData *)cellData withIMMsg:(V2TIMMessage *)imMsg {
    if (!cellData) {
        return;
    }
    cellData.innerMessage = imMsg;
    cellData.msgID = imMsg.msgID;
    cellData.direction = imMsg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
    cellData.identifier = imMsg.sender;
    cellData.name = [TUIMessageDataProvider getShowName:imMsg];
    cellData.avatarUrl = [NSURL URLWithString:imMsg.faceURL];
    // 满足 -> 1、群消息 2、非自己的消息 3、非系统消息 ->展示 showName
    if (imMsg.groupID.length > 0 && !imMsg.isSelf
       && ![cellData isKindOfClass:[TUISystemMessageCellData class]]) {
        cellData.showName = YES;
    }
    switch (imMsg.status) {
        case V2TIM_MSG_STATUS_SEND_SUCC:
            cellData.status = Msg_Status_Succ;
            break;
        case V2TIM_MSG_STATUS_SEND_FAIL:
            cellData.status = Msg_Status_Fail;
            break;
        case V2TIM_MSG_STATUS_SENDING:
            cellData.status = Msg_Status_Sending_2;
            break;
        default:
            break;
    }
}


+ (V2TIMMessage *)getIMMsgFromCellData:(TUIMessageCellData *)data
{
    V2TIMMessage *msg = nil;
    if([data isKindOfClass:[TUITextMessageCellData class]]){
        TUITextMessageCellData *text = (TUITextMessageCellData *)data;
        if (text.atUserList.count > 0) {
            msg = [[V2TIMManager sharedInstance] createTextAtMessage:text.content atUserList:text.atUserList];
        } else {
            msg = [[V2TIMManager sharedInstance] createTextMessage:text.content];
        }
    }
    else if([data isKindOfClass:[TUIFaceMessageCellData class]]){
        TUIFaceMessageCellData *image = (TUIFaceMessageCellData *)data;
        msg = [[V2TIMManager sharedInstance] createFaceMessage:(int)image.groupIndex data:[image.faceName dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else if([data isKindOfClass:[TUIImageMessageCellData class]]){
        TUIImageMessageCellData *uiImage = (TUIImageMessageCellData *)data;
        msg = [[V2TIMManager sharedInstance] createImageMessage:uiImage.path];
    }
    else if([data isKindOfClass:[TUIVideoMessageCellData class]]){
        TUIVideoMessageCellData *uiVideo = (TUIVideoMessageCellData *)data;
        msg = [[V2TIMManager sharedInstance] createVideoMessage:uiVideo.videoPath type:uiVideo.videoItem.type duration:(int)uiVideo.videoItem.duration snapshotPath:uiVideo.snapshotPath];
    }
    else if([data isKindOfClass:[TUIVoiceMessageCellData class]]){
        TUIVoiceMessageCellData *uiSound = (TUIVoiceMessageCellData *)data;
        msg = [[V2TIMManager sharedInstance] createSoundMessage:uiSound.path duration:uiSound.duration];
    }
    else if([data isKindOfClass:[TUIFileMessageCellData class]]){
        TUIFileMessageCellData *uiFile = (TUIFileMessageCellData *)data;
        msg = [[V2TIMManager sharedInstance] createFileMessage:uiFile.path fileName:uiFile.fileName];
    }
    data.innerMessage = msg;
    return msg;

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

#pragma mark - 表情国际化
+ (NSString *)localizableStringWithFaceContent:(NSString *)faceContent
{
    NSString *content = faceContent?:@"";
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (re) {
        NSArray *resultArray = [re matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        TUIFaceGroup *group = [TUIConfig defaultConfig].faceGroups[0];
        NSMutableArray *waitingReplaceM = [NSMutableArray array];
        for(NSTextCheckingResult *match in resultArray) {
            NSRange range = [match range];
            NSString *subStr = [content substringWithRange:range];
            for (TUIFaceCellData *face in group.faces) {
                if ([face.name isEqualToString:subStr]) {
                    [waitingReplaceM addObject:@{
                        @"range":NSStringFromRange(range),
                        @"localizableStr": face.localizableName.length?face.localizableName:face.name
                    }];
                    break;
                }
            }
        }
        
        if (waitingReplaceM.count) {
            // 从后往前替换，否则会引起位置问题
            for (int i = (int)waitingReplaceM.count -1; i >= 0; i--) {
                NSRange range = NSRangeFromString(waitingReplaceM[i][@"range"]);
                NSString *localizableStr = waitingReplaceM[i][@"localizableStr"];
                content = [content stringByReplacingCharactersInRange:range withString:localizableStr];
            }
        }
    }
    return content;
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

+ (V2TIMMessage *)customMessageWithJsonData:(NSData *)data {
    return [[V2TIMManager sharedInstance] createCustomMessage:data];
}

+ (NSString *)getShowName:(V2TIMMessage *)imMsg {
    NSString *showName = imMsg.sender;
    if (imMsg.nameCard.length > 0) {
        showName = imMsg.nameCard;
    } else if (imMsg.friendRemark.length > 0) {
        showName = imMsg.friendRemark;
    } else if (imMsg.nickName.length > 0) {
        showName = imMsg.nickName;
    }
    return showName;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)msg
{
    NSString *str;
    if(msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED){
        if(msg.isSelf){
            str = TUIKitLocalizableString(TUIKitMessageTipsYouRecallMessage); // @"你撤回了一条消息";
        }
        else if(msg.groupID != nil){
            //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
            NSString *userString = msg.nameCard;;
            if(userString.length == 0){
                userString = msg.nickName;
            }
            if (userString.length == 0) {
                userString = msg.sender;
            }
            str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsRecallMessageFormat), userString]; // "\"%@\"撤回了一条消息";
        }
        else if(msg.userID != nil){
            str = TUIKitLocalizableString(TUIkitMessageTipsOthersRecallMessage);   // @"对方撤回了一条消息";
        }
    } else {
        switch (msg.elemType) {
            case V2TIM_ELEM_TYPE_TEXT:
            {
                // 处理表情的国际化
                NSString *content = msg.textElem.text;
                str = [self localizableStringWithFaceContent:content];
            }
                break;
            case V2TIM_ELEM_TYPE_CUSTOM:
            {
                // 处理自定义消息
                str = [TUIMessageDataProvider getCallDisplayString:msg];
                if (!str) {
                    str = [TUIMessageDataProvider getLiveDisplayString:msg];
                }
                if (!str) {
                    str = [TUIMessageDataProvider getLinkDisplayString:msg];
                }
                if (!str) {
                    str = TUIKitLocalizableString(TUIKitMessageTipsUnsupportCustomMessage); // 不支持的自定义消息;
                }
            }
                break;
            case V2TIM_ELEM_TYPE_IMAGE:
            {
                str = TUIKitLocalizableString(TUIkitMessageTypeImage); // @"[图片]";
            }
                break;
            case V2TIM_ELEM_TYPE_SOUND:
            {
                str = TUIKitLocalizableString(TUIKitMessageTypeVoice); // @"[语音]";
            }
                break;
            case V2TIM_ELEM_TYPE_VIDEO:
            {
                str = TUIKitLocalizableString(TUIkitMessageTypeVideo); // @"[视频]";
            }
                break;
            case V2TIM_ELEM_TYPE_FILE:
            {
                str = TUIKitLocalizableString(TUIkitMessageTypeFile); // @"[文件]";
            }
                break;
            case V2TIM_ELEM_TYPE_FACE:
            {
                str = TUIKitLocalizableString(TUIKitMessageTypeAnimateEmoji); // @"[动画表情]";
            }
                break;
            case V2TIM_ELEM_TYPE_GROUP_TIPS:
            {
                V2TIMGroupTipsElem *tips = msg.groupTipsElem;
                NSString *opUser = [self getOpUserName:tips.opMember];
                NSMutableArray<NSString *> *userList = [self getUserNameList:tips.memberList];
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
                                        str = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsEditGroupAnnounceFormat), str, info.value]; // %@修改群公告为\"%@\"、
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
                                str = [NSString stringWithFormat:@"%@%@", [userId isEqualToString:myId] ? TUIKitLocalizableString(You) : userId, muteTime == 0 ? TUIKitLocalizableString(TUIKitMessageTipsUnmute): TUIKitLocalizableString(TUIKitMessageTipsMute)];
                                break;
                            }
                        }
                    }
                        break;
                        default:
                            break;
                    }
            }
                break;
            case V2TIM_ELEM_TYPE_MERGER:
            {
                str = [NSString stringWithFormat:@"[%@]", TUIKitLocalizableString(TUIKitRelayChatHistory)];
            }
                break;
            default:
                break;
        }
    }
    
    return str;
}
@end
