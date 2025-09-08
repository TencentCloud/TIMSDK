package com.tencent.qcloud.tuikit.tuicallkit.state

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.AudioPlaybackDevice
import com.tencent.trtc.TRTCCloudDef
import com.trtc.tuikit.common.livedata.LiveData

class MediaState {
    var isMicrophoneMuted: LiveData<Boolean> = LiveData(false)

    // TODO:等 engine 适配完成后修改，当前直接使用 TRTC SDK 的定义
    var audioPlayoutDevice: LiveData<AudioPlaybackDevice> = LiveData(AudioPlaybackDevice.Speakerphone)

    var isCameraOpened: LiveData<Boolean> = LiveData(false)
    var isFrontCamera: LiveData<TUICommonDefine.Camera> = LiveData(TUICommonDefine.Camera.Front)

    var availableAudioDevices: LiveData<List<Int>> = LiveData(ArrayList())
    var selectedAudioDevice: LiveData<Int> = LiveData(TRTCCloudDef.TRTC_AUDIO_ROUTE_UNKNOWN)

    fun reset() {
        isMicrophoneMuted.set(false)
        audioPlayoutDevice.set(AudioPlaybackDevice.Speakerphone)

        isCameraOpened.set(false)
        isFrontCamera.set(TUICommonDefine.Camera.Front)

        availableAudioDevices.set(ArrayList())
        selectedAudioDevice.set(TRTCCloudDef.TRTC_AUDIO_ROUTE_UNKNOWN)
    }
}
