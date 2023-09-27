package com.tencent.qcloud.tuikit.tuicallkit.view.root

import android.content.Context
import android.view.LayoutInflater
import android.widget.RelativeLayout
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.view.component.SwitchAudioView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.CallTimerView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatingWindowButton
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.*
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.SingleCallVideoLayout
import com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.single.AudioCallUserInfoView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.single.VideoCallUserInfoView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.root.SingleCallViewModel

class SingleCallView(context: Context) : RelativeLayout(context) {

    private var layoutTimer: RelativeLayout? = null
    private var layoutUserInfoVideo: RelativeLayout? = null
    private var layoutUserInfoAudio: RelativeLayout? = null
    private var layoutSwitchAudio: RelativeLayout? = null
    private var layoutFunction: RelativeLayout? = null
    private var layoutFloatIcon: RelativeLayout? = null
    private var layoutRender: RelativeLayout? = null

    private var functionView: BaseCallView? = null
    private var userInfoView: BaseCallView? = null
    private var switchAudioView: SwitchAudioView? = null
    private var callTimerView: CallTimerView? = null
    private var singleCallVideoLayout: SingleCallVideoLayout? = null
    private var floatingWindowButton: FloatingWindowButton? = null
    private var viewModel = SingleCallViewModel()

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        refreshFunctionView()
        refreshTimerView()
    }

    private var mediaTypeObserver = Observer<TUICallDefine.MediaType> {
        if (it != TUICallDefine.MediaType.Unknown) {
            refreshUserInfoView()
            refreshFunctionView()
            refreshSwitchAudioView()
            refreshRenderView()
            refreshFloatView()
        }
    }

    init {
        initView()

        addObserver()
    }

    fun clear() {
        functionView?.clear()
        userInfoView?.clear()
        switchAudioView?.clear()
        callTimerView?.clear()
        singleCallVideoLayout?.clear()
        floatingWindowButton?.clear()
        removeObserver()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_root_view_single, this)
        layoutRender = findViewById(R.id.rl_container)
        layoutFloatIcon = findViewById(R.id.rl_layout_float_icon)
        layoutUserInfoVideo = findViewById(R.id.rl_video_user_info_layout)
        layoutUserInfoAudio = findViewById(R.id.rl_audio_user_info_layout)
        layoutSwitchAudio = findViewById(R.id.rl_switch_audio)
        layoutTimer = findViewById(R.id.rl_single_time)
        layoutFunction = findViewById(R.id.rl_single_function)

        refreshUserInfoView()
        refreshFunctionView()
        refreshSwitchAudioView()
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
        if (viewModel.mediaType.get() == TUICallDefine.MediaType.Video) {
            singleCallVideoLayout = SingleCallVideoLayout(context)
            layoutRender!!.removeAllViews()
            layoutRender!!.addView(singleCallVideoLayout)
        } else {
            layoutRender!!.removeAllViews()
            singleCallVideoLayout = null
        }
    }

    private fun refreshTimerView() {
        if (TUICallDefine.Status.Accept == viewModel.callStatus.get()) {
            layoutTimer?.removeAllViews()
            callTimerView = CallTimerView(context)
            layoutTimer?.addView(callTimerView)
        } else {
            layoutTimer?.removeAllViews()
            callTimerView = null
        }
    }

    private fun refreshSwitchAudioView() {
        if (viewModel.mediaType.get() == TUICallDefine.MediaType.Video) {
            switchAudioView = SwitchAudioView(context)
            layoutSwitchAudio!!.removeAllViews()
            layoutSwitchAudio!!.addView(switchAudioView)
        } else {
            layoutSwitchAudio!!.removeAllViews()
            switchAudioView = null
        }
    }

    private fun addObserver() {
        viewModel.callStatus.observe(callStatusObserver)
        viewModel.mediaType.observe(mediaTypeObserver)
    }

    private fun removeObserver() {
        viewModel.callStatus.removeObserver(callStatusObserver)
        viewModel.mediaType.removeObserver(mediaTypeObserver)
    }

    private fun refreshUserInfoView() {
        if (viewModel.mediaType.get() == TUICallDefine.MediaType.Audio) {
            layoutUserInfoAudio?.visibility = VISIBLE
            layoutUserInfoVideo?.visibility = GONE
            userInfoView = AudioCallUserInfoView(context)
            layoutUserInfoAudio!!.removeAllViews()
            if (null != userInfoView) {
                layoutUserInfoAudio!!.addView(userInfoView)
            }
        } else {
            layoutUserInfoAudio?.visibility = GONE
            layoutUserInfoVideo?.visibility = VISIBLE
            userInfoView = VideoCallUserInfoView(context)
            layoutUserInfoVideo!!.removeAllViews()
            if (null != userInfoView) {
                layoutUserInfoVideo!!.addView(userInfoView)
            }
        }
    }

    private fun refreshFunctionView() {
        if (TUICallDefine.Status.Waiting == viewModel.callStatus.get()) {

            if (viewModel.callRole.get() == TUICallDefine.Role.Caller) {
                if (viewModel.mediaType.get() == TUICallDefine.MediaType.Audio) {
                    functionView = AudioCallerWaitingAndAcceptedView(context)
                } else {
                    functionView = VideoCallerWaitingView(context)
                }
            } else {
                functionView = AudioAndVideoCalleeWaitingView(context)
            }
        } else if (TUICallDefine.Status.Accept == viewModel.callStatus.get()) {
            if (viewModel.mediaType.get() == TUICallDefine.MediaType.Audio) {
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
}