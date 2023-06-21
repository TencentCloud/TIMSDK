package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.group

import android.text.TextUtils
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class GroupCallerUserInfoViewModel {
    public var avatar = LiveData<String>()
    public var nickname = LiveData<String>()
    public var mediaType = LiveData<TUICallDefine.MediaType>()

    init {
        var user = findCaller()
        if (user != null) {
            avatar = user.avatar
            if (TextUtils.isEmpty(user.nickname.get())) {
                nickname.set(user.id)
            } else {
                nickname = user.nickname
            }
        }
        mediaType = TUICallState.instance.mediaType
    }

    private fun findCaller(): User? {
        for (user in TUICallState.instance.remoteUserList.get()) {
            if (TUICallDefine.Role.Caller == user.callRole.get()) {
                return user
            }
        }
        return null
    }
}