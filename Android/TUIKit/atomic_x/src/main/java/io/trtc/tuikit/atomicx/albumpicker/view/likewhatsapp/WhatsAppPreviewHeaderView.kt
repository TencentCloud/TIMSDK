package io.trtc.tuikit.atomicx.albumpicker.view.likewhatsapp

import android.content.Context
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.ImageView
import io.trtc.tuikit.albumpickercore.util.AlbumPickerUtil
import io.trtc.tuikit.atomicx.albumpicker.R
import io.trtc.tuikit.atomicx.albumpicker.util.AlbumPickerWindowHelper
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerThemeInternal

internal class WhatsAppPreviewHeaderView(
    context: Context,
    private val onDismissListener: OnDismissListener,
) : FrameLayout(context) {
    fun interface OnDismissListener {
        fun onDismiss()
    }

    companion object {
        private const val HEADER_HEIGHT_DP = 44
        private const val BACK_ICON_SIZE_DP = 24
    }

    init {
        val statusBarHeight = AlbumPickerWindowHelper.getStatusBarHeight(context)
        val headerHeight = AlbumPickerUtil.dpToPx(context, HEADER_HEIGHT_DP)
        val horizontalPadding = resources.getDimensionPixelSize(R.dimen.spacing_16)
        val darkBackground = AlbumPickerThemeInternal.darkBackground
        val darkTextColor = AlbumPickerThemeInternal.darkTextColor

        layoutParams =
            LayoutParams(
                LayoutParams.MATCH_PARENT, headerHeight + statusBarHeight,
            ).apply {
                gravity = Gravity.TOP
            }
        setPadding(horizontalPadding, statusBarHeight, horizontalPadding, 0)
        setBackgroundColor(darkBackground)

        val backIconSize = AlbumPickerUtil.dpToPx(context, BACK_ICON_SIZE_DP)
        val backButton =
            ImageView(context).apply {
                setImageResource(R.drawable.album_picker_ic_back)
                setColorFilter(darkTextColor)
                layoutParams =
                    LayoutParams(backIconSize, backIconSize).apply {
                        gravity = Gravity.START or Gravity.CENTER_VERTICAL
                    }
                setOnClickListener { onDismissListener.onDismiss() }
            }
        addView(backButton)
    }
}
