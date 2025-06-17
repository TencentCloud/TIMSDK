package com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingbanner

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.request.target.SimpleTarget
import com.bumptech.glide.request.transition.Transition
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.MediaType
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.feature.NotificationFeature
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.tencent.qcloud.tuikit.tuicallkit.view.CallMainActivity
import com.trtc.tuikit.common.livedata.Observer

class IncomingNotificationBanner(context: Context) {
    private val context: Context = context.applicationContext
    private var notificationManager: NotificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private val notificationId = 9909
    private var remoteViews: RemoteViews? = null
    private var notification: Notification? = null

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None || it == TUICallDefine.Status.Accept) {
            cancelNotification()
        }
    }

    private fun registerObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(callStatusObserver)
    }

    fun showNotification(user: UserState.User) {
        Logger.i(TAG, "showNotification, user: $user")
        registerObserver()
        notification = createNotification()

        if (user.nickname.get().isNullOrEmpty()) {
            remoteViews?.setTextViewText(R.id.tv_incoming_title, user.id)
        } else {
            remoteViews?.setTextViewText(R.id.tv_incoming_title, user.nickname.get())
        }

        val mediaType = CallManager.instance.callState.mediaType.get()
        if (mediaType == MediaType.Video) {
            remoteViews?.setTextViewText(R.id.tv_desc, context.getString(R.string.tuicallkit_invite_video_call))
            remoteViews?.setImageViewResource(R.id.img_media_type, R.drawable.tuicallkit_ic_video_incoming)
            remoteViews?.setImageViewResource(R.id.btn_accept, R.drawable.tuicallkit_ic_dialing_video)
        } else {
            remoteViews?.setTextViewText(R.id.tv_desc, context.getString(R.string.tuicallkit_invite_audio_call))
            remoteViews?.setImageViewResource(R.id.img_media_type, R.drawable.tuicallkit_ic_float)
            remoteViews?.setImageViewResource(R.id.btn_accept, R.drawable.tuicallkit_bg_dialing)
        }

        if (user.avatar.get().isNullOrEmpty()) {
            remoteViews?.setImageViewResource(R.id.img_incoming_avatar, R.drawable.tuicallkit_ic_avatar)
            notificationManager.notify(notificationId, notification)
        } else {
            val uri = Uri.parse(user.avatar.get())

            Glide.with(context).asBitmap().load(uri)
                .diskCacheStrategy(DiskCacheStrategy.ALL).placeholder(R.drawable.tuicallkit_ic_avatar)
                .apply(RequestOptions.bitmapTransform(RoundedCorners(15)))
                .into(object : SimpleTarget<Bitmap>() {
                    override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                        remoteViews?.setImageViewBitmap(R.id.img_incoming_avatar, resource)
                        notificationManager.notify(notificationId, notification)
                    }

                    override fun onLoadFailed(errorDrawable: Drawable?) {
                        remoteViews?.setImageViewResource(R.id.img_incoming_avatar, R.drawable.tuicallkit_ic_avatar)
                        notificationManager.notify(notificationId, notification)
                    }
                })
        }
    }

    private fun cancelNotification() {
        Logger.i(TAG, "cancelNotification")
        notificationManager.cancel(notificationId)
        unregisterObserver()
    }

    private fun createNotification(): Notification {
        val channelId = NotificationFeature.CHANNEL_ID
        val builder = NotificationCompat.Builder(context)
            .setOngoing(true)
            .setAutoCancel(true)
            .setWhen(System.currentTimeMillis())
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setTimeoutAfter(Constants.CALL_WAITING_MAX_TIME * 1000L)

        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
            builder.setCategory(NotificationCompat.CATEGORY_CALL)
            builder.priority = NotificationCompat.PRIORITY_MAX
        }

        builder.setChannelId(channelId)
        builder.setSmallIcon(R.drawable.tuicallkit_ic_avatar)
        builder.setSound(null)

        builder.setContentIntent(getPendingIntent())
        builder.setFullScreenIntent(getPendingIntent(), true)

        remoteViews = RemoteViews(context.packageName, R.layout.tuicallkit_incoming_notification_view)
        remoteViews?.setOnClickPendingIntent(R.id.btn_decline, getDeclineIntent())
        remoteViews?.setOnClickPendingIntent(R.id.btn_accept, getAcceptIntent())

        builder.setCustomContentView(remoteViews)
        builder.setCustomBigContentView(remoteViews)
        return builder.build()
    }

    private fun getPendingIntent(): PendingIntent {
        val intent = Intent(context, CallMainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)
    }

    private fun getDeclineIntent(): PendingIntent {
        val intent = Intent(context, IncomingCallReceiver::class.java)
        intent.action = Constants.REJECT_CALL_ACTION
        return PendingIntent.getBroadcast(context, 1, intent, PendingIntent.FLAG_IMMUTABLE)
    }

    private fun getAcceptIntent(): PendingIntent {
        val intent = Intent(context, CallMainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.action = Constants.ACCEPT_CALL_ACTION
        return PendingIntent.getActivity(context, 2, intent, PendingIntent.FLAG_IMMUTABLE)
    }

    companion object {
        private const val TAG = "IncomingViewNotification"
    }
}