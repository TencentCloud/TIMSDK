package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.function

import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallEngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class VideoCallerWaitingViewModel {
    public var frontCamera = LiveData<Boolean>()

    private var isFrontCameraObserver = Observer<TUICommonDefine.Camera> {
        frontCamera.set(it == TUICommonDefine.Camera.Front)
    }

    init {
        frontCamera.set(TUICallState.instance.isFrontCamera.get() == TUICommonDefine.Camera.Front)
        addObserver()
    }

    private fun addObserver() {
        TUICallState.instance.isFrontCamera.observe(isFrontCameraObserver)
    }

    public fun removeObserver() {
        TUICallState.instance.isFrontCamera.removeObserver(isFrontCameraObserver)
    }

    fun switchCamera(camera: TUICommonDefine.Camera) {
        CallEngineManager.instance.switchCamera(camera)
    }

    fun hangup() {
        CallEngineManager.instance.hangup(object : TUICommonDefine.Callback {
            override fun onSuccess() {}

            override fun onError(errCode: Int, errMsg: String?) {}

        })
    }
}