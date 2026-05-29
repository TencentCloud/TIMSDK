package io.trtc.tuikit.atomicx.common.foregroundservice

import android.content.Context
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
import io.trtc.tuikit.atomicx.common.foregroundservice.base.BaseForegroundService
import io.trtc.tuikit.atomicx.common.foregroundservice.base.ServiceLauncher

class MediaForegroundService : BaseForegroundService(launcher) {

    override fun provideForegroundServiceType() = FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
    
    override fun provideChannelId() = "rtc_uikit_media_foreground_service"

    companion object {
        internal val launcher =
            ServiceLauncher(MediaForegroundService::class.java, "MediaForegroundService")

        @JvmStatic
        fun start(context: Context, title: String?, description: String?, icon: Int) {
            launcher.start(context, title, description, icon) { true }
        }

        @JvmStatic
        fun stop(context: Context) = launcher.stop(context)
    }
}