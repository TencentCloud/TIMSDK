package com.tencent.qcloud.tuikit.tuicallkit.beauty.tebeauty

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout

class TEBeautyView(context: Context) : FrameLayout(context) {

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        init()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unInit()
    }

    private fun init() {
        TEBeautyManager.setListener(beautyListener) 
        TEBeautyManager.init(context)
    }

    private fun unInit() {
        TEBeautyManager.setListener(null)
    }

    private val beautyListener = object : TEBeautyManager.OnBeautyViewListener {
        override fun onCreateBeautyView(view: View) {
            view.let {
                removeAllViews()
                (it.parent as? ViewGroup)?.removeView(view)
                addView(it)
            }
        }

        override fun onDestroyBeautyView() {
            removeAllViews()
        }
    }
}
