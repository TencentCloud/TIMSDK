package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import android.view.*
import android.widget.RelativeLayout
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout.SingleCallVideoLayoutViewModel

class SingleCallVideoLayout(context: Context) : BaseCallView(context) {

    private var layoutRenderBig: RelativeLayout? = null
    private var layoutRenderSmall: RelativeLayout? = null
    private var videoViewSmall: VideoView? = null
    private var videoViewBig: VideoView? = null
    private var viewModel: SingleCallVideoLayoutViewModel = SingleCallVideoLayoutViewModel()

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.Accept) {
            initSmallRenderView()
            videoViewSmall?.setImageAvatarVisibility(false)
            switchRenderLayout()
        }
    }

    init {
        initView()
        addObserver()
    }


    override fun clear() {
        removeObserver()
    }

    private fun addObserver() {
        viewModel.selfUser.callStatus.observe(callStatusObserver)
        viewModel.remoteUser.callStatus.observe(callStatusObserver)
    }

    private fun removeObserver() {
        viewModel.selfUser.callStatus.removeObserver(callStatusObserver)
        viewModel.remoteUser.callStatus.removeObserver(callStatusObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_render_view_single, this)
        layoutRenderBig = findViewById(R.id.rl_render_inviter)
        layoutRenderBig?.setOnClickListener() {
            viewModel.showFullScreen()
        }
        layoutRenderSmall = findViewById(R.id.rl_render_invitee)
        layoutRenderSmall?.setOnClickListener {
            switchRenderLayout()
        }
        initGestureListener(layoutRenderSmall)
        initBigRenderView()
        initSmallRenderView()
        if (viewModel.lastReverseRenderView) {
            switchRenderLayout()
        }
    }

    private fun switchRenderLayout() {
        if (viewModel.remoteUser.callStatus.get() == TUICallDefine.Status.Accept) {
            if (videoViewSmall != null && videoViewSmall?.parent != null) {
                var parent: RelativeLayout = videoViewSmall?.parent as RelativeLayout
                parent.removeAllViews()
                layoutRenderSmall?.removeAllViews()
            }
            if (videoViewBig != null && videoViewBig?.parent != null) {
                var parent: RelativeLayout = videoViewBig?.parent as RelativeLayout
                parent.removeAllViews()
                layoutRenderBig?.removeAllViews()
            }
            if (viewModel.currentReverseRenderView) {
                viewModel.reverseRenderLayout(false)
                layoutRenderSmall?.addView(videoViewSmall)
                layoutRenderBig?.addView(videoViewBig)
            } else {
                viewModel.reverseRenderLayout(true)
                layoutRenderSmall?.addView(videoViewBig)
                layoutRenderBig?.addView(videoViewSmall)
            }
        }
    }

    private fun initSmallRenderView() {
        if (viewModel.remoteUser.callStatus.get() == TUICallDefine.Status.Accept) {
            videoViewSmall = VideoViewFactory.instance.createVideoView(viewModel.remoteUser, context)
            if (videoViewSmall != null && videoViewSmall?.parent != null) {
                (videoViewSmall?.parent as ViewGroup).removeView(videoViewSmall)
                layoutRenderSmall?.removeAllViews()
            }
            layoutRenderSmall?.addView(videoViewSmall)
            EngineManager.instance.startRemoteView(
                viewModel.remoteUser.id,
                videoViewSmall?.getVideoView(),
                null
            )
        }
    }

    private fun initBigRenderView() {
        videoViewBig = VideoViewFactory.instance.createVideoView(viewModel.selfUser, context)
        if (videoViewBig != null && videoViewBig?.parent != null) {
            (videoViewBig?.parent as ViewGroup).removeView(videoViewBig)
            layoutRenderBig?.removeAllViews()
        }
        layoutRenderBig?.addView(videoViewBig)
        if (!viewModel.isCameraOpen.get() && TUICallDefine.Status.Accept != viewModel.selfUser.callStatus.get()) {
            viewModel.selfUser.videoAvailable.set(true)
            EngineManager.instance.openCamera(
                viewModel.isFrontCamera.get(),
                videoViewBig?.getVideoView(),
                null
            )
        }
    }

    private fun initGestureListener(view: RelativeLayout?) {
        val detector = GestureDetector(context, object : GestureDetector.SimpleOnGestureListener() {
            override fun onSingleTapUp(e: MotionEvent): Boolean {
                view!!.performClick()
                return false
            }

            override fun onDown(e: MotionEvent): Boolean {
                return true
            }

            override fun onScroll(e1: MotionEvent?, e2: MotionEvent, distanceX: Float, distanceY: Float): Boolean {
                val params = view?.layoutParams
                if (params is LayoutParams) {
                    val offsetX = if (isRTL) (e2.x - (e1?.x ?: 0f)) else ((e1?.x ?: 0f) - e2.x)

                    val layoutParams = view.layoutParams as LayoutParams
                    val newX = (layoutParams.marginEnd + offsetX).toInt()
                    val newY = (layoutParams.topMargin + (e2.y - (e1?.y ?: 0f))).toInt()
                    if (newX >= 0 && newX <= width - view.width && newY >= 0 && newY <= height - view.height) {
                        layoutParams.marginEnd = newX
                        layoutParams.topMargin = newY
                        view.layoutParams = layoutParams
                    }
                }
                return true
            }
        })
        view!!.setOnTouchListener { v, event -> detector.onTouchEvent(event) }
    }

    private val isRTL: Boolean
        private get() {
            val configuration = context.resources.configuration
            val layoutDirection = configuration.layoutDirection
            return layoutDirection == View.LAYOUT_DIRECTION_RTL
        }
}