package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class CallWaitingHintViewModel {
    public var callStatus = LiveData<TUICallDefine.Status>()
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var callRole = LiveData<TUICallDefine.Role>()

    init {
        callStatus = TUICallState.instance.selfUser.get().callStatus
        mediaType = TUICallState.instance.mediaType
        callRole = TUICallState.instance.selfUser.get().callRole
    }
}