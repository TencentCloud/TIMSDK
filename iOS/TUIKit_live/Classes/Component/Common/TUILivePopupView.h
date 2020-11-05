//
//  TUILivePopupView.h
//  Pods
//
//  Created by harvy on 2020/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILivePopupView : UIView

@property (nonatomic, strong) UIView *animateView;

// API
- (void)showInView:(UIView * __nullable)view animate:(BOOL)animated;
- (void)showInView:(UIView *)view animate:(BOOL)animated completion:(dispatch_block_t __nullable)completion;
- (void)hide:(BOOL)animated;
- (void)hide:(BOOL)animated completion:(dispatch_block_t __nullable)completion;
- (void)updateAnimateViewHeight:(CGFloat)height animated:(BOOL)animated;

// 子类重写，自定义显示内容
- (CGFloat)animateViewHeight;
- (void)layoutAnimateView;
- (void)tapCover;

@end

NS_ASSUME_NONNULL_END
