package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import androidx.constraintlayout.widget.ConstraintLayout
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager

class CallVideoLayout(context: Context) : ConstraintLayout(context) {
    init {
        initView()
    }

    private fun initView() {
        this.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)

        val scene = CallManager.instance.callState.scene.get()
        if (scene == TUICallDefine.Scene.GROUP_CALL || scene == TUICallDefine.Scene.MULTI_CALL) {
            addView(MultiCallVideoLayout(context), layoutParams)
        } else {
            addView(SingleCallVideoLayout(context), layoutParams)
        }
    }
}