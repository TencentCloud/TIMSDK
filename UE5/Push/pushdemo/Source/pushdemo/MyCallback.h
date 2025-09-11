// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

#if PLATFORM_IOS || PLATFORM_ANDROID
#include "TIMPush.h"
class DemoPushCallback : public PushCallback {
public:
    using SuccessCallback = std::function<void()>;
    using ErrorCallback = std::function<void(int, const FString &)>;
    
    DemoPushCallback() = default;
    ~DemoPushCallback() override = default;
    
    void SetCallback(SuccessCallback success_cb, ErrorCallback error_cb);
    
    void OnSuccess() override;
    void OnError(int error_code, const FString &error_message) override;
    
private:
    SuccessCallback success_callback_;
    ErrorCallback error_callback_;
};

template <class T>
class DemoPushValueCallback : public PushValueCallback<T> {
public:
    using SuccessCallback = std::function<void(const T &)>;
    using ErrorCallback = std::function<void(int, const FString &)>;
    
    DemoPushValueCallback<T>() = default;
    ~DemoPushValueCallback() override = default;
    
    void SetCallback(SuccessCallback success_cb, ErrorCallback error_cb);
    
    void OnSuccess(const T &value) override;
    void OnError(int error_code, const FString &error_message) override;
    
private:
    SuccessCallback success_callback_;
    ErrorCallback error_callback_;
};

class DemoPushListener: public PushListener {
public:
    using OnRecvPushMessageCallback = std::function<void(const PushMessage &)>;
    using OnRevokePushMessageCallback = std::function<void(const FString &)>;
    using OnNotificationClickedCallback = std::function<void(const FString &)>;
    
    void SetCallback(OnRecvPushMessageCallback recv_cb, OnRevokePushMessageCallback revoke_cb, OnNotificationClickedCallback clicked_cb);
    
    void OnRecvPushMessage(const PushMessage& message) override;
    void OnRevokePushMessage(const FString& messageID) override;
    void OnNotificationClicked(const FString& ext) override;
    
private:
    OnRecvPushMessageCallback on_recv_message_callback_;
    OnRevokePushMessageCallback on_revoke_message_callback_;
    OnNotificationClickedCallback on_notification_clicked_callback_;
};

template <class T>
void DemoPushValueCallback<T>::SetCallback(SuccessCallback success_cb, ErrorCallback error_cb) {
    success_callback_ = std::move(success_cb);
    error_callback_ = std::move(error_cb);
}

template <class T>
void DemoPushValueCallback<T>::OnSuccess(const T &value) {
    if (success_callback_) {
        success_callback_(value);
    }
}

template <class T>
void DemoPushValueCallback<T>::OnError(int error_code, const FString &error_message) {
    if (error_callback_) {
        error_callback_(error_code, error_message);
    }
}

#endif

/**
 * 
 */
class PUSHDEMO_API MyCallback
{
public:
	MyCallback();
	~MyCallback();
};
