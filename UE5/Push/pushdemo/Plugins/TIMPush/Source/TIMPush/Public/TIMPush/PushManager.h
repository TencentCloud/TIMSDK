// Copyright (c) 2025 Tencent. All rights reserved.

/////////////////////////////////////////////////////////////////////////////////
//
//       TIMPush 主核心类，负责 Push 相关的逻辑
//
/////////////////////////////////////////////////////////////////////////////////

#ifndef PUSH_MANAGER_H__
#define PUSH_MANAGER_H__

#include "PushListener.h"
#include "PushMessage.h"
#include "PushCallback.h"
#include "CoreMinimal.h"

class PushCallback;
class PushListener;
class PushMessage;

class TIMPUSH_API PushManager {
public:
    virtual ~PushManager() {}

    static PushManager* GetInstance();

/////////////////////////////////////////////////////////////////////////////////
//
//                         注册/反注册推送服务
//
/////////////////////////////////////////////////////////////////////////////////

    /**
     *  1.1 注册推送服务
     *
     *  @param sdkAppId  应用的 sdkAppId
     *  @param appKey    控制台为您分配的 appKey
     *
     *  @note
     *  - 如果您单独使用推送服务，请正确传递 sdkAppId 和 appKey 两个参数，即可注册推送服务
     *  - 如果您已经集成 IM 产品，请在 IM 登录成功后调用该接口，将 appKey 参数设置为 ""，接入离线推送能力
     */
    virtual void RegisterPush(int sdkAppId, const FString& appKey, PushValueCallback<FString>* callback) = 0;

    /**
     *  1.2 反注册关闭离线推送服务
     */
    virtual void UnRegisterPush(PushCallback* callback) = 0;

    /**
     *  1.3 注册离线推送服务成功后，通过该接口可获取推送唯一 ID 标识, 即 RegistrationID，然后可以根据 RegistrationID 来向指定设备推送消息
     *
     *  @return  RegistrationID 设备的推送唯一标识 ID，默认注册推送服务成功后会自动生成，也支持用户自定义设置，提供用户根据 RegistrationID 来向指定设备推送消息功能，卸载重装会改变。
     *
     */
    virtual void GetRegistrationID(PushValueCallback<FString>* callback) = 0;

    /**
     *  1.4 自定义设置设备使用的推送唯一标识 ID, 即 RegistrationID，需要在注册推送服务之前调用
     *
     *  @return  RegistrationID 设备的推送唯一标识 ID，默认注册推送服务成功后会自动生成，也支持用户自定义设置，提供用户根据 RegistrationID 来向指定设备推送消息功能，卸载重装会改变。
     *
     */
    virtual void SetRegistrationID(const FString& registrationID, PushCallback* callback) = 0;
  
/////////////////////////////////////////////////////////////////////////////////
//
//                         Push 全局监听
//
/////////////////////////////////////////////////////////////////////////////////

    /**
     * 2.1 添加 Push 监听器
     */
    virtual void AddPushListener(PushListener* listener) = 0;

    /**
     * 2.2 移除 Push 监听器
     */
    virtual void RemovePushListener(PushListener* listener) = 0;
    
/////////////////////////////////////////////////////////////////////////////////
//
//                         自定义配置
//
/////////////////////////////////////////////////////////////////////////////////

    /**
     * 3.1 指定设备离线推送使用 FCM 通道，需要在注册推送服务之前调用。
     *
     * @note 常用于海外推送走 FCM 通道，如海外小米手机走 FCM 通道
     *
     * @param enable true:使用 FCM 通道 false:使用本机通道
     */
    virtual void ForceUseFCMPushChannel(bool enable) = 0;

    /**
     * 3.2 关闭 APP 在前台时弹出通知栏
     *
     * @param disable  true:关闭 false:开启
     *
     * @note 推送 SDK 收到在线推送时，会自动向通知栏增加 Notification 提示，如果您想自己处理在线推送消息，可以调用该接口关闭自动弹通知栏提示的特性
     */
    virtual void DisablePostNotificationInForeground(bool disable) = 0;
    
/////////////////////////////////////////////////////////////////////////////////
//
//                         实验性 API
//
/////////////////////////////////////////////////////////////////////////////////

    /**
     * 4.1 实验性 API 接口
     *
     * @param api 接口名称
     * @param param 接口参数
     *
     * @note 该接口提供一些实验性功能
     */
    virtual void CallExperimentalAPI(const FString& api, void* param, PushBaseCallback* callback) = 0;
};

#endif // PUSH_MANAGER_H__