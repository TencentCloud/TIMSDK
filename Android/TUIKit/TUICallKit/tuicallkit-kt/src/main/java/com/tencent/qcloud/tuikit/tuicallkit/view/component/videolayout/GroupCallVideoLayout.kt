package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.View.OnTouchListener
import android.view.ViewGroup
import android.widget.RelativeLayout
import androidx.transition.TransitionManager
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout.GroupCallVideoLayoutViewModel

class GroupCallVideoLayout(context: Context) : GroupCallFlowLayout(context) {
    private var viewModel = GroupCallVideoLayoutViewModel()
    private var changedUserObserver = Observer<User> {
        updateView(it)
    }
    private var showLargeViewUserIdObserver = Observer<String> {
        var index = DEFAULT_INDEX
        for (i in 0 until viewModel.userList.get().size) {
            if (it == viewModel.userList.get()[i].id) {
                index = i
                break
            }
        }
        TransitionManager.beginDelayedTransition(this)
        setLargeViewIndex(index)
        val isExpand = showLargeViewIndex != index || showLargeViewIndex == DEFAULT_INDEX
        viewModel.updateBottomViewExpanded(isExpand)
    }

    init {
        initView()
        addObserver()
    }

    fun clear() {
        removeObserver()
        viewModel.removeObserver()
    }

    private fun addObserver() {
        viewModel.changedUser.observe(changedUserObserver)
        viewModel.showLargeViewUserId.observe(showLargeViewUserIdObserver)
    }

    private fun removeObserver() {
        viewModel.changedUser.removeObserver(changedUserObserver)
        viewModel.showLargeViewUserId.removeObserver(showLargeViewUserIdObserver)
    }

    private fun initView() {
        removeAllViews()

        for ((index, user) in viewModel.userList.get().withIndex()) {
            val videoView = VideoViewFactory.instance.createVideoView(user, context)
            if (videoView != null && videoView.parent != null) {
                if (videoView.parent.parent != null) {
                    (videoView.parent.parent as ViewGroup).removeAllViews()
                }
                (videoView.parent as RelativeLayout).removeView(videoView)
            }

            addView(videoView)
            initGestureListener(user)

            post {
                if (viewModel.showLargeViewUserId.get() == user.id) {
                    setLargeViewIndex(index)
                    viewModel.updateBottomViewExpanded(false)
                }
            }

            if (TUICallDefine.MediaType.Video == viewModel.mediaType.get()) {
                if (index == 0) {
                    if ((TUICallDefine.Role.Caller == user.callRole.get() && TUICallDefine.Status.Waiting == user.callStatus.get())
                        || (TUICallDefine.Role.Called == user.callRole.get() && TUICallDefine.Status.Accept == user.callStatus.get())
                    ) {
                        user.videoAvailable.set(true)
                        EngineManager.instance.openCamera(
                            viewModel.isFrontCamera.get(), videoView?.getVideoView(), null
                        )
                        viewModel.updateShowLargeViewUserId(user.id)
                    }
                } else {
                    EngineManager.instance.startRemoteView(user.id, videoView?.getVideoView(), null)
                }
            }
        }
    }

    private fun updateView(user: User) {
        if (user.callStatus.get() == TUICallDefine.Status.None) {
            var videoView = VideoViewFactory.instance.findVideoView(user.id)
            if (videoView != null && videoView.parent != null) {
                (videoView.parent as RelativeLayout).removeView(videoView)
                videoView.clear()
                videoView = null
            }
            post {
                if (viewModel.showLargeViewUserId.get() == user.id) {
                    TransitionManager.beginDelayedTransition(this)
                    viewModel.updateShowLargeViewUserId(null)
                    setLargeViewIndex(DEFAULT_INDEX)
                    viewModel.updateBottomViewExpanded(true)
                }
            }
            VideoViewFactory.instance.videoEntityList.remove(user.id)
        } else {
            val videoView = VideoViewFactory.instance.createVideoView(user, context)
            if (videoView != null && videoView.parent != null) {
                (videoView.parent as RelativeLayout).removeView(videoView)
            }
            addView(videoView)
            initGestureListener(user)
        }
    }

    private fun initGestureListener(user: User) {
        val videoView = VideoViewFactory.instance.findVideoView(user.id)
        videoView?.setOnClickListener() {
            post {
                val index: Int = viewModel.userList.get().indexOf(user)
                val showLargeViewUserId = if (index == showLargeViewIndex) null else user.id
                viewModel.updateShowLargeViewUserId(showLargeViewUserId)
            }
        }

        val detector = GestureDetector(context, object : GestureDetector.SimpleOnGestureListener() {
            override fun onSingleTapUp(e: MotionEvent): Boolean {
                videoView?.performClick()
                return false
            }

            override fun onDown(e: MotionEvent): Boolean {
                return true
            }

            override fun onScroll(e1: MotionEvent?, e2: MotionEvent, distanceX: Float, distanceY: Float): Boolean {
                return true
            }
        })
        videoView?.setOnTouchListener(OnTouchListener { v, event -> detector.onTouchEvent(event) })
    }
}