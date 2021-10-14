//
//  TPopView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPopView;
@protocol TPopViewDelegate <NSObject>
- (void)popView:(TPopView *)popView didSelectRowAtIndex:(NSInteger)index;
@end

@interface TPopView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGPoint arrowPoint;
@property (nonatomic, weak) id<TPopViewDelegate> delegate;
- (void)setData:(NSMutableArray *)data;
- (void)showInWindow:(UIWindow *)window;
@end
