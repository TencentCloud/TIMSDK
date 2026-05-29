/*
 * Copyright (c) 2025 Tencent
 * All rights reserved.
 *
 * Author: eddardliu
 */

package io.trtc.tuikit.atomicx.imageuploader.view

import android.content.Context
import android.content.res.Configuration
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.theme.Theme
import io.trtc.tuikit.atomicx.theme.ThemeState
import io.trtc.tuikit.atomicx.theme.ThemeStore
import io.trtc.tuikit.atomicx.theme.tokens.ColorTokens

class ImageSourceBottomSheet(
    context: Context,
    private val listener: Listener
) : FrameLayout(context) {

    interface Listener {
        fun onCameraClick()
        fun onAlbumClick()
        fun onCancelClick()
    }

    companion object {
        private const val ANIMATION_DURATION = 250L
        private const val BOTTOM_SHEET_HEIGHT_DP = 300
    }

    private val dimBackground: View
    private val bottomSheet: LinearLayout
    private val colorTokens get() = ThemeStore.shared(context).themeState.value.currentTheme.tokens.color
    private val fontTokens get() = ThemeStore.shared(context).themeState.value.currentTheme.tokens.font

    init {
        layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        dimBackground = View(context).apply {
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
            background = ColorDrawable(colorTokens.bgColorMask)
            alpha = 0f
            setOnClickListener { listener.onCancelClick() }
        }
        bottomSheet = createBottomSheet()

        addView(dimBackground)
        addView(bottomSheet)
    }

    private fun createBottomSheet(): LinearLayout {
        val radius12 = context.resources.getDimensionPixelSize(R.dimen.radius_12)

        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT).apply {
                gravity = Gravity.BOTTOM
            }

            background = GradientDrawable().apply {
                setColor(colorTokens.bgColorDialog)
                cornerRadii = floatArrayOf(
                    radius12.toFloat(), radius12.toFloat(), radius12.toFloat(), radius12.toFloat(),
                    0f, 0f, 0f, 0f
                )
            }

            setPadding(0, context.resources.getDimensionPixelSize(R.dimen.spacing_16), 0,
                context.resources.getDimensionPixelSize(R.dimen.spacing_24))
            translationY = (BOTTOM_SHEET_HEIGHT_DP * context.resources.displayMetrics.density).toInt().toFloat()

            addView(createOptionItem(
                icon = ContextCompat.getDrawable(context, R.drawable.image_uploader_ic_camera),
                text = context.getString(R.string.image_uploader_camera),
                onClick = { listener.onCameraClick() }
            ))

            addView(createOptionItem(
                icon = ContextCompat.getDrawable(context, R.drawable.image_uploader_ic_album),
                text = context.getString(R.string.image_uploader_album),
                onClick = { listener.onAlbumClick() }
            ))

            addView(View(context).apply {
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    context.resources.getDimensionPixelSize(R.dimen.spacing_8)
                ).apply {
                    topMargin = context.resources.getDimensionPixelSize(R.dimen.radius_12)
                }
                setBackgroundColor(colorTokens.strokeColorSecondary)
            })

            addView(TextView(context).apply {
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    context.resources.getDimensionPixelSize(R.dimen.spacing_56)
                )
                text = context.getString(R.string.image_uploader_cancel)
                setTextColor(colorTokens.buttonColorPrimaryDefault)
                textSize = fontTokens.regular16.size
                gravity = Gravity.CENTER
                setOnClickListener { listener.onCancelClick() }
            })
        }
    }

    private fun createOptionItem(icon: android.graphics.drawable.Drawable?, text: String, onClick: () -> Unit): LinearLayout {
        return LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                context.resources.getDimensionPixelSize(R.dimen.spacing_56)
            )
            gravity = Gravity.CENTER_VERTICAL
            setPadding(context.resources.getDimensionPixelSize(R.dimen.spacing_16), 0,
                context.resources.getDimensionPixelSize(R.dimen.spacing_16), 0)

            val typedValue = TypedValue()
            context.theme.resolveAttribute(android.R.attr.selectableItemBackground, typedValue, true)
            setBackgroundResource(typedValue.resourceId)

            setOnClickListener { onClick() }

            addView(ImageView(context).apply {
                layoutParams = LinearLayout.LayoutParams(
                    context.resources.getDimensionPixelSize(R.dimen.spacing_24),
                    context.resources.getDimensionPixelSize(R.dimen.spacing_24)
                )
                setImageDrawable(icon)
                setColorFilter(colorTokens.textColorSecondary)
            })

            addView(TextView(context).apply {
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                    marginStart = context.resources.getDimensionPixelSize(R.dimen.radius_12)
                }
                this.text = text
                setTextColor(colorTokens.textColorPrimary)
                this.textSize = fontTokens.regular16.size
            })

            addView(ImageView(context).apply {
                layoutParams = LinearLayout.LayoutParams(
                    context.resources.getDimensionPixelSize(R.dimen.spacing_20),
                    context.resources.getDimensionPixelSize(R.dimen.spacing_20)
                )
                setImageDrawable(ContextCompat.getDrawable(context, R.drawable.image_uploader_ic_arrow_right))
                setColorFilter(colorTokens.textColorSecondary)
            })
        }
    }

    fun show() {
        visibility = VISIBLE
        dimBackground.visibility = VISIBLE
        bottomSheet.visibility = VISIBLE
        dimBackground.animate().alpha(1f).setDuration(ANIMATION_DURATION).start()
        bottomSheet.animate().translationY(0f).setDuration(ANIMATION_DURATION).start()
    }

    fun hide(onEnd: (() -> Unit)? = null) {
        dimBackground.animate().alpha(0f).setDuration(ANIMATION_DURATION).start()
        bottomSheet.animate().translationY(bottomSheet.height.toFloat()).setDuration(ANIMATION_DURATION).withEndAction {
                dimBackground.visibility = GONE
                bottomSheet.visibility = GONE
                visibility = GONE
                onEnd?.invoke()
            }.start()
    }
}