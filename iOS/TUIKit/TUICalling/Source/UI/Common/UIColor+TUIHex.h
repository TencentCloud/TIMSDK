//
//  UIColor+TUIHex.h
//  TUICalling
//
//  Created by noah on 2021/8/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TUIHex)

/// UIColor转换成UIImage
/// @param color UIColor颜色
/// @param size image的大小
/// @return UIImage类型
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

/// 色值字符串转换成UIColor
/// @param color 16进制字符串
/// @return UIColor类型
+ (UIColor *)t_colorWithHexString:(NSString *)color;

+ (UIColor *)t_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

/// 16进制当中带有透明度的色值字符串转成UIColor
/// @param color 16进制带透明度的字符串
/// @return UIColor类型
+ (UIColor *)t_colorWithAlphaHexString:(NSString *)color;

@end

NS_ASSUME_NONNULL_END
