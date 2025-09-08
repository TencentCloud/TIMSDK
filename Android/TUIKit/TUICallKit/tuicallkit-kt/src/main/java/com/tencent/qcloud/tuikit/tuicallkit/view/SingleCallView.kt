package com.tencent.qcloud.tuikit.tuicallkit.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.constraintlayout.widget.ConstraintLayout
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.CallFunctionLayout
import com.tencent.qcloud.tuikit.tuicallkit.view.component.hint.CallHintView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.hint.CallTimerView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.CallVideoLayout
import com.trtc.tuikit.common.livedata.Observer

class SingleCallView(context: Context) : ConstraintLayout(context) {
    private val activityContext = context
    private var layoutFunction: FrameLayout? = null
    private var layoutTimer: FrameLayout? = null
    private var layoutCallHint: FrameLayout? = null
    private var floatButton: ImageView? = null

    private var isScreenCleanedObserver = Observer<Boolean> {
        layoutFunction?.visibility = if (it) View.GONE else View.VISIBLE
        layoutTimer?.visibility = if (it) View.GONE else View.VISIBLE
        layoutCallHint?.visibility = if (it) View.GONE else View.VISIBLE
        floatButton?.visibility = if (it) View.GONE else View.VISIBLE
    }

    init {
        initView()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun registerObserver() {
        CallManager.instance.viewState.isScreenCleaned.observe(isScreenCleanedObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.viewState.isScreenCleaned.removeObserver(isScreenCleanedObserver)
    }

    private fun initView() {
        LayoutInflater.from(activityContext).inflate(R.layout.tuicallkit_root_view_single, this)

        val callVideoLayout = CallVideoLayout(activityContext)
        val callAdapter = GlobalState.instance.callAdapter
        val view = callAdapter?.onCreateStreamView(callVideoLayout)
        if (view != null) {
            val lp = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
            this.addView(view, lp)
            return
        }

        addVideoLayout(callVideoLayout)
        addFunctionLayout()
        addCallTimeView()
        addCallHintView()
        addFloatButton()
    }

    private fun addVideoLayout(videoLayout: CallVideoLayout) {
        val layoutVideo: FrameLayout = findViewById(R.id.fl_video)
        layoutVideo.addView(videoLayout)
    }

    private fun addFunctionLayout() {
        layoutFunction = findViewById(R.id.rl_single_function)
        layoutFunction?.addView(CallFunctionLayout(activityContext))
    }

    private fun addCallTimeView() {
        layoutTimer = findViewById(R.id.rl_single_time)
        layoutTimer?.addView(CallTimerView(activityContext))
    }

    private fun addCallHintView() {
        layoutCallHint = findViewById(R.id.fl_call_hint)
        layoutCallHint?.addView(CallHintView(activityContext))
    }

    private fun addFloatButton() {
        if (!GlobalState.instance.enableFloatWindow) {
            return
        }
        floatButton = findViewById(R.id.image_float_icon)
        floatButton?.visibility = View.VISIBLE
        floatButton?.setOnClickListener {
            TUICore.notifyEvent(Constants.KEY_TUI_CALLKIT, Constants.SUB_KEY_SHOW_FLOAT_WINDOW, null)
        }
    }
}