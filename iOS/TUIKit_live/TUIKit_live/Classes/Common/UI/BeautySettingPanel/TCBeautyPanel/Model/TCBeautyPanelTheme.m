//
//  TCPanelTheme.m
//  TC
//
//  Created by cui on 2019/12/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TCBeautyPanelTheme.h"
#import <objc/runtime.h>

@interface TCBeautyPanelTheme () {
    @public
    NSMutableDictionary<NSString *, UIImage *> *_imageDict;
    NSMutableDictionary<NSString *, UIImage *> *_filterIconDictionary;
}
@property (strong, nonatomic) NSBundle *resourceBundle;
- (UIImage *)imageForKey:(NSString *)key;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;
@end

static UIImage *getImageByName(TCBeautyPanelTheme *self, SEL selector) {
    NSString *selName = NSStringFromSelector(selector);
    NSString *key = [[[selName substringToIndex:1] lowercaseString] stringByAppendingString:[selName substringFromIndex:1]];
    UIImage *image = [self imageForKey:key];
    if (nil == image) {
        image = [UIImage imageNamed:NSStringFromSelector(selector) inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    }
    if (nil == image) {
        NSLog(@"%@ %@ image not found", NSStringFromClass([self class]), key);
    }
    return image;
}

static void setImageForKey(id self, SEL selector, UIImage *image) {
    NSString *selName = NSStringFromSelector(selector);
    NSString *attrName = [[selName substringFromIndex:3] stringByTrimmingCharactersInSet:
                          [NSCharacterSet characterSetWithCharactersInString:@":"]];
    NSString *key = [[[attrName substringToIndex:1] lowercaseString] stringByAppendingString:[attrName substringFromIndex:1]];
    [self setImage:image forKey:key];
}


@implementation TCBeautyPanelTheme
@synthesize backgroundColor=_backgroundColor;
@synthesize beautyPanelTitleColor=_beautyPanelTitleColor;
@synthesize beautyPanelSelectionColor=_beautyPanelSelectionColor;
@synthesize speedControlSelectedTitleColor=_speedControlSelectedTitleColor;
@synthesize sliderMinColor=_sliderMinColor;
@synthesize sliderMaxColor=_sliderMaxColor;
@synthesize sliderValueColor=_sliderValueColor;
@dynamic beautyPanelEyeScaleIcon;
@dynamic beautyPanelPTuBeautyStyleIcon;
@dynamic beautyPanelRuddyIcon;
@dynamic beautyPanelBgRemovalIcon;
@dynamic beautyPanelWhitnessIcon;
@dynamic beautyPanelFaceSlimIcon;
@dynamic beautyPanelGoodLuckIcon;
@dynamic beautyPanelChinIcon;
@dynamic beautyPanelFaceVIcon;
@dynamic beautyPanelFaceScaleIcon;
@dynamic beautyPanelNoseSlimIcon;
@dynamic beautyPanelToothWhitenIcon;
@dynamic beautyPanelEyeDistanceIcon;
@dynamic beautyPanelForeheadIcon;
@dynamic beautyPanelFaceBeautyIcon;
@dynamic beautyPanelEyeAngleIcon;
@dynamic beautyPanelNoseWingIcon;
@dynamic beautyPanelLipsThicknessIcon;
@dynamic beautyPanelWrinkleRemoveIcon;
@dynamic beautyPanelMouthShapeIcon;
@dynamic beautyPanelPounchRemoveIcon;
@dynamic beautyPanelSmileLinesRemoveIcon;
@dynamic beautyPanelEyeLightenIcon;
@dynamic beautyPanelNosePositionIcon;
@dynamic menuDisableIcon;
@dynamic beautyPanelMenuSelectionBackgroundImage;
@dynamic sliderThumbImage;

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSString *selName = NSStringFromSelector(sel);
    if ([selName hasPrefix:@"set"]) {
        if ([selName hasSuffix:@"Icon:"] || [selName hasSuffix:@"Image:"]) {
            class_addMethod([self class], sel, (IMP)setImageForKey, "@@:@");
            return YES;
        }
    } else if ([selName hasSuffix:@"Icon"] || [selName hasSuffix:@"Image"]) {
        class_addMethod([self class], sel, (IMP)getImageByName, "@@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"UGCKitResources" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:resourcePath];
        if (nil == bundle) {
            bundle = [NSBundle mainBundle];
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:@"TCBeautyPanelResources" ofType:@"bundle"];
        if (!path) {
            path = [bundle pathForResource:@"TCBeautyPanelResources" ofType:@"bundle"];
        }
        NSBundle *panelResBundle = [NSBundle bundleWithPath:path];
        if (panelResBundle) {
            bundle = panelResBundle;
        }
        _imageDict = [NSMutableDictionary dictionary];

        _resourceBundle = bundle ?: [NSBundle mainBundle];

        _beautyPanelTitleColor = [UIColor whiteColor];
        _beautyPanelSelectionColor = [UIColor colorWithRed:0xff/255.0 green:0x58/255.0 blue:0x4c/255.0 alpha:1];
        _backgroundColor = [UIColor blackColor];
        _sliderValueColor = [UIColor colorWithRed:1.0 green:0x58/255.0 blue:0x4c/255.0 alpha:1];
    }
    return self;
}
- (NSURL *)goodLuckVideoFileURL {
    return [_resourceBundle URLForResource:@"goodluck" withExtension:@"mp4"];
}

- (UIImage *)iconForFilter:(nonnull NSString *)filter {
    UIImage *image = _filterIconDictionary[filter];
    if (image) {
        return image;
    }

    if (nil == filter) {
        return [UIImage imageNamed:@"original" inBundle:_resourceBundle compatibleWithTraitCollection:nil];
    } else if ([filter isEqualToString:@"white"]) {
        return [UIImage imageNamed:@"fwhite" inBundle:_resourceBundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageNamed:filter inBundle:_resourceBundle compatibleWithTraitCollection:nil];
    }
}


- (UIImage *)imageNamed:(nonnull NSString *)name {
    return [UIImage imageNamed:name inBundle:_resourceBundle compatibleWithTraitCollection:nil];
}

- (UIImage *)imageForKey:(NSString *)key
{
    return _imageDict[key];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    _imageDict[key] = image;
}

- (NSString *)localizedString:(nonnull NSString *)key {
    static NSDictionary *defaultStringMap = nil;
    NSString *string = [_resourceBundle localizedStringForKey:key value:@"" table:nil];
    if (![string isEqualToString:key]) {
        return string;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStringMap = @{
            @"TC.Common.Clear": @"清除",
            @"TC.BeautySettingPanel.None" : @"无动效",
            @"TC.BeautySettingPanel.GoodLuck" : @"Good Luck",
            @"TC.BeautySettingPanel.Beauty-P" : @"磨皮",
            @"TC.BeautySettingPanel.White" : @"美白",
            @"TC.BeautySettingPanel.Ruddy" : @"红润",
            @"TC.BeautySettingPanel.BigEyes" : @"大眼",
            @"TC.BeautySettingPanel.ThinFace" : @"瘦脸",
            @"TC.BeautySettingPanel.VFace" : @"V脸",
            @"TC.BeautySettingPanel.Chin" : @"下巴",
            @"TC.BeautySettingPanel.ShortFace" : @"短脸",
            @"TC.BeautySettingPanel.ThinNose" : @"瘦鼻",
            @"TC.BeautySettingPanel.EyeLighten" : @"亮眼",
            @"TC.BeautySettingPanel.ToothWhiten" : @"白牙",
            @"TC.BeautySettingPanel.WrinkleRemove" : @"祛皱",
            @"TC.BeautySettingPanel.PounchRemove" : @"祛眼袋",
            @"TC.BeautySettingPanel.SmileLinesRemove" : @"祛法令纹",
            @"TC.BeautySettingPanel.Forehead" : @"发际线",
            @"TC.BeautySettingPanel.EyeDistance" : @"眼距",
            @"TC.BeautySettingPanel.EyeAngle" : @"眼角",
            @"TC.BeautySettingPanel.MouthShape" : @"嘴型",
            @"TC.BeautySettingPanel.NoseWing" : @"鼻翼",
            @"TC.BeautySettingPanel.NosePosition" : @"鼻子位置",
            @"TC.BeautySettingPanel.LipsThickness" : @"嘴唇厚度",
            @"TC.BeautySettingPanel.FaceBeauty" : @"脸型",
            @"TC.BeautyPanel.Menu.Beauty" : @"美颜",
            @"TC.BeautyPanel.Menu.Filter" : @"滤镜",
            @"TC.BeautyPanel.Menu.VideoEffect" : @"动效",
            @"TC.BeautyPanel.Menu.BlendPic" : @"抠背",
            @"TC.BeautyPanel.Menu.GreenScreen" : @"绿幕",
            @"TC.BeautyPanel.Menu.Gesture" : @"手势",
            @"TC.BeautyPanel.Menu.Cosmetic" : @"美妆",
            @"TC.Common.Filter_original" : @"原图",
            @"TC.Common.Filter_baixi" : @"白皙",
            @"TC.Common.Filter_normal" : @"标准",
            @"TC.Common.Filter_ziran" : @"自然",
            @"TC.Common.Filter_yinghong" : @"樱红",
            @"TC.Common.Filter_yunshang" : @"云裳",
            @"TC.Common.Filter_chunzhen" : @"纯真",
            @"TC.Common.Filter_bailan" : @"白兰",
            @"TC.Common.Filter_yuanqi" : @"元气",
            @"TC.Common.Filter_chaotuo" : @"超脱",
            @"TC.Common.Filter_xiangfen" : @"香氛",
            @"TC.Common.Filter_white" : @"美白",
            @"TC.Common.Filter_langman" : @"浪漫",
            @"TC.Common.Filter_qingxin" : @"清新",
            @"TC.Common.Filter_weimei" : @"唯美",
            @"TC.Common.Filter_fennen" : @"粉嫩",
            @"TC.Common.Filter_huaijiu" : @"怀旧",
            @"TC.Common.Filter_landiao" : @"蓝调",
            @"TC.Common.Filter_qingliang" : @"清凉",
            @"TC.Common.Filter_rixi" : @"日系",
        };
    });
    return defaultStringMap[key] ?: key;
}

@end
