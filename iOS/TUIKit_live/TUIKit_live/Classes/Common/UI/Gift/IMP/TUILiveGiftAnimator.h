//
//  TUILiveLottieAnimator.h
//  Pods
//
//  Created by harvy on 2020/9/17.
//

#import <UIKit/UIKit.h>
#import "TUILiveGiftInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveGiftAnimator : NSObject


/// 初始化方法
/// @param animationContainerView 礼物动画容器，用来展示礼物动画的
- (instancetype)initWithAnimationContainerView:(UIView *)animationContainerView;
- (void)show:(TUILiveGiftInfo *)giftInfo;

@end

NS_ASSUME_NONNULL_END
