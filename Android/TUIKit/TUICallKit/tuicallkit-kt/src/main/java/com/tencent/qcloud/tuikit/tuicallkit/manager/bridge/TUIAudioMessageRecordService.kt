package com.tencent.qcloud.tuikit.tuicallkit.manager.bridge

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.text.TextUtils
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallEngine
import com.tencent.cloud.tuikit.engine.call.TUICallObserver
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.interfaces.ITUINotification
import com.tencent.qcloud.tuicore.interfaces.ITUIService
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.trtc.TRTCCloud
import com.tencent.trtc.TRTCCloudDef
import com.tencent.trtc.TRTCCloudListener
import org.json.JSONException
import org.json.JSONObject

class TUIAudioMessageRecordService(context: Context) : ITUIService, ITUINotification {
    private var context: Context = context.applicationContext
    private var audioRecordInfo: AudioRecordInfo? = null
    private var focusRequest: AudioFocusRequest? = null
    private var audioManager: AudioManager? = null
    private var focusChangeListener: AudioManager.OnAudioFocusChangeListener? = null
    private var audioRecordValueCallback: TUIServiceCallback? = null

    init {
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this
        )
    }

    override fun onCall(method: String?, param: Map<String?, Any?>?, callback: TUIServiceCallback?): Any {
        audioRecordValueCallback = callback
        if (TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_START_RECORD_AUDIO_MESSAGE, method)) {
            if (param == null) {
                Logger.e(TAG, "startRecordAudioMessage failed, param is empty")
                notifyAudioMessageRecordEvent(
                    TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                    TUIConstants.TUICalling.ERROR_INVALID_PARAM, null
                )
                return false
            }

            if (TUICallDefine.Status.None != CallManager.instance.userState.selfUser.get().callStatus.get()) {
                Logger.e(TAG, "startRecordAudioMessage failed, The current call status does not support recording")
                notifyAudioMessageRecordEvent(
                    TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                    TUIConstants.TUICalling.ERROR_STATUS_IN_CALL, null
                )
                return false
            }

            if (audioRecordInfo != null) {
                Logger.e(TAG, "startRecordAudioMessage failed, The recording is not over, It cannot be called again")
                notifyAudioMessageRecordEvent(
                    TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                    TUIConstants.TUICalling.ERROR_STATUS_IS_AUDIO_RECORDING, null
                )
                return false
            }

            PermissionRequest.requestPermissions(context, TUICallDefine.MediaType.Audio, object : PermissionCallback() {
                override fun onGranted() {
                    initAudioFocusManager()
                    if (requestAudioFocus() != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                        Logger.e(TAG, "startRecordAudioMessage failed, Failed to obtain audio focus")
                        notifyAudioMessageRecordEvent(
                            TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                            TUIConstants.TUICalling.ERROR_REQUEST_AUDIO_FOCUS_FAILED, null
                        )
                        return
                    }
                    audioRecordInfo = AudioRecordInfo()
                    if (param.containsKey(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH)) {
                        audioRecordInfo!!.path = param[TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH] as String
                    }
                    if (param.containsKey(TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID)) {
                        audioRecordInfo!!.sdkAppId = param[TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID] as Int
                    }
                    if (param.containsKey(TUIConstants.TUICalling.PARAM_NAME_AUDIO_SIGNATURE)) {
                        audioRecordInfo!!.signature =
                            param[TUIConstants.TUICalling.PARAM_NAME_AUDIO_SIGNATURE] as String?
                    }

                    TRTCCloud.sharedInstance(context).addListener(trtcCloudListener)
                    startRecordAudioMessage()
                }

                override fun onDenied() {
                    super.onDenied()
                    notifyAudioMessageRecordEvent(
                        TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                        TUIConstants.TUICalling.ERROR_MIC_PERMISSION_REFUSED, null
                    )
                }
            })
            return true
        }
        if (TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_STOP_RECORD_AUDIO_MESSAGE, method)) {
            stopRecordAudioMessage()
        }
        return true
    }

    private val trtcCloudListener: TRTCCloudListener = object : TRTCCloudListener() {
        override fun onError(errCode: Int, errMsg: String, extraInfo: Bundle) {
            super.onError(errCode, errMsg, extraInfo)
            if (errCode == TUIConstants.TUICalling.ERR_MIC_START_FAIL
                || errCode == TUIConstants.TUICalling.ERR_MIC_NOT_AUTHORIZED
                || errCode == TUIConstants.TUICalling.ERR_MIC_SET_PARAM_FAIL
                || errCode == TUIConstants.TUICalling.ERR_MIC_OCCUPY
            ) {
                notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START, errCode, null)
            }
        }

        override fun onLocalRecordBegin(errCode: Int, storagePath: String) {
            super.onLocalRecordBegin(errCode, storagePath)
            val code = convertErrorCode("onLocalRecordBegin", errCode)
            if (errCode == TUIConstants.TUICalling.ERROR_NONE) {
                TRTCCloud.sharedInstance(context).startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH)
            }
            notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START, code, storagePath)
        }

        override fun onLocalRecordComplete(errCode: Int, storagePath: String) {
            super.onLocalRecordComplete(errCode, storagePath)
            val code = convertErrorCode("onLocalRecordComplete", errCode)
            notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_STOP, code, storagePath)
        }
    }
    private val callObserver: TUICallObserver = object : TUICallObserver() {
        override fun onCallReceived(
            callerId: String?,
            calleeIdList: List<String?>?,
            groupId: String?,
            callMediaType: TUICallDefine.MediaType?,
            userData: String?
        ) {
            super.onCallReceived(callerId, calleeIdList, groupId, callMediaType, userData)
            stopRecordAudioMessage()
        }
    }

    private fun startRecordAudioMessage() {
        if (audioRecordInfo == null) {
            Logger.e(TAG, "startRecordAudioMessage failed, audioRecordInfo is empty")
            return
        }
        Logger.i(TAG, "startRecordAudioMessage, mAudioRecordInfo: $audioRecordInfo")
        val jsonObject = JSONObject()
        try {
            jsonObject.put("api", "startRecordAudioMessage")
            val params = JSONObject()
            params.put(TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID, audioRecordInfo!!.sdkAppId)
            params.put(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH, audioRecordInfo!!.path)
            params.put("key", audioRecordInfo!!.signature)
            jsonObject.put("params", params)
            TRTCCloud.sharedInstance(context).callExperimentalAPI(jsonObject.toString())
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }

    private fun stopRecordAudioMessage() {
        if (audioRecordInfo == null) {
            Logger.w(TAG, "stopRecordAudioMessage, current recording status is Idle,do not need to stop")
            return
        }
        val jsonObject = JSONObject()
        try {
            jsonObject.put("api", "stopRecordAudioMessage")
            val params = JSONObject()
            jsonObject.put("params", params)
            TRTCCloud.sharedInstance(context).callExperimentalAPI(jsonObject.toString())
        } catch (e: JSONException) {
            e.printStackTrace()
        }
        Logger.i(TAG, "stopRecordAudioMessage, stopLocalAudio")
        TRTCCloud.sharedInstance(context).stopLocalAudio()

        audioRecordInfo = null
        abandonAudioFocus()
    }

    private fun notifyAudioMessageRecordEvent(method: String, errCode: Int, path: String?) {
        Logger.i(TAG, "notifyAudioMessageRecordEvent, method: $method, errCode: $errCode,path: $path")
        if (audioRecordValueCallback != null) {
            val bundleInfo = Bundle()
            bundleInfo.putString(TUIConstants.TUICalling.EVENT_KEY_RECORD_AUDIO_MESSAGE, method)
            bundleInfo.putString(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH, path)
            audioRecordValueCallback?.onServiceCallback(errCode, "", bundleInfo)
        }
    }

    override fun onNotifyEvent(key: String, subKey: String, param: Map<String, Any>?) {
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED == key && TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS == subKey) {
            TUICallEngine.createInstance(context).addObserver(callObserver)
        }
    }

    private fun initAudioFocusManager() {
        if (audioManager == null) {
            audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        }
        if (focusChangeListener == null) {
            focusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
                when (focusChange) {
                    AudioManager.AUDIOFOCUS_GAIN -> {}
                    AudioManager.AUDIOFOCUS_LOSS, AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> stopRecordAudioMessage()
                    AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                        //transient lost audio focus and the new focus owner doesn't require others to be silent.
                    }
                    else -> {}
                }
            }
        }
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
            val attributes: AudioAttributes = AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build()

            if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O) {
                focusRequest = AudioFocusRequest
                    .Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                    .setWillPauseWhenDucked(true)
                    .setAudioAttributes(attributes)
                    .setOnAudioFocusChangeListener(focusChangeListener!!)
                    .build()
            }
        }
    }

    private fun requestAudioFocus(): Int {
        if (audioManager == null) {
            return AudioManager.AUDIOFOCUS_REQUEST_FAILED
        }
        val result: Int = if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O) {
            audioManager!!.requestAudioFocus(focusRequest!!)
        } else {
            audioManager!!.requestAudioFocus(
                focusChangeListener, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
            )
        }
        return result
    }

    private fun abandonAudioFocus(): Int {
        if (audioManager == null) {
            return AudioManager.AUDIOFOCUS_REQUEST_FAILED
        }
        val result: Int = if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O) {
            audioManager!!.abandonAudioFocusRequest(focusRequest!!)
        } else {
            audioManager!!.abandonAudioFocus(focusChangeListener)
        }
        return result
    }

    private fun convertErrorCode(method: String, errorCode: Int): Int {
        val targetCode: Int = when (errorCode) {
            -1 -> if ("onLocalRecordBegin" == method) TUIConstants.TUICalling.ERROR_RECORD_INIT_FAILED
            else TUIConstants.TUICalling.ERROR_RECORD_FAILED
            -2 -> TUIConstants.TUICalling.ERROR_PATH_FORMAT_NOT_SUPPORT
            -3 -> TUIConstants.TUICalling.ERROR_NO_MESSAGE_TO_RECORD
            -4 -> TUIConstants.TUICalling.ERROR_SIGNATURE_ERROR
            -5 -> TUIConstants.TUICalling.ERROR_SIGNATURE_EXPIRED
            else -> TUIConstants.TUICalling.ERROR_NONE
        }
        return targetCode
    }

    internal class AudioRecordInfo {
        var path: String? = null
        var sdkAppId = 0
        var signature: String? = null
        override fun toString(): String {
            return ("AudioRecordInfo{path=$path, SDKAppID=$sdkAppId}")
        }
    }

    companion object {
        private const val TAG = "TUIAudioMessageRecordService"
    }
}