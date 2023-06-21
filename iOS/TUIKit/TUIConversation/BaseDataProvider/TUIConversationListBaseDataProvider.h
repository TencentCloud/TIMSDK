//
//  TUIConversationListBaseDataProvider.h
//  TUIConversation
//
//  Created by harvy on 2022/7/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@import ImSDK_Plus;

@class V2TIMConversation;
@class V2TIMConversationListFilter;
@class V2TIMMessage;
@class TUIConversationCellData;

NS_ASSUME_NONNULL_BEGIN

static NSString *gGroup_conversationFoldListMockID = @"group_conversationFoldListMockID";

@protocol TUIConversationListDataProviderDelegate <NSObject>
@optional
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation;

- (void)insertConversationsAtIndexPaths:(NSArray *)indexPaths;
- (void)reloadConversationsAtIndexPaths:(NSArray *)indexPaths;
- (void)deleteConversationAtIndexPaths:(NSArray *)indexPaths;
- (void)reloadAllConversations;

- (void)updateMarkUnreadCount:(NSInteger)markUnreadCount markHideUnreadCount:(NSInteger)markHideUnreadCount;
@end

@interface TUIConversationListBaseDataProvider : NSObject
/**
 * 会话拉取过滤器
 * The conversations pull filter
 */
@property(nonatomic, strong) V2TIMConversationListFilter *filter;

/**
 * 分页大小，默认 100 个
 * The count of conversations per page, default is 100
 */
@property(nonatomic, assign) NSUInteger pageSize;

/**
 * 当前分页的索引
 * The index of the current page
 */
@property(nonatomic, assign) NSUInteger pageIndex;

/**
 * 标识是否已经拉到了最后一页
 * An identifier that identifies whether the paging data has been completely pulled
 */
@property(nonatomic, assign, readonly, getter=isLastPage) BOOL lastPage;

@property(nonatomic, weak, nullable) id<TUIConversationListDataProviderDelegate> delegate;

@property(nonatomic, strong, readonly) NSMutableArray<TUIConversationCellData *> *conversationList;

@property(nonatomic, strong) NSMutableDictionary<NSString *, TUIConversationCellData *> *markHideMap;

@property(nonatomic, strong) NSMutableDictionary<NSString *, TUIConversationCellData *> *markUnreadMap;

@property(nonatomic, strong) NSMutableDictionary<NSString *, TUIConversationCellData *> *markFoldMap;

- (void)loadNexPageConversations;
- (void)addConversationList:(NSArray<TUIConversationCellData *> *)conversationList;
- (void)removeConversation:(TUIConversationCellData *)conversation;
- (void)clearHistoryMessage:(TUIConversationCellData *)conversation;
- (void)pinConversation:(TUIConversationCellData *)conversation pin:(BOOL)pin;
- (void)hideConversation:(TUIConversationCellData *)conversation;
- (void)markConversationHide:(TUIConversationCellData *)data;
- (void)markConversationAsRead:(TUIConversationCellData *)conv;
- (void)markConversationAsUnRead:(TUIConversationCellData *)conv;

+ (void)cacheConversationFoldListSettings_HideFoldItem:(BOOL)flag;
+ (void)cacheConversationFoldListSettings_FoldItemIsUnread:(BOOL)flag;
+ (BOOL)getConversationFoldListSettings_HideFoldItem;
+ (BOOL)getConversationFoldListSettings_FoldItemIsUnread;

- (NSString *)getGroupAtTipString:(V2TIMConversation *)conv;
- (NSString *)getDraftContent:(V2TIMConversation *)conv;
- (BOOL)isConversationNotDisturb:(V2TIMConversation *)conversation;

// subclass override
- (Class)getConversationCellClass;
- (NSString *)getDisplayStringFromService:(V2TIMMessage *)msg;
- (NSMutableAttributedString *)getLastDisplayString:(V2TIMConversation *)conversation;
- (TUIConversationCellData *)cellDataForConversation:(V2TIMConversation *)conversation;
- (BOOL)filteConversation:(V2TIMConversation *)conversation;
- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList;
- (void)handleInsertConversationList:(NSArray<TUIConversationCellData *> *)conversationList;
- (void)handleUpdateConversationList:(NSArray<TUIConversationCellData *> *)conversationList
                           positions:(NSMutableDictionary<NSString *, NSNumber *> *)positionMaps;
- (void)handleHideConversation:(TUIConversationCellData *)conversation;
- (void)updateMarkUnreadCount;
@end

NS_ASSUME_NONNULL_END
