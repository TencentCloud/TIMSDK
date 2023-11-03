//
//  TUICallingService.m
//  TUICalling
//
//  Created by noah on 2021/8/20.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TUICallingService.h"
#import "TUICore.h"
#import "TUILogin.h"
#import "TUIDefine.h"
#import "TUICallKit.h"
#import "TUICallingCommon.h"
#import "TUIGlobalization.h"
#import "NSDictionary+TUISafe.h"
#import "TUICallEngineHeader.h"
#import "TUICallingStatusManager.h"

@interface TUICallingService () <TUIServiceProtocol>

@end

@implementation TUICallingService

+ (void)load {
    [TUICore registerService:TUICore_TUICallingService object:[TUICallingService shareInstance]];
    TUIRegisterThemeResourcePath(TUICallKitThemePath, TUIThemeModuleCalling);
}

+ (TUICallingService *)shareInstance {
    static dispatch_once_t onceToken;
    static TUICallingService * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUICallingService alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginSuccessNotification)
                                                     name:TUILoginSuccessNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loginSuccessNotification {
    [TUICallKit createInstance];
    [self adaptiveComponentReport];
    [self setExcludeFromHistoryMessage];
}

- (void)startCall:(NSString *)groupID userIDs:(NSArray *)userIDs callingType:(TUICallMediaType)callingType {
    if ([[TUICallEngine createInstance] respondsToSelector:@selector(setOnlineUserOnly:)]) {
        [[TUICallEngine createInstance] performSelector:@selector(setOnlineUserOnly:) withObject:@(0)];
    }
    
    if (groupID && [groupID isKindOfClass:NSString.class]) {
        [[TUICallKit createInstance] groupCall:groupID userIdList:userIDs callMediaType:callingType];
    } else {
        [[TUICallKit createInstance] call:[userIDs firstObject] callMediaType:callingType];
    }
}

#pragma mark - TUIServiceProtocol

- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    if (![TUICallingCommon checkDictionaryValid:param]) {
        return nil;
    }
    
    if ([method isEqualToString:TUICore_TUICallingService_EnableFloatWindowMethod]) {
        NSString *keyStr = TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow;
        NSNumber *enableFloatWindow = [param tui_objectForKey:keyStr asClass:NSNumber.class];
        [[TUICallKit createInstance] enableFloatWindow:[enableFloatWindow boolValue]];
    } else if ([method isEqualToString:TUICore_TUICallingService_ShowCallingViewMethod]) {
        NSArray *userIDs = [param tui_objectForKey:TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey asClass:NSArray.class];
        NSString *callMediaTypeKey = TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey;
        NSInteger callingMediaValue = (TUICallMediaType)[[param tui_objectForKey:callMediaTypeKey asClass:NSString.class] integerValue];
        TUICallMediaType callingType = TUICallMediaTypeUnknown;
        if (callingMediaValue == 0) {
            callingType = TUICallMediaTypeAudio;
        } else if (callingMediaValue == 1) {
            callingType = TUICallMediaTypeVideo;
        }
        NSString *groupID = [param tui_objectForKey:TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey asClass:NSString.class];
        
        [self startCall:groupID userIDs:userIDs callingType:callingType];
    } else if ([method isEqualToString:TUICore_TUICallingService_ReceivePushCallingMethod]) {
        NSString *keyStr = TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo;
        V2TIMSignalingInfo *signalingInfo = [param tui_objectForKey:keyStr asClass:V2TIMSignalingInfo.class];
        NSString *groupID = signalingInfo.groupID;
        
        if ([[TUICallKit createInstance] respondsToSelector:@selector(setGroupID:)]) {
            [[TUICallKit createInstance] performSelector:@selector(setGroupID:) withObject:groupID];
        }
        
        if ([[TUICallEngine createInstance] respondsToSelector:@selector(onReceiveGroupCallAPNs:)]) {
            [[TUICallEngine createInstance] performSelector:@selector(onReceiveGroupCallAPNs:) withObject:signalingInfo];
        }
    } else if ([method isEqualToString:TUICore_TUICallingService_EnableMultiDeviceAbilityMethod]) {
        NSString *keyStr = TUICore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility;
        NSNumber *enableMultiDeviceAbility = [param tui_objectForKey:keyStr asClass:NSNumber.class];
        [[TUICallEngine createInstance] enableMultiDeviceAbility:[enableMultiDeviceAbility boolValue] succ:^{
        } fail:^(int code, NSString * _Nullable errMsg) {
        }];
    } else if ([method isEqualToString:TUICore_TUICallingService_SetAudioPlaybackDeviceMethod]) {
        NSString *keyStr = TUICore_TUICallingService_SetAudioPlaybackDevice_AudioPlaybackDevice;
        NSNumber *audioPlaybackDevice = [param tui_objectForKey:keyStr asClass:NSNumber.class];
        [TUICallingStatusManager shareInstance].audioPlaybackDevice = [audioPlaybackDevice unsignedIntegerValue];
    } else if ([method isEqualToString:TUICore_TUICallingService_SetIsMicMuteMethod]) {
        NSString *keyStr = TUICore_TUICallingService_SetIsMicMuteMethod_IsMicMute;
        NSNumber *isMicMute = [param tui_objectForKey:keyStr asClass:NSNumber.class];
        [TUICallingStatusManager shareInstance].isMicMute = [isMicMute boolValue];
    }
    
    return nil;
}

- (void)adaptiveComponentReport {
    NSDictionary *jsonDic = [[NSDictionary alloc] init];
    
    if (![TUICore getService:TUICore_TUIChatService]) {
        jsonDic = @{@"api": @"setFramework",
                    @"params": @{@"component": @(14),
                                 @"language": @(4)}};
    } else {
        jsonDic = @{@"api": @"setFramework",
                    @"params": @{@"component": @(15),
                                 @"language": @(4)}};
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSAssert(NO, @"invalid jsonDic");
        return;
    }
    [[TUICallEngine createInstance] callExperimentalAPI:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

- (void)setExcludeFromHistoryMessage {
    if (![TUICore getService:TUICore_TUIChatService]) {
        return;
    }
    
    NSDictionary *jsonDic = @{@"api": @"setExcludeFromHistoryMessage",
                              @"params": @{@"excludeFromHistoryMessage": @(NO)}};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSAssert(NO, @"invalid jsonDic");
        return;
    }
    [[TUICallEngine createInstance] callExperimentalAPI:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

@end
