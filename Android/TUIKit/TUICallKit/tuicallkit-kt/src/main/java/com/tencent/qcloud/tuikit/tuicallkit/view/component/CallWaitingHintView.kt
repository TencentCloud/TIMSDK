package com.tencent.qcloud.tuikit.tuicallkit.view.component

import android.content.Context
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.CallWaitingHintViewModel

class CallWaitingHintView(context: Context) : androidx.appcompat.widget.AppCompatTextView(context) {

    private var viewmodel = CallWaitingHintViewModel()

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        visibility = if (it == TUICallDefine.Status.Waiting) {
            VISIBLE
        } else {
            GONE
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
        if (TUICallDefine.MediaType.Video == viewmodel.mediaType.get()) {
            setTextColor(context.resources.getColor(R.color.tuicalling_color_white))
        } else {
            setTextColor(context.resources.getColor(R.color.tuicalling_color_black))
        }

        text =  if (TUICallDefine.Role.Caller == viewmodel.callRole.get()) {
            context.getString(R.string.tuicalling_waiting_accept)
        } else {
            if (TUICallDefine.MediaType.Audio == viewmodel.mediaType.get()) {
                context.getString(R.string.tuicalling_invite_audio_call)
            } else {
                context.getString(R.string.tuicalling_invite_video_call)
            }
        }
        visibility = if (viewmodel.callStatus.get() == TUICallDefine.Status.Waiting) {
            VISIBLE
        } else {
            GONE
        }
    }

    private fun addObserver() {
        viewmodel.callStatus.observe(callStatusObserver)
    }

    private fun removeObserver() {
        viewmodel.callStatus.removeObserver(callStatusObserver)
    }
}