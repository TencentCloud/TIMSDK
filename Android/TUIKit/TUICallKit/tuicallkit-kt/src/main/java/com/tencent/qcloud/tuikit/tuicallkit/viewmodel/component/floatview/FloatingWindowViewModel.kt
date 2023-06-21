package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.floatview

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallEvent
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatWindowService

class FloatingWindowViewModel {
    public var selfUser: User? = null
    public var remoteUser: User? = null
    public var remoteUserList: LinkedHashSet<User>
    public var timeCount = LiveData<Int>()
    public var scene = LiveData<TUICallDefine.Scene>()
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var event = LiveData<TUICallEvent>()

    init {
        this.scene = TUICallState.instance.scene
        this.selfUser = TUICallState.instance.selfUser.get()
        this.mediaType = TUICallState.instance.mediaType
        this.event = TUICallState.instance.event
        remoteUserList = TUICallState.instance.remoteUserList.get()
        if (remoteUserList != null && remoteUserList.size > 0) {
            remoteUser = remoteUserList.first()
        } else {
            remoteUser = User()
        }
        this.timeCount = TUICallState.instance.timeCount
    }

    fun stopFloatService() {
        FloatWindowService.stopService()
    }
}