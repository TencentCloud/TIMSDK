//
//  UIImage+TUIKIT.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/13.
//

#import "UIImage+TUIKIT.h"
#import "THeader.h"
#import "UIImage+TUIDarkMode.h"

@implementation UIImage (TUIKIT)

+ (UIImage *)tk_imageNamed:(NSString *)name
{
    UIImage *image = [UIImage d_imageWithImageLight:TUIKitResource(name) dark:[NSString stringWithFormat:@"%@_dark",TUIKitResource(name)]];
    return image;
}

+ (UIImage *)tk_imagePath:(NSString *)path
{
    UIImage *image = [UIImage d_imageWithImageLight:path dark:[NSString stringWithFormat:@"%@_dark",path]];
    return image;
}
@end
