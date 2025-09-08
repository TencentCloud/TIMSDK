package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import android.content.res.Configuration
import android.view.GestureDetector
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.imageloader.ImageOptions
import com.trtc.tuikit.common.livedata.Observer

class SingleCallVideoLayout(context: Context) : ConstraintLayout(context) {
    private lateinit var layoutRenderBig: FrameLayout
    private lateinit var layoutRenderSmall: FrameLayout
    private lateinit var imageAvatar: ImageView
    private lateinit var textUserName: TextView
    private lateinit var imageBackground: ImageView
    private var videoViewSmall: VideoView? = null
    private var videoViewBig: VideoView? = null

    private var remoteUser: UserState.User = UserState.User()

    private var remoteUserAvatarObserver = Observer<String> {
        if (!it.isNullOrEmpty()) {
            ImageLoader.load(context.applicationContext, imageAvatar, it, R.drawable.tuicallkit_ic_avatar)
        }
    }
    private var remoteUserNicknameObserver = Observer<String> {
        if (!it.isNullOrEmpty()) {
            textUserName.text = it
        }
    }
    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (CallManager.instance.callState.mediaType.get() == TUICallDefine.MediaType.Audio) {
            return@Observer
        }
        if (it == TUICallDefine.Status.Accept) {
            updateUserInfoView(false)
            initSmallVideoView()
            switchRenderLayout()
        }
    }

    private var isVirtualBackgroundOpenedObserver = Observer<Boolean> {
        if (it == true && CallManager.instance.viewState.reverse1v1CallRenderView) {
            switchRenderLayout()
        }
    }

    init {
        val remoteUserList = CallManager.instance.userState.remoteUserList.get()
        if (remoteUserList != null && remoteUserList.size > 0) {
            remoteUser = remoteUserList.first()
        }
        initView()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
        layoutRenderBig.removeAllViews()
        layoutRenderSmall.removeAllViews()
    }

    private fun registerObserver() {
        remoteUser.avatar.observe(remoteUserAvatarObserver)
        remoteUser.nickname.observe(remoteUserNicknameObserver)
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
        CallManager.instance.viewState.isVirtualBackgroundOpened.observe(isVirtualBackgroundOpenedObserver)
    }

    private fun unregisterObserver() {
        remoteUser.avatar.removeObserver(remoteUserAvatarObserver)
        remoteUser.nickname.removeObserver(remoteUserNicknameObserver)
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(callStatusObserver)
        CallManager.instance.viewState.isVirtualBackgroundOpened.removeObserver(isVirtualBackgroundOpenedObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_video_layout_single, this)
        layoutRenderBig = findViewById(R.id.rl_video_big)
        layoutRenderBig.setOnClickListener {
            if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.Accept) {
                CallManager.instance.viewState.isScreenCleaned.set(!CallManager.instance.viewState.isScreenCleaned.get())
            }
        }
        layoutRenderSmall = findViewById(R.id.rl_video_small)
        layoutRenderSmall.setOnClickListener {
            switchRenderLayout()
        }
        imageAvatar = findViewById(R.id.iv_user_avatar)
        textUserName = findViewById(R.id.tv_user_name)
        imageBackground = findViewById(R.id.img_user_background)

        initVideoLayout()
        setBackground()
    }

    private fun initVideoLayout() {
        val mediaType = CallManager.instance.callState.mediaType.get()
        val callStatus = CallManager.instance.userState.selfUser.get().callStatus.get()

        if (mediaType == TUICallDefine.MediaType.Audio) {
            updateUserInfoView(true)
            layoutRenderBig.visibility = GONE
            layoutRenderSmall.visibility = GONE
        } else if (mediaType == TUICallDefine.MediaType.Video) {
            initBigVideoView()
            initGestureListener(layoutRenderSmall)
            layoutRenderBig.visibility = VISIBLE

            if (callStatus == TUICallDefine.Status.Accept) {
                updateUserInfoView(false)
                layoutRenderSmall.visibility = VISIBLE
                initSmallVideoView()
            } else {
                updateUserInfoView(true)
                layoutRenderSmall.visibility = GONE
            }
        }
    }

    private fun updateUserInfoView(show: Boolean) {
        val visibility = if (show) VISIBLE else GONE
        imageAvatar.visibility = visibility
        textUserName.visibility = visibility
        if (show) {
            ImageLoader.load(context, imageAvatar, remoteUser.avatar.get(), R.drawable.tuicallkit_ic_avatar)
            textUserName.text = remoteUser.nickname.get()
        }
    }

    private fun initBigVideoView() {
        videoViewBig = VideoFactory.instance.createVideoView(context, CallManager.instance.userState.selfUser.get())
        resetView(videoViewBig)
        layoutRenderBig.removeAllViews()
        layoutRenderBig.addView(videoViewBig)
        val isCameraOpen = CallManager.instance.mediaState.isCameraOpened.get()
        val isFrontCamera = CallManager.instance.mediaState.isFrontCamera.get()
        if (isCameraOpen) {
            CallManager.instance.openCamera(isFrontCamera, videoViewBig, null)
        }
    }

    private fun initSmallVideoView() {
        updateSmallViewSize()
        videoViewSmall = VideoFactory.instance.createVideoView(context, remoteUser)
        resetView(videoViewSmall)
        layoutRenderSmall.removeAllViews()
        layoutRenderSmall.addView(videoViewSmall)
        layoutRenderSmall.visibility = VISIBLE

        CallManager.instance.startRemoteView(remoteUser.id, videoViewSmall, null)
    }

    private fun switchRenderLayout() {
        if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.Accept) {
            resetView(videoViewBig)
            resetView(videoViewSmall)
            layoutRenderSmall.removeAllViews()
            layoutRenderBig.removeAllViews()

            updateSmallViewSize()
            val isViewReversed = CallManager.instance.viewState.reverse1v1CallRenderView
            if (isViewReversed) {
                layoutRenderSmall.addView(videoViewSmall)
                layoutRenderBig.addView(videoViewBig)
            } else {
                layoutRenderSmall.addView(videoViewBig)
                layoutRenderBig.addView(videoViewSmall)
            }
            CallManager.instance.reverse1v1CallRenderView(!isViewReversed)
        }
    }

    private fun setBackground() {
        if (CallManager.instance.callState.mediaType.get() == TUICallDefine.MediaType.Audio) {
            imageBackground.visibility = VISIBLE
            val option = ImageOptions.Builder().setPlaceImage(R.drawable.tuicallkit_ic_avatar)
                .setBlurEffect(80f).build()
            ImageLoader.load(context, imageBackground, remoteUser.avatar.get(), option)
            imageBackground.setColorFilter(ContextCompat.getColor(context, R.color.tuicallkit_color_blur_mask))
        }
    }

    private fun resetView(view: View?) {
        if (view?.parent != null) {
            (view.parent as ViewGroup).removeView(view)
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration?) {
        super.onConfigurationChanged(newConfig)
        layoutRenderSmall.requestLayout()
    }

    private fun updateSmallViewSize() {
        val isLandScape = when (GlobalState.instance.orientation) {
            Constants.Orientation.Portrait -> false
            Constants.Orientation.LandScape -> true
            else -> ScreenUtil.getRealScreenWidth(context) > ScreenUtil.getRealScreenHeight(context)
        }

        val wWidth =
            context.resources.getDimension(R.dimen.tuicallkit_video_small_view_width).toInt()
        val hHeight =
            context.resources.getDimension(R.dimen.tuicallkit_video_small_view_height).toInt()

        val lp = layoutRenderSmall.layoutParams
        lp?.width = if (isLandScape) hHeight else wWidth
        lp?.height = if (isLandScape) wWidth else hHeight
        layoutRenderSmall.layoutParams = lp
    }

    private fun initGestureListener(view: FrameLayout) {
        val detector = GestureDetector(context, object : GestureDetector.SimpleOnGestureListener() {
            override fun onSingleTapUp(e: MotionEvent): Boolean {
                view.performClick()
                return false
            }

            override fun onDown(e: MotionEvent): Boolean {
                return true
            }

            override fun onScroll(
                e1: MotionEvent?,
                e2: MotionEvent,
                distanceX: Float,
                distanceY: Float
            ): Boolean {
                val offsetX = if (isRTL) (e2.x - (e1?.x ?: 0f)) else ((e1?.x ?: 0f) - e2.x)
                val layoutParams = view.layoutParams as ConstraintLayout.LayoutParams
                val newX = (layoutParams.marginEnd + offsetX).toInt()
                val newY = (layoutParams.topMargin + (e2.y - (e1?.y ?: 0f))).toInt()
                if (newX >= 0 && newX <= width - view.width && newY >= 0 && newY <= height - view.height) {
                    layoutParams.marginEnd = newX
                    layoutParams.topMargin = newY
                    view.layoutParams = layoutParams
                }
                return true
            }
        })
        view.setOnTouchListener { v, event -> detector.onTouchEvent(event) }
    }

    private val isRTL: Boolean =
        context.resources.configuration.layoutDirection == View.LAYOUT_DIRECTION_RTL
}