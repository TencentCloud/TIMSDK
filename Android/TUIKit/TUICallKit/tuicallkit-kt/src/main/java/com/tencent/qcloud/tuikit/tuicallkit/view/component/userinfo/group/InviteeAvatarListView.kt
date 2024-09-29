package com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.group

import android.content.Context
import android.view.Gravity
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.constraintlayout.utils.widget.ImageFilterView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import java.util.concurrent.CopyOnWriteArrayList

class InviteeAvatarListView(context: Context) : LinearLayout(context) {

    private var inviteeUserList = LiveData<CopyOnWriteArrayList<User>>()

    private var remoteUserListObserver = Observer<LinkedHashSet<User>> {
        if (it != null && it.size > 0) {
            for (user in it) {
                if (!inviteeUserList.get().contains(user) && TUICallDefine.Role.Called == user.callRole.get()) {
                    inviteeUserList.add(user)
                }
            }
            for ((index, user) in inviteeUserList.get().withIndex()) {
                if (index == 0) {
                    continue
                }
                if (!it.contains(user)) {
                    inviteeUserList.remove(user)
                }
            }
        }
        removeAllViews()
        initView()
    }


    private var avatarObserver = Observer<String> {
        removeAllViews()
        initView()
    }

    init {
        inviteeUserList.set(CopyOnWriteArrayList())
        inviteeUserList.get().add(TUICallState.instance.selfUser.get())
        for (user in TUICallState.instance.remoteUserList.get()) {
            if (TUICallDefine.Role.Called == user.callRole.get()) {
                inviteeUserList.get().add(user)
            }
        }

        orientation = VERTICAL
        initView()
        addObserver()
    }

    fun clear() {
        removeObserver()
    }

    private fun addObserver() {
        TUICallState.instance.remoteUserList.observe(remoteUserListObserver)
        for (user in inviteeUserList.get()) {
            user.avatar.observe(avatarObserver)
        }
    }

    private fun removeObserver() {
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
        for (user in inviteeUserList.get()) {
            user.avatar.removeObserver(avatarObserver)
        }
    }

    private fun initView() {
        if (inviteeUserList == null || inviteeUserList.get().isNullOrEmpty()) {
            return
        }
        addView(createTextView())

        val layoutAvatar = LinearLayout(context)
        layoutAvatar.layoutParams =
            LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        addView(layoutAvatar)

        val squareWidth = context.resources.getDimensionPixelOffset(R.dimen.tuicallkit_small_image_size)
        val leftMargin = context.resources.getDimensionPixelOffset(R.dimen.tuicallkit_small_image_left_margin)
        for ((index, user) in inviteeUserList?.get()!!.withIndex()) {
            val imageView = ImageFilterView(context)
            val layoutParams = LayoutParams(squareWidth, squareWidth)
            if (index != 0) {
                layoutParams.marginStart = leftMargin
            }
            imageView.round = 12f
            imageView.scaleType = ImageView.ScaleType.CENTER_CROP
            imageView.layoutParams = layoutParams
            ImageLoader.loadImage(context, imageView, user!!.avatar.get(), R.drawable.tuicallkit_ic_avatar)
            layoutAvatar.addView(imageView)
        }
    }

    private fun createTextView(): TextView {
        val textView = TextView(context)
        textView.text = context.getString(R.string.tuicallkit_invitee_user_list)
        textView.textSize = 12f
        textView.setTextColor(context.resources.getColor(R.color.tuicallkit_color_white))
        val param = LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        param.bottomMargin = 24
        param.gravity = Gravity.CENTER
        textView.layoutParams = param
        return textView
    }
}