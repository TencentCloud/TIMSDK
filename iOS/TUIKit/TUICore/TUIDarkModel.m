//
//  TUIDarkModel.m
//  TUICore
//
//  Created by xiangzhang on 2021/9/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIDarkModel.h"
#import <objc/message.h>
#import "TUIDefine.h"

@implementation UIColor (TUIDarkModel)

+ (UIColor *)d_colorWithColorLight:(UIColor *)light dark:(UIColor *)dark {
    if (@available(iOS 13.0, *)) {
        return [self colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
          switch (traitCollection.userInterfaceStyle) {
              case UIUserInterfaceStyleDark:
                  return dark;
              case UIUserInterfaceStyleLight:
              case UIUserInterfaceStyleUnspecified:
              default:
                  return light;
          }
        }];
    } else {
        return light;
    }
}

+ (UIColor *)d_systemBlackColor {
    if (@available(iOS 13.0, *)) {
        return [self systemBackgroundColor];
    } else {
        return [UIColor whiteColor];
    }
}

+ (UIColor *)d_systemGrayColor {
    if (@available(iOS 13.0, *)) {
        return [self systemGrayColor];
    } else {
        return [UIColor grayColor];
    }
}

+ (UIColor *)d_systemRedColor {
    if (@available(iOS 13.0, *)) {
        return [self systemRedColor];
    } else {
        return [UIColor redColor];
    }
}

+ (UIColor *)d_systemBlueColor {
    if (@available(iOS 13.0, *)) {
        return [self systemBlueColor];
    } else {
        return [UIColor blueColor];
    }
}

@end

@implementation UIImage (TUIDarkModel)

+ (UIImage *)d_imagePath:(NSString *)path {
    UIImage *image = [UIImage d_imageWithImageLight:path dark:[NSString stringWithFormat:@"%@_dark", path]];
    return image;
}

+ (UIImage *)d_imageNamed:(NSString *)imageName bundle:(NSString *)bundleName;
{
    NSString *path = nil;
    if ([bundleName isEqualToString:TUIDemoBundle]) {
        path = TUIDemoImagePath(imageName);
    } else if ([bundleName isEqualToString:TUICoreBundle]) {
        path = TUICoreImagePath(imageName);
    } else if ([bundleName isEqualToString:TUIChatBundle]) {
        path = TUIChatImagePath(imageName);
    } else if ([bundleName isEqualToString:TUIChatFaceBundle]) {
        path = TUIChatFaceImagePath(imageName);
    } else if ([bundleName isEqualToString:TUIConversationBundle]) {
        path = TUIConversationImagePath(imageName);
    } else if ([bundleName isEqualToString:TUIContactBundle]) {
        path = TUIContactImagePath(imageName);
    } else if ([bundleName isEqualToString:TUISearchBundle]) {
        path = TUISearchImagePath(imageName);
    } else if ([bundleName isEqualToString:TUIGroupBundle]) {
        path = TUIGroupImagePath(imageName);
    }
    if (path) {
        return [UIImage d_imageWithImageLight:path dark:[NSString stringWithFormat:@"%@_dark", path]];
    }
    return nil;
}

+ (void)d_fixResizableImage {
    if (@available(iOS 13.0, *)) {
        Class klass = UIImage.class;
        SEL selector = @selector(resizableImageWithCapInsets:resizingMode:);
        Method method = class_getInstanceMethod(klass, selector);
        if (method == NULL) {
            return;
        }

        IMP originalImp = class_getMethodImplementation(klass, selector);
        if (!originalImp) {
            return;
        }

        IMP dynamicColorCompatibleImp = imp_implementationWithBlock(^UIImage *(UIImage *_self, UIEdgeInsets insets, UIImageResizingMode resizingMode) {
          UITraitCollection *lightTrait = [self lightTrait];
          UITraitCollection *darkTrait = [self darkTrait];

          UIImage *resizable = ((UIImage * (*)(UIImage *, SEL, UIEdgeInsets, UIImageResizingMode)) originalImp)(_self, selector, insets, resizingMode);
          UIImage *resizableInLight = [_self.imageAsset imageWithTraitCollection:lightTrait];
          UIImage *resizableInDark = [_self.imageAsset imageWithTraitCollection:darkTrait];

          if (resizableInLight) {
              [resizable.imageAsset registerImage:((UIImage * (*)(UIImage *, SEL, UIEdgeInsets, UIImageResizingMode)) originalImp)(resizableInLight, selector,
                                                                                                                                   insets, resizingMode)
                              withTraitCollection:lightTrait];
          }
          if (resizableInDark) {
              [resizable.imageAsset registerImage:((UIImage * (*)(UIImage *, SEL, UIEdgeInsets, UIImageResizingMode)) originalImp)(resizableInDark, selector,
                                                                                                                                   insets, resizingMode)
                              withTraitCollection:darkTrait];
          }
          return resizable;
        });

        class_replaceMethod(klass, selector, dynamicColorCompatibleImp, method_getTypeEncoding(method));
    }
}

+ (UITraitCollection *)lightTrait API_AVAILABLE(ios(13.0)) {
    static UITraitCollection *trait = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      trait = [UITraitCollection traitCollectionWithTraitsFromCollections:@[
          [UITraitCollection traitCollectionWithDisplayScale:UIScreen.mainScreen.scale],
          [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]
      ]];
    });

    return trait;
}

+ (UITraitCollection *)darkTrait API_AVAILABLE(ios(13.0)) {
    static UITraitCollection *trait = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      trait = [UITraitCollection traitCollectionWithTraitsFromCollections:@[
          [UITraitCollection traitCollectionWithDisplayScale:UIScreen.mainScreen.scale],
          [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]
      ]];
    });

    return trait;
}

+ (UIImage *)d_imageWithImageLight:(NSString *)lightImagePath dark:(NSString *)darkImagePath {
    UIImage *lightImage = [UIImage imageNamed:lightImagePath];
    if (!lightImage) {
        return nil;
    }
    if (@available(iOS 13.0, *)) {
        UIImage *darkImage = [UIImage imageNamed:darkImagePath];
        UITraitCollection *const scaleTraitCollection = [UITraitCollection currentTraitCollection];
        UITraitCollection *const darkUnscaledTraitCollection = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark];
        UITraitCollection *const darkScaledTraitCollection =
            [UITraitCollection traitCollectionWithTraitsFromCollections:@[ scaleTraitCollection, darkUnscaledTraitCollection ]];
        UIImage *image = [lightImage
            imageWithConfiguration:[lightImage.configuration
                                       configurationWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]]];
        darkImage = [darkImage
            imageWithConfiguration:[darkImage.configuration
                                       configurationWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]]];
        [image.imageAsset registerImage:darkImage withTraitCollection:darkScaledTraitCollection];
        return image;
    } else {
        return lightImage;
    }
    return nil;
}

+ (UIImage *)d_imageWithImageLightImg:(UIImage *)lightImage dark:(UIImage *)darkImage {
    if (!lightImage) {
        return nil;
    }
    if (@available(iOS 13.0, *)) {
        UITraitCollection *const scaleTraitCollection = [UITraitCollection currentTraitCollection];
        UITraitCollection *const darkUnscaledTraitCollection = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark];
        UITraitCollection *const darkScaledTraitCollection =
            [UITraitCollection traitCollectionWithTraitsFromCollections:@[ scaleTraitCollection, darkUnscaledTraitCollection ]];
        UIImage *image = [lightImage
            imageWithConfiguration:[lightImage.configuration
                                       configurationWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]]];
        darkImage = [darkImage
            imageWithConfiguration:[darkImage.configuration
                                       configurationWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]]];
        [image.imageAsset registerImage:darkImage withTraitCollection:darkScaledTraitCollection];
        return image;
    } else {
        return lightImage;
    }
    return nil;
}

@end
