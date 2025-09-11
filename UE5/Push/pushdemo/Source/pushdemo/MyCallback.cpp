// Fill out your copyright notice in the Description page of Project Settings.


#include "MyCallback.h"

#if PLATFORM_IOS || PLATFORM_ANDROID
void DemoPushCallback::SetCallback(SuccessCallback success_cb, ErrorCallback error_cb) {
    success_callback_ = std::move(success_cb);
    error_callback_ = std::move(error_cb);
}

void DemoPushCallback::OnSuccess() {
    if (success_callback_) {
        success_callback_();
    }
}

void DemoPushCallback::OnError(int error_code, const FString &error_message) {
    if (error_callback_) {
        error_callback_(error_code, error_message);
    }
}

void DemoPushListener::SetCallback(OnRecvPushMessageCallback recv_cb, OnRevokePushMessageCallback revoke_cb, OnNotificationClickedCallback clicked_cb) {
    on_recv_message_callback_ = std::move(recv_cb);
    on_revoke_message_callback_ = std::move(revoke_cb);
    on_notification_clicked_callback_ = std::move(clicked_cb);
}

void DemoPushListener::OnRecvPushMessage(const PushMessage& message) {
//        UE_LOG(LogTemp, Warning, TEXT("Called in OnRecvPushMessage. Message title: %s, desc: %s, ext: %s, id: %s"), *message.GetTitle(), *message.GetDesc(), *message.GetExt(), *message.GetMessageID());
    if (on_recv_message_callback_) {
        on_recv_message_callback_(message);
    }
}

void DemoPushListener::OnRevokePushMessage(const FString& messageID) {
//        UE_LOG(LogTemp, Warning, TEXT("Called in OnRevokePushMessage. Message id: %s"), *messageID);
    if (on_revoke_message_callback_) {
        on_revoke_message_callback_(messageID);
    }
}

void DemoPushListener::OnNotificationClicked(const FString& ext) {
//        UE_LOG(LogTemp, Warning, TEXT("Called in OnNotificationClicked. Message ext: %s"), *ext);
    if (on_notification_clicked_callback_) {
        on_notification_clicked_callback_(ext);
    }
}
#endif



MyCallback::MyCallback()
{
}

MyCallback::~MyCallback()
{
}
