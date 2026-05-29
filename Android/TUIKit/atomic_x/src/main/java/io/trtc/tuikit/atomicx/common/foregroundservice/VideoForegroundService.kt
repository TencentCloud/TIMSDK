package io.trtc.tuikit.atomicx.common.foregroundservice

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
import android.os.Build
import androidx.core.content.ContextCompat
import io.trtc.tuikit.atomicx.common.foregroundservice.base.BaseForegroundService
import io.trtc.tuikit.atomicx.common.foregroundservice.base.ServiceLauncher

class VideoForegroundService : BaseForegroundService(launcher) {

    override fun provideForegroundServiceType(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            FOREGROUND_SERVICE_TYPE_MICROPHONE or FOREGROUND_SERVICE_TYPE_CAMERA
        } else 0
    }
    
    override fun provideChannelId() = "rtc_uikit_video_foreground_service"

    companion object {
        internal val launcher =
            ServiceLauncher(VideoForegroundService::class.java, "VideoForegroundService")

        @JvmStatic
        fun start(context: Context, title: String?, description: String?, icon: Int) {
            launcher.start(context, title, description, icon) {
                val hasCameraPermission =
                    ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.CAMERA
                    ) == PackageManager.PERMISSION_GRANTED
                val hasAudioPermission =
                    ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.RECORD_AUDIO
                    ) == PackageManager.PERMISSION_GRANTED
                hasCameraPermission && hasAudioPermission
            }
        }

        @JvmStatic
        fun stop(context: Context) = launcher.stop(context)
    }
}