package com.tencent.qcloud.tuikit.tuicallkit.view.root

import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.RelativeLayout
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.CallTimerView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.CallWaitingHintView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatingWindowButton
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.AudioAndVideoCalleeWaitingView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.AudioCallerWaitingAndAcceptedView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.VideoCallerAndCalleeAcceptedView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.VideoCallerWaitingView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.single.AudioCallUserInfoView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.single.VideoCallUserInfoView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.SingleCallVideoLayout

class SingleCallView(context: Context) : RelativeLayout(context) {
    private var layoutTimer: FrameLayout? = null
    private var layoutUserInfo: FrameLayout? = null
    private var layoutFunction: FrameLayout? = null
    private var layoutFloatIcon: FrameLayout? = null
    private var layoutRender: FrameLayout? = null
    private var layoutCallTag: FrameLayout? = null

    private var functionView: BaseCallView? = null
    private var userInfoView: BaseCallView? = null
    private var callTimerView: CallTimerView? = null
    private var hintView: CallWaitingHintView? = null
    private var singleCallVideoLayout: SingleCallVideoLayout? = null
    private var floatingWindowButton: FloatingWindowButton? = null

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        refreshFunctionView()
        refreshTimerView()
        showAntiFraudReminder()
    }

    private var mediaTypeObserver = Observer<TUICallDefine.MediaType> {
        if (it != TUICallDefine.MediaType.Unknown) {
            refreshUserInfoView()
            refreshFunctionView()
            refreshRenderView()
            refreshFloatView()
        }
    }

    private var isShowFullScreenObserver = Observer<Boolean> {
        if (it) {
            layoutFloatIcon?.visibility = GONE
            layoutTimer?.visibility = GONE
            layoutFunction?.visibility = GONE
        } else {
            layoutFloatIcon?.visibility = VISIBLE
            layoutTimer?.visibility = VISIBLE
            layoutFunction?.visibility = VISIBLE
            layoutFloatIcon?.bringToFront()
            layoutTimer?.bringToFront()
            layoutFunction?.bringToFront()
        }
    }

    init {
        initView()
        addObserver()
    }

    fun clear() {
        functionView?.clear()
        userInfoView?.clear()
        callTimerView?.clear()
        singleCallVideoLayout?.clear()
        floatingWindowButton?.clear()
        removeObserver()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_root_view_single, this)
        layoutRender = findViewById(R.id.rl_container)
        layoutFloatIcon = findViewById(R.id.rl_layout_float_icon)
        layoutUserInfo = findViewById(R.id.rl_user_info_layout)
        layoutTimer = findViewById(R.id.rl_single_time)
        layoutFunction = findViewById(R.id.rl_single_function)
        layoutCallTag = findViewById(R.id.fl_call_tag)

        hintView = CallWaitingHintView(context)
        if (hintView?.parent != null) {
            (hintView?.parent as ViewGroup).removeView(hintView)
        }
        if (hintView != null) {
            layoutCallTag?.addView(hintView)
        }

        refreshUserInfoView()
        refreshFunctionView()
        refreshTimerView()
        refreshRenderView()
        refreshFloatView()
    }

    private fun refreshFloatView() {
        layoutFloatIcon?.removeAllViews()
        floatingWindowButton = FloatingWindowButton(context)
        layoutFloatIcon?.addView(floatingWindowButton)
    }

    private fun refreshRenderView() {
        if (TUICallState.instance.mediaType.get() == TUICallDefine.MediaType.Video) {
            singleCallVideoLayout = SingleCallVideoLayout(context)
            layoutRender!!.removeAllViews()
            layoutRender!!.addView(singleCallVideoLayout)
        } else {
            layoutRender!!.removeAllViews()
            singleCallVideoLayout = null
        }
    }

    private fun refreshTimerView() {
        if (TUICallDefine.Status.Accept == TUICallState.instance.selfUser.get().callStatus.get()) {
            layoutTimer?.removeAllViews()
            callTimerView = CallTimerView(context)
            layoutTimer?.addView(callTimerView)
        } else {
            layoutTimer?.removeAllViews()
            callTimerView = null
        }
    }

    private fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
        TUICallState.instance.mediaType.observe(mediaTypeObserver)
        TUICallState.instance.isShowFullScreen.observe(isShowFullScreenObserver)
    }

    private fun removeObserver() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        TUICallState.instance.isShowFullScreen.removeObserver(isShowFullScreenObserver)
    }

    private fun refreshUserInfoView() {
        if (TUICallState.instance.mediaType.get() == TUICallDefine.MediaType.Audio) {
            layoutUserInfo?.visibility = VISIBLE
            userInfoView = AudioCallUserInfoView(context)
            layoutUserInfo!!.removeAllViews()
            if (null != userInfoView) {
                layoutUserInfo!!.addView(userInfoView)
            }
        } else {
            if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.Waiting) {
                layoutUserInfo?.visibility = VISIBLE
                userInfoView = VideoCallUserInfoView(context)
                layoutUserInfo!!.removeAllViews()
                if (null != userInfoView) {
                    layoutUserInfo!!.addView(userInfoView)
                }
            } else {
                layoutUserInfo?.visibility = GONE
            }
        }
    }

    private fun refreshFunctionView() {
        if (TUICallDefine.Status.Waiting == TUICallState.instance.selfUser.get().callStatus.get()) {

            if (TUICallState.instance.selfUser.get().callRole.get() == TUICallDefine.Role.Caller) {
                if (TUICallState.instance.mediaType.get() == TUICallDefine.MediaType.Audio) {
                    functionView = AudioCallerWaitingAndAcceptedView(context)
                } else {
                    functionView = VideoCallerWaitingView(context)
                }
            } else {
                functionView = AudioAndVideoCalleeWaitingView(context)
            }
        } else if (TUICallDefine.Status.Accept == TUICallState.instance.selfUser.get().callStatus.get()) {
            if (TUICallState.instance.mediaType.get() == TUICallDefine.MediaType.Audio) {
                functionView = AudioCallerWaitingAndAcceptedView(context)
            } else {
                functionView = VideoCallerAndCalleeAcceptedView(context)
            }
        }

        layoutFunction!!.removeAllViews()
        if (null != functionView) {
            layoutFunction!!.addView(functionView)
        }
    }

    private fun showAntiFraudReminder() {
        if (TUICallDefine.Status.Accept != TUICallState.instance.selfUser.get().callStatus.get()) {
            return
        }

        if (TUICore.getService(TUIConstants.Service.TUI_PRIVACY) == null) {
            return
        }
        var map = HashMap<String, Any?>()
        map[TUIConstants.Privacy.PARAM_DIALOG_CONTEXT] = context
        TUICore.callService(
            TUIConstants.Service.TUI_PRIVACY, TUIConstants.Privacy.METHOD_ANTO_FRAUD_REMINDER, map, null
        )
    }
}