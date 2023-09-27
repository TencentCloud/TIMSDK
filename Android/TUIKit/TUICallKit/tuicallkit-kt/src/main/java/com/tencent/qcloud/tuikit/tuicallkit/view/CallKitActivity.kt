package com.tencent.qcloud.tuikit.tuicallkit.view

import android.app.NotificationManager
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.RelativeLayout
import androidx.appcompat.app.AppCompatActivity
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallEvent
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallEvent.Companion.EVENT_KEY_CODE
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallEvent.Companion.EVENT_KEY_MESSAGE
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallEvent.Companion.EVENT_KEY_USER_ID
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils.setScreenLockParams
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatWindowService
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory
import com.tencent.qcloud.tuikit.tuicallkit.view.root.GroupCallView
import com.tencent.qcloud.tuikit.tuicallkit.view.root.SingleCallView

class CallKitActivity : AppCompatActivity() {
    private var baseCallView: RelativeLayout? = null
    private var layoutContainer: RelativeLayout? = null

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None) {
            TUILog.i(TAG, "callStatusObserver None -> finishActivity")
            finishActivity()
        }
    }

    private var callEventObserver = Observer<TUICallEvent> {
        if (it.eventType == TUICallEvent.EventType.TIP) {
            when (it.event) {
                (TUICallEvent.Event.USER_REJECT) -> {
                    var userId = it.param?.get(EVENT_KEY_USER_ID) as String
                    showUserToast(userId, R.string.tuicalling_toast_user_reject_call)
                }
                (TUICallEvent.Event.USER_LEAVE) -> {
                    var userId = it.param?.get(EVENT_KEY_USER_ID) as String
                    showUserToast(userId, R.string.tuicalling_toast_user_end)
                }
                (TUICallEvent.Event.USER_LINE_BUSY) -> {
                    var userId = it.param?.get(EVENT_KEY_USER_ID) as String
                    showUserToast(userId, R.string.tuicalling_toast_user_busy)
                }
                (TUICallEvent.Event.USER_NO_RESPONSE) -> {
                    var userId = it.param?.get(EVENT_KEY_USER_ID) as String
                    showUserToast(userId, R.string.tuicalling_toast_user_not_response)
                }
                (TUICallEvent.Event.USER_EXCEED_LIMIT) -> {
                    ToastUtil.toastLongMessage(getString(R.string.tuicalling_user_exceed_limit))
                }
                else -> {}
            }
        } else if (TUICallEvent.EventType.ERROR == it.eventType && TUICallEvent.Event.ERROR_COMMON == it.event) {
            var code = it.param?.get(EVENT_KEY_CODE) as Int
            var msg = it.param?.get(EVENT_KEY_MESSAGE) as String
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        TUILog.i(TAG, "onCreate")
        setScreenLockParams(window)
        mActivity = this
        setContentView(R.layout.tuicallkit_activity_call_kit)
        initStatusBar()
        addObserver()
    }

    override fun onResume() {
        super.onResume()
        TUILog.i(TAG, "onResume")
        if (TUICallDefine.Status.None == TUICallState.instance.selfUser.get().callStatus.get()) {
            if (null != mActivity) {
                mActivity?.finish()
            }
            mActivity = null
            removeObserver()
            return
        }
        initView()
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager?
        notificationManager?.cancelAll()
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
        if (TUICallState.instance.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            baseCallView = SingleCallView(this)
        } else {
            baseCallView = GroupCallView(this)
        }
        layoutContainer?.addView(baseCallView)
    }

    private fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
        TUICallState.instance.event.observe(callEventObserver)
    }

    private fun removeObserver() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.event.removeObserver(callEventObserver)
    }

    private fun showUserToast(userId: String, msgId: Int) {
        if (TextUtils.isEmpty(userId)) {
            return
        }
        var userName = userId
        if (userId == TUICallState.instance.selfUser.get().id) {
            if (!TextUtils.isEmpty(TUICallState.instance.selfUser.get().nickname.get())) {
                userName = TUICallState.instance.selfUser.get().nickname.get()
            }
        } else {
            for (user in TUICallState.instance.remoteUserList.get()) {
                if (null != user && !TextUtils.isEmpty(user.id) && userId == user.id) {
                    if (!TextUtils.isEmpty(user.nickname.get())) {
                        userName = user.nickname.get()
                    }
                }
            }
        }
        ToastUtil.toastLongMessage(ServiceInitializer.getAppContext().getString(msgId, userName))
    }

    private fun finishActivity() {
        if (null != mActivity) {
            mActivity?.finish()
        }
        mActivity = null
        removeObserver()
        if (null != baseCallView && null != baseCallView!!.parent) {
            (baseCallView!!.parent as ViewGroup).removeView(baseCallView)
        }
        if (null != baseCallView && baseCallView is GroupCallView) {
            (baseCallView as GroupCallView).clear()
        }
        if (null != baseCallView && baseCallView is SingleCallView) {
            (baseCallView as SingleCallView).clear()
        }
        baseCallView = null
        layoutContainer = null
        VideoViewFactory.instance.clear()
        if (TUICallDefine.Status.None == TUICallState.instance.selfUser.get().callStatus.get()) {
            FloatWindowService.stopService()
        }
    }

    companion object {
        private var mActivity: AppCompatActivity? = null
        const val TAG = "CallKitActivity"

        fun finishActivity() {
            if (null != mActivity) {
                mActivity!!.finish()
            }
        }
    }
}