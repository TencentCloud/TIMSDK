package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.single

import android.text.TextUtils
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class VideoCallUserInfoViewModel {
    public var avatar = LiveData<String>()
    public var nickname = LiveData<String>()
    public var callTag: String? = ""
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var callStatus = LiveData<TUICallDefine.Status>()

    init {
        var userModel = TUICallState.instance.remoteUserList.get().first()
        avatar = userModel.avatar
        nickname = userModel.nickname
        callTag = if (TUICallDefine.Role.Caller == TUICallState.instance.selfUser.get().callRole.get()) {
            ServiceInitializer.getAppContext().getString(R.string.tuicalling_waiting_accept)
        } else {
            ServiceInitializer.getAppContext().getString(R.string.tuicalling_invite_video_call)
        }

        mediaType = TUICallState.instance.mediaType
        callStatus = TUICallState.instance.selfUser.get().callStatus
    }
}