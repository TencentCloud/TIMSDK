package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.single

import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class AudioCallUserInfoViewModel {
    public var avatar = LiveData<String>()
    public var nickname = LiveData<String>()
    public var callTag = LiveData<String>()
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var callStatus = LiveData<TUICallDefine.Status>()

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (TUICallDefine.Status.Waiting == it) {
            callTag.set(
                if (TUICallDefine.Role.Caller == TUICallState.instance.selfUser.get().callRole.get()) {
                    ServiceInitializer.getAppContext().getString(R.string.tuicalling_waiting_accept)
                } else {
                    ServiceInitializer.getAppContext().getString(R.string.tuicalling_invite_audio_call)
                }
            )
        } else if (TUICallDefine.Status.Accept == it) {
            callTag.set("")
        }
    }

    init {
        var userModel = TUICallState.instance.remoteUserList.get().first()
        avatar = userModel.avatar
        nickname = userModel.nickname

        callTag.set(
            if (TUICallDefine.Role.Caller == TUICallState.instance.selfUser.get().callRole.get()) {
                ServiceInitializer.getAppContext().getString(R.string.tuicalling_waiting_accept)
            } else {
                ServiceInitializer.getAppContext().getString(R.string.tuicalling_invite_audio_call)
            }
        )
        if (TUICallDefine.Status.Accept == TUICallState.instance.selfUser.get().callStatus.get()) {
            callTag.set("")
        }
        mediaType = TUICallState.instance.mediaType
        callStatus = TUICallState.instance.selfUser.get().callStatus
        addObserver()
    }

    private fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
    }

    public fun removeObserver() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
    }
}