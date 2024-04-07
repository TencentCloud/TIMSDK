
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *
 * Tencent Cloud Communication Service Interface Component TUIKIT - Conversation List Component.
 *
 * This file declares the view component of the conversation list.
 * The conversation list component can display brief information of each conversation in the order of the time when new messages are sent (newer messages are
 * sorted earlier). The conversation information displayed in the conversation list includes:
 * 1. Avatar information (user avatar/group avatar)
 * 2. Conversation title (user nickname/group name)
 * 3. Conversation message overview (display the latest message content)
 * 4. The number of unread messages (if there are unread messages)
 * 5. Conversation time (receive/send time of the latest message)
 * The conversation information displayed in the conversation list is implemented by TUIConversationCell. For details, please refer to
 * TUIConversation\Cell\CellUI\TUIConversationCell.h
 */

#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TUIConversationCell.h"
#import "TUIConversationListControllerListener.h"
#import "TUIConversationListDataProvider_Minimalist.h"
#import "TUIConversationMultiChooseView_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *
 * 【Module name】 message list interface component (TUIConversationListController_Minimalist)
 *
 * 【Function description】 It is responsible for displaying each conversation in the order in which the messages are received, and responding to the user's
 * operation, providing users with multi-session management functions. The conversation information displayed in the conversation list includes:
 *  1. Avatar information (user avatar/group avatar)
 *  2. Conversation title (user nickname/group name)
 *  3. Conversation message overview (display the latest message content)
 *  4. The number of unread messages (if there are unread messages)
 *  5. Conversation time (receive/send time of the latest message)
 */
@interface TUIConversationListController_Minimalist : UIViewController

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) TUIConversationMultiChooseView_Minimalist *multiChooseView;

@property(nonatomic, weak) id<TUIConversationListControllerListener> delegate;

@property(nonatomic, strong) TUIConversationListBaseDataProvider *dataProvider;

@property(nonatomic) BOOL isShowBanner;

@property(nonatomic, copy) void (^dataSourceChanged)(NSInteger count);

- (void)openMultiChooseBoard:(BOOL)open;

- (void)enableMultiSelectedMode:(BOOL)enable;

- (NSArray<TUIConversationCellData *> *)getMultiSelectedResult;

- (void)startConversation:(V2TIMConversationType)type;
@end

NS_ASSUME_NONNULL_END
