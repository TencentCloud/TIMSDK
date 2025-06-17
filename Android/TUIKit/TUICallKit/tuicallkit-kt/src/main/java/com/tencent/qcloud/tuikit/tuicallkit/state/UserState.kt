package com.tencent.qcloud.tuikit.tuicallkit.state

import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.trtc.tuikit.common.livedata.LiveData

class UserState {
    var selfUser: LiveData<User> = LiveData(User())
    var remoteUserList: LiveData<LinkedHashSet<User>> = LiveData(LinkedHashSet())

    fun reset() {
        selfUser.get().reset()
        for (user in remoteUserList.get()) {
            user.reset()
        }
        remoteUserList.set(LinkedHashSet())
    }

    class User {
        var id: String = ""
        var nickname: LiveData<String> = LiveData("")
        var avatar: LiveData<String> = LiveData("")

        var callRole: TUICallDefine.Role = TUICallDefine.Role.None
        var callStatus: LiveData<TUICallDefine.Status> = LiveData(TUICallDefine.Status.None)

        var audioAvailable: LiveData<Boolean> = LiveData(false)
        var videoAvailable: LiveData<Boolean> = LiveData(false)
        var playoutVolume: LiveData<Int> = LiveData(0)
        var networkQualityReminder: LiveData<Boolean> = LiveData(false)

        fun reset() {
            avatar.set("")
            nickname.set("")
            callStatus.set(TUICallDefine.Status.None)
            callRole = TUICallDefine.Role.None
            audioAvailable.set(false)
            videoAvailable.set(false)
            playoutVolume.set(0)
            networkQualityReminder.set(false)
        }

        override fun equals(other: Any?): Boolean {
            if (other == null || this.javaClass != other.javaClass) {
                return false
            }
            if (this === other) {
                return true
            }
            val model = other as User
            return id == model.id
        }

        override fun toString(): String {
            return "User {id: $id, avatar: ${avatar.get()}, nickname: ${nickname.get()}, " +
                    "callRole: $callRole, callStatus: ${callStatus.get()}, " +
                    "audioAvailable: ${audioAvailable.get()}, videoAvailable: ${videoAvailable.get()}, " +
                    "playoutVolume: ${playoutVolume.get()}, networkQualityReminder: ${networkQualityReminder.get()}}"
        }
    }
}