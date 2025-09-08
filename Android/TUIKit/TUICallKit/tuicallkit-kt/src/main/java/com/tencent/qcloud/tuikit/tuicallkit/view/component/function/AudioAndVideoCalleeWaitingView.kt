package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.LinearLayout
import androidx.constraintlayout.utils.widget.ImageFilterView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.trtc.tuikit.common.imageloader.ImageLoader

class AudioAndVideoCalleeWaitingView(context: Context) : ConstraintLayout(context) {
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
        val imageViewReject: ImageFilterView = findViewById(R.id.img_reject)

        layoutReject.setOnClickListener {
            imageViewReject.roundPercent = 1.0f
            imageViewReject.setBackgroundColor(ContextCompat.getColor(context, R.color.tuicallkit_button_bg_red))
            ImageLoader.loadGif(context, imageViewReject, R.drawable.tuicallkit_hangup_loading)
            layoutDialing.isEnabled = false
            layoutDialing.alpha = 0.8f
            CallManager.instance.reject(null)
        }
        layoutDialing.setOnClickListener {
            if (!layoutDialing.isEnabled) {
                return@setOnClickListener
            }
            CallManager.instance.accept(null)
        }
    }
}