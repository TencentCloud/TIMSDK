//
//  UIColor+TUIHexColor.h
//  TUICore
//
//  Created by gg on 2021/10/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TUIHexColor)

+ (UIColor *)colorWithHex:(NSString *)hex;

+ (UIColor *)colorWithHex:(NSString *)hex alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
