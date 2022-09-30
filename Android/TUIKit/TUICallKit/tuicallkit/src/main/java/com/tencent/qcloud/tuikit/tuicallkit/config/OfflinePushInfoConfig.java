package com.tencent.qcloud.tuikit.tuicallkit.config;

import android.content.Context;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.tuicallengine.offlinepush.TUIOfflinePushInfo;
import com.tencent.qcloud.tuikit.tuicallkit.R;

public class OfflinePushInfoConfig {

    //Customize offline push information
    public static TUIOfflinePushInfo createOfflinePushInfo(Context context) {
        TUIOfflinePushInfo pushInfo = new TUIOfflinePushInfo();
        pushInfo.setTitle(TUILogin.getNickName());
        pushInfo.setDesc(context.getString(R.string.tuicalling_have_a_new_call));
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        // OPPO must set a ChannelID to receive push messages. This channelID needs to be the same as the console.
        pushInfo.setAndroidOPPOChannelID("tuikit");
        pushInfo.setIgnoreIOSBadge(false);
        pushInfo.setIOSSound("phone_ringing.mp3");
        return pushInfo;
    }
}
