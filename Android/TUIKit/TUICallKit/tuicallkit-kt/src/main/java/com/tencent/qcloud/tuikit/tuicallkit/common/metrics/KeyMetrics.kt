package com.tencent.qcloud.tuikit.tuicallkit.common.utils

import com.tencent.cloud.tuikit.engine.common.ContextProvider
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.liteav.base.Log
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.trtc.TRTCCloud
import com.trtc.tuikit.common.util.TUIBuild
import org.json.JSONException
import org.json.JSONObject
import java.util.concurrent.atomic.AtomicBoolean

object KeyMetrics {
    private const val TAG = "KeyMetrics"
    private const val API_REPORT_ROOM_ENGINE_EVENT = "reportRoomEngineEvent"

    private val hasPendingWakeup = AtomicBoolean(false)

    enum class EventId(val value: Int) {
        RECEIVED(171010),
        WAKEUP(171011),
        WAKEUP_BY_PUSH(171012),
    }

    fun countUV(eventId: EventId, callId: String) {
        when (eventId) {
            EventId.RECEIVED -> {
                hasPendingWakeup.set(true)
                countEvent(eventId, callId)
            }

            EventId.WAKEUP -> {
                if (hasPendingWakeup.compareAndSet(true, false)) {
                    countEvent(eventId, callId)
                }
            }

            EventId.WAKEUP_BY_PUSH -> countEvent(eventId, callId)
        }
    }

    fun reset() {
        hasPendingWakeup.set(false)
    }

    fun flushMetrics() {
        try {
            val paramsJson = JSONObject().apply {
                put("sdkAppId", TUILogin.getSdkAppId())
                put("report", "report")
            }
            val jsonParams = JSONObject().apply {
                put("api", "KeyMetricsStats")
                put("params", paramsJson)
            }
            TRTCCloud.sharedInstance(ContextProvider.getApplicationContext()).callExperimentalAPI(jsonParams.toString())
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }

    private fun countEvent(eventId: EventId, callId: String) {
        trackForKibana(eventId, callId)
        trackForTRTC(eventId)
    }

    private fun trackForKibana(eventId: EventId, callId: String) {
        try {
            val extensionJson = buildExtensionJson(callId)
            val payload = buildEventPayload(eventId, extensionJson.toString())

            V2TIMManager.getInstance().callExperimentalAPI(API_REPORT_ROOM_ENGINE_EVENT, payload.toString(),
                object : V2TIMValueCallback<Any?> {
                    override fun onSuccess(data: Any?) {
                        Log.i(TAG, "trackForKibana success: eventId=$eventId")
                    }

                    override fun onError(code: Int, desc: String) {
                        Log.e(TAG, "trackForKibana failed: code=$code, desc=$desc")
                    }
                }
            )
        } catch (e: Exception) {
            Log.e(TAG, "trackForKibana exception: eventId=$eventId", e)
        }
    }

    private fun trackForTRTC(eventId: EventId) {
        try {
            val paramsJson = JSONObject().apply {
                put("opt", "CountPV")
                put("key", eventId.value)
                put("withInstanceTrace", false)
                put("version", Constants.VERSION)
            }
            val jsonParams = JSONObject().apply {
                put("api", "KeyMetricsStats")
                put("params", paramsJson)
            }

            TRTCCloud.sharedInstance(ContextProvider.getApplicationContext()).callExperimentalAPI(jsonParams.toString())
        } catch (e: JSONException) {
            Log.e(TAG, "trackForTRTC call exception: eventId=$eventId", e)
            e.printStackTrace()
        }

        if (TUILogin.getSdkAppId() > 0) {
            flushMetrics()
        }
    }

    private fun buildExtensionJson(callId: String): JSONObject {
        return JSONObject().apply {
            // Basic Info
            put(JsonKeys.CALL_ID, callId)
            put(JsonKeys.INT_ROOM_ID, CallManager.instance.callState.roomId?.intRoomId ?: 0)
            put(JsonKeys.STR_ROOM_ID, CallManager.instance.callState.roomId?.strRoomId ?: "")
            put(JsonKeys.UI_KIT_VERSION, Constants.VERSION)

            // Platform Info
            put(JsonKeys.PLATFORM, "android")
            put(JsonKeys.FRAMEWORK, Constants.framework)
            put(JsonKeys.DEVICE_BRAND, TUIBuild.getBrand())
            put(JsonKeys.DEVICE_MODEL, TUIBuild.getModel())
            put(JsonKeys.ANDROID_VERSION, TUIBuild.getVersion())
            put(JsonKeys.IS_FOREGROUND, DeviceUtils.isAppRunningForeground(TUIConfig.getAppContext()))
            put(JsonKeys.IS_SCREEN_LOCKED, DeviceUtils.isScreenLocked(TUIConfig.getAppContext()))
            put(
                JsonKeys.HAS_FLOATING_WINDOW_PERMISSION,
                PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()
            )
            put(
                JsonKeys.HAS_BACKGROUND_LAUNCH_PERMISSION,
                PermissionRequester.newInstance(PermissionRequester.BG_START_PERMISSION).has()
            )
            put(JsonKeys.HAS_NOTIFICATION_PERMISSION, PermissionRequest.isNotificationEnabled())
        }
    }

    private fun buildEventPayload(eventId: EventId, extensionMessage: String): JSONObject {
        return JSONObject().apply {
            put(JsonKeys.EVENT_ID, eventId.value)
            put(JsonKeys.EVENT_CODE, 0)
            put(JsonKeys.EVENT_RESULT, 0)
            put(JsonKeys.EVENT_MESSAGE, Constants.VERSION)
            put(JsonKeys.MORE_MESSAGE, "")
            put(JsonKeys.EXTENSION_MESSAGE, extensionMessage)
        }
    }

    private object JsonKeys {
        // Event Payload Keys
        const val EVENT_ID = "event_id"
        const val EVENT_CODE = "event_code"
        const val EVENT_RESULT = "event_result"
        const val EVENT_MESSAGE = "event_message"
        const val MORE_MESSAGE = "more_message"
        const val EXTENSION_MESSAGE = "extension_message"

        // Basic Info Keys
        const val CALL_ID = "call_id"
        const val INT_ROOM_ID = "int_room_id"
        const val STR_ROOM_ID = "str_room_id"
        const val UI_KIT_VERSION = "ui_kit_version"

        // Platform Info Keys
        const val PLATFORM = "platform"
        const val FRAMEWORK = "framework"
        const val DEVICE_BRAND = "device_brand"
        const val DEVICE_MODEL = "device_model"
        const val ANDROID_VERSION = "android_version"
        const val IS_FOREGROUND = "is_foreground"
        const val IS_SCREEN_LOCKED = "is_screen_locked"
        const val HAS_FLOATING_WINDOW_PERMISSION = "has_floating_window_permission"
        const val HAS_BACKGROUND_LAUNCH_PERMISSION = "has_background_launch_permission"
        const val HAS_NOTIFICATION_PERMISSION = "has_notification_permission"
    }
}