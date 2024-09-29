package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.LinearLayout
import android.widget.TextView
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView

class AudioAndVideoCalleeWaitingView(context: Context) : BaseCallView(context) {
    private var layoutReject: LinearLayout? = null
    private var layoutDialing: LinearLayout? = null
    private var textReject: TextView? = null
    private var textDialing: TextView? = null

    init {
        initView()
    }

    override fun clear() {
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_invited_waiting, this)
        layoutReject = findViewById(R.id.ll_decline)
        layoutDialing = findViewById(R.id.ll_answer)
        textReject = findViewById(R.id.tv_reject)
        textDialing = findViewById(R.id.tv_dialing)

        initViewListener()
    }

    private fun initViewListener() {
        layoutReject!!.setOnClickListener { EngineManager.instance.reject(null) }
        layoutDialing!!.setOnClickListener { EngineManager.instance.accept(null) }
    }
}