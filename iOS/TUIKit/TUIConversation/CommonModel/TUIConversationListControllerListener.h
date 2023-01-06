//
//  TUIConversationListControllerListener.h
//  Masonry
//
//  Created by wyl on 2022/10/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUISearchType) {
    TUISearchTypeContact     = 0,
    TUISearchTypeGroup       = 1,
    TUISearchTypeChatHistory = 2
};


@protocol TUIConversationListControllerListener <NSObject>
@optional

/**
 *  在会话列表中，获取会话展示信息时候回调。
 *  In the conversation list, the callback to get the session display information.
 */
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation;

/**
 *  在会话列表中，点击了具体某一会话后的回调。
 *  您可以通过该回调响应用户的点击操作，跳转到该会话对应的聊天界面。
 *
 *  @param conversationController 委托者，当前所在的消息列表。
 *  @param conversation 被选中的会话单元
 *
 *  The callback for clicking the conversation in the conversation list
 *  You can use this callback to respond to the user's click operation and jump to the chat interface corresponding to the session.
 */
- (void)conversationListController:(UIViewController *)conversationController didSelectConversation:(TUIConversationCellData *)conversation;

/**
 *  清空所有会话未读数回调。
 *  The callback to clear all conversation unread count.
 */
- (void)onClearAllConversationUnreadCount;

/**
 *  会话列表多选面板关闭。
 *  The callback to close conversation multiple choose board.
 */
- (void)onCloseConversationMultiChooseBoard;
@end
NS_ASSUME_NONNULL_END
