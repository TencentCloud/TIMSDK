package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import android.view.GestureDetector
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.View.OnTouchListener
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.transition.TransitionManager
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.Status
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.multicall.MultiCallGridLayout
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.multicall.MultiCallGridLayout.Companion.DEFAULT_INDEX
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.multicall.MultiCallWaitingView
import com.trtc.tuikit.common.livedata.Observer
import java.util.concurrent.CopyOnWriteArraySet

class MultiCallVideoLayout(context: Context) : ConstraintLayout(context) {
    private lateinit var layoutCalleeWaitingView: LinearLayout
    private lateinit var layoutVideoGrid: MultiCallGridLayout

    private var userList: CopyOnWriteArraySet<UserState.User> = CopyOnWriteArraySet()

    private val callStatusObserver = Observer<Status> {
        if (it == Status.Accept) {
            if (CallManager.instance.userState.selfUser.get().callRole == TUICallDefine.Role.Called) {
                updateVideoGrid(userList)
            }
            updateWaitingView()
        }
    }

    private var remoteUserListObserver = Observer<LinkedHashSet<UserState.User>> {
        if (it == null || it.size <= 0) {
            return@Observer
        }
        val newUsers = it - userList
        if (!newUsers.isNullOrEmpty()) {
            userList.addAll(newUsers)
            updateVideoGrid(newUsers)
            return@Observer
        }

        val removedUsers = userList - it - CallManager.instance.userState.selfUser.get()
        if (!removedUsers.isNullOrEmpty()) {
            userList.removeAll(removedUsers)
            updateVideoGrid(removedUsers)
        }
    }

    private var showLargeViewUserIdObserver = Observer<String> {
        var index = DEFAULT_INDEX
        for ((i, user) in userList.withIndex()) {
            if (it == user.id) {
                index = i
                break
            }
        }
        TransitionManager.beginDelayedTransition(layoutVideoGrid)
        setLargeViewIndex(index)
    }

    init {
        userList.add(CallManager.instance.userState.selfUser.get())
        userList.addAll(CallManager.instance.userState.remoteUserList.get())
        initView()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
        layoutVideoGrid.removeAllViews()
        userList.clear()
    }

    private fun registerObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
        CallManager.instance.userState.remoteUserList.observe(remoteUserListObserver)
        CallManager.instance.viewState.showLargeViewUserId.observe(showLargeViewUserIdObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(callStatusObserver)
        CallManager.instance.userState.remoteUserList.removeObserver(remoteUserListObserver)
        CallManager.instance.viewState.showLargeViewUserId.removeObserver(
            showLargeViewUserIdObserver
        )
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_video_layout_group, this)
        layoutCalleeWaitingView = findViewById(R.id.ll_callee_waiting_view)
        layoutVideoGrid = findViewById(R.id.grid_layout)

        updateVideoGrid(userList)
        updateWaitingView()
    }

    private fun updateVideoGrid(userList: Set<UserState.User>) {
        for ((index, user) in userList.withIndex()) {
            if (CallManager.instance.viewState.showLargeViewUserId.get() == user.id) {
                setLargeViewIndex(index)
            }
            setRender(user)
        }
    }

    private fun setRender(user: UserState.User) {
        if (user.callStatus.get() == Status.None) {
            val videoView = VideoFactory.instance.findVideoView(user.id)
            videoView?.setOnClickListener(null)
            VideoFactory.instance.removeVideoView(user)
            resetView(videoView)
            layoutVideoGrid.removeView(videoView)
            if (CallManager.instance.viewState.showLargeViewUserId.get() == user.id) {
                TransitionManager.beginDelayedTransition(this)
                updateShowLargeViewUserId("")
                setLargeViewIndex(DEFAULT_INDEX)
            }
            return
        }

        val videoView = VideoFactory.instance.createVideoView(context, user)
        resetView(videoView)
        layoutVideoGrid.addView(videoView)
        initGestureListener(user)

        if (user.id == CallManager.instance.userState.selfUser.get().id) {
            val isCameraOpen = CallManager.instance.mediaState.isCameraOpened.get()
            val isFrontCamera = CallManager.instance.mediaState.isFrontCamera.get()
            if (isCameraOpen) {
                CallManager.instance.openCamera(isFrontCamera, videoView, null)
                updateShowLargeViewUserId(user.id)
            }
        } else {
            CallManager.instance.startRemoteView(user.id, videoView, null)
        }
    }

    private fun updateWaitingView() {
        val selfUser = CallManager.instance.userState.selfUser.get()
        if (Status.Waiting == selfUser.callStatus.get() && TUICallDefine.Role.Called == selfUser.callRole) {
            layoutCalleeWaitingView.addView(MultiCallWaitingView(context))
            layoutCalleeWaitingView.visibility = VISIBLE
            layoutVideoGrid.visibility = GONE
        } else {
            layoutCalleeWaitingView.visibility = GONE
            layoutVideoGrid.visibility = VISIBLE
        }
    }

    private fun initGestureListener(user: UserState.User) {
        val videoView = VideoFactory.instance.findVideoView(user.id)
        videoView?.setOnClickListener() {
            post {
                val index: Int = userList.indexOf(user)
                val showLargeViewUserId =
                    if (index != layoutVideoGrid.showLargeViewIndex) user.id else ""
                updateShowLargeViewUserId(showLargeViewUserId)
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

            override fun onScroll(
                e1: MotionEvent?,
                e2: MotionEvent,
                distanceX: Float,
                distanceY: Float
            ): Boolean {
                return true
            }
        })
        videoView?.setOnTouchListener(OnTouchListener { v, event -> detector.onTouchEvent(event) })
    }

    private fun resetView(view: View?) {
        if (view?.parent != null) {
            (view.parent as ViewGroup).removeView(view)
        }
    }

    private fun setLargeViewIndex(index: Int) {
        layoutVideoGrid.showLargeViewIndex = when {
            index == layoutVideoGrid.showLargeViewIndex -> DEFAULT_INDEX
            else -> index
        }
        layoutVideoGrid.requestLayout()
    }

    private fun updateShowLargeViewUserId(userId: String?) {
        CallManager.instance.setGroupLargeViewUserId(userId)
    }
}