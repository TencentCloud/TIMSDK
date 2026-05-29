package com.tencent.qcloud.tuikit.tuichat.component.voiceinput

internal object LegacyKeyboardHeightCalculator {
    fun toVisibleKeyboardHeight(
        occludedBottom: Int,
        navigationBarBottom: Int,
        minKeyboardHeight: Int,
    ): Int {
        val height = KeyboardInsetsUtil.toPanelSpacerHeight(
            imeBottom = occludedBottom,
            navigationBarBottom = navigationBarBottom,
        )
        return if (height >= minKeyboardHeight) height else 0
    }

    fun toPopupProbeKeyboardHeight(
        popupHeight: Int,
        baseHeight: Int = popupHeight,
        contentHeight: Int = popupHeight,
        visibleBottom: Int,
        navigationBarBottom: Int,
        minKeyboardHeight: Int,
    ): Int {
        val visibleFrameOccludedBottom = if (visibleBottom in 0..popupHeight) {
            popupHeight - visibleBottom
        } else {
            0
        }
        val resizedContentOccludedBottom = (popupHeight - contentHeight).coerceAtLeast(0)
        val baseResizeOccludedBottom = (baseHeight - contentHeight).coerceAtLeast(0)
        val visibleFrameHeight = toVisibleKeyboardHeight(
            occludedBottom = visibleFrameOccludedBottom,
            navigationBarBottom = navigationBarBottom,
            minKeyboardHeight = minKeyboardHeight,
        )
        val resizedContentHeight = resizedContentOccludedBottom.takeIf { it >= minKeyboardHeight } ?: 0
        val baseResizeHeight = baseResizeOccludedBottom.takeIf { it >= minKeyboardHeight } ?: 0
        return maxOf(visibleFrameHeight, resizedContentHeight, baseResizeHeight)
    }
}
