package io.trtc.tuikit.atomicx.theme.utils

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit

class ThemePersistUtil(context: Context) {
    
    private val sharedPreferences: SharedPreferences = 
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    
    companion object {
        private const val PREFS_NAME = "theme_preferences"
        private const val KEY_CURRENT_THEME_ID = "current_theme_id"
        private const val KEY_USER_HAS_MANUALLY_SET_THEME = "user_has_manually_set_theme"
        private const val KEY_FOLLOW_SYSTEM_APPEARANCE = "follow_system_appearance"
        private const val KEY_CUSTOM_PRIMARY_COLOR = "custom_primary_color"
    }

    fun getCurrentThemeId(): String? {
        return sharedPreferences.getString(KEY_CURRENT_THEME_ID, null)
    }

    fun setCurrentThemeId(themeId: String) {
        sharedPreferences.edit {
            putString(KEY_CURRENT_THEME_ID, themeId)
        }
    }

    fun getUserHasManuallySetTheme(): Boolean {
        return sharedPreferences.getBoolean(KEY_USER_HAS_MANUALLY_SET_THEME, false)
    }

    fun setUserHasManuallySetTheme(hasSet: Boolean) {
        sharedPreferences.edit {
            putBoolean(KEY_USER_HAS_MANUALLY_SET_THEME, hasSet)
        }
    }

    fun getFollowSystemAppearance(): Boolean {
        return sharedPreferences.getBoolean(KEY_FOLLOW_SYSTEM_APPEARANCE, true)
    }

    fun setFollowSystemAppearance(follow: Boolean) {
        sharedPreferences.edit {
            putBoolean(KEY_FOLLOW_SYSTEM_APPEARANCE, follow)
        }
    }

    fun getCustomPrimaryColor(): String? {
        return sharedPreferences.getString(KEY_CUSTOM_PRIMARY_COLOR, null)
    }

    fun setCustomPrimaryColor(hexColor: String) {
        sharedPreferences.edit {
            putString(KEY_CUSTOM_PRIMARY_COLOR, hexColor)
        }
    }

    fun clearCustomPrimaryColor() {
        sharedPreferences.edit {
            remove(KEY_CUSTOM_PRIMARY_COLOR)
        }
    }
}