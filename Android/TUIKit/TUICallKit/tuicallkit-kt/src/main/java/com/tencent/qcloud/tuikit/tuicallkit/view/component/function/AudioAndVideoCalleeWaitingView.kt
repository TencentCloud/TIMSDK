package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.LinearLayout
import android.widget.RelativeLayout
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager

class AudioAndVideoCalleeWaitingView(context: Context) : RelativeLayout(context) {
    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        initView()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_invited_waiting, this)
        val layoutReject: LinearLayout = findViewById(R.id.ll_reject)
        val layoutDialing: LinearLayout = findViewById(R.id.ll_answer)

        layoutReject.setOnClickListener {
            CallManager.instance.reject(null)
        }
        layoutDialing.setOnClickListener {
            CallManager.instance.accept(null)
        }
    }
}