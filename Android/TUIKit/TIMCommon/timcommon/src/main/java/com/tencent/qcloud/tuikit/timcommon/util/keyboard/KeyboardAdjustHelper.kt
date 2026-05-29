package com.tencent.qcloud.tuikit.timcommon.util.keyboard

import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat

object KeyboardAdjustHelper {
    fun attachKeyboardAdjustments(view: View?, listener: KeyBoardAdjustListener?) {
        if (view == null) {
            return
        }

        val rootView = view.rootView
        ViewCompat.setWindowInsetsAnimationCallback(
            rootView, object : WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_CONTINUE_ON_SUBTREE) {
                var softInputHeight: Float = 0F

                val isSoftInputVisible: Boolean
                    get() {
                        val insets = ViewCompat.getRootWindowInsets(rootView) ?: return false
                        return insets.isVisible(WindowInsetsCompat.Type.ime())
                    }

                override fun onStart(
                    animation: WindowInsetsAnimationCompat, bounds: WindowInsetsAnimationCompat.BoundsCompat
                ): WindowInsetsAnimationCompat.BoundsCompat {
                    if ((animation.typeMask and WindowInsetsCompat.Type.ime()) != 0) {
                        softInputHeight = bounds.upperBound.bottom.toFloat()
                        val isSoftInputVisible = isSoftInputVisible
                        listener?.onStart(isSoftInputVisible, softInputHeight)
                    }
                    return super.onStart(animation, bounds)
                }

                override fun onEnd(animation: WindowInsetsAnimationCompat) {
                    if ((animation.typeMask and WindowInsetsCompat.Type.ime()) != 0) {
                        val isSoftInputVisible = isSoftInputVisible
                        listener?.onEnd(isSoftInputVisible, softInputHeight)
                    }
                    super.onEnd(animation)
                }

                override fun onProgress(
                    insets: WindowInsetsCompat,
                    runningAnimations: List<WindowInsetsAnimationCompat>
                ): WindowInsetsCompat {
                    if (softInputHeight == 0F) {
                        return insets
                    }
                    val isSoftInputVisible = isSoftInputVisible
                    for (runningAnimation in runningAnimations) {
                        if ((runningAnimation.typeMask and WindowInsetsCompat.Type.ime()) != 0) {
                            val imeInsets = insets.getInsets(WindowInsetsCompat.Type.ime())
                            listener?.onProgress(isSoftInputVisible, imeInsets.bottom.toFloat())
                            break
                        }
                    }

                    return insets
                }
            })
    }

    fun detachKeyboardAdjustments(view: View?) {
        if (view == null) {
            return
        }

        val rootView = view.rootView
        ViewCompat.setWindowInsetsAnimationCallback(rootView, null)
    }

}

interface KeyBoardAdjustListener {
    fun onStart(isVisible: Boolean, keyboardHeight: Float) {}
    fun onEnd(isVisible: Boolean, keyboardHeight: Float) {}
    fun onProgress(isVisible: Boolean, currentKeyboardHeight: Float) {}
}