package com.tencent.qcloud.tuikit.tuicallkit.manager

import android.content.Context
import android.util.Log
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallEngine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.imsdk.BaseConstants
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.liteav.TXLiteAVCode
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter
import com.tencent.qcloud.tuicore.util.SPUtils
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.manager.feature.CallingBellFeature
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.state.ViewState
import com.tencent.trtc.TRTCCloud
import com.trtc.tuikit.common.foregroundservice.AudioForegroundService
import com.trtc.tuikit.common.foregroundservice.VideoForegroundService
import io.trtc.tuikit.atomicx.widget.basicwidget.toast.AtomicToast
import io.trtc.tuikit.atomicxcore.api.CompletionHandler
import io.trtc.tuikit.atomicxcore.api.ai.AITranscriberStore
import io.trtc.tuikit.atomicxcore.api.ai.SourceLanguage
import io.trtc.tuikit.atomicxcore.api.ai.TranscriberConfig
import io.trtc.tuikit.atomicxcore.api.ai.TranslationLanguage
import io.trtc.tuikit.atomicxcore.api.call.CallMediaType
import io.trtc.tuikit.atomicxcore.api.call.CallParams
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.device.AudioRoute
import io.trtc.tuikit.atomicxcore.api.device.DeviceStore
import io.trtc.tuikit.atomicxcore.api.login.LoginStore
import org.json.JSONArray
import org.json.JSONObject

class CallManager private constructor(context: Context) {
    private val context: Context = context.applicationContext
    val viewState: ViewState = ViewState()

    fun reset() {
        viewState.reset()
    }

    fun calls(
        userIdList: List<String>, mediaType: CallMediaType, params: CallParams?,
        completion: CompletionHandler?
    ) {
        Logger.i(TAG, "calls, userIdList: $userIdList, mediaType: $mediaType, params: $params")
        if (userIdList.size >= Constants.MAX_USER) {
            AtomicToast.show(context, context.getString(R.string.callkit_user_exceed_limit), AtomicToast.Style.ERROR)
            Logger.e(TAG, "calls failed, exceeding max user number: 9")
            completion?.onFailure(TUICallDefine.ERROR_PARAM_INVALID, "calls failed, exceeding max user number")
            return
        }

        CallStore.shared.calls(userIdList, mediaType, params, object : CompletionHandler {
            override fun onSuccess() {
                Logger.i(TAG, "calls success. list: $userIdList")
                completion?.onSuccess()
            }

            override fun onFailure(code: Int, desc: String) {
                Logger.e(TAG, "calls failed, errCode: $code, errMsg: $desc")
                val errMessage: String = convertErrorMsg(code, desc)
                AtomicToast.show(context, errMessage, AtomicToast.Style.ERROR)
                completion?.onFailure(code, errMessage)
            }
        })
    }

    fun join(callId: String?, callback: TUICommonDefine.Callback?) {
        Logger.i(TAG, "join, callId: $callId")
        if (callId.isNullOrEmpty()) {
            Logger.e(TAG, "join failed, callId is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "join failed, callId is empty")
            return
        }

        CallStore.shared.join(callId, object : CompletionHandler {
            override fun onSuccess() {
                callback?.onSuccess()
            }

            override fun onFailure(code: Int, desc: String) {
                Logger.e(TAG, "join failed callId: $callId, errCode: $code, errMsg: $desc")
                ToastUtil.toastLongMessage(convertErrorMsg(code, desc))
                callback?.onError(code, desc)
            }
        })
    }

    fun inviteUser(userIdList: List<String?>?, completion: CompletionHandler?) {
        Logger.i(TAG, "inviteUser, userIdList: $userIdList")
        val filteredList = userIdList?.filterNotNull()?.distinct() ?: emptyList()
        if (filteredList.isEmpty()) {
            Logger.e(TAG, "inviteUser failed, userIdList is empty")
            return
        }
        val params = CallParams()
        CallStore.shared
            .invite(filteredList, params, object : CompletionHandler {

                override fun onSuccess() {
                    Logger.i(TAG, "inviteUser success")
                    completion?.onSuccess()
                }

                override fun onFailure(code: Int, desc: String) {
                    Logger.e(TAG, "inviteUser failed, errCode: $code, errMsg: $desc")
                    completion?.onFailure(code, desc)
                }
            })
    }

    fun reject(completion: CompletionHandler?) {
        Logger.i(TAG, "reject")
        CallStore.shared.reject(object : CompletionHandler {
            override fun onSuccess() {
                completion?.onSuccess()
            }

            override fun onFailure(code: Int, desc: String) {
                Logger.e(TAG, "reject failed, errorCode: $code, errMsg: $desc")
                completion?.onFailure(code, desc)
            }
        })
        reset()
    }

    fun hangup(completion: CompletionHandler?) {
        Logger.i(TAG, "hangup")
        CallStore.shared.hangup(object : CompletionHandler {
            override fun onSuccess() {
                completion?.onSuccess()
            }

            override fun onFailure(code: Int, desc: String) {
                Logger.e(TAG, "hangup failed, errorCode: $code, errMsg: $desc")
                completion?.onFailure(code, desc)
            }
        })
        reset()
    }

    fun selectAudioPlaybackDevice(device: TUICommonDefine.AudioPlaybackDevice) {
        val currentAudioRoute =
            if (device == TUICommonDefine.AudioPlaybackDevice.Speakerphone) AudioRoute.SPEAKERPHONE else AudioRoute.EARPIECE
        DeviceStore.shared().setAudioRoute(currentAudioRoute)
    }

    fun enableMultiDeviceAbility(enable: Boolean, completion: CompletionHandler?) {
        Logger.i(TAG, "enableMultiDeviceAbility, enable: $enable")
        TUICallEngine.createInstance(context).enableMultiDeviceAbility(enable, object : TUICommonDefine.Callback {
            override fun onSuccess() {
                completion?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String?) {
                completion?.onFailure(errCode, errMsg ?: "")
            }

        })
    }

    fun setSelfInfo(nickname: String?, avatar: String?, completion: CompletionHandler?) {
        Logger.i(TAG, "setSelfInfo, nickname: $nickname, avatar: $avatar")
        TUICallEngine.createInstance(context).setSelfInfo(nickname, avatar, object : TUICommonDefine.Callback {
            override fun onSuccess() {
                completion?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String?) {
                completion?.onFailure(errCode, errMsg ?: "")
            }
        })
    }

    fun setCallingBell(filePath: String?) {
        Logger.i(TAG, "setCallingBell, filePath: $filePath")
        SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT).put(CallingBellFeature.PROFILE_CALL_BELL, filePath)
    }

    fun enableMuteMode(enable: Boolean) {
        Logger.i(TAG, "enableMuteMode, enable: $enable")
        GlobalState.instance.enableMuteMode = enable
        SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT).put(CallingBellFeature.PROFILE_MUTE_MODE, enable)
    }

    fun enableFloatWindow(enable: Boolean) {
        Logger.i(TAG, "enableFloatWindow, enable: $enable")
        GlobalState.instance.enableFloatWindow = enable
    }

    fun enableVirtualBackground(enable: Boolean) {
        Logger.i(TAG, "enableVirtualBackground, enable: $enable")
        GlobalState.instance.enableVirtualBackground = enable
        val data = HashMap<String, Any>()
        data[Constants.KEY_VIRTUAL_BACKGROUND]
        reportOnlineLog(data)
    }

    fun enableAITranscriber(enable: Boolean) {
        Logger.i(TAG, "enableAITranscriber, enable: $enable")
        GlobalState.instance.enableAITranscriber = enable
    }

    fun enableIncomingBanner(enable: Boolean) {
        Logger.i(TAG, "enableIncomingBanner, enable: $enable")
        GlobalState.instance.enableIncomingBanner = enable
    }

    fun setScreenOrientation(orientation: Int) {
        Logger.i(TAG, "setScreenOrientation, orientation: $orientation")
        if (orientation in 0..2) {
            GlobalState.instance.orientation = Constants.Orientation.values()[orientation]
        }

        if (orientation == Constants.Orientation.LandScape.ordinal) {
            val videoEncoderParams = TUICommonDefine.VideoEncoderParams()
            videoEncoderParams.resolutionMode = TUICommonDefine.VideoEncoderParams.ResolutionMode.Landscape
            TUICallEngine.createInstance(context).setVideoEncoderParams(videoEncoderParams, null)
        }
    }

    fun disableControlButton(button: Constants.ControlButton?) {
        Logger.i(TAG, "disableControlButton, button: $button")
        button?.let { GlobalState.instance.disableControlButtonSet.add(it) }
    }

    fun callExperimentalAPI(jsonStr: String) {
        if (jsonStr.isNullOrEmpty()) {
            Logger.w(TAG, "callExperimentalAPI, jsonStr is empty");
            return
        }
        try {
            val json = JSONObject(jsonStr)
            if (!json.has("api") || !json.has("params")) {
                Logger.e(TAG, "callExperimentalAPI[lack api or illegal params]: $jsonStr")
                return
            }
            val api = json.getString("api")
            val params = json.getJSONObject("params")
            Logger.i(TAG, "callExperimentalAPI, api: $api, params: $params")
            if (api == "forceUseV2API") {
                if (params.has("enable")) {
                    GlobalState.instance.enableForceUseV2API = params.getBoolean("enable")
                }
            }
            if (api == "setFramework") {
                if (params.has("framework")) {
                    Constants.framework = params.getInt("framework")
                }
                if (params.has("component")) {
                    Constants.component = params.getInt("component")
                }
                if (params.has("language")) {
                    Constants.language = params.getInt("language")
                }
                val params = JSONObject()
                params.put("framework", Constants.framework)
                params.put("component", Constants.component)
                params.put("language", Constants.language)

                val jsonObject = JSONObject()
                jsonObject.put("api", "setFramework")
                jsonObject.put("params", params)
                TUICallEngine.createInstance(context).callExperimentalAPI(jsonObject.toString())
            }
        } catch (e: Exception) {
            Logger.e(TAG, "callExperimentalAPI json parse fail，json: $jsonStr, error: $e")
        }
    }

    fun startRealtimeTranscriber() {
        val transcriberConfig = TranscriberConfig(
            sourceLanguage = SourceLanguage.CHINESE_ENGLISH,
            translationLanguages = mutableListOf(TranslationLanguage.ENGLISH)
        )
        AITranscriberStore.shared.startRealtimeTranscriber(transcriberConfig, object : CompletionHandler {
            override fun onSuccess() {
                observerTranscriber()
            }

            override fun onFailure(code: Int, desc: String) {
            }
        })
        closeVAD()
    }

    fun stopRealtimeTranscriber() {
        AITranscriberStore.shared.stopRealtimeTranscriber(null)
    }

    private fun closeVAD() {
        val resetObj = JSONObject().apply {
            put("api", "setPrivateConfig")
            put("params", JSONObject().apply {
                put("configs", JSONArray().apply {
                    put(JSONObject().apply {
                        put("key", "Liteav.Audio.common.enable.send.eos.packet.in.dtx")
                        put("action", "reset")
                    })
                })
            })
        }
        TRTCCloud.sharedInstance(context).callExperimentalAPI(resetObj.toString())

        val closeObj = JSONObject().apply {
            put("api", "setPrivateConfig")
            put("params", JSONObject().apply {
                put("configs", JSONArray().apply {
                    put(JSONObject().apply {
                        put("key", "Liteav.Audio.common.enable.send.eos.packet.in.dtx")
                        put("value", 0)
                        put("default", 0)
                    })
                })
            })
        }
        TRTCCloud.sharedInstance(context).callExperimentalAPI(closeObj.toString())
    }

    private fun observerTranscriber() {
        val param = JSONObject().apply {
            put("UIComponentType", 1402)
        }.toString()
        V2TIMManager.getInstance()
            .callExperimentalAPI("reportTUIFeatureUsage", param, object : V2TIMValueCallback<Any> {
                override fun onSuccess(t: Any?) {
                }
                override fun onError(code: Int, desc: String?) {
                    Log.e(TAG, "reportFeatureUsage failed: $code $desc")
                }
            })
    }

    private fun convertErrorMsg(errorCode: Int, errMsg: String): String {
        if (errorCode == BaseConstants.ERR_SVR_MSG_IN_PEER_BLACKLIST) {
            return context.getString(R.string.callkit_error_in_peer_blacklist)
        }

        val commonErrorMap = getCommonErrorMap()
        if (commonErrorMap.containsKey(errorCode)) {
            return commonErrorMap[errorCode]!!
        }
        return ErrorMessageConverter.convertIMError(errorCode, errMsg)
    }

    private fun getCommonErrorMap(): Map<Int, String> {
        val map = HashMap<Int, String>()
        map[TUICallDefine.ERROR_PACKAGE_NOT_PURCHASED] = context.getString(R.string.callkit_package_not_purchased)
        map[TUICallDefine.ERROR_PACKAGE_NOT_SUPPORTED] = context.getString(R.string.callkit_package_not_support)
        map[TUICallDefine.ERROR_INIT_FAIL] = context.getString(R.string.callkit_error_invalid_login)
        map[TUICallDefine.ERROR_PARAM_INVALID] = context.getString(R.string.callkit_error_parameter_invalid)
        map[TUICallDefine.ERROR_REQUEST_REFUSED] = context.getString(R.string.callkit_error_currently_in_a_call)
        map[TUICallDefine.ERROR_REQUEST_REPEATED] = context.getString(R.string.callkit_error_request_repeated)
        map[TUICallDefine.ERROR_SCENE_NOT_SUPPORTED] = context.getString(R.string.callkit_error_scene_not_support)
        // todo: 待补充 6017 、-3301 对应错误码后删除
        map[BaseConstants.ERR_INVALID_PARAMETERS] = context.getString(R.string.callkit_toast_error_call_user_not_exist)
        map[TXLiteAVCode.ERR_TRTC_ENTER_ROOM_FAILED] = context.getString(R.string.callkit_toast_error_call_failed)
        map[ERR_SVR_GROUP_HAS_ACTIVE_CALL] = context.getString(R.string.callkit_toast_error_group_call_has_active_call)
        return map
    }

    fun startForegroundService() {
        val inviteeIdsSize = CallStore.shared.observerState.activeCall.value.inviteeIds.size
        val scene: TUICallDefine.Scene = if (inviteeIdsSize == 0) {
            TUICallDefine.Scene.NONE
        } else if (inviteeIdsSize == 1) {
            TUICallDefine.Scene.SINGLE_CALL
        } else {
            TUICallDefine.Scene.GROUP_CALL
        }
        val mediaType = CallStore.shared.observerState.activeCall.value.mediaType
        if (scene == TUICallDefine.Scene.GROUP_CALL || scene == TUICallDefine.Scene.MULTI_CALL
            || mediaType == CallMediaType.Video
        ) {
            VideoForegroundService.start(TUIConfig.getAppContext(), "", "", 0)
        } else if (mediaType == CallMediaType.Audio) {
            AudioForegroundService.start(TUIConfig.getAppContext(), "", "", 0)
        }
    }

    fun stopForegroundService() {
        VideoForegroundService.stop(TUIConfig.getAppContext())
        AudioForegroundService.stop(TUIConfig.getAppContext())
    }

    private fun reportOnlineLog(data: Map<String, Any>) {
        try {
            val map: JSONObject = JSONObject(data)
            map.put("version", TUICallDefine.VERSION)
            map.put("platform", "android")
            map.put("framework", "native")
            map.put("sdk_app_id", LoginStore.shared.sdkAppID)

            val params = JSONObject()
            params.put("level", 1)
            params.put("msg", map.toString())
            params.put("more_msg", "TUICallKit")

            val jsonObject = JSONObject()
            jsonObject.put("api", "reportOnlineLog")
            jsonObject.put("params", params)

            TUICallEngine.createInstance(context).trtcCloudInstance.callExperimentalAPI(jsonObject.toString())
        } catch (e: Exception) {
            Logger.e(TAG, "reportOnlineLog fail, error: $e")
        }
    }

    companion object {
        private const val TAG = "CallManager"
        private const val ERR_SVR_GROUP_HAS_ACTIVE_CALL = 101012
        val instance: CallManager = CallManager(TUIConfig.getAppContext())
        private const val BLUR_LEVEL_HIGH = 3
        private const val BLUR_LEVEL_CLOSE = 0
    }
}