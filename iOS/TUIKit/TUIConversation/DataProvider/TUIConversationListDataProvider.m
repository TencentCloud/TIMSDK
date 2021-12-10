//
//  TConversationListViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import "TUIConversationListDataProvider.h"
#import "TUICore.h"
#import "TUILogin.h"
#import "TUIDefine.h"

#define Default_PagePullCount 100

@interface TUIConversationListDataProvider ()<V2TIMConversationListener, V2TIMGroupListener>
@property (nonatomic, assign) uint64_t nextSeq;
@property (nonatomic, assign) uint64_t isFinished;
@property (nonatomic, strong) NSMutableArray<V2TIMConversation *> *convList;
@end

@implementation TUIConversationListDataProvider

- (instancetype)init
{
    if (self = [super init]) {
        
        [[V2TIMManager sharedInstance] addConversationListener:self];
        [[V2TIMManager sharedInstance] addGroupListener:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didTopConversationListChanged:)
                                                     name:kTopConversationListChangedNotification
                                                   object:nil];
        self.convList = [[NSMutableArray alloc] init];
        self.pagePullCount = Default_PagePullCount;
        self.nextSeq = 0;
        self.isFinished = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - V2TIMConversationListener
- (void)onNewConversation:(NSArray<V2TIMConversation*> *) conversationList {
    [self updateConversation:conversationList];
}

- (void)onConversationChanged:(NSArray<V2TIMConversation*> *) conversationList {
    [self updateConversation:conversationList];
}

#pragma mark - V2TIMGroupListener
- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (data) {
        [TUITool makeToast:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupDismssTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (void)onGroupRecycled:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (data) {
        [TUITool makeToast:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupRecycledTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (void)onMemberKicked:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    for (V2TIMGroupMemberInfo *info in memberList) {
        if ([info.userID isEqualToString:[TUILogin getUserID]]) {
            TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
            if (data) {
                [TUITool makeToast:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupKickOffTipsFormat), data.groupID]];
                [self removeData:data];
            }
            return;
        }
    }
}

- (void)onQuitFromGroup:(NSString *)groupID {
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (data) {
        [TUITool makeToast:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupDropoutTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupChangeInfo *> *)changeInfoList
{
    if (groupID.length == 0) {
        return;
    }
    NSString *conversationID = [NSString stringWithFormat:@"group_%@", groupID];
    TUIConversationCellData *tmpData = nil;
    for (TUIConversationCellData *cellData in self.dataList) {
        if ([cellData.conversationID isEqual:conversationID]) {
            tmpData = cellData;
            break;
        }
    }
    if (tmpData == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance getConversation:conversationID succ:^(V2TIMConversation *conv) {
        [weakSelf updateConversation:@[conv]];
    } fail:^(int code, NSString *desc) {
        
    }];
}


#pragma mark -

- (void)didTopConversationListChanged:(NSNotification *)no
{
    NSMutableArray *dataList = [NSMutableArray arrayWithArray:self.dataList];
    [self sortDataList:dataList];
    self.dataList = dataList;
}

- (void)loadConversation
{
    if (self.isFinished) {
        return;
    }
    @weakify(self)
    [[V2TIMManager sharedInstance] getConversationList:self.nextSeq count:self.pagePullCount succ:^(NSArray<V2TIMConversation *> *list, uint64_t nextSeq, BOOL isFinished) {
        @strongify(self)
        self.nextSeq = nextSeq;
        self.isFinished = isFinished;
        [self updateConversation:list];
    } fail:^(int code, NSString *msg) {
        self.isFinished = YES;
        NSLog(@"getConversationList failed, code:%d msg:%@", code, msg);
    }];
}

- (void)updateConversation:(NSArray *)convList
{
    // 更新 UI 会话列表，如果 UI 会话列表有新增的会话，就替换，如果没有，就新增
    for (int i = 0 ; i < convList.count ; ++ i) {
        V2TIMConversation *conv = convList[i];
        BOOL isExit = NO;
        for (int j = 0; j < self.convList.count; ++ j) {
            V2TIMConversation *localConv = self.convList[j];
            if ([localConv.conversationID isEqualToString:conv.conversationID]) {
                [self.convList replaceObjectAtIndex:j withObject:conv];
                isExit = YES;
                break;
            }
        }
        if (!isExit) {
            [self.convList addObject:conv];
        }
    }
    // 更新 cell data
    NSMutableArray *dataList = [NSMutableArray array];
    for (V2TIMConversation *conv in self.convList) {
        // 屏蔽会话
        if ([self filteConversation:conv]) {
            continue;
        }
        // 创建cellData
        TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
        data.conversationID = conv.conversationID;
        data.groupID = conv.groupID;
        data.groupType = conv.groupType;
        data.userID = conv.userID;
        data.title = conv.showName;
        data.faceUrl = conv.faceUrl;
        data.subTitle = [self getLastDisplayString:conv];
        data.atMsgSeqList = [self getGroupAtMsgSeqList:conv];
        data.time = [self getLastDisplayDate:conv];
        data.isOnTop = conv.isPinned;
        data.unreadCount = conv.unreadCount;
        data.draftText = conv.draftText;
        data.isNotDisturb = ![conv.groupType isEqualToString:GroupType_Meeting] && (V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE == conv.recvOpt);
        data.orderKey = conv.orderKey;
        data.avatarImage = (conv.type == V2TIM_C2C ? DefaultAvatarImage : DefaultGroupAvatarImage);
        [dataList addObject:data];
    }
    // UI 会话列表根据 orderKey 重新排序
    [self sortDataList:dataList];
    self.dataList = dataList;
}

- (NSString *)getDraftContent:(V2TIMConversation *)conv
{
    NSString *draft = conv.draftText;
    if (draft.length == 0) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[draft dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    if (error || jsonDict == nil) {
        return draft;
    }
    
    // 显示草稿
    NSString *draftContent = [jsonDict.allKeys containsObject:@"content"] ? jsonDict[@"content"] : @"";
    return draftContent;
}

- (BOOL)filteConversation:(V2TIMConversation *)conv
{
    // 屏蔽AVChatRoom的群聊会话
    if ([conv.groupType isEqualToString:@"AVChatRoom"]) {
        return YES;
    }
    
    // 屏蔽异常会话
    if ([self getLastDisplayDate:conv] == nil) {
        if (conv.unreadCount != 0) {
            // 修复 在某种情况下会出现data.time为nil且还有未读会话的情况，实际上是lastMessage为空(v1conv的lastmessage)，导致出现界面不显示当前会话，聊天界面却显示未读的情况
            // 如果碰到这种情况，直接设置成已读
            NSString *userID = conv.userID;
            if (userID.length > 0) {
                [[V2TIMManager sharedInstance] markC2CMessageAsRead:userID succ:^{
                    
                } fail:^(int code, NSString *msg) {
                    
                }];
            }
            NSString *groupID = conv.groupID;
            if (groupID.length > 0) {
                [[V2TIMManager sharedInstance] markGroupMessageAsRead:groupID succ:^{
                    
                } fail:^(int code, NSString *msg) {
                    
                }];
            }
        }
        return YES;
    }
    
    return NO;
}

- (NSMutableArray<NSNumber *> *)getGroupAtMsgSeqList:(V2TIMConversation *)conv {
    NSMutableArray *seqList = [NSMutableArray array];
    for (V2TIMGroupAtInfo *atInfo in conv.groupAtInfolist) {
        [seqList addObject:@(atInfo.seq)];
    }
    if (seqList.count > 0) {
        return seqList;
    }
    return nil;
}

- (NSString *)getGroupAtTipString:(V2TIMConversation *)conv {
    NSString *atTipsStr = @"";
    BOOL atMe = NO;
    BOOL atAll = NO;
    for (V2TIMGroupAtInfo *atInfo in conv.groupAtInfolist) {
        switch (atInfo.atType) {
            case V2TIM_AT_ME:
                atMe = YES;
                continue;;
            case V2TIM_AT_ALL:
                atAll = YES;
                continue;;
            case V2TIM_AT_ALL_AT_ME:
                atMe = YES;
                atAll = YES;
                continue;;
            default:
                continue;;
        }
    }
    if (atMe && !atAll) {
        atTipsStr = TUIKitLocalizableString(TUIKitConversationTipsAtMe); // @"[有人@我]";
    }
    if (!atMe && atAll) {
        atTipsStr = TUIKitLocalizableString(TUIKitConversationTipsAtAll); // @"[@所有人]";
    }
    if (atMe && atAll) {
        atTipsStr = TUIKitLocalizableString(TUIKitConversationTipsAtMeAndAll); // @"[有人@我][@所有人]";
    }
    return atTipsStr;
}

- (NSMutableAttributedString *)getLastDisplayString:(V2TIMConversation *)conv
{
    NSString *lastMsgStr = @"";
    // 先看下外部有没自定义会话的 lastMsg 展示信息
    if (self.delegate && [self.delegate respondsToSelector:@selector(getConversationDisplayString:)]) {
        lastMsgStr = [self.delegate getConversationDisplayString:conv];
    }
    // 外部没有自定义，通过消息获取 lastMsg 展示信息
    if (lastMsgStr.length == 0 && conv.lastMessage) {
        NSDictionary *param = @{TUICore_TUIChatService_GetDisplayStringMethod_MsgKey:conv.lastMessage};
        lastMsgStr = [TUICore callService:TUICore_TUIChatService method:TUICore_TUIChatService_GetDisplayStringMethod param:param];
    }
    // 如果没有 lastMsg 展示信息，也没有草稿信息，直接返回 nil
    if (lastMsgStr.length == 0 && conv.draftText.length == 0) {
        return nil;
    }
    // 如果设置了免打扰，需要展示免打扰消息数量
    // Meeting 群默认就是 V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE 状态，UI 上不特殊处理
    if (![conv.groupType isEqualToString:GroupType_Meeting] && V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE == conv.recvOpt && conv.unreadCount > 0) {
        lastMsgStr = [NSString stringWithFormat:@"[%d条] %@", conv.unreadCount,lastMsgStr];
    }
    // 如果有群 @ ，需要展示群 @ 信息
    NSString *atStr = [self getGroupAtTipString:conv];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",atStr]];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemRedColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];
    
    if(conv.draftText.length > 0){
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:TUIKitLocalizableString(TUIKitMessageTypeDraftFormat) attributes:@{NSForegroundColorAttributeName:[UIColor d_systemRedColor]}]];
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:[self getDraftContent:conv] attributes:@{NSForegroundColorAttributeName:[UIColor d_systemGrayColor]}]];
    } else {
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:lastMsgStr]];
    }
    return attributeString;
}

- (NSDate *)getLastDisplayDate:(V2TIMConversation *)conv
{
    if(conv.draftText.length > 0){
        return conv.draftTimestamp;
    }
    if (conv.lastMessage) {
        return conv.lastMessage.timestamp;
    }
    return [NSDate distantPast];
}

- (TUIConversationCellData *)cellDataOfGroupID:(NSString *)groupID
{
    for (TUIConversationCellData *data in self.dataList) {
        if ([data.groupID isEqualToString:groupID]) {
            return data;
        }
    }
    return nil;
}

- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList
{
    [dataList sortUsingComparator:^NSComparisonResult(TUIConversationCellData *obj1, TUIConversationCellData *obj2) {
        return obj1.orderKey < obj2.orderKey;
    }];
}

- (void)removeData:(TUIConversationCellData *)data
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:self.dataList];
    [list removeObject:data];
    self.dataList = list;
    for (V2TIMConversation *conv in self.convList) {
        if ([conv.conversationID isEqualToString:data.conversationID]) {
            [self.convList removeObject:conv];
            break;
        }
    }
    [[V2TIMManager sharedInstance] deleteConversation:data.conversationID succ:nil fail:nil];
}

- (void)clearGroupHistoryMessage:(NSString *)groupID {
    [V2TIMManager.sharedInstance clearGroupHistoryMessage:groupID succ:^{
        NSLog(@"clear group history messages, success");
    } fail:^(int code, NSString *desc) {
        NSLog(@"clear group history messages, error|code:%d|desc:%@", code, desc);
    }];
}

- (void)clearC2CHistoryMessage:(NSString *)userID {
    [V2TIMManager.sharedInstance clearC2CHistoryMessage:userID succ:^{
        NSLog(@"clear c2c history messages, success");
    } fail:^(int code, NSString *desc) {
        NSLog(@"clear c2c history messages, error|code:%d|desc:%@", code, desc);
    }];
}

@end
