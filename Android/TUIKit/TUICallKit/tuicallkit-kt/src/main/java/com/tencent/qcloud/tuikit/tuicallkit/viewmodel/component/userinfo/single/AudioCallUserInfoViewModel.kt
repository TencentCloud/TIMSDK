package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.single

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class AudioCallUserInfoViewModel {
    var avatar = LiveData<String>()
    var nickname = LiveData<String>()
    var mediaType = LiveData<TUICallDefine.MediaType>()
    var callRole = LiveData<TUICallDefine.Role>()

    init {
        var userModel = TUICallState.instance.remoteUserList.get().first()
        avatar = userModel.avatar
        nickname = userModel.nickname
        mediaType = TUICallState.instance.mediaType
        callRole = TUICallState.instance.selfUser.get().callRole
    }
}