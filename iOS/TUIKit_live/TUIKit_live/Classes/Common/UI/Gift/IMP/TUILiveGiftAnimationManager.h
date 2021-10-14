//
//  TUILiveGiftAnimationManager.h
//  Pods
//
//  Created by harvy on 2020/9/17.
//

#import <Foundation/Foundation.h>
@class TUILiveGiftInfo;
@class TUILiveGiftAnimationManager;

NS_ASSUME_NONNULL_BEGIN

@protocol TUILiveGiftAnimationManagerDelegate <NSObject>

- (void)giftAnimationManager:(TUILiveGiftAnimationManager *)mamager
         handleGiftAnimation:(TUILiveGiftInfo *)gift
                  completion:(void(^)(void))completion;

@end


@interface TUILiveGiftAnimationManager : NSObject

@property (nonatomic, weak) id<TUILiveGiftAnimationManagerDelegate> delegate;

/// 收到礼物动画播放消息
/// @param giftInfo 礼物信息
- (void)onRecevieGiftInfo:(TUILiveGiftInfo *)giftInfo;

@end

NS_ASSUME_NONNULL_END
