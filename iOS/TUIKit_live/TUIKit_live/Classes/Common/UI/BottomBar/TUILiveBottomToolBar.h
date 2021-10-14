//
//  TUILiveBottomToolBar.h
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUILiveBottomToolBar;
typedef void(^TUILiveBottomToolBarClickBlock)(TUILiveBottomToolBar *toolBar, UIButton *sender);
@interface TUILiveBottomToolBar : UIView
/// UI
@property(nonatomic, strong, readonly) UIButton *inputButton; /// 左边输入框按钮
@property(nonatomic, strong) NSArray<UIButton *> *rightButtons; /// 右边的按钮
@property(nonatomic, strong) TUILiveBottomToolBarClickBlock onClick; /// 按钮点击回调

/// 便捷创建底部栏右侧按钮
/// @param image 按钮正常情况下显示的图片
/// @param selectedImage 按钮选中状态下显示的图片、为空时使用image替代
+ (UIButton *)createButtonWithImage:(nullable UIImage *)image selectedImage:(nullable UIImage *)selectedImage;
@end

NS_ASSUME_NONNULL_END
