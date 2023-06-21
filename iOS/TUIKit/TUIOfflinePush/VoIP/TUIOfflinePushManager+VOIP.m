//
//  TUIOfflinePushManager+VoIP.m
//  TUIOfflinePush
//
//  Created by harvy on 2022/9/15.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIOfflinePushManager+Inner.h"
#import "TUIOfflinePushManager+VOIP.h"

#import <ImSDK_Plus/ImSDK_Plus.h>
#import <PushKit/PushKit.h>

@interface TUIOfflinePushManager () <PKPushRegistryDelegate>

@end

@implementation TUIOfflinePushManager (VOIP)
PKPushRegistry *_voipRegistry;

- (void)registerForVOIPPush {
    _voipRegistry = [[PKPushRegistry alloc] initWithQueue:nil];
    _voipRegistry.delegate = self;
    _voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

- (void)reportVOIPToken:(NSData *)token {
    NSLog(@"[TUIOfflinePushManager] %s", __func__);
    if (token) {
        V2TIMVOIPConfig *config = [[V2TIMVOIPConfig alloc] init];
        config.token = token;
        config.certificateID = self.voipCertificateID;
        [[V2TIMManager sharedInstance] setVOIP:config
            succ:^{
              NSLog(@"%s, succ, id:%zd", __func__, config.certificateID);
            }
            fail:^(int code, NSString *desc) {
              NSLog(@"%s, fail, %d, %@", __func__, code, desc);
            }];
    }
}

#pragma mark - PKPushRegistryDelegate
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    NSLog(@"[TUIOfflinePushManager][VoIP] %s, type:%@", __func__, type);
    [self reportVOIPToken:pushCredentials.token];
}

- (void)pushRegistry:(PKPushRegistry *)registry
    didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
                              forType:(PKPushType)type
                withCompletionHandler:(void (^)(void))completion {
    if (type != PKPushTypeVoIP) {
        return;
    }

    NSDictionary *payloadDict = payload.dictionaryPayload;

    SEL selector = NSSelectorFromString(@"onReceiveIncomingVOIPPushWithPayload:withCompletionHandler:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    [invocation setArgument:&payloadDict atIndex:2];
    [invocation setArgument:&completion atIndex:3];
    [invocation invoke];
}

#pragma mark - Configuration
- (int)voipCertificateID {
    SEL selector = NSSelectorFromString(@"push_certificateIDForVoIP");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return 0;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    [invocation invoke];

    int busiID = 0;
    if (signature.methodReturnLength) {
        [invocation getReturnValue:&busiID];
    }
    return busiID;
}

@end
