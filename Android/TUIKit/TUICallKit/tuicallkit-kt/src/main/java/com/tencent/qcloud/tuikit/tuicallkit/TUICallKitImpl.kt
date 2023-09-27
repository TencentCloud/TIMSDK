package com.tencent.qcloud.tuikit.tuicallkit

import android.content.Context
import android.content.Intent
import com.tencent.liteav.beauty.TXBeautyManager
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.interfaces.ITUINotification
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuicore.util.SPUtils
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.TUICommonDefine.Callback
import com.tencent.qcloud.tuikit.TUICommonDefine.RoomId
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.CallParams
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.data.OfflinePushInfoConfig
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingBellFeature
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingKeepAliveFeature
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallEngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.view.CallKitActivity

class TUICallKitImpl private constructor(context: Context) : TUICallKit(), ITUINotification {
    private val context: Context
    private var callingBellFeature: CallingBellFeature? = null
    private var callingKeepAliveFeature: CallingKeepAliveFeature? = null

    init {
        this.context = context.applicationContext
        TUICallEngine.createInstance(this.context).addObserver(TUICallState.instance.mTUICallObserver)
        registerCallingEvent()
    }

    companion object {
        private val TAG = "TUICallKitImpl"
        private var instance: TUICallKitImpl? = null
        fun createInstance(context: Context): TUICallKitImpl {
            if (null == instance) {
                synchronized(TUICallKitImpl::class.java) {
                    if (null == instance) {
                        instance = TUICallKitImpl(context)
                    }
                }
            }
            return instance!!
        }
    }

    override fun setSelfInfo(nickname: String?, avatar: String?, callback: Callback?) {
        TUILog.i(TAG, "TUICallKit setSelfInfo{nickname:${nickname}, avatar:${avatar}")
        TUICallEngine.createInstance(context).setSelfInfo(nickname, avatar, callback)
    }

    override fun call(userId: String, callMediaType: TUICallDefine.MediaType) {
        TUILog.i(TAG, "TUICallKit call{userId:${userId}, callMediaType:${callMediaType}")
        val params = CallParams()
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(context)
        params.timeout = Constants.SIGNALING_MAX_TIME
        call(userId, callMediaType, params, null)
    }

    override fun call(
        userId: String,
        callMediaType: TUICallDefine.MediaType,
        params: CallParams?,
        callback: Callback?
    ) {
        TUILog.i(TAG, "TUICallKit call{userId:${userId}, callMediaType:${callMediaType}, params:${params?.toString()}")
        callingBellFeature = CallingBellFeature(context)
        callingKeepAliveFeature = CallingKeepAliveFeature(context)
        CallEngineManager.instance.call(userId, callMediaType, params, object : Callback {
            override fun onSuccess() {
                initAudioPlayDevice()
                var intent = Intent(context, CallKitActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String?) {
                callback?.onError(errCode, errMsg)
            }

        })
    }

    override fun groupCall(groupId: String, userIdList: List<String?>?, callMediaType: TUICallDefine.MediaType) {
        TUILog.i(TAG, "TUICallKit groupCall{groupId:${groupId}, userIdList:${userIdList}, callMediaType:${callMediaType}")
        val params = CallParams()
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(context)
        params.timeout = Constants.SIGNALING_MAX_TIME
        groupCall(groupId, userIdList, callMediaType, params, null)
    }

    override fun groupCall(
        groupId: String, userIdList: List<String?>?, callMediaType: TUICallDefine.MediaType,
        params: CallParams?, callback: Callback?
    ) {
        TUILog.i(
            TAG, "TUICallKit groupCall{groupId:${groupId}, userIdList:${userIdList}, callMediaType:${callMediaType}, " +
                    "params:${params}"
        )
        callingBellFeature = CallingBellFeature(context)
        callingKeepAliveFeature = CallingKeepAliveFeature(context)
        CallEngineManager.instance.groupCall(groupId, userIdList, callMediaType!!, params, object : Callback {
            override fun onSuccess() {
                initAudioPlayDevice()
                var intent = Intent(context, CallKitActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String?) {
                callback?.onError(errCode, errMsg)
            }

        })
    }

    override fun joinInGroupCall(roomId: RoomId?, groupId: String?, mediaType: TUICallDefine.MediaType?) {
        TUILog.i(TAG, "TUICallKit joinInGroupCall{roomId:${roomId}, groupId:${groupId}, mediaType:${mediaType}")
        CallEngineManager.instance.joinInGroupCall(roomId, groupId, mediaType)
    }

    override fun setCallingBell(filePath: String?) {
        TUILog.i(TAG, "TUICallKit setCallingBell{filePath:${filePath}")
        SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT)
            .put(CallingBellFeature.PROFILE_CALL_BELL, filePath)
    }

    override fun enableMuteMode(enable: Boolean) {
        TUILog.i(TAG, "TUICallKit enableMuteMode{enable:${enable}")
        CallEngineManager.instance.enableMuteMode(enable)
    }

    override fun enableFloatWindow(enable: Boolean) {
        TUILog.i(TAG, "TUICallKit enableFloatWindow{enable:${enable}")
        CallEngineManager.instance.enableFloatWindow(enable)
    }

    fun queryOfflineCall() {
        TUILog.i(TAG, "queryOfflineCall start")
        if (TUICallDefine.Status.Accept != TUICallState.instance.selfUser.get().callStatus.get()) {
            val role: TUICallDefine.Role = TUICallState.instance.selfUser.get().callRole.get()
            val mediaType: TUICallDefine.MediaType =  TUICallState.instance.mediaType.get()
            if (TUICallDefine.Role.None == role || TUICallDefine.MediaType.Unknown == mediaType) {
                return
            }

            //The received call has been processed in #onCallReceived
            if (TUICallDefine.Role.Called == role && PermissionRequester.newInstance(PermissionRequester.BG_START_PERMISSION)
                    .has()
            ) {
                return
            }
            PermissionRequest.requestPermissions(context, mediaType, object : PermissionCallback() {
                override fun onGranted() {
                    TUILog.i(TAG, "queryOfflineCall requestPermissions onGranted")
                    if (TUICallDefine.Status.None != TUICallState.instance.selfUser.get().callStatus.get()) {
                        initAudioPlayDevice()
                        var intent = Intent(context, CallKitActivity::class.java)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        context.startActivity(intent)
                    } else {
                        TUICallState.instance.clear()
                    }
                }

                override fun onDenied() {
                    if (TUICallDefine.Role.Called == role) {
                        TUICallEngine.createInstance(context).reject(null)
                    }
                }
            })
        }
    }

    private fun registerCallingEvent() {
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this
        )
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS, this
        )

        TUICore.registerEvent(
            Constants.EVENT_TUICALLKIT_CHANGED,
            Constants.EVENT_START_FEATURE, this
        )

        TUICore.registerEvent(
            Constants.EVENT_TUICALLKIT_CHANGED,
            Constants.EVENT_START_ACTIVITY, this
        )

    }

    override fun onNotifyEvent(key: String, subKey: String, param: Map<String?, Any>?) {
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED == key) {
            if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS == subKey) {
                TUICallEngine.createInstance(context).hangup(null)
                TUICallEngine.destroyInstance()
                TUICallState.instance.clear()
            } else if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS == subKey) {
                TUICallEngine.createInstance(context).addObserver(TUICallState.instance.mTUICallObserver)
                initCallEngine()
            }
        }

        if (Constants.EVENT_TUICALLKIT_CHANGED == key) {
            if (Constants.EVENT_START_FEATURE == subKey) {
                callingBellFeature = CallingBellFeature(context)
                callingKeepAliveFeature = CallingKeepAliveFeature(context)
            } else if (Constants.EVENT_START_ACTIVITY == subKey) {
                TUILog.i(TAG, "onNotifyEvent EVENT_START_ACTIVITY")
                PermissionRequest.requestPermissions(context, TUICallState.instance.mediaType.get(), object :
                    PermissionCallback() {
                    override fun onGranted() {
                        if (TUICallDefine.Status.None != TUICallState.instance.selfUser.get().callStatus.get()) {
                            initAudioPlayDevice()
                            TUILog.i(TAG, "onNotifyEvent requestPermissions onGranted")
                            var intent = Intent(context, CallKitActivity::class.java)
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            context.startActivity(intent)
                        } else {
                            TUICallState.instance.clear()
                        }
                    }

                    override fun onDenied() {
                        if (TUICallState.instance.selfUser.get().callRole.get() == TUICallDefine.Role.Called) {
                            TUICallEngine.createInstance(context).reject(null)
                        }
                        TUICallState.instance.clear()
                    }
                })
            }
        }
    }

    private fun initCallEngine() {
        TUICallEngine.createInstance(context).init(
            TUILogin.getSdkAppId(), TUILogin.getLoginUser(),
            TUILogin.getUserSig(), object : Callback {
                override fun onSuccess() {}
                override fun onError(errCode: Int, errMsg: String) {}
            })
        initCallVideoParams()
        initCallBeautyParams()
    }

    private fun initCallVideoParams() {
        val renderParams = TUICommonDefine.VideoRenderParams()
        renderParams.fillMode = TUICommonDefine.VideoRenderParams.FillMode.Fill
        renderParams.rotation = TUICommonDefine.VideoRenderParams.Rotation.Rotation_0
        val user = TUILogin.getLoginUser()
        TUICallEngine.createInstance(context)
            .setVideoRenderParams(user, renderParams, object : TUICommonDefine.Callback {
                override fun onSuccess() {}
                override fun onError(errCode: Int, errMsg: String) {}
            })

        val encoderParams = TUICommonDefine.VideoEncoderParams()
        encoderParams.resolution = TUICommonDefine.VideoEncoderParams.Resolution.Resolution_640_360
        encoderParams.resolutionMode = TUICommonDefine.VideoEncoderParams.ResolutionMode.Portrait
        TUICallEngine.createInstance(context).setVideoEncoderParams(encoderParams, object : TUICommonDefine.Callback {
            override fun onSuccess() {}
            override fun onError(errCode: Int, errMsg: String) {}
        })
    }

    private fun initCallBeautyParams() {
        val trtcCloud = TUICallEngine.createInstance(context).trtcCloudInstance
        val txBeautyManager = trtcCloud.beautyManager
        txBeautyManager.setBeautyStyle(TXBeautyManager.TXBeautyStyleNature)
        txBeautyManager.setBeautyLevel(6f)
    }

    private fun initAudioPlayDevice() {
        val device = if (TUICallDefine.MediaType.Audio == TUICallState.instance.mediaType.get()) {
            TUICommonDefine.AudioPlaybackDevice.Earpiece
        } else {
            TUICommonDefine.AudioPlaybackDevice.Speakerphone
        }
        TUICallState.instance.audioPlayoutDevice.set(device)
    }
}