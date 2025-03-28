// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaImageUtil.h"

@implementation TUIMultimediaImageUtil
+ (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)imageFromView:(UIView *)view withRotate:(CGFloat)rotate {
    // view旋转后占用的矩形大小--最终画布大小
    CGSize finalSize = CGSizeMake(CGRectGetWidth(view.frame), CGRectGetHeight(view.frame));
    // view的原始大小
    CGSize originSize = CGSizeMake(CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds));

    UIGraphicsBeginImageContext(finalSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 根据画布大小，先移动到中心点
    CGContextTranslateCTM(ctx, finalSize.width / 2, finalSize.height / 2);
    // 旋转坐标系
    CGContextRotateCTM(ctx, rotate);
    // 根据原始大小确定绘制view的起始位置
    CGContextTranslateCTM(ctx, -originSize.width / 2, -originSize.height / 2);
    [view.layer renderInContext:ctx];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)simpleImageFromImage:(UIImage *)img withTintColor:(UIColor *)tintColor {
    // We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the
    // device’s main screen.
    UIGraphicsBeginImageContextWithOptions(img.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, img.size.width, img.size.height);
    UIRectFill(bounds);

    // Draw the tinted image in context
    [img drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

+ (UIImage *)imageFromImage:(UIImage *)img withTintColor:(UIColor *)tintColor {
    UIImage *imgWithTintColor = [self simpleImageFromImage:img withTintColor:tintColor];
    if (img.imageAsset == nil) {
        return imgWithTintColor;
    }
    UITraitCollection *const scaleTraitCollection = [UITraitCollection currentTraitCollection];
    UITraitCollection *const darkUnscaledTraitCollection = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark];
    UITraitCollection *const darkScaledTraitCollection =
        [UITraitCollection traitCollectionWithTraitsFromCollections:@[ scaleTraitCollection, darkUnscaledTraitCollection ]];

    UIImage *imageDark = [img.imageAsset imageWithTraitCollection:darkScaledTraitCollection];
    if (img != imageDark) {
        [imgWithTintColor.imageAsset registerImage:[self simpleImageFromImage:imageDark withTintColor:tintColor] withTraitCollection:darkScaledTraitCollection];
    }

    return imgWithTintColor;
}

+ (UIImage *)resizeImage:(UIImage *)img toSize:(CGSize)size {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull rendererContext) {
      [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }];
}

+ (UIImage *)rotateImage:(UIImage *)image angle:(float)angle {
    CGFloat radians = angle * (M_PI / 180.0);
    CGSize size = image.size;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *rotatedImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextRef cgContext = context.CGContext;
        CGContextTranslateCTM(cgContext, size.width / 2, size.height / 2);
        CGContextRotateCTM(cgContext, radians);
        CGContextTranslateCTM(cgContext, -size.width / 2, -size.height / 2);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }];

    return rotatedImage;
}


+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull rendererContext) {
      [color set];
      [rendererContext fillRect:CGRectMake(0, 0, size.width, size.height)];
    }];
}

+ (UIImage *)createBlueCircleWithWhiteBorder : (CGSize)size withColor:(UIColor*) color{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return nil;
    

    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    
    
    CGFloat centerX = size.width / 2;
    CGFloat centerY = size.width / 2;
    CGFloat radius = size.width / 2;

    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 0);
    CGContextAddArc(context, centerX, centerY, radius, 0, 2 * M_PI, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 0);
    CGContextAddArc(context, centerX, centerY, 5, 0, 2 * M_PI, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
