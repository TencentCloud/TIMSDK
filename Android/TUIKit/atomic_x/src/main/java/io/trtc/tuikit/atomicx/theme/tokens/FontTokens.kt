package io.trtc.tuikit.atomicx.theme.tokens

import android.graphics.Typeface

data class Font(
    val size: Float,
    val weight: Int
)

data class FontTokens(
    val bold40: Font = Font(size = 40f, weight = Typeface.BOLD),
    val bold36: Font = Font(size = 36f, weight = Typeface.BOLD),
    val bold34: Font = Font(size = 34f, weight = Typeface.BOLD),
    val bold32: Font = Font(size = 32f, weight = Typeface.BOLD),
    val bold28: Font = Font(size = 28f, weight = Typeface.BOLD),
    val bold24: Font = Font(size = 24f, weight = Typeface.BOLD),
    val bold20: Font = Font(size = 20f, weight = Typeface.BOLD),
    val bold18: Font = Font(size = 18f, weight = Typeface.BOLD),
    val bold16: Font = Font(size = 16f, weight = Typeface.BOLD),
    val bold14: Font = Font(size = 14f, weight = Typeface.BOLD),
    val bold12: Font = Font(size = 12f, weight = Typeface.BOLD),
    val bold10: Font = Font(size = 10f, weight = Typeface.BOLD),

    val regular40: Font = Font(size = 40f, weight = Typeface.NORMAL),
    val regular36: Font = Font(size = 36f, weight = Typeface.NORMAL),
    val regular34: Font = Font(size = 34f, weight = Typeface.NORMAL),
    val regular32: Font = Font(size = 32f, weight = Typeface.NORMAL),
    val regular28: Font = Font(size = 28f, weight = Typeface.NORMAL),
    val regular24: Font = Font(size = 24f, weight = Typeface.NORMAL),
    val regular20: Font = Font(size = 20f, weight = Typeface.NORMAL),
    val regular18: Font = Font(size = 18f, weight = Typeface.NORMAL),
    val regular16: Font = Font(size = 16f, weight = Typeface.NORMAL),
    val regular14: Font = Font(size = 14f, weight = Typeface.NORMAL),
    val regular12: Font = Font(size = 12f, weight = Typeface.NORMAL),
    val regular10: Font = Font(size = 10f, weight = Typeface.NORMAL)
)