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
        //VIVO message type: 0-push message, 1-System message(have a higher delivery rate)
        pushInfo.setAndroidVIVOClassification(1);
        return pushInfo;
    }
}
