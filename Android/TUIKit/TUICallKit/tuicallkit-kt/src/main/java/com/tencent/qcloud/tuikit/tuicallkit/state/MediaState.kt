package com.tencent.qcloud.tuikit.tuicallkit.state

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.AudioPlaybackDevice
import com.trtc.tuikit.common.livedata.LiveData

class MediaState {
    var isMicrophoneMuted: LiveData<Boolean> = LiveData(false)
    var audioPlayoutDevice: LiveData<AudioPlaybackDevice> = LiveData(AudioPlaybackDevice.Speakerphone)

    var isCameraOpened: LiveData<Boolean> = LiveData(false)
    var isFrontCamera: LiveData<TUICommonDefine.Camera> = LiveData(TUICommonDefine.Camera.Front)

    fun reset() {
        isMicrophoneMuted.set(false)
        audioPlayoutDevice.set(AudioPlaybackDevice.Speakerphone)

        isCameraOpened.set(false)
        isFrontCamera.set(TUICommonDefine.Camera.Front)
    }
}
