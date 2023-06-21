package com.tencent.qcloud.tuikit.tuicallkit.view.component

import android.annotation.SuppressLint
import android.content.Context
import android.view.ViewGroup
import android.widget.ImageView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.InviteUserButtonModel

@SuppressLint("AppCompatCustomView")
class InviteUserButton(context: Context) : ImageView(context) {
    private var viewModel = InviteUserButtonModel()

    init {
        initView()

        addObserver()
    }

    private fun addObserver() {
        viewModel.registerEvent()
    }

    fun clear() {
        removeObserver()
    }

    private fun removeObserver() {
        viewModel.unRegisterEvent()
    }

    private fun initView() {
        if (TUICallDefine.MediaType.Video == viewModel.mediaType.get()) {
            setBackgroundResource(R.drawable.tuicallkit_ic_add_user_white)
        } else {
            setBackgroundResource(R.drawable.tuicallkit_ic_add_user_black)
        }
        val lp = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        layoutParams = lp

        visibility = if (TUICallDefine.Role.Caller == viewModel.role?.get()) {
            VISIBLE
        } else {
            GONE
        }

        setOnClickListener{
            viewModel.inviteUser()
        }
    }
}