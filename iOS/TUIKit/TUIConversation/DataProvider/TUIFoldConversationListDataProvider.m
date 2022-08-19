//
//  TUIFoldConversationListDataProvider.m
//  TUIConversation
//
//  Created by wyl on 2022/7/21.
//

#import "TUIFoldConversationListDataProvider.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import "TUIDefine.h"
#import "TUICore.h"
#import "TUILogin.h"
#import "TUIConversationCellData.h"

@interface TUIFoldConversationListDataProvider (private)

- (BOOL)filteConversation:(V2TIMConversation *)conv;
- (TUIConversationCellData *)cellDataForConversation:(V2TIMConversation *)conversation;
- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList;
- (void)handleHideConversation:(TUIConversationCellData *)conversation;
- (void)checkStartIndexOfUnpinnedConversation;
- (void)handleInsertConversationList:(NSArray<TUIConversationCellData *> *)conversationList;
- (void)handleUpdateConversationList:(NSArray<TUIConversationCellData *> *)conversationList
                           positions:(NSMutableDictionary<NSString *, NSNumber *> *)positionMaps;
- (TUIConversationCellData *)cellDataOfGroupID:(NSString *)groupID;
- (void)handleRemoveConversation:(TUIConversationCellData *)conversation;
- (void)updateMarkUnreadCount;

@end

@implementation TUIFoldConversationListDataProvider


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
        }
        else {
            // 如果没有被标记为折叠， 则这个会话是需要被移出折叠列表的数据
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
        [markHideDataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.conversationList containsObject:obj] ) {
                [self handleHideConversation:obj];
            }
        }];
    }
    
    if (needHideByCancelMarkFoldDataList.count) {
        [self sortDataList:needHideByCancelMarkFoldDataList];
        [needHideByCancelMarkFoldDataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.conversationList containsObject:obj] ) {
                [self handleHideConversation:obj];
            }
        }];
    }
    
    [self checkStartIndexOfUnpinnedConversation];
}

- (void)handleRemoveConversation:(TUIConversationCellData *)conversation {
    NSInteger index = [self.conversationList indexOfObject:conversation];
    [self.conversationList removeObject:conversation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteConversationAtIndexPaths:)]) {
        [self.delegate deleteConversationAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    }
    
    @weakify(self)
    void (^deleteAction)(void) = ^{
        [[V2TIMManager sharedInstance] deleteConversation:conversation.conversationID succ:^{
            @strongify(self)
            [self updateMarkUnreadCount];
        } fail:nil];
    };

    [V2TIMManager.sharedInstance markConversation:@[conversation.conversationID] markType:@(V2TIM_CONVERSATION_MARK_TYPE_FOLD) enableMark:NO succ:^(NSArray<V2TIMConversationOperationResult *> *result) {
        if (deleteAction) {
            deleteAction();
        }
    } fail:^(int code, NSString *desc) {
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
