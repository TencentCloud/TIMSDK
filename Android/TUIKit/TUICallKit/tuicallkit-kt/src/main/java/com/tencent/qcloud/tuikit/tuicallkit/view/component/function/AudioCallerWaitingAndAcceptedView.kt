package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.AudioPlaybackDevice
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.trtc.tuikit.common.livedata.Observer

class AudioCallerWaitingAndAcceptedView(context: Context) : RelativeLayout(context) {
    private lateinit var layoutMute: LinearLayout
    private lateinit var layoutHangup: LinearLayout
    private lateinit var layoutAudioDevice: LinearLayout
    private lateinit var imageMute: ImageView
    private lateinit var imageHandsFree: ImageView
    private lateinit var textMute: TextView
    private lateinit var textAudioDevice: TextView

    private var isMicMuteObserver = Observer<Boolean> {
        imageMute.isActivated = it
        textMute.text = getMicText()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        initView()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun registerObserver() {
        CallManager.instance.mediaState.isMicrophoneMuted.observe(isMicMuteObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.mediaState.isMicrophoneMuted.removeObserver(isMicMuteObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_audio, this)
        layoutMute = findViewById(R.id.ll_mute)
        imageMute = findViewById(R.id.img_mute)
        layoutHangup = findViewById(R.id.ll_hangup)
        layoutAudioDevice = findViewById(R.id.ll_audio_device)
        imageHandsFree = findViewById(R.id.img_audio_device)
        textMute = findViewById(R.id.tv_mic)
        textAudioDevice = findViewById(R.id.tv_audio_device)

        imageMute.isActivated = CallManager.instance.mediaState.isMicrophoneMuted.get()
        imageHandsFree.isActivated =
            CallManager.instance.mediaState.audioPlayoutDevice.get() == AudioPlaybackDevice.Speakerphone
        textMute.text = getMicText()
        textAudioDevice.text = getAudioDeviceText()

        initViewListener()
    }

    private fun initViewListener() {
        layoutMute.setOnClickListener {
            if (CallManager.instance.mediaState.isMicrophoneMuted.get()) {
                CallManager.instance.openMicrophone(null)
            } else {
                CallManager.instance.closeMicrophone()
            }
        }
        layoutHangup.setOnClickListener {
            CallManager.instance.hangup(null)
        }
        layoutAudioDevice.setOnClickListener {
            val isSpeaker = CallManager.instance.mediaState.audioPlayoutDevice.get() == AudioPlaybackDevice.Speakerphone
            val device = if (isSpeaker) AudioPlaybackDevice.Earpiece else AudioPlaybackDevice.Speakerphone
            CallManager.instance.selectAudioPlaybackDevice(device)
            textAudioDevice.text = getAudioDeviceText()
            imageHandsFree.isActivated = !isSpeaker
        }
    }

    private fun getMicText(): String {
        return if (CallManager.instance.mediaState.isMicrophoneMuted.get()) {
            context.getString(R.string.tuicallkit_toast_enable_mute)
        } else {
            context.getString(R.string.tuicallkit_toast_disable_mute)
        }
    }

    private fun getAudioDeviceText(): String {
        return if (CallManager.instance.mediaState.audioPlayoutDevice.get() == AudioPlaybackDevice.Speakerphone) {
            context.getString(R.string.tuicallkit_toast_speaker)
        } else {
            context.getString(R.string.tuicallkit_toast_use_earpiece)
        }
    }
}