//
//  V2TUIConversationListDataProvider.m
//  TUIConversation
//
//  Created by harvy on 2022/7/14.
//

#import "TUIConversationListDataProvider.h"

#import <ImSDK_Plus/ImSDK_Plus.h>
#import "TUIDefine.h"
#import "TUICore.h"
#import "TUILogin.h"
#import "TUIConversationCellData.h"

#define kPageSize 100
#define kLog(...) NSLog(__VA_ARGS__)

@interface TUIConversationListDataProvider () <
                                                V2TIMConversationListener,
                                                V2TIMGroupListener,
                                                V2TIMSDKListener,
                                                V2TIMAdvancedMsgListener,
                                                TUINotificationProtocol
                                                >

@property (nonatomic, strong) NSMutableArray<TUIConversationCellData *> *conversationList;
@property (nonatomic, assign, getter=isLastPage) BOOL lastPage;

/**
 * 本地插入的会话折叠列表
 * Locally inserted conversation collapse list
 */
@property (nonatomic, strong) TUIConversationCellData *conversationFoldListData;

@property (nonatomic, assign) NSUInteger startIndexOfUnpinedConversation;

@end

@implementation TUIConversationListDataProvider

- (instancetype)init {
    if (self = [super init]) {
        self.pageIndex = 0;
        self.pageSize = kPageSize;
        self.lastPage = NO;
        
        [[V2TIMManager sharedInstance] addConversationListener:self];
        [[V2TIMManager sharedInstance] addGroupListener:self];
        [[V2TIMManager sharedInstance] addIMSDKListener:self];
        [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];

        [TUICore registerEvent:TUICore_TUIConversationNotify subKey:TUICore_TUIConversationNotify_RemoveConversationSubKey object:self];

    }
    return self;
}

- (void)loadNexPageConversations {
    if (self.isLastPage) {
        return;
    }
    @weakify(self);
    [V2TIMManager.sharedInstance getConversationList:self.pageIndex
                                               count:(int)self.pageSize
                                                succ:^(NSArray<V2TIMConversation *> *list,
                                                       uint64_t nextSeq,
                                                       BOOL isFinished) {
        @strongify(self);
        self.pageIndex = nextSeq;
        self.lastPage = isFinished;
        [self preprocess:list];
    }
                                                fail:^(int code, NSString *desc) {
        @strongify(self);
        self.lastPage = YES;
        kLog(@"[TUIConversation] %s, code:%d, desc:%@", __func__, code, desc);
    }];
}

- (void)removeConversation:(TUIConversationCellData *)conversation {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf removeConversation:conversation];
        });
        return;
    }
    [self handleRemoveConversation:conversation];
}

- (void)clearHistoryMessage:(TUIConversationCellData *)conversation {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf clearHistoryMessage:conversation];
        });
        return;
    }
    if (conversation.groupID) {
        [self handleClearGroupHistoryMessage:conversation.groupID];
    } else if (conversation.userID) {
        [self handleClearC2CHistoryMessage:conversation.userID];
    }
}

- (void)pinConversation:(TUIConversationCellData *)conversation pin:(BOOL)pin {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf pinConversation:conversation pin:pin];
        });
        return;
    }
    [self handlePinConversation:conversation pin:pin];
}

- (void)hideConversation:(TUIConversationCellData *)conversation {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideConversation:conversation];
        });
        return;
    }
    [self handleHideConversation:conversation];
}

#pragma mark - Data process
- (void)preprocess:(NSArray<V2TIMConversation *> *)v2Convs {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf preprocess:v2Convs];
        });
        return;
    }
    
    NSMutableDictionary<NSString *, NSNumber *> *conversationMap = [NSMutableDictionary dictionary];
    for (TUIConversationCellData *item in self.conversationList) {
        if (item.conversationID) {
            [conversationMap setObject:@([self.conversationList indexOfObject:item])
                                forKey:item.conversationID];
        }
    }
    
    NSMutableArray *duplicateDataList = [NSMutableArray array];
    NSMutableArray *addedDataList = [NSMutableArray array];
    NSMutableArray *markHideDataList = [NSMutableArray array];
    NSMutableArray *markFoldDataList = [NSMutableArray array];

    for (V2TIMConversation *conv in v2Convs) {
        if ([self filteConversation:conv]) {
            continue;
        }
        
        TUIConversationCellData *cellData = [self cellDataForConversation:conv];
        if ([self.markHideMap objectForKey:cellData.conversationID] ) {
            if (![TUIConversationCellData isMarkedByHideType:conv.markList]) {
                [self.markHideMap removeObjectForKey:cellData.conversationID];
            }
        }
        else {
            if ([TUIConversationCellData isMarkedByHideType:conv.markList]) {
                [self.markHideMap setObject:cellData forKey:cellData.conversationID];
            }
        }
        
        if ([self.markFoldMap objectForKey:cellData.conversationID] ) {
            if (![TUIConversationCellData isMarkedByFoldType:conv.markList]) {
                [self.markFoldMap removeObjectForKey:cellData.conversationID];
            }
        }
        else {
            if ([TUIConversationCellData isMarkedByFoldType:conv.markList]) {
                [self.markFoldMap setObject:cellData forKey:cellData.conversationID];
            }
        }
        
        if ([TUIConversationCellData isMarkedByHideType:conv.markList] || [TUIConversationCellData isMarkedByFoldType:conv.markList]) {
            if ([TUIConversationCellData isMarkedByHideType:conv.markList]) {
                [markHideDataList addObject:cellData];
            }
            if ([TUIConversationCellData isMarkedByFoldType:conv.markList]) {
                [markFoldDataList addObject:cellData];
            }
            continue;
        }
    

        if ([conversationMap objectForKey:cellData.conversationID]) {
            [duplicateDataList addObject:cellData];
        } else {
            [addedDataList addObject:cellData];
        }
        if ([self.markUnreadMap objectForKey:cellData.conversationID] ) {
            // 这是一个取消未读标记操作 或 被别人发来的新消息冲掉了标记的操作
            // This is an operation to cancel the unread mark operation or to be cleaned away by a new message from someone else
            if (![TUIConversationCellData isMarkedByUnReadType:conv.markList]) {
                [self.markUnreadMap removeObjectForKey:cellData.conversationID];
            }
        }
        else {
            if ([TUIConversationCellData isMarkedByUnReadType:conv.markList]) {
                [self.markUnreadMap setObject:cellData forKey:cellData.conversationID];
            }
        }
    }
    if (markFoldDataList.count) {
        __block TUIConversationCellData * cellRecent  = nil;
        [markFoldDataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TUIConversationCellData * cellData = (TUIConversationCellData*)obj;
            if (!cellData.isMarkAsHide) {
                cellRecent = cellData;
                *stop = YES;
            }
        }];
        if (IS_NOT_EMPTY_NSSTRING([cellRecent.foldSubTitle string])) {
            if (cellRecent.orderKey > self.conversationFoldListData.orderKey) {
                if (self.conversationFoldListData.orderKey == 0) {
                    if ([self.class getConversationFoldListSettings_FoldItemIsUnread]) {
                        self.conversationFoldListData.isMarkAsUnread = YES;
                    }
                }
                else {
                    self.conversationFoldListData.isMarkAsUnread = YES;
                    [self.class cacheConversationFoldListSettings_FoldItemIsUnread:YES];
                    [self.class cacheConversationFoldListSettings_HideFoldItem:NO];
                }
            }
            self.conversationFoldListData.subTitle = cellRecent.foldSubTitle;
            self.conversationFoldListData.orderKey = cellRecent.orderKey;
        }

        if (![self.class getConversationFoldListSettings_HideFoldItem]) {
            if ([conversationMap objectForKey:self.conversationFoldListData.conversationID]) {
                [duplicateDataList addObject:self.conversationFoldListData];
            } else {
                [addedDataList addObject:self.conversationFoldListData];
            }
        }
        self.conversationFoldListData.isLocalConversationFoldList = YES;
    }
    else {
        [self updateFoldGroupNameWhileKickOffOrDismissed];
    }
    
    if (duplicateDataList.count) {
        [self sortDataList:duplicateDataList];
        [self handleUpdateConversationList:duplicateDataList positions:conversationMap];
    }
    
    if (addedDataList.count) {
        [self sortDataList:addedDataList];
        [self handleInsertConversationList:addedDataList];
    }
    
    if (markHideDataList.count) {
        [self sortDataList:markHideDataList];
        [markHideDataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.conversationList containsObject:obj] ) {
                [self handleHideConversation:obj];
            }
        }];
    }
    
    [self updateMarkUnreadCount];

    if (markFoldDataList.count) {
        [self sortDataList:markFoldDataList];
        [markFoldDataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 如果有被折叠的会话出现在首页会话列表，则需要隐藏，注意不能删除历史记录
            // If a collapsed session appears in the home page List, it needs to be hidden. Note that the history cannot be deleted.
            if ([self.conversationList containsObject:obj] ) {
                [self handleHideConversation:obj];
            }
        }];

    }
    [self checkStartIndexOfUnpinnedConversation];
}

- (void)updateMarkUnreadCount {

    __block NSInteger markUnreadCount = 0;
    [self.markUnreadMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TUIConversationCellData * _Nonnull obj, BOOL * _Nonnull stop) {
        if (!obj.isNotDisturb) {
            markUnreadCount ++ ;
        }
    }];
    
    __block NSInteger markHideUnreadCount = 0;
    [self.markHideMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TUIConversationCellData * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:TUIConversationCellData.class]) {
            if (!obj.isNotDisturb) {
                if (obj.isMarkAsUnread) {
                    markHideUnreadCount = markHideUnreadCount + 1;
                }
                else {
                    markHideUnreadCount = markHideUnreadCount + obj.unreadCount;
                }
                
            }
        }
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onConversationMarkUnreadCountChanged object:nil userInfo:
     @{@"markUnreadCount":[NSNumber numberWithInteger:markUnreadCount],
       @"markHideUnreadCount":[NSNumber numberWithInteger:markHideUnreadCount],
       @"markUnreadMap":self.markUnreadMap,
     }];
}
- (void)handleInsertConversationList:(NSArray<TUIConversationCellData *> *)conversationList {
    [self.conversationList addObjectsFromArray:conversationList];
    [self sortDataList:self.conversationList];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (TUIConversationCellData *item in conversationList) {
        NSInteger index = [self.conversationList indexOfObject:item];
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(insertConversationsAtIndexPaths:)]) {
        [self.delegate insertConversationsAtIndexPaths:indexPaths];
    }
    [self updateOnlineStatus:conversationList];
}

- (void)handleUpdateConversationList:(NSArray<TUIConversationCellData *> *)conversationList
                           positions:(NSMutableDictionary<NSString *, NSNumber *> *)positionMaps{
    for (TUIConversationCellData *item in conversationList) {
        NSNumber *position = [positionMaps objectForKey:item.conversationID];
        NSAssert((position && [position isKindOfClass:NSNumber.class]),
                 @"serius error, the self.conversationList maybe changed on the other thread");
        TUIConversationCellData *cellData = self.conversationList[position.integerValue];
        item.onlineStatus = cellData.onlineStatus;
        [self.conversationList replaceObjectAtIndex:[position integerValue] withObject:item];
    }
    
    [self sortDataList:self.conversationList];
    
    NSInteger minIndex = self.conversationList.count - 1;
    NSInteger maxIndex = 0;
    for (TUIConversationCellData *cellData in conversationList) {
        for (TUIConversationCellData *item in self.conversationList) {
            if ([item.conversationID isEqualToString:cellData.conversationID]) {
                NSInteger previous = [[positionMaps objectForKey:item.conversationID] integerValue];
                NSInteger current  = [self.conversationList indexOfObject:item];
                minIndex = minIndex < MIN(previous, current) ? minIndex : MIN(previous, current);
                maxIndex = maxIndex > MAX(previous, current) ? maxIndex : MAX(previous, current);
            }
        }
    }
    
    if (minIndex > maxIndex) {
        return;
    }
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSInteger index = minIndex; index < maxIndex + 1; index++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadConversationsAtIndexPaths:)]) {
        [self.delegate reloadConversationsAtIndexPaths:indexPaths];
    }
}

- (void)handleRemoveConversation:(TUIConversationCellData *)conversation {
    NSInteger index = [self.conversationList indexOfObject:conversation];
    [self.conversationList removeObject:conversation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteConversationAtIndexPaths:)]) {
        [self.delegate deleteConversationAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    }
    @weakify(self)
    [[V2TIMManager sharedInstance] deleteConversation:conversation.conversationID succ:^{
        @strongify(self)
        [self updateMarkUnreadCount];
    } fail:nil];
}

- (void)handleHideConversation:(TUIConversationCellData *)conversation {
    NSInteger index = [self.conversationList indexOfObject:conversation];
    if (index != NSNotFound) {
        [self.conversationList removeObject:conversation];
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteConversationAtIndexPaths:)]) {
            [self.delegate deleteConversationAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        }
    }
}
- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList {
    [dataList sortUsingComparator:^NSComparisonResult(TUIConversationCellData *obj1, TUIConversationCellData *obj2) {
        return obj1.orderKey < obj2.orderKey;
    }];
}

- (TUIConversationCellData *)cellDataOfGroupID:(NSString *)groupID {
    TUIConversationCellData *cellData = nil;
    NSString *conversationID = [NSString stringWithFormat:@"group_%@",groupID];
    for (TUIConversationCellData *item in self.conversationList) {
        if ([item.conversationID isEqualToString:conversationID]) {
            cellData = item;
            break;
        }
    }
    return cellData;
}

- (void)dealFoldcellDataOfGroupID:(NSString *)groupID {
    TUIConversationCellData *cellData = nil;
    NSString *conversationID = [NSString stringWithFormat:@"group_%@",groupID];
    cellData =  [self.markFoldMap objectForKey:conversationID];
    if (cellData) {
        @weakify(self)
        [[V2TIMManager sharedInstance] deleteConversation:cellData.conversationID succ:^{
            @strongify(self);
            [self.markFoldMap removeObjectForKey:conversationID];
            [self updateFoldGroupNameWhileKickOffOrDismissed];
        } fail:nil];
    }
}

- (void)updateFoldGroupNameWhileKickOffOrDismissed {
    __block TUIConversationCellData * cellRecent  = nil;
    [self.markFoldMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TUIConversationCellData * _Nonnull obj, BOOL * _Nonnull stop) {
        TUIConversationCellData * cellData = (TUIConversationCellData*)obj;
        if (!cellData.isMarkAsHide) {
            if (!cellRecent) {
                cellRecent = cellData;
            }
            else {
                if (cellData.orderKey > cellRecent.orderKey) {
                    cellRecent = cellData;
                }
            }
        }
    }];

    if (cellRecent) {
        if (IS_NOT_EMPTY_NSSTRING([cellRecent.foldSubTitle string])) {
            self.conversationFoldListData.subTitle = cellRecent.foldSubTitle;
        }
        NSMutableDictionary<NSString *, NSNumber *> *conversationMap = [NSMutableDictionary dictionary];
        for (TUIConversationCellData *item in self.conversationList) {
            if (item.conversationID) {
                [conversationMap setObject:@([self.conversationList indexOfObject:item])
                                    forKey:item.conversationID];
            }
        }
        [self handleUpdateConversationList:@[self.conversationFoldListData] positions:conversationMap];
    }
    else {
        if (_conversationFoldListData) {
            [self hideConversation:self.conversationFoldListData];
        }
    }
    

}
- (void)checkStartIndexOfUnpinnedConversation {
    NSUInteger index = 0;
    for (TUIConversationCellData *item in self.conversationList) {
        if (item.isOnTop == NO) {
            break;
        }
        index++;
    }
    self.startIndexOfUnpinedConversation = index;
}

#pragma mark - TUICore
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param {
    
    if ([key isEqualToString:TUICore_TUIConversationNotify]
        && [subKey isEqualToString:TUICore_TUIConversationNotify_RemoveConversationSubKey]
        ) {
        NSString *conversationID = param[TUICore_TUIConversationNotify_RemoveConversationSubKey_ConversationID];
        if (IS_NOT_EMPTY_NSSTRING(conversationID)) {
            TUIConversationCellData *removeConversation = nil;
            for (TUIConversationCellData *item in self.conversationList) {
                if ([conversationID isEqualToString:item.conversationID]) {
                    removeConversation = item;
                    break;
                }
            }
            if (removeConversation) {
                [self removeConversation:removeConversation];
            }
            else {
                @weakify(self)
                [[V2TIMManager sharedInstance] deleteConversation:conversationID succ:^{
                    @strongify(self)
                    [self updateMarkUnreadCount];
                } fail:nil];
            }
        }
        
    }
}
#pragma mark - User Status
- (void)updateOnlineStatus:(NSArray<TUIConversationCellData *> *)conversationList {
    if (conversationList.count == 0) {
        return;
    }
    
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateOnlineStatus:conversationList];
        });
        return;
    }
    
    // reset
    NSMutableArray *userIDList = [NSMutableArray array];
    NSMutableDictionary *positionMap = [NSMutableDictionary dictionary];
    for (TUIConversationCellData *item in conversationList) {
        if (item.onlineStatus == TUIConversationOnlineStatusOnline) {
            item.onlineStatus = TUIConversationOnlineStatusOffline;
        }
        if (item.userID.length && item.groupID.length == 0) {
            [userIDList addObject:item.userID];
        }
        if (item.conversationID) {        
            [positionMap setObject:@([self.conversationList indexOfObject:item])
                            forKey:item.conversationID];
        }
    }
    [self handleUpdateConversationList:conversationList positions:positionMap];
    
    // fetch
    [self asyncGetOnlineStatus:userIDList];
}

- (void)asyncGetOnlineStatus:(NSArray *)userIDList {
    if (userIDList.count == 0) {
        return;
    }
    
    if (NSThread.isMainThread) {
        @weakify(self)
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @strongify(self)
            [self asyncGetOnlineStatus:userIDList];
        });
        return;
    }
    
    // get
    @weakify(self)
    [V2TIMManager.sharedInstance getUserStatus:userIDList succ:^(NSArray<V2TIMUserStatus *> *result) {
        @strongify(self)
        [self handleOnlineStatus:result];
    } fail:^(int code, NSString *desc) {
#if DEBUG
        if (code == ERR_SDK_INTERFACE_NOT_SUPPORT && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
            [TUITool makeToast:desc];
        }
#endif
    }];
    
    // subscribe for the users who was deleted from friend list
    [V2TIMManager.sharedInstance subscribeUserStatus:userIDList succ:^{
        
    } fail:^(int code, NSString *desc) {
        
    }];
}

- (void)handleOnlineStatus:(NSArray<V2TIMUserStatus *> *)userStatusList {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleOnlineStatus:userStatusList];
        });
        return;
    }
    NSMutableDictionary *positonMap = [NSMutableDictionary dictionary];
    for (TUIConversationCellData *item in self.conversationList) {
        NSAssert(item.conversationID, @"the data of self.conversation maybe damaged");
        if (item.conversationID && item.userID.length != 0 && item.groupID.length == 0) {
            [positonMap setObject:@([self.conversationList indexOfObject:item])
                           forKey:item.conversationID];
        }
    }
    
    NSMutableArray *changedConversation = [NSMutableArray array];
    for (V2TIMUserStatus *item in userStatusList) {
        NSString *conversationID = [NSString stringWithFormat:@"c2c_%@", item.userID];
        NSNumber *position = [positonMap objectForKey:conversationID];
        if (position == nil) {
            continue;
        }
        TUIConversationCellData *conversation = [self.conversationList objectAtIndex:position.integerValue];
        if (![conversation.conversationID isEqualToString:conversationID]) {
            continue;
        }
        switch (item.statusType) {
            case V2TIM_USER_STATUS_ONLINE: {
                conversation.onlineStatus = TUIConversationOnlineStatusOnline;
            }
                break;
            case V2TIM_USER_STATUS_OFFLINE:
            case V2TIM_USER_STATUS_UNLOGINED: {
                conversation.onlineStatus = TUIConversationOnlineStatusOffline;
            }
                break;
            default:
                conversation.onlineStatus = TUIConversationOnlineStatusUnknown;
                break;
        }
        [changedConversation addObject:conversation];
    }
    
    if (changedConversation.count > 0) {
        [self handleUpdateConversationList:changedConversation positions:positonMap];
    }
    
}

#pragma mark - V2TIMConversationListener
- (void)onNewConversation:(NSArray<V2TIMConversation*> *)conversationList {
    [self preprocess:conversationList];
}

- (void)onConversationChanged:(NSArray<V2TIMConversation*> *)conversationList {
    [self preprocess:conversationList];
}

#pragma mark - V2TIMGroupListener
- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (data == nil) {
        [self dealFoldcellDataOfGroupID:groupID];
        return;
    }
    [TUITool makeToast:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupDismssTipsFormat), data.groupID]];
    [self handleRemoveConversation:data];
}

- (void)onGroupRecycled:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (data == nil) {
        [self dealFoldcellDataOfGroupID:groupID];
        return;
    }
    [TUITool makeToast:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupRecycledTipsFormat), data.groupID]];
    [self handleRemoveConversation:data];
}

- (void)onMemberKicked:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    BOOL kicked = NO;
    for (V2TIMGroupMemberInfo *info in memberList) {
        if ([info.userID isEqualToString:[TUILogin getUserID]]) {
            kicked = YES;
            break;
        }
    }
    if (kicked == NO) {
        return;
    }
    
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (data == nil) {
        [self dealFoldcellDataOfGroupID:groupID];
        return;
    }
    
    [TUITool makeToast:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupKickOffTipsFormat), data.groupID]];
    [self handleRemoveConversation:data];
}

- (void)onQuitFromGroup:(NSString *)groupID {
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (data == nil) {
        [self dealFoldcellDataOfGroupID:groupID];
        return;
    }
    [TUITool makeToast:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitGroupDropoutTipsFormat), data.groupID]];
    [self handleRemoveConversation:data];
}

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupChangeInfo *> *)changeInfoList {
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (groupID.length == 0 || data == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSString *conversationID = [NSString stringWithFormat:@"group_%@",groupID];
    [V2TIMManager.sharedInstance getConversation:conversationID succ:^(V2TIMConversation *conv) {
        [weakSelf preprocess:@[conv]];
    } fail:^(int code, NSString *desc) {
        kLog(@"[TUIConversation] %s, code:%d, desc:%@", __func__, code, desc);
    }];
}

#pragma mark - V2TIMSDKListener
- (void)onUserStatusChanged:(NSArray<V2TIMUserStatus *> *)userStatusList {
    [self handleOnlineStatus:userStatusList];
}

#pragma mark - V2TIMAdvancedMsgListener

- (void)onRecvNewMessage:(V2TIMMessage *)msg {

    // 如果会话里是被隐藏的会话，则需要先清理被隐藏标记
    // when a new message is received, if the conversation is a hidden conversation, you need to clear the hidden mark first
    
    // 如果会话里被标记未读，则需要清理标记
    // when a new message is received, if the conversation is marked unread, you need to clear the mark
    
    NSString *userID = msg.userID;
    NSString *groupID = msg.groupID;
    NSString *conversationID = @"";
    
    if ([self.class isTypingBusinessMessage:msg] ) {
        return;
    }
    if (IS_NOT_EMPTY_NSSTRING(userID)) {
        conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
    }
    
    if (IS_NOT_EMPTY_NSSTRING(groupID)) {
        conversationID = [NSString stringWithFormat:@"group_%@",groupID];
    }
    
    [V2TIMManager.sharedInstance markConversation:@[conversationID] markType:@(V2TIM_CONVERSATION_MARK_TYPE_HIDE) enableMark:NO succ:^(NSArray<V2TIMConversationOperationResult *> *result) {
        [V2TIMManager.sharedInstance markConversation:@[conversationID] markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD) enableMark:NO succ:nil fail:^(int code, NSString *desc) {
            kLog(@"[TUIConversation] %s code:%d, desc:%@", __func__, code, desc);
        }];
    } fail:^(int code, NSString *desc) {
        kLog(@"[TUIConversation] %s code:%d, desc:%@", __func__, code, desc);
    }];

}

#pragma mark - SDK Data Process

- (void)handleClearGroupHistoryMessage:(NSString *)groupID {
    [V2TIMManager.sharedInstance clearGroupHistoryMessage:groupID succ:^{
        kLog(@"[TUIConversation] %s success", __func__);
    } fail:^(int code, NSString *desc) {
        kLog(@"[TUIConversation] %s code:%d, desc:%@", __func__, code, desc);
    }];
}

- (void)handleClearC2CHistoryMessage:(NSString *)userID {
    [V2TIMManager.sharedInstance clearC2CHistoryMessage:userID succ:^{
        kLog(@"[TUIConversation] %s success", __func__);
    } fail:^(int code, NSString *desc) {
        kLog(@"[TUIConversation] %s code:%d, desc:%@", __func__, code, desc);
    }];
}

- (void)handlePinConversation:(TUIConversationCellData *)conversation pin:(BOOL)pin {
    NSInteger index = pin ? 0 : self.startIndexOfUnpinedConversation;
    NSInteger currentIndex = [self.conversationList indexOfObject:conversation];
    if (currentIndex <= index) {
        index = index - 1;
        if (index < 0) {
            index = 0;
        }
    }
    conversation.isOnTop = pin;
    [self.conversationList removeObject:conversation];
    [self.conversationList insertObject:conversation atIndex:index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadAllConversations)]) {
        [self.delegate reloadAllConversations];
    }
    [self checkStartIndexOfUnpinnedConversation];

    dispatch_async(dispatch_get_main_queue(), ^{
        [V2TIMManager.sharedInstance pinConversation:conversation.conversationID
                                            isPinned:pin
                                                succ:nil
                                                fail:nil];
    });
}

- (TUIConversationCellData *)cellDataForConversation:(V2TIMConversation *)conversation {
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.conversationID = conversation.conversationID;
    data.groupID        = conversation.groupID;
    data.groupType      = conversation.groupType;
    data.userID         = conversation.userID;
    data.title          = conversation.showName;
    data.faceUrl        = conversation.faceUrl;
    data.subTitle       = [self getLastDisplayString:conversation];
    data.foldSubTitle   = [self getLastDisplayStringForFoldList:conversation];
    data.atMsgSeqs      = [self getGroupatMsgSeqs:conversation];
    data.time           = [self getLastDisplayDate:conversation];
    data.isOnTop        = conversation.isPinned;
    data.unreadCount    = conversation.unreadCount;
    data.draftText      = conversation.draftText;
    data.isNotDisturb   = [self isConversationNotDisturb:conversation];
    data.orderKey       = conversation.orderKey;
    data.avatarImage    = (conversation.type == V2TIM_C2C ? DefaultAvatarImage : DefaultGroupAvatarImageByGroupType(conversation.groupType));
    data.onlineStatus   = TUIConversationOnlineStatusUnknown;
    data.isMarkAsUnread = [TUIConversationCellData isMarkedByUnReadType:conversation.markList];
    data.isMarkAsHide = [TUIConversationCellData isMarkedByHideType:conversation.markList];
    return data;
}

- (BOOL)isConversationNotDisturb:(V2TIMConversation *)conversation {
    return ![conversation.groupType isEqualToString:GroupType_Meeting] && (V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE == conversation.recvOpt);
}

- (NSMutableAttributedString *)getLastDisplayStringForFoldList:(V2TIMConversation *)conv {
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemRedColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];
    
    NSString * showName = [NSString stringWithFormat:@"%@: ",conv.showName];
    [attributeString appendAttributedString:[[NSAttributedString alloc]
                                             initWithString:showName]];

    NSString *lastMsgStr = @"";
    
    /**
     * 先看下外部有没自定义会话的 lastMsg 展示信息
     * Attempt to get externally customized display information
     */
    if (self.delegate && [self.delegate respondsToSelector:@selector(getConversationDisplayString:)]) {
        lastMsgStr = [self.delegate getConversationDisplayString:conv];
    }
    
    /**
     * 外部没有自定义，通过消息获取 lastMsg 展示信息
     * If there is no external customization, get the lastMsg display information through the message module
     */
    if (lastMsgStr.length == 0 && conv.lastMessage) {
        NSDictionary *param = @{TUICore_TUIChatService_GetDisplayStringMethod_MsgKey:conv.lastMessage};
        lastMsgStr = [TUICore callService:TUICore_TUIChatService method:TUICore_TUIChatService_GetDisplayStringMethod param:param];
    }
    
    /**
     * 如果没有 lastMsg 展示信息，也没有草稿信息，直接返回 nil
     * If there is no lastMsg display information and no draft information, return nil directly
     */
    if (lastMsgStr.length == 0) {
        return nil;
    }
    [attributeString appendAttributedString:[[NSAttributedString alloc]
                                             initWithString:lastMsgStr]];
    return attributeString;

}
- (NSMutableAttributedString *)getLastDisplayString:(V2TIMConversation *)conv {
    /**
     * 如果有群 @ ，展示群 @ 信息
     * If has group-at message, the group-at information will be displayed first
     */
    NSString *atStr = [self getGroupAtTipString:conv];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:atStr];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemRedColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];
    
    /**
     * 如果有草稿箱，优先展示草稿箱信息
     * If there is a draft box, the draft box information will be displayed first
     */
    if(conv.draftText.length > 0){
        NSAttributedString *draft = [[NSAttributedString alloc] initWithString:TUIKitLocalizableString(TUIKitMessageTypeDraftFormat)
                                                                    attributes:@{NSForegroundColorAttributeName:RGB(250, 81, 81)}];
        [attributeString appendAttributedString:draft];
        
        NSAttributedString *draftContent = [[NSAttributedString alloc] initWithString:[self getDraftContent:conv]
                                                                           attributes:@{NSForegroundColorAttributeName:[UIColor d_systemGrayColor]}];
        [attributeString appendAttributedString:draftContent];
    } else {
        /**
         * 没有草稿箱，展示会话 lastMsg 信息
         * No drafts, show conversation lastMsg information
         */
        NSString *lastMsgStr = @"";
        
        /**
         * 先看下外部有没自定义会话的 lastMsg 展示信息
         * Attempt to get externally customized display information
         */
        if (self.delegate && [self.delegate respondsToSelector:@selector(getConversationDisplayString:)]) {
            lastMsgStr = [self.delegate getConversationDisplayString:conv];
        }
        
        /**
         * 外部没有自定义，通过消息获取 lastMsg 展示信息
         * If there is no external customization, get the lastMsg display information through the message module
         */
        if (lastMsgStr.length == 0 && conv.lastMessage) {
            NSDictionary *param = @{TUICore_TUIChatService_GetDisplayStringMethod_MsgKey:conv.lastMessage};
            lastMsgStr = [TUICore callService:TUICore_TUIChatService method:TUICore_TUIChatService_GetDisplayStringMethod param:param];
        }
        
        /**
         * 如果没有 lastMsg 展示信息，也没有草稿信息，直接返回 nil
         * If there is no lastMsg display information and no draft information, return nil directly
         */
        if (lastMsgStr.length == 0) {
            return nil;
        }
        [attributeString appendAttributedString:[[NSAttributedString alloc]
                                                 initWithString:lastMsgStr]];
    }
    
    /**
     * 如果设置了免打扰，展示消息免打扰状态
     * Meeting 群默认就是 V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE 状态，UI 上不特殊处理
     *
     * If do-not-disturb is set, the message do-not-disturb state is displayed
     * The default state of the meeting type group is V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE, and the UI does not process it.
     */
    if ([self isConversationNotDisturb:conv] && conv.unreadCount > 0) {
        NSAttributedString *unreadString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%d条] ", conv.unreadCount]];
        [attributeString insertAttributedString:unreadString atIndex:0];
    }
    
    /**
     * 如果会话 lastMsg 在发送中或者发送失败，展示消息发送状态（草稿箱不用展示发送状态）
     * If the status of the lastMsg of the conversation is sending or failed, display the sending status of the message (the draft box does not need to display the sending status)
     */
    if (!conv.draftText && (V2TIM_MSG_STATUS_SENDING == conv.lastMessage.status || V2TIM_MSG_STATUS_SEND_FAIL == conv.lastMessage.status)) {
        UIFont *textFont = [UIFont systemFontOfSize:14];
        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName: textFont}];
        NSTextAttachment *attchment = [[NSTextAttachment alloc] init];
        UIImage *image = nil;
        if (V2TIM_MSG_STATUS_SENDING == conv.lastMessage.status) {
            image = TUIConversationCommonBundleImage(@"msg_sending_for_conv");
        } else {
            image = TUIConversationCommonBundleImage(@"msg_error_for_conv");
        }
        attchment.image = image;
        attchment.bounds = CGRectMake(0, -(textFont.lineHeight-textFont.pointSize)/2, textFont.pointSize, textFont.pointSize);
        NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)];
        [attributeString insertAttributedString:spaceString atIndex:0];
        [attributeString insertAttributedString:imageString atIndex:0];
    }
    return attributeString;
}

- (NSMutableArray<NSNumber *> *)getGroupatMsgSeqs:(V2TIMConversation *)conv {
    NSMutableArray *seqList = [NSMutableArray array];
    for (V2TIMGroupAtInfo *atInfo in conv.groupAtInfolist) {
        [seqList addObject:@(atInfo.seq)];
    }
    if (seqList.count > 0) {
        return seqList;
    }
    return nil;
}

- (NSDate *)getLastDisplayDate:(V2TIMConversation *)conv {
    if(conv.draftText.length > 0){
        return conv.draftTimestamp;
    }
    if (conv.lastMessage) {
        return conv.lastMessage.timestamp;
    }
    return [NSDate distantPast];
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
        atTipsStr = TUIKitLocalizableString(TUIKitConversationTipsAtMe);
    }
    if (!atMe && atAll) {
        atTipsStr = TUIKitLocalizableString(TUIKitConversationTipsAtAll);
    }
    if (atMe && atAll) {
        atTipsStr = TUIKitLocalizableString(TUIKitConversationTipsAtMeAndAll);
    }
    return atTipsStr;
}

- (NSString *)getDraftContent:(V2TIMConversation *)conv {
    NSString *draft = conv.draftText;
    if (draft.length == 0) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[draft dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    if (error || jsonDict == nil) {
        return draft;
    }
    
    NSString *draftContent = [jsonDict.allKeys containsObject:@"content"] ? jsonDict[@"content"] : @"";
    return draftContent;
}

- (BOOL)filteConversation:(V2TIMConversation *)conv {
    if (conv.conversationID.length == 0) {
        return YES;
    }
    
    if (conv.userID.length == 0 && conv.groupID.length == 0) {
        return YES;
    }
    
    if (conv.type == V2TIM_UNKNOWN) {
        return YES;
    }
    
    if ([conv.groupType isEqualToString:@"AVChatRoom"]) {
        return YES;
    }
        
    if ([self getLastDisplayDate:conv] == nil) {
        if (conv.unreadCount != 0) {
            /**
             * 修复 在某种情况下会出现data.time为nil且还有未读会话的情况
             * 如果碰到这种情况，直接设置成已读
             *
             * In some case, the time of unread conversation will be nil.
             * If this happens, directly mark the conversation as read.
             */
            if (conv.userID.length > 0) {
                [[V2TIMManager sharedInstance] markC2CMessageAsRead:conv.userID succ:nil fail:nil];
            }
            if (conv.groupID.length > 0) {
                [[V2TIMManager sharedInstance] markGroupMessageAsRead:conv.groupID succ:nil fail:nil];
            }
        }
        return YES;
    }
    return NO;
}

- (void)markConversationHide:(TUIConversationCellData *)data {

    [self handleHideConversation:data];
    
    [V2TIMManager.sharedInstance markConversation:@[data.conversationID] markType:@(V2TIM_CONVERSATION_MARK_TYPE_HIDE) enableMark:YES succ:nil fail:nil];
}

- (void)markConversationAsRead:(TUIConversationCellData *)conv {

    if (conv.userID.length > 0) {
        [[V2TIMManager sharedInstance] markC2CMessageAsRead:conv.userID succ:nil fail:nil];
    }
    if (conv.groupID.length > 0) {
        [[V2TIMManager sharedInstance] markGroupMessageAsRead:conv.groupID succ:nil fail:nil];
    }
    
    [V2TIMManager.sharedInstance markConversation:@[conv.conversationID] markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD) enableMark:NO succ:nil fail:nil];
    
}

- (void)markConversationAsUnRead:(TUIConversationCellData *)conv {

    [V2TIMManager.sharedInstance markConversation:@[conv.conversationID] markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD) enableMark:YES succ:nil fail:nil];
}

+ (BOOL)isTypingBusinessMessage:(V2TIMMessage *)message {
    if (!message.customElem) {
        return NO;
    }
    NSError *error;
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"parse customElem data error: %@", error);
        return NO;
    }
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSString *businessID = param[BussinessID];
    if (!businessID || ![businessID isKindOfClass:[NSString class]]) {
        return NO;
    }
    if ([businessID isEqualToString:BussinessID_Typing]) {
        return  YES;
    }
    return NO;
}

+ (void)cacheConversationFoldListSettings_HideFoldItem:(BOOL)flag{
    NSString *userID =  [TUILogin getUserID];
    NSString *key = [NSString stringWithFormat:@"hide_fold_item_%@",userID];
    [NSUserDefaults.standardUserDefaults setBool:flag forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (void)cacheConversationFoldListSettings_FoldItemIsUnread:(BOOL)flag {
    NSString *userID =  [TUILogin getUserID];
    NSString *key = [NSString stringWithFormat:@"fold_item_is_unread_%@",userID];
    [NSUserDefaults.standardUserDefaults setBool:flag forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (BOOL)getConversationFoldListSettings_HideFoldItem {
    NSString *userID =  [TUILogin getUserID];
    NSString *key = [NSString stringWithFormat:@"hide_fold_item_%@",userID];
    return [NSUserDefaults.standardUserDefaults boolForKey:key];
}
+ (BOOL)getConversationFoldListSettings_FoldItemIsUnread {
    NSString *userID =  [TUILogin getUserID];
    NSString *key = [NSString stringWithFormat:@"fold_item_is_unread_%@",userID];
    return [NSUserDefaults.standardUserDefaults boolForKey:key];
}

#pragma mark - Lazy
- (NSMutableArray<TUIConversationCellData *> *)conversationList {
    if (_conversationList == nil) {
        _conversationList = [NSMutableArray array];
    }
    return _conversationList;
}

- (TUIConversationCellData *)conversationFoldListData {
    if (_conversationFoldListData == nil) {
        _conversationFoldListData = [[TUIConversationCellData alloc] init];
        _conversationFoldListData.conversationID = @"group_conversationFoldListMockID";
        _conversationFoldListData.title          = TUIKitLocalizableString(TUIKitConversationMarkFoldGroups);
        _conversationFoldListData.avatarImage =  TUICoreBundleThemeImage(@"", @"default_fold_group");
        _conversationFoldListData.isNotDisturb   = YES;
    }
    return _conversationFoldListData;
}

- (NSMutableDictionary<NSString *,TUIConversationCellData *> *)markUnreadMap {
    if (_markUnreadMap == nil) {
        _markUnreadMap = [NSMutableDictionary dictionary];
    }
    return _markUnreadMap;
}
- (NSMutableDictionary<NSString *,TUIConversationCellData *> *)markHideMap {
    if (_markHideMap == nil) {
        _markHideMap = [NSMutableDictionary dictionary];
    }
    return _markHideMap;
}
- (NSMutableDictionary<NSString *,TUIConversationCellData *> *)markFoldMap {
    if (_markFoldMap == nil) {
        _markFoldMap = [NSMutableDictionary dictionary];
    }
    return _markFoldMap;
}
@end
