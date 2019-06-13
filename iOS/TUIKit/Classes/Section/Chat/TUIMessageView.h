//
//  TUIMessageView.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIMessageCell.h"


@interface TUIMessageView : UIView
@property (nonatomic, strong) UITableView *tableView;
- (void)sendMessage:(TUIMessageCellData *)msg;
- (void)scrollToBottom:(BOOL)animate;
@end
