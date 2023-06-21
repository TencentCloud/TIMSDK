package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.floatview

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatWindowService
import com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow.FloatingWindowView

class FloatingWindowButtonModel {
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var enableFloatWindow : Boolean

    init {
        mediaType = TUICallState.instance.mediaType
        enableFloatWindow = TUICallState.instance.enableFloatWindow
    }

    fun startFloatService(view: FloatingWindowView) {
        FloatWindowService.startFloatService(view)
    }
}