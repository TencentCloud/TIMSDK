package io.trtc.tuikit.atomicx.common.foregroundservice

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
import androidx.core.content.ContextCompat
import io.trtc.tuikit.atomicx.common.foregroundservice.base.BaseForegroundService
import io.trtc.tuikit.atomicx.common.foregroundservice.base.ServiceLauncher

class AudioForegroundService : BaseForegroundService(launcher) {

    override fun provideForegroundServiceType() = FOREGROUND_SERVICE_TYPE_MICROPHONE
    
    override fun provideChannelId() = "rtc_uikit_audio_foreground_service"

    companion object {
        internal val launcher =
            ServiceLauncher(AudioForegroundService::class.java, "AudioForegroundService")

        @JvmStatic
        fun start(context: Context, title: String?, description: String?, icon: Int) {
            launcher.start(context, title, description, icon) {
                ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED
            }
        }

        @JvmStatic
        fun stop(context: Context) = launcher.stop(context)
    }
}