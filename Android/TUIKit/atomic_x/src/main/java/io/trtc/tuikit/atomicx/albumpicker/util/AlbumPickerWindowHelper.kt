package io.trtc.tuikit.atomicx.albumpicker.util

import android.app.Activity
import android.content.Context
import android.view.View
import android.view.WindowManager
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

internal object AlbumPickerWindowHelper {
    private var originalNavigationBarColor: Int? = null
    private var originalSoftInputMode: Int? = null

    fun getStatusBarHeight(context: Context): Int {
        val res = context.resources
        val id = res.getIdentifier("status_bar_height", "dimen", "android")
        return if (id > 0) res.getDimensionPixelSize(id) else 0
    }

    fun applyNavigationBarColor(activity: Activity?, backgroundColor: Int) {
        val window = activity?.window ?: return
        originalNavigationBarColor = window.navigationBarColor
        window.navigationBarColor = backgroundColor
    }

    fun restoreNavigationBarColor(activity: Activity?) {
        val window = activity?.window ?: return
        originalNavigationBarColor?.let { window.navigationBarColor = it }
    }

    fun applySoftInputMode(
        activity: Activity?,
        containerView: View,
        vararg paddingTargets: View,
        onImeHidden: () -> Unit,
    ) {
        val window = activity?.window ?: return
        originalSoftInputMode = window.attributes.softInputMode
        window.setSoftInputMode(
            WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE or
                WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN,
        )

        ViewCompat.setOnApplyWindowInsetsListener(containerView) { _, insets ->
            val imeVisible = insets.isVisible(WindowInsetsCompat.Type.ime())
            val imeBottom = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom
            val navBottom = insets.getInsets(WindowInsetsCompat.Type.navigationBars()).bottom
            val bottomPadding = if (imeBottom > navBottom) imeBottom - navBottom else 0
            for (view in paddingTargets) {
                view.setPadding(view.paddingLeft, view.paddingTop, view.paddingRight, bottomPadding)
            }
            if (!imeVisible) {
                onImeHidden()
            }
            insets
        }
        ViewCompat.requestApplyInsets(containerView)
    }

    fun restoreSoftInputMode(activity: Activity?, containerView: View, vararg paddingTargets: View) {
        val window = activity?.window ?: return
        originalSoftInputMode?.let { window.setSoftInputMode(it) }
        ViewCompat.setOnApplyWindowInsetsListener(containerView, null)
        for (view in paddingTargets) {
            view.setPadding(view.paddingLeft, view.paddingTop, view.paddingRight, 0)
        }
    }
}
