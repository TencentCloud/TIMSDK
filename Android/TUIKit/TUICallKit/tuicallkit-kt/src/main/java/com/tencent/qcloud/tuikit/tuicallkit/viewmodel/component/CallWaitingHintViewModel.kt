package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class CallWaitingHintViewModel {
    var callStatus = LiveData<TUICallDefine.Status>()
    var mediaType = LiveData<TUICallDefine.MediaType>()
    var callRole = LiveData<TUICallDefine.Role>()
    var scene = LiveData<TUICallDefine.Scene>()
    var networkReminder = LiveData<Constants.NetworkQualityHint>()

    init {
        callStatus = TUICallState.instance.selfUser.get().callStatus
        mediaType = TUICallState.instance.mediaType
        callRole = TUICallState.instance.selfUser.get().callRole
        scene = TUICallState.instance.scene
        networkReminder = TUICallState.instance.networkQualityReminder
    }
}