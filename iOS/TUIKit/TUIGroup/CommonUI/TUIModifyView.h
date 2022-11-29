//
//  TModifyView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TUIModifyView;
@protocol TModifyViewDelegate <NSObject>
- (void)modifyView:(TUIModifyView *)modifyView didModiyContent:(NSString *)content;
@end

@interface TModifyViewData : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) BOOL enableNull;
@end

@interface TUIModifyView : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UITextField *content;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *confirm;
@property (nonatomic, strong) UIView *hLine;
@property (nonatomic, weak) id<TModifyViewDelegate> delegate;
- (void)setData:(TModifyViewData *)data;
- (void)showInWindow:(UIWindow *)window;
@end
