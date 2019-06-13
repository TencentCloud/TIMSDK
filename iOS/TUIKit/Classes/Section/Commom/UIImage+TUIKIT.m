//
//  UIImage+TUIKIT.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/13.
//

#import "UIImage+TUIKIT.h"
#import "THeader.h"

@implementation UIImage (TUIKIT)

+ (UIImage *)tk_imageNamed:(NSString *)name
{
    return [UIImage imageNamed:TUIKitResource(name)];
}

@end
