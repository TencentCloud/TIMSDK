// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaEffectItem.h"
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"

#define DEFAULT_FILTER_EFFECT_STRENGTH 4

@implementation TUIMultimediaEffectItem
- (instancetype)initWithName:(NSString *)name iconImage:(UIImage *)iconImage strength:(int)strength {
    self = [super init];
    if (self != nil) {
        _name = name;
        _iconImage = iconImage;
        _strength = strength;
    }
    return self;
}
+ (TUIMultimediaEffectItem *)newWithName:(NSString *)name iconImageName:(NSString *)iconImageName tag:(NSInteger)tag {
    TUIMultimediaEffectItem *item = [[TUIMultimediaEffectItem alloc] initWithName:name iconImage:[TUIMultimediaCommon bundleImageByName:iconImageName] strength:0];
    item.tag = tag;
    return item;
}
+ (TUIMultimediaEffectItem *)newWithFilterName:(NSString *)filterName {
    NSString *nameKey = [NSString stringWithFormat:@"filter_%@", filterName];
    NSString *name = [TUIMultimediaCommon localizedStringForKey:nameKey];

    NSString *iconImageName = [NSString stringWithFormat:@"filter/icon/%@", filterName];
    NSString *filterMapImageName = [NSString stringWithFormat:@"filter/map/%@", filterName];
    TUIMultimediaEffectItem *item = [[TUIMultimediaEffectItem alloc] initWithName:name iconImage:[TUIMultimediaCommon bundleImageByName:iconImageName] strength:DEFAULT_FILTER_EFFECT_STRENGTH];
    item.filterMapImage = [TUIMultimediaCommon bundleImageByName:filterMapImageName];
    return item;
}
+ (NSArray<NSString *> *)filterNameList {
    return @[
        @"none",
        @"bailan",
        @"biaozhun",
        @"chaotuo",
        @"chunzhen",
        @"fennen",
        @"huaijiu",
        @"landiao",
        @"langman",
        @"qingliang",
        @"qingxin",
        @"rixi",
        @"weimei",
        @"xiangfen",
        @"yinghong",
        @"yuanqi",
        @"yunshang",
    ];
}
+ (NSArray<TUIMultimediaEffectItem *> *)defaultBeautifyEffects {
    return @[
        [TUIMultimediaEffectItem newWithName:[TUIMultimediaCommon localizedStringForKey:@"beautify_none"] iconImageName:@"beauty/none" tag:TUIMultimediaEffectItemTagNone],
        [TUIMultimediaEffectItem newWithName:[TUIMultimediaCommon localizedStringForKey:@"beautify_smooth"] iconImageName:@"beauty/smooth" tag:TUIMultimediaEffectItemTagSmooth],
        [TUIMultimediaEffectItem newWithName:[TUIMultimediaCommon localizedStringForKey:@"beautify_whitness"]
                        iconImageName:@"beauty/whitness"
                                  tag:TUIMultimediaEffectItemTagWhiteness],
        [TUIMultimediaEffectItem newWithName:[TUIMultimediaCommon localizedStringForKey:@"beautify_ruddy"] iconImageName:@"beauty/ruddy" tag:TUIMultimediaEffectItemTagRuddy],
    ];
}
+ (NSArray<TUIMultimediaEffectItem *> *)defaultFilterEffects {
    NSArray<TUIMultimediaEffectItem *> *list = [[TUIMultimediaEffectItem filterNameList] tui_multimedia_map:^(NSString *name) {
      return [TUIMultimediaEffectItem newWithFilterName:name];
    }];
    list.firstObject.tag = TUIMultimediaEffectItemTagNone;
    return list;
}

@end
