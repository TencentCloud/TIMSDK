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
typedef void (^ThemeSelectCallback)(TUIThemeSelectCollectionViewCellModel *cellModel);

@protocol TUIThemeSelectControllerDelegate <NSObject>

- (void)onSelectTheme:(TUIThemeSelectCollectionViewCellModel *)cellModel;

@end

@interface TUIThemeSelectCollectionViewCellModel : NSObject

@property(nonatomic, strong) UIImage *backImage;
@property(nonatomic, strong) UIColor *startColor;
@property(nonatomic, strong) UIColor *endColor;

@property(nonatomic, assign) BOOL selected;
@property(nonatomic, copy) NSString *themeName;
@property(nonatomic, copy) NSString *themeID;

@end

@interface TUIThemeSelectCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *backView;
@property(nonatomic, strong) UIButton *chooseButton;
@property(nonatomic, strong) UILabel *descLabel;

@property(nonatomic, strong) TUIThemeSelectCollectionViewCellModel *cellModel;

@property(nonatomic, copy) ThemeSelectCallback onSelect;

@end

@interface TUIThemeHeaderCollectionViewCell : UICollectionViewCell
@property(nonatomic, strong) TUIThemeSelectCollectionViewCellModel *cellModel;
@property(nonatomic, copy) ThemeSelectCallback onSelect;
@end

@interface TUIThemeSelectController : UIViewController

@property(nonatomic, weak) id<TUIThemeSelectControllerDelegate> delegate;

@property(nonatomic, assign) BOOL disable;

/**
 * Disable follow system style.
 */
+ (void)disableFollowSystemStyle;

/**
 * Applying the theme, if the id is empty, use the last setting.
 */
+ (void)applyTheme:(NSString *__nullable)themeID;

/**
 * Applying the last theme
 */
+ (void)applyLastTheme;

/**
 * Get the last used theme name
 */
+ (NSString *)getLastThemeName;
- (void)setBackGroundColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
