package com.tencent.qcloud.tuikit.tuicallkit.data

import android.content.Context
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.OfflinePushInfo
import com.tencent.qcloud.tuikit.tuicallkit.R

object OfflinePushInfoConfig {
    fun createOfflinePushInfo(context: Context): OfflinePushInfo {
        val pushInfo = OfflinePushInfo()
        pushInfo.title = TUILogin.getNickName()
        pushInfo.desc = context.getString(R.string.tuicalling_have_a_new_call)
        //OPPO必须设置ChannelID才可以收到推送消息，如果在控制台已经配置,代码中无需调用
        //OPPO must set a ChannelID to receive push messages. If you set it on the console, you don't need set here.
        //pushInfo.androidOPPOChannelID = "tuikit"
        pushInfo.isIgnoreIOSBadge = false
        pushInfo.iosSound = "phone_ringing.mp3"
        pushInfo.androidSound = "phone_ringing"
        //VIVO message type: 0-push message, 1-System message(have a higher delivery rate)
        pushInfo.androidVIVOClassification = 1
        //FCM channel ID, you need change PrivateConstants.java and set "fcmPushChannelId", If you set it on the console, you don't need set here.
        //pushInfo.androidFCMChannelID = "fcm_push_channel"
        //HuaWei message type: https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
        pushInfo.androidHuaWeiCategory = "IM"
        //IOS push type: if you want user VoIP, please modify type to TUICallDefine.IOSOfflinePushType.VoIP
        pushInfo.iosPushType = TUICallDefine.IOSOfflinePushType.APNs
        return pushInfo
    }
}