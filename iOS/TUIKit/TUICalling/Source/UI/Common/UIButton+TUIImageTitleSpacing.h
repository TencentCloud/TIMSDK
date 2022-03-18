//
//  UIButton+TUIImageTitleSpacing.h
//  TUICalling
//
//  Created by noah on 2021/8/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TUIButtonEdgeInsetsStyle) {
    TUIButtonEdgeInsetsStyleTop, // Image上，Label下
    TUIButtonEdgeInsetsStyleLeft, // Image左，Label右
    TUIButtonEdgeInsetsStyleBottom, // Image下，Label上
    TUIButtonEdgeInsetsStyleRight // Image右，Label左
};

@interface UIButton (TUIImageTitleSpacing)

/// 设置Button的 TitleLabel 和 ImageView 的布局样式，及间距
/// @param style 布局样式，四种之一
/// @param space 图片和文字的间隔
- (void)layoutButtonWithEdgeInsetsStyle:(TUIButtonEdgeInsetsStyle)style imageTitleSpace:(CGFloat)space NS_SWIFT_NAME(layoutButtonWithEdgeInsetsStyle(style:space:));;

@end

NS_ASSUME_NONNULL_END
