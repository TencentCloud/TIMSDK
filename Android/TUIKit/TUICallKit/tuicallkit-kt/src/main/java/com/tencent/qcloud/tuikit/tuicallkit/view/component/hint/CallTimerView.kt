package com.tencent.qcloud.tuikit.tuicallkit.view.component.hint

import android.content.Context
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.trtc.tuikit.common.livedata.Observer

class CallTimerView(context: Context) : AppCompatTextView(context) {
    private var callDurationObserver = Observer<Int> {
        this.post {
            if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.Accept) {
                text = DateTimeUtil.formatSecondsTo00(it)
                visibility = VISIBLE
            } else {
                visibility = GONE
            }
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
        CallManager.instance.callState.callDurationCount.observe(callDurationObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.callState.callDurationCount.removeObserver(callDurationObserver)
    }

    private fun initView() {
        setTextColor(ContextCompat.getColor(context, R.color.tuicallkit_color_white))

        if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.Accept) {
            text = DateTimeUtil.formatSecondsTo00(CallManager.instance.callState.callDurationCount.get())
            visibility = VISIBLE
        } else {
            visibility = GONE
        }
    }
}