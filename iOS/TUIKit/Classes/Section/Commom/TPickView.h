//
//  TPickView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPickView;
@protocol TPickViewDelegate <NSObject>
- (void)pickView:(TPickView *)pickView didSelectRowAtIndex:(NSInteger)index;
@end

@interface TPickView : UIView
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, weak) id<TPickViewDelegate> delegate;
- (void)setData:(NSMutableArray *)data;
- (void)showInWindow:(UIWindow *)window;
@end
