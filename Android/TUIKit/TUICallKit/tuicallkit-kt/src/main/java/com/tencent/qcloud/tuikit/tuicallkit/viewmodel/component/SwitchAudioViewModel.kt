package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallEngineManager

class SwitchAudioViewModel {
    fun switchCallMediaType(audio: TUICallDefine.MediaType) {
        CallEngineManager.instance.switchCallMediaType(audio)
    }
}