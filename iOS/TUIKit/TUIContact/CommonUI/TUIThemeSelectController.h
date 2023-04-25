//
//  ThemeSelectController.h
//  TUIKitDemo
//
//  Created by harvy on 2022/1/5.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIThemeSelectCollectionViewCellModel;
typedef void(^ThemeSelectCallback)(TUIThemeSelectCollectionViewCellModel *cellModel);

@protocol TUIThemeSelectControllerDelegate <NSObject>

- (void)onSelectTheme:(TUIThemeSelectCollectionViewCellModel *)cellModel;

@end

@interface TUIThemeSelectCollectionViewCellModel : NSObject

@property (nonatomic, strong) UIImage *backImage;
@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) NSString *themeName;
@property (nonatomic, copy) NSString *themeID;

@end

@interface TUIThemeSelectCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *backView;
@property (nonatomic, strong) UIButton *chooseButton;
@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) TUIThemeSelectCollectionViewCellModel *cellModel;

@property (nonatomic, copy) ThemeSelectCallback onSelect;


@end

@interface TUIThemeHeaderCollectionViewCell : TUIThemeSelectCollectionViewCell

@end


@interface TUIThemeSelectController : UIViewController

@property (nonatomic, weak) id<TUIThemeSelectControllerDelegate> delegate;

@property (nonatomic, assign) BOOL disable;

/**
 * 禁用跟随系统风格
 * Disable follow system style.
 */
+ (void)disableFollowSystemStyle;

/**
 * 应用主题，如果ID为空，则使用最近一次的设置
 * Applying the theme, if the id is empty, use the last setting.
 */
+ (void)applyTheme:(NSString * __nullable)themeID;

/**
 * 应用最近一次使用的主题
 * Applying the last theme
 */
+ (void)applyLastTheme;

/**
 * 获取上一次使用的主题名
 * Get the last used theme name
 */
+ (NSString *)getLastThemeName;
- (void)setBackGroundColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
