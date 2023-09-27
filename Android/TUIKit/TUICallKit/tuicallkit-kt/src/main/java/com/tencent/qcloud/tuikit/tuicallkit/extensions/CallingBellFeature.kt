package com.tencent.qcloud.tuikit.tuicallkit.extensions

import android.content.Context
import android.content.res.AssetFileDescriptor
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.text.TextUtils
import com.tencent.qcloud.tuicore.util.SPUtils
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import java.io.File

class CallingBellFeature(context: Context) {
    private val context: Context
    private val mediaPlayer: MediaPlayer
    private var handler: Handler? = null
    private var bellResourceId: Int
    private var bellResourcePath: String

    init {
        this.context = context.applicationContext
        mediaPlayer = MediaPlayer()
        bellResourceId = -1
        bellResourcePath = ""

        addObserver()
    }

    fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe {
            when (it) {
                TUICallDefine.Status.None -> {
                    stopRing()
                }

                TUICallDefine.Status.Waiting -> {
                    startRing()
                }

                TUICallDefine.Status.Accept -> {
                    stopRing()
                }
            }
        }
    }

    private fun startRing() {
        if (TUICallState.instance?.selfUser?.get()?.callRole?.get() == TUICallDefine.Role.Caller) {
            start("", R.raw.phone_dialing, 0)
        } else {
            if (TUICallState.instance.enableMuteMode) {
                return
            }
            val path = SPUtils.getInstance(PROFILE_TUICALLKIT).getString(PROFILE_CALL_BELL, "")
            if (TextUtils.isEmpty(path)) {
                start("", R.raw.phone_ringing, 0)
            } else {
                start(path, -1, 0)
            }
        }
    }

    private fun stopRing() {
        stop()
    }

    private fun start(resPath: String, resId: Int, duration: Long) {
        preHandler()
        if (TextUtils.isEmpty(resPath) && -1 == resId) {
            return
        }
        if (-1 != resId && bellResourceId == resId
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
            if (mediaPlayer.isPlaying) {
                mediaPlayer.stop()
            }
            mediaPlayer.reset()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val attrs = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
                mediaPlayer.setAudioAttributes(attrs)
            }
            var mAudioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager?
            mAudioManager?.mode = AudioManager.MODE_NORMAL
            mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC)

            try {
                if (null != afd) {
                    mediaPlayer.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                } else if (!TextUtils.isEmpty(bellResourcePath)) {
                    mediaPlayer.setDataSource(bellResourcePath)
                } else {
                    return@Runnable
                }
                mediaPlayer.isLooping = true
                mediaPlayer.prepare()
                mediaPlayer.start()
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

    private fun stop() {
        if (null == handler) {
            return
        }
        if (-1 == bellResourceId && TextUtils.isEmpty(bellResourcePath)) {
            return
        }
        handler!!.post {
            if (mediaPlayer.isPlaying) {
                mediaPlayer.stop()
            }
            bellResourceId = -1
            bellResourcePath = ""
        }
    }

    companion object {
        const val PROFILE_TUICALLKIT = "per_profile_tuicallkit"
        const val PROFILE_CALL_BELL = "per_call_bell"
        const val PROFILE_MUTE_MODE = "per_mute_mode"
    }
}