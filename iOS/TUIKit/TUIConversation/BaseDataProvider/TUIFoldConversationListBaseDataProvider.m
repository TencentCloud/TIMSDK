//
//  TUIFoldConversationListBaseDataProvider.m
//  TUIConversation
//
//  Created by wyl on 2022/7/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFoldConversationListBaseDataProvider.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import "TUIConversationCellData.h"

@interface TUIFoldConversationListBaseDataProvider (private)
@property(nonatomic, assign, getter=isLastPage) BOOL lastPage;

- (BOOL)filteConversation:(V2TIMConversation *)conv;
- (TUIConversationCellData *)cellDataForConversation:(V2TIMConversation *)conversation;
- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList;
- (void)handleHideConversation:(TUIConversationCellData *)conversation;
- (void)handleInsertConversationList:(NSArray<TUIConversationCellData *> *)conversationList;
- (void)handleUpdateConversationList:(NSArray<TUIConversationCellData *> *)conversationList
                           positions:(NSMutableDictionary<NSString *, NSNumber *> *)positionMaps;
- (TUIConversationCellData *)cellDataOfGroupID:(NSString *)groupID;
- (void)handleRemoveConversation:(TUIConversationCellData *)conversation;
- (void)updateMarkUnreadCount;

@end

@implementation TUIFoldConversationListBaseDataProvider

- (void)loadNexPageConversations {
    if (self.isLastPage) {
        return;
    }
    @weakify(self);
    V2TIMConversationListFilter *filter = [[V2TIMConversationListFilter alloc] init];
    filter.type = V2TIM_GROUP;
    filter.markType = V2TIM_CONVERSATION_MARK_TYPE_FOLD;

    [V2TIMManager.sharedInstance getConversationListByFilter:filter
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
        }];
}
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
    NSMutableArray *needHideByCancelMarkFoldDataList = [NSMutableArray array];

    for (V2TIMConversation *conv in v2Convs) {
        if ([self filteConversation:conv]) {
            continue;
        }

        if ([TUIConversationCellData isMarkedByHideType:conv.markList]) {
            if ([TUIConversationCellData isMarkedByHideType:conv.markList]) {
                [markHideDataList addObject:[self cellDataForConversation:conv]];
            }
            continue;
        }

        TUIConversationCellData *cellData = [self cellDataForConversation:conv];
        if ([TUIConversationCellData isMarkedByFoldType:conv.markList]) {
            if ([conversationMap objectForKey:cellData.conversationID]) {
                [duplicateDataList addObject:cellData];
            } else {
                [addedDataList addObject:cellData];
            }
        } else {
            // If not marked as folded, this conversation is the data that needs to be removed from the folded list
            if ([conversationMap objectForKey:cellData.conversationID]) {
                [needHideByCancelMarkFoldDataList addObject:cellData];
            }
        }
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

    if (needHideByCancelMarkFoldDataList.count) {
        [self sortDataList:needHideByCancelMarkFoldDataList];
        NSMutableArray *pRemoveCellUIList = [NSMutableArray array];
        NSMutableDictionary<NSString *, TUIConversationCellData *> *pMarkCancelFoldDataMap = [NSMutableDictionary dictionary];
        for (TUIConversationCellData *item in needHideByCancelMarkFoldDataList) {
            if (item.conversationID) {
                [pRemoveCellUIList addObject:item];
                [pMarkCancelFoldDataMap setObject:item forKey:item.conversationID];
            }
        }
        for (TUIConversationCellData *item in self.conversationList) {
            if ([pMarkCancelFoldDataMap objectForKey:item.conversationID]) {
                [pRemoveCellUIList addObject:item];
            }
        }
        for (TUIConversationCellData *item in pRemoveCellUIList) {
            [self handleHideConversation:item];
        }
    }
}

- (void)handleRemoveConversation:(TUIConversationCellData *)conversation {
    NSInteger index = [self.conversationList indexOfObject:conversation];
    [self.conversationList removeObject:conversation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteConversationAtIndexPaths:)]) {
        [self.delegate deleteConversationAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]];
    }

    @weakify(self);
    void (^deleteAction)(void) = ^{
      [[V2TIMManager sharedInstance] deleteConversation:conversation.conversationID
                                                   succ:^{
                                                     @strongify(self);
                                                     [self updateMarkUnreadCount];
                                                   }
                                                   fail:nil];
    };

    [V2TIMManager.sharedInstance markConversation:@[ conversation.conversationID ]
        markType:@(V2TIM_CONVERSATION_MARK_TYPE_FOLD)
        enableMark:NO
        succ:^(NSArray<V2TIMConversationOperationResult *> *result) {
          if (deleteAction) {
              deleteAction();
          }
        }
        fail:^(int code, NSString *desc) {
          if (deleteAction) {
              deleteAction();
          }
        }];

    [self.needRemoveConversationList addObject:conversation.conversationID];
}

- (NSMutableArray *)needRemoveConversationList {
    if (!_needRemoveConversationList) {
        _needRemoveConversationList = [NSMutableArray array];
    }
    return _needRemoveConversationList;
}

@end
