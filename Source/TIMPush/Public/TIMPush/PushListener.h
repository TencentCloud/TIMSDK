#ifndef PUSH_LISTENER_H__
#define PUSH_LISTENER_H__

#include "PushMessage.h"
#include "CoreMinimal.h"

class PushListener {
public:
    virtual ~PushListener() = default;
    
    /**
     * 收到 Push 消息
     * @param message 消息
     */
    virtual void OnRecvPushMessage(const PushMessage& message) {}
    
    /**
     * 收到 Push 消息撤回的通知
     * @param messageID 消息唯一标识
     */
    virtual void OnRevokePushMessage(const FString& messageID) {}
    
    /**
     * 点击通知栏消息回调
     * @param ext 离线消息透传字段
     */
    virtual void OnNotificationClicked(const FString& ext) {}
};

#endif // PUSH_LISTENER_H__