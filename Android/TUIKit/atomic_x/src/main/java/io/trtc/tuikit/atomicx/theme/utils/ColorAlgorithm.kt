package io.trtc.tuikit.atomicx.theme.utils

import android.content.Context
import androidx.annotation.ColorInt
import androidx.core.content.ContextCompat
import io.trtc.tuikit.atomicx.R
import kotlin.math.*
import androidx.core.graphics.toColorInt

object ColorAlgorithm {
    fun generateColorPalette(context: Context, baseColor: String, theme: String): List<Int> {
        return if (isStandardColor(baseColor)) {
            val paletteType = getClosestPaletteType(baseColor)
            getPaletteFromResources(context, paletteType, theme)
        } else {
            generateDynamicColorVariations(baseColor, theme)
        }
    }

    @ColorInt
    fun parseHexColor(hexColor: String): Int {
        val cleanHex = hexColor.removePrefix("#")
        return "#$cleanHex".toColorInt()
    }

    private enum class PaletteType {
        BLUE, GREEN, RED, ORANGE
    }

    private fun getPaletteFromResources(
        context: Context,
        type: PaletteType,
        theme: String
    ): List<Int> {
        val colorIds = when (type) {
            PaletteType.BLUE -> if (theme == "dark") {
                listOf(
                    R.color.theme_dark_1, R.color.theme_dark_2, R.color.theme_dark_3,
                    R.color.theme_dark_4, R.color.theme_dark_5, R.color.theme_dark_6,
                    R.color.theme_dark_7, R.color.theme_dark_8, R.color.theme_dark_9,
                    R.color.theme_dark_10
                )
            } else {
                listOf(
                    R.color.theme_light_1, R.color.theme_light_2, R.color.theme_light_3,
                    R.color.theme_light_4, R.color.theme_light_5, R.color.theme_light_6,
                    R.color.theme_light_7, R.color.theme_light_8, R.color.theme_light_9,
                    R.color.theme_light_10
                )
            }

            PaletteType.GREEN -> if (theme == "dark") {
                listOf(
                    R.color.green_dark_1, R.color.green_dark_2, R.color.green_dark_3,
                    R.color.green_dark_4, R.color.green_dark_5, R.color.green_dark_6,
                    R.color.green_dark_7, R.color.green_dark_8, R.color.green_dark_9,
                    R.color.green_dark_10
                )
            } else {
                listOf(
                    R.color.green_light_1, R.color.green_light_2, R.color.green_light_3,
                    R.color.green_light_4, R.color.green_light_5, R.color.green_light_6,
                    R.color.green_light_7, R.color.green_light_8, R.color.green_light_9,
                    R.color.green_light_10
                )
            }

            PaletteType.RED -> if (theme == "dark") {
                listOf(
                    R.color.red_dark_1, R.color.red_dark_2, R.color.red_dark_3,
                    R.color.red_dark_4, R.color.red_dark_5, R.color.red_dark_6,
                    R.color.red_dark_7, R.color.red_dark_8, R.color.red_dark_9,
                    R.color.red_dark_10
                )
            } else {
                listOf(
                    R.color.red_light_1, R.color.red_light_2, R.color.red_light_3,
                    R.color.red_light_4, R.color.red_light_5, R.color.red_light_6,
                    R.color.red_light_7, R.color.red_light_8, R.color.red_light_9,
                    R.color.red_light_10
                )
            }

            PaletteType.ORANGE -> if (theme == "dark") {
                listOf(
                    R.color.orange_dark_1, R.color.orange_dark_2, R.color.orange_dark_3,
                    R.color.orange_dark_4, R.color.orange_dark_5, R.color.orange_dark_6,
                    R.color.orange_dark_7, R.color.orange_dark_8, R.color.orange_dark_9,
                    R.color.orange_dark_10
                )
            } else {
                listOf(
                    R.color.orange_light_1, R.color.orange_light_2, R.color.orange_light_3,
                    R.color.orange_light_4, R.color.orange_light_5, R.color.orange_light_6,
                    R.color.orange_light_7, R.color.orange_light_8, R.color.orange_light_9,
                    R.color.orange_light_10
                )
            }
        }

        return colorIds.map { ContextCompat.getColor(context, it) }
    }

    private val STANDARD_COLORS = mapOf(
        PaletteType.BLUE to "#1c66e5",
        PaletteType.GREEN to "#0abf77",
        PaletteType.RED to "#e54545",
        PaletteType.ORANGE to "#ff7200"
    )

    private fun isStandardColor(color: String): Boolean {
        val inputHsl = hexToHSL(color)
        return STANDARD_COLORS.values.any { standardColor ->
            val standardHsl = hexToHSL(standardColor)
            val dh =
                min(
                    abs(inputHsl.first - standardHsl.first),
                    360 - abs(inputHsl.first - standardHsl.first)
                )
            dh < 15 && abs(inputHsl.second - standardHsl.second) < 15 && abs(inputHsl.third - standardHsl.third) < 15
        }
    }

    private fun getClosestPaletteType(color: String): PaletteType {
        val hsl = hexToHSL(color)

        val distances = STANDARD_COLORS.map { (type, baseColor) ->
            type to colorDistance(hsl, hexToHSL(baseColor))
        }

        return distances.minByOrNull { it.second }?.first ?: PaletteType.BLUE
    }

    private val HSL_ADJUSTMENTS = mapOf(
        "light" to mapOf(
            1 to Pair(-40.0, 45.0),
            2 to Pair(-30.0, 35.0),
            3 to Pair(-20.0, 25.0),
            4 to Pair(-10.0, 15.0),
            5 to Pair(-5.0, 5.0),
            6 to Pair(0.0, 0.0),
            7 to Pair(5.0, -10.0),
            8 to Pair(10.0, -20.0),
            9 to Pair(15.0, -30.0),
            10 to Pair(20.0, -40.0)
        ),
        "dark" to mapOf(
            1 to Pair(-60.0, -35.0),
            2 to Pair(-50.0, -25.0),
            3 to Pair(-40.0, -15.0),
            4 to Pair(-30.0, -5.0),
            5 to Pair(-20.0, 5.0),
            6 to Pair(0.0, 0.0),
            7 to Pair(-10.0, 15.0),
            8 to Pair(-20.0, 30.0),
            9 to Pair(-30.0, 45.0),
            10 to Pair(-40.0, 60.0)
        )
    )

    private fun generateDynamicColorVariations(baseColor: String, theme: String): List<Int> {
        val variations = mutableListOf<Int>()
        val adjustments = HSL_ADJUSTMENTS[theme] ?: HSL_ADJUSTMENTS["light"]!!
        val baseHsl = hexToHSL(baseColor)
        val saturationFactor = when {
            baseHsl.second > 70 -> 0.8
            baseHsl.second < 30 -> 1.2
            else -> 1.0
        }
        val lightnessFactor = when {
            baseHsl.third > 70 -> 0.8
            baseHsl.third < 30 -> 1.2
            else -> 1.0
        }

        for (i in 1..10) {
            val adjustment = adjustments[i] ?: Pair(0.0, 0.0)
            val adjustedS = adjustment.first * saturationFactor
            val adjustedL = adjustment.second * lightnessFactor
            variations.add(parseHexColor(adjustColor(baseColor, Pair(adjustedS, adjustedL))))
        }

        return variations
    }

    private fun adjustColor(color: String, adjustment: Pair<Double, Double>): String {
        val hsl = hexToHSL(color)
        val newS = max(0.0, min(100.0, hsl.second + adjustment.first))
        val newL = max(0.0, min(100.0, hsl.third + adjustment.second))
        return hslToHex(hsl.first, newS, newL)
    }

    private fun colorDistance(
        c1: Triple<Double, Double, Double>,
        c2: Triple<Double, Double, Double>
    ): Double {
        val dh = min(abs(c1.first - c2.first), 360 - abs(c1.first - c2.first))
        val ds = c1.second - c2.second
        val dl = c1.third - c2.third
        return sqrt(dh * dh + ds * ds + dl * dl)
    }

    private fun hexToHSL(hex: String): Triple<Double, Double, Double> {
        val cleanHex = hex.removePrefix("#")
        val colorInt = cleanHex.toLong(16)

        val r = ((colorInt shr 16) and 0xFF) / 255.0
        val g = ((colorInt shr 8) and 0xFF) / 255.0
        val b = (colorInt and 0xFF) / 255.0

        val maxVal = maxOf(r, g, b)
        val minVal = minOf(r, g, b)
        var h = 0.0
        var s = 0.0
        val l = (maxVal + minVal) / 2.0

        if (maxVal != minVal) {
            val d = maxVal - minVal
            s = if (l > 0.5) d / (2.0 - maxVal - minVal) else d / (maxVal + minVal)

            h = when (maxVal) {
                r -> (g - b) / d + (if (g < b) 6.0 else 0.0)
                g -> (b - r) / d + 2.0
                b -> (r - g) / d + 4.0
                else -> 0.0
            }
            h /= 6.0
        }

        return Triple(h * 360.0, s * 100.0, l * 100.0)
    }

    private fun hslToHex(h: Double, s: Double, l: Double): String {
        val hNorm = h / 360.0
        val sNorm = s / 100.0
        val lNorm = l / 100.0

        val c = (1.0 - abs(2.0 * lNorm - 1.0)) * sNorm
        val x = c * (1.0 - abs((hNorm * 6.0) % 2.0 - 1.0))
        val m = lNorm - c / 2.0

        val (r, g, b) = when ((hNorm * 6.0).toInt()) {
            0 -> Triple(c, x, 0.0)
            1 -> Triple(x, c, 0.0)
            2 -> Triple(0.0, c, x)
            3 -> Triple(0.0, x, c)
            4 -> Triple(x, 0.0, c)
            5 -> Triple(c, 0.0, x)
            else -> Triple(0.0, 0.0, 0.0)
        }

        val red = ((r + m) * 255.0).toInt()
        val green = ((g + m) * 255.0).toInt()
        val blue = ((b + m) * 255.0).toInt()

        return "#%02X%02X%02X".format(red, green, blue)
    }
}