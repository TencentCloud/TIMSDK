package io.trtc.tuikit.atomicx.widget.basicwidget.button

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.PorterDuff
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.core.content.withStyledAttributes
import androidx.core.graphics.drawable.DrawableCompat
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.theme.Theme
import io.trtc.tuikit.atomicx.theme.ThemeStore
import io.trtc.tuikit.atomicx.theme.tokens.DesignTokenSet
import io.trtc.tuikit.atomicx.widget.utils.DisplayUtil
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

enum class ButtonVariant {
    FILLED,
    OUTLINED,
    TEXT
}

enum class ButtonColorType {
    PRIMARY,
    SECONDARY,
    DANGER
}

enum class ButtonIconPosition {
    START,
    END,
    NONE
}

enum class ButtonSize(
    val heightDp: Float,
    val minWidthDp: Float,
    val iconSizeDp: Float,
) {
    XS(24f, 48f, 14f),
    S(32f, 64f, 16f),
    M(40f, 80f, 20f),
    L(48f, 96f, 20f);

    fun getHeightPx(context: Context): Int = DisplayUtil.dp2px(context, heightDp)
    fun getMinWidthPx(context: Context): Int = DisplayUtil.dp2px(context, minWidthDp)
    fun getIconSizePx(context: Context): Int = DisplayUtil.dp2px(context, iconSizeDp)
}

class AtomicButton @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    companion object {
        private const val ICON_PADDING_DP = 4f
    }

    private var lastDesignConfig: ButtonDesignConfig? = null

    private val contentContainer: LinearLayout
    private val iconView: ImageView = ImageView(context).apply {
        visibility = GONE
        scaleType = ImageView.ScaleType.CENTER_INSIDE
    }
    private val textView: TextView = TextView(context).apply {
        gravity = Gravity.CENTER
        includeFontPadding = false
    }

    var variant: ButtonVariant = ButtonVariant.FILLED
        set(value) {
            field = value
            updateAppearance()
        }

    var colorType: ButtonColorType = ButtonColorType.PRIMARY
        set(value) {
            field = value
            updateAppearance()
        }

    var size: ButtonSize = ButtonSize.S
        set(value) {
            field = value
            requestLayout()
            updateAppearance()
        }

    var iconDrawable: Drawable? = null
        set(value) {
            field = value
            updateIcon()
        }

    var iconPosition: ButtonIconPosition = ButtonIconPosition.NONE
        set(value) {
            field = value
            updateIcon()
        }

    var text: CharSequence
        get() = textView.text
        set(value) {
            textView.text = value
        }

    var isBold: Boolean = false
        set(value) {
            field = value
            updateAppearance()
        }

    var customTextSizeSp: Float? = null
        set(value) {
            field = value
            updateAppearance()
        }

    private var buttonScope: CoroutineScope? = null

    init {

        contentContainer = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            addView(iconView)
            addView(textView)
        }

        addView(
            contentContainer, FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }
        )

        isClickable = true
        isFocusable = true

        if (attrs != null) {
            context.withStyledAttributes(
                attrs,
                R.styleable.AtomicButton,
                defStyleAttr,
                0
            ) {
                variant = when (getInt(R.styleable.AtomicButton_buttonVariant, 0)) {
                    1 -> ButtonVariant.OUTLINED
                    2 -> ButtonVariant.TEXT
                    else -> ButtonVariant.FILLED
                }

                colorType = when (getInt(R.styleable.AtomicButton_buttonColorType, 0)) {
                    1 -> ButtonColorType.SECONDARY
                    2 -> ButtonColorType.DANGER
                    else -> ButtonColorType.PRIMARY
                }

                size = when (getInt(R.styleable.AtomicButton_customButtonSize, 1)) {
                    0 -> ButtonSize.XS
                    1 -> ButtonSize.S
                    2 -> ButtonSize.M
                    3 -> ButtonSize.L
                    else -> ButtonSize.S
                }

                iconPosition = when (getInt(R.styleable.AtomicButton_buttonIconPosition, 2)) {
                    0 -> ButtonIconPosition.START
                    1 -> ButtonIconPosition.END
                    else -> ButtonIconPosition.NONE
                }

                iconDrawable = getDrawable(R.styleable.AtomicButton_buttonIcon)

                textView.text = getText(R.styleable.AtomicButton_android_text)

                isBold = getBoolean(R.styleable.AtomicButton_textStyle, false)

                if (hasValue(R.styleable.AtomicButton_buttonTextSize)) {
                    val sizePx = getDimension(R.styleable.AtomicButton_buttonTextSize, 0f)
                    val scaledDensity = resources.displayMetrics.scaledDensity
                    customTextSizeSp = sizePx / scaledDensity
                }
            }
        }

        if (isInEditMode) {
            updateAppearance(Theme.lightTheme(context).tokens)
        }
    }

    override fun setEnabled(enabled: Boolean) {
        super.setEnabled(enabled)
        textView.isEnabled = enabled
        iconView.isEnabled = enabled
        updateAppearance()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        bindTheme()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        buttonScope?.cancel()
        buttonScope = null
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val heightPx = size.getHeightPx(context)
        val minWidthPx = size.getMinWidthPx(context)

        val finalHeightMeasureSpec = MeasureSpec.makeMeasureSpec(heightPx, MeasureSpec.EXACTLY)
        super.onMeasure(widthMeasureSpec, finalHeightMeasureSpec)
        val widthMode = MeasureSpec.getMode(widthMeasureSpec)
        val widthSize = MeasureSpec.getSize(widthMeasureSpec)

        val finalWidth = when (widthMode) {
            MeasureSpec.EXACTLY -> {
                widthSize
            }
            MeasureSpec.AT_MOST -> {
                maxOf(measuredWidth, minWidthPx).coerceAtMost(widthSize)
            }
            MeasureSpec.UNSPECIFIED -> {
                maxOf(measuredWidth, minWidthPx)
            }
            else -> measuredWidth
        }
        setMeasuredDimension(finalWidth, heightPx)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (!isEnabled) {
            return false
        }

        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                isPressed = true
            }
            MotionEvent.ACTION_MOVE -> {
                val isInside = event.x >= 0 && event.x <= width &&
                        event.y >= 0 && event.y <= height
                isPressed = isInside
            }
            MotionEvent.ACTION_UP -> {
                if (isPressed) {
                    isPressed = false
                    performClick()
                }
            }
            MotionEvent.ACTION_CANCEL -> {
                isPressed = false
            }
        }
        return true
    }

    override fun performClick(): Boolean {
        return super.performClick()
    }

    override fun setPressed(pressed: Boolean) {
        val wasPressed = isPressed
        super.setPressed(pressed)

        if (wasPressed != pressed) {
            updateAppearance()
        }
    }

    private fun bindTheme() {
        buttonScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
        buttonScope?.launch {
            ThemeStore.shared(context).themeState.collectLatest {
                updateAppearance(it.currentTheme.tokens)
            }
        }
    }

    private fun getCurrentTokens(): DesignTokenSet {
        return ThemeStore.shared(context).themeState.value.currentTheme.tokens
    }

    private fun updateAppearance(tokens: DesignTokenSet = getCurrentTokens()) {
        val newConfig = getButtonDesignConfig(tokens)

        textView.setTextColor(newConfig.textColor)
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, newConfig.fontSize)
        textView.typeface = if (newConfig.isBold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT

        if (shouldRecreateBackground(newConfig, lastDesignConfig)) {
            background = createBackgroundDrawable(tokens, newConfig)
        } else {
            updateExistingBackground(newConfig)
        }

        updateIcon(newConfig.textColor)
        lastDesignConfig = newConfig
    }

    private fun shouldRecreateBackground(
        newConfig: ButtonDesignConfig,
        oldConfig: ButtonDesignConfig?,
    ): Boolean {
        if (oldConfig == null) return true

        if (newConfig.cornerRadiusDp != oldConfig.cornerRadiusDp ||
            newConfig.borderWidth != oldConfig.borderWidth
        ) {
            return true
        }
        if ((newConfig.borderWidth == 0f && oldConfig.borderWidth != 0f) ||
            (newConfig.borderWidth != 0f && oldConfig.borderWidth == 0f)
        ) {
            return true
        }

        return false
    }

    private fun updateExistingBackground(newConfig: ButtonDesignConfig) {
        val currentBackground = background

        if (currentBackground is GradientDrawable) {
            currentBackground.setColor(newConfig.backgroundColor)
            currentBackground.setStroke(
                DisplayUtil.dp2px(context, newConfig.borderWidth),
                newConfig.borderColor
            )
        }
    }

    private fun updateIcon(@ColorInt tintColor: Int = textView.currentTextColor) {
        val icon = iconDrawable
        val iconSizeDp = size.iconSizeDp
        val iconSizePx = DisplayUtil.dp2px(context, iconSizeDp)
        val iconPadding = DisplayUtil.dp2px(context, ICON_PADDING_DP)

        if (icon == null || iconPosition == ButtonIconPosition.NONE) {
            iconView.visibility = View.GONE
            return
        }

        iconView.visibility = View.VISIBLE

        val wrappedIcon = DrawableCompat.wrap(icon.mutate())
        DrawableCompat.setTint(wrappedIcon, tintColor)
        DrawableCompat.setTintMode(wrappedIcon, PorterDuff.Mode.SRC_IN)

        iconView.setImageDrawable(wrappedIcon)

        val iconLayoutParams = iconView.layoutParams as? LinearLayout.LayoutParams
            ?: LinearLayout.LayoutParams(iconSizePx, iconSizePx)

        iconLayoutParams.width = iconSizePx
        iconLayoutParams.height = iconSizePx

        when (iconPosition) {
            ButtonIconPosition.START -> {
                iconLayoutParams.setMargins(0, 0, iconPadding, 0)
                contentContainer.removeAllViews()
                contentContainer.addView(iconView)
                contentContainer.addView(textView)
            }

            ButtonIconPosition.END -> {
                iconLayoutParams.setMargins(iconPadding, 0, 0, 0)
                contentContainer.removeAllViews()
                contentContainer.addView(textView)
                contentContainer.addView(iconView)
            }

            ButtonIconPosition.NONE -> {
                iconView.visibility = View.GONE
            }
        }

        iconView.layoutParams = iconLayoutParams
    }

    private data class ButtonDesignConfig(
        @ColorInt val backgroundColor: Int,
        @ColorInt val borderColor: Int,
        @ColorInt val textColor: Int,
        val borderWidth: Float,
        val cornerRadiusDp: Float,
        val fontSize: Float,
        val isBold: Boolean,
    )

    private fun getButtonDesignConfig(
        tokens: DesignTokenSet,
        forcePressed: Boolean = false
    ): ButtonDesignConfig {
        val colors = tokens.color
        val font = tokens.font

        val isEnabledState = isEnabled
        val isPressedState = forcePressed || isPressed

        val primaryColorTokens = when (colorType) {
            ButtonColorType.PRIMARY -> Triple(
                colors.buttonColorPrimaryDefault,
                colors.buttonColorPrimaryActive,
                colors.buttonColorPrimaryDisabled
            )

            ButtonColorType.SECONDARY -> Triple(
                colors.buttonColorSecondaryDefault,
                colors.buttonColorSecondaryActive,
                colors.buttonColorSecondaryDisabled
            )

            ButtonColorType.DANGER -> Triple(
                colors.buttonColorHangupDefault,
                colors.buttonColorHangupActive,
                colors.buttonColorHangupDisabled
            )
        }

        val textColors = when (colorType) {
            ButtonColorType.PRIMARY -> Triple(
                colors.textColorLink,
                colors.textColorLinkActive,
                colors.textColorLinkDisabled
            )

            ButtonColorType.SECONDARY -> Triple(
                colors.textColorPrimary,
                colors.textColorSecondary,
                colors.textColorDisable
            )

            ButtonColorType.DANGER -> Triple(
                colors.buttonColorHangupDefault,
                colors.buttonColorHangupActive,
                colors.buttonColorHangupDisabled
            )
        }

        @ColorInt val defaultPrimaryColor = primaryColorTokens.first
        @ColorInt val activePrimaryColor = primaryColorTokens.second
        @ColorInt val disabledPrimaryColor = primaryColorTokens.third

        @ColorInt val defaultTextColor = textColors.first
        @ColorInt val activeTextColor = textColors.second
        @ColorInt val disabledTextColor = textColors.third

        @ColorInt var finalBg: Int
        @ColorInt var finalBorder: Int
        @ColorInt var finalText: Int
        val borderWidth: Float

        if (!isEnabledState) {
            finalText = when (variant) {
                ButtonVariant.FILLED -> colors.textColorButtonDisabled
                ButtonVariant.OUTLINED, ButtonVariant.TEXT -> disabledTextColor
            }

            val primaryDisabledColor = disabledPrimaryColor

            when (variant) {
                ButtonVariant.FILLED -> {
                    finalBg = primaryDisabledColor
                    finalBorder = primaryDisabledColor
                }

                ButtonVariant.OUTLINED -> {
                    finalBg = Color.TRANSPARENT
                    finalBorder = primaryDisabledColor
                }

                ButtonVariant.TEXT -> {
                    finalBg = Color.TRANSPARENT
                    finalBorder = Color.TRANSPARENT
                }
            }

            borderWidth = if (variant == ButtonVariant.OUTLINED) 1f else 0f
        } else {
            val currentPrimaryColor =
                if (isPressedState) activePrimaryColor else defaultPrimaryColor
            val currentTextColor = if (isPressedState) activeTextColor else defaultTextColor

            when (variant) {
                ButtonVariant.FILLED -> {
                    finalBg = currentPrimaryColor
                    finalBorder = currentPrimaryColor
                    finalText = colors.textColorButton
                    borderWidth = 0f
                }

                ButtonVariant.OUTLINED -> {
                    finalBg = Color.TRANSPARENT
                    finalBorder = currentPrimaryColor
                    finalText = when (colorType) {
                        ButtonColorType.SECONDARY -> {
                            colors.textColorButton
                        }
                        ButtonColorType.PRIMARY,
                        ButtonColorType.DANGER -> {
                            currentPrimaryColor
                        }
                    }
                    borderWidth = 1f
                }

                ButtonVariant.TEXT -> {
                    finalBg = Color.TRANSPARENT
                    finalBorder = Color.TRANSPARENT
                    finalText = currentTextColor
                    borderWidth = 0f
                }
            }
        }

        val defaultFontSize = when (size) {
            ButtonSize.XS -> font.bold12.size
            ButtonSize.S -> font.bold14.size
            ButtonSize.M -> font.bold16.size
            ButtonSize.L -> font.bold16.size
        }

        val finalFontSize = customTextSizeSp ?: defaultFontSize

        val finalCornerRadiusDp = 9999f

        return ButtonDesignConfig(
            backgroundColor = finalBg,
            borderColor = finalBorder,
            textColor = finalText,
            borderWidth = borderWidth,
            cornerRadiusDp = finalCornerRadiusDp,
            fontSize = finalFontSize,
            isBold = isBold
        )
    }

    private fun createBackgroundDrawable(
        tokens: DesignTokenSet,
        config: ButtonDesignConfig,
    ): Drawable {
        val cornerRadiusPx = DisplayUtil.dp2px(context, config.cornerRadiusDp).toFloat()
        val borderWidthPx = DisplayUtil.dp2px(context, config.borderWidth)

        val backgroundDrawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = cornerRadiusPx
            setColor(config.backgroundColor)
            setStroke(borderWidthPx, config.borderColor)
        }

        return backgroundDrawable
    }
}