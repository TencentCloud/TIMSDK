//
//  TUILiveGiftPannelDelegate.h
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import <Foundation/Foundation.h>
@class TUILiveGiftInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol TUILiveGiftPanelDelegate <NSObject>

@optional
/// 礼物点击事件
/// @param giftInfo 礼物信息
- (void)onGiftItemClick:(TUILiveGiftInfo *)giftInfo;

/// 充值点击事件
- (void)onChargeClick;

@end

NS_ASSUME_NONNULL_END
