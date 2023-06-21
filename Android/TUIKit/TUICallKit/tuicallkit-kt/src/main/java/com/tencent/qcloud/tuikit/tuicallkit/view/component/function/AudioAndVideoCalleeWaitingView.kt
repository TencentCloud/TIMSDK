package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.LinearLayout
import android.widget.TextView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.function.AudioAndVideoCalleeWaitingViewModel

class AudioAndVideoCalleeWaitingView(context: Context) : BaseCallView(context) {
    private var layoutReject: LinearLayout? = null
    private var layoutDialing: LinearLayout? = null
    private var textReject: TextView? = null
    private var textDialing: TextView? = null
    private var viewModel = AudioAndVideoCalleeWaitingViewModel()
    private var mediaTypeObserver = Observer<TUICallDefine.MediaType> {
        updateTextColor(it)
    }

    init {
        initView()

        addObserver()
    }

    override fun clear() {
        removeObserver()
    }

    private fun addObserver() {
        viewModel.mediaType.observe(mediaTypeObserver)
    }

    private fun removeObserver() {
        viewModel.mediaType.removeObserver(mediaTypeObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_funcation_view_invited_waiting, this)
        layoutReject = findViewById(R.id.ll_decline)
        layoutDialing = findViewById(R.id.ll_answer)
        textReject = findViewById(R.id.tv_reject)
        textDialing = findViewById(R.id.tv_dialing)
        updateTextColor(viewModel.mediaType.get())

        initViewListener()
    }

    private fun initViewListener() {
        layoutReject!!.setOnClickListener { viewModel?.reject() }
        layoutDialing!!.setOnClickListener { viewModel?.accept() }
    }

    private fun updateTextColor(type: TUICallDefine.MediaType) {
        if (type == TUICallDefine.MediaType.Video) {
            textReject?.setTextColor(context.resources.getColor(R.color.tuicalling_color_white))
            textDialing?.setTextColor(context.resources.getColor(R.color.tuicalling_color_white))
        } else {
            textReject?.setTextColor(context.resources.getColor(R.color.tuicalling_color_black))
            textDialing?.setTextColor(context.resources.getColor(R.color.tuicalling_color_black))
        }
    }
}