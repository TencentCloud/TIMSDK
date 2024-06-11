package com.tencent.qcloud.tuikit.tuicallkit.view

import android.app.NotificationManager
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.RelativeLayout
import androidx.appcompat.app.AppCompatActivity
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatWindowService
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory
import com.tencent.qcloud.tuikit.tuicallkit.view.root.GroupCallView
import com.tencent.qcloud.tuikit.tuicallkit.view.root.SingleCallView

class CallKitActivity : AppCompatActivity() {
    private var baseCallView: RelativeLayout? = null
    private var layoutContainer: FrameLayout? = null

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None) {
            TUILog.i(TAG, "callStatusObserver None -> finishActivity")
            removeObserver()
            finishActivity()
            VideoViewFactory.instance.clear()
            if (TUICallDefine.Status.None == TUICallState.instance.selfUser.get().callStatus.get()) {
                FloatWindowService.stopService()
            }
        }
    }

    private var isShowFullScreenObserver = Observer<Boolean> {
        if (it) {
            window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        TUILog.i(TAG, "onCreate")
        DeviceUtils.setScreenLockParams(window)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        activity = this
        setContentView(R.layout.tuicallkit_activity_call_kit)
        initStatusBar()
        addObserver()
    }

    override fun onResume() {
        super.onResume()
        TUILog.i(TAG, "onResume")
        if (TUICallDefine.Status.None == TUICallState.instance.selfUser.get().callStatus.get()) {
            if (null != activity) {
                activity?.finish()
            }
            activity = null
            removeObserver()
            return
        }
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager?
        notificationManager?.cancelAll()

        PermissionRequest.requestPermissions(application, TUICallState.instance.mediaType.get(),
            object : PermissionCallback() {
                override fun onGranted() {
                    initView()
                    startActivityByAction()
                }

                override fun onDenied() {
                    if (TUICallState.instance.selfUser.get().callRole.get() == TUICallDefine.Role.Called) {
                        EngineManager.instance.reject(null)
                    }
                }
            })
    }

    private fun startActivityByAction() {
        if (intent.action == Constants.ACCEPT_CALL_ACTION) {
            TUILog.i(TAG, "IncomingView -> startActivityByAction")
            EngineManager.instance.accept(null)
            if (TUICallState.instance.mediaType.get() == TUICallDefine.MediaType.Video) {
                val videoView = VideoViewFactory.instance.createVideoView(
                    TUICallState.instance.selfUser.get(), application
                )

                EngineManager.instance.openCamera(
                    TUICallState.instance.isFrontCamera.get(), videoView?.getVideoView(), null
                )
            }
        }
    }

    override fun onBackPressed() {}

    override fun onDestroy() {
        super.onDestroy()
        TUILog.i(TAG, "onDestroy")
    }

    private fun initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val window = window
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR)
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            window.statusBarColor = Color.TRANSPARENT
            val lp = window.getAttributes();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            }
            window.setAttributes(lp);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
        }
    }

    private fun initView() {
        layoutContainer = findViewById(R.id.rl_container)
        layoutContainer?.removeAllViews()
        if (baseCallView != null && baseCallView?.parent != null) {
            (baseCallView?.parent as ViewGroup).removeView(baseCallView)
        }

        when (TUICallState.instance.scene.get()) {
            TUICallDefine.Scene.SINGLE_CALL -> {
                baseCallView = SingleCallView(this)
                layoutContainer?.addView(baseCallView)
            }

            TUICallDefine.Scene.GROUP_CALL -> {
                baseCallView = GroupCallView(this)
                layoutContainer?.addView(baseCallView)
            }

            else -> {
                TUILog.w(TAG, "current scene is invalid")
                finishActivity()
            }
        }
    }

    private fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
        TUICallState.instance.isShowFullScreen.observe(isShowFullScreenObserver)
    }

    private fun removeObserver() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.isShowFullScreen.removeObserver(isShowFullScreenObserver)
    }

    companion object {
        private var activity: CallKitActivity? = null
        const val TAG = "CallKitActivity"

        fun finishActivity() {
            if (null != activity) {
                activity?.finish()
            }
            if (null != activity?.baseCallView && null != activity?.baseCallView?.parent) {
                (activity?.baseCallView?.parent as ViewGroup).removeView(activity?.baseCallView)
            }
            if (null != activity?.baseCallView && activity?.baseCallView is GroupCallView) {
                (activity?.baseCallView as GroupCallView).clear()
            }
            if (null != activity?.baseCallView && activity?.baseCallView is SingleCallView) {
                (activity?.baseCallView as SingleCallView).clear()
            }
            activity?.baseCallView = null
            activity?.layoutContainer = null
            activity = null
        }
    }
}