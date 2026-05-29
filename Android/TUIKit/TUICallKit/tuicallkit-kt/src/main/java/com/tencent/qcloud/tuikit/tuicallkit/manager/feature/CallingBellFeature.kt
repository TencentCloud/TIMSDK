package com.tencent.qcloud.tuikit.tuicallkit.manager.feature

import android.content.Context
import android.content.res.AssetFileDescriptor
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.text.TextUtils
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallEngine
import com.tencent.liteav.audio.TXAudioEffectManager.AudioMusicParam
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.util.SPUtils
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.DeviceUtils
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.manager.PushManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileOutputStream

class CallingBellFeature(context: Context) {
    private val scope = MainScope()
    private val context: Context = context.applicationContext
    private var mediaPlayer: MediaPlayer? = null
    private var handler: Handler? = null
    private var bellResourceId: Int
    private var bellResourcePath: String = ""
    private var dialPath: String? = null
    private var isMusicPlaying = false

    init {
        bellResourceId = -1
        bellResourcePath = ""
        isMusicPlaying = false
        registerObserver()
    }

    private fun registerObserver() {
        scope.launch {
            CallStore.shared.observerState.selfInfo.collect { selfInfo ->
                if (selfInfo.status != CallParticipantStatus.Waiting) {
                    stopMusic()
                    return@collect
                }
                val self = CallStore.shared.observerState.selfInfo.value.copy()
                if (isCaller(self.id)) {
                    startDialingMusic()
                    return@collect
                }
                if (isLocalRingtonePlaybackNeeded()) {
                    startRinging()
                }
            }
        }
    }

    private fun isLocalRingtonePlaybackNeeded(): Boolean {
        if (DeviceUtils.isAppRunningForeground(TUIConfig.getAppContext())) {
            Logger.i(TAG, "isLocalRingtonePlaybackNeeded, appRunningForeground, play local ringtone")
            return true
        }
        val notificationPermission = PermissionRequest.isNotificationEnabled()
        if (!notificationPermission) {
            Logger.w(TAG, "isLocalRingtonePlaybackNeeded, call has no notification permission, play local ringtone")
            return true
        }
        val pushData = PushManager.getPushData()
        val isFCMDataChannel = pushData.channelId == TUIConstants.DeviceInfo.BRAND_GOOGLE_ELSE
        val isPushRegisterSuccess = pushData.status == PushManager.PUSH_REGISTER_SUCCESS

        val hint = if (isFCMDataChannel || !isPushRegisterSuccess) "local" else "push"
        Logger.i(
            TAG, "isLocalRingtonePlaybackNeeded, pushData:$pushData, play $hint ringtone" +
                    "(only when channel is Google or register failed, play local ringtone)"
        )

        return isFCMDataChannel || !isPushRegisterSuccess
    }

    private fun startRinging() {
        if (GlobalState.instance.enableMuteMode) {
            return
        }
        val path = SPUtils.getInstance(PROFILE_TUICALLKIT).getString(PROFILE_CALL_BELL, "")
        if (TextUtils.isEmpty(path)) {
            start("", R.raw.phone_ringing)
        } else {
            start(path, -1)
        }
    }

    private fun stopMusic() {
        if (!isMusicPlaying) {
            return
        }
        isMusicPlaying = false
        val self = CallStore.shared.observerState.selfInfo.value.copy()
        if (isCaller(self.id)) {
            TUICallEngine.createInstance(context).trtcCloudInstance.audioEffectManager.stopPlayMusic(AUDIO_DIAL_ID)
        } else {
            stopRinging()
        }
    }

    private fun startDialingMusic() {
        if (TextUtils.isEmpty(dialPath)) {
            dialPath = getBellPath(context, R.raw.phone_dialing, "phone_dialing.mp3")
        }
        if (TextUtils.isEmpty(dialPath)) {
            Logger.e(TAG, "startDialingMusic failed: dialPath is null or empty")
            return
        }
        TUICallEngine.createInstance(context).trtcCloudInstance
            .audioEffectManager.setMusicPlayoutVolume(AUDIO_DIAL_ID, 100)
        val param = AudioMusicParam(AUDIO_DIAL_ID, dialPath)
        param.isShortFile = true
        isMusicPlaying = true
        TUICallEngine.createInstance(context).trtcCloudInstance.audioEffectManager.startPlayMusic(param)
    }

    private fun start(resPath: String, resId: Int) {
        preHandler()
        if (TextUtils.isEmpty(resPath) && resId == -1) {
            return
        }
        if (resId != -1 && bellResourceId == resId
            || !TextUtils.isEmpty(resPath) && TextUtils.equals(bellResourcePath, resPath)
        ) {
            return
        }

        if (!TextUtils.isEmpty(resPath) && isUrl(resPath)) {
            return
        }
        isMusicPlaying = true

        var assetFileDescriptor: AssetFileDescriptor? = null
        if (!TextUtils.isEmpty(resPath) && File(resPath).exists()) {
            bellResourcePath = resPath
        } else if (-1 != resId) {
            bellResourceId = resId
            assetFileDescriptor = context.resources.openRawResourceFd(resId)
        }

        val afd = assetFileDescriptor
        handler?.post(Runnable {
            if (mediaPlayer == null) {
                mediaPlayer = MediaPlayer()
            }
            if (mediaPlayer?.isPlaying == true) {
                mediaPlayer?.stop()
            }
            mediaPlayer?.reset()

            if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
                val attrs = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build()
                mediaPlayer?.setAudioAttributes(attrs)
            }
            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager?
            audioManager?.mode = AudioManager.MODE_RINGTONE
            mediaPlayer?.setAudioStreamType(AudioManager.STREAM_VOICE_CALL)

            try {
                if (null != afd) {
                    mediaPlayer?.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                } else if (!TextUtils.isEmpty(bellResourcePath)) {
                    mediaPlayer?.setDataSource(bellResourcePath)
                } else {
                    return@Runnable
                }
                mediaPlayer?.isLooping = true
                mediaPlayer?.prepare()
                mediaPlayer?.start()
            } catch (e: java.lang.Exception) {
                e.printStackTrace()
            }
        })
    }

    private fun isUrl(url: String): Boolean {
        return url.startsWith("http://") || url.startsWith("https://")
    }

    private fun preHandler() {
        if (null != handler) {
            return
        }
        val thread = HandlerThread("Handler-MediaPlayer")
        thread.start()
        handler = Handler(thread.looper)
    }

    private fun stopRinging() {
        if (-1 == bellResourceId && TextUtils.isEmpty(bellResourcePath)) {
            return
        }
        handler?.post {
            if (mediaPlayer?.isPlaying == true) {
                mediaPlayer?.stop()
            }
            bellResourceId = -1
            bellResourcePath = ""
        }
    }

    private fun getBellPath(context: Context, resId: Int, name: String): String? {
        val externalDir = ContextCompat.getExternalFilesDirs(context, null).getOrNull(0)
        externalDir?.let { dir ->
            tryCopyResourceToPath(context, resId, name, dir.absolutePath)?.let { path ->
                return path
            }
        }

        val internalDir = context.filesDir.absolutePath
        tryCopyResourceToPath(context, resId, name, internalDir)?.let { path ->
            return path
        }

        Logger.e(TAG, "getBellPath: both external and internal storage failed")
        return null
    }

    private fun tryCopyResourceToPath(context: Context, resId: Int, name: String, savePath: String): String? {
        return try {
            val dir = File(savePath)
            if (!dir.exists() && !dir.mkdirs()) {
                Logger.e(TAG, "tryCopyResourceToPath: failed to create directory $savePath")
                return null
            }

            val file = File(savePath, name)
            file.takeIf { it.exists() && it.length() > 0 }?.absolutePath?.let { return it }

            context.resources.openRawResource(resId).use { inputStream ->
                FileOutputStream(file).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
            return file.absolutePath
        } catch (e: Exception) {
            Logger.e(TAG, "tryCopyResourceToPath: failed at $savePath e=${e.message}")
            null
        }
    }

    private fun isCaller(userId: String): Boolean {
        val callerId = CallStore.shared.observerState.activeCall.value.inviterId
        return callerId == userId
    }

    companion object {
        private const val TAG = "CallingBellFeature"
        const val PROFILE_TUICALLKIT = "per_profile_tuicallkit"
        const val PROFILE_CALL_BELL = "per_call_bell"
        const val PROFILE_MUTE_MODE = "per_mute_mode"
        const val AUDIO_DIAL_ID = 48
    }
}