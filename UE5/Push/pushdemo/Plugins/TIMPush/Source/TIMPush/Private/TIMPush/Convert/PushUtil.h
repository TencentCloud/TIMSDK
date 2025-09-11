// Copyright (c) 2025 Tencent. All rights reserved.


#ifndef PUSH_UTIL_ANDROID_H__
#define PUSH_UTIL_ANDROID_H__

#include "Core.h"

#include "Interfaces/IPluginManager.h"
#include "Misc/Paths.h"
#include "HAL/PlatformProcess.h"

#if PLATFORM_ANDROID
#include "Android/AndroidJava.h"
#include "Android/AndroidJavaEnv.h"
#include "Android/AndroidJNI.h"
#include "Android/AndroidApplication.h"
#elif PLATFORM_IOS
#import <objc/runtime.h>
#include "TPush/TPush.h"
#include "PushListener.h"
#endif

namespace Push {
namespace Convert {
namespace Util {
#if PLATFORM_ANDROID
    std::string FStringToStdString(const FString& fstr);
    FString StdStringToFString(const std::string& str);
    FString JStringToFString(JNIEnv* jenv, jstring jstr);
    jstring FStringToJString(JNIEnv* jenv, const FString& fstr);
    jstring FStringVoidPtrToJString(JNIEnv* Env, void* Param);
    jobject GetJavaCallback(JNIEnv* jenv, jlong ptr);
    jobject GetJavaListener(JNIEnv* jenv, jlong ptr);

#elif PLATFORM_IOS
    NSString* Base64StringFromData(NSData *deviceToken);
#endif
}  // namespace Util
}  // namespace Convert
}  // namespace Push

#if PLATFORM_IOS
@interface PluginNotificationHandler : NSObject
    + (void) load;
    + (void) swizzleNotification;
    - (void) swizzled_userNotificationCenter: (UNUserNotificationCenter *)center
                       willPresentNotification: (UNNotification *)notification
                       withCompletionHandler: (void (^)(UNNotificationPresentationOptions options)) completionHandler;
@end

@interface PushListenerWrapper : NSObject<TIMPushListener>
    @property (nonatomic) PushListener *wrapper;
    - (instancetype) initWithWrapper:(PushListener*)wrapper;
@end

#endif
#endif  // PUSH_UTIL_ANDROID_H__
