package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout

import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class VideoViewModel(user: User) {
    public var user: User? = null
    public var selfUser: User
    public var scene: LiveData<TUICallDefine.Scene>? = null
    public var isFrontCamera: TUICommonDefine.Camera
    public var showLargeViewUserId: LiveData<String>

    private val isFrontCameraObserver = Observer<TUICommonDefine.Camera> {
        isFrontCamera = it
    }

    init {
        this.user = user
        this.scene = TUICallState.instance.scene
        this.isFrontCamera = TUICallState.instance.isFrontCamera.get()
        selfUser = TUICallState.instance.selfUser.get()
        showLargeViewUserId = TUICallState.instance.showLargeViewUserId

        addObserver()
    }

    private fun addObserver() {
        TUICallState.instance.isFrontCamera.observe(isFrontCameraObserver)
    }

    public fun removeObserver() {
        TUICallState.instance.isFrontCamera.removeObserver(isFrontCameraObserver)
    }

}