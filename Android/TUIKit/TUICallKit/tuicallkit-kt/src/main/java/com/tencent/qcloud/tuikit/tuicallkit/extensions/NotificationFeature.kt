package com.tencent.qcloud.tuikit.tuicallkit.extensions

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationChannelGroup
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.os.Build
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants

class NotificationFeature {
    private val groupID = "CallGroupId"
    private val groupName = "CallGroup"

    fun createCallNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelGroup = NotificationChannelGroup(groupID, groupName)
            nm.createNotificationChannelGroup(channelGroup)

            val channelName = "CallChannel"
            val channel =
                NotificationChannel(Constants.CALL_CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_HIGH)
            channel.group = groupID
            channel.enableLights(true)
            channel.enableVibration(true)
            channel.setShowBadge(true)
            channel.setSound(null, null)
            channel.setBypassDnd(true)
            channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            nm.createNotificationChannel(channel)
        }
    }

    fun createForegroundNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val nm = context.getSystemService(Service.NOTIFICATION_SERVICE) as NotificationManager
            val channelGroup = NotificationChannelGroup(groupID, groupName)
            nm.createNotificationChannelGroup(channelGroup)

            val channelName = "Call Foreground Service Notification"
            val notificationChannel = NotificationChannel(
                Constants.NOTIFICATION_CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_LOW
            )
            notificationChannel.group = groupID
            notificationChannel.description = "Call Foreground Service"
            nm.createNotificationChannel(notificationChannel)
        }
    }
}