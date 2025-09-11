// Copyright (c) 2025 Tencent. All rights reserved.

#include "PushManagerImpl.h"

#if PLATFORM_ANDROID
#include "PushUtil.h"

PushManager *PushManager::GetInstance() {
    static PushManager *unique_instance = new PushManagerImpl();
    return unique_instance;
}

PushManagerImpl::PushManagerImpl() {
    std::lock_guard<std::mutex> lock_guard(push_listener_android_mutex_);
    push_listener_android_map_.clear();
}

PushManagerImpl::~PushManagerImpl() {
    std::lock_guard<std::mutex> lock_guard(push_listener_android_mutex_);
    push_listener_android_map_.clear();
}

void PushManagerImpl::RegisterPush(int sdkAppId, const FString& appKey, PushValueCallback<FString>* callback) {
    UE_LOG(LogInit, Log, TEXT("Push registerPush"));

    // runningPlatform
    static const FString API_NAME = TEXT("setPushConfig");
    static const FString PARAM_JSON = TEXT(R"({"runningPlatform":6})");
    CallExperimentalAPI(API_NAME, (void*)*PARAM_JSON, nullptr);

    if (JNIEnv* jenv = FAndroidApplication::GetJavaEnv()) {
        jlong ptr = 0;
        if (callback) {
            ptr = (jlong)callback;
        }

        jobject callbackObj = Push::Convert::Util::GetJavaCallback(jenv, ptr);
        if (!callbackObj) {
            UE_LOG(LogInit, Error, TEXT("Push failed to create PushCallback instance"));
            return;
        }

        jmethodID registerPushNameMethodID = FJavaWrapper::FindMethod(
            jenv, 
            FJavaWrapper::GameActivityClassID, 
            "registerPush", 
            "(ILjava/lang/String;Lcom/tencent/qcloud/tim/push/TIMPushCallback;)V", 
            false
        );

        if (!registerPushNameMethodID) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find registerPush method"));
            jenv->DeleteLocalRef(callbackObj);
            return;
        }

        jstring jAppKey = Push::Convert::Util::FStringToJString(jenv, appKey);
        FJavaWrapper::CallVoidMethod(jenv, FJavaWrapper::GameActivityThis, 
            registerPushNameMethodID, sdkAppId, jAppKey, callbackObj
        );

        jenv->DeleteLocalRef(jAppKey);
        jenv->DeleteLocalRef(callbackObj);
    }
}

void PushManagerImpl::UnRegisterPush(PushCallback* callback) {
    UE_LOG(LogInit, Log, TEXT("Push unRegisterPush"));
    if (JNIEnv* jenv = FAndroidApplication::GetJavaEnv()) {
        jlong ptr = 0;
        if (callback) {
            ptr = (jlong)callback;
        }

        jobject callbackObj = Push::Convert::Util::GetJavaCallback(jenv, ptr);
        if (!callbackObj) {
            UE_LOG(LogInit, Error, TEXT("Push failed to create PushCallback instance"));
            return;
        }

        jmethodID unRegisterPushNameMethodID = FJavaWrapper::FindMethod(
            jenv, 
            FJavaWrapper::GameActivityClassID, 
            "unRegisterPush", 
            "(Lcom/tencent/qcloud/tim/push/TIMPushCallback;)V", 
            false
        );
        if (!unRegisterPushNameMethodID) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find unRegisterPush method"));
            jenv->DeleteLocalRef(callbackObj);
            return;
        }

        FJavaWrapper::CallVoidMethod(jenv, FJavaWrapper::GameActivityThis, 
            unRegisterPushNameMethodID, callbackObj
        );

        jenv->DeleteLocalRef(callbackObj);
    }
}

void PushManagerImpl::GetRegistrationID(PushValueCallback<FString>* callback) {
    UE_LOG(LogInit, Log, TEXT("Push getRegistrationID"));
    if (JNIEnv* jenv = FAndroidApplication::GetJavaEnv()) {
        jlong ptr = 0;
        if (callback) {
            ptr = (jlong)callback;
        }

        jobject callbackObj = Push::Convert::Util::GetJavaCallback(jenv, ptr);
        if (!callbackObj) {
            UE_LOG(LogInit, Error, TEXT("Push failed to create PushCallback instance"));
            return;
        }

        jmethodID getRegistrationIDNameMethodID = FJavaWrapper::FindMethod(
            jenv, 
            FJavaWrapper::GameActivityClassID, 
            "getRegistrationID", 
            "(Lcom/tencent/qcloud/tim/push/TIMPushCallback;)V", 
            false
        );

        if (!getRegistrationIDNameMethodID) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find getRegistrationID method"));
            jenv->DeleteLocalRef(callbackObj);
            return;
        }

        FJavaWrapper::CallVoidMethod(jenv, FJavaWrapper::GameActivityThis, 
            getRegistrationIDNameMethodID, callbackObj
        );

        jenv->DeleteLocalRef(callbackObj);
    }
}

void PushManagerImpl::SetRegistrationID(const FString& registrationID, PushCallback* callback) {
    UE_LOG(LogInit, Log, TEXT("Push setRegistrationID"));
    if (JNIEnv* jenv = FAndroidApplication::GetJavaEnv()) {
        jlong ptr = 0;
        if (callback) {
            ptr = (jlong)callback;
        }

        jobject callbackObj = Push::Convert::Util::GetJavaCallback(jenv, ptr);
        if (!callbackObj) {
            UE_LOG(LogInit, Error, TEXT("Push failed to create PushCallback instance"));
            return;
        }

        jmethodID setRegistrationIDNameMethodID = FJavaWrapper::FindMethod(
            jenv, 
            FJavaWrapper::GameActivityClassID, 
            "setRegistrationID",
            "(Ljava/lang/String;Lcom/tencent/qcloud/tim/push/TIMPushCallback;)V", 
            false
        );

        if (!setRegistrationIDNameMethodID) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find setRegistrationID method"));
            jenv->DeleteLocalRef(callbackObj);
            return;
        }

        jstring jRegistrationID = Push::Convert::Util::FStringToJString(jenv, registrationID);
        FJavaWrapper::CallVoidMethod(jenv, FJavaWrapper::GameActivityThis, 
            setRegistrationIDNameMethodID, jRegistrationID, callbackObj
        );

        jenv->DeleteLocalRef(jRegistrationID);
        jenv->DeleteLocalRef(callbackObj);
    }
}

void PushManagerImpl::AddPushListener(PushListener *listener) {
    UE_LOG(LogInit, Log, TEXT("Push addPushListener"));

    if (listener == nullptr) {
        UE_LOG(LogInit, Error, TEXT("Push listener is null"));
        return;
    }

    if (JNIEnv* jenv = FAndroidApplication::GetJavaEnv()) {
        std::lock_guard<std::mutex> lock_guard(push_listener_android_mutex_);
        if (push_listener_android_map_.find(listener) != push_listener_android_map_.end()) {
            UE_LOG(LogInit, Warning, TEXT("Push listener already exists"));
            return;
        }

        jobject listenerObj = Push::Convert::Util::GetJavaListener(jenv, (jlong)listener);
        if (!listenerObj) {
            UE_LOG(LogInit, Error, TEXT("Push failed to create PushListener instance"));
            return;
        }

        jmethodID addPushListenerNameMethodID = FJavaWrapper::FindMethod(
            jenv, 
            FJavaWrapper::GameActivityClassID, 
            "addPushListener", 
            "(Lcom/tencent/qcloud/tim/push/TIMPushListener;)V", 
            false
        );
    
        if (!addPushListenerNameMethodID) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find addPushListener method"));
            jenv->DeleteLocalRef(listenerObj);
            return;
        }
    
        FJavaWrapper::CallVoidMethod(
            jenv, 
            FAndroidApplication::GetGameActivityThis(), 
            addPushListenerNameMethodID, 
            listenerObj
        );

        push_listener_android_map_.emplace(listener, listenerObj);
    }
}

void PushManagerImpl::RemovePushListener(PushListener *listener) {
    UE_LOG(LogInit, Log, TEXT("Push removePushListener"));

    if (listener == nullptr) {
        UE_LOG(LogInit, Error, TEXT("Push listener is null"));
        return;
    }

    if (JNIEnv* jenv = FAndroidApplication::GetJavaEnv()) {
        std::lock_guard<std::mutex> lock_guard(push_listener_android_mutex_);
        const auto it = push_listener_android_map_.find(listener);
        if (it == push_listener_android_map_.end()) {
            UE_LOG(LogInit, Warning, TEXT("Push listener not found in map"));
            return;
        }

        jobject listenerObj = it->second;
        if (!listenerObj) {
            UE_LOG(LogInit, Error, TEXT("Push invalid listener object"));
            push_listener_android_map_.erase(it);
            return;
        }

        jmethodID removePushListenerNameMethodID = FJavaWrapper::FindMethod(
            jenv, 
            FJavaWrapper::GameActivityClassID, 
            "removePushListener",
            "(Lcom/tencent/qcloud/tim/push/TIMPushListener;)V", 
            false
        );
    
        if (!removePushListenerNameMethodID) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find removePushListener method"));
            jenv->DeleteLocalRef(listenerObj);
            push_listener_android_map_.erase(it);
            return;
        }
    
        FJavaWrapper::CallVoidMethod(
            jenv, 
            FAndroidApplication::GetGameActivityThis(), 
            removePushListenerNameMethodID, 
            listenerObj
        );

        push_listener_android_map_.erase(it);
        jenv->DeleteLocalRef(listenerObj);
    }
}

void PushManagerImpl::ForceUseFCMPushChannel(bool enable) {
    UE_LOG(LogInit, Log, TEXT("Push forceUseFCMPushChannel"));
    if (JNIEnv* jenv = FAndroidApplication::GetJavaEnv()) {
        jmethodID forceUseFCMPushChannelMethodID = FJavaWrapper::FindMethod(
            jenv, 
            FJavaWrapper::GameActivityClassID, 
            "forceUseFCMPushChannel", 
            "(Z)V", 
            false
        );
    
        if (!forceUseFCMPushChannelMethodID) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find forceUseFCMPushChannel method"));
            return;
        }
    
        FJavaWrapper::CallVoidMethod(
            jenv, 
            FAndroidApplication::GetGameActivityThis(), 
            forceUseFCMPushChannelMethodID, 
            enable
        );
    }
}

void PushManagerImpl::DisablePostNotificationInForeground(bool disable) {
    UE_LOG(LogInit, Log, TEXT("Push disablePostNotificationInForeground"));
    if (JNIEnv* jenv = FAndroidApplication::GetJavaEnv()) {
        jmethodID disablePostNotificationInForegroundMethodID = FJavaWrapper::FindMethod(
            jenv, 
            FJavaWrapper::GameActivityClassID, 
            "disablePostNotificationInForeground", 
            "(Z)V", 
            false
        );
    
        if (!disablePostNotificationInForegroundMethodID) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find disablePostNotificationInForeground method"));
            return;
        }
    
        FJavaWrapper::CallVoidMethod(
            jenv, 
            FAndroidApplication::GetGameActivityThis(), 
            disablePostNotificationInForegroundMethodID, 
            disable
        );
    }
}

void PushManagerImpl::CallExperimentalAPI(const FString& api, void* param, PushBaseCallback* callback) {
    UE_LOG(LogInit, Log, TEXT("callExperimentalAPI"));
    if (JNIEnv* jenv = FAndroidApplication::GetJavaEnv()) {
        jlong ptr = 0;
        if (callback) {
            ptr = (jlong)callback;
        }

        jobject jCallbackObj = Push::Convert::Util::GetJavaCallback(jenv, ptr);
        if (!jCallbackObj) {
            UE_LOG(LogInit, Error, TEXT("Push failed to create PushCallback instance"));
            return;
        }

        jstring jApi = Push::Convert::Util::FStringToJString(jenv, api);
        jobject jParamObj = nullptr;
        if (api == TEXT("setAppLanguage") 
                || api == TEXT("setPushToken") 
                || api == TEXT("createNotificationChannel")
                || api == TEXT("setPushConfig")) {
            if (!param) {
                UE_LOG(LogInit, Error, TEXT("Push invalid param"));
                return;
            }
            jParamObj = Push::Convert::Util::FStringVoidPtrToJString(jenv, param);;
        } else if (api == TEXT("disableRequestPostNotificationPermission") || api == TEXT("disableAutoRegisterPush")) {
            if (!param) {
                UE_LOG(LogInit, Error, TEXT("Push invalid param"));
                return;
            }
            bool boolParam = *(bool*)param; 
            jclass booleanClass = jenv->FindClass("java/lang/Boolean");
            if (!booleanClass) {
                UE_LOG(LogInit, Error, TEXT("booleanClass is null"));
                return;
            }
            jmethodID booleanCtor = jenv->GetMethodID(booleanClass, "<init>", "(Z)V");
            if (!booleanCtor) {
                UE_LOG(LogInit, Error, TEXT("booleanCtor is null"));
                return;
            }
            jParamObj = jenv->NewObject(booleanClass, booleanCtor, boolParam ? JNI_TRUE : JNI_FALSE);
        } else if (api == TEXT("setCustomBadgeNumber")) {
            if (!param) {
                UE_LOG(LogInit, Error, TEXT("Push invalid param"));
                return;
            }
            int intParam = *(int*)param;
            jint jintParam = static_cast<jint>(intParam);
            jclass integerClass = jenv->FindClass("java/lang/Integer");
            if (!integerClass) {
                UE_LOG(LogInit, Error, TEXT("integerClass is null"));
                return;
            }
            jmethodID integerCtor = jenv->GetMethodID(integerClass, "<init>", "(I)V");
            if (!integerCtor) {
                UE_LOG(LogInit, Error, TEXT("integerCtor is null"));
                return;
            }
            jParamObj = jenv->NewObject(integerClass, integerCtor, jintParam);
        } else if (api == TEXT("getPushToken") || api == TEXT("getPushChannelId")) {
            jParamObj = nullptr;
        } else {
            UE_LOG(LogInit, Error, TEXT("Push invalid API"));
            if (callback && callback->IsValueCallback()) {
                PushValueCallback<FString>* valueCallback = reinterpret_cast<PushValueCallback<FString>*>(callback);
                valueCallback->OnError(-1, "Invalid API");
            } else if (callback) {
                PushCallback* pushcallback = reinterpret_cast<PushCallback*>(callback);
                pushcallback->OnError(-1, "Invalid API");
            } else {
                UE_LOG(LogTemp, Error, TEXT("Push invalid callback type in nativeOnError"));
            }
            return;
        }

        jmethodID callExperimentalAPIMethodID = FJavaWrapper::FindMethod(
            jenv, 
            FJavaWrapper::GameActivityClassID, 
            "callExperimentalAPI",
            "(Ljava/lang/String;Ljava/lang/Object;Lcom/tencent/qcloud/tim/push/TIMPushCallback;)V", 
            false
        );

        if (!callExperimentalAPIMethodID) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find callExperimentalAPI method"));
            return;
        }

        FJavaWrapper::CallVoidMethod(
            jenv, 
            FAndroidApplication::GetGameActivityThis(), 
            callExperimentalAPIMethodID, 
            jApi, jParamObj, jCallbackObj
        );

        jenv->DeleteLocalRef(jApi);
        jenv->DeleteLocalRef(jParamObj);
        jenv->DeleteLocalRef(jCallbackObj);          
    }
}
#endif