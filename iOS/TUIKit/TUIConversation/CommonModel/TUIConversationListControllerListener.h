//
//  TUIConversationListControllerListener.h
//  Masonry
//
//  Created by wyl on 2022/10/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUISearchType) { TUISearchTypeContact = 0, TUISearchTypeGroup = 1, TUISearchTypeChatHistory = 2 };

@protocol TUIConversationListControllerListener <NSObject>
@optional

/**
 *  In the conversation list, the callback to get the session display information.
 */
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation;

/**
 *  The callback for clicking the conversation in the conversation list
 *  You can use this callback to respond to the user's click operation and jump to the chat interface corresponding to the session.
 */
- (void)conversationListController:(UIViewController *)conversationController didSelectConversation:(TUIConversationCellData *)conversation;

/**
 *  The callback to clear all conversation unread count.
 */
- (void)onClearAllConversationUnreadCount;

/**
 *  The callback to close conversation multiple choose board.
 */
- (void)onCloseConversationMultiChooseBoard;
@end
NS_ASSUME_NONNULL_END
