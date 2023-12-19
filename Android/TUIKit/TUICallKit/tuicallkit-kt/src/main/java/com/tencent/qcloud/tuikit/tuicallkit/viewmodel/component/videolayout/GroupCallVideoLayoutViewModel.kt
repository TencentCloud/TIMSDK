package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout

import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import java.util.concurrent.CopyOnWriteArrayList

class GroupCallVideoLayoutViewModel {
    public var userList = LiveData<CopyOnWriteArrayList<User>>()
    public var isCameraOpen = LiveData<Boolean>()
    public var isFrontCamera = LiveData<TUICommonDefine.Camera>()
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var changedUser = LiveData<User>()
    public var showLargeViewUserId = LiveData<String>()

    private var remoteUserListObserver = Observer<LinkedHashSet<User>> {
        if (it != null && it.size > 0) {
            for (user in it) {
                if (!userList.get().contains(user)) {
                    userList.get().add(user)
                    changedUser.set(user)
                }
            }
            for ((index, user) in userList.get().withIndex()) {
                if (index == 0) {
                    continue
                }
                if (!it.contains(user)) {
                    user.callStatus.set(TUICallDefine.Status.None)
                    userList.get().remove(user)
                    changedUser.set(user)
                }
            }
        }
    }

    init {
        isCameraOpen = TUICallState.instance.isCameraOpen
        isFrontCamera = TUICallState.instance.isFrontCamera
        mediaType = TUICallState.instance.mediaType
        changedUser.set(null)
        userList.set(CopyOnWriteArrayList())
        userList.get().add(TUICallState.instance.selfUser.get())
        userList.get().addAll(TUICallState.instance.remoteUserList.get())
        showLargeViewUserId = TUICallState.instance.showLargeViewUserId

        addObserver()
    }

    private fun addObserver() {
        TUICallState.instance.remoteUserList.observe(remoteUserListObserver)
    }

    public fun removeObserver() {
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }

    fun updateShowLargeViewUserId(userId: String?) {
        TUICallState.instance.showLargeViewUserId.set(userId)
    }

    fun updateBottomViewExpanded(isExpand: Boolean) {
        if (isExpand != TUICallState.instance.isBottomViewExpand.get()) {
            TUICallState.instance.isBottomViewExpand.set(!TUICallState.instance.isBottomViewExpand.get())
        }
    }
}