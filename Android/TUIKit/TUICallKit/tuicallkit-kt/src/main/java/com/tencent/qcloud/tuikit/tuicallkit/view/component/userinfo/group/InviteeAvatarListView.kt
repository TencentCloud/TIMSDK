package com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.group

import android.content.Context
import android.widget.ImageView
import android.widget.LinearLayout
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

    init {
        initView()

        addObserver()
    }

    fun clear() {
        removeObserver()

        viewModel?.removeObserver()
    }

    private fun addObserver() {
        viewModel.inviteeUserList.observe(inviteeUserListObserver)
    }

    private fun removeObserver() {
        viewModel.inviteeUserList.removeObserver(inviteeUserListObserver)
    }

    private fun initView() {
        val squareWidth = context.resources.getDimensionPixelOffset(R.dimen.tuicalling_small_image_size)
        val leftMargin = context.resources.getDimensionPixelOffset(R.dimen.tuicalling_small_image_left_margin)
        for ((index, user) in viewModel?.inviteeUserList?.get()!!.withIndex()) {
            val imageView = ImageView(context)
            val layoutParams = LayoutParams(squareWidth, squareWidth)
            if (index != 0) {
                layoutParams.marginStart = leftMargin
            }
            imageView.layoutParams = layoutParams
            ImageLoader.loadImage(context, imageView, user!!.avatar.get(), R.drawable.tuicallkit_ic_avatar)
            addView(imageView)
        }
    }
}