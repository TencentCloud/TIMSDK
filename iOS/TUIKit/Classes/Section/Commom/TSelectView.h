//
//  TSelectView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSelectView;
@protocol TSelectViewDelegate <NSObject>
- (void)selectView:(TSelectView *)selectView didSelectRowAtIndex:(NSInteger)index;
@end

@interface TSelectView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<TSelectViewDelegate> delegate;
- (void)setData:(NSMutableArray *)data;
- (void)showInWindow:(UIWindow *)window;
@end
