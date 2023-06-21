
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUIChatService.h"
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIChatConfig.h"
#import "TUIChatDefine.h"
#import "TUIMessageDataProvider.h"

@interface TUIChatService () <TUINotificationProtocol, TUIExtensionProtocol>

@end

@implementation TUIChatService

+ (void)load {
    [TUICore registerService:TUICore_TUIChatService object:[TUIChatService shareInstance]];
    TUIRegisterThemeResourcePath(TUIChatThemePath, TUIThemeModuleChat);
}

+ (TUIChatService *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIChatService *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      g_sharedInstance = [[TUIChatService alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNotification) name:TUILoginSuccessNotification object:nil];
    }
    return self;
}

- (void)loginSuccessNotification {
    [TUICore callService:TUICore_TUICallingService
                  method:TUICore_TUICallingService_EnableFloatWindowMethod
                   param:@{TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow : @(TUIChatConfig.defaultConfig.enableFloatWindowForCall)}];
    [TUICore
        callService:TUICore_TUICallingService
             method:TUICore_TUICallingService_EnableMultiDeviceAbilityMethod
              param:@{
                  TUICore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility : @(TUIChatConfig.defaultConfig.enableMultiDeviceForCall)
              }];
}

- (NSString *)getDisplayString:(V2TIMMessage *)message {
    return [TUIMessageDataProvider getDisplayString:message];
}

#pragma mark - TUIServiceProtocol
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIChatService_GetDisplayStringMethod]) {
        return [self getDisplayString:param[TUICore_TUIChatService_GetDisplayStringMethod_MsgKey]];
    } else if ([method isEqualToString:TUICore_TUIChatService_SendMessageMethod]) {
        V2TIMMessage *message = [param tui_objectForKey:TUICore_TUIChatService_SendMessageMethod_MsgKey asClass:V2TIMMessage.class];
        if (message == nil) {
            return nil;
        }
        NSDictionary *userInfo = @{TUICore_TUIChatService_SendMessageMethod_MsgKey : message};
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIChatSendMessageNotification object:nil userInfo:userInfo];
    } else if ([method isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod]) {
        [param enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *_Nonnull stop) {
          if (![key isKindOfClass:NSString.class] || ![obj isKindOfClass:NSNumber.class]) {
              return;
          }
          if ([key isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod_EnableVideoCallKey]) {
              TUIChatConfig.defaultConfig.enableVideoCall = obj.boolValue;
          } else if ([key isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod_EnableAudioCallKey]) {
              TUIChatConfig.defaultConfig.enableAudioCall = obj.boolValue;
          } else if ([key isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod_EnableLinkKey]) {
              TUIChatConfig.defaultConfig.enableWelcomeCustomMessage = obj.boolValue;
          }
        }];
    } else if ([method isEqualToString:TUICore_TUIChatService_AppendCustomMessageMethod]) {
        NSMutableArray *customMessageInfo = [TUIMessageDataProvider getCustomMessageInfo];
        NSMutableArray *pluginMessageInfo = [TUIMessageDataProvider getPluginCustomMessageInfo];
        if ([param isKindOfClass:NSDictionary.class]) {
            NSString *businessID = param[BussinessID];
            NSString *cellName = param[TMessageCell_Name];
            NSString *cellDataName = param[TMessageCell_Data_Name];
            if (IS_NOT_EMPTY_NSSTRING(businessID) && IS_NOT_EMPTY_NSSTRING(cellName) && IS_NOT_EMPTY_NSSTRING(cellDataName)) {
                [customMessageInfo addObject:@{BussinessID : businessID, TMessageCell_Name : cellName, TMessageCell_Data_Name : cellDataName}];
                [pluginMessageInfo addObject:@{BussinessID : businessID, TMessageCell_Name : cellName, TMessageCell_Data_Name : cellDataName}];
            }
        }
    }

    return nil;
}

@end
