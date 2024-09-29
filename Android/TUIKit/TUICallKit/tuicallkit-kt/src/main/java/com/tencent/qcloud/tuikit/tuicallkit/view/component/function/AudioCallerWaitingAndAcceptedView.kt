package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView

class AudioCallerWaitingAndAcceptedView(context: Context) : BaseCallView(context) {
    private var layoutMute: LinearLayout? = null
    private var layoutHangup: LinearLayout? = null
    private var layoutHandsFree: LinearLayout? = null
    private var imageMute: ImageView? = null
    private var imageHandsFree: ImageView? = null
    private var textMic: TextView? = null
    private var textAudioDevice: TextView? = null

    private var isMicMuteObserver = Observer<Boolean> {
        imageMute?.isActivated = it
        textMic?.text = getMicText()
    }

    private var audioPlayoutDeviceObserver = Observer<TUICommonDefine.AudioPlaybackDevice> {
        if (it == TUICommonDefine.AudioPlaybackDevice.Speakerphone) {
            imageHandsFree?.isActivated = true
        } else {
            imageHandsFree?.isActivated = false
        }
    }

    init {
        initView()
        addObserver()
    }

    override fun clear() {
        removeObserver()
    }

    private fun addObserver() {
        TUICallState.instance.isMicrophoneMute.observe(isMicMuteObserver)
        TUICallState.instance.audioPlayoutDevice?.observe(audioPlayoutDeviceObserver)
    }

    private fun removeObserver() {
        TUICallState.instance.isMicrophoneMute.removeObserver(isMicMuteObserver)
        TUICallState.instance.audioPlayoutDevice?.removeObserver(audioPlayoutDeviceObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_audio, this)
        layoutMute = findViewById(R.id.ll_mute)
        imageMute = findViewById(R.id.img_mute)
        layoutHangup = findViewById(R.id.ll_hangup)
        layoutHandsFree = findViewById(R.id.ll_handsfree)
        imageHandsFree = findViewById(R.id.img_handsfree)
        textMic = findViewById(R.id.tv_mic)
        textAudioDevice = findViewById(R.id.tv_audio_device)

        imageMute?.isActivated = TUICallState.instance.isMicrophoneMute.get() == true
        imageHandsFree?.isActivated =
            TUICallState.instance.audioPlayoutDevice.get() == TUICommonDefine.AudioPlaybackDevice.Speakerphone
        textMic?.text = getMicText()
        textAudioDevice?.text = getAudioDeviceText()

        initViewListener()
    }

    private fun initViewListener() {
        layoutMute?.setOnClickListener {
            if (TUICallState.instance.isMicrophoneMute.get() == true) {
                EngineManager.instance.openMicrophone(null)
            } else {
                EngineManager.instance.closeMicrophone()
            }
        }
        layoutHangup?.setOnClickListener { EngineManager.instance.hangup(null) }
        layoutHandsFree?.setOnClickListener {
            if (TUICallState.instance.audioPlayoutDevice.get() == TUICommonDefine.AudioPlaybackDevice.Speakerphone) {
                EngineManager.instance.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Earpiece)
            } else {
                EngineManager.instance.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Speakerphone)
            }
            textAudioDevice?.text = getAudioDeviceText()
        }
    }

    private fun getMicText(): String {
        return if (TUICallState.instance.isMicrophoneMute.get() == true) {
            context.getString(R.string.tuicallkit_toast_enable_mute)
        } else {
            context.getString(R.string.tuicallkit_toast_disable_mute)
        }
    }

    private fun getAudioDeviceText(): String {
        return if (TUICallState.instance.audioPlayoutDevice.get() == TUICommonDefine.AudioPlaybackDevice.Speakerphone) {
            context.getString(R.string.tuicallkit_toast_speaker)
        } else {
            context.getString(R.string.tuicallkit_toast_use_earpiece)
        }
    }
}