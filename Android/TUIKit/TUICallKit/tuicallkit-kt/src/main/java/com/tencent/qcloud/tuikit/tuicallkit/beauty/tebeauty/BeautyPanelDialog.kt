package com.tencent.qcloud.tuikit.tuicallkit.beauty.tebeauty

import android.content.Context
import android.os.Bundle
import android.view.View
import io.trtc.tuikit.atomicx.widget.basicwidget.popover.AtomicPopover

class BeautyPanelDialog(
    private val context: Context
) : AtomicPopover(context) {

    init {
        setShowMask(false)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val beautyView: View = TEBeautyView(context)
        setContent(beautyView)
    }
}