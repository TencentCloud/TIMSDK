package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.floatview

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatWindowService
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView

class FloatingWindowButtonModel {
    public var scene = LiveData<TUICallDefine.Scene>()
    public var enableFloatWindow: Boolean
    public var callStatus = LiveData<TUICallDefine.Status>()
    public var callRole = LiveData<TUICallDefine.Role>()

    init {
        scene = TUICallState.instance.scene
        enableFloatWindow = TUICallState.instance.enableFloatWindow
        callStatus = TUICallState.instance.selfUser.get().callStatus
        callRole = TUICallState.instance.selfUser.get().callRole
    }

    fun startFloatService(view: BaseCallView) {
        FloatWindowService.startFloatService(view)
    }
}