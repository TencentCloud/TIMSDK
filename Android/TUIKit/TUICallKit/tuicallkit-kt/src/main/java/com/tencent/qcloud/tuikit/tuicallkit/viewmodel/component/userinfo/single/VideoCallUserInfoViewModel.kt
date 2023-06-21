package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.single

import android.text.TextUtils
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class VideoCallUserInfoViewModel {
    public var userAvatar: String? = ""
    public var userName: String? = ""
    public var callTag: String? = ""
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var callStatus = LiveData<TUICallDefine.Status>()

    init {
        var userModel = if (TUICallDefine.Role.Caller == TUICallState.instance.selfUser.get().callRole.get()
            && !TUICallState.instance.remoteUserList.get().isEmpty()
        ) {
            TUICallState.instance.remoteUserList.get().first()
        } else {
            TUICallState.instance.selfUser.get()
        }
        userAvatar = userModel.avatar.get()
        userName = if (TextUtils.isEmpty(userModel.nickname.get())) userModel.id else userModel.nickname.get()
        callTag = if (TUICallDefine.Role.Caller == TUICallState.instance.selfUser.get().callRole.get()) {
            ServiceInitializer.getAppContext().getString(R.string.tuicalling_waiting_accept)
        } else {
            ServiceInitializer.getAppContext().getString(R.string.tuicalling_invite_video_call)
        }

        mediaType = TUICallState.instance.mediaType
        callStatus = TUICallState.instance.selfUser.get().callStatus
    }
}