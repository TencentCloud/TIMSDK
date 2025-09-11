//
// Copyright (c) 2025 Tencent. All rights reserved.
//
//

#ifndef TIM_PUSH_MANAGER_CWRAPPER_H
#define TIM_PUSH_MANAGER_CWRAPPER_H

#ifdef __cplusplus
extern "C"
{
#endif

typedef void (*CTIMPushSuccessCallback)(const char *data, const char *userData);
typedef void (*CTIMPushFailedCallback)(int code, const char *desc, const char *userData);
typedef void (*CTIMPushMessageCallback)(const char *message);
typedef void (*CTIMPushRevokeCallback)(const char *messageID);
typedef void (*CTIMPushNotificationClickedCallback)(const char *ext);

// 1. 注册/反注册推送服务
void TIMRegisterPush(int sdkAppId, const char *appKey,
                                    CTIMPushSuccessCallback successCallback,
                                    CTIMPushFailedCallback failedCallback, const char *userData) NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");

void TIMUnRegisterPush(CTIMPushSuccessCallback successCallback, CTIMPushFailedCallback failedCallback, const char *userData) NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");

void TIMGetRegistrationID(CTIMPushSuccessCallback callback, const char *userData) NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");

void TIMSetRegistrationID(const char *registrationID, CTIMPushSuccessCallback callback, const char *userData) NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");

void TIMDisablePostNotificationInForeground(int disable);

// 2. 添加/移除推送监听器
void TIMAddPushListener(CTIMPushMessageCallback messageCallback,
                        CTIMPushRevokeCallback revokeCallback,
                        CTIMPushNotificationClickedCallback clickedCallback) NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");

void TIMRemovePushListener(void) NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");



// 3. 实验性 API
void TIMCallExperimentalAPI(const char *api, const char *paramStr, int paramInt,
                            CTIMPushSuccessCallback successCallback, CTIMPushFailedCallback failedCallback, const char *userData) NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");

#ifdef __cplusplus
}
#endif

#endif /* TIM_PUSH_MANAGER_CWRAPPER_H */
