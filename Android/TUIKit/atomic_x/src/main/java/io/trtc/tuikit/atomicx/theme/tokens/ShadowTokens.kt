package io.trtc.tuikit.atomicx.theme.tokens

import androidx.annotation.ColorInt

data class ShadowStyle(
    val elevation: Float,
    @ColorInt val color: Int,
    val x: Float = 0f,
    val y: Float = 0f,
    val radius: Float = 0f,
    val opacity: Float = 1.0f
)

data class ShadowTokens(
    val smallShadow: ShadowStyle,
    val mediumShadow: ShadowStyle
) {
    companion object {

        fun standard(): ShadowTokens {
            return ShadowTokens(
                smallShadow = ShadowStyle(
                    elevation = 2f,
                    color = 0x1F000000.toInt(),
                    x = 0f,
                    y = 2f,
                    radius = 4f,
                    opacity = 1.0f
                ),
                mediumShadow = ShadowStyle(
                    elevation = 4f,
                    color = 0x29000000.toInt(),
                    x = 0f,
                    y = 4f,
                    radius = 8f,
                    opacity = 1.0f
                )
            )
        }
    }
}