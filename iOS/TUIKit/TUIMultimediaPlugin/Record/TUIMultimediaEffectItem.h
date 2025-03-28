// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static const int TUIMultimediaEffectItemTagNone = -1;
static const int TUIMultimediaEffectItemTagSmooth = 1;
static const int TUIMultimediaEffectItemTagNatural = 2;
static const int TUIMultimediaEffectItemTagPitu = 3;
static const int TUIMultimediaEffectItemTagWhiteness = 4;
static const int TUIMultimediaEffectItemTagRuddy = 5;

/**
 美颜或滤镜效果
 */
@interface TUIMultimediaEffectItem : NSObject
@property(nonatomic) NSString *name;
@property(nonatomic) UIImage *iconImage;
@property(nullable, nonatomic) UIImage *filterMapImage;
@property(nonatomic) int strength;
@property(nonatomic) NSInteger tag;
- (instancetype)initWithName:(NSString *)name iconImage:(UIImage *)iconImage strength:(int)strength;

+ (NSArray<TUIMultimediaEffectItem *> *)defaultBeautifyEffects;
+ (NSArray<TUIMultimediaEffectItem *> *)defaultFilterEffects;
@end

NS_ASSUME_NONNULL_END
