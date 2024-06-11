package com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingview

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager

class IncomingCallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent != null && intent.action == Constants.REJECT_CALL_ACTION) {
            EngineManager.instance.reject(null)
        }
    }
}