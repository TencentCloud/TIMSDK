package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout

import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class VideoViewModel(user: User) {
    var user: User? = null
    var selfUser: User
    var scene: LiveData<TUICallDefine.Scene>? = null
    var isFrontCamera: LiveData<TUICommonDefine.Camera>
    var showLargeViewUserId: LiveData<String>

    init {
        this.user = user
        this.scene = TUICallState.instance.scene
        this.isFrontCamera = TUICallState.instance.isFrontCamera
        selfUser = TUICallState.instance.selfUser.get()
        showLargeViewUserId = TUICallState.instance.showLargeViewUserId
    }
}