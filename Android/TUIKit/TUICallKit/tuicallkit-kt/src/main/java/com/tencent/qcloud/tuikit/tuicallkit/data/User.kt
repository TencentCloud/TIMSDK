package com.tencent.qcloud.tuikit.tuicallkit.data

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import java.util.*

class User {
    public var id: String? = null
    public var avatar: LiveData<String> = LiveData()
    public var nickname: LiveData<String> = LiveData()

    public var callRole = LiveData<TUICallDefine.Role>()
    public var callStatus: LiveData<TUICallDefine.Status> = LiveData()
    public var audioAvailable: LiveData<Boolean> = LiveData()
    public var videoAvailable: LiveData<Boolean> = LiveData()
    public var playoutVolume: LiveData<Int> = LiveData()

    init {
        avatar.set("")
        nickname.set("")
        callStatus.set(TUICallDefine.Status.None)
        callRole.set(TUICallDefine.Role.None)
        audioAvailable.set(false)
        videoAvailable.set(false)
        playoutVolume.set(0)
    }

    fun clear() {
        avatar.set(null)
        nickname.set(null)
        callStatus.set(TUICallDefine.Status.None)
        callRole.set(TUICallDefine.Role.None)
        audioAvailable.set(false)
        videoAvailable.set(false)
        playoutVolume.set(0)

        avatar.removeAll()
        nickname.removeAll()
        callStatus.removeAll()
        callRole.removeAll()
        audioAvailable.removeAll()
        videoAvailable.removeAll()
        playoutVolume.removeAll()
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
                + ", avatar='" + avatar
                + ", nickname='" + nickname
                + ", callRole='" + callRole
                + ", callStates=" + callStatus
                + ", audioAvailable=" + audioAvailable
                + ", videoAvailable=" + videoAvailable
                + ", playoutVolume=" + playoutVolume
                + '}')
    }
}