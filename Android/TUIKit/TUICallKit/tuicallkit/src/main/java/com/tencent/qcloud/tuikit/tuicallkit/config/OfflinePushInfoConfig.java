package com.tencent.qcloud.tuikit.tuicallkit.config;

import android.content.Context;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.R;

public class OfflinePushInfoConfig {

    //Customize offline push information
    public static TUICallDefine.OfflinePushInfo createOfflinePushInfo(Context context) {
        TUICallDefine.OfflinePushInfo pushInfo = new TUICallDefine.OfflinePushInfo();
        pushInfo.setTitle(TUILogin.getNickName());
        pushInfo.setDesc(context.getString(R.string.tuicalling_have_a_new_call));
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        // OPPO must set a ChannelID to receive push messages. This channelID needs to be the same as the console.
        pushInfo.setAndroidOPPOChannelID("tuikit");
        pushInfo.setIgnoreIOSBadge(false);
        pushInfo.setIOSSound("phone_ringing.mp3");
        pushInfo.setAndroidSound("phone_ringing");
        //VIVO message type: 0-push message, 1-System message(have a higher delivery rate)
        pushInfo.setAndroidVIVOClassification(1);
        //FCM channel ID, you need change PrivateConstants.java and set "fcmPushChannelId"
        pushInfo.setAndroidFCMChannelID("fcm_push_channel");
        //HuaWei message type: https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
        pushInfo.setAndroidHuaWeiCategory("IM");
        //IOS push type: if you want user VoIP, please modify type to TUICallDefine.IOSOfflinePushType.VoIP
        pushInfo.setIOSPushType(TUICallDefine.IOSOfflinePushType.APNs);
        return pushInfo;
    }
}
