package com.tencent.qcloud.tuikit.tuicallkit.extensions

import android.content.Context
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils

class CallingKeepAliveFeature(private val mContext: Context) {

    fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe {
            if (it == TUICallDefine.Status.None) {
                stopKeepAlive()
            } else if (it == TUICallDefine.Status.Waiting) {
                startKeepAlive()
            }
        }
    }

    private fun startKeepAlive() {
        TUICallService.start(mContext)
    }

    private fun stopKeepAlive() {
        if (DeviceUtils.isServiceRunning(mContext, TUICallService::class.java.getName())) {
            TUICallService.stop(mContext)
        }
    }
}