package com.tencent.qcloud.tuikit.tuicallkit.view.root

import android.content.Context
import android.widget.RelativeLayout

abstract class BaseCallView(context: Context) : RelativeLayout(context) {
    abstract fun clear()
}