//
//  TCASKitTheme.h
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/26.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCASKitTheme : NSObject

#pragma mark - 颜色

/// 标题颜色
@property (nonatomic, strong) UIColor *titleColor;
/// 背景色
@property (nonatomic, strong) UIColor *backgroundColor;

/// 通用字体颜色
@property (nonatomic, strong) UIColor *normalFontColor;

/// 滑杆配置
@property (strong, nonatomic) UIColor *sliderMinColor;
@property (strong, nonatomic) UIColor *sliderMaxColor;
@property (strong, nonatomic) UIColor *sliderValueColor;


/// 资源包
@property(nonatomic, strong)NSBundle *resourceBundle;

- (UIFont *)themeFontWithSize:(CGFloat)size;
- (NSString *)localizedString:(NSString *)key __attribute__((annotate("returns_localized_nsstring")));

- (UIImage *)imageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
