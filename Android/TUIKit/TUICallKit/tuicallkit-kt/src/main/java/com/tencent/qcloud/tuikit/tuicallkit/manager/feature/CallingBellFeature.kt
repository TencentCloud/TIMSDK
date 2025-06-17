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
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
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
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.PushManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.trtc.tuikit.common.livedata.Observer
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class CallingBellFeature(context: Context) {
    private val context: Context = context.applicationContext
    private var mediaPlayer: MediaPlayer? = null
    private var handler: Handler? = null
    private var bellResourceId: Int
    private var bellResourcePath: String = ""
    private var dialPath: String? = null

    private val callStatusObserver = Observer<TUICallDefine.Status> {
        if (it != TUICallDefine.Status.Waiting) {
            stopMusic()
            return@Observer
        }
        if (CallManager.instance.userState.selfUser.get().callRole == TUICallDefine.Role.Caller) {
            startDialingMusic()
            return@Observer
        }
        if (isLocalRingtonePlaybackNeeded()) {
            startRinging()
        }
    }

    init {
        bellResourceId = -1
        bellResourcePath = ""
        registerObserver()
    }

    fun registerObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
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
        if (CallManager.instance.userState.selfUser.get()?.callRole == TUICallDefine.Role.Caller) {
            TUICallEngine.createInstance(context).trtcCloudInstance.audioEffectManager.stopPlayMusic(AUDIO_DIAL_ID)
        } else {
            stopRinging()
        }
    }

    private fun startDialingMusic() {
        if (TextUtils.isEmpty(dialPath)) {
            dialPath = getBellPath(context, R.raw.phone_dialing, "phone_dialing.mp3")
        }
        TUICallEngine.createInstance(context).trtcCloudInstance
            .audioEffectManager.setMusicPlayoutVolume(AUDIO_DIAL_ID, 100)
        val param = AudioMusicParam(AUDIO_DIAL_ID, dialPath)
        param.isShortFile = true
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
        val savePath = ContextCompat.getExternalFilesDirs(context, null)[0].absolutePath
        val dir = File(savePath)
        if (!dir.exists()) {
            dir.mkdir()
        }
        try {
            val file = File("$savePath/$name")
            if (file.exists()) {
                return file.absolutePath
            }
            val inputStream = context.resources.openRawResource(resId)
            val outputStream = FileOutputStream(file)
            val buffer = ByteArray(2048)
            var length: Int
            while (inputStream.read(buffer).also { length = it } > 0) {
                outputStream.write(buffer, 0, length)
            }
            outputStream.flush()
            outputStream.close()
            inputStream.close()
            return file.absolutePath
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return null
    }

    companion object {
        private const val TAG = "CallingBellFeature"
        const val PROFILE_TUICALLKIT = "per_profile_tuicallkit"
        const val PROFILE_CALL_BELL = "per_call_bell"
        const val PROFILE_MUTE_MODE = "per_mute_mode"
        const val AUDIO_DIAL_ID = 48
    }
}