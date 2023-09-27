package com.tencent.qcloud.tuikit.tuicallkit.extensions

import android.content.Context
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils

class CallingKeepAliveFeature(private val mContext: Context) {
    init {
        addObserver()
    }

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None) {
            stopKeepAlive()
        } else if (it == TUICallDefine.Status.Waiting) {
            startKeepAlive()
        }
    }

    fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
    }

    private fun startKeepAlive() {
        TUICallService.start(mContext)
    }

    private fun stopKeepAlive() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
        if (DeviceUtils.isServiceRunning(mContext, TUICallService::class.java.name)) {
            TUICallService.stop(mContext)
        }
    }
}