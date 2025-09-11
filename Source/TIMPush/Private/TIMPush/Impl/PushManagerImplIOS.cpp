// Copyright (c) 2025 Tencent. All rights reserved.

#include "PushManagerImpl.h"

#if PLATFORM_IOS
#include "PushSDK/PushSDK.h"
#include "TPush/TPush.h"

PushManager *PushManager::GetInstance() {
    static PushManager *unique_instance = new PushManagerImpl();
    return unique_instance;
}

PushManagerImpl::PushManagerImpl() {
    std::lock_guard<std::mutex> lock_guard(push_listener_ios_mutex_);
    push_listener_ios_map_.clear();
}

PushManagerImpl::~PushManagerImpl() {
    std::lock_guard<std::mutex> lock_guard(push_listener_ios_mutex_);
    push_listener_ios_map_.clear();
}

void PushManagerImpl::RegisterPush(int sdkAppId, const FString& appKey, PushValueCallback<FString>* callback) {
    UE_LOG(LogInit, Log, TEXT("Push registerPush"));

    // runningPlatform
    static const FString API_NAME = TEXT("setPushConfig");
    static const FString PARAM_JSON = TEXT(R"({"runningPlatform":6})");
    CallExperimentalAPI(API_NAME, (void*)*PARAM_JSON, nullptr);

    NSString *nsAppKey = [NSString stringWithUTF8String:TCHAR_TO_UTF8(*appKey)];
    [TIMPushManager registerPush:sdkAppId appKey:nsAppKey succ:^(NSData * _Nonnull deviceToken) {
        if (callback) {
            NSString *tokenString = Push::Convert::Util::Base64StringFromData(deviceToken);
            FString token = FString(tokenString);
            callback->OnSuccess(token);
        }
    } fail:^(int code, NSString * _Nonnull desc) {
        if (callback) {
            FString descString = FString(desc);
            callback->OnError(code, descString);
        }
    }];
}

void PushManagerImpl::UnRegisterPush(PushCallback* callback) {
    UE_LOG(LogInit, Log, TEXT("Push unRegisterPush"));
    [TIMPushManager unRegisterPush:^{
        if (callback) {
            callback->OnSuccess();
        }
    } fail:^(int code, NSString * _Nonnull desc) {
        if (callback) {
            FString descString = FString(desc);
            callback->OnError(code, descString);
        }
    }];
}

void PushManagerImpl::GetRegistrationID(PushValueCallback<FString>* callback) {
    UE_LOG(LogInit, Log, TEXT("Push getRegistrationID"));
    [TIMPushManager getRegistrationID:^(NSString * _Nonnull value) {
        if (callback) {
            FString valueString = FString(value);
            callback->OnSuccess(valueString);
        }
    }];
}

void PushManagerImpl::SetRegistrationID(const FString& registrationID, PushCallback* callback) {
    UE_LOG(LogInit, Log, TEXT("Push setRegistrationID"));
    NSString *nsRegistrationID = [NSString stringWithUTF8String:TCHAR_TO_UTF8(*registrationID)];
    [TIMPushManager setRegistrationID:nsRegistrationID callback:^{
        if (callback) {
            callback->OnSuccess();
        }
    }];
}

void PushManagerImpl::AddPushListener(PushListener *listener) {
    UE_LOG(LogInit, Log, TEXT("Push addPushListener"));

    if (listener == nullptr) {
        UE_LOG(LogInit, Error, TEXT("Push listener is null"));
        return;
    }

    std::lock_guard<std::mutex> lock_guard(push_listener_ios_mutex_);
    if (push_listener_ios_map_.find(listener) != push_listener_ios_map_.end()) {
        UE_LOG(LogInit, Warning, TEXT("Push listener already exists"));
        return;
    }
   
    PushListenerWrapper *listenerWrapper = [[PushListenerWrapper alloc] initWithWrapper:listener];
    if (!listenerWrapper) {
        UE_LOG(LogInit, Error, TEXT("Push failed to create PushListenerWrapper"));
        return;
    }
    
    [TIMPushManager addPushListener:listenerWrapper];
    push_listener_ios_map_.emplace(listener, listenerWrapper);
}

void PushManagerImpl::RemovePushListener(PushListener *listener) {
    UE_LOG(LogInit, Log, TEXT("Push removePushListener"));

    if (listener == nullptr) {
        UE_LOG(LogInit, Error, TEXT("Push listener is null"));
        return;
    }

    std::lock_guard<std::mutex> lock_guard(push_listener_ios_mutex_);
    auto it = push_listener_ios_map_.find(listener);
    if (it == push_listener_ios_map_.end()) {
        return;
    }

    PushListenerWrapper *listenerWrapper = it->second;
    [TIMPushManager removePushListener:listenerWrapper];
    [listenerWrapper release];
    push_listener_ios_map_.erase(it);
}

void PushManagerImpl::ForceUseFCMPushChannel(bool enable) {
    UE_LOG(LogInit, Log, TEXT("Push forceUseFCMPushChannel"));
}

void PushManagerImpl::DisablePostNotificationInForeground(bool disable) {
    UE_LOG(LogInit, Log, TEXT("Push disablePostNotificationInForeground"));
    [TIMPushManager disablePostNotificationInForeground:disable];
}

void PushManagerImpl::CallExperimentalAPI(const FString& api, void* param, PushBaseCallback* callback) {
    UE_LOG(LogInit, Log, TEXT("Push callExperimentalAPI"));
    NSString *nsApi = nil;
    NSObject *nsParam = nil;
    if (api.Equals("getNotificationExtInfo")) {
        nsApi = [NSString stringWithUTF8String:TCHAR_TO_UTF8(*api)];
    } else if (api.Equals("disableAutoRegisterPush")) {
        nsApi = [NSString stringWithUTF8String:TCHAR_TO_UTF8(*api)];
    } else if (api.Equals("setPushConfig")) {
        if (!param) {
            UE_LOG(LogInit, Error, TEXT("Push invalid param"));
            return;
        }
        nsApi = [NSString stringWithUTF8String:TCHAR_TO_UTF8(*api)];
        const TCHAR* tcharStr = static_cast<const TCHAR*>(param);
        nsParam = [NSString stringWithUTF8String:TCHAR_TO_UTF8(tcharStr)]; // FString param = "{\"businessID\" : \"123456\"}";
    } else if (api.Equals("setAppLanguage")) {
        if (!param) {
            UE_LOG(LogInit, Error, TEXT("Push invalid param"));
            return;
        }
        nsApi = [NSString stringWithUTF8String:TCHAR_TO_UTF8(*api)];
        const TCHAR* tcharStr = static_cast<const TCHAR*>(param);
        nsParam = [NSString stringWithUTF8String:TCHAR_TO_UTF8(tcharStr)];
    } else if (api.Equals("setCustomBadgeNumber")) {
        if (!param) {
            UE_LOG(LogInit, Error, TEXT("Push invalid param"));
            return;
        }
        nsApi = [NSString stringWithUTF8String:TCHAR_TO_UTF8(*api)];
        int32 intValue = *static_cast<int32*>(param);
        nsParam = [NSNumber numberWithInt:intValue];
    } else if (api.Equals("setPushToken")) {
        if (!param) {
            UE_LOG(LogInit, Error, TEXT("Push invalid param"));
            return;
        }
        nsApi = [NSString stringWithUTF8String:TCHAR_TO_UTF8(*api)];
        const TCHAR* tcharStr = static_cast<const TCHAR*>(param);
        nsParam = [NSString stringWithUTF8String:TCHAR_TO_UTF8(tcharStr)];
    } else if (api.Equals("getPushToken")) {
        nsApi = [NSString stringWithUTF8String:TCHAR_TO_UTF8(*api)];
    } else {
        UE_LOG(LogInit, Error, TEXT("Push invalid API"));
        if (callback && callback->IsValueCallback()) {
            PushValueCallback<FString> *valueCallback = reinterpret_cast<PushValueCallback<FString>*>(callback);
            valueCallback->OnError(-1, "Invalid API");
        } else if (callback) {
            PushCallback *pushcallback = reinterpret_cast<PushCallback*>(callback);
            pushcallback->OnError(-1, "Invalid API");
        } else {
            UE_LOG(LogTemp, Error, TEXT("Push invalid callback type in nativeOnError"));
        }
        return ;
    }
    
    [TIMPushManager callExperimentalAPI:nsApi param:nsParam succ:^(NSObject * _Nonnull object) {
         NSString *objectString = @"";
         if ([object isKindOfClass:NSData.class]) {
             NSData *dataObject = (NSData *)object;
             objectString = Push::Convert::Util::Base64StringFromData(dataObject);
         } else if ([object isKindOfClass:NSString.class]) {
             objectString = (NSString *) object;
         }
         if (callback) {
             FString objectFString = FString(objectString);
             if (callback->IsValueCallback()) {
                 PushValueCallback<FString> *valueCallback = reinterpret_cast<PushValueCallback<FString>*>(callback);
                 valueCallback->OnSuccess(FString(objectString));
             } else {
                 PushCallback *pushcallback = reinterpret_cast<PushCallback*>(callback);
                 pushcallback->OnSuccess();
             }
         }
        } fail:^(int code, NSString * _Nonnull desc) {
         if (callback) {
             FString descString = FString(desc);
             if (callback->IsValueCallback()) {
                 PushValueCallback<FString> *valueCallback = reinterpret_cast<PushValueCallback<FString>*>(callback);
                 valueCallback->OnError(code, descString);
             } else {
                 PushCallback *pushcallback = reinterpret_cast<PushCallback*>(callback);
                 pushcallback->OnError(code, descString);
             }
         }
    }];
}
#endif
