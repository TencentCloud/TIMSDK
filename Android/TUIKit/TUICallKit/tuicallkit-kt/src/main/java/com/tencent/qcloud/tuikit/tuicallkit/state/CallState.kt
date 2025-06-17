package com.tencent.qcloud.tuikit.tuicallkit.state

import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.trtc.tuikit.common.livedata.LiveData

class CallState {
    var callId: String = ""
    var roomId: TUICommonDefine.RoomId? = null
    var chatGroupId: String? = ""
    var scene: LiveData<TUICallDefine.Scene> = LiveData(TUICallDefine.Scene.SINGLE_CALL)
    var mediaType: LiveData<TUICallDefine.MediaType> = LiveData(TUICallDefine.MediaType.Unknown)
    var callDurationCount: LiveData<Int> = LiveData(0)
    var networkQualityReminder: LiveData<Constants.NetworkQualityHint> = LiveData(Constants.NetworkQualityHint.None)

    fun reset() {
        callId = ""
        roomId = null
        chatGroupId = ""
        scene.set(TUICallDefine.Scene.SINGLE_CALL)
        mediaType.set(TUICallDefine.MediaType.Unknown)
        callDurationCount.set(0)
        networkQualityReminder.set(Constants.NetworkQualityHint.None)
    }

    override fun toString(): String {
        return "CallState{roomId=$roomId, callId=$callId, chatGroupId=$chatGroupId, scene=${scene.get()}, " +
                "mediaType=${mediaType.get()}," + " callDurationCount=${callDurationCount.get()}," +
                " networkQualityReminder=${networkQualityReminder.get()}}"
    }
}
