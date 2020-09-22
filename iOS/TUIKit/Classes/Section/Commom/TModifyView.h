//
//  TModifyView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TModifyView;
@protocol TModifyViewDelegate <NSObject>
- (void)modifyView:(TModifyView *)modifyView didModiyContent:(NSString *)content;
@end

@interface TModifyViewData : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@end

@interface TModifyView : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UITextView *content;
@property (nonatomic, strong) UIButton *cancel;
@property (nonatomic, strong) UIButton *confirm;
@property (nonatomic, strong) UIView *hLine;
@property (nonatomic, strong) UIView *vLine;
@property (nonatomic, weak) id<TModifyViewDelegate> delegate;
- (void)setData:(TModifyViewData *)data;
- (void)showInWindow:(UIWindow *)window;
@end
