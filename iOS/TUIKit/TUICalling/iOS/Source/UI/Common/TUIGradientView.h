//
//  TUIGradientView.h
//  TUICalling
//
//  Created by noah on 2021/8/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 颜色渐变方向
typedef NS_ENUM(NSInteger, TUIGradientViewDirection) {
    TUIGradientViewDirectionLeftToRight,             // 从左到右
    TUIGradientViewDirectionRightToLeft,             // 从右到左
    TUIGradientViewDirectionBottomToTop,             // 从下到上
    TUIGradientViewDirectionTopToBottom,             // 从上到下
    TUIGradientViewDirectionLeftBottomToRightTop,    // 从左下到右上
    TUIGradientViewDirectionLeftTopToRightBottom,    // 从左上到右下
    TUIGradientViewDirectionRightBottomToLeftTop,    // 从右下到左上
    TUIGradientViewDirectionRightTopToLeftBottom,    // 从右上到左下
};

@interface TUIGradientView : UIView

/// 设置渐变参数，提供常用渐变方向
/// @param colors 渐变颜色
/// @param direction 常用渐变方向
- (void)configWithColors:(NSArray <UIColor *> *_Nullable)colors direction:(TUIGradientViewDirection)direction;

/// 设置渐变参数
/// @param colors 渐变颜色
/// @param locations 渐变颜色区间
/// @param startPoint 起始点
/// @param endPoint 结束点
- (void)configWithColors:(NSArray <UIColor *> *_Nullable)colors
               locations:(NSArray <NSNumber *> *_Nullable)locations
              startPoint:(CGPoint)startPoint
                endPoint:(CGPoint)endPoint;

@end

NS_ASSUME_NONNULL_END
