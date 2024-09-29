//
//  TUIConversationConfig.h
//  TUIConversation
//
//  Created by Tencent on 2024/9/6.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIConversationCellData;

typedef NS_OPTIONS(NSInteger, TUIConversationItemInMoreMenu) {
    TUIConversationItemInMoreMenu_None = 0,
    TUIConversationItemInMoreMenu_Delete = 1 << 0,
    TUIConversationItemInMoreMenu_MarkRead = 1 << 1,
    TUIConversationItemInMoreMenu_Hide = 1 << 2,
    TUIConversationItemInMoreMenu_Pin = 1 << 1,
    TUIConversationItemInMoreMenu_Clear = 1 << 2,
};
@protocol TUIConversationConfigDataSource <NSObject>
@optional
/**
 * Implement this method to hide items in more menu.
 */
- (TUIConversationItemInMoreMenu)conversationShouldHideItemsInMoreMenu:(TUIConversationCellData *)data;
/**
 * Implement this method to add new items.
 */
- (NSArray *)conversationShouldAddNewItemsToMoreMenu:(TUIConversationCellData *)data;
@end


@interface TUIConversationConfig : NSObject

+ (TUIConversationConfig *)sharedConfig;

/**
 *  DataSource of more menu.
 */
@property (nonatomic, weak) id<TUIConversationConfigDataSource> moreMenuDataSource;
/**
 *  Background color of conversation list.
 */
@property (nonatomic, strong) UIColor *listBackgroundColor;
/**
 *  Background color of cell in conversation list.
 *  This configuration takes effect in all cells.
 */
@property (nonatomic, strong) UIColor *cellBackgroundColor;
/**
 *  Background color of pinned cell in conversation list.
 *  This configuration takes effect in all pinned cells.
 */
@property (nonatomic, strong) UIColor *pinnedCellBackgroundColor;
/**
 *  Font of title label of cell in conversation list.
 *  This configuration takes effect in all cells.
 */
@property (nonatomic, strong) UIFont *cellTitleLabelFont;
/**
 *  Font of subtitle label of cell in conversation list.
 *  This configuration takes effect in all cells.
 */
@property (nonatomic, strong) UIFont *cellSubtitleLabelFont;
/**
 *  Font of time label of cell in conversation list.
 *  This configuration takes effect in all cells.
 */
@property (nonatomic, strong) UIFont *cellTimeLabelFont;
/**
 *  Corner radius of the avatar.
 *  This configuration takes effect in all avatars.
 */
@property(nonatomic, assign) CGFloat avatarCornerRadius;
/**
 *  Display user's online status icon in conversation and contact list.
 *  The default value is NO.
 */
@property(nonatomic, assign) BOOL showUserOnlineStatusIcon;
/**
 *  Display unread count icon in each conversation cell.
 *  The default value is YES.
 */
@property(nonatomic, assign) BOOL showCellUnreadCount;

@end

NS_ASSUME_NONNULL_END
