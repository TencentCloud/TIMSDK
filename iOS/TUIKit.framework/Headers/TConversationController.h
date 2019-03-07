//
//  ConversationController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/14.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TConversationCell.h"

@class TConversationController;
@protocol TConversationControllerDelegagte <NSObject>
- (void)conversationController:(TConversationController *)conversationController didSelectConversation:(TConversationCellData *)conversation;
- (void)conversationController:(TConversationController *)conversationController DidClickRightBarButton:(UIButton *)rightBarButton;
@end

@interface TConversationController : UIViewController
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<TConversationControllerDelegagte> delegate;
@end
