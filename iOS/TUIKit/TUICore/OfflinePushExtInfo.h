//
//  OfflinePushExtInfo.h
//  TUICore
//
//  Created by cologne on 2024/3/19.
//  Copyright © 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "OfflinePushExtBusinessInfo.h"
#import "OfflinePushExtConfigInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface OfflinePushExtInfo : NSObject
// Common feature function class instance
@property (nonatomic, strong) OfflinePushExtBusinessInfo *entity;
// Entrance to features and functions supported by the TIMPush plug-in
@property (nonatomic, strong) OfflinePushExtConfigInfo *timPushFeatures;

/**
 * If you need to customize the parsing of the received remote push, you need to implement the `- onRemoteNotificationReceived` method in the AppDelegate.m file;
 * You can convert ext to the OfflinePushExtInfo model according to the passed parameters for customized operations.
 */
+ (OfflinePushExtInfo *)createWithExtString:(NSString *)ext;

/**
 * If you need to customize the parsing of the received remote push, you need to implement the `- onRemoteNotificationReceived` method in the AppDelegate.m file;
 * You can convert ext to the OfflinePushExtInfo model according to the passed parameters for customized operations.
 */
- (NSString *)toReportExtString;
@end

NS_ASSUME_NONNULL_END
