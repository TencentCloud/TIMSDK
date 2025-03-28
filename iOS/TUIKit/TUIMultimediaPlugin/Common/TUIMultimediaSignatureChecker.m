// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaSignatureChecker.h"
#import <ImSDK_Plus/V2TIMManager.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUILogin.h>
#import <TXLiteAVSDK_Professional/TXLiteAVSDK.h>
#import <objc/runtime.h>
#import "NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaPersistence.h"

#define SCHEDULE_UPDATE_SIGNATURE_INTERVAL_WHEN_START  0.f
#define SCHEDULE_UPDATE_SIGNATURE_INTERVAL_WHEN_SUCCESS  3600 * 1000.0f
#define SCHEDULE_UPDATE_SIGNATURE_INTERVAL_WHEN_FAIL  1000.0f
#define SCHEDULE_UPDATE_SIGNATURE_RETRY_TIMES  3

@interface TUIMultimediaSignatureChecker () {
    NSString* _signature;
    NSInteger _expiredTime;
    NSTimer* _timer;
    void (^_updateSignatureSuccess)(void);
}
@property (nonatomic, assign) NSInteger retryCount;
@end

@implementation TUIMultimediaSignatureChecker

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _retryCount = 0;
    }
    return self;
}

- (void)startUpdateSignature:(void (^)(void))updateSignatureSuccessful {
    NSLog(@"TUIMultimediaSignatureChecker startUpdateSignature");
    _updateSignatureSuccess = updateSignatureSuccessful;
    [self scheduleUpdateSignature:SCHEDULE_UPDATE_SIGNATURE_INTERVAL_WHEN_START];
}

- (void)updateSignatureIfNeed {
    if ([NSDate.now timeIntervalSince1970] < _expiredTime) {
        [self scheduleUpdateSignature:(_expiredTime - [NSDate.now timeIntervalSince1970]) *1000];
        return;
    }
    [V2TIMManager.sharedInstance callExperimentalAPI:@"getVideoEditSignature"
                                               param:nil
                                                succ:^(NSObject *result) {
        if (result == nil || ![result isKindOfClass:NSDictionary.class]) {
            NSLog(@"getVideoEditSignature: data = nil");
            return;
        }
        NSDictionary *data = (NSDictionary *)result;
        NSLog(@"getVideoEditSignature: data = %@", data);
        NSNumber *expiredTime = data[@"expired_time"];
        NSString *signature = data[@"signature"];
        if (![expiredTime isKindOfClass:NSNumber.class]) {
            NSLog(@"getVideoEditSignature: expiredTime type error");
            return;
        }
        if (![signature isKindOfClass:NSString.class]) {
            NSLog(@"getVideoEditSignature: signature type error");
            return;
        }
        self.retryCount = 0;
        self->_expiredTime = [expiredTime integerValue];
        self->_signature = signature;
        NSLog(@"getVideoEditSignature: succeed. signature=%@, expiredTime=%@", self->_signature, @(self->_expiredTime));
        [self setSignatureToSDK];
        [self scheduleUpdateSignature:([expiredTime integerValue] -  [NSDate.now timeIntervalSince1970]) * 1000];
        if (self->_updateSignatureSuccess != nil) {
            self->_updateSignatureSuccess();
            self->_updateSignatureSuccess = nil;
        }
    }
                                                fail:^(int code, NSString *desc) {
        NSLog(@"getVideoEditSignature: failed. code=%@, desc=%@", @(code), desc);
        if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
            [self cancelTimer];
            return;
        }
        self.retryCount ++;
        if (self.retryCount > SCHEDULE_UPDATE_SIGNATURE_RETRY_TIMES) {
            self.retryCount = 0;
            return;
        }
        else {
            NSLog(@"getVideoEditSignature: Attempting to get signature for the %ld time",self.retryCount);
            [self scheduleUpdateSignature:SCHEDULE_UPDATE_SIGNATURE_INTERVAL_WHEN_FAIL];
        }
    }];
}

- (void)setSignatureToSDK {
    NSDictionary *param = @{
        @"api" : @"setSignature",
        @"params" : @{
            @"appid" : [@([TUILogin getSdkAppID]) stringValue],
            @"signature" : _signature,
        },
    };
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
    if (error != nil) {
        NSLog(@"TUIMultimedia GetMultimediaIsSupport Error:%@", error);
    }
    NSString *paramStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"TUIMultimedia setSignature:%@", paramStr);
    
    SEL selector = NSSelectorFromString(@"callExperimentalAPI:");
    if ([[TXUGCBase class] respondsToSelector:selector]) {
//        [TXUGCBase callExperimentalAPI:paramStr];
        [[TXUGCBase class] performSelector:selector withObject:paramStr];
    } else {
        NSLog(@"callExperimentalAPI: method is not available.");
    }
}

- (BOOL)isFunctionSupport {
    return _signature != nil && _signature.length > 0 && [NSDate.now timeIntervalSince1970] < _expiredTime;
}

-(void)scheduleUpdateSignature:(float)interval {
    [self cancelTimer];
    interval = interval / 1000;
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateSignatureIfNeed) userInfo:nil repeats:NO];
}

- (void)cancelTimer {
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
