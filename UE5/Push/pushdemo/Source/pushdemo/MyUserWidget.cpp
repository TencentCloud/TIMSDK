// Fill out your copyright notice in the Description page of Project Settings.


#include "MyUserWidget.h"

#if PLATFORM_IOS || PLATFORM_ANDROID
static auto DEMO_PUSH_LISTENER = DemoPushListener();
#endif

void UMyUserWidget::CallRegisterPush() {
#if PLATFORM_IOS || PLATFORM_ANDROID
    int appID = 11111111;// 您的 SDKAPPID
    FString appKey = "xxxxxxxx"; // 您的 SDKAPPID 对应的 AppKey
    auto callback = new DemoPushValueCallback<FString>();
    callback->SetCallback(
        [=](const FString &value) {
          UE_LOG(LogTemp, Warning, TEXT("Push succeed, device token is %s"), *value);
          delete callback;
        },
        [=](int error_code, const FString &error_message) {
          UE_LOG(LogTemp, Warning, TEXT("Push failed error code: %d, desc: %s"), error_code, *error_message);
          delete callback;
        }
    );
    PushManager::GetInstance()->RegisterPush(appID, appKey, callback);
    GLog->Flush();
#endif
}

void UMyUserWidget::CallUnregisterPush() {
#if PLATFORM_IOS || PLATFORM_ANDROID
    auto callback = new DemoPushCallback();
    callback->SetCallback(
        [=]() {
          UE_LOG(LogTemp, Warning, TEXT("Push unregister succeed"));
          delete callback;
        },
        [=](int error_code, const FString &error_message) {
          UE_LOG(LogTemp, Warning, TEXT("Push failed error code: %d, desc: %s"), error_code, *error_message);
          delete callback;
        }
    );
    PushManager::GetInstance()->UnRegisterPush(callback);
    GLog->Flush();
#endif
}

void UMyUserWidget::CallGetRegistrationID() {
#if PLATFORM_IOS || PLATFORM_ANDROID
    auto callback = new DemoPushValueCallback<FString>();
    callback->SetCallback(
        [=](const FString &value) {
            UE_LOG(LogTemp, Warning, TEXT("Push registration ID: %s"), *value);
            delete callback;
        },
        [=](int error_code, const FString &error_message) {
            UE_LOG(LogTemp, Warning, TEXT("Push failed error code: %d, desc: %s"), error_code, *error_message);
            delete callback;
        });
    PushManager::GetInstance()->GetRegistrationID(callback);
    GLog->Flush();
#endif
}

void UMyUserWidget::CallSetRegistrationID() {
#if PLATFORM_IOS || PLATFORM_ANDROID
    FString registrationID = "bernie";
    auto callback = new DemoPushCallback();
    callback->SetCallback(
        [=]() {
          UE_LOG(LogTemp, Warning, TEXT("Push succeed"));
          delete callback;
        },
        [=](int error_code, const FString &error_message) {
          UE_LOG(LogTemp, Warning, TEXT("Push failed error code: %d, desc: %s"), error_code, *error_message);
          delete callback;
        }
    );
    PushManager::GetInstance()->SetRegistrationID(registrationID, callback);
    GLog->Flush();
#endif
}

void UMyUserWidget::CallAddPushListener() {
#if PLATFORM_IOS || PLATFORM_ANDROID
    DEMO_PUSH_LISTENER.SetCallback(
        [](const PushMessage& message) {
            UE_LOG(LogTemp, Warning, TEXT("Push Called in OnRecvPushMessage. Message title: %s, desc: %s, ext: %s, id: %s"), *message.GetTitle(), *message.GetDesc(), *message.GetExt(), *message.GetMessageID());
        },
        [](const FString& messageID) {
            UE_LOG(LogTemp, Warning, TEXT("Push Called in OnRevokePushMessage. Message id: %s"), *messageID);
        },
        [](const FString& ext) {
            UE_LOG(LogTemp, Warning, TEXT("Push Called in OnNotificationClicked. Message ext: %s"), *ext);
        }
    );
    PushManager::GetInstance()->AddPushListener(&DEMO_PUSH_LISTENER);
    GLog->Flush();
#endif
}

void UMyUserWidget::CallRemovePushListener() {
#if PLATFORM_IOS || PLATFORM_ANDROID
    PushManager::GetInstance()->RemovePushListener(&DEMO_PUSH_LISTENER);
    GLog->Flush();
#endif
}

void UMyUserWidget::CallForceUseFCMPushChannel() {
#if PLATFORM_ANDROID
    PushManager::GetInstance()->ForceUseFCMPushChannel(true);
    GLog->Flush();
#endif
}

void UMyUserWidget::CallDisablePostNotificationInForeground() {
#if PLATFORM_IOS || PLATFORM_ANDROID
    PushManager::GetInstance()->DisablePostNotificationInForeground(true);
    GLog->Flush();
#endif
}

void UMyUserWidget::CallExperimentalAPI() {
#if PLATFORM_IOS || PLATFORM_ANDROID
    // // setAppLanguage
    // FString api = "setAppLanguage";
    // FString param = "en";
    // const TCHAR* CharPtr = *param;
    // void* paramPtr = (void*)(CharPtr);
    // auto callback = new DemoPushCallback();
    // callback->SetCallback(
    //     [=]() {
    //       UE_LOG(LogTemp, Warning, TEXT("Push Succeed"));
    //       delete callback;
    //     },
    //     [=](int error_code, const FString &error_message) {
    //       UE_LOG(LogTemp, Warning, TEXT("Push failed error code: %d, desc: %s"), error_code, *error_message);
    //       delete callback;
    //     }
    // );
    // PushManager::GetInstance()->CallExperimentalAPI(api, paramPtr, callback);

    // // setPushToken
    // FString api1 = "setPushToken";
    // FString param1 = TEXT(R"({"token":"token"})");
    // const TCHAR* CharPtr1 = *param1;
    // void* paramPtr1 = (void*)(CharPtr1);
    // auto callback1 = new DemoPushValueCallback<FString>();
    // callback1->SetCallback(
    //     [=](const FString &value) {
    //       UE_LOG(LogTemp, Warning, TEXT("Push Succeed 1 token:%s"), *value);
    //       delete callback1;
    //     },
    //     [=](int error_code, const FString &error_message) {
    //       UE_LOG(LogTemp, Warning, TEXT("Push failed 1 error code: %d, desc: %s"), error_code, *error_message);
    //       delete callback1;
    //     }
    // );
    // PushManager::GetInstance()->CallExperimentalAPI(api1, paramPtr1, callback1);

    // // setPushConfig
    // FString api2 = "setPushConfig";
    // FString param2 = TEXT(R"({"runningPlatform":2,"customConfigFile":"customConfigFile"})");
    // const TCHAR* CharPtr2 = *param2;
    // void* paramPtr2 = (void*)(CharPtr2);
    // auto callback2 = new DemoPushCallback();
    // callback2->SetCallback(
    //     [=]() {
    //       UE_LOG(LogTemp, Warning, TEXT("Push 2 Succeed"));
    //       delete callback2;
    //     },
    //     [=](int error_code, const FString &error_message) {
    //       UE_LOG(LogTemp, Warning, TEXT("Push  2 failed error code: %d, desc: %s"), error_code, *error_message);
    //       delete callback2;
    //     }
    // );
    // PushManager::GetInstance()->CallExperimentalAPI(api2, paramPtr2, callback2);

    // // disableRequestPostNotificationPermission
    // FString api3 = "disableRequestPostNotificationPermission";
    // bool param3 = true;
    // void* paramPtr3 = &param3;
    // auto callback3 = new DemoPushCallback();
    // callback3->SetCallback(
    //     [=]() {
    //       UE_LOG(LogTemp, Warning, TEXT("Push 3 Succeed"));
    //       delete callback3;
    //     },
    //     [=](int error_code, const FString &error_message) {
    //       UE_LOG(LogTemp, Warning, TEXT("Push 3 failed error code: %d, desc: %s"), error_code, *error_message);
    //       delete callback3;
    //     }
    // );
    // PushManager::GetInstance()->CallExperimentalAPI(api3, paramPtr3, callback3);

    // // setCustomBadgeNumber
    // FString api4 = "setCustomBadgeNumber";
    // int param4 = 10;
    // void* paramPtr4 = &param4;
    // auto callback4 = new DemoPushCallback();
    // callback4->SetCallback(
    //     [=]() {
    //       UE_LOG(LogTemp, Warning, TEXT("Push 4 Succeed"));
    //       delete callback4;
    //     },
    //     [=](int error_code, const FString &error_message) {
    //       UE_LOG(LogTemp, Warning, TEXT("Push 4 failed error code: %d, desc: %s"), error_code, *error_message);
    //       delete callback4;
    //     }
    // );
    // PushManager::GetInstance()->CallExperimentalAPI(api4, paramPtr4, callback4);

    // // getPushToken
    // FString api5 = "getPushToken";
    // auto callback5 = new DemoPushValueCallback<FString>();
    // callback5->SetCallback(
    //     [=](const FString &value) {
    //       UE_LOG(LogTemp, Warning, TEXT("Push 5 succeed, device token is %s"), *value);
    //       delete callback5;
    //     },
    //     [=](int error_code, const FString &error_message) {
    //       UE_LOG(LogTemp, Warning, TEXT("Push 5 failed error code: %d, desc: %s"), error_code, *error_message);
    //       delete callback5;
    //     }
    // );
    // PushManager::GetInstance()->CallExperimentalAPI(api5, nullptr, callback5);

    GLog->Flush();
#endif
}
