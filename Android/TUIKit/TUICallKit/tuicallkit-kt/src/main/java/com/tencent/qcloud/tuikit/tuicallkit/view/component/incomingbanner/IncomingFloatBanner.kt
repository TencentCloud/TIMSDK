package com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingbanner

import android.content.Context
import android.content.Context.WINDOW_SERVICE
import android.content.Intent
import android.content.res.Configuration
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.common.metrics.KeyMetrics
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.ViewState
import com.tencent.qcloud.tuikit.tuicallkit.view.CallMainActivity
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.livedata.Observer
import io.trtc.tuikit.atomicxcore.api.call.CallMediaType
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantInfo
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class IncomingFloatBanner(context: Context) : RelativeLayout(context) {
    private var appContext: Context = context.applicationContext
    private val scope = MainScope()
    private val windowManager: WindowManager = appContext.getSystemService(WINDOW_SERVICE) as WindowManager

    private lateinit var layoutView: View
    private lateinit var imageFloatAvatar: ImageView
    private lateinit var textFloatTitle: TextView
    private lateinit var textFloatDescription: TextView
    private lateinit var imageReject: ImageView
    private lateinit var imageAccept: ImageView
    private val padding = 40
    private var callStatus = CallParticipantStatus.None

    private lateinit var caller: CallParticipantInfo

    private val viewRouterObserver = Observer<ViewState.ViewRouter> {
        if (it == ViewState.ViewRouter.FullView || it == ViewState.ViewRouter.FloatView) {
            Logger.i(TAG, "viewRouterObserver, viewRouter: $it")
            cancelIncomingView()
        }
    }

    fun showIncomingView(user: CallParticipantInfo) {
        Logger.i(TAG, "showIncomingView")
        caller = user
        initView()
        registerObserver()
    }

    private fun cancelIncomingView() {
        Logger.i(TAG, "cancelIncomingView")
        if (layoutView.isAttachedToWindow) {
            windowManager.removeView(layoutView)
        }
        unregisterObserver()
    }

    private fun registerObserver() {
        scope.launch {
            CallStore.shared.observerState.selfInfo.collect { selfInfo ->
                if (callStatus == selfInfo.status) {
                    return@collect
                }
                callStatus = selfInfo.status
                if (selfInfo.status == CallParticipantStatus.None || selfInfo.status == CallParticipantStatus.Accept) {
                    cancelIncomingView()
                }
            }
        }
        CallManager.instance.viewState.router.observe(viewRouterObserver)
    }

    private fun unregisterObserver() {
        scope.cancel()
        CallManager.instance.viewState.router.removeObserver(viewRouterObserver)
    }

    private fun initView() {
        layoutView = LayoutInflater.from(context).inflate(R.layout.tuicallkit_incoming_float_view, this)
        imageFloatAvatar = layoutView.findViewById(R.id.img_float_avatar)
        textFloatTitle = layoutView.findViewById(R.id.tv_float_title)
        textFloatDescription = layoutView.findViewById(R.id.tv_float_desc)
        imageReject = layoutView.findViewById(R.id.btn_float_decline)
        imageAccept = layoutView.findViewById(R.id.btn_float_accept)

        ImageLoader.load(appContext, imageFloatAvatar, caller.avatarURL, R.drawable.tuicallkit_ic_avatar)
        textFloatTitle.text = caller.name

        val mediaType = CallStore.shared.observerState.activeCall.value.mediaType
        textFloatDescription.text = getTextDescription()

        imageReject.setOnClickListener {
            CallManager.instance.reject(null)
            cancelIncomingView()
        }

        layoutView.setOnClickListener {
            cancelIncomingView()
            val intent = Intent(context, CallMainActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
        }

        when (mediaType) {
            CallMediaType.Video -> imageAccept.setBackgroundResource(R.drawable.tuicallkit_ic_dialing_video)
            else -> imageAccept.setBackgroundResource(R.drawable.tuicallkit_bg_dialing)
        }
        val callStatus = CallStore.shared.observerState.selfInfo.value.status
        imageAccept.setOnClickListener {
            if (callStatus == CallParticipantStatus.None) {
                Logger.w(TAG, "current status is None, ignore")
                cancelIncomingView()
                return@setOnClickListener
            }

            Logger.i(TAG, "accept the call")
            CallStore.shared.accept(null)
            val intent = Intent(context, CallMainActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            intent.action = Constants.ACCEPT_CALL_ACTION
            context.startActivity(intent)
            cancelIncomingView()
        }

        CallManager.instance.viewState.router.set(ViewState.ViewRouter.Banner)
        windowManager.addView(layoutView, viewParams)
        val callId = CallStore.shared.observerState.activeCall.value.callId
        KeyMetrics.countUV(KeyMetrics.EventId.WAKEUP, callId)
    }

    private val viewParams: WindowManager.LayoutParams
        get() {
            val windowLayoutParams = WindowManager.LayoutParams()
            if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O) {
                windowLayoutParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                windowLayoutParams.type = WindowManager.LayoutParams.TYPE_PHONE
            }
            windowLayoutParams.flags = (WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                    or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                    or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
            windowLayoutParams.gravity = Gravity.START or Gravity.TOP
            windowLayoutParams.x = padding
            windowLayoutParams.y = 0
            windowLayoutParams.width = ScreenUtil.getScreenWidth(appContext) - padding * 2
            windowLayoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT
            windowLayoutParams.format = PixelFormat.TRANSPARENT
            return windowLayoutParams
        }

    private fun getTextDescription(): String {
        val activeCall = CallStore.shared.observerState.activeCall.value
        return when {
            activeCall.inviteeIds.size > 1 || activeCall.chatGroupId.isNotEmpty() ->
                appContext.getString(R.string.callkit_invite_multi_call)
            activeCall.mediaType == CallMediaType.Video ->
                appContext.getString(R.string.callkit_invite_video_call)
            else ->
                appContext.getString(R.string.callkit_invite_audio_call)
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration?) {
        super.onConfigurationChanged(newConfig)
        layoutView.let { windowManager?.updateViewLayout(layoutView, viewParams) }
    }

    companion object {
        private const val TAG = "IncomingViewFloat"
    }
}