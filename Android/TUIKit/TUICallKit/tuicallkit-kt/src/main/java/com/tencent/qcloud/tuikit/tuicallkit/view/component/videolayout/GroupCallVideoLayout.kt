package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import android.widget.RelativeLayout
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallEngineManager
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout.GroupCallVideoLayoutViewModel

class GroupCallVideoLayout(context: Context) : BaseCallView(context) {

    private var viewModel = GroupCallVideoLayoutViewModel()

    private var changedUserObserver = Observer<User> {
        updateView(it)
    }

    init {
        initView()

        addObserver()
    }

    override fun clear() {
        removeObserver()

        if (viewModel != null) {
            viewModel.removeObserver()
        }
    }

    private fun addObserver() {
        viewModel.changedUser.observe(changedUserObserver)
    }

    private fun removeObserver() {
        viewModel.changedUser.removeObserver(changedUserObserver)
    }

    private fun initView() {
        val paramList = if (viewModel.userList.get().size == 2) {
            viewModel.initLayoutParamsForTwoUser(context)
        } else if (viewModel.userList.get().size == 3) {
            viewModel.initLayoutParamsForThreeUser(context)
        } else if (viewModel.userList.get().size == 4) {
            viewModel.initLayoutParamsForFourUser(context)
        } else {
            viewModel.initLayoutParamsMoreThanFourUser(context)
        }
        removeAllViews()
        for ((index, user) in viewModel.userList.get().withIndex()) {
            var videoView = VideoViewFactory.instance.createVideoView(user, context)
            if (videoView != null && videoView?.parent != null) {
                var parent : RelativeLayout = videoView?.parent as RelativeLayout
                parent.removeView(videoView)
            }
            videoView?.layoutParams = paramList[index]
            addView(videoView)
            if (TUICallDefine.MediaType.Video == viewModel.mediaType.get()) {
                if (index == 0 && !viewModel.isCameraOpen.get()) {
                    user.videoAvailable.set(true)
                    CallEngineManager.instance.openCamera(
                        viewModel.isFrontCamera.get(),
                        videoView?.getVideoView(),
                        null
                    )
                } else {
                    CallEngineManager.instance.startRemoteView(
                        user.id,
                        videoView?.getVideoView(),
                        null
                    )
                }
            }
        }
    }

    private fun updateView(user: User) {
        if (user.callStatus.get() == TUICallDefine.Status.None) {
            var videoView = VideoViewFactory.instance.findVideoView(user.id)
            if (videoView != null && videoView?.parent != null) {
                var parent : RelativeLayout = videoView?.parent as RelativeLayout
                parent.removeView(videoView)
                videoView.clear()
                videoView = null
            }
            VideoViewFactory.instance.videoEntityList.remove(user.id)
        } else {
            var videoView = VideoViewFactory.instance.createVideoView(user, context)
            if (videoView != null && videoView?.parent != null) {
                var parent : RelativeLayout = videoView?.parent as RelativeLayout
                parent.removeView(videoView)
            }
            addView(videoView)
            CallEngineManager.instance.startRemoteView(
                user.id,
                videoView?.getVideoView(),
                null
            )
        }
        val paramList = if (viewModel.userList.get().size == 2) {
            viewModel.initLayoutParamsForTwoUser(context)
        } else if (viewModel.userList.get().size == 3) {
            viewModel.initLayoutParamsForThreeUser(context)
        } else if (viewModel.userList.get().size == 4) {
            viewModel.initLayoutParamsForFourUser(context)
        } else {
            viewModel.initLayoutParamsMoreThanFourUser(context)
        }
        for ((index, user) in viewModel.userList.get().withIndex()) {
            var videoView = VideoViewFactory.instance.findVideoView(user.id)
            videoView?.layoutParams = paramList[index]
        }
    }
}