//
//  TCASKitTheme.m
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/26.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TCASKitTheme.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
 blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]

@interface TCASKitTheme ()


@end

@implementation TCASKitTheme

#pragma mark - 初始化方法
- (instancetype)init {
    self = [super init];
    if (self) {
        // 颜色初始化
        _titleColor = UIColorFromRGB(0xEBF4FF);
        _backgroundColor = UIColorFromRGB(0x13233F);
        _normalFontColor = UIColorFromRGB(0xEBF4FF);
        _sliderMinColor = UIColorFromRGB(0x0062E3);
        _sliderMaxColor = [UIColorFromRGB(0xEBF4FF) colorWithAlphaComponent:0.14];
        _sliderValueColor = UIColorFromRGB(0xEBF4FF);
        
    }
    return self;
}

#pragma mark - 属性懒加载
/// 初始化资源包
- (NSBundle *)resourceBundle {
    if (!_resourceBundle) {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"AudioEffectSettingKitResources" ofType:@"bundle"];
        NSBundle* bundle = [NSBundle bundleWithPath:resourcePath];
        _resourceBundle = bundle ?:[NSBundle mainBundle];
    }
    return _resourceBundle;
}

- (NSString *)localizedString:(NSString *)key {
    return [self.resourceBundle localizedStringForKey:key value:@"" table:@"AudioSettingPanelLocalizable"];
}

- (UIFont *)themeFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Regular" size:size];
}

- (UIImage *)imageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name
                                inBundle:self.resourceBundle
    compatibleWithTraitCollection:nil];
    return image;
}


@end
