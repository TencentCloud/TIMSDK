
#import "UIColor+TUIDarkMode.h"

@implementation UIColor (TUIDarkMode)

+ (UIColor *)d_colorWithColorLight:(UIColor *)light dark:(UIColor *)dark {
    if (@available(iOS 13.0, *)) {
        return [self colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
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
