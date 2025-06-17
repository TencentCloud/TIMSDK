package com.tencent.qcloud.tuikit.tuicallkit.state

import com.tencent.qcloud.tuicore.util.SPUtils
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.feature.CallingBellFeature

class GlobalState private constructor() {
    var enableMultiDevice: Boolean = false
    var enableMuteMode: Boolean = SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT)
        .getBoolean(CallingBellFeature.PROFILE_MUTE_MODE, false)
    var enableFloatWindow: Boolean = true
    var enableIncomingBanner: Boolean = false
    var enableVirtualBackground: Boolean = false
    var orientation = Constants.Orientation.Portrait
    var enableForceUseV2API = false

    companion object {
        val instance: GlobalState by lazy { GlobalState() }
    }
}