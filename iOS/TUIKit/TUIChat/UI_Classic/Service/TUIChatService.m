
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUIChatService.h"
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIChatConfig.h"
#import "TUIChatDefine.h"
#import "TUIMessageCellConfig.h"
#import "TUIBaseMessageController.h"

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
    return [TUIBaseMessageController getDisplayString:message];
}

- (void)asyncGetDisplayString:(NSArray<V2TIMMessage *> *)messageList callback:(TUICallServiceResultCallback)resultCallback {
  if (resultCallback == nil) {
    return;
  }

  [TUIBaseMessageController asyncGetDisplayString:messageList callback:^(NSDictionary<NSString *,NSString *> * result) {
    resultCallback(0, @"", result);
  }];
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
    } else if ([method isEqualToString:TUICore_TUIChatService_SendMessageMethodWithoutUpdateUI]) {
        V2TIMMessage *message = [param tui_objectForKey:TUICore_TUIChatService_SendMessageMethodWithoutUpdateUI_MsgKey asClass:V2TIMMessage.class];
        if (message == nil) {
            return nil;
        }
        NSDictionary *userInfo = @{TUICore_TUIChatService_SendMessageMethodWithoutUpdateUI_MsgKey : message};
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIChatSendMessageWithoutUpdateUINotification object:nil userInfo:userInfo];
    } else if ([method isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod]) {
        [param enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *_Nonnull stop) {
          if (![key isKindOfClass:NSString.class] || ![obj isKindOfClass:NSNumber.class]) {
              return;
          }
        }];
    } else if ([method isEqualToString:TUICore_TUIChatService_AppendCustomMessageMethod]) {
        if ([param isKindOfClass:NSDictionary.class]) {
            NSString *businessID = param[BussinessID];
            NSString *cellName = param[TMessageCell_Name];
            NSString *cellDataName = param[TMessageCell_Data_Name];
            [TUIMessageCellConfig registerCustomMessageCell:cellName messageCellData:cellDataName forBusinessID:businessID isPlugin:YES];
        }
    }
    else if ([method isEqualToString:TUICore_TUIChatService_SetMaxTextSize]) {
        if ([param isKindOfClass:NSDictionary.class]) {
            CGSize sizeVa = [param[@"maxsize"] CGSizeValue];
            [TUIMessageCellConfig setMaxTextSize:sizeVa];
        }
    }

    return nil;
}

- (id)onCall:(NSString *)method param:(NSDictionary *)param resultCallback:(TUICallServiceResultCallback)resultCallback {
  if ([method isEqualToString:TUICore_TUIChatService_AsyncGetDisplayStringMethod]) {
    NSArray *messageList = param[TUICore_TUIChatService_AsyncGetDisplayStringMethod_MsgListKey];
    [self asyncGetDisplayString:messageList callback:resultCallback];
    return nil;
  }
  return nil;
}

@end
