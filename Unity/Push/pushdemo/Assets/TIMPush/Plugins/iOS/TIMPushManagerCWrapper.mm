//
// Copyright (c) 2025 Tencent. All rights reserved.

#import "TIMPushManagerCWrapper.h"
#import "TPush/TPush.h"
#import <Foundation/Foundation.h>

@interface TIMPushListenerBridge : NSObject <TIMPushListener>
@property (nonatomic, assign) CTIMPushMessageCallback messageCallback;
@property (nonatomic, assign) CTIMPushRevokeCallback revokeCallback;
@property (nonatomic, assign) CTIMPushNotificationClickedCallback clickedCallback;
@end

@implementation TIMPushListenerBridge

- (void)onRecvPushMessage:(TIMPushMessage *)message {
    if (self.messageCallback) {
        // 转换为JSON字符串
        NSDictionary *dict = @{
            @"title": message.title ?: @"",
            @"desc": message.desc ?: @"",
            @"ext": message.ext ?: @"",
            @"messageID": message.messageID ?: @""
        };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.messageCallback([jsonStr UTF8String]);
    }
}

- (void)onRevokePushMessage:(NSString *)messageID {
    if (self.revokeCallback) {
        self.revokeCallback(messageID ? [messageID UTF8String] : "");
    }
}

- (void)onNotificationClicked:(NSString *)ext {
    if (self.clickedCallback) {
        self.clickedCallback(ext ? [ext UTF8String] : "");
    }
}

@end


static TIMPushListenerBridge *g_listener = nil;

NSString* Base64StringFromData(NSData *deviceToken)
{
    if (deviceToken == nil) {
        return @"";
    }
    
    const char *data = (const char*)([deviceToken bytes]);
    NSMutableString *token = [NSMutableString string];
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat : @"%02.2hhX", data[i]];
    }
    return token;
}

void TIMRegisterPush(int sdkAppId, const char *appKey,
                     CTIMPushSuccessCallback successCallback,
                     CTIMPushFailedCallback failedCallback, const char *userData) {
  NSString *ocAppKey = appKey ? [NSString stringWithUTF8String:appKey] : nil;

  [TIMPushManager registerPush:sdkAppId
      appKey:ocAppKey
      succ:^(NSData *deviceToken) {
        if (successCallback) {
          NSString *tokenStr = deviceToken ? Base64StringFromData(deviceToken) : @"";
          successCallback([tokenStr UTF8String], userData);
        }
      }
      fail:^(int code, NSString *desc) {
        if (failedCallback) {
          failedCallback(code, desc ? [desc UTF8String] : "", userData);
        }
      }];
}

void TIMUnRegisterPush(CTIMPushSuccessCallback successCallback,
                       CTIMPushFailedCallback failedCallback, const char *userData) {
  [TIMPushManager unRegisterPush:^{
        if (successCallback) {
          successCallback("", userData);
        }
      }
      fail:^(int code, NSString *desc) {
        if (failedCallback) {
          failedCallback(code, desc ? [desc UTF8String] : "", userData);
        }
      }];
}

void TIMGetRegistrationID(CTIMPushSuccessCallback callback,  const char *userData) {
  [TIMPushManager getRegistrationID:^(NSString *value) {
    if (callback) {
      callback(value ? [value UTF8String] : "",  userData);
    }
  }];
}

void TIMSetRegistrationID(const char *registrationID,
                          CTIMPushSuccessCallback callback, const char *userData) {
  NSString *id =
      registrationID ? [NSString stringWithUTF8String:registrationID] : nil;

  [TIMPushManager setRegistrationID:id
                           callback:^{
                             if (callback) {
                               callback("",  userData);
                             }
                           }];
}

void TIMDisablePostNotificationInForeground(int disable) {
  [TIMPushManager disablePostNotificationInForeground:disable];
}

void TIMAddPushListener(
    CTIMPushMessageCallback messageCallback,
    CTIMPushRevokeCallback revokeCallback,
    CTIMPushNotificationClickedCallback clickedCallback) {
    if (!g_listener) {
      g_listener = [[TIMPushListenerBridge alloc] init];
    }

    g_listener.messageCallback = messageCallback;
    g_listener.revokeCallback = revokeCallback;
    g_listener.clickedCallback = clickedCallback;

    [TIMPushManager addPushListener:g_listener];
}

void TIMRemovePushListener(void) {
  if (g_listener) {
    [TIMPushManager removePushListener:g_listener];
  }
}

void TIMCallExperimentalAPI(const char *api, const char *paramStr, int paramInt,
                            CTIMPushSuccessCallback successCallback, CTIMPushFailedCallback failedCallback,
                            const char *userData) {
    NSString *ocApi = api ? [NSString stringWithUTF8String:api] : nil;
    NSString *ocParamStr = paramStr ? [NSString stringWithUTF8String:paramStr] : nil;
    NSNumber *ocParamInt = @(paramInt);

    [TIMPushManager callExperimentalAPI:ocApi
      param: ocParamStr ? ocParamStr : ocParamInt
      succ:^(NSObject *result) {
        if (successCallback) {
          NSString *resultStr = [result isKindOfClass:[NSString class]] ? (NSString *)result : @"";
          successCallback([resultStr UTF8String], userData);
        }
      }
      fail:^(int code, NSString *desc) {
        if (failedCallback) {
          failedCallback(code, desc ? [desc UTF8String] : "", userData);
        }
      }];

}
