//
//  TUISecurityStrikeView.h
//  TIMCommon
//
//  Created by wyl on 2023/10/11.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#define  kTUISecurityStrikeViewTopLineMargin 14.5
#define  kTUISecurityStrikeViewTopLineToBottom 28
@interface TUISecurityStrikeView : UIView
@property(nonatomic, strong) UIView * topLine;
@property(nonatomic, strong) UILabel * textLabel;

+ (UIImage *)changeImageColorWith:(UIColor *)color image:(UIImage *)image alpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
