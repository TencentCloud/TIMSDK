package com.tencent.qcloud.tuikit.tuicallkit.view.component

import android.content.Context
import android.view.Gravity
import android.view.View
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class CallWaitingHintView(context: Context) : androidx.appcompat.widget.AppCompatTextView(context) {

    private var isFirstShowAccept = true

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        updateStatusText()
    }

    private var networkQualityObserver = Observer<Constants.NetworkQualityHint> {
        when (it) {
            Constants.NetworkQualityHint.Local ->
                text = TUIConfig.getAppContext().getString(R.string.tuicallkit_self_network_low_quality)

            Constants.NetworkQualityHint.Remote ->
                text = TUIConfig.getAppContext().getString(R.string.tuicallkit_other_party_network_low_quality)

            else -> updateStatusText()
        }
    }

    init {
        initView()
        addObserver()
    }

    fun clear() {
        removeObserver()
    }

    private fun initView() {
        setTextColor(context.resources.getColor(R.color.tuicallkit_color_white))
        gravity = Gravity.CENTER

        text = if (TUICallDefine.Scene.GROUP_CALL == TUICallState.instance.scene.get()) {
            if (TUICallDefine.Role.Caller == TUICallState.instance.selfUser.get().callRole.get()) {
                context.getString(R.string.tuicallkit_wait_response)
            } else {
                context.getString(R.string.tuicallkit_wait_accept_group)
            }
        } else {
            updateStatusText()
        }
    }

    private fun updateSingleCallWaitingText(): String {
        return if (TUICallDefine.Role.Caller == TUICallState.instance.selfUser.get().callRole.get()) {
            context.getString(R.string.tuicallkit_waiting_accept)
        } else {
            if (TUICallDefine.MediaType.Video == TUICallState.instance.mediaType.get()) {
                context.getString(R.string.tuicallkit_invite_video_call)
            } else {
                context.getString(R.string.tuicallkit_invite_audio_call)
            }
        }
    }

    private fun updateStatusText(): String {
        if (TUICallDefine.Scene.GROUP_CALL == TUICallState.instance.scene.get()
            && TUICallDefine.Status.Accept == TUICallState.instance.selfUser.get().callStatus.get()
        ) {
            visibility = View.GONE
            return ""
        }
        if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.Waiting) {
            text = updateSingleCallWaitingText()
        } else if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.Accept) {
            if (TUICallState.instance.selfUser.get().callRole.get() == TUICallDefine.Role.Caller && isFirstShowAccept) {
                text = context.getString(R.string.tuicallkit_accept_single)
                postDelayed({
                    isFirstShowAccept = false
                }, 2000)
            } else {
                text = ""
            }
        } else {
            text = ""
        }

        return text.toString()
    }

    private fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
        TUICallState.instance.networkQualityReminder.observe(networkQualityObserver)
    }

    private fun removeObserver() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.networkQualityReminder.removeObserver(networkQualityObserver)
    }
}