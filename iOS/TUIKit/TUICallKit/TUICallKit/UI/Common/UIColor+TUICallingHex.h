//
//  UIColor+TUICallingHex.h
//  TUICalling
//
//  Created by noah on 2022/5/31.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TUICallingHex)

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

+ (UIColor *)t_colorWithHexString:(NSString *)color;

+ (UIColor *)t_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

+ (UIColor *)t_colorWithAlphaHexString:(NSString *)color;

@end

NS_ASSUME_NONNULL_END
