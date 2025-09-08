package com.tencent.qcloud.tuikit.tuicallkit.state

import com.trtc.tuikit.common.livedata.LiveData

class ViewState {
    var reverse1v1CallRenderView = false
    var showLargeViewUserId: LiveData<String> = LiveData("")
    var isVirtualBackgroundOpened: LiveData<Boolean> = LiveData(false)
    val isScreenCleaned: LiveData<Boolean> = LiveData(false)
    val router: LiveData<ViewRouter> = LiveData(ViewRouter.None)
    var enterPipMode: LiveData<Boolean> = LiveData(false)

    fun reset() {
        reverse1v1CallRenderView = false
        showLargeViewUserId.set("")
        isVirtualBackgroundOpened.set(false)
        isScreenCleaned.set(false)
        router.set(ViewRouter.None)
        enterPipMode.set(false)
    }

    enum class ViewRouter {
        None,
        Banner,
        FullView,
        FloatView,
    }
}