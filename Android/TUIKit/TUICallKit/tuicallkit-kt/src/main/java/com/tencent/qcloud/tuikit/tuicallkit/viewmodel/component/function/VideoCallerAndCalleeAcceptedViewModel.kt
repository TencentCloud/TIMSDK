package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.function

import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory

class VideoCallerAndCalleeAcceptedViewModel {
    var isMicMute = LiveData<Boolean>()
    var isSpeaker = LiveData<Boolean>()
    var isCameraOpen = LiveData<Boolean>()
    var frontCamera = LiveData<Boolean>()
    var isBottomViewExpanded = LiveData<Boolean>()
    var showLargerViewUserId = LiveData<String>()
    var scene = LiveData<TUICallDefine.Scene>()

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

        isBottomViewExpanded = TUICallState.instance.isBottomViewExpand
        showLargerViewUserId = TUICallState.instance.showLargeViewUserId
        scene = TUICallState.instance.scene

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

    fun updateView() {
        TUICallState.instance.isBottomViewExpand.set(!TUICallState.instance.isBottomViewExpand.get())
    }

    fun closeCamera() {
        EngineManager.instance.closeCamera()
    }

    fun openCamera(frontCamera: Boolean?) {
        var camera: TUICommonDefine.Camera = if (frontCamera!!) {
            TUICommonDefine.Camera.Front
        } else {
            TUICommonDefine.Camera.Back
        }
        val videoView =
            VideoViewFactory.instance.videoEntityList.get(TUICallState.instance.selfUser.get().id)?.videoView
        EngineManager.instance.openCamera(camera, videoView?.getVideoView(), object :
            TUICommonDefine.Callback {
            override fun onSuccess() {}

            override fun onError(errCode: Int, errMsg: String?) {}
        })

        updateGroupCallLargeView()
    }

    private fun updateGroupCallLargeView() {
        if (scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            return
        }
        if (TUICallState.instance.showLargeViewUserId.get() != TUICallState.instance.selfUser.get().id) {
            TUICallState.instance.showLargeViewUserId.set(TUICallState.instance.selfUser.get().id)
        }
    }

    fun switchCamera(camera: TUICommonDefine.Camera) {
        EngineManager.instance.switchCamera(camera)
    }

    fun openMicrophone() {
        EngineManager.instance.openMicrophone(object : TUICommonDefine.Callback {
            override fun onSuccess() {
                TUICallState.instance.isMicrophoneMute.set(false)
            }

            override fun onError(errCode: Int, errMsg: String?) {}
        })
    }

    fun closeMicrophone() {
        TUICallState.instance.isMicrophoneMute.set(true)
        EngineManager.instance.closeMicrophone()
    }

    fun selectAudioPlaybackDevice(type: TUICommonDefine.AudioPlaybackDevice) {
        EngineManager.instance.selectAudioPlaybackDevice(type)
    }

    fun hangup() {
        EngineManager.instance.hangup(object : TUICommonDefine.Callback {
            override fun onSuccess() {}

            override fun onError(errCode: Int, errMsg: String?) {}

        })
    }
}