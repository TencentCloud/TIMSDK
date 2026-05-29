package io.trtc.tuikit.atomicx.common.foregroundservice.base

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.tencent.cloud.tuikit.engine.common.ContextProvider
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.common.util.TUIBuild

abstract class BaseForegroundService(
    private val launcher: ServiceLauncher<*>
) : Service() {

    companion object {
        const val TITLE = "title"
        const val ICON = "icon"
        const val DESCRIPTION = "description"
        const val NOTIFICATION_ID = 1001
    }

    abstract fun provideForegroundServiceType(): Int
    
    abstract fun provideChannelId(): String

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) return START_NOT_STICKY

        val appContext = ContextProvider.getApplicationContext()
        val title = intent.getStringExtra(TITLE)
        val description = intent.getStringExtra(DESCRIPTION)
        val icon = intent.getIntExtra(ICON, appContext?.applicationInfo?.icon ?: 0)

        val notification = createNotification(title, description, icon)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            startForeground(NOTIFICATION_ID, notification, provideForegroundServiceType())
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        if (launcher.state == ServiceState.STOPPING) {
            stopSelf()
            launcher.updateState(ServiceState.IDLE)
        } else {
            launcher.updateState(ServiceState.RUNNING)
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        stopSelf()
        launcher.updateState(ServiceState.IDLE)
    }

    override fun onDestroy() {
        super.onDestroy()
        clearNotification()
    }

    private fun createNotification(title: String?, desc: String?, icon: Int): Notification {
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        val channelId = provideChannelId()
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                applicationContext.getString(R.string.common_rtc_channel_name),
                NotificationManager.IMPORTANCE_LOW
            )
            manager.createNotificationChannel(channel)
        }
        return NotificationCompat.Builder(this, channelId)
            .setSmallIcon(icon)
            .setContentTitle(title)
            .setContentText(desc)
            .build()
    }

    private fun clearNotification() {
        val manager = getSystemService(NOTIFICATION_SERVICE) as? NotificationManager
        manager?.cancel(NOTIFICATION_ID)
    }
}