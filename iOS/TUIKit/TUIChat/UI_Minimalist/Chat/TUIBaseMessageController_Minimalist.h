
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  This file declares the controller class used to implement the messaging logic
 *  The message controller is responsible for uniformly displaying the messages you send/receive, while providing response callbacks when you interact with
 * those messages (tap/long-press, etc.). The message controller is also responsible for unified data processing of the messages you send into a data format
 * that can be sent through the IM SDK and sent. That is to say, when you use this controller, you can save a lot of data processing work, so that you can
 * access the IM SDK more quickly and conveniently.
 */

#import <TIMCommon/TUIMessageCell.h>
#import <UIKit/UIKit.h>

#import "TUIBaseMessageControllerDelegate_Minimalist.h"
#import "TUIChatConversationModel.h"
#import "TUIChatDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIConversationCellData_Minimalist;
@class TUIBaseMessageController_Minimalist;
@class TUIReplyMessageCell_Minimalist;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIBaseMessageController_Minimalist
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【Module name】TUIBaseMessageController_Minimalist
 * 【Function description】The message controller is responsible for implementing a series of business logic such as receiving, sending, and displaying
 * messages.
 *  - This class provides callback interfaces for interactive operations such as receiving/displaying new messages, showing/hiding menus, and clicking on
 * message avatars.
 *  - At the same time, this class provides the sending function of image, video, and file information, and directly integrates and calls the IM SDK to realize
 * the sending function.
 *
 */
@interface TUIBaseMessageController_Minimalist : UITableViewController

+ (void)asyncGetDisplayString:(NSArray<V2TIMMessage *> *)messageList callback:(void(^)(NSDictionary<NSString *, NSString *> *))callback;
+ (nullable NSString *)getDisplayString:(V2TIMMessage *)message;

@property(nonatomic, copy) void (^groupRoleChanged)(V2TIMGroupMemberRole role);

@property(nonatomic, copy) void (^pinGroupMessageChanged)(NSArray *groupPinList);

@property(nonatomic, copy) void (^steamCellFinishedBlock)(BOOL finished, TUIMessageCellData *cellData);

@property(nonatomic, weak) id<TUIBaseMessageControllerDelegate_Minimalist> delegate;

@property(nonatomic, assign) BOOL isInVC;

/**
 * Whether a read receipt is required to send a message, the default is NO
 */
@property(nonatomic) BOOL isMsgNeedReadReceipt;

- (void)sendMessage:(V2TIMMessage *)msg;

- (void)sendMessage:(V2TIMMessage *)msg placeHolderCellData:(TUIMessageCellData *)placeHolderCellData;

- (void)clearUImsg;

- (void)sendPlaceHolderUIMessage:(TUIMessageCellData *)cellData;

// AI typing message management
- (void)createAITypingMessage;
- (void)restoreAITypingMessageIfNeeded;

- (void)scrollToBottom:(BOOL)animate;

- (void)setConversation:(TUIChatConversationModel *)conversationData;

/**
 * After enabling multi-selection mode, get the currently selected result
 * Returns an empty array if multiple selection mode is off
 */
- (NSArray<TUIMessageCellData *> *)multiSelectedResult:(TUIMultiResultOption)option;
- (void)enableMultiSelectedMode:(BOOL)enable;

- (void)deleteMessages:(NSArray<TUIMessageCellData *> *)uiMsgs;
- (void)removeUIMsgList:(NSArray<TUIMessageCellData *> *)uiMsgs;

/**
 * Conversation read report
 *
 */
- (void)readReport;

/**
 * Subclass implements click-to-reply messages
 */
- (void)showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell;
- (void)willShowMediaMessage:(TUIMessageCell *)cell;
- (void)didCloseMediaMessage:(TUIMessageCell *)cell;

/**
 * Subclass implements click-to-delete message
 */
- (void)onDelete:(TUIMessageCell *)cell;

// Reload the specific cell UI.
- (void)reloadCellOfMessage:(NSString *)messageID;
- (void)reloadAndScrollToBottomOfMessage:(NSString *)messageID;
- (void)scrollCellToBottomOfMessage:(NSString *)messageID;

- (void)loadGroupInfo;
- (BOOL)isCurrentUserRoleSuperAdminInGroup;
- (BOOL)isCurrentMessagePin:(NSString *)msgID;
- (void)unPinGroupMessage:(V2TIMMessage *)innerMessage;

- (CGFloat)getHeightFromMessageCellData:(TUIMessageCellData *)cellData;
@end

NS_ASSUME_NONNULL_END
