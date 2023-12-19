package com.tencent.qcloud.tuikit.tuicallkit.view.component

import android.content.Context
import androidx.appcompat.widget.AppCompatTextView
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.CallTimerViewModel

class CallTimerView(context: Context) : AppCompatTextView(context) {

    private var viewmodel = CallTimerViewModel()

    private var timeCountObserver = Observer<Int> {
        this.post {
            if (viewmodel.callStatus.get() == TUICallDefine.Status.Accept) {
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

        if (viewmodel.callStatus.get() == TUICallDefine.Status.Accept) {
            text = DateTimeUtil.formatSecondsTo00(viewmodel.timeCount.get())
            visibility = VISIBLE
        } else {
            visibility = GONE
        }
    }

    private fun addObserver() {
        viewmodel.timeCount.observe(timeCountObserver)
    }

    private fun removeObserver() {
        viewmodel.timeCount.removeObserver(timeCountObserver)
    }
}