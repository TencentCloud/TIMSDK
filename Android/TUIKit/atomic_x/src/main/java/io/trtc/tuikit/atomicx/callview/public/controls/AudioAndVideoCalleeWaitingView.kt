package io.trtc.tuikit.atomicx.callview.public.controls

import android.content.Context
import android.view.LayoutInflater
import android.widget.LinearLayout
import android.widget.RelativeLayout
import androidx.constraintlayout.utils.widget.ImageFilterView
import androidx.core.content.ContextCompat
import com.trtc.tuikit.common.imageloader.ImageLoader
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicxcore.api.call.CallStore

class AudioAndVideoCalleeWaitingView(context: Context) : RelativeLayout(context) {
    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        initView()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.callview_function_view_invited_waiting, this)
        val layoutReject: LinearLayout = findViewById(R.id.ll_reject)
        val layoutDialing: LinearLayout = findViewById(R.id.ll_answer)
        val imageViewReject: ImageFilterView = findViewById(R.id.img_reject)
        layoutDialing.isEnabled = true

        layoutReject.setOnClickListener {
            imageViewReject.roundPercent = 1.0f
            imageViewReject.setBackgroundColor(ContextCompat.getColor(context, R.color.callview_button_bg_red))
            ImageLoader.loadGif(context, imageViewReject, R.drawable.callview_hangup_loading)
            layoutDialing.isEnabled = false
            layoutDialing.alpha = 0.8f
            CallStore.shared.reject(null)
        }
        layoutDialing.setOnClickListener {
            if (!layoutDialing.isEnabled) {
                return@setOnClickListener
            }
            CallStore.shared.accept(null)
        }
    }
}