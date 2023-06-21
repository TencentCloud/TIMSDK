package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class VideoViewModel(user: User) {
    public var user: User? = null
    public var scene: LiveData<TUICallDefine.Scene>? = null

    init {
        this.user = user
        this.scene = TUICallState.instance.scene
    }
}