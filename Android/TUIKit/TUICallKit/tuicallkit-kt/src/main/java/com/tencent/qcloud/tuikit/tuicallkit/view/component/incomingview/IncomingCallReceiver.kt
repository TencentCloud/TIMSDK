package com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingview

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory

class IncomingCallReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "IncomingCallReceiver"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) {
            TUILog.w(TAG, "intent is invalid,ignore")
            return
        }

        TUILog.e(TAG, "onReceive: action: ${intent.action}")
        when (intent.action) {
            Constants.ACCEPT_CALL_ACTION -> {
                TUICore.notifyEvent(Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_START_ACTIVITY, HashMap())

                EngineManager.instance.accept(null)
                if (TUICallState.instance.mediaType.get() == TUICallDefine.MediaType.Video) {
                    val videoView = VideoViewFactory.instance.createVideoView(
                        TUICallState.instance.selfUser.get(), context
                    )

                    EngineManager.instance.openCamera(
                        TUICallState.instance.isFrontCamera.get(), videoView?.getVideoView(), null
                    )
                }
            }

            Constants.REJECT_CALL_ACTION -> {
                EngineManager.instance.reject(null)
            }

            else -> {
                TUILog.w(TAG, "intent.action is invalid,ignore")
            }
        }
    }
}