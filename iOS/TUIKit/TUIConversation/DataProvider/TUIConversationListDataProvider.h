//
//  TUIConversationListDataProvider.h
//  TUIConversation
//
//  Created by harvy on 2022/7/14.
//

#import <Foundation/Foundation.h>

@class V2TIMConversation;
@class TUIConversationCellData;

NS_ASSUME_NONNULL_BEGIN

@protocol TUIConversationListDataProviderDelegate <NSObject>

- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation;

- (void)insertConversationsAtIndexPaths:(NSArray *)indexPaths;
- (void)reloadConversationsAtIndexPaths:(NSArray *)indexPaths;
- (void)deleteConversationAtIndexPaths:(NSArray *)indexPaths;
- (void)reloadAllConversations;

@end

@interface TUIConversationListDataProvider : NSObject

/**
 * 分页大小，默认 100 个
 * The count of conversations per page, default is 100
 */
@property (nonatomic, assign) NSUInteger pageSize;

/**
 * 当前分页的索引
 * The index of the current page
 */
@property (nonatomic, assign) NSUInteger pageIndex;

/**
 * 标识是否已经拉到了最后一页
 * An identifier that identifies whether the paging data has been completely pulled
 */
@property (nonatomic, assign, readonly, getter=isLastPage) BOOL lastPage;

@property (nonatomic, weak, nullable) id<TUIConversationListDataProviderDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableArray<TUIConversationCellData *> *conversationList;

@property (nonatomic, strong) NSMutableDictionary<NSString *,TUIConversationCellData *> *markHideMap;

@property (nonatomic, strong) NSMutableDictionary<NSString *,TUIConversationCellData *> *markUnreadMap;

@property (nonatomic, strong) NSMutableDictionary<NSString *,TUIConversationCellData *> *markFoldMap;

- (void)loadNexPageConversations;
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

@end

NS_ASSUME_NONNULL_END
