package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.single

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class VideoCallUserInfoViewModel {
    var avatar = LiveData<String>()
    var nickname = LiveData<String>()
    var mediaType = LiveData<TUICallDefine.MediaType>()
    var callStatus = LiveData<TUICallDefine.Status>()

    init {
        var userModel = TUICallState.instance.remoteUserList.get().first()
        avatar = userModel.avatar
        nickname = userModel.nickname
        mediaType = TUICallState.instance.mediaType
        callStatus = TUICallState.instance.selfUser.get().callStatus
    }
}