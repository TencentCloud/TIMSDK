package com.tencent.qcloud.tim.tuiofflinepush;

import android.content.Context;
import android.content.SharedPreferences;

import com.tencent.qcloud.tim.tuiofflinepush.OEMPush.OEMPushSetting;
import com.tencent.qcloud.tim.tuiofflinepush.TPNSPush.TPNSPushSetting;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;

public class PushSetting {

    /**
     *  是否接入 TPNS 标记
     *
     *  @note demo 实现了厂商和 TPNS 两种方式，以此变量作为逻辑区分
     *
     *  - 当接入推送方案选择 TPNS 通道，设置 isTPNSChannel 为 true，走 TPNS 推送逻辑；
     *  - 当接入推送方案选择厂商通道，设置 isTPNSChannel 为 false，走厂商推送逻辑；
     */
    public static boolean isTPNSChannel = false;
    public void initPush(Context context) {
        PushSettingInterface pushSettingInterface;
        SharedPreferences sharedPreferences = context.getSharedPreferences("TUIKIT_DEMO_SETTINGS", context.MODE_PRIVATE);
        isTPNSChannel = sharedPreferences.getBoolean("isTPNSChannel", PrivateConstants.isTPNSChannel);
        TUIOfflinePushLog.i("PushSetting", "initPush isTPNSChannel = " + isTPNSChannel);
        if (isTPNSChannel) {
            pushSettingInterface = new TPNSPushSetting();
            pushSettingInterface.init(context);
        } else {
            pushSettingInterface = new OEMPushSetting();
            pushSettingInterface.init(context);
        }
    }

    public void bindUserID(String userId) {
        PushSettingInterface pushSettingInterface;
        if (isTPNSChannel) {
            pushSettingInterface = new TPNSPushSetting();
            pushSettingInterface.bindUserID(userId);
        }
    }

    public void unBindUserID(Context context, String userId) {
        PushSettingInterface pushSettingInterface;
        if (isTPNSChannel) {
            pushSettingInterface = new TPNSPushSetting();
            pushSettingInterface.unBindUserID(context, userId);
        }
    }

    public void unInitPush(Context context) {
        PushSettingInterface pushSettingInterface;
        if (isTPNSChannel) {
            pushSettingInterface = new TPNSPushSetting();
            pushSettingInterface.unInit(context);
        }
    }
}
