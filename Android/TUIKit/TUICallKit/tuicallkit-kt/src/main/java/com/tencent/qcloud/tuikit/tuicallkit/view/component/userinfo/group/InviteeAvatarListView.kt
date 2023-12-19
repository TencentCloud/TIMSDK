package com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.group

import android.content.Context
import android.view.Gravity
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.constraintlayout.utils.widget.ImageFilterView
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.group.InviteeAvatarListViewModel
import java.util.concurrent.CopyOnWriteArrayList

class InviteeAvatarListView(context: Context) : LinearLayout(context) {

    private var viewModel = InviteeAvatarListViewModel()

    private var inviteeUserListObserver = Observer<CopyOnWriteArrayList<User>> {
        removeAllViews()
        initView()
    }

    private var avatarObserver = Observer<String> {
        removeAllViews()
        initView()
    }

    init {
        orientation = VERTICAL
        initView()

        addObserver()
    }

    fun clear() {
        removeObserver()

        viewModel?.removeObserver()
    }

    private fun addObserver() {
        viewModel.inviteeUserList.observe(inviteeUserListObserver)
        for (user in viewModel.inviteeUserList.get()) {
            user.avatar.observe(avatarObserver)
        }
    }

    private fun removeObserver() {
        viewModel.inviteeUserList.removeObserver(inviteeUserListObserver)
        for (user in viewModel.inviteeUserList.get()) {
            user.avatar.removeObserver(avatarObserver)
        }
    }

    private fun initView() {
        addView(createTextView())

        val layoutAvatar = LinearLayout(context)
        layoutAvatar.layoutParams =
            LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        addView(layoutAvatar)

        val squareWidth = context.resources.getDimensionPixelOffset(R.dimen.tuicallkit_small_image_size)
        val leftMargin = context.resources.getDimensionPixelOffset(R.dimen.tuicallkit_small_image_left_margin)
        for ((index, user) in viewModel?.inviteeUserList?.get()!!.withIndex()) {
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