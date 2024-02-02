package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.root

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class SingleCallViewModel {
    var callStatus = LiveData<TUICallDefine.Status>()
    var callRole = LiveData<TUICallDefine.Role>()
    var mediaType = LiveData<TUICallDefine.MediaType>()
    var isShowFullScreen = LiveData<Boolean>()
    var selfUser = LiveData<User>()

    init {
        callStatus = TUICallState.instance.selfUser.get().callStatus
        callRole = TUICallState.instance.selfUser.get().callRole
        mediaType = TUICallState.instance.mediaType
        isShowFullScreen = TUICallState.instance.isShowFullScreen
        selfUser = TUICallState.instance.selfUser
    }
}