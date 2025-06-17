package com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingbanner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager

class IncomingCallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent != null && intent.action == Constants.REJECT_CALL_ACTION) {
            CallManager.instance.reject(null)
        }
    }
}