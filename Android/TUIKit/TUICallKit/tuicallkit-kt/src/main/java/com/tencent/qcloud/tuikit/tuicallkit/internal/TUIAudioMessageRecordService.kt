package com.tencent.qcloud.tuikit.tuicallkit.internal

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.text.TextUtils
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.interfaces.ITUINotification
import com.tencent.qcloud.tuicore.interfaces.ITUIService
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallObserver
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest
import com.tencent.trtc.TRTCCloud
import com.tencent.trtc.TRTCCloudDef
import com.tencent.trtc.TRTCCloudListener
import org.json.JSONException
import org.json.JSONObject

class TUIAudioMessageRecordService(context: Context) : ITUIService, ITUINotification {

    private lateinit var mContext: Context
    private var mAudioRecordInfo: AudioRecordInfo? = null
    private var mFocusRequest: AudioFocusRequest? = null
    private var mAudioManager: AudioManager? = null
    private var mOnFocusChangeListener: AudioManager.OnAudioFocusChangeListener? = null
    private var mAudioRecordValueCallback: TUIServiceCallback? = null

    override fun onCall(method: String?, param: Map<String?, Any?>?, callback: TUIServiceCallback?): Any {
        mAudioRecordValueCallback = callback
        if (TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_START_RECORD_AUDIO_MESSAGE, method)) {
            if (param == null) {
                TUILog.e(TAG, "startRecordAudioMessage failed, param is empty")
                notifyAudioMessageRecordEvent(
                    TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                    TUIConstants.TUICalling.ERROR_INVALID_PARAM,
                    null
                )
                return false
            }

            if (TUICallDefine.Status.None != TUICallState.instance.selfUser.get().callStatus.get()) {
                TUILog.e(TAG, "startRecordAudioMessage failed, The current call status does not support recording")
                notifyAudioMessageRecordEvent(
                    TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                    TUIConstants.TUICalling.ERROR_STATUS_IN_CALL,
                    null
                )
                return false
            }

            if (mAudioRecordInfo != null) {
                TUILog.e(TAG, "startRecordAudioMessage failed, The recording is not over, It cannot be called again")
                notifyAudioMessageRecordEvent(
                    TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                    TUIConstants.TUICalling.ERROR_STATUS_IS_AUDIO_RECORDING,
                    null
                )
                return false
            }

            PermissionRequest.requestPermissions(mContext,
                TUICallDefine.MediaType.Audio,
                object : PermissionCallback() {
                    override fun onGranted() {
                        initAudioFocusManager()
                        if (requestAudioFocus() != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                            TUILog.e(TAG, "startRecordAudioMessage failed, Failed to obtain audio focus")
                            notifyAudioMessageRecordEvent(
                                TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                                TUIConstants.TUICalling.ERROR_REQUEST_AUDIO_FOCUS_FAILED,
                                null
                            )
                            return
                        }
                        mAudioRecordInfo = AudioRecordInfo()
                        if (param.containsKey(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH)) {
                            mAudioRecordInfo!!.path = param[TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH] as String?
                        }
                        if (param.containsKey(TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID)) {
                            mAudioRecordInfo!!.sdkAppId = param[TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID] as Int
                        }
                        if (param.containsKey(TUIConstants.TUICalling.PARAM_NAME_AUDIO_SIGNATURE)) {
                            mAudioRecordInfo!!.signature =
                                param[TUIConstants.TUICalling.PARAM_NAME_AUDIO_SIGNATURE] as String?
                        }

                        TRTCCloud.sharedInstance(mContext).setListener(mTRTCCloudListener)
                        startRecordAudioMessage()
                    }

                    override fun onDenied() {
                        super.onDenied()
                        notifyAudioMessageRecordEvent(
                            TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START,
                            TUIConstants.TUICalling.ERROR_MIC_PERMISSION_REFUSED,
                            null
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

    private val mTRTCCloudListener: TRTCCloudListener = object : TRTCCloudListener() {
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
            val tempCode = convertErrorCode("onLocalRecordBegin", errCode)
            if (errCode == TUIConstants.TUICalling.ERROR_NONE) {
                TRTCCloud.sharedInstance(mContext).startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH)
            }
            notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_START, tempCode, storagePath)
        }

        override fun onLocalRecordComplete(errCode: Int, storagePath: String) {
            super.onLocalRecordComplete(errCode, storagePath)
            val tempCode = convertErrorCode("onLocalRecordComplete", errCode)
            notifyAudioMessageRecordEvent(TUIConstants.TUICalling.EVENT_SUB_KEY_RECORD_STOP, tempCode, storagePath)
        }
    }
    private val mCallObserver: TUICallObserver = object : TUICallObserver() {
        override fun onCallReceived(
            callerId: String?,
            calleeIdList: List<String?>?,
            groupId: String?,
            callMediaType: TUICallDefine.MediaType?,
            userData: String?
        ) {
            super.onCallReceived(callerId, calleeIdList, groupId, callMediaType, userData)
            //收到通话邀请,停止录制
            stopRecordAudioMessage()
        }
    }

    init {
        mContext = context.applicationContext
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS,
            this
        )
    }

    private fun startRecordAudioMessage() {
        if (mAudioRecordInfo == null) {
            TUILog.e(TAG, "startRecordAudioMessage failed, audioRecordInfo is empty")
            return
        }
        TUILog.i(TAG, "startRecordAudioMessage, mAudioRecordInfo: $mAudioRecordInfo")
        val jsonObject = JSONObject()
        try {
            jsonObject.put("api", "startRecordAudioMessage")
            val params = JSONObject()
            params.put(TUIConstants.TUICalling.PARAM_NAME_SDK_APP_ID, mAudioRecordInfo!!.sdkAppId)
            params.put(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH, mAudioRecordInfo!!.path)
            params.put("key", mAudioRecordInfo!!.signature)
            jsonObject.put("params", params)
            TRTCCloud.sharedInstance(mContext).callExperimentalAPI(jsonObject.toString())
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }

    private fun stopRecordAudioMessage() {
        if (mAudioRecordInfo == null) {
            TUILog.w(TAG, "stopRecordAudioMessage, current recording status is Idle,do not need to stop")
            return
        }
        val jsonObject = JSONObject()
        try {
            jsonObject.put("api", "stopRecordAudioMessage")
            val params = JSONObject()
            jsonObject.put("params", params)
            TRTCCloud.sharedInstance(mContext).callExperimentalAPI(jsonObject.toString())
        } catch (e: JSONException) {
            e.printStackTrace()
        }
        TUILog.i(TAG, "stopRecordAudioMessage, stopLocalAudio")
        TRTCCloud.sharedInstance(mContext).stopLocalAudio()
        //清空录制信息
        mAudioRecordInfo = null
        //释放音频焦点
        abandonAudioFocus()
    }

    private fun notifyAudioMessageRecordEvent(method: String, errCode: Int, path: String?) {
        TUILog.i(TAG, "notifyAudioMessageRecordEvent, method: $method, errCode: $errCode,path: $path")
        if (mAudioRecordValueCallback != null) {
            val bundleInfo = Bundle()
            bundleInfo.putString(TUIConstants.TUICalling.EVENT_KEY_RECORD_AUDIO_MESSAGE, method)
            bundleInfo.putString(TUIConstants.TUICalling.PARAM_NAME_AUDIO_PATH, path)
            mAudioRecordValueCallback?.onServiceCallback(errCode, "", bundleInfo)
        }
    }

    override fun onNotifyEvent(key: String, subKey: String, param: Map<String, Any>?) {
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED == key && TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS == subKey) {
            TUICallEngine.createInstance(mContext).addObserver(mCallObserver)
        }
    }

    private fun initAudioFocusManager() {
        if (mAudioManager == null) {
            mAudioManager = mContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        }
        if (mOnFocusChangeListener == null) {
            mOnFocusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
                when (focusChange) {
                    AudioManager.AUDIOFOCUS_GAIN -> {}
                    AudioManager.AUDIOFOCUS_LOSS, AudioManager.AUDIOFOCUS_LOSS_TRANSIENT, AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK ->                             //其他应用占用焦点的时候,停止录制
                        stopRecordAudioMessage()

                    else -> {}
                }
            }
        }
        var attributes: AudioAttributes?
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            attributes = AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                mFocusRequest = AudioFocusRequest
                    .Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                    .setWillPauseWhenDucked(true)
                    .setAudioAttributes(attributes)
                    .setOnAudioFocusChangeListener(mOnFocusChangeListener!!)
                    .build()
            }
        }
    }

    private fun requestAudioFocus(): Int {
        if (mAudioManager == null) {
            return AudioManager.AUDIOFOCUS_REQUEST_FAILED
        }
        var result: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mAudioManager!!.requestAudioFocus(mFocusRequest!!)
        } else {
            mAudioManager!!.requestAudioFocus(
                mOnFocusChangeListener, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
            )
        }
        return result
    }

    private fun abandonAudioFocus(): Int {
        if (mAudioManager == null) {
            return AudioManager.AUDIOFOCUS_REQUEST_FAILED
        }
        val result: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mAudioManager!!.abandonAudioFocusRequest(mFocusRequest!!)
        } else {
            mAudioManager!!.abandonAudioFocus(mOnFocusChangeListener)
        }
        return result
    }

    private fun convertErrorCode(method: String, errorCode: Int): Int {
        var targetCode: Int = when (errorCode) {
            -1 -> if ("onLocalRecordBegin" == method) TUIConstants.TUICalling.ERROR_RECORD_INIT_FAILED else TUIConstants.TUICalling.ERROR_RECORD_FAILED
            -2 -> TUIConstants.TUICalling.ERROR_PATH_FORMAT_NOT_SUPPORT
            -3 -> TUIConstants.TUICalling.ERROR_NO_MESSAGE_TO_RECORD
            -4 -> TUIConstants.TUICalling.ERROR_SIGNATURE_ERROR
            -5 -> TUIConstants.TUICalling.ERROR_SIGNATURE_EXPIRED
            else -> TUIConstants.TUICalling.ERROR_NONE
        }
        return targetCode
    }

    internal inner class AudioRecordInfo {
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