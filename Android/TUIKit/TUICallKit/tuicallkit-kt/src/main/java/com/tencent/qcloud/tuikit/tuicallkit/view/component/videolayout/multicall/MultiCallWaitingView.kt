package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.multicall

import android.content.Context
import android.view.Gravity
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.constraintlayout.utils.widget.ImageFilterView
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.livedata.Observer
import com.trtc.tuikit.common.util.ScreenUtil

class MultiCallWaitingView(context: Context) : LinearLayout(context) {
    private var caller: UserState.User = UserState.User()
    private val squareWidth = context.resources.getDimensionPixelOffset(R.dimen.tuicallkit_small_image_size)
    private val defaultMargin = context.resources.getDimensionPixelOffset(R.dimen.tuicallkit_small_image_left_margin)

    private lateinit var textWaitingUserName: TextView
    private lateinit var imageCallerAvatar: ImageFilterView
    private lateinit var layoutAvatarList: LinearLayout

    private var remoteUserListObserver = Observer<LinkedHashSet<UserState.User>> {
        for (user in it) {
            if (TUICallDefine.Role.Called == user.callRole) {
                user.avatar.observe(avatarObserver)
            }
        }
        updateAvatarListView()
    }

    private var selfUserAvatarObserver = Observer<String> {
        if (!it.isNullOrEmpty()) {
            ImageLoader.load(context, imageCallerAvatar, caller.avatar.get(), R.drawable.tuicallkit_ic_avatar)
            textWaitingUserName.text = caller.nickname.get()
        }
    }

    private var avatarObserver = Observer<String> {
        if (!it.isNullOrEmpty()) {
            updateAvatarListView()
        }
    }

    init {
        this.orientation = VERTICAL
        this.gravity = Gravity.CENTER
        caller = CallManager.instance.userState.remoteUserList.get()
            .find { user -> user.callRole == TUICallDefine.Role.Caller } ?: UserState.User()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initView()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun registerObserver() {
        CallManager.instance.userState.remoteUserList.observe(remoteUserListObserver)
        if (!caller.id.isNullOrEmpty()) {
            caller.avatar.observe(selfUserAvatarObserver)
        }
        for (user in CallManager.instance.userState.remoteUserList.get()) {
            user.avatar.observe(avatarObserver)
        }
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.remoteUserList.removeObserver(remoteUserListObserver)
        caller.avatar.removeObserver(selfUserAvatarObserver)
        for (user in CallManager.instance.userState.remoteUserList.get()) {
            user.avatar.removeObserver(avatarObserver)
        }
    }

    private fun initView() {
        imageCallerAvatar = createImageView(caller, ScreenUtil.dip2px(100f), 0, 20)
        textWaitingUserName = createTextView(caller.nickname.get(), 48)
        textWaitingUserName.textSize = 18f
        layoutAvatarList = LinearLayout(context)
        layoutAvatarList.layoutParams =
            LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)

        addView(imageCallerAvatar)
        addView(textWaitingUserName)
        addView(createTextView(context.getString(R.string.tuicallkit_invitee_user_list), 24))
        addView(layoutAvatarList)
    }

    private fun updateAvatarListView() {
        layoutAvatarList.removeAllViews()
        val list = HashSet<UserState.User>()
        list.add(CallManager.instance.userState.selfUser.get())
        list.addAll(CallManager.instance.userState.remoteUserList.get() - caller)

        for (user in list) {
            layoutAvatarList.addView(createImageView(user, squareWidth, defaultMargin, 0))
        }
    }

    private fun createImageView(user: UserState.User, width: Int, start: Int, bottom: Int): ImageFilterView {
        val imageView = ImageFilterView(context)
        val layoutParams = LayoutParams(width, width)
        layoutParams.marginStart = start
        layoutParams.bottomMargin = bottom
        imageView.round = 12f
        imageView.scaleType = ImageView.ScaleType.CENTER_CROP
        imageView.layoutParams = layoutParams
        ImageLoader.load(context, imageView, user.avatar.get(), R.drawable.tuicallkit_ic_avatar)
        return imageView
    }

    private fun createTextView(text: String, margin: Int): TextView {
        val textView = TextView(context)
        textView.text = text
        textView.textSize = 12f
        textView.setTextColor(ContextCompat.getColor(context, R.color.tuicallkit_color_white))
        val param = LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        param.bottomMargin = margin
        param.gravity = Gravity.CENTER
        textView.layoutParams = param
        return textView
    }
}