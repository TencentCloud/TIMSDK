package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.function

import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory

class VideoCallerWaitingViewModel {
    var isShowVirtualBackgroundButton = false
    var isCameraOpen = true
    var enableBlurBackground: LiveData<Boolean>

    init {
        isShowVirtualBackgroundButton = TUICallState.instance.showVirtualBackgroundButton
        enableBlurBackground = TUICallState.instance.enableBlurBackground
    }

    fun switchCamera() {
        var camera = TUICommonDefine.Camera.Back
        if (TUICallState.instance.isFrontCamera.get() == TUICommonDefine.Camera.Back) {
            camera = TUICommonDefine.Camera.Front
        }
        EngineManager.instance.switchCamera(camera)
    }

    fun openCamera() {
        isCameraOpen = true
        val camera = TUICallState.instance.isFrontCamera.get()
        val videoView = VideoViewFactory.instance.findVideoView(TUICallState.instance.selfUser.get().id)
        EngineManager.instance.openCamera(camera, videoView?.getVideoView(), null)
    }

    fun closeCamera() {
        isCameraOpen = false
        EngineManager.instance.closeCamera()
    }

    fun setBlurBackground() {
        EngineManager.instance.setBlurBackground(!TUICallState.instance.enableBlurBackground.get())
    }

    fun hangup() {
        EngineManager.instance.hangup(object : TUICommonDefine.Callback {
            override fun onSuccess() {}

            override fun onError(errCode: Int, errMsg: String?) {}

        })
    }
}