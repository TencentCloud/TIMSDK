
#import <Foundation/Foundation.h>
#import "TUICallModel.h"
#import "TUICall.h"
#import "TUICall+Signal.h"

@interface TUICallManager : NSObject

/**
 *  获取 TUICallManager 管理实例
 */
+(TUICallManager *)shareInstance;

/**
 *  初始化通话模块
 */
- (void)initWithSdkAppID:(UInt32)sdkAppid userID:(NSString *)userID userSig:(NSString *)userSig;

/**
 *  收到群通话邀请 APNs
 */
- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo;


@end

