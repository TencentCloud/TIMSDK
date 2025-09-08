package com.tencent.qcloud.tuikit.tuicallkit.view

import android.app.AppOpsManager
import android.app.PictureInPictureParams
import android.content.pm.ActivityInfo
import android.os.Build
import android.os.Bundle
import android.util.Rational
import android.view.View
import android.view.ViewGroup
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintLayout.LayoutParams
import androidx.lifecycle.Lifecycle
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.DeviceUtils
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.state.ViewState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatwindow.PipWindowView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.trtc.tuikit.common.FullScreenActivity
import com.trtc.tuikit.common.livedata.Observer
import com.trtc.tuikit.common.ui.floatwindow.FloatWindowManager
import com.trtc.tuikit.common.util.ToastUtil

class CallMainActivity : FullScreenActivity() {
    private var callView: ConstraintLayout? = null

    private val callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None) {
            Logger.i(TAG, "callStatusObserver, callStatus: $it")
            VideoFactory.instance.clearVideoView()
            finishCallMainActivity()
        }
    }

    private val viewRouterObserver = Observer<ViewState.ViewRouter> {
        if (it != ViewState.ViewRouter.FullView) {
            Logger.i(TAG, "viewRouterObserver, viewRouter: $it")
            finishCallMainActivity()
        }
    }

    private val enterPipModeObserver = Observer<Boolean> {
        if (it) {
            enterPictureInPictureModeWithBuild()
        }
    }

    private fun enterPictureInPictureModeWithBuild() {
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O && hasPipModePermission()) {
            val pictureInPictureParams: PictureInPictureParams.Builder = PictureInPictureParams.Builder()
            val floatViewWidth = resources.getDimensionPixelSize(R.dimen.tuicallkit_video_small_view_width)
            val floatViewHeight = resources.getDimensionPixelSize(R.dimen.tuicallkit_video_small_view_height)
            val aspectRatio = Rational(floatViewWidth, floatViewHeight)
            pictureInPictureParams.setAspectRatio(aspectRatio).build()
            val requestPipSuccess = this.enterPictureInPictureMode(pictureInPictureParams.build())
            if (!requestPipSuccess) {
                CallManager.instance.viewState.enterPipMode.set(false)
                return
            }
            callView?.animate()?.alpha(0.2f)?.setDuration(500)?.withEndAction {
                callView?.alpha = 1f
            }?.start()
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
            ToastUtil.toastShortMessage(getString(R.string.tuicallkit_enter_pip_mode_fail_hint))
        }
        return hasPipModePermission
    }

    private fun hangupOnPipWindowClose() {
        if (lifecycle.currentState == Lifecycle.State.CREATED) {
            Logger.i(TAG, "user close pip window")
            CallManager.instance.hangup(null)
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode)
        if (isInPictureInPictureMode) {
            callView?.removeAllViews()
            val lp = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
            callView?.addView(PipWindowView(this), lp)
        } else {
            CallManager.instance.viewState.enterPipMode.set(false)
            hangupOnPipWindowClose()
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
    }

    override fun onResume() {
        super.onResume()

        PermissionRequest.requestPermissions(application, CallManager.instance.callState.mediaType.get(),
            object : PermissionCallback() {
                override fun onGranted() {
                    initView()
                    handleCallAcceptAction()
                    registerObserver()
                }

                override fun onDenied() {
                    if (CallManager.instance.userState.selfUser.get().callRole == TUICallDefine.Role.Called) {
                        CallManager.instance.reject(null)
                    }
                    finishCallMainActivity()
                }
            })
    }

    private fun initView() {
        val scene = CallManager.instance.callState.scene.get()
        val callStatus = CallManager.instance.userState.selfUser.get().callStatus.get()
        Logger.i(TAG, "initView, scene: $scene ,callStatus: $callStatus")
        if (TUICallDefine.Status.None == callStatus) {
            finishCallMainActivity()
            return
        }
        callView?.removeAllViews()
        if (scene == TUICallDefine.Scene.GROUP_CALL || scene == TUICallDefine.Scene.MULTI_CALL) {
            callView = GroupCallView(this)
        } else if (scene == TUICallDefine.Scene.SINGLE_CALL) {
            callView = SingleCallView(this)
        }
        val view = GlobalState.instance.callAdapter?.onCreateMainView(callView!!) ?: callView
        val rootView = window.decorView.findViewById<View>(android.R.id.content) as ViewGroup
        rootView.addView(view)

        FloatWindowManager.sharedInstance().dismiss()
        CallManager.instance.viewState.router.set(ViewState.ViewRouter.FullView)
    }

    private fun handleCallAcceptAction() {
        val selfUser = CallManager.instance.userState.selfUser.get()
        if (selfUser.callStatus.get() == TUICallDefine.Status.Accept) {
            return
        }
        if (intent.action == Constants.ACCEPT_CALL_ACTION) {
            Logger.i(TAG, "IncomingView -> handleCallAcceptAction")
            CallManager.instance.accept(null)
            if (CallManager.instance.callState.mediaType.get() == TUICallDefine.MediaType.Video) {
                val videoView = VideoFactory.instance.createVideoView(application, selfUser)
                val camera = CallManager.instance.mediaState.isFrontCamera.get()
                CallManager.instance.openCamera(camera, videoView, null)
            }
        }
    }

    private fun registerObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
        CallManager.instance.viewState.router.observe(viewRouterObserver)
        CallManager.instance.viewState.enterPipMode.observe(enterPipModeObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(callStatusObserver)
        CallManager.instance.viewState.router.removeObserver(viewRouterObserver)
        CallManager.instance.viewState.enterPipMode.removeObserver(enterPipModeObserver)
    }

    private fun finishCallMainActivity() {
        callView?.removeAllViews()
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
            finishAndRemoveTask()
        } else {
            finish()
        }
    }

    override fun onUserLeaveHint() {
        if (CallManager.instance.viewState.enterPipMode.get()) {
            return
        }
        if (FloatWindowManager.sharedInstance().isPictureInPictureSupported && GlobalState.instance.enablePipMode) {
            CallManager.instance.viewState.enterPipMode.set(true)
        }
    }

    override fun onBackPressed() {}

    override fun onDestroy() {
        super.onDestroy()
        Logger.i(TAG, "onDestroy")
        unregisterObserver()
    }

    companion object {
        private const val TAG = "CallMainActivity"
    }
}