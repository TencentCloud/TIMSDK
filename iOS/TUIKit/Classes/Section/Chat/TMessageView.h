//
//  TMessageView.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMessageCell.h"

@class TMessageView;
@protocol TMessageControllerDelegate <NSObject>
- (void)didTapMessageView:(TMessageView *)view;
@end

@interface TMessageView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<TMessageControllerDelegate> delegate;
- (void)sendMessage:(TMessageCellData *)msg;
- (void)scrollToBottom:(BOOL)animate;
@end
