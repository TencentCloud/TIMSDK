//
//  UIColor+TUICallingHex.m
//  TUICalling
//
//  Created by noah on 2022/5/31.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "UIColor+TUICallingHex.h"

@implementation UIColor (TUICallingHex)

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
    UIImage *colorImage = nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return colorImage;
}

+ (UIColor *)t_colorWithHexString:(NSString *)color {
    return [[self class] t_colorWithHexString:color alpha:1];
}

+ (UIColor *)t_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha {
    NSString *colorString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([colorString length] < 6) {
        return [UIColor clearColor];
    }
    
    if ([colorString hasPrefix:@"0X"])
        colorString = [colorString substringFromIndex:2];
    
    if ([colorString hasPrefix:@"#"])
        colorString = [colorString substringFromIndex:1];
    
    if ([colorString length] < 6)
        return [UIColor clearColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [colorString substringWithRange:range];
    range.location = 2;
    NSString *gString = [colorString substringWithRange:range];
    range.location = 4;
    NSString *bString = [colorString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}

+ (UIColor *)t_colorWithAlphaHexString:(NSString *)color {
    NSString *colorString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([colorString length] < 6) {
        return [UIColor clearColor];
    }
    
    if ([colorString hasPrefix:@"0X"] || [colorString hasPrefix:@"0x"])
        colorString = [colorString substringFromIndex:2];
    
    if ([colorString hasPrefix:@"#"])
        colorString = [colorString substringFromIndex:1];
    
    if ([colorString length] < 6)
        return [UIColor clearColor];
    
    if (colorString.length == 6) {
        return [self t_colorWithHexString:colorString alpha: 1.0];
    } else if (colorString.length == 8){
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString *aString = [colorString substringWithRange:range];
        
        range.location = 2;
        NSString *rString = [colorString substringWithRange:range];
        
        range.location = 4;
        NSString *gString = [colorString substringWithRange:range];
        
        range.location = 6;
        NSString *bString = [colorString substringWithRange:range];
        
        unsigned int a, r, g, b;
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:((float) a / 255.0f)];
    } else {
        return [UIColor clearColor];
    }
}

@end
