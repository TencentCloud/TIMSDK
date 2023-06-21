package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import android.text.TextUtils
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.data.User

class VideoViewFactory {
    public var videoEntityList = HashMap<String, UserVideoEntity?>()

    companion object {
        const val TAG = "VideoViewFactory"
        var instance: VideoViewFactory = VideoViewFactory()
    }

    fun createVideoView(user: User?, context: Context): VideoView? {
        if (null == user || TextUtils.isEmpty(user.id)) {
            TUILog.e(TAG, "createVideoView user:${user}" )
            return null
        }
        var videoView = findVideoView(user.id)
        if (null != videoView) {
            videoView.setUser(user)
            return videoView
        }
        videoView = VideoView(context)
        videoView.setUser(user)
        var entity = UserVideoEntity(user?.id, videoView, user)
        user?.id?.let { videoEntityList.put(user?.id!!, entity) }
        return videoEntityList[user?.id]?.videoView
    }

    fun clear() {
        if ( videoEntityList.isNotEmpty()) {
            for (userId in videoEntityList.keys) {
                var entity = videoEntityList.get(userId)
                entity?.videoView?.clear()
            }
            videoEntityList.clear()
        }
    }

    fun findVideoView(userId: String?): VideoView? {
        if (TextUtils.isEmpty(userId)) {
            return null
        }
        if (videoEntityList.contains(userId)) {
            return videoEntityList[userId]?.videoView
        }
        return null
    }

    fun findVideoUser(userId: String?): User? {
        if (TextUtils.isEmpty(userId)) {
            return null
        }
        if (videoEntityList.contains(userId)) {
            return videoEntityList[userId]?.user
        }
        return null
    }

    class UserVideoEntity(id: String?, view: VideoView, user: User) {
        var userId: String? = ""
        var videoView: VideoView? = null
        var user: User? = null

        init {
            this.userId = id
            this.videoView = view
            this.user = user
        }
    }

}