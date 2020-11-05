//
//  TCPanelTheme.h
//  TC
//
//  Created by cui on 2019/12/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TCBeautyPanelThemeProtocol <NSObject>

@property (strong, nonatomic) UIColor *backgroundColor;
#pragma mark - Beauty Panel
/// 美颜面板 - 大眼图标
@property (strong, nonatomic) UIImage *beautyPanelEyeScaleIcon;
/// 美颜面板 - P图（磨皮）风格美颜图标
@property (strong, nonatomic) UIImage *beautyPanelPTuBeautyStyleIcon;
/// 美颜面板 - 红润图标
@property (strong, nonatomic) UIImage *beautyPanelRuddyIcon;
/// 美颜面板 - 绿幕图标
@property (strong, nonatomic) UIImage *beautyPanelBgRemovalIcon;
/// 美颜面板 - 美白图标
@property (strong, nonatomic) UIImage *beautyPanelWhitnessIcon;
/// 美颜面板 - 瘦脸图标
@property (strong, nonatomic) UIImage *beautyPanelFaceSlimIcon;
/// 美颜面板 - AI抠图图标
@property (strong, nonatomic) UIImage *beautyPanelGoodLuckIcon;
/// 美颜面板 - 下巴调整图标
@property (strong, nonatomic) UIImage *beautyPanelChinIcon;
/// 美颜面板 - V脸图标
@property (strong, nonatomic) UIImage *beautyPanelFaceVIcon;
/// 美颜面板 - 瘦脸图标
@property (strong, nonatomic) UIImage *beautyPanelFaceScaleIcon;
/// 美颜面板 - 瘦鼻图标
@property (strong, nonatomic) UIImage *beautyPanelNoseSlimIcon;
/// 美颜面板 - 白牙图标
@property (strong, nonatomic) UIImage *beautyPanelToothWhitenIcon;
/// 美颜面板 - 眼距图标
@property (strong, nonatomic) UIImage *beautyPanelEyeDistanceIcon;
/// 美颜面板 - 发际线图标
@property (strong, nonatomic) UIImage *beautyPanelForeheadIcon;
/// 美颜面板 - 脸型图标
@property (strong, nonatomic) UIImage *beautyPanelFaceBeautyIcon;
/// 美颜面板 - 眼睛角度图标
@property (strong, nonatomic) UIImage *beautyPanelEyeAngleIcon;
/// 美颜面板 - 鼻翼图标
@property (strong, nonatomic) UIImage *beautyPanelNoseWingIcon;
/// 美颜面板 - 嘴唇厚度图标
@property (strong, nonatomic) UIImage *beautyPanelLipsThicknessIcon;
/// 美颜面板 - 袪皱图标
@property (strong, nonatomic) UIImage *beautyPanelWrinkleRemoveIcon;
/// 美颜面板 - 嘴形图标
@property (strong, nonatomic) UIImage *beautyPanelMouthShapeIcon;
/// 美颜面板 - 袪眼袋图标x
@property (strong, nonatomic) UIImage *beautyPanelPounchRemoveIcon;
/// 美颜面板 - 嘴形图标
@property (strong, nonatomic) UIImage *beautyPanelSmileLinesRemoveIcon;
/// 美颜面板 - 亮眼图标
@property (strong, nonatomic) UIImage *beautyPanelEyeLightenIcon;
/// 美颜面板 - 鼻子位置图标
@property (strong, nonatomic) UIImage *beautyPanelNosePositionIcon;
/// 美颜面板 - 关闭效果图标
@property (strong, nonatomic) UIImage *menuDisableIcon;
/// 菜单选中背景图片
@property (strong, nonatomic) UIImage *beautyPanelMenuSelectionBackgroundImage;
/// 菜单文字颜色
@property (strong, nonatomic) UIColor *beautyPanelTitleColor;
/// 菜单文字选中颜色
@property (strong, nonatomic) UIColor *beautyPanelSelectionColor;
/// 录制速度选中文字颜色
@property (strong, nonatomic) UIColor *speedControlSelectedTitleColor;

- (NSString *)localizedString:(NSString *)key __attribute__((annotate("returns_localized_nsstring")));

/// 滑杆配置
@property (strong, nonatomic) UIColor *sliderMinColor;
@property (strong, nonatomic) UIColor *sliderMaxColor;
@property (strong, nonatomic) UIImage *sliderThumbImage;
@property (strong, nonatomic) UIColor *sliderValueColor;

- (UIImage *)iconForFilter:(NSString *)filter;
- (UIImage *)imageNamed:(NSString *)name;
- (NSURL *)goodLuckVideoFileURL;
@end


@interface TCBeautyPanelTheme : NSObject <TCBeautyPanelThemeProtocol>

@end

NS_ASSUME_NONNULL_END
