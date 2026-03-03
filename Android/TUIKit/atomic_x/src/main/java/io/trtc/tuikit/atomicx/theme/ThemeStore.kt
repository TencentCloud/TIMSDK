package io.trtc.tuikit.atomicx.theme

import android.content.Context
import io.trtc.tuikit.atomicx.theme.tokens.ColorTokens
import io.trtc.tuikit.atomicx.theme.tokens.DesignTokenSet
import io.trtc.tuikit.atomicx.theme.utils.ColorAlgorithm
import io.trtc.tuikit.atomicx.theme.utils.ThemePersistUtil
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class Theme(
    val id: String,
    val displayName: String,
    val tokens: DesignTokenSet
) {
    companion object {

        fun lightTheme(context: Context): Theme {
            return Theme(
                id = "light",
                displayName = "Light",
                tokens = DesignTokenSet.defaultLight(context)
            )
        }

        fun darkTheme(context: Context): Theme {
            return Theme(
                id = "dark",
                displayName = "Dark",
                tokens = DesignTokenSet.defaultDark(context)
            )
        }
    }
}

data class ThemeState(
    val currentTheme: Theme
)

class ThemeStore private constructor(context: Context) {
    private val appContext: Context = context.applicationContext
    
    private val _themeState = MutableStateFlow(ThemeState(Theme.darkTheme(appContext)))
    val themeState: StateFlow<ThemeState> = _themeState.asStateFlow()

    private var themePersistUtil: ThemePersistUtil = ThemePersistUtil(appContext)

    init {
        loadPersistedTheme()
    }

    companion object {
        @Volatile
        private var instance: ThemeStore? = null

        fun shared(context: Context): ThemeStore {
            return instance ?: synchronized(this) {
                instance ?: ThemeStore(context.applicationContext).also {
                    instance = it
                }
            }
        }
    }

    fun setTheme(theme: Theme) {
        updateThemeState(theme)
        persistTheme(theme)
    }

    fun setPrimaryColor(hexColor: String) {
        if (!hexColor.matches(Regex("^#[0-9A-Fa-f]{6}$"))) {
            return
        }

        val palette = ColorAlgorithm.generateColorPalette(
            appContext,
            hexColor,
            if (_themeState.value.currentTheme.id == Theme.darkTheme(appContext).id) "dark" else "light"
        )

        val newTokens = if (_themeState.value.currentTheme.id == Theme.darkTheme(appContext).id) {
            ColorTokens.generateDarkTokens(appContext, palette)
        } else {
            ColorTokens.generateLightTokens(appContext, palette)
        }

        val newTheme = _themeState.value.currentTheme.copy(
            tokens = _themeState.value.currentTheme.tokens.copy(color = newTokens)
        )

        updateThemeState(newTheme)
        themePersistUtil.setCustomPrimaryColor(hexColor)
    }

    private fun updateThemeState(theme: Theme) {
        _themeState.value = ThemeState(currentTheme = theme)
    }

    private fun loadPersistedTheme() {
        if (themePersistUtil.getUserHasManuallySetTheme()) {
            themePersistUtil.getCurrentThemeId()?.let { themeId ->
                loadTheme(themeId)
                return
            }
        }

        if (themePersistUtil.getFollowSystemAppearance()) {
            loadThemeBasedOnSystemAppearance()
        }
    }

    private fun persistTheme(theme: Theme) {
        themePersistUtil.setCurrentThemeId(theme.id)
        themePersistUtil.setUserHasManuallySetTheme(true)
        themePersistUtil.setFollowSystemAppearance(false)
    }

    private fun loadTheme(themeId: String) {
        val theme = when (themeId) {
            "light" -> Theme.lightTheme(appContext)
            "dark" -> Theme.darkTheme(appContext)
            else -> Theme.lightTheme(appContext)
        }

        themePersistUtil.getCustomPrimaryColor()?.let { hexColor ->
            val palette = ColorAlgorithm.generateColorPalette(appContext, hexColor, themeId)
            val customTokens = if (themeId == "dark") {
                ColorTokens.generateDarkTokens(appContext, palette)
            } else {
                ColorTokens.generateLightTokens(appContext, palette)
            }
            val customTheme = theme.copy(
                tokens = theme.tokens.copy(color = customTokens)
            )
            updateThemeState(customTheme)
        } ?: run {
            updateThemeState(theme)
        }
    }

    private fun loadThemeBasedOnSystemAppearance() {

    }
}