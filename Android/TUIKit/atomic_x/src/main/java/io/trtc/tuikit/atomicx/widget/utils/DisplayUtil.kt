package io.trtc.tuikit.atomicx.widget.utils

import android.content.Context
import androidx.annotation.FloatRange
import androidx.annotation.IntRange


object DisplayUtil {

    @JvmStatic
    @IntRange(from = 0)
    fun dp2px(context: Context, @FloatRange(from = 0.0) dpValue: Float): Int {
        val scale = context.resources.displayMetrics.density
        return (dpValue * scale + 0.5f).toInt()
    }

    @JvmStatic
    fun px2dp(context: Context, pxValue: Float): Int {
        val scale = context.resources.displayMetrics.density
        return (pxValue / scale + 0.5f).toInt()
    }
}