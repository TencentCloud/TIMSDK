//
//  UIImage+TUIKIT.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TUIKIT)

+ (UIImage *)tk_imageNamed:(NSString *)name;

+ (UIImage *)tk_imagePath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
