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
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.KeyMetrics
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.tencent.qcloud.tuikit.tuicallkit.state.ViewState
import com.tencent.qcloud.tuikit.tuicallkit.view.CallMainActivity
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.livedata.Observer

class IncomingFloatBanner(context: Context) : RelativeLayout(context) {
    private var appContext: Context = context.applicationContext
    private val windowManager: WindowManager = appContext.getSystemService(WINDOW_SERVICE) as WindowManager

    private lateinit var layoutView: View
    private lateinit var imageFloatAvatar: ImageView
    private lateinit var textFloatTitle: TextView
    private lateinit var textFloatDescription: TextView
    private lateinit var imageReject: ImageView
    private lateinit var imageAccept: ImageView
    private val padding = 40

    private lateinit var caller: UserState.User

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None || it == TUICallDefine.Status.Accept) {
            cancelIncomingView()
        }
    }

    private val viewRouterObserver = Observer<ViewState.ViewRouter> {
        if (it == ViewState.ViewRouter.FullView || it == ViewState.ViewRouter.FloatView) {
            Logger.i(TAG, "viewRouterObserver, viewRouter: $it")
            cancelIncomingView()
        }
    }

    fun showIncomingView(user: UserState.User) {
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
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
        CallManager.instance.viewState.router.observe(viewRouterObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(callStatusObserver)
        CallManager.instance.viewState.router.removeObserver(viewRouterObserver)
    }

    private fun initView() {
        layoutView = LayoutInflater.from(context).inflate(R.layout.tuicallkit_incoming_float_view, this)
        imageFloatAvatar = layoutView.findViewById(R.id.img_float_avatar)
        textFloatTitle = layoutView.findViewById(R.id.tv_float_title)
        textFloatDescription = layoutView.findViewById(R.id.tv_float_desc)
        imageReject = layoutView.findViewById(R.id.btn_float_decline)
        imageAccept = layoutView.findViewById(R.id.btn_float_accept)

        ImageLoader.load(appContext, imageFloatAvatar, caller.avatar?.get(), R.drawable.tuicallkit_ic_avatar)
        textFloatTitle.text = caller.nickname.get()

        val mediaType = CallManager.instance.callState.mediaType.get()
        textFloatDescription.text =
            if (mediaType == TUICallDefine.MediaType.Video) {
                appContext.resources.getString(R.string.tuicallkit_invite_video_call)
            } else {
                appContext.resources.getString(R.string.tuicallkit_invite_audio_call)
            }

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
            TUICallDefine.MediaType.Video -> imageAccept.setBackgroundResource(R.drawable.tuicallkit_ic_dialing_video)
            else -> imageAccept.setBackgroundResource(R.drawable.tuicallkit_bg_dialing)
        }
        imageAccept.setOnClickListener {
            if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                Logger.w(TAG, "current status is None, ignore")
                cancelIncomingView()
                return@setOnClickListener
            }

            Logger.i(TAG, "accept the call")
            val intent = Intent(context, CallMainActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            intent.action = Constants.ACCEPT_CALL_ACTION
            context.startActivity(intent)
            cancelIncomingView()
        }

        CallManager.instance.viewState.router.set(ViewState.ViewRouter.Banner)
        windowManager.addView(layoutView, viewParams)
        KeyMetrics.countUV(KeyMetrics.EventId.WAKEUP, CallManager.instance.callState.callId)
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

    override fun onConfigurationChanged(newConfig: Configuration?) {
        super.onConfigurationChanged(newConfig)
        layoutView.let { windowManager?.updateViewLayout(layoutView, viewParams) }
    }

    companion object {
        private const val TAG = "IncomingViewFloat"
    }
}