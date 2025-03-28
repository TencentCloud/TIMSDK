// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaColorPanelDelegate;

/**
 条形颜色选择器
 */
@interface TUIMultimediaColorPanel : UIView
@property(weak, nullable, nonatomic) id<TUIMultimediaColorPanelDelegate> delegate;
@property(nonatomic) NSArray<UIColor *> *colorList;
@property(nonatomic) UIColor *selectedColor;
@end

@protocol TUIMultimediaColorPanelDelegate <NSObject>
- (void)onColorPanel:(TUIMultimediaColorPanel *)panel selectColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
