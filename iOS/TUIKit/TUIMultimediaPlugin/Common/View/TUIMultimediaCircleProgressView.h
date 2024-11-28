// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 环形进度条
 */
@interface TUIMultimediaCircleProgressView : UIView
@property(nonatomic) CGFloat progress;          // 0.0 ~ 1.0
@property(nonatomic) UIColor *progressColor;    // 进度条颜色
@property(nonatomic) UIColor *progressBgColor;  // 进度条背景颜色
@property(nonatomic) CGFloat width;             // 圆环宽度
@property(nonatomic) BOOL clockwise;
@property(nonatomic) CGFloat startAngle;
@property(nonatomic) CAShapeLayerLineCap lineCap;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
