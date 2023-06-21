package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class CallTimerViewModel {
    public var timeCount = LiveData<Int>()
    public var callStatus = LiveData<TUICallDefine.Status>()
    public var mediaType = LiveData<TUICallDefine.MediaType>()

    init {
        timeCount = TUICallState.instance.timeCount
        callStatus = TUICallState.instance.selfUser.get().callStatus
        mediaType = TUICallState.instance.mediaType
    }
}