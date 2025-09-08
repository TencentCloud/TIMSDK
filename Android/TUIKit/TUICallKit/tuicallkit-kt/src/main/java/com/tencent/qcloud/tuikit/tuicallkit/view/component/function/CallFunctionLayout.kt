package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import androidx.constraintlayout.widget.ConstraintLayout
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.trtc.tuikit.common.livedata.Observer

class CallFunctionLayout(context: Context) : ConstraintLayout(context) {
    private var functionLayout: ConstraintLayout? = null
    private val callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.Accept) {
            updateLayout()
        }
    }
    private var sceneObserver = Observer<TUICallDefine.Scene> {
        if (it == TUICallDefine.Scene.GROUP_CALL) {
            if (functionLayout is VideoCallerAndCalleeAcceptedView) {
                return@Observer
            }
            updateLayout()
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        updateLayout()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun registerObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
        CallManager.instance.callState.scene.observe(sceneObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(callStatusObserver)
        CallManager.instance.callState.scene.removeObserver(sceneObserver)
    }

    private fun updateLayout() {
        val scene = CallManager.instance.callState.scene.get()
        if (scene == TUICallDefine.Scene.GROUP_CALL || scene == TUICallDefine.Scene.MULTI_CALL) {
            updateGroupCallLayout()
        } else {
            updateSingleCallLayout()
        }
    }

    private fun updateSingleCallLayout() {
        val mediaType = CallManager.instance.callState.mediaType.get()
        val role = CallManager.instance.userState.selfUser.get().callRole
        val callStatus = CallManager.instance.userState.selfUser.get().callStatus.get()

        when {
            callStatus == TUICallDefine.Status.Waiting && role == TUICallDefine.Role.Called -> {
                functionLayout = AudioAndVideoCalleeWaitingView(context)
            }
            callStatus == TUICallDefine.Status.Waiting && role == TUICallDefine.Role.Caller -> {
                functionLayout = when (mediaType) {
                    TUICallDefine.MediaType.Video -> VideoCallerWaitingView(context)
                    else -> AudioCallerWaitingAndAcceptedView(context)
                }
            }
            callStatus == TUICallDefine.Status.Accept -> {
                functionLayout = when (mediaType) {
                    TUICallDefine.MediaType.Video -> VideoCallerAndCalleeAcceptedView(context)
                    else -> AudioCallerWaitingAndAcceptedView(context)
                }
            }
        }

        removeAllViews()
        addView(functionLayout)
    }

    private fun updateGroupCallLayout() {
        val role = CallManager.instance.userState.selfUser.get().callRole
        val callStatus = CallManager.instance.userState.selfUser.get().callStatus.get()
        val functionLayout = if (callStatus == TUICallDefine.Status.Waiting && role == TUICallDefine.Role.Called) {
            AudioAndVideoCalleeWaitingView(context)
        } else {
            VideoCallerAndCalleeAcceptedView(context)
        }
        removeAllViews()
        addView(functionLayout)
    }
}