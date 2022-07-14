package com.tencent.qcloud.tim.tuiofflinepush;

import android.content.Context;

public interface PushSettingInterface {
    /**
     *  注册离线推送服务, IM 账号登录成功时调用
     */
    void initPush(Context context);
    
    /**
     *  推送回调接口
     */
    void setPushCallback(TUIOfflinePushManager.PushCallback callback);
}
