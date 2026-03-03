package com.tencent.qcloud.tuikit.tuicallkit.manager

import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore

object PushManager {
    const val PUSH_UNREGISTER = -1
    const val PUSH_REGISTER_SUCCESS = 0
    const val PUSH_REGISTER_FAILED = 1

    private const val METHOD_KEY = "callPushMethod"
    private const val METHOD_SUB_KEY = "callPushSubMethod"

    fun getPushData(): PushData {
        if (TUICore.getService(TUIConstants.TIMPush.SERVICE_NAME) == null) {
            return PushData()
        }

        val pushData = PushData()
        pushData.channelId = TUIConfig.getCustomData("pushChannelId") as? Int ?: -1
        pushData.status = TUIConfig.getCustomData("pushStatus") as? Int ?: PUSH_UNREGISTER
        return pushData
    }

    fun disableRequestPostNotificationPermission() {
        val map = HashMap<String, Any>()
        map[METHOD_SUB_KEY] = "disableRequestPostNotificationPermission"
        map["disable"] = true
        TUICore.callService(TUIConstants.TIMPush.SERVICE_NAME, METHOD_KEY, map, null)
    }
}

/**
 * @see TUIConstants.DeviceInfo
 */
class PushData {
    var channelId: Int = -1                       // current Push channelId
    var status: Int = PushManager.PUSH_UNREGISTER // current Push register status: -1-unregister, 0-success; 1-failed

    override fun toString(): String {
        var channel = ""
        when (channelId) {
            TUIConstants.DeviceInfo.BRAND_XIAOMI -> channel = "Xiaomi"
            TUIConstants.DeviceInfo.BRAND_HUAWEI -> channel = "Huawei"
            TUIConstants.DeviceInfo.BRAND_GOOGLE_ELSE -> channel = "Google"
            TUIConstants.DeviceInfo.BRAND_MEIZU -> channel = "Meizu"
            TUIConstants.DeviceInfo.BRAND_OPPO -> channel = "OPPO"
            TUIConstants.DeviceInfo.BRAND_VIVO -> channel = "VIVO"
            TUIConstants.DeviceInfo.BRAND_HONOR -> channel = "Honor"
        }
        var pushStatus = ""
        when (this.status) {
            PushManager.PUSH_UNREGISTER -> pushStatus = "unregister"
            PushManager.PUSH_REGISTER_SUCCESS -> pushStatus = "success"
            PushManager.PUSH_REGISTER_FAILED -> pushStatus = "failed"
        }
        return "PushData(channelId=$channel, status=$pushStatus)"
    }
}