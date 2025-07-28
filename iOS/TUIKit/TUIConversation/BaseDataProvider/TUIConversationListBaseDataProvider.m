//
//  TUIConversationListBaseDataProvider.m
//  TUIConversation
//
//  Created by harvy on 2022/7/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationListBaseDataProvider.h"

#import <ImSDK_Plus/ImSDK_Plus.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import "TUIConversationCellData.h"

#define kPageSize 100
#define kLog(...) NSLog(__VA_ARGS__)

@interface TUIConversationListBaseDataProvider () <V2TIMConversationListener,
                                                   V2TIMGroupListener,
                                                   V2TIMSDKListener,
                                                   V2TIMAdvancedMsgListener,
                                                   TUINotificationProtocol>
@property(nonatomic, strong) NSMutableArray<TUIConversationCellData *> *conversationList;
@property(nonatomic, assign, getter=isLastPage) BOOL lastPage;

/**
 * Locally inserted conversation collapse list
 */
@property(nonatomic, strong) TUIConversationCellData *conversationFoldListData;

/**
 *  Deleting conversation list
 */
@property(nonatomic, strong) NSMutableArray *deletingConversationList;
@end

@implementation TUIConversationListBaseDataProvider

- (instancetype)init {
    if (self = [super init]) {
        self.pageIndex = 0;
        self.pageSize = kPageSize;
        self.lastPage = NO;
        self.filter = [[V2TIMConversationListFilter alloc] init];
        self.deletingConversationList = [NSMutableArray array];

        [[V2TIMManager sharedInstance] addConversationListener:self];
        [[V2TIMManager sharedInstance] addGroupListener:self];
        [[V2TIMManager sharedInstance] addIMSDKListener:self];
        [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];

        [TUICore registerEvent:TUICore_TUIConversationNotify subKey:TUICore_TUIConversationNotify_RemoveConversationSubKey object:self];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onLoginSucc) name:TUILoginSuccessNotification object:nil];

    }
    return self;
}

- (void)loadNexPageConversations {
    if (self.isLastPage) {
        return;
    }
    @weakify(self);
    [V2TIMManager.sharedInstance getConversationListByFilter:self.filter
        nextSeq:self.pageIndex
        count:(int)self.pageSize
        succ:^(NSArray<V2TIMConversation *> *list, uint64_t nextSeq, BOOL isFinished) {
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

- (void)addConversationList:(NSArray<TUIConversationCellData *> *)conversationList {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf addConversationList:conversationList];
        });
        return;
    }
    [self handleInsertConversationList:conversationList];
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
            [conversationMap setObject:@([self.conversationList indexOfObject:item]) forKey:item.conversationID];
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
        if ([self.markHideMap objectForKey:cellData.conversationID]) {
            if (![TUIConversationCellData isMarkedByHideType:conv.markList]) {
                [self.markHideMap removeObjectForKey:cellData.conversationID];
            }
        } else {
            if ([TUIConversationCellData isMarkedByHideType:conv.markList]) {
                [self.markHideMap setObject:cellData forKey:cellData.conversationID];
            }
        }

        if ([self.markFoldMap objectForKey:cellData.conversationID]) {
            if (![TUIConversationCellData isMarkedByFoldType:conv.markList]) {
                [self.markFoldMap removeObjectForKey:cellData.conversationID];
            }
        } else {
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
        if ([self.markUnreadMap objectForKey:cellData.conversationID]) {
            //   
            // This is an operation to cancel the unread mark operation or to be cleaned away by a new message from someone else
            if (![TUIConversationCellData isMarkedByUnReadType:conv.markList]) {
                [self.markUnreadMap removeObjectForKey:cellData.conversationID];
            }
        } else {
            if ([TUIConversationCellData isMarkedByUnReadType:conv.markList]) {
                [self.markUnreadMap setObject:cellData forKey:cellData.conversationID];
            }
        }
    }

    if (markFoldDataList.count) {
        __block TUIConversationCellData *cellRecent = nil;
        [markFoldDataList enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
          TUIConversationCellData *cellData = (TUIConversationCellData *)obj;
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
                } else {
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
            } else if (0 == self.filter.conversationGroup.length) {
                [addedDataList addObject:self.conversationFoldListData];
            }
        }
        self.conversationFoldListData.isLocalConversationFoldList = YES;
    } else {
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

    BOOL onlyAIConversation = NO ;
    if (duplicateDataList.count == 1 ) {
        TUIConversationCellData *firstCellData = duplicateDataList.firstObject;
        if (firstCellData && [firstCellData.conversationID  containsString:@"@RBT#"]) {
            onlyAIConversation = YES;
        }
    }
    
    [self updateMardHide:markHideDataList];

    if (!onlyAIConversation) {
        [self updateMarkUnreadCount];
    }

    [self updateMarkFold:markFoldDataList];
  
    [self asnycGetLastMessageDisplay:duplicateDataList addedDataList:addedDataList];
}

- (void)updateMardHide:(NSMutableArray *) markHideDataList {
    if (markHideDataList.count) {
        [self sortDataList:markHideDataList];
        NSMutableArray *pRemoveCellUIList = [NSMutableArray array];
        NSMutableDictionary<NSString *, TUIConversationCellData *> *pMarkHideDataMap = [NSMutableDictionary dictionary];
        for (TUIConversationCellData *item in markHideDataList) {
            if (item.conversationID) {
                [pRemoveCellUIList addObject:item];
                [pMarkHideDataMap setObject:item forKey:item.conversationID];
            }
        }
        for (TUIConversationCellData *item in self.conversationList) {
            if ([pMarkHideDataMap objectForKey:item.conversationID]) {
                [pRemoveCellUIList addObject:item];
            }
        }
        for (TUIConversationCellData *item in pRemoveCellUIList) {
            [self handleHideConversation:item];
        }
    }
}

- (void)updateMarkUnreadCount {
    __block NSInteger markUnreadCount = 0;
    [self.markUnreadMap enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, TUIConversationCellData *_Nonnull obj, BOOL *_Nonnull stop) {
      if (!obj.isNotDisturb) {
          markUnreadCount++;
      }
    }];

    __block NSInteger markHideUnreadCount = 0;
    [self.markHideMap enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, TUIConversationCellData *_Nonnull obj, BOOL *_Nonnull stop) {
      if (obj && [obj isKindOfClass:TUIConversationCellData.class]) {
          if (!obj.isNotDisturb) {
              if (obj.isMarkAsUnread) {
                  markHideUnreadCount = markHideUnreadCount + 1;
              } else {
                  markHideUnreadCount = markHideUnreadCount + obj.unreadCount;
              }
          }
      }
    }];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:TUIKitNotification_onConversationMarkUnreadCountChanged
                      object:nil
                    userInfo:@{
                        TUIKitNotification_onConversationMarkUnreadCountChanged_DataProvider : self,
                        TUIKitNotification_onConversationMarkUnreadCountChanged_MarkUnreadCount : [NSNumber numberWithInteger:markUnreadCount],
                        TUIKitNotification_onConversationMarkUnreadCountChanged_MarkHideUnreadCount : [NSNumber numberWithInteger:markHideUnreadCount],
                        TUIKitNotification_onConversationMarkUnreadCountChanged_MarkUnreadMap : self.markUnreadMap,
                    }];
}

- (void)updateMarkFold:(NSMutableArray *) markFoldDataList {
    if (markFoldDataList.count) {
        [self sortDataList:markFoldDataList];
        NSMutableArray *pRemoveCellUIList = [NSMutableArray array];
        NSMutableDictionary<NSString *, TUIConversationCellData *> *pMarkFoldDataMap = [NSMutableDictionary dictionary];
        for (TUIConversationCellData *item in markFoldDataList) {
            if (item.conversationID) {
                [pRemoveCellUIList addObject:item];
                [pMarkFoldDataMap setObject:item forKey:item.conversationID];
            }
        }
        for (TUIConversationCellData *item in self.conversationList) {
            if ([pMarkFoldDataMap objectForKey:item.conversationID]) {
                [pRemoveCellUIList addObject:item];
            }
        }
        // If a collapsed session appears in the home page List, it needs to be hidden. Note that the history cannot be deleted.
        for (TUIConversationCellData *item in pRemoveCellUIList) {
            [self handleHideConversation:item];
        }
    }
}

- (void)asnycGetLastMessageDisplay:(NSArray<TUIConversationCellData *> *)duplicateDataList addedDataList:(NSArray<TUIConversationCellData *> *)addedDataList {
  // override by subclass
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
                           positions:(NSMutableDictionary<NSString *, NSNumber *> *)positionMaps {
    if (0 == conversationList.count) {
        return;
    }

    for (TUIConversationCellData *item in conversationList) {
        if (item.isLocalConversationFoldList){
            continue;
        }
        NSNumber *position = [positionMaps objectForKey:item.conversationID];
        NSAssert((position && [position isKindOfClass:NSNumber.class]), @"serius error, the self.conversationList maybe changed on the other thread");
        if (position && position.integerValue < self.conversationList.count) {
            TUIConversationCellData *cellData = self.conversationList[position.integerValue];
            item.onlineStatus = cellData.onlineStatus;
            [self.conversationList replaceObjectAtIndex:[position integerValue] withObject:item];
        }
    }

    [self sortDataList:self.conversationList];

    NSInteger minIndex = self.conversationList.count - 1;
    NSInteger maxIndex = 0;

    NSMutableDictionary<NSString *, TUIConversationCellData *> *conversationMap = [NSMutableDictionary dictionary];
    for (TUIConversationCellData *item in self.conversationList) {
        if (item.conversationID) {
            [conversationMap setObject:item forKey:item.conversationID];
        }
    }

    for (TUIConversationCellData *cellData in conversationList) {
        TUIConversationCellData *item = [conversationMap objectForKey:cellData.conversationID];
        if (item) {
            NSInteger previous = [[positionMaps objectForKey:item.conversationID] integerValue];
            NSInteger current = [self.conversationList indexOfObject:item];
            minIndex = minIndex < MIN(previous, current) ? minIndex : MIN(previous, current);
            maxIndex = maxIndex > MAX(previous, current) ? maxIndex : MAX(previous, current);
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
    if (index != NSNotFound) {
        [self.conversationList removeObject:conversation];
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteConversationAtIndexPaths:)]) {
            [self.delegate deleteConversationAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]];
        }

        [self.deletingConversationList addObject:conversation.conversationID];
        @weakify(self)
        [[V2TIMManager sharedInstance] deleteConversation:conversation.conversationID succ:^{
            @strongify(self)
            [self.deletingConversationList removeObject:conversation.conversationID];
            if ([self.markUnreadMap objectForKey:conversation.conversationID]) {
               [self.markUnreadMap removeObjectForKey:conversation.conversationID];
            }
            [self updateMarkUnreadCount];
        } fail:^(int code, NSString *desc) {
            @strongify(self)
            NSLog(@"deleteConversation failed, conversationID:%@ code:%d desc:%@", conversation.conversationID, code, desc);
            [self.deletingConversationList removeObject:conversation.conversationID];
        }];
    }
}

- (void)handleHideConversation:(TUIConversationCellData *)conversation {
    NSInteger index = [self.conversationList indexOfObject:conversation];
    if (index != NSNotFound) {
        [self.conversationList removeObject:conversation];
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteConversationAtIndexPaths:)]) {
            [self.delegate deleteConversationAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]];
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
    NSString *conversationID = [NSString stringWithFormat:@"group_%@", groupID];
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
    NSString *conversationID = [NSString stringWithFormat:@"group_%@", groupID];
    cellData = [self.markFoldMap objectForKey:conversationID];
    if (cellData) {
        @weakify(self);
        [[V2TIMManager sharedInstance] deleteConversation:cellData.conversationID
                                                     succ:^{
                                                       @strongify(self);
                                                       [self.markFoldMap removeObjectForKey:conversationID];
                                                       [self updateFoldGroupNameWhileKickOffOrDismissed];
                                                     }
                                                     fail:nil];
    }
}

- (void)updateFoldGroupNameWhileKickOffOrDismissed {
    __block TUIConversationCellData *cellRecent = nil;
    [self.markFoldMap enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, TUIConversationCellData *_Nonnull obj, BOOL *_Nonnull stop) {
      TUIConversationCellData *cellData = (TUIConversationCellData *)obj;
      if (!cellData.isMarkAsHide) {
          if (!cellRecent) {
              cellRecent = cellData;
          } else {
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
                [conversationMap setObject:@([self.conversationList indexOfObject:item]) forKey:item.conversationID];
            }
        }
        [self handleUpdateConversationList:@[ self.conversationFoldListData ] positions:conversationMap];
    } else {
        if (_conversationFoldListData) {
            [self hideConversation:self.conversationFoldListData];
        }
    }
}

#pragma mark - TUICore
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIConversationNotify] && [subKey isEqualToString:TUICore_TUIConversationNotify_RemoveConversationSubKey]) {
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
            } else {
                @weakify(self);
                [[V2TIMManager sharedInstance] deleteConversation:conversationID
                                                             succ:^{
                                                               @strongify(self);
                                                               [self updateMarkUnreadCount];
                                                             }
                                                             fail:nil];
            }
        }
    }
}
#pragma mark - User Status
- (void)updateOnlineStatus:(NSArray<TUIConversationCellData *> *)conversationList {
    if (conversationList.count == 0) {
        return;
    }
    if (!TUILogin.isUserLogined) {
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
            [positionMap setObject:@([self.conversationList indexOfObject:item]) forKey:item.conversationID];
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
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
          @strongify(self);
          [self asyncGetOnlineStatus:userIDList];
        });
        return;
    }

    // get
    @weakify(self);
    [V2TIMManager.sharedInstance getUserStatus:userIDList
        succ:^(NSArray<V2TIMUserStatus *> *result) {
          @strongify(self);
          [self handleOnlineStatus:result];
        }
        fail:^(int code, NSString *desc) {
#if DEBUG
          if (code == ERR_SDK_INTERFACE_NOT_SUPPORT && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
              [TUITool makeToast:desc];
          }
#endif
        }];

    // subscribe for the users who was deleted from friend list
    [V2TIMManager.sharedInstance subscribeUserStatus:userIDList
                                                succ:^{

                                                }
                                                fail:^(int code, NSString *desc){

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
            [positonMap setObject:@([self.conversationList indexOfObject:item]) forKey:item.conversationID];
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
            } break;
            case V2TIM_USER_STATUS_OFFLINE:
            case V2TIM_USER_STATUS_UNLOGINED: {
                conversation.onlineStatus = TUIConversationOnlineStatusOffline;
            } break;
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
- (void)onNewConversation:(NSArray<V2TIMConversation *> *)conversationList {
    [self preprocess:conversationList];
}

- (void)onConversationChanged:(NSArray<V2TIMConversation *> *)conversationList {
    [self preprocess:conversationList];
}

- (void)onConversationDeleted:(NSArray<NSString *> *)conversationIDList {
    NSArray *cacheConversationList = [self.conversationList copy];
    for (TUIConversationCellData *item in cacheConversationList) {
        if ([conversationIDList containsObject:item.conversationID]) {
            NSInteger index = [self.conversationList indexOfObject:item];
            if (index != NSNotFound) {
                [self.conversationList removeObject:item];
                if (self.delegate && [self.delegate respondsToSelector:@selector(deleteConversationAtIndexPaths:)]) {
                    [self.delegate deleteConversationAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]];
                }
                if ([self.markUnreadMap objectForKey:item.conversationID]) {
                   [self.markUnreadMap removeObjectForKey:item.conversationID];
                }
                [self updateMarkUnreadCount];
            }
        }
    }
}

#pragma mark - V2TIMGroupListener
- (NSString *)getGroupName:(TUIConversationCellData *)cellData {
    NSString *formatString = cellData.groupID;
    if (cellData.title.length > 0) {
        return cellData.title;
    }
    else if (cellData.groupID.length > 0) {
        return cellData.groupID;
    }
    return @"";
}

- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (data == nil) {
        [self dealFoldcellDataOfGroupID:groupID];
        return;
    }
    
    NSString *groupName = [self getGroupName:data];
    [TUITool makeToast:[NSString stringWithFormat:TIMCommonLocalizableString(TUIKitGroupDismssTipsFormat), groupName]];
    [self handleRemoveConversation:data];
}

- (void)onGroupRecycled:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (data == nil) {
        [self dealFoldcellDataOfGroupID:groupID];
        return;
    }
    NSString *groupName = [self getGroupName:data];

    [TUITool makeToast:[NSString stringWithFormat:TIMCommonLocalizableString(TUIKitGroupRecycledTipsFormat), groupName]];
    [self handleRemoveConversation:data];
}

- (void)onMemberKicked:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList {
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

    NSString *groupName = [self getGroupName:data];
    [TUITool makeToast:[NSString stringWithFormat:TIMCommonLocalizableString(TUIKitGroupKickOffTipsFormat), groupName]];
    [self handleRemoveConversation:data];
}

- (void)onQuitFromGroup:(NSString *)groupID {
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (data == nil) {
        [self dealFoldcellDataOfGroupID:groupID];
        return;
    }
    NSString *groupName = [self getGroupName:data];
    [TUITool makeToast:[NSString stringWithFormat:TIMCommonLocalizableString(TUIKitGroupDropoutTipsFormat), groupName]];
    [self handleRemoveConversation:data];
}

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray<V2TIMGroupChangeInfo *> *)changeInfoList {
    TUIConversationCellData *data = [self cellDataOfGroupID:groupID];
    if (groupID.length == 0 || data == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSString *conversationID = [NSString stringWithFormat:@"group_%@", groupID];
    [V2TIMManager.sharedInstance getConversation:conversationID
        succ:^(V2TIMConversation *conv) {
          [weakSelf preprocess:@[ conv ]];
        }
        fail:^(int code, NSString *desc) {
          kLog(@"[TUIConversation] %s, code:%d, desc:%@", __func__, code, desc);
        }];
}

#pragma mark - V2TIMSDKListener
- (void)onUserStatusChanged:(NSArray<V2TIMUserStatus *> *)userStatusList {
    [self handleOnlineStatus:userStatusList];
}

- (void)onConnectFailed:(int)code err:(NSString *)err {
    NSLog(@"%s", __func__);
}

- (void)onConnectSuccess {
    NSLog(@"%s", __func__);
    if (self.conversationList.count > 0) {
        NSArray *conversationList = [NSArray arrayWithArray:self.conversationList];
        [self updateOnlineStatus:conversationList];
    }
}

- (void)onLoginSucc {
    NSLog(@"%s", __func__);
    if (self.conversationList.count > 0) {
        NSArray *conversationList = [NSArray arrayWithArray:self.conversationList];
        [self updateOnlineStatus:conversationList];
    }

}
#pragma mark - V2TIMAdvancedMsgListener

- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    // when a new message is received, if the conversation is a hidden conversation, you need to clear the hidden mark first
    
    // when a new message is received, if the conversation is marked unread, you need to clear the mark
    
    NSString *userID = msg.userID;
    NSString *groupID = msg.groupID;
    NSString *conversationID = @"";

    if ([self.class isTypingBusinessMessage:msg]) {
        return;
    }
    if (IS_NOT_EMPTY_NSSTRING(userID)) {
        conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
    }

    if (IS_NOT_EMPTY_NSSTRING(groupID)) {
        conversationID = [NSString stringWithFormat:@"group_%@", groupID];
    }
    
    TUIConversationCellData * targetCellData = nil;
    for (TUIConversationCellData * cellData in self.conversationList) {
        if ([cellData.conversationID isEqualToString:conversationID]) {
            targetCellData = cellData;
            break;
        }
    }
    if (targetCellData) {
        BOOL existInHidelist = targetCellData.isMarkAsHide;
        
        BOOL existInUnreadlist = targetCellData.isMarkAsUnread;

        if (existInHidelist || existInUnreadlist) {
            [self cancelHideAndUnreadMarkConversation:conversationID existInHidelist:existInHidelist existInUnreadlist:existInUnreadlist];
        }
    }
    else {
        [V2TIMManager.sharedInstance getConversation:conversationID
            succ:^(V2TIMConversation *conv) {
            TUIConversationCellData *cellData = [self cellDataForConversation:conv];
            BOOL existInHidelist = cellData.isMarkAsHide;
            
            BOOL existInUnreadlist = cellData.isMarkAsUnread;

            if (existInHidelist || existInUnreadlist) {
                [self cancelHideAndUnreadMarkConversation:conversationID existInHidelist:existInHidelist existInUnreadlist:existInUnreadlist];
            }

            }
            fail:^(int code, NSString *desc) {
              kLog(@"[TUIConversation] %s, code:%d, desc:%@", __func__, code, desc);
            }];
    }

}
- (void)cancelHideAndUnreadMarkConversation:(NSString *)conversationID existInHidelist:(BOOL)existInHidelist existInUnreadlist:(BOOL)existInUnreadlist  {
    if(existInHidelist && existInUnreadlist) {
        [V2TIMManager.sharedInstance markConversation:@[ conversationID ]
            markType:@(V2TIM_CONVERSATION_MARK_TYPE_HIDE)
            enableMark:NO
            succ:^(NSArray<V2TIMConversationOperationResult *> *result) {
              [V2TIMManager.sharedInstance markConversation:@[ conversationID ]
                                                   markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD)
                                                 enableMark:NO
                                                       succ:nil
                                                       fail:^(int code, NSString *desc) {
                                                         kLog(@"[TUIConversation] %s code:%d, desc:%@", __func__, code, desc);
                                                       }];
            }
            fail:^(int code, NSString *desc) {
              kLog(@"[TUIConversation] %s code:%d, desc:%@", __func__, code, desc);
            }];
    }
    else if (existInHidelist)  {
        [V2TIMManager.sharedInstance markConversation:@[ conversationID ]
            markType:@(V2TIM_CONVERSATION_MARK_TYPE_HIDE)
            enableMark:NO
            succ:nil
            fail:^(int code, NSString *desc) {
              kLog(@"[TUIConversation] %s code:%d, desc:%@", __func__, code, desc);
            }];
    }
    else if (existInUnreadlist) {
        [V2TIMManager.sharedInstance markConversation:@[ conversationID ]
                                             markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD)
                                           enableMark:NO
                                                 succ:nil
                                                 fail:^(int code, NSString *desc) {
                                                   kLog(@"[TUIConversation] %s code:%d, desc:%@", __func__, code, desc);
                                                 }];
    }
    else {
        // noting to do
    }
}

#pragma mark - SDK Data Process

- (void)handleClearGroupHistoryMessage:(NSString *)groupID {
    [V2TIMManager.sharedInstance clearGroupHistoryMessage:groupID
        succ:^{
          kLog(@"[TUIConversation] %s success", __func__);
        }
        fail:^(int code, NSString *desc) {
          kLog(@"[TUIConversation] %s code:%d, desc:%@", __func__, code, desc);
        }];
}

- (void)handleClearC2CHistoryMessage:(NSString *)userID {
    [V2TIMManager.sharedInstance clearC2CHistoryMessage:userID
        succ:^{
          kLog(@"[TUIConversation] %s success", __func__);
        }
        fail:^(int code, NSString *desc) {
          kLog(@"[TUIConversation] %s code:%d, desc:%@", __func__, code, desc);
        }];
}

- (void)handlePinConversation:(TUIConversationCellData *)conversation pin:(BOOL)pin {
    dispatch_async(dispatch_get_main_queue(), ^{
      [V2TIMManager.sharedInstance pinConversation:conversation.conversationID isPinned:pin succ:nil fail:nil];
    });
}

- (TUIConversationCellData *)cellDataForConversation:(V2TIMConversation *)conversation {
    Class cls = [self getConversationCellClass];
    if (cls) {
        TUIConversationCellData *data = (TUIConversationCellData *)[[cls alloc] init];
        data.conversationID = conversation.conversationID;
        data.groupID = conversation.groupID;
        data.groupType = conversation.groupType;
        data.userID = conversation.userID;
        data.title = conversation.showName;
        data.faceUrl = conversation.faceUrl;
        data.subTitle = [self getLastDisplayString:conversation];
        data.foldSubTitle = [self getLastDisplayStringForFoldList:conversation];
        data.atTipsStr = [self getGroupAtTipString:conversation];
        data.atMsgSeqs = [self getGroupatMsgSeqs:conversation];
        data.time = [self getLastDisplayDate:conversation];
        data.isOnTop = conversation.isPinned;
        data.unreadCount = conversation.unreadCount;
        data.draftText = conversation.draftText;
        data.isNotDisturb = [self isConversationNotDisturb:conversation];
        data.orderKey = conversation.orderKey;
        data.avatarImage = (conversation.type == V2TIM_C2C ? DefaultAvatarImage : DefaultGroupAvatarImageByGroupType(conversation.groupType));
        data.onlineStatus = TUIConversationOnlineStatusUnknown;
        data.isMarkAsUnread = [TUIConversationCellData isMarkedByUnReadType:conversation.markList];
        data.isMarkAsHide = [TUIConversationCellData isMarkedByHideType:conversation.markList];
        data.isMarkAsFolded = [TUIConversationCellData isMarkedByFoldType:conversation.markList];
        data.lastMessage = conversation.lastMessage;
        data.innerConversation = conversation;
        data.conversationGroupList = conversation.conversationGroupList;
        data.conversationMarkList = conversation.markList;
        return data;
    }
    return nil;
}

- (BOOL)isConversationNotDisturb:(V2TIMConversation *)conversation {
    return ![conversation.groupType isEqualToString:GroupType_Meeting] && (V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE == conversation.recvOpt);
}

- (NSMutableAttributedString *)getLastDisplayStringForFoldList:(V2TIMConversation *)conversation {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName : [UIColor d_systemRedColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];

    NSString *showName = [NSString stringWithFormat:@"%@: ", conversation.showName];
    [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:showName]];

    NSString *lastMsgStr = @"";

    /**
     * Attempt to get externally customized display information
     */
    if (self.delegate && [self.delegate respondsToSelector:@selector(getConversationDisplayString:)]) {
        lastMsgStr = [self.delegate getConversationDisplayString:conversation];
    }

    /**
     * If there is no external customization, get the lastMsg display information through the message module
     */
    if (lastMsgStr.length == 0 && conversation.lastMessage) {
        lastMsgStr = [self getDisplayStringFromService:conversation.lastMessage];
    }

    /**
     * If there is no lastMsg display information and no draft information, return nil directly
     */
    if (lastMsgStr.length == 0) {
        return nil;
    }
    [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:lastMsgStr]];
    return attributeString;
}
- (NSMutableAttributedString *)getLastDisplayString:(V2TIMConversation *)conversation {
    // subclass overide
    return nil;
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
    if (conv.draftText.length > 0) {
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
                continue;
                ;
            case V2TIM_AT_ALL:
                atAll = YES;
                continue;
                ;
            case V2TIM_AT_ALL_AT_ME:
                atMe = YES;
                atAll = YES;
                continue;
                ;
            default:
                continue;
                ;
        }
    }
    if (atMe && !atAll) {
        atTipsStr = TIMCommonLocalizableString(TUIKitConversationTipsAtMe);
    }
    if (!atMe && atAll) {
        atTipsStr = TIMCommonLocalizableString(TUIKitConversationTipsAtAll);
    }
    if (atMe && atAll) {
        atTipsStr = TIMCommonLocalizableString(TUIKitConversationTipsAtMeAndAll);
    }
    return atTipsStr;
}

- (NSString *)getDraftContent:(V2TIMConversation *)conv {
    NSString *draft = conv.draftText;
    if (draft.length == 0) {
        return nil;
    }

    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[draft dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableLeaves
                                                               error:&error];
    if (error || jsonDict == nil) {
        return draft;
    }

    NSString *draftContent = [jsonDict.allKeys containsObject:@"content"] ? jsonDict[@"content"] : @"";
    return draftContent;
}

- (BOOL)filteConversation:(V2TIMConversation *)conversation {
    if (conversation.conversationID.length == 0 ||
        [self.deletingConversationList containsObject:conversation.conversationID]) {
        return YES;
    }

    if (conversation.userID.length == 0 && conversation.groupID.length == 0) {
        return YES;
    }

    if (conversation.type == V2TIM_UNKNOWN) {
        return YES;
    }

    if ([conversation.groupType isEqualToString:@"AVChatRoom"]) {
        return YES;
    }

    if ([self getLastDisplayDate:conversation] == nil) {
        if (conversation.unreadCount != 0) {
            /**
             * In some case, the time of unread conversation will be nil.
             * If this happens, directly mark the conversation as read.
             */
            [[V2TIMManager sharedInstance] cleanConversationUnreadMessageCount:conversation.conversationID cleanTimestamp:0 cleanSequence:0 succ:nil fail:nil];
        }
        return YES;
    }
    return NO;
}

- (void)markConversationHide:(TUIConversationCellData *)data {
    [self handleHideConversation:data];

    [V2TIMManager.sharedInstance markConversation:@[ data.conversationID ] markType:@(V2TIM_CONVERSATION_MARK_TYPE_HIDE) enableMark:YES succ:nil fail:nil];
}

- (void)markConversationAsRead:(TUIConversationCellData *)conv {
    [[V2TIMManager sharedInstance] cleanConversationUnreadMessageCount:conv.conversationID cleanTimestamp:0 cleanSequence:0 succ:nil fail:nil];

    [V2TIMManager.sharedInstance markConversation:@[ conv.conversationID ] markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD) enableMark:NO succ:nil fail:nil];
}

- (void)markConversationAsUnRead:(TUIConversationCellData *)conv {
    [V2TIMManager.sharedInstance markConversation:@[ conv.conversationID ] markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD) enableMark:YES succ:nil fail:nil];
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
    // Normal session peer is typing
    NSString *businessID = param[BussinessID];
    if (businessID && [businessID isKindOfClass:[NSString class]] && [businessID isEqualToString:BussinessID_Typing]) {
        return YES;
    }
    // The customer service session peer is typing
    if ([param.allKeys containsObject:BussinessID_CustomerService]) {
        NSString *src = param[BussinessID_Src_CustomerService];
        if (src && [src isKindOfClass:[NSString class]] && [src isEqualToString:BussinessID_Src_CustomerService_Typing]) {
            return YES;
        }
    }
    return NO;
}

+ (void)cacheConversationFoldListSettings_HideFoldItem:(BOOL)flag {
    NSString *userID = [TUILogin getUserID];
    NSString *key = [NSString stringWithFormat:@"hide_fold_item_%@", userID];
    [NSUserDefaults.standardUserDefaults setBool:flag forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (void)cacheConversationFoldListSettings_FoldItemIsUnread:(BOOL)flag {
    NSString *userID = [TUILogin getUserID];
    NSString *key = [NSString stringWithFormat:@"fold_item_is_unread_%@", userID];
    [NSUserDefaults.standardUserDefaults setBool:flag forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (BOOL)getConversationFoldListSettings_HideFoldItem {
    NSString *userID = [TUILogin getUserID];
    NSString *key = [NSString stringWithFormat:@"hide_fold_item_%@", userID];
    return [NSUserDefaults.standardUserDefaults boolForKey:key];
}
+ (BOOL)getConversationFoldListSettings_FoldItemIsUnread {
    NSString *userID = [TUILogin getUserID];
    NSString *key = [NSString stringWithFormat:@"fold_item_is_unread_%@", userID];
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
        Class cls = [self getConversationCellClass];
        if (cls) {
            _conversationFoldListData = (TUIConversationCellData *)[[cls alloc] init];
            _conversationFoldListData.conversationID = gGroup_conversationFoldListMockID;
            _conversationFoldListData.title = TIMCommonLocalizableString(TUIKitConversationMarkFoldGroups);
            _conversationFoldListData.avatarImage = TUICoreBundleThemeImage(@"", @"default_fold_group");
            _conversationFoldListData.isNotDisturb = YES;
        }
    }
    return _conversationFoldListData;
}

- (NSMutableDictionary<NSString *, TUIConversationCellData *> *)markUnreadMap {
    if (_markUnreadMap == nil) {
        _markUnreadMap = [NSMutableDictionary dictionary];
    }
    return _markUnreadMap;
}
- (NSMutableDictionary<NSString *, TUIConversationCellData *> *)markHideMap {
    if (_markHideMap == nil) {
        _markHideMap = [NSMutableDictionary dictionary];
    }
    return _markHideMap;
}
- (NSMutableDictionary<NSString *, TUIConversationCellData *> *)markFoldMap {
    if (_markFoldMap == nil) {
        _markFoldMap = [NSMutableDictionary dictionary];
    }
    return _markFoldMap;
}

#pragma mark Override func
- (Class)getConversationCellClass {
    // subclass override
    return nil;
}

- (NSString *)getDisplayStringFromService:(V2TIMMessage *)msg {
    // subclass override
    return nil;
}
@end
