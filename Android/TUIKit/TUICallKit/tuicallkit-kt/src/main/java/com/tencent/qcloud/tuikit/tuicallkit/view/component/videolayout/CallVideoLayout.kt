package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import androidx.constraintlayout.widget.ConstraintLayout
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager

class CallVideoLayout(context: Context) : ConstraintLayout(context) {
    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initView()
    }

    private fun initView() {
        layoutParams.width = LayoutParams.MATCH_PARENT
        layoutParams.height = LayoutParams.MATCH_PARENT

        if (CallManager.instance.callState.scene.get() == TUICallDefine.Scene.GROUP_CALL) {
            addView(MultiCallVideoLayout(context), layoutParams)
        } else {
            addView(SingleCallVideoLayout(context), layoutParams)
        }
    }
}