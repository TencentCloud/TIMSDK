// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaStickerViewDelegate;

@interface TUIMultimediaStickerView : UIView
@property(nullable, nonatomic) UIView *content;
@property(nonatomic) BOOL selected;
@property(nonatomic) BOOL editButtonHidden;
@property(nonatomic, readonly) CGFloat rotation;
@property(nonatomic) CGFloat contentMargin;
// 旋转夹角小于此值时，吸附到水平和竖直方向
@property(nonatomic) CGFloat rotateAdsorptionLimitAngle;
@property(weak, nullable, nonatomic) id<TUIMultimediaStickerViewDelegate> delegate;

@end

@protocol TUIMultimediaStickerViewDelegate <NSObject>
- (void)onStickerViewSelected:(TUIMultimediaStickerView *)v;
- (void)onStickerViewShouldDelete:(TUIMultimediaStickerView *)v;
- (void)onStickerViewShouldEdit:(TUIMultimediaStickerView *)v;
- (void)onStickerViewSizeChanged:(TUIMultimediaStickerView *)v;
@end

NS_ASSUME_NONNULL_END
