package com.tencent.qcloud.tuikit.tuicallkit

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
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
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingBellFeature
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingKeepAliveFeature
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.utils.UserInfoUtils
import com.tencent.qcloud.tuikit.tuicallkit.view.CallKitActivity
import com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingview.IncomingFloatView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingview.IncomingNotificationView


class TUICallKitImpl private constructor(context: Context) : TUICallKit(), ITUINotification {
    private val context: Context
    private var callingBellFeature: CallingBellFeature? = null
    private var callingKeepAliveFeature: CallingKeepAliveFeature? = null
    private val mainHandler: Handler = Handler(Looper.getMainLooper())

    init {
        this.context = context.applicationContext
        TUICallEngine.createInstance(this.context).addObserver(TUICallState.instance.mTUICallObserver)
        registerCallingEvent()
    }

    companion object {
        private const val TAG = "TUICallKitImpl"
        private const val TAG_VIEW = "IncomingView"
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
        EngineManager.instance.call(userId, callMediaType, params, object : Callback {
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
        TUILog.i(
            TAG, "TUICallKit groupCall{groupId:${groupId}, userIdList:${userIdList}, callMediaType:${callMediaType}"
        )
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
        EngineManager.instance.groupCall(groupId, userIdList, callMediaType!!, params, object : Callback {
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
        EngineManager.instance.joinInGroupCall(roomId, groupId, mediaType)
    }

    override fun setCallingBell(filePath: String?) {
        TUILog.i(TAG, "TUICallKit setCallingBell{filePath:${filePath}")
        SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT)
            .put(CallingBellFeature.PROFILE_CALL_BELL, filePath)
    }

    override fun enableMuteMode(enable: Boolean) {
        TUILog.i(TAG, "TUICallKit enableMuteMode{enable:${enable}")
        EngineManager.instance.enableMuteMode(enable)
    }

    override fun enableFloatWindow(enable: Boolean) {
        TUILog.i(TAG, "TUICallKit enableFloatWindow{enable:${enable}")
        EngineManager.instance.enableFloatWindow(enable)
    }

    fun queryOfflineCall() {
        TUILog.i(TAG, "queryOfflineCall start")
        if (TUICallDefine.Status.Accept != TUICallState.instance.selfUser.get().callStatus.get()) {
            val role: TUICallDefine.Role = TUICallState.instance.selfUser.get().callRole.get()
            val mediaType: TUICallDefine.MediaType = TUICallState.instance.mediaType.get()
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

        TUICore.registerEvent(Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_START_FEATURE, this)
        TUICore.registerEvent(Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_START_ACTIVITY, this)
        TUICore.registerEvent(Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_SHOW_INCOMING_VIEW, this)
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
                startFullScreenView()
            } else if (Constants.EVENT_SHOW_INCOMING_VIEW == subKey) {
                handleNewCall()
            }
        }
    }

    private fun handleNewCall() {
        mainHandler.post {
            if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                TUILog.w(TAG_VIEW, "handleNewCall, current status: None, ignore")
                return@post
            }

            val hasFloatPermission = PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()
            val isAppInBackground: Boolean = !DeviceUtils.isAppRunningForeground(context)
            val hasBgPermission = PermissionRequester.newInstance(PermissionRequester.BG_START_PERMISSION).has()
            val hasNotificationPermission = PermissionRequest.isNotificationEnabled()

            val innerNotification = isShowInnerNotification()

            TUILog.i(
                TAG_VIEW, "handleNewCall, isAppInBackground: $isAppInBackground, floatPermission: $hasFloatPermission" +
                        ", backgroundStartPermission: $hasBgPermission, notificationPermission: $hasNotificationPermission , " +
                        "showNotification: $innerNotification"
            )
            if (isAppInBackground) {
                when {
                    hasFloatPermission -> startSmallScreenView(IncomingFloatView(context))
                    innerNotification && hasNotificationPermission -> startSmallScreenView(
                        IncomingNotificationView(context)
                    )

                    hasBgPermission -> startFullScreenView()
                    else -> {
                        //do nothing, wait user click desktop icon
                    }
                }
                return@post
            }

            when {
                hasFloatPermission -> startSmallScreenView(IncomingFloatView(context))
                hasNotificationPermission -> startSmallScreenView(IncomingNotificationView(context))
                else -> startFullScreenView()
            }
        }
    }

    private fun isShowInnerNotification(): Boolean {
        if (TUICore.getService(TUIConstants.TIMPush.SERVICE_NAME) == null) {
            return true
        }

        val pushBrandId =
            TUICore.callService(TUIConstants.TIMPush.SERVICE_NAME, TUIConstants.TIMPush.METHOD_GET_PUSH_BRAND_ID, null)

        return pushBrandId == TUIConstants.DeviceInfo.BRAND_GOOGLE_ELSE
    }

    private fun startFullScreenView() {
        TUILog.i(TAG_VIEW, "startFullScreenView")
        mainHandler.post {
            if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                TUILog.i(TAG_VIEW, "startFullScreenView, current status: None, ignore")
                return@post
            }
            PermissionRequest.requestPermissions(context, TUICallState.instance.mediaType.get(), object :
                PermissionCallback() {
                override fun onGranted() {
                    if (TUICallDefine.Status.None != TUICallState.instance.selfUser.get().callStatus.get()) {
                        initAudioPlayDevice()
                        TUILog.i(TAG_VIEW, "startFullScreenView requestPermissions onGranted")
                        val intent = Intent(context, CallKitActivity::class.java)
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

    private fun startSmallScreenView(view: Any) {
        var caller: User = TUICallState.instance.selfUser.get()
        for (user in TUICallState.instance.remoteUserList.get()) {
            if (user.callRole.get() == TUICallDefine.Role.Caller) {
                caller = user
                break
            }
        }

        val list = ArrayList<String>()
        caller.id?.let { list.add(it) }

        UserInfoUtils.getUserListInfo(list, object : TUICommonDefine.ValueCallback<List<User>?> {
            override fun onSuccess(data: List<User>?) {
                if (data.isNullOrEmpty()) {
                    return
                }
                if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                    TUILog.w(TAG_VIEW, "startSmallScreenView, current status: None, ignore")
                    return
                }
                caller.avatar.set(data[0].avatar.get())
                caller.nickname.set(data[0].nickname.get())

                if (view is IncomingFloatView) {
                    view.showIncomingView(caller)
                } else if (view is IncomingNotificationView) {
                    view.showNotification(caller)
                }
            }

            override fun onError(errCode: Int, errMsg: String?) {
                if (view is IncomingFloatView) {
                    view.showIncomingView(caller)
                } else if (view is IncomingNotificationView) {
                    view.showNotification(caller)
                }
            }
        })
    }

    private fun initCallEngine() {
        TUICallEngine.createInstance(context).init(
            TUILogin.getSdkAppId(), TUILogin.getLoginUser(),
            TUILogin.getUserSig(), object : Callback {
                override fun onSuccess() {}
                override fun onError(errCode: Int, errMsg: String) {}
            })
    }

    private fun initAudioPlayDevice() {
        val device = if (TUICallDefine.MediaType.Audio == TUICallState.instance.mediaType.get()) {
            TUICommonDefine.AudioPlaybackDevice.Earpiece
        } else {
            TUICommonDefine.AudioPlaybackDevice.Speakerphone
        }
        EngineManager.instance.selectAudioPlaybackDevice(device)
    }
}