//
//  TUICallKitOfflinePushInfoConfig.h
//  TUICallKit
//
//  Created by noah on 2022/9/15.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TUIOfflinePushInfo;

NS_ASSUME_NONNULL_BEGIN

@interface TUICallKitOfflinePushInfoConfig : NSObject

+ (TUIOfflinePushInfo *)createOfflinePushInfo;

@end

NS_ASSUME_NONNULL_END
