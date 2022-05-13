//
//  TUIOfflinePushManager+TPNS.h
//  Pods
//
//  Created by harvy on 2022/5/6.
//

#import <ImSDK_Plus/ImSDK_Plus.h>
#import <TPNS-iOS/XGPush.h>
#import "TUIOfflinePushManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIOfflinePushManager (TPNS) <XGPushDelegate, V2TIMConversationListener>

@end

NS_ASSUME_NONNULL_END
