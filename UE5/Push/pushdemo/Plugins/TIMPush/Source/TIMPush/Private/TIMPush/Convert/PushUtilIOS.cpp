// Copyright (c) 2025 Tencent. All rights reserved.
#if PLATFORM_IOS
#include "PushUtil.h"

#include "PushListener.h"
#include "PushMessage.h"
#include "PushCallback.h"
#include <string>


@implementation PluginNotificationHandler
+ (void) load {
    [self swizzleNotification];
}

+ (void) swizzleNotification {
    Class iosAppDelegateClass = NSClassFromString(@"IOSAppDelegate");
    if (!iosAppDelegateClass) {
        // if not exist
        return ;
    }
    Method originalMethod = class_getInstanceMethod(iosAppDelegateClass, @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(swizzled_userNotificationCenter:willPresentNotification:withCompletionHandler:));
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void) swizzled_userNotificationCenter: (UNUserNotificationCenter *)center
                   willPresentNotification: (UNNotification *)notification
                   withCompletionHandler: (void (^)(UNNotificationPresentationOptions options)) completionHandler {
    // get the contents
    NSString *identifier = notification.request.identifier;
    // if it's in foreground
    BOOL isLoaclNotification = [identifier hasPrefix:@"TIMPushLocalNotification"] ;
    // set the alert and sound in foreground
    if (completionHandler && isLoaclNotification ) {
        completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    }
}
@end

@implementation PushListenerWrapper
- (instancetype) initWithWrapper:(PushListener *)wrapper {
    self = [super init];
    if (self) {
        self.wrapper = wrapper;
    }
    return self;
}

// message 来自于底层 SDK
- (void) onRecvPushMessage:(TIMPushMessage *)message {
    if (self.wrapper) {
        PushMessage fMessage = PushMessage(FString(message.title), FString(message.desc), FString(message.ext), FString(message.messageID));
        self.wrapper->OnRecvPushMessage(fMessage);
    }
}

- (void) onRevokePushMessage:(NSString *)messageID {
    if (self.wrapper) {
        FString fMessageID = FString(messageID);
        self.wrapper->OnRevokePushMessage(fMessageID);
    }
}

- (void) onNotificationClicked:(NSString *)ext {
    if (self.wrapper) {
        FString fExt = FString(ext);
        self.wrapper->OnNotificationClicked(fExt);
    }
}
@end

namespace Push {
namespace Convert {
namespace Util {
    // convert NSData to NSString
    NSString* Base64StringFromData(NSData *deviceToken)
    {
        if (deviceToken == nil) {
            UE_LOG(LogTemp, Warning, TEXT("Push token is nil"));
            return @"";
        }
    
        const char *data = (const char*)([deviceToken bytes]);
        NSMutableString *token = [NSMutableString string];
        for (NSUInteger i = 0; i < [deviceToken length]; i++) {
            [token appendFormat : @"%02.2hhX", data[i]];
        }
        return token;
    }
}  // namespace Util
}  // namespace Convert
}  // namespace Push

#endif  // PLATFORM_IOS
