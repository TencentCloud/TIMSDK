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
        setTextColor(context.resources.getColor(R.color.tuicallkit_color_white))

        text = if (TUICallDefine.Role.Caller == viewmodel.callRole.get()) {
            context.getString(R.string.tuicallkit_wait_response)
        } else {
            context.getString(R.string.tuicallkit_wait_accept_group)
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