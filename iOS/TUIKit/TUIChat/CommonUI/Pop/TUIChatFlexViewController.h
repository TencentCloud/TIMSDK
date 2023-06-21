//
//  TUIChatFlexViewController.h
//  TUIChat
//
//  Created by wyl on 2022/10/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatFlexViewController : UIViewController

@property(nonatomic, strong) UIView *topGestureView;
@property(nonatomic, strong) UIImageView *topImgView;

@property(nonatomic, strong) UIView *containerView;

- (void)updateSubContainerView;

- (void)setnormalTop;

- (void)setNormalBottom;

@end

NS_ASSUME_NONNULL_END
