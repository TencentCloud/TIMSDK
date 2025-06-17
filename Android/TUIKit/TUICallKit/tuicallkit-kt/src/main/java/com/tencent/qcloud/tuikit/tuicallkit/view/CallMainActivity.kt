package com.tencent.qcloud.tuikit.tuicallkit.view

import android.content.pm.ActivityInfo
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import androidx.constraintlayout.widget.ConstraintLayout
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
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.trtc.tuikit.common.FullScreenActivity
import com.trtc.tuikit.common.livedata.Observer
import com.trtc.tuikit.common.ui.floatwindow.FloatWindowManager

class CallMainActivity : FullScreenActivity() {
    private var callView: ConstraintLayout? = null

    private val callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None) {
            Logger.i(TAG, "callStatusObserver, callStatus: $it")
            VideoFactory.instance.clearVideoView()
            finish()
        }
    }

    private val viewRouterObserver = Observer<ViewState.ViewRouter> {
        if (it != ViewState.ViewRouter.FullView) {
            Logger.i(TAG, "viewRouterObserver, viewRouter: $it")
            finish()
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
                    finish()
                }
            })
    }

    private fun initView() {
        val scene = CallManager.instance.callState.scene
        val callStatus = CallManager.instance.userState.selfUser.get().callStatus.get()

        Logger.i(TAG, "initView, scene: ${scene.get()} ,callStatus: $callStatus")
        if (TUICallDefine.Status.None == callStatus) {
            finish()
            return
        }

        callView?.removeAllViews()
        if (scene.get() == TUICallDefine.Scene.GROUP_CALL) {
            callView = GroupCallView(this)
        } else if (scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            callView = SingleCallView(this)
        }

        val rootView = window.decorView.findViewById<View>(android.R.id.content) as ViewGroup
        rootView.addView(callView)

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
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(callStatusObserver)
        CallManager.instance.viewState.router.removeObserver(viewRouterObserver)
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