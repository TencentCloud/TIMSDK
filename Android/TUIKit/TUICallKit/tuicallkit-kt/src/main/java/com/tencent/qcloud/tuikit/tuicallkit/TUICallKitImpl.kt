package com.tencent.qcloud.tuikit.tuicallkit

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Callback
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.common.metrics.KeyMetrics
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.DeviceUtils
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.PushManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.UserManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.state.ViewState.ViewRouter
import com.tencent.qcloud.tuikit.tuicallkit.view.CallAdapter
import com.tencent.qcloud.tuikit.tuicallkit.view.CallMainActivity
import com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingbanner.IncomingFloatBanner
import com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingbanner.IncomingNotificationBanner
import com.trtc.tuikit.common.ui.floatwindow.FloatWindowManager
import io.trtc.tuikit.atomicx.common.permission.PermissionCallback
import io.trtc.tuikit.atomicx.common.permission.PermissionRequester
import io.trtc.tuikit.atomicx.widget.basicwidget.toast.AtomicToast
import io.trtc.tuikit.atomicx.widget.basicwidget.toast.AtomicToast.Style
import io.trtc.tuikit.atomicxcore.api.CompletionHandler
import io.trtc.tuikit.atomicxcore.api.call.CallEndReason
import io.trtc.tuikit.atomicxcore.api.call.CallListener
import io.trtc.tuikit.atomicxcore.api.call.CallMediaType
import io.trtc.tuikit.atomicxcore.api.call.CallParams
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantInfo
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import io.trtc.tuikit.atomicxcore.api.login.LoginStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.supervisorScope

class TUICallKitImpl private constructor(context: Context) : TUICallKit() {
    private val context = context.applicationContext ?: context
    private val mainHandler = Handler(Looper.getMainLooper())
    private var subscribeSelfStateJob: Job? = null
    private val callStatusObserver = object : CallListener() {
        override fun onCallStarted(callId: String, mediaType: CallMediaType) {
            if (selfIsCaller() && GlobalState.instance.enableAITranscriber) {
                CallManager.instance.startRealtimeTranscriber()
            }
        }
        override fun onCallEnded(callId: String, mediaType: CallMediaType, reason: CallEndReason, userId: String) {
            val activeCall = CallStore.shared.observerState.activeCall.value
            val selfInfo = CallStore.shared.observerState.selfInfo.value
            if (activeCall.inviteeIds.size > 1 || activeCall.chatGroupId.isNotEmpty() || selfInfo.id == userId) {
                return
            }

            if (reason == CallEndReason.LineBusy) {
                mainHandler.post {
                    AtomicToast.show(context, context.getString(R.string.callkit_toast_other_party_busy), Style.INFO)
                }
            }
        }

        override fun onCallReceived(callId: String, mediaType: CallMediaType, userData: String) {
            KeyMetrics.countUV(KeyMetrics.EventId.RECEIVED, callId)
        }
    }

    init {
        registerObserver()
    }

    override fun setSelfInfo(nickname: String?, avatar: String?, completion: CompletionHandler?) {
        CallManager.instance.setSelfInfo(nickname, avatar, completion)
    }

    override fun calls(
        userIdList: List<String>, mediaType: CallMediaType, params: CallParams?, completion: CompletionHandler?
    ) {
        val selfStatus = CallStore.shared.observerState.selfInfo.value.status
        if (selfStatus != CallParticipantStatus.None) {
            completion?.onFailure(TUICallDefine.ERROR_PARAM_INVALID, "You are currently on a call.")
            AtomicToast.show(context, context.getString(R.string.callkit_toast_error_already_in_call), Style.ERROR)
            return
        }
        val list = userIdList.distinct().toMutableList()
        if (list.isEmpty()) {
            Logger.e(TAG, "calls failed, userIdList is empty")
            completion?.onFailure(TUICallDefine.ERROR_PARAM_INVALID, "calls failed, userIdList is empty")
            return
        }
        if (list.singleOrNull() == LoginStore.shared.loginState.loginUserInfo.value?.userID) {
            AtomicToast.show(context, context.getString(R.string.callkit_toast_error_call_self), Style.ERROR)
            completion?.onFailure(TUICallDefine.ERROR_PARAM_INVALID, "calls failed, you cannot call yourself")
            return
        }
        PermissionRequest.requestPermissions(context, mediaType, object : PermissionCallback() {
            override fun onGranted() {
                CallManager.instance.calls(list, mediaType, params, object : CompletionHandler {
                    override fun onSuccess() {
                        startCallActivity()
                        completion?.onSuccess()
                    }

                    override fun onFailure(code: Int, desc: String) {
                        completion?.onFailure(code, desc)
                        CallManager.instance.reset()
                    }
                })
            }

            override fun onDenied() {
                Logger.w(TAG, "calls, request Permissions failed")
                completion?.onFailure(TUICallDefine.ERROR_PERMISSION_DENIED, "request Permissions failed")
            }
        })
    }

    override fun join(callId: String?, completion: CompletionHandler?) {
        val selfStatus = CallStore.shared.observerState.selfInfo.value.status
        if (selfStatus != CallParticipantStatus.None) {
            completion?.onFailure(TUICallDefine.ERROR_PARAM_INVALID, "You are currently on a call.")
            AtomicToast.show(context, context.getString(R.string.callkit_toast_error_already_in_call), Style.ERROR)
            return
        }
        PermissionRequest.requestPermissions(context, CallMediaType.Video, object : PermissionCallback() {
            override fun onGranted() {
                CallManager.instance.join(callId, object : Callback {
                    override fun onSuccess() {
                        startCallActivity()
                        completion?.onSuccess()
                    }

                    override fun onError(errCode: Int, errMsg: String?) {
                        completion?.onFailure(errCode, errMsg ?: "")
                        CallManager.instance.reset()
                    }
                })
            }

            override fun onDenied() {
                Logger.w(TAG, "join, request Permissions failed")
                completion?.onFailure(TUICallDefine.ERROR_PERMISSION_DENIED, "request Permissions failed")
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

    override fun enableAITranscriber(enable: Boolean) {
        CallManager.instance.enableAITranscriber(enable)
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

    fun queryOfflineCall() {
        if (FloatWindowManager.sharedInstance().isShowing) {
            Logger.w(TAG, "queryOfflineCall, float window is showing")
            return
        }

        Logger.i(TAG, "queryOfflineCall start")
        val selfUser = CallStore.shared.observerState.selfInfo.value
        val mediaType = CallStore.shared.observerState.activeCall.value.mediaType
        if (CallParticipantStatus.Accept == selfUser.status) {
            return
        }

        if (null == mediaType) {
            Logger.w(TAG, "queryOfflineCall, current status is Unknown")
            return
        }

        //The received call has been processed in #onCallReceived
        if (!selfIsCaller() && PermissionRequester.newInstance(PermissionRequester.BG_START_PERMISSION).has()) {
            return
        }
        startCallActivity()
    }

    private fun registerObserver() {
        CallStore.shared.addListener(callStatusObserver)
        subscribeSelfStateJob = CoroutineScope(Dispatchers.Main).launch {
            supervisorScope {
                launch { observeSelfInfo() }
            }
        }
    }

    private suspend fun observeSelfInfo() {
        CallStore.shared.observerState.selfInfo.collect { selfInfo ->
            Logger.i(TAG, "selfInfo id=${selfInfo.id} status=${selfInfo.status}")
            notifyInternalEvent()
            if (selfInfo.status == CallParticipantStatus.None) {
                CallManager.instance.reset()
                return@collect
            }
            if (selfInfo.status != CallParticipantStatus.Waiting || selfIsCaller()) {
                return@collect
            }
            handleNewCall()
        }
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
        if (CallStore.shared.observerState.selfInfo.value.status == CallParticipantStatus.None) {
            Logger.i(TAG, "startFullScreenView, current status: None, ignore")
            return
        }
        val mediaType = CallStore.shared.observerState.activeCall.value.mediaType
        PermissionRequest.requestPermissions(context, mediaType, object
            : PermissionCallback() {
            override fun onGranted() {
                if (CallParticipantStatus.None != CallStore.shared.observerState.selfInfo.value.status) {
                    Logger.i(TAG, "startFullScreenView requestPermissions onGranted")
                    startCallActivity()
                } else {
                    CallManager.instance.reset()
                }
            }

            override fun onDenied() {
                if (!selfIsCaller()) {
                    CallStore.shared.reject(null)
                }
                CallManager.instance.reset()
            }
        })
    }

    private fun startSmallScreenView(view: Any) {
        if (CallManager.instance.viewState.router.get() == ViewRouter.FullView) {
            return
        }
        val inviterId = CallStore.shared.observerState.activeCall.value.inviterId
        val caller = CallParticipantInfo()
        caller.id = inviterId
        val callStatus = CallStore.shared.observerState.selfInfo.value.status

        val list = ArrayList<String?>()
        list.add(caller.id)
        UserManager.instance.updateUserListInfo(list, object : TUICommonDefine.ValueCallback<List<CallParticipantInfo>?> {
            override fun onSuccess(data: List<CallParticipantInfo>?) {
                if (callStatus == CallParticipantStatus.None) {
                    Logger.w(TAG, "startSmallScreenView, current status: None, ignore")
                    return
                }
                caller.avatarURL = data!![0].avatarURL
                caller.name = data[0].name

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

    private fun startCallActivity() {
        val intent = Intent(context, CallMainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }

    private fun notifyInternalEvent() {
        val selfUser = CallStore.shared.observerState.selfInfo.value
        if (selfUser.status == CallParticipantStatus.None) {
            TUICore.notifyEvent(
                TUIConstants.Privacy.EVENT_ROOM_STATE_CHANGED, TUIConstants.Privacy.EVENT_SUB_KEY_ROOM_STATE_STOP, null
            )
            if (selfIsCaller()) {
                TUICore.notifyEvent(EVENT_KEY_TIME_LIMIT, EVENT_SUB_KEY_COUNTDOWN_END, null)
            }
            return
        }
        if (selfUser.status == CallParticipantStatus.Accept) {
            if (selfIsCaller()) {
                TUICore.notifyEvent(EVENT_KEY_TIME_LIMIT, EVENT_SUB_KEY_COUNTDOWN_START, null)
            }
            if (TUICore.getService(TUIConstants.Service.TUI_PRIVACY) != null) {
                val map = HashMap<String, Any?>()
                map[TUIConstants.Privacy.PARAM_DIALOG_CONTEXT] = context
                TUICore.callService(
                    TUIConstants.Service.TUI_PRIVACY, TUIConstants.Privacy.METHOD_ANTO_FRAUD_REMINDER, map, null
                )
            }
        }
    }

    private fun selfIsCaller(): Boolean {
        val selfId = CallStore.shared.observerState.selfInfo.value.id
        val callerId = CallStore.shared.observerState.activeCall.value.inviterId
        return selfId == callerId
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
