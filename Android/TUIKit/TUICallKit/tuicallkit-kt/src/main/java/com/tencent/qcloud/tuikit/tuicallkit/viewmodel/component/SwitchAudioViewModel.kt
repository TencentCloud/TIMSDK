package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager

class SwitchAudioViewModel {
    fun switchCallMediaType(audio: TUICallDefine.MediaType) {
        EngineManager.instance.switchCallMediaType(audio)
    }
}