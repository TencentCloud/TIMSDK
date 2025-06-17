package com.tencent.qcloud.tuikit.tuicallkit.view.component.hint

import android.content.Context
import android.view.Gravity
import android.view.View
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.Scene
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.trtc.tuikit.common.livedata.Observer

class CallHintView(context: Context) : AppCompatTextView(context) {
    private var isFirstShowAccept = true

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        updateStatusText()
    }

    private var networkQualityObserver = Observer<Constants.NetworkQualityHint> {
        when (it) {
            Constants.NetworkQualityHint.Local -> text = context.getString(R.string.tuicallkit_self_network_low_quality)
            Constants.NetworkQualityHint.Remote -> text =
                context.getString(R.string.tuicallkit_other_party_network_low_quality)
            else -> updateStatusText()
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initView()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun registerObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
        CallManager.instance.callState.networkQualityReminder.observe(networkQualityObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(callStatusObserver)
        CallManager.instance.callState.networkQualityReminder.removeObserver(networkQualityObserver)
    }

    private fun initView() {
        setTextColor(ContextCompat.getColor(context, R.color.tuicallkit_color_white))
        gravity = Gravity.CENTER

        text = if (Scene.GROUP_CALL == CallManager.instance.callState.scene.get()) {
            if (TUICallDefine.Role.Caller == CallManager.instance.userState.selfUser.get().callRole) {
                context.getString(R.string.tuicallkit_wait_response)
            } else {
                context.getString(R.string.tuicallkit_wait_accept_group)
            }
        } else {
            updateStatusText()
        }
    }

    private fun updateSingleCallWaitingText(): String {
        return if (TUICallDefine.Role.Caller == CallManager.instance.userState.selfUser.get().callRole) {
            context.getString(R.string.tuicallkit_waiting_accept)
        } else {
            if (TUICallDefine.MediaType.Video == CallManager.instance.callState.mediaType.get()) {
                context.getString(R.string.tuicallkit_invite_video_call)
            } else {
                context.getString(R.string.tuicallkit_invite_audio_call)
            }
        }
    }

    private fun updateStatusText(): String {
        val callStatus = CallManager.instance.userState.selfUser.get().callStatus.get()
        if (Scene.GROUP_CALL == CallManager.instance.callState.scene.get() && TUICallDefine.Status.Accept == callStatus) {
            visibility = View.GONE
            return ""
        }

        if (callStatus == TUICallDefine.Status.Waiting) {
            return updateSingleCallWaitingText()
        }

        text = ""
        val role = CallManager.instance.userState.selfUser.get().callRole
        if (callStatus == TUICallDefine.Status.Accept && role == TUICallDefine.Role.Caller && isFirstShowAccept) {
            text = context.getString(R.string.tuicallkit_accept_single)
            postDelayed({
                isFirstShowAccept = false
            }, 2000)
        }
        return text.toString()
    }
}