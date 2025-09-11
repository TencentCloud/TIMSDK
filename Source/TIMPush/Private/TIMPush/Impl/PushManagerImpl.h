// Copyright (c) 2025 Tencent. All rights reserved.


#ifndef PUSH_MANAGER_IMPL_H__
#define PUSH_MANAGER_IMPL_H__

#include "PushManager.h"
#include <unordered_map>
#include <mutex>

#if PLATFORM_ANDROID
#include "Android/AndroidJava.h"
#include "Android/AndroidJavaEnv.h"
#include "Android/AndroidJNI.h"
#include "Android/AndroidApplication.h"
#elif PLATFORM_IOS
#include "PushUtil.h"
#endif


class PushManagerImpl final: public PushManager {
public:
    PushManagerImpl();
    PushManagerImpl(const PushManagerImpl &) = delete;
    PushManagerImpl &operator=(const PushManagerImpl &) = delete;
    ~PushManagerImpl() override;

    void RegisterPush(int sdkAppId, const FString& appKey, PushValueCallback<FString>* callback) override;
    void UnRegisterPush(PushCallback* callback) override;
    void GetRegistrationID(PushValueCallback<FString>* callback) override;
    void SetRegistrationID(const FString& registrationID, PushCallback* callback) override;

    void AddPushListener(PushListener *listener) override;
    void RemovePushListener(PushListener *listener) override;

    void ForceUseFCMPushChannel(bool enable) override;
    void DisablePostNotificationInForeground(bool disable) override;

    void CallExperimentalAPI(const FString& api, void* param, PushBaseCallback* callback) override;

private:
#if PLATFORM_ANDROID
    std::unordered_map<PushListener*, jobject> push_listener_android_map_;
    std::mutex push_listener_android_mutex_;
#elif PLATFORM_IOS
    std::unordered_map<PushListener*, PushListenerWrapper*> push_listener_ios_map_;
    std::mutex push_listener_ios_mutex_;
#endif
};

#endif // PUSH_MANAGER_IMPL_H__
