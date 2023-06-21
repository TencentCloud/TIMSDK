package com.tencent.qcloud.tuikit.tuicallkit.view.component

import android.content.Context
import androidx.appcompat.widget.AppCompatTextView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.CallTimerViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class CallTimerView(context: Context) : AppCompatTextView(context) {

    private var viewmodel = CallTimerViewModel()

    private var timeCountObserver = Observer<Int> {
        GlobalScope.launch(Dispatchers.Main) {
            if (viewmodel.callStatus.get() == TUICallDefine.Status.Accept) {
                if (it > 0) {
                    text = context.getString(R.string.tuicalling_called_time_format, it / 60, it % 60)
                    visibility = VISIBLE
                }
            } else {
                visibility = GONE
            }
        }
    }

    private var mediaTypeObserver = Observer<TUICallDefine.MediaType> {
        if (TUICallDefine.MediaType.Video == it) {
            setTextColor(context.resources.getColor(R.color.tuicalling_color_white))
        }else {
            setTextColor(context.resources.getColor(R.color.tuicalling_color_black))
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
        }else {
            setTextColor(context.resources.getColor(R.color.tuicalling_color_black))
        }
        if (viewmodel.callStatus.get() == TUICallDefine.Status.Accept) {
            text = context.getString(R.string.tuicalling_called_time_format,
                viewmodel.timeCount.get() / 60,
                viewmodel.timeCount.get() % 60
            )
            visibility = VISIBLE
        } else {
            visibility = GONE
        }
    }

    private fun addObserver() {
        viewmodel.timeCount.observe(timeCountObserver)
        viewmodel.mediaType.observe(mediaTypeObserver)
    }

    private fun removeObserver() {
        viewmodel.timeCount.removeObserver(timeCountObserver)
        viewmodel.mediaType.removeObserver(mediaTypeObserver)
    }
}