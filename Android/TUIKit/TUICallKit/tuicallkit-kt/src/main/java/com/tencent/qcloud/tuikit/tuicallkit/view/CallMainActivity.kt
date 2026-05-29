package com.tencent.qcloud.tuikit.tuicallkit.view

import android.app.AppOpsManager
import android.app.PictureInPictureParams
import android.content.pm.ActivityInfo
import android.os.Build
import android.os.Bundle
import android.util.Rational
import android.view.View
import android.widget.ImageView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import android.Manifest
import android.app.Activity
import android.util.Log
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import android.widget.TextView
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.beauty.BeautyIntegration
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.common.metrics.KeyMetrics
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.DeviceUtils
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.state.ViewState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.inviteuser.InviteUserButton
import com.trtc.tuikit.common.FullScreenActivity
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.imageloader.ImageOptions
import com.trtc.tuikit.common.ui.floatwindow.FloatWindowManager
import io.trtc.tuikit.atomicx.callview.CallView
import kotlinx.coroutines.launch
import com.trtc.tuikit.common.util.ToastUtil
import io.trtc.tuikit.atomicx.callview.Feature
import io.trtc.tuikit.atomicx.common.permission.PermissionCallback
import io.trtc.tuikit.atomicx.common.permission.PermissionRequester
import io.trtc.tuikit.atomicxcore.api.call.CallEndReason
import io.trtc.tuikit.atomicxcore.api.call.CallListener
import io.trtc.tuikit.atomicxcore.api.call.CallMediaType
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import io.trtc.tuikit.atomicxcore.api.device.DeviceStore
import io.trtc.tuikit.atomicxcore.api.view.CallLayoutTemplate
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.first

class CallMainActivity : FullScreenActivity() {
    private var callView: CallView? = null
    private var imageFloatIcon: ImageView? = null
    private var imageBeautyIcon: ImageView? = null
    private var inviteUserButton: FrameLayout? = null
    private var callEndHintView: TextView? = null
    private var finishActivityJob: Job? = null
    private val callStatusObserver = object : CallListener() {
        override fun onCallEnded(callId: String, mediaType: CallMediaType, reason: CallEndReason, userId: String) {
            runOnUiThread {
                handleCallEnded(reason, userId)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        DeviceUtils.setScreenLockParams(window)
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        setContentView(R.layout.tuicallkit_activity_call_kit)
        requestedOrientation = when (GlobalState.instance.orientation) {
            Constants.Orientation.Portrait -> ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
            Constants.Orientation.LandScape -> ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
            else -> ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
        }
        callEndHintView = findViewById(R.id.tv_call_end_hint)
        CallStore.shared.addListener(callStatusObserver)
        lifecycleScope.launchWhenStarted {
            CallStore.shared.observerState.selfInfo.first {
                if (it.status == CallParticipantStatus.Accept) {
                    Log.i(TAG, "CallStore.shared.observerState.selfInfo accept")
                    val groupId = CallStore.shared.observerState.activeCall.value.chatGroupId
                    val inviteeSize = CallStore.shared.observerState.activeCall.value.inviteeIds.size
                    val mediaType = CallStore.shared.observerState.activeCall.value.mediaType
                    if (mediaType == CallMediaType.Video && groupId.isEmpty() && inviteeSize == 1) {
                        addBeautyView()
                    }
                    true
                }
                false
            }
        }
        val mediaType = CallStore.shared.observerState.activeCall.value.mediaType
        if (mediaType != null) {
            setAudioDeviceRoute(mediaType)
            openDeviceMediaForMediaType(mediaType)
        }
        CallManager.instance.startForegroundService()
    }

    private fun initView() {
        val callStatus = CallStore.shared.observerState.selfInfo.value.status
        if (CallParticipantStatus.None == callStatus) {
            finishCallMainActivity()
            return
        }
        val callId = CallStore.shared.observerState.activeCall.value.callId
        KeyMetrics.countUV(KeyMetrics.EventId.WAKEUP, callId)
        setBackground()
        addCallView()
        addFloatButton()
        addInviteButton()
        FloatWindowManager.sharedInstance().dismiss()
        CallManager.instance.viewState.router.set(ViewState.ViewRouter.FullView)
        handleCallAcceptAction()
    }

    private fun finishCallMainActivity() {
        if (isFinishing || isDestroyed) {
            return
        }
        callView?.removeAllViews()
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP && isTaskRoot) {
            finishAndRemoveTask()
        } else {
            finish()
        }
    }

    private fun addCallView() {
        val callViewContainer = findViewById<FrameLayout>(R.id.call_view_container)
        callViewContainer?.removeAllViews()
        callView?.removeAllViews()
        callView = CallView(this)
        val chatGroupId = CallStore.shared.observerState.activeCall.value.chatGroupId
        val inviteeIdListSize = CallStore.shared.observerState.activeCall.value.inviteeIds.size
        if (inviteeIdListSize == 1 && chatGroupId.isEmpty()) {
            callView?.setLayoutTemplate(CallLayoutTemplate.Float)
        } else {
            callView?.setLayoutTemplate(CallLayoutTemplate.Grid)
        }
        if (!GlobalState.instance.enableAITranscriber) {
            callView?.disableFeatures(listOf(Feature.AI_TRANSCRIBER))
        }
        val view = GlobalState.instance.callAdapter?.onCreateMainView(callView!!) ?: callView
        callViewContainer?.addView(view)
    }

    private fun addBeautyView() {
        imageBeautyIcon = findViewById(R.id.iv_beauty)
        imageBeautyIcon?.visibility =
            if (BeautyIntegration.isSupportTEBeauty() && !isInPipModeSafe()) View.VISIBLE else View.GONE
        imageBeautyIcon?.setOnClickListener {
            BeautyIntegration.showBeautyDialog(this)
        }
    }

    private fun addFloatButton() {
        imageFloatIcon = findViewById(R.id.image_float_icon)
        imageFloatIcon?.setOnClickListener {
            if (FloatWindowManager.sharedInstance().isPictureInPictureSupported) {
                enterPictureInPictureModeWithBuild()
            }
        }
    }

    private fun addInviteButton() {
        inviteUserButton = findViewById(R.id.rl_layout_invite_user)
        if (shouldShowInviteButton()) {
            inviteUserButton?.visibility = View.VISIBLE
            inviteUserButton?.addView(InviteUserButton(this))
            return
        }
        inviteUserButton?.visibility = View.GONE
    }

    private fun shouldShowInviteButton(): Boolean {
        val chatGroupId = CallStore.shared.observerState.activeCall.value.chatGroupId
        return !chatGroupId.isNullOrEmpty()
    }

    private fun setBackground() {
        val imageBackground = findViewById<ImageView>(R.id.img_view_background)
        val selfUser = CallStore.shared.observerState.selfInfo.value
        val option = ImageOptions.Builder().setPlaceImage(R.drawable.tuicallkit_ic_avatar).setBlurEffect(80f).build()
        ImageLoader.load(this, imageBackground, selfUser.avatarURL, option)
        imageBackground?.setColorFilter(ContextCompat.getColor(this, R.color.callkit_color_blur_mask))
    }

    private fun handleCallAcceptAction() {
        val selfStatus = CallStore.shared.observerState.selfInfo.value.status
        if (selfStatus == CallParticipantStatus.Accept) {
            return
        }
        if (intent.action == Constants.ACCEPT_CALL_ACTION) {
            Logger.i(TAG, "IncomingView -> handleCallAcceptAction")
            CallStore.shared.accept(null)
        }
    }

    override fun onResume() {
        super.onResume()
        val mediaType = CallStore.shared.observerState.activeCall.value.mediaType
        PermissionRequest.requestPermissions(application, mediaType,
            object : PermissionCallback() {
                override fun onGranted() {
                    initView()
                }

                override fun onDenied() {
                    val self = CallStore.shared.observerState.selfInfo.value
                    if (!isCaller(self.id)) {
                        CallManager.instance.reject(null)
                    }
                    finishCallMainActivity()
                }
            })
    }

    override fun onDestroy() {
        super.onDestroy()
        finishActivityJob?.cancel()
        CallStore.shared.removeListener(callStatusObserver)
        CallManager.instance.stopForegroundService()
        BeautyIntegration.resetBeauty()
        Logger.i(TAG, "onDestroy")
    }

    override fun onUserLeaveHint() {
        val hasAudioPermission = PermissionRequester.newInstance(Manifest.permission.RECORD_AUDIO).has()
        if (!hasAudioPermission) {
            return
        }
        val hasVideoPermission = PermissionRequester.newInstance(Manifest.permission.CAMERA).has()
        val mediaType = CallStore.shared.observerState.activeCall.value.mediaType
        if (mediaType == CallMediaType.Video && !hasVideoPermission) {
            return
        }
        enterPictureInPictureModeWithBuild()
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode)
        imageFloatIcon?.visibility = if (isInPictureInPictureMode) View.GONE else View.VISIBLE
        imageBeautyIcon?.visibility = if (isInPictureInPictureMode) View.GONE else View.VISIBLE
        if (shouldShowInviteButton()) {
            inviteUserButton?.visibility = if (isInPictureInPictureMode) View.GONE else View.VISIBLE
        }
        if (isInPictureInPictureMode) {
            callView?.setLayoutTemplate(CallLayoutTemplate.Pip)
        } else {
            hangupOnPipWindowClose()
        }
    }

    private fun hangupOnPipWindowClose() {
        if (lifecycle.currentState != Lifecycle.State.CREATED) {
            return
        }
        val callerId = CallStore.shared.observerState.activeCall.value.inviterId
        val selfId = CallStore.shared.observerState.selfInfo.value.id
        val selfStatus = CallStore.shared.observerState.selfInfo.value.status
        Logger.i(TAG, "user close pip window , callerId = $callerId , selfId = $selfId , selfStatus=$selfStatus")
        if (selfId == callerId) {
            CallManager.instance.hangup(null)
            return
        }
        if (selfStatus == CallParticipantStatus.Waiting) {
            CallManager.instance.reject(null)
        } else {
            CallManager.instance.hangup(null)
        }
    }

    private fun enterPictureInPictureModeWithBuild() {
        if (!lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
            return
        }
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O && hasPipModePermission()) {
            val pictureInPictureParams: PictureInPictureParams.Builder = PictureInPictureParams.Builder()
            val floatViewWidth = resources.getDimensionPixelSize(R.dimen.callkit_video_small_view_width)
            val floatViewHeight = resources.getDimensionPixelSize(R.dimen.callkit_video_small_view_height)
            val aspectRatio = Rational(floatViewWidth, floatViewHeight)
            pictureInPictureParams.setAspectRatio(aspectRatio).build()
            val requestPipSuccess = this.enterPictureInPictureMode(pictureInPictureParams.build())
            if (!requestPipSuccess) {
                CallManager.instance.viewState.enterPipMode.set(false)
                return
            }
        } else {
            Logger.w(TAG, "current version (" + Build.VERSION.SDK_INT + ") does not support picture-in-picture")
        }
    }

    private fun hasPipModePermission(): Boolean {
        val appOpsManager = this.getSystemService(APP_OPS_SERVICE) as AppOpsManager
        val hasPipModePermission =
            (AppOpsManager.MODE_ALLOWED == appOpsManager.checkOpNoThrow(
                AppOpsManager.OPSTR_PICTURE_IN_PICTURE,
                this.applicationInfo.uid,
                this.packageName
            ))
        if (!hasPipModePermission) {
            ToastUtil.toastShortMessage(getString(R.string.callkit_enter_pip_mode_fail_hint))
        }
        return hasPipModePermission
    }

    private fun openDeviceMediaForMediaType(mediaType: CallMediaType) {
        DeviceStore.shared().openLocalMicrophone(null)
        if (mediaType == CallMediaType.Video) {
            BeautyIntegration.setupVideoProcessor()
            DeviceStore.shared().openLocalCamera(true, null)
        }
    }

    private fun getEndCallHintText(reason: CallEndReason, userId: String): String? {
        val activeCall = CallStore.shared.observerState.activeCall.value
        val selfInfo = CallStore.shared.observerState.selfInfo.value
        if (activeCall.inviteeIds.size > 1 || activeCall.chatGroupId.isNotEmpty() || selfInfo.id == userId) {
            return null
        }
        return when (reason) {
            CallEndReason.Hangup -> getString(R.string.callkit_toast_other_party_hung_up)
            CallEndReason.Reject -> getString(R.string.callkit_toast_other_party_declined)
            CallEndReason.NoResponse -> getString(R.string.callkit_toast_other_party_no_response)
            CallEndReason.LineBusy -> getString(R.string.callkit_toast_other_party_busy)
            CallEndReason.Canceled -> getString(R.string.callkit_toast_other_party_cancelled)
            else -> null
        }
    }

    private fun handleCallEnded(reason: CallEndReason, userId: String) {
        val endHintText = getEndCallHintText(reason, userId)
        if (endHintText.isNullOrEmpty()) {
            finishCallMainActivity()
            return
        }
        showEndCallHint(endHintText)
    }

    private fun showEndCallHint(text: String) {
        finishActivityJob?.cancel()
        callEndHintView?.apply {
            alpha = 1f
            visibility = View.VISIBLE
            this.text = text
        }
        finishActivityJob = lifecycleScope.launch {
            delay(CALL_END_HINT_DURATION_MS)
            finishCallMainActivity()
        }
    }

    private fun setAudioDeviceRoute(mediaType: CallMediaType) {
        if (CallMediaType.Video == mediaType) {
            CallManager.instance.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Speakerphone)
        } else {
            CallManager.instance.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Earpiece)
        }
    }

    private fun isCaller(userId: String): Boolean {
        val callerId = CallStore.shared.observerState.activeCall.value.inviterId
        return callerId == userId
    }

    private fun Activity.isInPipModeSafe(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            try {
                isInPictureInPictureMode
            } catch (e: Exception) {
                Logger.e(TAG, "isInPictureInPictureMode failed. {Device:${Build.MODEL},Exception:$e}")
                false
            }
        } else {
            false
        }
    }

    companion object {
        private const val TAG = "CallMainActivity"
        private const val CALL_END_HINT_DURATION_MS = 1000L
    }
}