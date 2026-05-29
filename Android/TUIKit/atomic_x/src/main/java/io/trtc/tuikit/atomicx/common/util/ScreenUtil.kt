package io.trtc.tuikit.atomicx.common.util

import android.content.Context
import android.util.DisplayMetrics
import android.util.TypedValue
import android.view.WindowManager
import com.tencent.cloud.tuikit.engine.common.ContextProvider

object ScreenUtil {

    @JvmStatic
    fun getScreenHeight(context: Context): Int {
        val metric = DisplayMetrics()
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        wm.defaultDisplay.getMetrics(metric)
        return metric.heightPixels
    }

    @JvmStatic
    fun getScreenWidth(context: Context): Int {
        val metric = DisplayMetrics()
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        wm.defaultDisplay.getMetrics(metric)
        return metric.widthPixels
    }

    @JvmStatic
    fun getPxByDp(dp: Float): Int {
        val scale =
            ContextProvider.getApplicationContext()?.resources?.displayMetrics?.density ?: 1.0f
        return (dp * scale + 0.5f).toInt()
    }

    @JvmStatic
    fun getRealScreenHeight(context: Context): Int {
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val display = wm.defaultDisplay
        val dm = DisplayMetrics()
        display.getRealMetrics(dm)
        return dm.heightPixels
    }

    @JvmStatic
    fun getRealScreenWidth(context: Context): Int {
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val display = wm.defaultDisplay
        val dm = DisplayMetrics()
        display.getRealMetrics(dm)
        return dm.widthPixels
    }

    @JvmStatic
    fun getNavigationBarHeight(context: Context): Int {
        val resourceId =
            context.resources.getIdentifier("navigation_bar_height", "dimen", "android")
        if (resourceId > 0) {
            return context.resources.getDimensionPixelSize(resourceId)
        }
        return 0
    }

    @JvmStatic
    fun scaledSize(
        containerWidth: Int,
        containerHeight: Int,
        realWidth: Int,
        realHeight: Int
    ): IntArray {
        val deviceRate = containerWidth.toFloat() / containerHeight.toFloat()
        val rate = realWidth.toFloat() / realHeight.toFloat()
        val width: Int
        val height: Int
        if (rate < deviceRate) {
            height = containerHeight
            width = (containerHeight * rate).toInt()
        } else {
            width = containerWidth
            height = (containerWidth / rate).toInt()
        }
        return intArrayOf(width, height)
    }

    @JvmStatic
    fun dip2px(dpValue: Float): Int {
        val scale =
            ContextProvider.getApplicationContext()?.resources?.displayMetrics?.density ?: 1.0f
        return (dpValue * scale + 0.5f).toInt()
    }

    @JvmStatic
    fun dp2px(dpValue: Float, displayMetrics: DisplayMetrics): Float {
        return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dpValue, displayMetrics)
    }
}
