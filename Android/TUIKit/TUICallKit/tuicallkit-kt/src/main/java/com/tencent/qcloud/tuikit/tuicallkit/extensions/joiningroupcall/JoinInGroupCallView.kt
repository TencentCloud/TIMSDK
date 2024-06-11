package com.tencent.qcloud.tuikit.tuicallkit.extensions.joiningroupcall

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.constraintlayout.utils.widget.ImageFilterView
import androidx.constraintlayout.widget.ConstraintLayout
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.TUICommonDefine.ValueCallback
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.MediaType
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.utils.UserInfoUtils

class JoinInGroupCallView(context: Context) : FrameLayout(context) {
    private var callView: View? = null
    private var layoutExpand: ConstraintLayout? = null
    private var layoutUserListView: LinearLayout? = null
    private var imageIconExpand: ImageView? = null
    private var textUserHint: TextView? = null
    private var btnJoinCall: Button? = null

    private var appContext: Context
    private var isViewExpand: Boolean = false

    init {
        appContext = context.applicationContext
        initView()
    }

    private fun initView() {
        callView = LayoutInflater.from(appContext).inflate(R.layout.tuicallkit_join_group_call_expand_view, this)

        textUserHint = callView?.findViewById(R.id.tv_user_hint)
        imageIconExpand = callView?.findViewById(R.id.img_ic_expand)
        btnJoinCall = callView?.findViewById(R.id.btn_join_call)
        layoutUserListView = callView?.findViewById(R.id.ll_layout_avatar)
        layoutExpand = callView?.findViewById(R.id.cl_expand_view)
    }

    fun updateView(groupId: String?, roomId: TUICommonDefine.RoomId, mediaType: MediaType, userList: List<String>?) {
        TUILog.i(TAG, "updateView groupId: $groupId, roomId: $roomId, mediaType: $mediaType, userList: $userList")

        btnJoinCall?.text = context.resources.getString(R.string.tuicallkit_join_group_call)

        if (userList.isNullOrEmpty()) {
            if (callView != null && callView?.parent != null) {
                (callView?.parent as ViewGroup).removeView(callView)
            }
            return
        }
        refreshUserAvatarView(userList)

        val hint = appContext.resources.getString(R.string.tuicallkit_join_group_call_users)
        val type = if (mediaType == MediaType.Video) {
            R.string.tuicallkit_video_call
        } else {
            R.string.tuicallkit_audio_call
        }
        textUserHint?.text = String.format(hint, userList.size, appContext.resources.getString(type))

        btnJoinCall?.setOnClickListener {
            TUICallKit.createInstance(appContext).joinInGroupCall(roomId, groupId, mediaType)
        }

        imageIconExpand?.setBackgroundResource(R.drawable.tuicallkit_ic_join_group_expand)
        layoutExpand?.visibility = LinearLayout.GONE
        imageIconExpand?.setOnClickListener {
            displayExpandView()
        }
    }

    private fun refreshUserAvatarView(list: List<String>) {
        UserInfoUtils.getUserListInfo(list, object : ValueCallback<List<User>?> {
            override fun onSuccess(data: List<User>?) {
                data?.let { setAvatar(it) }
            }

            override fun onError(errCode: Int, errMsg: String?) {
                setAvatar(list)
            }
        })
    }

    private fun setAvatar(userList: List<Any>) {
        layoutUserListView?.removeAllViews()

        val width = ScreenUtil.dip2px(50f)
        val startMargin = ScreenUtil.dip2px(12f)

        for ((index, user) in userList.withIndex()) {
            val imageView = ImageFilterView(appContext)
            val layoutParams = LinearLayout.LayoutParams(width, width)
            if (index != 0) {
                layoutParams.marginStart = startMargin
            }
            imageView.round = 12f
            imageView.scaleType = ImageView.ScaleType.CENTER_CROP
            imageView.layoutParams = layoutParams
            if (user is User) {
                ImageLoader.loadImage(appContext, imageView, user.avatar.get(), R.drawable.tuicallkit_ic_avatar)
            } else {
                ImageLoader.loadImage(appContext, imageView, R.drawable.tuicallkit_ic_avatar)
            }
            layoutUserListView?.addView(imageView)
        }
    }

    private fun displayExpandView() {
        if (isViewExpand) {
            layoutExpand?.visibility = LinearLayout.GONE
            imageIconExpand?.setBackgroundResource(R.drawable.tuicallkit_ic_join_group_expand)
            isViewExpand = false
        } else {
            layoutExpand?.visibility = LinearLayout.VISIBLE
            imageIconExpand?.setBackgroundResource(R.drawable.tuicallkit_ic_join_group_compress)
            isViewExpand = true
        }
    }

    companion object {
        private const val TAG = "JoinInGroupCall"
    }
}