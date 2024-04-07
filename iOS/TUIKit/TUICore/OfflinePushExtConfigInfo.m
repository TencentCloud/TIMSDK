//
//  OfflinePushExtConfigInfo.m
//  TUICore
//
//  Created by cologne on 2024/3/19.
//  Copyright © 2024 Tencent. All rights reserved.

#import "OfflinePushExtConfigInfo.h"

@implementation OfflinePushExtConfigInfo
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupData];
    }
    return self;
}

- (void)setupData {
    self.fcmPushType = 0;
    self.fcmNotificationType = 0;
}

- (void)configWithTIMPushFeaturesDic:(NSDictionary *)featuresDic {
    if (featuresDic == nil || ![featuresDic isKindOfClass:NSDictionary.class]) {
        return ;
    }
    
    if ([featuresDic.allKeys containsObject:@"fcmPushType"]) {
        int fcmPushType = 0;
        fcmPushType = [featuresDic[@"fcmPushType"] integerValue];
        self.fcmPushType = fcmPushType;
    }

    if ([featuresDic.allKeys containsObject:@"fcmNotificationType"]) {
        int fcmNotificationType = 0;
        fcmNotificationType = [featuresDic[@"fcmNotificationType"] integerValue];
        self.fcmNotificationType = fcmNotificationType;
    }
    
}
- (NSDictionary *)toReportData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"fcmPushType"] = @(self.fcmPushType);
    dict[@"fcmNotificationType"] = @(self.fcmNotificationType);
    return dict;
}

@end
