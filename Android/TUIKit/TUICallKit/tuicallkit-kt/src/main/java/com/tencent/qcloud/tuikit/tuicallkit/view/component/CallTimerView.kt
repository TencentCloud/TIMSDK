package com.tencent.qcloud.tuikit.tuicallkit.view.component

import android.content.Context
import androidx.appcompat.widget.AppCompatTextView
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class CallTimerView(context: Context) : AppCompatTextView(context) {

    private var timeCountObserver = Observer<Int> {
        this.post {
            if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.Accept) {
                if (it > 0) {
                    text = DateTimeUtil.formatSecondsTo00(it)
                    visibility = VISIBLE
                }
            } else {
                visibility = GONE
            }
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

        if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.Accept) {
            text = DateTimeUtil.formatSecondsTo00(TUICallState.instance.timeCount.get())
            visibility = VISIBLE
        } else {
            visibility = GONE
        }
    }

    private fun addObserver() {
        TUICallState.instance.timeCount.observe(timeCountObserver)
    }

    private fun removeObserver() {
        TUICallState.instance.timeCount.removeObserver(timeCountObserver)
    }
}