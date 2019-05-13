//
//  TConversationView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/11.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TConversationCell.h"

@class TConversationView;
@protocol TConversationViewDelegate <NSObject>
- (void)conversationView:(TConversationView *)conversationView didSelectConversation:(TConversationCellData *)conversation;
@end

@interface TConversationView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<TConversationViewDelegate> delegate;
- (void)setData:(NSMutableArray *)data;
@end
