package com.tencent.qcloud.tim.tuiofflinepush.interfaces;

import android.content.Context;

public interface PushSettingInterface {
    /**
     *  注册离线推送服务, IM 账号登录成功时调用
     *
     *  Register offline push service, called when IM account login is successful
     */
    void initPush(Context context);

    /**
     *  推送回调接口
     *
     *  Push callback interface
     */
    void setPushCallback(PushCallback callback);
}
