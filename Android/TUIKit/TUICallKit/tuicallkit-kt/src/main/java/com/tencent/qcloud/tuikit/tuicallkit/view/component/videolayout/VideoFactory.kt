package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import java.util.concurrent.ConcurrentHashMap

class VideoFactory {
    private var videoEntityList: ConcurrentHashMap<String, UserVideoEntity> = ConcurrentHashMap()

    fun createVideoView(context: Context, user: UserState.User?): VideoView? {
        if (null == user || user.id.isEmpty()) {
            Logger.e(TAG, "createVideoView failed, user is invalid: $user")
            return null
        }
        var videoView = findVideoView(user.id)
        if (null != videoView) {
            return videoView
        }
        videoView = VideoView(context.applicationContext, user)
        val entity = UserVideoEntity(user.id, videoView, user)
        videoEntityList[user.id] = entity
        return videoEntityList[user.id]?.videoView
    }

    fun findVideoView(userId: String): VideoView? {
        if (videoEntityList.containsKey(userId)) {
            return videoEntityList[userId]?.videoView
        }
        return null
    }

    fun removeVideoView(user: UserState.User) {
        videoEntityList[user.id]?.videoView?.removeAllViews()
        videoEntityList.remove(user.id)
    }

    fun clearVideoView() {
        if (videoEntityList.isEmpty()) {
            return
        }
        videoEntityList.forEach {
            it.value.videoView.removeAllViews()
        }
        videoEntityList.clear()
    }

    class UserVideoEntity(id: String, view: VideoView, user: UserState.User) {
        var userId: String = id
        var videoView: VideoView = view
        var user: UserState.User = user
    }

    companion object {
        private const val TAG = "VideoFactory"
        val instance: VideoFactory = VideoFactory()
    }
}