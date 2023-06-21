package com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview

import android.annotation.SuppressLint
import android.content.Context
import android.view.ViewGroup
import android.widget.ImageView
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallengine.utils.PermissionUtils
import com.tencent.qcloud.tuikit.tuicallkit.view.CallKitActivity
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow.FloatingWindowView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.floatview.FloatingWindowButtonModel

@SuppressLint("AppCompatCustomView")
class FloatingWindowButton(context: Context) : ImageView(context) {
    private var viewModel = FloatingWindowButtonModel()

    private var mediaTypeObserver = Observer<TUICallDefine.MediaType> {
        if (TUICallDefine.MediaType.Video == it) {
            setBackgroundResource(R.drawable.tuicallkit_ic_move_back_white)
        } else {
            setBackgroundResource(R.drawable.tuicallkit_ic_move_back_black)
        }
    }

    init {
        initView()

        addObserver()
    }

    fun clear() {
        removeObserver()
    }

    private fun initView() {
        if (TUICallDefine.MediaType.Video == viewModel.mediaType.get()) {
            setBackgroundResource(R.drawable.tuicallkit_ic_move_back_white)
        } else {
            setBackgroundResource(R.drawable.tuicallkit_ic_move_back_black)
        }
        val lp = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        layoutParams = lp

        setOnClickListener {
            if (PermissionUtils.hasPermission(ServiceInitializer.getAppContext())) {
                viewModel.startFloatService(FloatingWindowView(context.applicationContext))
                CallKitActivity.finishActivity()
            } else {
                PermissionRequest.requestFloatPermission(ServiceInitializer.getAppContext())
            }
        }

        if (viewModel.enableFloatWindow) {
            visibility = VISIBLE
        } else {
            visibility = GONE
        }
    }

    private fun addObserver() {
        viewModel.mediaType.observe(mediaTypeObserver)
    }

    private fun removeObserver() {
        viewModel.mediaType.removeObserver(mediaTypeObserver)
    }
}