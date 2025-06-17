package com.tencent.qcloud.tuikit.tuicallkit.view.component.joiningroupcall

import android.content.Context
import android.view.LayoutInflater
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.constraintlayout.utils.widget.ImageFilterView
import androidx.constraintlayout.widget.ConstraintLayout
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.MediaType
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.ValueCallback
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit
import com.tencent.qcloud.tuikit.tuicallkit.manager.UserManager
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.trtc.tuikit.common.imageloader.ImageLoader

class JoinCallView(context: Context) : FrameLayout(context) {
    private lateinit var layoutExpand: ConstraintLayout
    private lateinit var layoutUserListView: LinearLayout
    private lateinit var imageIconExpand: ImageView
    private lateinit var textUserHint: TextView
    private lateinit var btnJoinCall: Button

    private var context = context.applicationContext
    private var isViewExpand: Boolean = false

    init {
        initView()
    }

    private fun initView() {
        val view = LayoutInflater.from(context).inflate(R.layout.tuicallkit_join_call_view, this)
        textUserHint = view.findViewById(R.id.tv_user_hint)
        imageIconExpand = view.findViewById(R.id.img_ic_expand)
        btnJoinCall = view.findViewById(R.id.btn_join_call)
        layoutUserListView = view.findViewById(R.id.ll_layout_avatar)
        layoutExpand = view.findViewById(R.id.cl_expand_view)

        imageIconExpand.setBackgroundResource(R.drawable.tuicallkit_ic_join_expand)
        layoutExpand.visibility = LinearLayout.GONE
    }

    fun updateView(
        mediaType: MediaType, userList: List<String>?,
        callId: String = "", groupId: String? = "", roomId: TUICommonDefine.RoomId? = null,
    ) {
        btnJoinCall.text = context.resources.getString(R.string.tuicallkit_join_group_call)

        if (userList.isNullOrEmpty()) {
            return
        }
        updateUserAvatarView(userList)

        textUserHint.text = context.resources.getString(R.string.tuicallkit_join_group_call_users, userList.size)

        btnJoinCall.setOnClickListener {
            if (!callId.isNullOrEmpty()) {
                TUICallKit.createInstance(context).join(callId, null)
            } else {
                TUICallKit.createInstance(context).joinInGroupCall(roomId, groupId, mediaType)
            }
        }

        imageIconExpand.setOnClickListener {
            displayExpandView()
        }
    }

    private fun updateUserAvatarView(list: List<String>) {
        UserManager.instance.updateUserListInfo(list, object : ValueCallback<List<UserState.User>?> {
            override fun onSuccess(data: List<UserState.User>?) {
                data?.let { setAvatar(it) }
            }

            override fun onError(errCode: Int, errMsg: String?) {
                setAvatar(list)
            }
        })
    }

    private fun setAvatar(userList: List<Any>) {
        layoutUserListView.removeAllViews()
        val width = ScreenUtil.dip2px(50f)
        val startMargin = ScreenUtil.dip2px(12f)

        for ((index, user) in userList.withIndex()) {
            val imageView = ImageFilterView(context)
            val layoutParams = LinearLayout.LayoutParams(width, width)
            if (index != 0) {
                layoutParams.marginStart = startMargin
            }
            imageView.round = 12f
            imageView.scaleType = ImageView.ScaleType.CENTER_CROP
            imageView.layoutParams = layoutParams
            if (user is UserState.User) {
                ImageLoader.load(context, imageView, user.avatar.get(), R.drawable.tuicallkit_ic_avatar)
            } else {
                ImageLoader.load(context, imageView, R.drawable.tuicallkit_ic_avatar, R.drawable.tuicallkit_ic_avatar)
            }
            layoutUserListView.addView(imageView)
        }
    }

    private fun displayExpandView() {
        val resId = when {
            isViewExpand -> R.drawable.tuicallkit_ic_join_expand
            else -> R.drawable.tuicallkit_ic_join_compress
        }
        imageIconExpand.setBackgroundResource(resId)
        layoutExpand.visibility = if (isViewExpand) LinearLayout.GONE else LinearLayout.VISIBLE
        isViewExpand = !isViewExpand
    }
}