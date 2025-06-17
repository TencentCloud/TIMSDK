package com.tencent.qcloud.tuikit.tuicallkit.manager.feature

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationChannelGroup
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import com.tencent.qcloud.tuikit.tuicallkit.R

class NotificationFeature(ctx: Context) {
    private val context: Context = ctx.applicationContext
    private val channelGroupId = "callKitChannelGroupId"

    // channelId only takes effect for the first time. If you want to change it,you need to uninstall the app and reinstall it.
    fun registerNotificationBannerChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelGroupName = context.getString(R.string.tuicallkit_notification_channel_group_id)
            val channelGroup = NotificationChannelGroup(channelGroupId, channelGroupName)
            nm.createNotificationChannelGroup(channelGroup)

            val channelName = context.getString(R.string.tuicallkit_notification_channel_id)
            val channel = NotificationChannel(CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_HIGH)
            channel.group = channelGroupId
            channel.enableLights(true)
            channel.enableVibration(true)
            channel.setShowBadge(true)
            channel.setSound(null, null)
            channel.setBypassDnd(true)
            channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            nm.createNotificationChannel(channel)
        }
    }

    companion object {
        const val CHANNEL_ID = "CallKitChannelId"
    }
}