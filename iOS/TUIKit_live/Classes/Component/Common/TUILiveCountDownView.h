//
//  TUILiveCountDownView.h
//  Pods
//
//  Created by harvy on 2020/10/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveCountDownView : UIView


/// 开启倒计时
/// @param count 倒计时起点
/// @param onEnd 结束后的回调
- (void)beginCount:(NSInteger)count onEnd:(dispatch_block_t)onEnd;

@end

NS_ASSUME_NONNULL_END
