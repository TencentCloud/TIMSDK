package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.function

import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallEngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class AudioAndVideoCalleeWaitingViewModel {
    public var mediaType = LiveData<TUICallDefine.MediaType>()

    init {
        mediaType = TUICallState.instance.mediaType
    }

    fun reject() {
        CallEngineManager.instance.reject(object : TUICommonDefine.Callback {
            override fun onSuccess() {}

            override fun onError(errCode: Int, errMsg: String?) {}
        })
    }

    fun accept() {
        CallEngineManager.instance.accept(object : TUICommonDefine.Callback{
            override fun onSuccess() {}

            override fun onError(errCode: Int, errMsg: String?) {}
        })
    }

}