//
//  AppDelegate+TPNS.h
//  TUIKitDemo
//
//  Created by harvy on 2021/12/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#if ENABLETPNS


#import "AppDelegate+Push.h"

@protocol XGPushDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (TPNS) <XGPushDelegate>

@end

NS_ASSUME_NONNULL_END


#endif
