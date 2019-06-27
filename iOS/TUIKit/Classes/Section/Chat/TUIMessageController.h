//
//  TUIMessageController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIMessageCell.h"

@class TUIConversationCellData;
@class TUIMessageController;
@protocol TMessageControllerDelegate <NSObject>
- (void)didTapInMessageController:(TUIMessageController *)controller;
- (void)didHideMenuInMessageController:(TUIMessageController *)controller;
- (BOOL)messageController:(TUIMessageController *)controller willShowMenuInCell:(UIView *)view;

- (TUIMessageCellData *)messageController:(TUIMessageController *)controller onNewMessage:(TIMMessage *)data;
- (TUIMessageCell *)messageController:(TUIMessageController *)controller onShowMessageData:(TUIMessageCellData *)data;

- (void)messageController:(TUIMessageController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell;


@end

@interface TUIMessageController : UITableViewController
@property (nonatomic, weak) id<TMessageControllerDelegate> delegate;
- (void)sendMessage:(TUIMessageCellData *)msg;
- (void)scrollToBottom:(BOOL)animate;
- (void)setConversation:(TIMConversation *)conversation;
- (void)sendImageMessage:(UIImage *)image;
- (void)sendVideoMessage:(NSURL *)url;
- (void)sendFileMessage:(NSURL *)url;
@end
