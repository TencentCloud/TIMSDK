package io.trtc.tuikit.atomicx.widget.basicwidget.label

import android.content.Context
import android.content.res.TypedArray
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.Size
import android.util.TypedValue
import android.view.Gravity
import androidx.annotation.ColorInt
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.withStyledAttributes
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.theme.Theme
import io.trtc.tuikit.atomicx.theme.ThemeStore
import io.trtc.tuikit.atomicx.theme.tokens.ColorTokens
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class AtomicLabel @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : AppCompatTextView(context, attrs, defStyleAttr) {

    data class LabelAppearance(
        @ColorInt val textColor: Int,
        @ColorInt val backgroundColor: Int,
        val textSize: Float,
        val textWeight: Int,
        val cornerRadius: Float
    ) {
        companion object {
            fun defaultAppearance(theme: Theme): LabelAppearance {
                val defaultFont = theme.tokens.font.regular14
                return LabelAppearance(
                    textColor = theme.tokens.color.textColorPrimary,
                    backgroundColor = Color.TRANSPARENT,
                    textSize = defaultFont.size,
                    textWeight = defaultFont.weight,
                    cornerRadius = 0f
                )
            }
        }
    }

    data class IconConfiguration(
        val drawable: Drawable?,
        val position: Position = Position.LEFT,
        val spacing: Float = 4f,
        val size: Size? = null
    ) {
        enum class Position { LEFT, RIGHT }
    }

    fun interface AppearanceProvider {
        fun provide(theme: Theme): LabelAppearance
    }

    var iconConfiguration: IconConfiguration? = null
        set(value) {
            field = value
            applyIconConfiguration()
        }

    private var appearanceProvider: AppearanceProvider? = null
    private val themeBackgroundDrawable by lazy { GradientDrawable() }
    private var isBackgroundManaged = false
    private var cornerRadiusOverride: Float? = null
    private var textColorTokenKey: String? = null
    private var backgroundColorTokenKey: String? = null
    private var backgroundColorStatic: Int? = null
    private var viewScope: CoroutineScope? = null

    init {
        if (gravity == 0) {
            gravity = Gravity.CENTER_VERTICAL
        }

        parseAttributes(attrs)
        applyStaticFallback()
    }

    fun setAppearanceProvider(provider: AppearanceProvider) {
        this.appearanceProvider = provider
        if (isAttachedToWindow) {
            refreshAppearance()
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        startThemeObservation()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        stopThemeObservation()
    }

    private fun startThemeObservation() {
        if (viewScope != null) return

        viewScope = CoroutineScope(Dispatchers.Main.immediate + SupervisorJob())
        viewScope?.launch {
            ThemeStore.shared(context).themeState.collect { state ->
                applyTheme(state.currentTheme)
            }
        }
    }

    private fun stopThemeObservation() {
        viewScope?.cancel()
        viewScope = null
    }

    private fun refreshAppearance() {
        val currentTheme = ThemeStore.shared(context).themeState.value.currentTheme
        applyTheme(currentTheme)
    }

    private fun applyTheme(theme: Theme) {
        val provider = appearanceProvider

        if (provider != null) {
            val appearance = provider.provide(theme)
            applyAppearance(appearance)
        } else {
            applyAtomicProperties(theme)
        }
    }

    private fun applyAppearance(appearance: LabelAppearance) {
        setTextColor(appearance.textColor)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, appearance.textSize)
        applyTypeface(appearance.textWeight)
        updateBackgroundState(appearance.backgroundColor, appearance.cornerRadius)
    }

    private fun applyAtomicProperties(theme: Theme) {
        textColorTokenKey?.let { key ->
            val color = theme.tokens.color[key]
            if (color != 0) {
                setTextColor(color)
            }
        }

        val bgColor = when {
            backgroundColorTokenKey != null -> theme.tokens.color[backgroundColorTokenKey!!]
            backgroundColorStatic != null -> backgroundColorStatic!!
            else -> null
        }

        if (bgColor != null) {
            updateBackgroundState(bgColor, cornerRadiusOverride ?: 0f)
        }
    }

    private fun updateBackgroundState(@ColorInt color: Int, radius: Float) {
        if (background != themeBackgroundDrawable) {
            background = themeBackgroundDrawable
            isBackgroundManaged = true
        }

        themeBackgroundDrawable.setColor(color)
        themeBackgroundDrawable.cornerRadius = radius
    }

    private fun applyTypeface(weight: Int) {
        val targetStyle = if (weight == Typeface.BOLD) Typeface.BOLD else Typeface.NORMAL
        if (typeface == null || typeface.style != targetStyle) {
            setTypeface(Typeface.create(Typeface.DEFAULT, targetStyle))
        }
    }

    private fun applyStaticFallback() {
        if (backgroundColorStatic != null && backgroundColorTokenKey == null) {
            updateBackgroundState(backgroundColorStatic!!, cornerRadiusOverride ?: 0f)
        }
    }

    private fun parseAttributes(attrs: AttributeSet?) {
        textColorTokenKey = ColorTokens.parseColorAttribute(
            attrs = attrs,
            attrId = android.R.attr.textColor,
            attrName = "textColor"
        )

        context.withStyledAttributes(attrs, R.styleable.AtomicLabel) {
            if (hasValue(R.styleable.AtomicLabel_labelCornerRadius)) {
                cornerRadiusOverride = getDimension(R.styleable.AtomicLabel_labelCornerRadius, 0f)
            }

            if (hasValue(R.styleable.AtomicLabel_labelBackgroundColor)) {
                val (tokenKey, staticColor) = parseColorTokenAttributeWithFallback(
                    R.styleable.AtomicLabel_labelBackgroundColor
                )
                backgroundColorTokenKey = tokenKey
                backgroundColorStatic = staticColor
            }
        }
    }

    private fun TypedArray.parseColorTokenAttributeWithFallback(index: Int): Pair<String?, Int?> {
        val resourceId = getResourceId(index, -1)
        if (resourceId != -1) {
            val tokenKey = ColorTokens.getTokenKeyFromColorResId(resourceId)
            if (tokenKey != null) {
                return Pair(tokenKey, null)
            }
        }
        return Pair(null, getColor(index, 0))
    }

    private fun applyIconConfiguration() {
        val config = iconConfiguration

        if (config?.drawable == null) {
            setCompoundDrawablesRelative(null, null, null, null)
            return
        }

        val drawable = config.drawable.mutate()
        val width = config.size?.width ?: drawable.intrinsicWidth
        val height = config.size?.height ?: drawable.intrinsicHeight

        drawable.setBounds(0, 0, width, height)
        compoundDrawablePadding = config.spacing.toInt()

        if (config.position == IconConfiguration.Position.LEFT) {
            setCompoundDrawablesRelative(drawable, null, null, null)
        } else {
            setCompoundDrawablesRelative(null, null, drawable, null)
        }
    }
}