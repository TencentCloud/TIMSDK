//
//  TUIDarkModel.h
//  TUICore
//
//  Created by xiangzhang on 2021/9/9.
//

#import <Foundation/Foundation.h>

@import UIKit;

/////////////////////////////////////////////////////////////////////////////////
//
//                            颜色深色适配
//
/////////////////////////////////////////////////////////////////////////////////
@interface UIColor (TUIDarkModel)
/**
 *  设置正常模式和深色模式 Color
 *
 *  @param light 正常模式 Color
 *  @param dark 深色模式 Color
 *  @return 适配深色模式的 Color
 */
+ (UIColor *)d_colorWithColorLight:(UIColor *)light dark:(UIColor *)dark;

/**
 *  系统灰色
 *
 *  @return 适配深色模式的灰色
 */
+ (UIColor *)d_systemGrayColor;

/**
 *  系统红色
 *
 *  @return 适配深色模式的红色
 */
+ (UIColor *)d_systemRedColor;

/**
 *  系统蓝色
 *
 *  @return 适配深色模式的蓝色
 */
+ (UIColor *)d_systemBlueColor;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                            图片深色适配
//
/////////////////////////////////////////////////////////////////////////////////

@interface UIImage (TUIDarkModel)
/**
 *  根据图片路径取 Image
 *
 *  @param path 普通图片路径（不带 @x.png 后缀），深色图片路径必须为 "普通图片路径_dark"
 *  @return 适配深色模式的 Image
 */
+ (UIImage *)d_imagePath:(NSString *)path;

/**
 *  根据图片名字取 Image
 *
 *  @param imageName 普通图片名字，暗黑图片名字必须为 "普通图片名字_dark"
 *  @param bundleName 存放图片的 bundleName
 *  @return 适配深色模式的 Image
 */
+ (UIImage *)d_imageNamed:(NSString *)imageName bundle:(NSString *)bundleName;

/**
 *  根据图片路径取 Image
 *
 *  @param lightImagePath 普通图片路径
 *  @param darkImagePath 暗黑图片路径
 *  @return 适配深色模式的 Image
 */
+ (UIImage *)d_imageWithImageLight:(NSString *)lightImagePath dark:(NSString *)darkImagePath;

/**
 *  修复图片拉伸导致深色模式适配失效的问题
 */
+ (void)d_fixResizableImage;

+ (UIImage *)d_imageWithImageLightImg:(UIImage *)lightImage dark:(UIImage *)darkImage;
@end
