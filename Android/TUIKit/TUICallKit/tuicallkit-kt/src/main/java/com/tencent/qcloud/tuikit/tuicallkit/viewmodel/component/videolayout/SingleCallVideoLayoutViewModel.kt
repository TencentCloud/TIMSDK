package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout

import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class SingleCallVideoLayoutViewModel {
    public var selfUser: User
    public var remoteUser: User
    public var isCameraOpen = LiveData<Boolean>()
    public var isFrontCamera = LiveData<TUICommonDefine.Camera>()
    public var currentReverseRenderView = false
    public var lastReverseRenderView = false
    public var isShowFullScreen = false

    init {
        selfUser = TUICallState.instance.selfUser.get()
        val remoteUserList = TUICallState.instance.remoteUserList.get()
        remoteUser = if (remoteUserList != null && remoteUserList.size > 0) {
            remoteUserList.first()
        } else {
            User()
        }
        isCameraOpen = TUICallState.instance.isCameraOpen
        isFrontCamera = TUICallState.instance.isFrontCamera
        lastReverseRenderView = TUICallState.instance.reverse1v1CallRenderView
    }

    public fun reverseRenderLayout(reverse: Boolean) {
        currentReverseRenderView = reverse
        TUICallState.instance.reverse1v1CallRenderView = reverse
    }

    public fun showFullScreen() {
        isShowFullScreen = !isShowFullScreen
        TUICallState.instance.isShowFullScreen.set(isShowFullScreen)
    }
}