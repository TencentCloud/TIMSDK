//
//  TUIOfflinePushManager+VOIP.h
//  TUIOfflinePush
//
//  Created by harvy on 2022/9/15.
//

#import "TUIOfflinePushManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIOfflinePushVOIPProcessProtocol <TUIOfflinePushProcessProtocol>

/**
 * 收到 VoIP push 回调
 *
 * @note 处理完成之后，需要调用 completion 通知系统已完成处理
 */
- (void)onReceiveIncomingVOIPPushWithPayload:(NSDictionary *)payload withCompletionHandler:(void(^)(void))completion;

@end


@interface TUIOfflinePushManager (VOIP)

@end

NS_ASSUME_NONNULL_END
