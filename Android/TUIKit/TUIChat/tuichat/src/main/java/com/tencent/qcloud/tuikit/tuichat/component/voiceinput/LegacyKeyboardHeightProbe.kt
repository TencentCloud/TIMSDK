package com.tencent.qcloud.tuikit.tuichat.component.voiceinput

import android.app.Activity
import android.graphics.Color
import android.graphics.Rect
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.PopupWindow

internal class LegacyKeyboardHeightProbe(
    private val activity: Activity,
    private val minKeyboardHeight: Int,
    private val navigationBarBottomProvider: () -> Int,
    private val listener: Listener,
) {
    interface Listener {
        fun onProbeHeightChanged(height: Int, visible: Boolean)
    }

    private var popupWindow: PopupWindow? = null
    private var contentView: FrameLayout? = null
    private var globalLayoutListener: ViewTreeObserver.OnGlobalLayoutListener? = null
    private var lastHeight = 0
    private var lastVisible = false
    private var baseHeight = 0

    fun start(anchor: View) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            return
        }
        if (popupWindow?.isShowing == true) {
            return
        }

        val content = FrameLayout(activity).apply {
            setBackgroundColor(Color.TRANSPARENT)
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            )
        }
        val visibleFrame = Rect()
        val layoutListener = ViewTreeObserver.OnGlobalLayoutListener {
            content.getWindowVisibleDisplayFrame(visibleFrame)
            val rootHeight = content.rootView.height
            val contentHeight = content.height
            val nav = navigationBarBottomProvider()
            if (baseHeight <= 0 && rootHeight > 0 && contentHeight > 0) {
                baseHeight = maxOf(rootHeight, contentHeight)
            }
            val height = LegacyKeyboardHeightCalculator.toPopupProbeKeyboardHeight(
                popupHeight = rootHeight,
                baseHeight = baseHeight.takeIf { it > 0 } ?: rootHeight,
                contentHeight = contentHeight,
                visibleBottom = visibleFrame.bottom,
                navigationBarBottom = nav,
                minKeyboardHeight = minKeyboardHeight,
            )
            val visible = height > 0
            if (height != lastHeight || visible != lastVisible) {
                lastHeight = height
                lastVisible = visible
                listener.onProbeHeightChanged(height, visible)
            }
        }
        content.viewTreeObserver.addOnGlobalLayoutListener(layoutListener)

        val popup = PopupWindow(content).apply {
            width = WindowManager.LayoutParams.MATCH_PARENT
            height = WindowManager.LayoutParams.MATCH_PARENT
            isFocusable = false
            isTouchable = false
            isOutsideTouchable = false
            setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
            inputMethodMode = PopupWindow.INPUT_METHOD_NEEDED
            @Suppress("DEPRECATION")
            softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
            isClippingEnabled = true
        }

        contentView = content
        globalLayoutListener = layoutListener
        popupWindow = popup
        anchor.post {
            if (canShow(anchor, popup)) {
                try {
                    popup.showAtLocation(anchor.rootView ?: anchor, Gravity.NO_GRAVITY, 0, 0)
                } catch (_: RuntimeException) {
                }
            }
        }
    }

    fun stop() {
        val content = contentView
        val layoutListener = globalLayoutListener
        if (content != null && layoutListener != null) {
            val observer = content.viewTreeObserver
            if (observer.isAlive) {
                observer.removeOnGlobalLayoutListener(layoutListener)
            }
        }
        popupWindow?.dismiss()
        popupWindow = null
        contentView = null
        globalLayoutListener = null
        lastHeight = 0
        lastVisible = false
        baseHeight = 0
    }

    private fun canShow(anchor: View, popup: PopupWindow): Boolean {
        return anchor.windowToken != null &&
            popupWindow === popup &&
            !popup.isShowing &&
            !activity.isFinishing &&
            !isActivityDestroyed()
    }

    private fun isActivityDestroyed(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1 && activity.isDestroyed
    }
}
