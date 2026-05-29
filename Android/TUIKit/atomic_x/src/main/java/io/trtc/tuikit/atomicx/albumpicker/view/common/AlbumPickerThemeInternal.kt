package io.trtc.tuikit.atomicx.albumpicker.view.common

import android.content.Context
import android.content.res.Configuration
import android.graphics.drawable.Drawable
import androidx.core.content.ContextCompat
import io.trtc.tuikit.albumpickercore.AlbumPickerCoreTheme
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerTheme
import io.trtc.tuikit.atomicx.albumpicker.R

internal object AlbumPickerThemeInternal {
    private const val DEFAULT_SMALL_RADIUS_DP = 4
    private const val DEFAULT_NORMAL_RADIUS_DP = 8
    private const val DEFAULT_BIG_RADIUS_DP = 12
    private const val DEFAULT_BIG_FONT_SIZE_SP = 16f
    private const val DEFAULT_NORMAL_FONT_SIZE_SP = 14f
    private const val DEFAULT_SMALL_FONT_SIZE_SP = 10f

    var currentPrimaryColor: Int = 0
        private set
    var backgroundColor: Int = 0
        private set
    var backgroundColorSecondary: Int = 0
        private set
    var textColor: Int = 0
        private set
    var textColorSecondary: Int = 0
        private set

    var darkBackground: Int = 0
        private set
    var darkBackgroundSecondary: Int = 0
        private set
    var darkTextColor: Int = 0
        private set
    var darkTextColorSecondary: Int = 0
        private set
    var smallRadius: Int = DEFAULT_SMALL_RADIUS_DP
        private set
    var normalRadius: Int = DEFAULT_NORMAL_RADIUS_DP
        private set
    var bigRadius: Int = DEFAULT_BIG_RADIUS_DP
        private set
    var bigFontSize: Float = DEFAULT_BIG_FONT_SIZE_SP
        private set
    var normalFontSize: Float = DEFAULT_NORMAL_FONT_SIZE_SP
        private set
    var smallFontSize: Float = DEFAULT_SMALL_FONT_SIZE_SP
        private set
    var confirmButtonIcon: Drawable? = null

    fun initialize(context: Context, theme: AlbumPickerTheme) {
        val isDark = isDarkMode(context)

        darkBackground = ContextCompat.getColor(context, R.color.album_picker_dark_background)
        darkBackgroundSecondary =
            ContextCompat.getColor(context, R.color.album_picker_dark_background_secondary)
        darkTextColor = ContextCompat.getColor(context, R.color.album_picker_dark_text_color)
        darkTextColorSecondary =
            ContextCompat.getColor(context, R.color.album_picker_dark_text_color_secondary)

        currentPrimaryColor = theme.currentPrimaryColor
            ?: ContextCompat.getColor(context, R.color.album_picker_primary_color)

        backgroundColor = theme.backgroundColor
            ?: if (isDark) darkBackground else {
                ContextCompat.getColor(context, R.color.album_picker_light_background)
            }

        backgroundColorSecondary = theme.backgroundColorSecondary
            ?: if (isDark) darkBackgroundSecondary else {
                ContextCompat.getColor(context, R.color.album_picker_light_background_secondary)
            }

        textColor = theme.textColor
            ?: if (isDark) darkTextColor else {
                ContextCompat.getColor(context, R.color.album_picker_light_text_color)
            }

        textColorSecondary = theme.textColorSecondary
            ?: if (isDark) darkTextColorSecondary else {
                ContextCompat.getColor(context, R.color.album_picker_light_text_color_secondary)
            }

        smallRadius = theme.smallRadius ?: DEFAULT_SMALL_RADIUS_DP
        normalRadius = theme.normalRadius ?: DEFAULT_NORMAL_RADIUS_DP
        bigRadius = theme.bigRadius ?: DEFAULT_BIG_RADIUS_DP
        bigFontSize = theme.bigFontSize ?: DEFAULT_BIG_FONT_SIZE_SP
        normalFontSize = theme.normalFontSize ?: DEFAULT_NORMAL_FONT_SIZE_SP
        smallFontSize = theme.smallFontSize ?: DEFAULT_SMALL_FONT_SIZE_SP
        confirmButtonIcon = theme.confirmButtonIcon

        updateStoreTheme(context)
    }

    private fun isDarkMode(context: Context): Boolean {
        val uiMode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        return uiMode == Configuration.UI_MODE_NIGHT_YES
    }

    private fun updateStoreTheme(context: Context) {
        AlbumPickerCoreTheme.getInstance(context).apply {
            currentPrimaryColor = this@AlbumPickerThemeInternal.currentPrimaryColor
            backgroundColor = this@AlbumPickerThemeInternal.backgroundColor
            backgroundColorSecondary = this@AlbumPickerThemeInternal.backgroundColorSecondary
            textColor = this@AlbumPickerThemeInternal.textColor
            textColorSecondary = this@AlbumPickerThemeInternal.textColorSecondary
            smallRadius = this@AlbumPickerThemeInternal.smallRadius
            normalRadius = this@AlbumPickerThemeInternal.normalRadius
            bigRadius = this@AlbumPickerThemeInternal.bigRadius
            bigFontSize = this@AlbumPickerThemeInternal.bigFontSize
            normalFontSize = this@AlbumPickerThemeInternal.normalFontSize
            smallFontSize = this@AlbumPickerThemeInternal.smallFontSize
        }
    }
}
