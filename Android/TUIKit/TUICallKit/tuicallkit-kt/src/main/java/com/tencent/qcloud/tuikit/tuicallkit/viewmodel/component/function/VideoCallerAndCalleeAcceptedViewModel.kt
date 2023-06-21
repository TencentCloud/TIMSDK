package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.function

import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallEngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory

class VideoCallerAndCalleeAcceptedViewModel {
    public var isMicMute = LiveData<Boolean>()
    public var isSpeaker = LiveData<Boolean>()
    public var isCameraOpen = LiveData<Boolean>()
    public var frontCamera = LiveData<Boolean>()

    private var isFrontCameraObserver = Observer<TUICommonDefine.Camera> {
        frontCamera.set(it == TUICommonDefine.Camera.Front)
    }

    private var audioPlayoutDeviceObserver = Observer<TUICommonDefine.AudioPlaybackDevice> {
        isSpeaker.set(it == TUICommonDefine.AudioPlaybackDevice.Speakerphone)
    }

    init {
        isMicMute = TUICallState.instance.isMicrophoneMute
        isSpeaker.set(TUICallState.instance.audioPlayoutDevice.get() == TUICommonDefine.AudioPlaybackDevice.Speakerphone)
        isCameraOpen = TUICallState.instance.isCameraOpen
        frontCamera.set(TUICallState.instance.isFrontCamera.get() == TUICommonDefine.Camera.Front)

        addObserver()
    }

    private fun addObserver() {
        TUICallState.instance.isFrontCamera.observe(isFrontCameraObserver)
        TUICallState.instance.audioPlayoutDevice?.observe(audioPlayoutDeviceObserver)
    }

    public fun removeObserver() {
        TUICallState.instance.isFrontCamera.removeObserver(isFrontCameraObserver)
        TUICallState.instance.audioPlayoutDevice?.removeObserver(audioPlayoutDeviceObserver)
    }

    fun closeCamera() {
        CallEngineManager.instance.closeCamera()
    }

    fun openCamera(frontCamera: Boolean?) {
        var camera: TUICommonDefine.Camera = if (frontCamera!!) {
            TUICommonDefine.Camera.Front
        } else {
            TUICommonDefine.Camera.Back
        }
        var videoView = VideoViewFactory.instance.videoEntityList.get(TUICallState.instance.selfUser.get().id)?.videoView
        CallEngineManager.instance.openCamera(camera, videoView?.getVideoView(), object :
            TUICommonDefine.Callback {
            override fun onSuccess() {}

            override fun onError(errCode: Int, errMsg: String?) {}
        })
    }

    fun switchCamera(camera: TUICommonDefine.Camera) {
        CallEngineManager.instance.switchCamera(camera)
    }

    fun openMicrophone() {
        CallEngineManager.instance.openMicrophone(object : TUICommonDefine.Callback {
            override fun onSuccess() {
                TUICallState.instance.isMicrophoneMute.set(false)
            }

            override fun onError(errCode: Int, errMsg: String?) {}
        })
    }

    fun closeMicrophone() {
        TUICallState.instance.isMicrophoneMute.set(true)
        CallEngineManager.instance.closeMicrophone()
    }

    fun selectAudioPlaybackDevice(type: TUICommonDefine.AudioPlaybackDevice) {
        CallEngineManager.instance.selectAudioPlaybackDevice(type)
    }

    fun hangup() {
        CallEngineManager.instance.hangup(object : TUICommonDefine.Callback {
            override fun onSuccess() {}

            override fun onError(errCode: Int, errMsg: String?) {}

        })
    }
}