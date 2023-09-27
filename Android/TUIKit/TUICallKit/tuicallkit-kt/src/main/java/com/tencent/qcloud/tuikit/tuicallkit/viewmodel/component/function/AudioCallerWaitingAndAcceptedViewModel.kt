package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.function

import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallEngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class AudioCallerWaitingAndAcceptedViewModel {
    public var isSpeaker = LiveData<Boolean>()
    public var isMicMute = LiveData<Boolean>()
    private var audioPlayoutDeviceObserver = Observer<TUICommonDefine.AudioPlaybackDevice> {
        if (it == TUICommonDefine.AudioPlaybackDevice.Speakerphone) {
            isSpeaker.set(true)
        } else {
            isSpeaker.set(false)
        }
    }

    init {
        isMicMute = TUICallState.instance.isMicrophoneMute
        isSpeaker.set(TUICallState.instance.audioPlayoutDevice.get() == TUICommonDefine.AudioPlaybackDevice.Speakerphone)
        addObserver()
    }

    private fun addObserver() {
        TUICallState.instance.audioPlayoutDevice?.observe(audioPlayoutDeviceObserver)
    }

    public fun removeObserver() {
        TUICallState.instance.audioPlayoutDevice?.removeObserver(audioPlayoutDeviceObserver)
    }

    fun hangup() {
        CallEngineManager.instance.hangup(object : TUICommonDefine.Callback {
            override fun onSuccess() {}

            override fun onError(errCode: Int, errMsg: String?) {}

        })
    }

    fun openMicrophone() {
        CallEngineManager.instance.openMicrophone(object : TUICommonDefine.Callback {
            override fun onSuccess() {
            }

            override fun onError(errCode: Int, errMsg: String?) {}
        })
    }

    fun closeMicrophone() {
        CallEngineManager.instance.closeMicrophone()
    }

    fun selectAudioPlaybackDevice(type: TUICommonDefine.AudioPlaybackDevice) {
        if (TUICallDefine.Status.Accept == TUICallState.instance.selfUser.get().callStatus.get()) {
            CallEngineManager.instance.selectAudioPlaybackDevice(type)
        } else {
            TUICallState.instance.audioPlayoutDevice.set(type)
        }
    }
}