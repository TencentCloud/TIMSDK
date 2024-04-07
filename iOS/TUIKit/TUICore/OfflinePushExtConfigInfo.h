//
//  OfflinePushExtConfigInfo.h
//  TUICore
//
//  Created by cologne on 2024/3/19.
//  Copyright © 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// Entrance to features and functions supported by the TIMPush plug-in
@interface OfflinePushExtConfigInfo : NSObject
/**
 * In the FCM channel data mode, set whether the notification bar message is popped up by a plug-in or thrown out by the business implementation (0: TIMPush implementation, 1: Throwing business implementation by itself)
 */
@property(nonatomic, assign) NSInteger fcmPushType;
/**
 * In FCM channel data mode, get the notification bar message whether it is a plug-in pop-up or a throw-out business implementation pop-up (0: TIMPush implementation; 1: throw-out business implementation)
 */
@property(nonatomic, assign) NSInteger fcmNotificationType;

- (void)configWithTIMPushFeaturesDic:(NSDictionary *)featuresDic;
- (NSDictionary *)toReportData;
@end

NS_ASSUME_NONNULL_END
