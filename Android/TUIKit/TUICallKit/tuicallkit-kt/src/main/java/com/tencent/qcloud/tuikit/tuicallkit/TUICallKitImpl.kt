package com.tencent.qcloud.tuikit.tuicallkit

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.CallParams
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.Role
import com.tencent.cloud.tuikit.engine.call.TUICallEngine
import com.tencent.cloud.tuikit.engine.call.TUICallObserver
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Callback
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.RoomId
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallkit.common.config.OfflinePushInfoConfig
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.DeviceUtils
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.PushManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.UserManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.tencent.qcloud.tuikit.tuicallkit.state.ViewState
import com.tencent.qcloud.tuikit.tuicallkit.view.CallAdapter
import com.tencent.qcloud.tuikit.tuicallkit.view.CallMainActivity
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatwindow.FloatWindowView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingbanner.IncomingFloatBanner
import com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingbanner.IncomingNotificationBanner
import com.trtc.tuikit.common.livedata.Observer
import com.trtc.tuikit.common.ui.floatwindow.FloatWindowManager
import com.trtc.tuikit.common.ui.floatwindow.FloatWindowObserver
import java.util.Collections


class TUICallKitImpl private constructor(context: Context) : TUICallKit() {
    private val context = context.applicationContext

    private val callStatusObserver = Observer<TUICallDefine.Status> {
        showAntiFraudReminder()

        if (it != TUICallDefine.Status.Waiting
            || CallManager.instance.userState.selfUser.get().callRole == TUICallDefine.Role.Caller
        ) {
            return@Observer
        }
        handleNewCall()
    }

    private val floatWindowObserver = object : FloatWindowObserver() {
        override fun onFloatWindowClick() {
            startCallActivity()
            FloatWindowManager.sharedInstance().dismiss()
        }
    }

    private val callObserver = object : TUICallObserver() {
        override fun onUserReject(userId: String?) {
            if (TUICallDefine.Scene.SINGLE_CALL == CallManager.instance.callState.scene.get()) {
                ToastUtil.toastShortMessage(context.getString(R.string.tuicallkit_toast_callee_reject))
            }
        }

        override fun onUserLineBusy(userId: String?) {
            ToastUtil.toastShortMessage(context.getString(R.string.tuicallkit_text_line_busy))
        }

        override fun onUserNoResponse(userId: String?) {
            if (TUICallDefine.Scene.SINGLE_CALL == CallManager.instance.callState.scene.get()) {
                ToastUtil.toastShortMessage(context.getString(R.string.tuicallkit_toast_callee_no_response))
            }
        }

        override fun onUserLeave(userId: String?) {
            if (TUICallDefine.Scene.SINGLE_CALL == CallManager.instance.callState.scene.get()) {
                ToastUtil.toastShortMessage(context.getString(R.string.tuicallkit_toast_callee_hangup))
            }
        }
    }

    init {
        registerObserver()
        registerEvent()
    }

    override fun setSelfInfo(nickname: String?, avatar: String?, callback: Callback?) {
        CallManager.instance.setSelfInfo(nickname, avatar, callback)
    }

    override fun calls(
        userIdList: List<String?>?, mediaType: TUICallDefine.MediaType, params: CallParams?, callback: Callback?
    ) {
        val list = userIdList?.toHashSet()?.toMutableList()
        list?.remove(TUILogin.getLoginUser())
        list?.removeAll(Collections.singleton(null))
        if (list.isNullOrEmpty()) {
            Logger.e(TAG, "calls failed, userIdList is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "calls failed, userIdList is empty")
            return
        }
        PermissionRequest.requestPermissions(context, mediaType, object : PermissionCallback() {
            override fun onGranted() {
                CallManager.instance.calls(userIdList, mediaType, createDefaultCallParams(params), object : Callback {
                    override fun onSuccess() {
                        callback?.onSuccess()
                    }

                    override fun onError(errCode: Int, errMsg: String?) {
                        callback?.onError(errCode, errMsg)
                        CallManager.instance.reset()
                    }
                })
                val selfUser = CallManager.instance.userState.selfUser.get()
                selfUser.id = TUILogin.getLoginUser() ?: ""
                selfUser.avatar.set(TUILogin.getFaceUrl())
                selfUser.nickname.set(TUILogin.getNickName())
                selfUser.callRole = TUICallDefine.Role.Caller
                selfUser.callStatus.set(TUICallDefine.Status.Waiting)
                val userList = ArrayList<UserState.User>()
                for (userId in list) {
                    if (userId.isNullOrEmpty()) {
                        continue
                    }
                    val user = UserState.User()
                    user.id = userId
                    UserManager.instance.updateUserInfo(user)
                    user.callRole = TUICallDefine.Role.Called
                    user.callStatus.set(TUICallDefine.Status.Waiting)
                    userList.add(user)
                }
                CallManager.instance.userState.remoteUserList.addAll(userList)
                CallManager.instance.callState.mediaType.set(mediaType)
                var scene = TUICallDefine.Scene.SINGLE_CALL
                if (params != null && !params.chatGroupId.isNullOrEmpty()) {
                    scene = TUICallDefine.Scene.GROUP_CALL
                } else if (list.size >= 2) {
                    scene = TUICallDefine.Scene.MULTI_CALL
                }
                CallManager.instance.callState.scene.set(scene)
                initCameraAndAudioDeviceState()
                startCallActivity()
            }

            override fun onDenied() {
                Logger.w(TAG, "calls, request Permissions failed")
                callback?.onError(TUICallDefine.ERROR_PERMISSION_DENIED, "request Permissions failed")
            }
        })
    }

    override fun join(callId: String?, callback: Callback?) {
        PermissionRequest.requestPermissions(context, TUICallDefine.MediaType.Audio, object : PermissionCallback() {
            override fun onGranted() {
                CallManager.instance.join(callId, object : Callback {
                    override fun onSuccess() {
                        callback?.onSuccess()
                    }

                    override fun onError(errCode: Int, errMsg: String?) {
                        callback?.onError(errCode, errMsg)
                        CallManager.instance.reset()
                    }
                })
                val selfUser = CallManager.instance.userState.selfUser.get()
                selfUser.id = TUILogin.getLoginUser() ?: ""
                selfUser.avatar.set(TUILogin.getFaceUrl())
                selfUser.nickname.set(TUILogin.getNickName())
                selfUser.callRole = TUICallDefine.Role.Called
                selfUser.callStatus.set(TUICallDefine.Status.Accept)
                CallManager.instance.callState.mediaType.set(TUICallDefine.MediaType.Audio)
                CallManager.instance.callState.scene.set(TUICallDefine.Scene.MULTI_CALL)
                initCameraAndAudioDeviceState()
                startCallActivity()
            }

            override fun onDenied() {
                Logger.w(TAG, "join, request Permissions failed")
                callback?.onError(TUICallDefine.ERROR_PERMISSION_DENIED, "request Permissions failed")
            }
        })
    }

    override fun callExperimentalAPI(jsonStr: String) {
        CallManager.instance.callExperimentalAPI(jsonStr)
    }

    override fun setCallingBell(filePath: String?) {
        CallManager.instance.setCallingBell(filePath)
    }

    override fun enableMuteMode(enable: Boolean) {
        CallManager.instance.enableMuteMode(enable)
    }

    override fun enableFloatWindow(enable: Boolean) {
        CallManager.instance.enableFloatWindow(enable)
    }

    override fun enableVirtualBackground(enable: Boolean) {
        CallManager.instance.enableVirtualBackground(enable)
    }

    override fun enableIncomingBanner(enable: Boolean) {
        CallManager.instance.enableIncomingBanner(enable)
    }

    override fun setScreenOrientation(orientation: Int) {
        CallManager.instance.setScreenOrientation(orientation)
    }

    override fun disableControlButton(button: Constants.ControlButton?) {
        CallManager.instance.disableControlButton(button)
    }

    override fun setAdapter(adapter: CallAdapter?) {
        Logger.i(TAG, "setAdapter, adapter: $adapter")
        GlobalState.instance.callAdapter = adapter
    }

    override fun call(userId: String, callMediaType: TUICallDefine.MediaType) {
        Logger.i(TAG, "call, userId: $userId, mediaType: $callMediaType")
        val params = CallParams()
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(context)
        params.timeout = Constants.CALL_WAITING_MAX_TIME
        call(userId, callMediaType, params, null)
    }

    override fun call(userId: String, mediaType: TUICallDefine.MediaType, params: CallParams?, callback: Callback?) {
        PermissionRequest.requestPermissions(context, mediaType, object : PermissionCallback() {
            override fun onGranted() {
                CallManager.instance.call(userId, mediaType, createDefaultCallParams(params), object : Callback {
                    override fun onSuccess() {
                        startCallActivity()
                        callback?.onSuccess()
                    }

                    override fun onError(errCode: Int, errMsg: String?) {
                        callback?.onError(errCode, errMsg)
                    }
                })
            }

            override fun onDenied() {
                Logger.w(TAG, "call, request Permissions failed")
                callback?.onError(TUICallDefine.ERROR_PERMISSION_DENIED, "request Permissions failed")
            }
        })
    }

    override fun groupCall(groupId: String, userIdList: List<String?>?, mediaType: TUICallDefine.MediaType) {
        val params = CallParams()
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(context)
        params.timeout = Constants.CALL_WAITING_MAX_TIME
        groupCall(groupId, userIdList, mediaType, params, null)
    }

    override fun groupCall(
        groupId: String, userIdList: List<String?>?, mediaType: TUICallDefine.MediaType,
        params: CallParams?, callback: Callback?
    ) {
        PermissionRequest.requestPermissions(context, mediaType, object : PermissionCallback() {
            override fun onGranted() {
                CallManager.instance.groupCall(groupId, userIdList, mediaType, createDefaultCallParams(params),
                    object : Callback {
                        override fun onSuccess() {
                            startCallActivity()
                            callback?.onSuccess()
                        }

                        override fun onError(errCode: Int, errMsg: String?) {
                            callback?.onError(errCode, errMsg)
                        }
                    })
            }

            override fun onDenied() {
                Logger.w(TAG, "groupCall, request Permissions failed")
                callback?.onError(TUICallDefine.ERROR_PERMISSION_DENIED, "request Permissions failed")
            }
        })
    }

    override fun joinInGroupCall(roomId: RoomId?, groupId: String?, mediaType: TUICallDefine.MediaType?) {
        PermissionRequest.requestPermissions(context, mediaType!!, object : PermissionCallback() {
            override fun onGranted() {
                CallManager.instance.joinInGroupCall(roomId, groupId, mediaType, object : Callback {
                    override fun onSuccess() {
                        startCallActivity()
                    }

                    override fun onError(errCode: Int, errMsg: String?) {
                    }
                })
            }

            override fun onDenied() {
                Logger.w(TAG, "joinInGroupCall, request Permissions failed")
            }
        })
    }


    fun queryOfflineCall() {
        if (FloatWindowManager.sharedInstance().isShowing) {
            Logger.w(TAG, "queryOfflineCall, float window is showing")
            return
        }

        Logger.i(TAG, "queryOfflineCall start")
        val selfUser = CallManager.instance.userState.selfUser.get()
        if (TUICallDefine.Status.Accept == selfUser.callStatus.get()) {
            return
        }

        val role = selfUser.callRole
        val mediaType = CallManager.instance.callState.mediaType.get()
        if (TUICallDefine.Role.None == role || TUICallDefine.MediaType.Unknown == mediaType) {
            Logger.w(TAG, "queryOfflineCall, current status is Unknown")
            return
        }

        //The received call has been processed in #onCallReceived
        if (TUICallDefine.Role.Called == role && PermissionRequester.newInstance(PermissionRequester.BG_START_PERMISSION)
                .has()
        ) {
            return
        }
        startCallActivity()
    }

    private fun handleNewCall() {
        val floatPermission = PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()
        val isAppInBackground = !DeviceUtils.isAppRunningForeground(context)
        val bgPermission = PermissionRequester.newInstance(PermissionRequester.BG_START_PERMISSION).has()
        val notificationPermission = PermissionRequest.isNotificationEnabled()

        val enableIncomingBanner = GlobalState.instance.enableIncomingBanner
        val pushData = PushManager.getPushData()
        val isFCMDataChannel = pushData.channelId == TUIConstants.DeviceInfo.BRAND_GOOGLE_ELSE

        Logger.i(
            TAG, "handleNewCall, isAppInBackground: $isAppInBackground, floatPermission: $floatPermission" +
                    ", backgroundStartPermission: $bgPermission, notificationPermission: $notificationPermission , " +
                    "pushData: $pushData, enableIncomingBanner:$enableIncomingBanner"
        )

        if (DeviceUtils.isScreenLocked(context)) {
            handleScreenLocked(isAppInBackground, isFCMDataChannel, notificationPermission)
            return
        }

        if (isAppInBackground) {
            handleAppInBackground(floatPermission, isFCMDataChannel, notificationPermission, bgPermission)
            return
        }

        if (enableIncomingBanner) {
            when {
                floatPermission -> startSmallScreenView(IncomingFloatBanner(context))
                else -> startFullScreenView()
            }
        } else {
            startFullScreenView()
        }
    }

    private fun handleScreenLocked(appInBackground: Boolean, fcmData: Boolean, notificationPermission: Boolean) {
        Logger.i(TAG, "handleScreenLocked, screen is locked")
        if (appInBackground && fcmData && notificationPermission) {
            startSmallScreenView(IncomingNotificationBanner(context))
        } else {
            startFullScreenView()
        }
    }

    private fun handleAppInBackground(
        floatPermission: Boolean, fcmData: Boolean,
        notificationPermission: Boolean, bgPermission: Boolean
    ) {
        when {
            floatPermission -> startSmallScreenView(IncomingFloatBanner(context))
            fcmData && notificationPermission -> startSmallScreenView(IncomingNotificationBanner(context))
            bgPermission -> startFullScreenView()
            else -> Logger.w(TAG, "App is in background with no permission")
        }
    }

    private fun startFullScreenView() {
        Logger.i(TAG, "startFullScreenView")
        if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
            Logger.i(TAG, "startFullScreenView, current status: None, ignore")
            return
        }
        PermissionRequest.requestPermissions(context, CallManager.instance.callState.mediaType.get(), object
            : PermissionCallback() {
            override fun onGranted() {
                if (TUICallDefine.Status.None != CallManager.instance.userState.selfUser.get().callStatus.get()) {
                    Logger.i(TAG, "startFullScreenView requestPermissions onGranted")
                    startCallActivity()
                } else {
                    CallManager.instance.reset()
                }
            }

            override fun onDenied() {
                if (CallManager.instance.userState.selfUser.get().callRole == TUICallDefine.Role.Called) {
                    CallManager.instance.reject(null)
                }
                CallManager.instance.reset()
            }
        })
    }

    private fun startSmallScreenView(view: Any) {
        var caller = CallManager.instance.userState.selfUser.get()
        for (user in CallManager.instance.userState.remoteUserList.get()) {
            if (user.callRole == TUICallDefine.Role.Caller) {
                caller = user
                break
            }
        }

        val list = ArrayList<String?>()
        list.add(caller.id)
        UserManager.instance.updateUserListInfo(list, object : TUICommonDefine.ValueCallback<List<UserState.User>?> {
            override fun onSuccess(data: List<UserState.User>?) {
                if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                    Logger.w(TAG, "startSmallScreenView, current status: None, ignore")
                    return
                }
                caller.avatar.set(data!![0].avatar.get())
                caller.nickname.set(data[0].nickname.get())

                if (view is IncomingFloatBanner) {
                    view.showIncomingView(caller)
                } else if (view is IncomingNotificationBanner) {
                    view.showNotification(caller)
                }
            }

            override fun onError(errCode: Int, errMsg: String?) {
                if (view is IncomingFloatBanner) {
                    view.showIncomingView(caller)
                } else if (view is IncomingNotificationBanner) {
                    view.showNotification(caller)
                }
            }
        })
    }

    private fun registerObserver() {
        TUICallEngine.createInstance(context).addObserver(callObserver)
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
    }

    private fun registerEvent() {
        TUICore.registerEvent(Constants.KEY_TUI_CALLKIT, Constants.SUB_KEY_SHOW_FLOAT_WINDOW) { key, subKey, _ ->
            startFloatWindow()
        }
    }

    private fun startFloatWindow() {
        if (FloatWindowManager.sharedInstance().isPictureInPictureSupported && GlobalState.instance.enablePipMode) {
            CallManager.instance.viewState.enterPipMode.set(true)
            return
        }
        if (FloatWindowManager.sharedInstance().isShowing) {
            Logger.w(TAG, "There is already a floatWindow on display, do not open it again.")
            return
        }
        FloatWindowManager.sharedInstance().addObserver(floatWindowObserver)

        if (PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()) {
            CallManager.instance.viewState.router.set(ViewState.ViewRouter.FloatView)
            FloatWindowManager.sharedInstance().show(FloatWindowView(context.applicationContext))
        } else {
            PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).request()
        }
    }

    private fun isPictureInPictureSupported(): Boolean {
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.O) {
            return false
        }
        return context.packageManager.hasSystemFeature(
            PackageManager.FEATURE_PICTURE_IN_PICTURE
        )
    }

    private fun startCallActivity() {
        val intent = Intent(context, CallMainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }

    private fun showAntiFraudReminder() {
        notifyCallEndEvent()
        if (TUICallDefine.Status.Accept != CallManager.instance.userState.selfUser.get().callStatus.get()) {
            return
        }

        if (TUICore.getService(TUIConstants.Service.TUI_PRIVACY) == null) {
            return
        }
        val map = HashMap<String, Any?>()
        map[TUIConstants.Privacy.PARAM_DIALOG_CONTEXT] = context
        TUICore.callService(
            TUIConstants.Service.TUI_PRIVACY, TUIConstants.Privacy.METHOD_ANTO_FRAUD_REMINDER, map, null
        )
    }

    private fun notifyCallEndEvent() {
        val selfUser = CallManager.instance.userState.selfUser.get()
        if (selfUser.callStatus.get() == TUICallDefine.Status.None) {
            TUICore.notifyEvent(
                TUIConstants.Privacy.EVENT_ROOM_STATE_CHANGED, TUIConstants.Privacy.EVENT_SUB_KEY_ROOM_STATE_STOP, null
            )
            if (selfUser.callRole == Role.Caller) {

                TUICore.notifyEvent(EVENT_KEY_TIME_LIMIT, EVENT_SUB_KEY_COUNTDOWN_END, null)
            }
            return
        }
        if (selfUser.callStatus.get() == TUICallDefine.Status.Accept && selfUser.callRole == Role.Caller) {
            TUICore.notifyEvent(EVENT_KEY_TIME_LIMIT, EVENT_SUB_KEY_COUNTDOWN_START, null)
        }
    }

    private fun createDefaultCallParams(params: CallParams?): CallParams {
        val callParams = params ?: CallParams().apply {
            offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(context)
            timeout = Constants.CALL_WAITING_MAX_TIME
        }
        callParams.offlinePushInfo = callParams.offlinePushInfo ?: OfflinePushInfoConfig.createOfflinePushInfo(context)
        return callParams
    }

    private fun initCameraAndAudioDeviceState() {
        if (TUICallDefine.MediaType.Video == CallManager.instance.callState.mediaType.get()) {
            CallManager.instance.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Speakerphone)
            CallManager.instance.mediaState.isCameraOpened.set(true)
        } else {
            CallManager.instance.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Earpiece)
            CallManager.instance.mediaState.isCameraOpened.set(false)
        }
        CallManager.instance.mediaState.isMicrophoneMuted.set(false)
        CallManager.instance.userState.selfUser.get().audioAvailable.set(true)
    }

    companion object {
        private const val TAG = "IncomingView"
        private const val EVENT_KEY_TIME_LIMIT = "RTCRoomTimeLimitService"
        private const val EVENT_SUB_KEY_COUNTDOWN_START = "CountdownStart"
        private const val EVENT_SUB_KEY_COUNTDOWN_END = "CountdownEnd"
        private var instance: TUICallKitImpl? = null
        fun createInstance(context: Context): TUICallKitImpl {
            if (instance == null) {
                synchronized(TUICallKitImpl::class.java) {
                    if (instance == null) {
                        instance = TUICallKitImpl(context)
                    }
                }
            }
            return instance!!
        }
    }
}