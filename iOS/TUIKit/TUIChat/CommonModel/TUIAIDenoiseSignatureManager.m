
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
//
//  TUIAIDenoiseSignatureManager.m
//  TUIChat
//

#import "TUIAIDenoiseSignatureManager.h"
#import <ImSDK_Plus/ImSDK_Plus.h>

static TUIAIDenoiseSignatureManager *gSharedInstance = nil;
static NSString *const kAPIKey = @"getAIDenoiseSignature";
static NSString *const kSignatureKey = @"signature";
static NSString *const kExpiredTimeKey = @"expired_time";

@interface TUIAIDenoiseSignatureManager ()
@property(nonatomic, copy, readwrite) NSString *signature;
@property(nonatomic, assign) NSTimeInterval expiredTime;
@end

@implementation TUIAIDenoiseSignatureManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        gSharedInstance = [[TUIAIDenoiseSignatureManager alloc] init];
    });
    return gSharedInstance;
}

- (void)updateSignature {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    if (currentTime < self.expiredTime) {
        return;
    }
    [[V2TIMManager sharedInstance] callExperimentalAPI:kAPIKey
        param:nil
        succ:^(NSObject *result) {
          if (result == nil || ![result isKindOfClass:NSDictionary.class]) {
              return;
          }
          NSDictionary *dict = (NSDictionary *)result;
          if (dict[kSignatureKey] != nil && [dict[kSignatureKey] isKindOfClass:NSString.class]) {
              self.signature = dict[kSignatureKey];
          }
          if (dict[kExpiredTimeKey] != nil && [dict[kExpiredTimeKey] isKindOfClass:NSNumber.class]) {
              self.expiredTime = [dict[kExpiredTimeKey] doubleValue];
          }
        }
        fail:^(int code, NSString *desc) {
          NSLog(@"getAIDenoiseSignature failed, code: %d, desc: %@", code, desc);
        }];
}

- (NSString *)signature {
    [self updateSignature];
    return _signature;
}

@end
