//
//  TMessageController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMessageCell.h"
#import "TConversationCell.h"

@class TMessageController;
@protocol TMessageControllerDelegate <NSObject>
- (void)didTapInMessageController:(TMessageController *)controller;
- (void)didHideMenuInMessageController:(TMessageController *)controller;
- (BOOL)messageController:(TMessageController *)controller willShowMenuInView:(UIView *)view;
- (void)messageController:(TMessageController *)controller didSelectMessages:(NSMutableArray *)msgs atIndex:(NSInteger)index;
@end

@interface TMessageController : UITableViewController
@property (nonatomic, weak) id<TMessageControllerDelegate> delegate;
- (void)sendMessage:(TMessageCellData *)msg;
- (void)scrollToBottom:(BOOL)animate;
- (void)setConversation:(TConversationCellData *)conversation;
- (void)sendImageMessage:(UIImage *)image;
- (void)sendVideoMessage:(NSURL *)url;
- (void)sendFileMessage:(NSURL *)url;
@end
