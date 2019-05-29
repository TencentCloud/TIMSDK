//
//  TAlertView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAlertView;
@protocol TAlertViewDelegate <NSObject>
- (void)didConfirmInAlertView:(TAlertView *)alertView;
- (void)didCancelInAlertView:(TAlertView *)alertView;
@end

@interface TAlertView : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancel;
@property (nonatomic, strong) UIButton *confirm;
@property (nonatomic, strong) UIView *hLine;
@property (nonatomic, strong) UIView *vLine;
@property (nonatomic, weak) id<TAlertViewDelegate> delegate;
- (id)initWithTitle:(NSString *)title;
- (void)setTitle:(NSString *)title;
- (void)showInWindow:(UIWindow *)window;
@end
