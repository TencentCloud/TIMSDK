
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#define tui_mm_weakify(object) \
    autoreleasepool {}         \
    __weak typeof(object) weak##object = object;
#define tui_mm_strongify(object) \
    autoreleasepool {}           \
    __strong typeof(weak##object) object = weak##object;

#import <UIKit/UIKit.h>

@interface UIView (TUILayout)

@property(nonatomic) CGFloat mm_x;  ///<< frame.x
@property(nonatomic) CGFloat mm_y;  ///<< frame.y
@property(nonatomic) CGFloat mm_w;  ///<< frame.size.width
@property(nonatomic) CGFloat mm_h;  ///<< frame.size.height

@property(nonatomic) CGFloat mm_r;  ///<< right
@property(nonatomic) CGFloat mm_b;  ///<< bottom

@property(nonatomic) CGFloat mm_centerX;  ///<< self.center.x
@property(nonatomic) CGFloat mm_centerY;  ///<< self.center.y

@property(readonly) CGFloat mm_maxY;  ///<< get CGRectGetMaxY
@property(readonly) CGFloat mm_minY;  ///<< get CGRectGetMinY
@property(readonly) CGFloat mm_maxX;  ///<< get CGRectGetMaxX
@property(readonly) CGFloat mm_minX;  ///<< get CGRectGetMinX

@property(readonly) UIView *mm_sibling;                   // 兄弟视图
@property(readonly) UIViewController *mm_viewController;  // self Responder UIViewControler

// iPhoneX adapt

@property(readonly) CGFloat mm_safeAreaBottomGap;
@property(readonly) CGFloat mm_safeAreaTopGap;
@property(readonly) CGFloat mm_safeAreaLeftGap;
@property(readonly) CGFloat mm_safeAreaRightGap;

- (UIView * (^)(CGFloat top))mm_top;             ///< set frame y
- (UIView * (^)(CGFloat bottom))mm_bottom;       ///< set frame y
- (UIView * (^)(CGFloat right))mm_flexToBottom;  ///< set frame height
- (UIView * (^)(CGFloat left))mm_left;           ///< set frame x
- (UIView * (^)(CGFloat right))mm_right;         ///< set frame x
- (UIView * (^)(CGFloat right))mm_flexToRight;   ///< set frame width
- (UIView * (^)(CGFloat width))mm_width;         ///< set frame width
- (UIView * (^)(CGFloat height))mm_height;       ///< set frame height
- (UIView * (^)(CGFloat x))mm__centerX;          ///< set center
- (UIView * (^)(CGFloat y))mm__centerY;          ///< set center

- (UIView * (^)(void))tui_mm_center;
- (UIView * (^)(void))mm_fill;

- (UIView * (^)(CGFloat space))mm_hstack;
- (UIView * (^)(CGFloat space))mm_vstack;

- (UIView * (^)(void))mm_sizeToFit;
- (UIView * (^)(CGFloat w, CGFloat h))mm_sizeToFitThan;
@end
