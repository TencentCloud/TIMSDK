package com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview

import android.annotation.SuppressLint
import android.content.Context
import android.view.ViewGroup
import android.widget.ImageView
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.view.CallKitActivity
import com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow.FloatingWindowView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.floatview.FloatingWindowButtonModel

@SuppressLint("AppCompatCustomView")
class FloatingWindowButton(context: Context) : ImageView(context) {
    private var viewModel = FloatingWindowButtonModel()

    private val callStatusObserver = Observer<TUICallDefine.Status> {
        if (viewModel.enableFloatWindow) {
            this.visibility = VISIBLE
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
        setBackgroundResource(R.drawable.tuicallkit_ic_move_back_white)
        val lp = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        layoutParams = lp

        setOnClickListener {
            if (PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()) {
                showFloatView()
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

    private fun showFloatView() {
        if (viewModel.scene.get() == TUICallDefine.Scene.GROUP_CALL) {
            viewModel.startFloatService(FloatingWindowGroupView(context.applicationContext))
        } else {
            viewModel.startFloatService(FloatingWindowView(context.applicationContext))
        }
        CallKitActivity.finishActivity()
    }

    private fun addObserver() {
        viewModel.callStatus.observe(callStatusObserver)
    }

    private fun removeObserver() {
        viewModel.callStatus.removeObserver(callStatusObserver)
    }
}