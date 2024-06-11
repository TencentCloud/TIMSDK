package com.tencent.qcloud.tuikit.tuicallkit.data

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import java.util.Objects

class User {
    var id: String? = null
    var avatar: LiveData<String> = LiveData()
    var nickname: LiveData<String> = LiveData()

    var callRole = LiveData<TUICallDefine.Role>()
    var callStatus: LiveData<TUICallDefine.Status> = LiveData()
    var audioAvailable: LiveData<Boolean> = LiveData()
    var videoAvailable: LiveData<Boolean> = LiveData()
    var playoutVolume: LiveData<Int> = LiveData()
    var networkQualityReminder: LiveData<Boolean> = LiveData()

    init {
        avatar.set("")
        nickname.set("")
        callStatus.set(TUICallDefine.Status.None)
        callRole.set(TUICallDefine.Role.None)
        audioAvailable.set(false)
        videoAvailable.set(false)
        playoutVolume.set(0)
        networkQualityReminder.set(false)
    }

    fun clear() {
        avatar.set(null)
        nickname.set(null)
        callStatus.set(TUICallDefine.Status.None)
        callRole.set(TUICallDefine.Role.None)
        audioAvailable.set(false)
        videoAvailable.set(false)
        playoutVolume.set(0)
        networkQualityReminder.set(false)

        avatar.removeAll()
        nickname.removeAll()
        callStatus.removeAll()
        callRole.removeAll()
        audioAvailable.removeAll()
        videoAvailable.removeAll()
        playoutVolume.removeAll()
        networkQualityReminder.removeAll()
    }

    override fun equals(o: Any?): Boolean {
        if (this === o) {
            return true
        }
        if (o == null || javaClass != o.javaClass) {
            return false
        }
        val model = o as User
        return id == model.id
    }

    override fun hashCode(): Int {
        return Objects.hash(id)
    }

    override fun toString(): String {
        return ("User {"
                + "id='" + id
                + ", avatar='" + avatar.get()
                + ", nickname='" + nickname.get()
                + ", callRole='" + callRole.get()
                + ", callStates=" + callStatus.get()
                + ", audioAvailable=" + audioAvailable.get()
                + ", videoAvailable=" + videoAvailable.get()
                + ", playoutVolume=" + playoutVolume.get()
                + ", networkQualityReminder=" + networkQualityReminder.get()
                + '}')
    }
}