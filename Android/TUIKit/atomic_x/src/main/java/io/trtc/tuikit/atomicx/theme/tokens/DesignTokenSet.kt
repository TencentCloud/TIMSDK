package io.trtc.tuikit.atomicx.theme.tokens

import android.content.Context

data class DesignTokenSet(
    val id: String,
    val displayName: String,
    val color: ColorTokens,
    val font: FontTokens,
    val shadow: ShadowTokens
) {
    companion object {

        fun defaultLight(context: Context): DesignTokenSet {
            return DesignTokenSet(
                id = "light",
                displayName = "Light Theme",
                color = ColorTokens.defaultLight(context),
                font = FontTokens(),
                shadow = ShadowTokens.standard()
            )
        }

        fun defaultDark(context: Context): DesignTokenSet {
            return DesignTokenSet(
                id = "dark",
                displayName = "Dark Theme",
                color = ColorTokens.defaultDark(context),
                font = FontTokens(),
                shadow = ShadowTokens.standard()
            )
        }
    }
}