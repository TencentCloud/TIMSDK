package com.tencent.qcloud.tuikit.tuichat.component.voiceinput

import android.app.Activity
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

internal object KeyboardInsetsUtil {
    fun toPanelSpacerHeight(imeBottom: Int, insets: WindowInsetsCompat?): Int {
        val navigationBarBottom = insets
            ?.getInsets(WindowInsetsCompat.Type.navigationBars())
            ?.bottom
            ?: 0
        return toPanelSpacerHeight(
            imeBottom = imeBottom,
            navigationBarBottom = navigationBarBottom,
        )
    }

    fun toPanelSpacerHeight(imeBottom: Int, navigationBarBottom: Int): Int {
        return (imeBottom - navigationBarBottom).coerceAtLeast(0)
    }

    fun getNavigationBarBottom(activity: Activity, view: View): Int {
        val insetsBottom = ViewCompat.getRootWindowInsets(view)
            ?.getInsets(WindowInsetsCompat.Type.navigationBars())
            ?.bottom
            ?: 0
        if (insetsBottom > 0) {
            return insetsBottom
        }
        val resourceId = activity.resources.getIdentifier("navigation_bar_height", "dimen", "android")
        return if (resourceId > 0) {
            activity.resources.getDimensionPixelSize(resourceId)
        } else {
            0
        }
    }
}
