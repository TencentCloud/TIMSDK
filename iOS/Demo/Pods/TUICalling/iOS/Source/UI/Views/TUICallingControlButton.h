//
//  TUICallingControlButton.h
//  TUICalling
//
//  Created by noah on 2021/9/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUICallingButtonActionBlcok) (UIButton *sender);

@interface TUICallingControlButton : UIView

/// 创造自定义试图
/// @param frame 视图尺寸
/// @param titleText 文本文字
/// @param buttonAction 按钮行为
/// @param imageSize 图标尺寸
+ (instancetype)createViewWithFrame:(CGRect)frame titleText:(NSString *)titleText  buttonAction:(TUICallingButtonActionBlcok)buttonAction imageSize:(CGSize)imageSize;

- (void)configBackgroundImage:(UIImage *)image;

- (void)configTitleColor:(UIColor *)titleColor;

@end

NS_ASSUME_NONNULL_END
