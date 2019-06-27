//
//  TUIChatController.h
//  UIKit
//
//  Created by annidyfeng on 2019/5/21.
//

#import <UIKit/UIKit.h>
#import "TUIInputController.h"
#import "TUIMessageController.h"
#import "TUIConversationCell.h"

@class TUIChatController;
@protocol TUIChatControllerDelegate <NSObject>

- (void)chatController:(TUIChatController *)chatController onSelectMoreCell:(TUIInputMoreCell *)cell;

- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewMessage:(TIMMessage *)msg;

- (TUIMessageCell *)chatController:(TUIChatController *)controller onShowMessageData:(TUIMessageCellData *)cellData;


@end

@interface TUIChatController : UIViewController

@property TUIMessageController *messageController;
@property TUIInputController *inputController;
@property (weak) id<TUIChatControllerDelegate> delegate;

/**
 * 可以显示在点击输入框“+”按钮之后的更多菜单
 */
@property NSArray<TUIInputMoreCellData *> *moreMenus;


- (instancetype)initWithConversation:(TIMConversation *)conversation;

- (void)sendMessage:(TUIMessageCellData *)message;

- (void)saveDraft;

@end
