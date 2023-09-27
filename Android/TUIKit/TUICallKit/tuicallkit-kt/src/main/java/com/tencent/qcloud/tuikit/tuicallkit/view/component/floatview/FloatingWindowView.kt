package com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallEngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallEvent
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.floatview.FloatingWindowViewModel

class FloatingWindowView(context: Context) : BaseCallView(context) {

    private var layoutVideoView: RelativeLayout? = null
    private var imageAudioIcon: ImageView? = null
    private var textCallStatus: TextView? = null
    private var imageAvatar: ImageView? = null
    private var videoView: VideoView? = null
    private var viewModel: FloatingWindowViewModel = FloatingWindowViewModel()
    private val observer: Observer<Any> = Observer {
        updateView(it)
    }

    private var callEventObserver = Observer<TUICallEvent> {
        if (it.eventType == TUICallEvent.EventType.TIP) {
            when (it.event) {
                (TUICallEvent.Event.USER_REJECT) -> {
                    var userId = it.param?.get(TUICallEvent.EVENT_KEY_USER_ID) as String
                    showUserToast(userId, R.string.tuicalling_toast_user_reject_call)
                }

                (TUICallEvent.Event.USER_LEAVE) -> {
                    var userId = it.param?.get(TUICallEvent.EVENT_KEY_USER_ID) as String
                    showUserToast(userId, R.string.tuicalling_toast_user_end)
                }

                (TUICallEvent.Event.USER_LINE_BUSY) -> {
                    var userId = it.param?.get(TUICallEvent.EVENT_KEY_USER_ID) as String
                    showUserToast(userId, R.string.tuicalling_toast_user_busy)
                }

                (TUICallEvent.Event.USER_NO_RESPONSE) -> {
                    var userId = it.param?.get(TUICallEvent.EVENT_KEY_USER_ID) as String
                    showUserToast(userId, R.string.tuicalling_toast_user_not_response)
                }

                (TUICallEvent.Event.USER_EXCEED_LIMIT) -> {
                    ToastUtil.toastLongMessage(context.getString(R.string.tuicalling_user_exceed_limit))
                }

                else -> {}
            }
        } else if (TUICallEvent.EventType.ERROR == it.eventType && TUICallEvent.Event.ERROR_COMMON == it.event) {
            var code = it.param?.get(TUICallEvent.EVENT_KEY_CODE) as Int
            var msg = it.param?.get(TUICallEvent.EVENT_KEY_MESSAGE) as String
        }
    }

    init {
        initView(context)

        addObserver()
    }

    override fun clear() {
        videoView?.clear()
        removeObserver()
    }

    private fun addObserver() {
        viewModel?.mediaType?.observe(observer)
        viewModel?.timeCount?.observe(observer)
        viewModel?.selfUser?.callStatus?.observe(observer)
        viewModel.remoteUser?.videoAvailable?.observe(observer)
        viewModel.event?.observe(callEventObserver)
    }

    private fun removeObserver() {
        viewModel?.mediaType?.removeObserver(observer)
        viewModel?.timeCount?.removeObserver(observer)
        viewModel?.selfUser?.callStatus?.removeObserver(observer)
        viewModel.remoteUser?.videoAvailable?.removeObserver(observer)
        viewModel.event?.removeObserver(callEventObserver)
    }

    private fun initView(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_float_call_view, this)
        layoutVideoView = findViewById(R.id.rl_video_view)
        imageAvatar = findViewById(R.id.iv_avatar)
        textCallStatus = findViewById(R.id.tv_call_status)
        imageAudioIcon = findViewById(R.id.iv_audio_view_icon)

        updateView(null)
    }

    private fun updateView(it: Any?) {
        if (it != null && it is Int) {
            textCallStatus?.post {
                textCallStatus?.text = DateTimeUtil.formatSecondsTo00(it)
            }
            return
        }
        if (viewModel.mediaType.get() == TUICallDefine.MediaType.Audio
            || viewModel.scene.get() == TUICallDefine.Scene.GROUP_CALL
        ) {
            imageAudioIcon?.visibility = VISIBLE
            textCallStatus?.visibility = VISIBLE
            layoutVideoView?.visibility = GONE
            imageAvatar?.visibility = GONE
            if (viewModel.selfUser?.callStatus?.get() == TUICallDefine.Status.Waiting) {
                textCallStatus?.text = context.getString(R.string.tuicalling_wait_resonse)
            } else if (viewModel.selfUser?.callStatus?.get() == TUICallDefine.Status.Accept) {
                textCallStatus?.text = DateTimeUtil.formatSecondsTo00(viewModel.timeCount.get())
            } else {
                VideoViewFactory.instance.clear()
                clear()
                viewModel.stopFloatService()
            }
        } else if (viewModel.mediaType.get() == TUICallDefine.MediaType.Video) {
            imageAudioIcon?.visibility = GONE
            textCallStatus?.visibility = GONE
            if (viewModel.selfUser?.callStatus?.get() == TUICallDefine.Status.Waiting) {
                layoutVideoView?.visibility = VISIBLE
                imageAvatar?.visibility = GONE
                videoView = VideoViewFactory.instance.createVideoView(viewModel.selfUser, context)
                if (videoView != null && videoView?.parent != null) {
                    var parent: RelativeLayout = videoView?.parent as RelativeLayout
                    parent.removeView(videoView)
                    layoutVideoView?.removeAllViews()
                }
                layoutVideoView?.addView(videoView)
            } else if (viewModel.selfUser?.callStatus?.get() == TUICallDefine.Status.Accept) {
                if (viewModel.remoteUser?.videoAvailable?.get() == true) {
                    layoutVideoView?.visibility = VISIBLE
                    imageAvatar?.visibility = GONE
                    videoView = VideoViewFactory.instance.createVideoView(viewModel.remoteUser, context)
                    if (videoView != null && videoView?.parent != null) {
                        var parent: RelativeLayout = videoView?.parent as RelativeLayout
                        parent.removeView(videoView)
                        layoutVideoView?.removeAllViews()
                    }
                    layoutVideoView?.addView(videoView)
                    CallEngineManager.instance.startRemoteView(
                        viewModel.remoteUser?.id,
                        videoView?.getVideoView(),
                        null
                    )
                } else {
                    layoutVideoView?.visibility = GONE
                    imageAvatar?.visibility = VISIBLE

                    ImageLoader.loadImage(
                        context,
                        imageAvatar,
                        viewModel.remoteUser?.avatar?.get(),
                        R.drawable.tuicallkit_ic_avatar
                    )
                }
            } else {
                VideoViewFactory.instance.clear()
                clear()
                viewModel.stopFloatService()
            }
        }
    }

    private fun showUserToast(userId: String, msgId: Int) {
        if (TextUtils.isEmpty(userId)) {
            return
        }
        var userName = userId
        if (userId == viewModel.selfUser?.id) {
            if (!TextUtils.isEmpty(TUICallState.instance.selfUser.get().nickname.get())) {
                userName = TUICallState.instance.selfUser.get().nickname.get()
            }
        } else {
            for (user in viewModel.remoteUserList) {
                if (null != user && !TextUtils.isEmpty(user.id) && userId == user.id) {
                    if (!TextUtils.isEmpty(user.nickname.get())) {
                        userName = user.nickname.get()
                    }
                }
            }
        }
        ToastUtil.toastLongMessage(ServiceInitializer.getAppContext().getString(msgId, userName))
    }

}