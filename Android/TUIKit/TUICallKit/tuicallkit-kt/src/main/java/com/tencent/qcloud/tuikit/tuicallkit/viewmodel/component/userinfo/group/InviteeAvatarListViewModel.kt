package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.group

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import java.util.concurrent.CopyOnWriteArrayList

class InviteeAvatarListViewModel {
    public var inviteeUserList = LiveData<CopyOnWriteArrayList<User>>()

    private var remoteUserListObserver = Observer<LinkedHashSet<User>> {
        if (it != null && it.size > 0) {
            for (user in it) {
                if (!inviteeUserList.get().contains(user) && TUICallDefine.Role.Called == user.callRole.get()) {
                    inviteeUserList.add(user)
                }
            }
            for ((index, user) in inviteeUserList.get().withIndex()) {
                if (index == 0) {
                    continue
                }
                if (!it.contains(user)) {
                    inviteeUserList.remove(user)
                }
            }
        }
    }

    init {
        inviteeUserList.set(CopyOnWriteArrayList())
        inviteeUserList.get().add(TUICallState.instance.selfUser.get())
        for (user in TUICallState.instance.remoteUserList.get()) {
            if (TUICallDefine.Role.Called == user.callRole.get()) {
                inviteeUserList.get().add(user)
            }
        }

        addObserver()
    }

    private fun addObserver() {
        TUICallState.instance.remoteUserList.observe(remoteUserListObserver)
    }

    fun removeObserver() {
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }

}