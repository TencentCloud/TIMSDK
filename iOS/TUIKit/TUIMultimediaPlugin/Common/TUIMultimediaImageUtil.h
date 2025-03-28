// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaImageUtil : NSObject
// 对View截图
+ (UIImage *)imageFromView:(UIView *)view;

// 对View截图，带旋转
+ (UIImage *)imageFromView:(UIView *)view withRotate:(CGFloat)rotate;

// 以另一图片为模版，创建一个形状大小相同，但颜色不同的图片，保留透明通道，不保留灰度信息
+ (UIImage *)imageFromImage:(UIImage *)img withTintColor:(UIColor *)tintColor;

+ (UIImage *)resizeImage:(UIImage *)img toSize:(CGSize)size;

+ (UIImage *)rotateImage:(UIImage *)img angle:(float)angle;

+ (UIImage *)imageWithColor:(UIColor *)color;  // size: 1x1
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)createBlueCircleWithWhiteBorder:(CGSize)size withColor:(UIColor*) color;
@end

NS_ASSUME_NONNULL_END
