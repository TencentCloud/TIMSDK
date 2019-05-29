//
//  ConversationController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TConversationCell.h"

@class TConversationController;
@protocol TConversationControllerDelegagte <NSObject>
- (void)conversationController:(TConversationController *)conversationController didSelectConversation:(TConversationCellData *)conversation;
@end

typedef NS_OPTIONS(NSUInteger, TConversationFilter) {
    TC2CMessage = 1 << 0,
    TGroupMessage = 1 << 1,
};

@interface TConversationController : UIViewController
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<TConversationControllerDelegagte> delegate;

@property TConversationFilter convFilter;
@end
