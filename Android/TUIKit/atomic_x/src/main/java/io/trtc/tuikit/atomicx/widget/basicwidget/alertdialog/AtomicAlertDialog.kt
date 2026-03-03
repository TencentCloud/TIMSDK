package io.trtc.tuikit.atomicx.widget.basicwidget.alertdialog

import android.app.Dialog
import android.content.Context
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.core.view.setPadding
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.theme.ThemeStore
import io.trtc.tuikit.atomicx.theme.tokens.ColorTokens
import io.trtc.tuikit.atomicx.theme.tokens.DesignTokenSet
import io.trtc.tuikit.atomicx.widget.basicwidget.popover.AtomicPopover
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import kotlinx.coroutines.Job
import android.graphics.Color

class AtomicAlertDialog(
    private val context: Context,
    private val gravity: AtomicPopover.PanelGravity = AtomicPopover.PanelGravity.CENTER,
) {
    private val DIVIDER_THICKNESS_PX = 1

    private lateinit var rootLayout: LinearLayout
    private lateinit var config: DialogConfig
    private var atomicPopover: AtomicPopover? = null
    private var dialogScope: CoroutineScope? = null
    private var countdownJob: Job? = null
    private var cancelButtonView: TextView? = null
    private var originalCancelText: String = ""

    enum class TextColorPreset {
        PRIMARY, GREY, BLUE, RED
    }

    data class DialogConfig(
        var title: String = "",
        var content: String? = null,
        var iconView: View? = null,
        var autoDismiss: Boolean = false,
        var countdownDuration: Long = 0,
        var confirmConfig: ButtonConfig? = null,
        var cancelConfig: ButtonConfig? = null,
        val itemList: MutableList<ButtonConfig> = mutableListOf(),
    )

    class ButtonConfig(
        var text: String,
        var type: TextColorPreset,
        var onClick: ((Dialog) -> Unit)?,
        var isBold: Boolean,
    )

    fun init(block: DialogConfig.() -> Unit) {
        config = DialogConfig().apply(block)
        val tokens = getCurrentTokens(context)
        rootLayout = createRootLayout(tokens)
        renderDialogContent(rootLayout, config, null, tokens)
    }

    fun show(): Dialog {
        atomicPopover?.dismiss()
        dialogScope?.cancel()
        countdownJob?.cancel()
        dialogScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

        val panel = AtomicPopover(context, gravity)

        atomicPopover = panel.apply {
            setContent(rootLayout)
            setCancelable(config.autoDismiss)
            setCanceledOnTouchOutside(config.autoDismiss)
            setOnDismissListener {
                atomicPopover = null
                countdownJob?.cancel()
            }
        }

        dialogScope?.launch {
            ThemeStore.shared(context).themeState.collectLatest {
                if (panel.isShowing) {
                    val newTokens = getCurrentTokens(context)
                    updateDialogTheme(rootLayout, config, panel, newTokens)
                }
            }
        }

        atomicPopover?.show()
        
        if (config.countdownDuration > 0 && cancelButtonView != null) {
            startCountdown(config.countdownDuration)
        }
        
        return atomicPopover!!
    }

    fun dismiss() {
        dialogScope?.cancel()
        dialogScope = null
        countdownJob?.cancel()
        countdownJob = null
        atomicPopover?.dismiss()
        atomicPopover = null
    }

    fun isShowing(): Boolean {
        return atomicPopover?.isShowing == true
    }

    private fun getCurrentTokens(context: Context): DesignTokenSet {
        return ThemeStore.shared(context).themeState.value.currentTheme.tokens
    }

    private fun createRootLayout(tokens: DesignTokenSet): LinearLayout {
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
        }
    }

    private fun renderDialogContent(
        root: LinearLayout,
        config: DialogConfig,
        dialog: Dialog?,
        tokens: DesignTokenSet,
    ) {
        root.removeAllViews()
        renderHeaderSection(root, config, tokens)
        renderBottomSection(root, config, dialog, tokens)
    }

    private fun updateDialogTheme(
        root: LinearLayout,
        config: DialogConfig,
        dialog: Dialog,
        tokens: DesignTokenSet,
    ) {
        root.removeAllViews()
        renderDialogContent(root, config, dialog, tokens)
    }

    private fun renderHeaderSection(
        root: LinearLayout,
        config: DialogConfig,
        tokens: DesignTokenSet,
    ) {
        val headerContainer = createHeaderContainer()
        root.addView(headerContainer)
        val titleWrapper = createTitleWrapper()
        headerContainer.addView(titleWrapper)
        renderIconIfPresent(titleWrapper, config)
        renderTitleText(titleWrapper, config, tokens)
        renderMessageContentIfPresent(headerContainer, config, tokens)
    }

    private fun createHeaderContainer(): LinearLayout {
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            val paddingPx = context.resources.getDimensionPixelSize(R.dimen.spacing_24)
            setPadding(paddingPx, paddingPx, paddingPx, paddingPx)
        }
    }

    private fun createTitleWrapper(): LinearLayout {
        return LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
    }

    private fun renderIconIfPresent(
        parent: ViewGroup,
        config: DialogConfig,
    ) {
        val iconView = config.iconView
        if (iconView != null) {
            val size = context.resources.getDimensionPixelSize(R.dimen.spacing_20)
            iconView.layoutParams = LinearLayout.LayoutParams(size, size).apply {
                marginEnd = context.resources.getDimensionPixelSize(R.dimen.spacing_8)
            }
            (iconView.parent as? ViewGroup)?.removeView(iconView)
            parent.addView(iconView)
        }
    }

    private fun renderTitleText(parent: ViewGroup, config: DialogConfig, tokens: DesignTokenSet) {
        val finalColor = tokens.color.textColorPrimary
        val finalSize = tokens.font.bold16.size
        val tvTitle = TextView(context).apply {
            text = config.title
            textSize = finalSize
            typeface = Typeface.DEFAULT
            setTextColor(finalColor)
            gravity = Gravity.CENTER
        }
        parent.addView(tvTitle)
    }

    private fun renderMessageContentIfPresent(
        parent: ViewGroup,
        config: DialogConfig,
        tokens: DesignTokenSet,
    ) {
        if (!config.content.isNullOrEmpty()) {
            val finalColor = tokens.color.textColorSecondary
            val finalSize = tokens.font.bold16.size
            val tvContent = TextView(context).apply {
                text = config.content
                textSize = finalSize
                setTextColor(finalColor)
                gravity = Gravity.CENTER
                val topPaddingPx = context.resources.getDimensionPixelSize(R.dimen.spacing_16)
                setPadding(0, topPaddingPx, 0, 0)
            }
            parent.addView(tvContent)
        }
    }

    private fun renderBottomSection(
        root: LinearLayout,
        config: DialogConfig,
        dialog: Dialog?,
        tokens: DesignTokenSet,
    ) {
        if (config.itemList.isNotEmpty()) {
            renderVerticalListMode(root, config, dialog, tokens)
        } else if (config.confirmConfig != null || config.cancelConfig != null) {
            renderStandardButtonMode(root, config, dialog, tokens)
        }
    }

    private fun renderVerticalListMode(
        root: LinearLayout,
        config: DialogConfig,
        dialog: Dialog?,
        tokens: DesignTokenSet,
    ) {
        if (config.itemList.isNotEmpty()) {
            addHorizontalDivider(root, tokens.color)
        }
        config.itemList.forEachIndexed { index, itemConfig ->
            if (index > 0) addHorizontalDivider(root, tokens.color)
            val isLastItem = index == config.itemList.lastIndex
            val itemBtn = createButtonView(
                itemConfig,
                tokens,
                isBottomLeftRounded = isLastItem && gravity == AtomicPopover.PanelGravity.CENTER,
                isBottomRightRounded = isLastItem && gravity == AtomicPopover.PanelGravity.CENTER
            )
            val heightPx = context.resources.getDimensionPixelSize(R.dimen.spacing_56)
            itemBtn.layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                heightPx
            )
            itemBtn.setOnClickListener {
                itemConfig.onClick?.invoke(dialog!!)
                dialog?.dismiss()
            }
            root.addView(itemBtn)
        }
    }

    private fun renderStandardButtonMode(
        root: LinearLayout,
        config: DialogConfig,
        dialog: Dialog?,
        tokens: DesignTokenSet,
    ) {
        addHorizontalDivider(root, tokens.color)

        val heightPx = context.resources.getDimensionPixelSize(R.dimen.spacing_56)
        val buttonContainer = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                heightPx
            )
        }
        root.addView(buttonContainer)

        val hasCancel = config.cancelConfig != null
        val hasConfirm = config.confirmConfig != null
        val isCenterGravity = gravity == AtomicPopover.PanelGravity.CENTER

        config.cancelConfig?.let { btnConfig ->
            val isOnlyCancel = !hasConfirm
            originalCancelText = btnConfig.text
            val displayText = if (config.countdownDuration > 0) {
                "$originalCancelText (${config.countdownDuration})"
            } else {
                btnConfig.text
            }
            val displayConfig = ButtonConfig(displayText, btnConfig.type, btnConfig.onClick, btnConfig.isBold)
            val btnView = createButtonView(
                displayConfig,
                tokens,
                isBottomLeftRounded = isCenterGravity,
                isBottomRightRounded = isOnlyCancel && isCenterGravity
            )
            cancelButtonView = btnView
            btnView.setOnClickListener {
                btnConfig.onClick?.invoke(dialog ?: return@setOnClickListener)
                dialog?.dismiss()
            }
            buttonContainer.addView(
                btnView,
                LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f)
            )
        }

        if (hasCancel && hasConfirm) {
            addVerticalDivider(buttonContainer, tokens.color)
        }

        config.confirmConfig?.let { btnConfig ->
            val isOnlyConfirm = !hasCancel
            val btnView = createButtonView(
                btnConfig,
                tokens,
                isBottomLeftRounded = isOnlyConfirm && isCenterGravity,
                isBottomRightRounded = isCenterGravity
            )
            btnView.setOnClickListener {
                btnConfig.onClick?.invoke(dialog ?: return@setOnClickListener)
                dialog?.dismiss()
            }
            buttonContainer.addView(
                btnView,
                LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f)
            )
        }
    }

    private fun addHorizontalDivider(root: ViewGroup, colorTokens: ColorTokens) {
        val view = View(context).apply {
            layoutParams =
                LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, DIVIDER_THICKNESS_PX)
            setBackgroundColor(colorTokens.strokeColorSecondary)
        }
        root.addView(view)
    }

    private fun addVerticalDivider(root: ViewGroup, colorTokens: ColorTokens) {
        val view = View(context).apply {
            layoutParams =
                LinearLayout.LayoutParams(DIVIDER_THICKNESS_PX, ViewGroup.LayoutParams.MATCH_PARENT)
            setBackgroundColor(colorTokens.strokeColorSecondary)
        }
        root.addView(view)
    }

    private fun createButtonView(
        config: ButtonConfig,
        tokens: DesignTokenSet,
        isBottomLeftRounded: Boolean = false,
        isBottomRightRounded: Boolean = false,
    ): TextView {
        val finalSize = tokens.font.bold16.size
        val buttonView = TextView(context).apply {
            text = config.text
            textSize = finalSize
            gravity = Gravity.CENTER
            val finalColor = resolveButtonTextColor(config.type, tokens.color)
            setTextColor(finalColor)
            typeface = if (config.isBold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
        }

        buttonView.setBackgroundColor(Color.TRANSPARENT)

        if (isBottomLeftRounded || isBottomRightRounded) {
            val cornerRadiusPx = context.resources.getDimension(R.dimen.radius_20)
            val br = if (isBottomRightRounded) cornerRadiusPx else 0f
            val bl = if (isBottomLeftRounded) cornerRadiusPx else 0f

            val radii = floatArrayOf(
                0f, 0f,
                0f, 0f,
                br, br,
                bl, bl
            )

            val drawable = GradientDrawable().apply {
                setColor(Color.TRANSPARENT)
                cornerRadii = radii
            }
            buttonView.background = drawable
        }

        return buttonView
    }

    @ColorInt
    private fun resolveButtonTextColor(type: TextColorPreset, colorTokens: ColorTokens): Int {
        return when (type) {
            TextColorPreset.RED -> colorTokens.textColorError
            TextColorPreset.BLUE -> colorTokens.textColorLink
            TextColorPreset.PRIMARY -> colorTokens.textColorPrimary
            TextColorPreset.GREY -> colorTokens.textColorSecondary
        }
    }

    private fun startCountdown(durationSeconds: Long) {
        countdownJob?.cancel()
        countdownJob = dialogScope?.launch {
            var remaining = durationSeconds
            while (remaining >= 1 && atomicPopover?.isShowing == true) {
                cancelButtonView?.text = "$originalCancelText ($remaining)"
                delay(1000)
                remaining--
            }
            if (atomicPopover?.isShowing == true) {
                atomicPopover?.dismiss()
            }
        }
    }
}

fun AtomicAlertDialog.DialogConfig.init(
    title: String,
    content: String? = null,
    iconView: View? = null,
    autoDismiss: Boolean = false,
) {
    this.title = title
    this.content = content
    this.iconView = iconView
    this.autoDismiss = autoDismiss
}

fun AtomicAlertDialog.DialogConfig.addItem(
    text: String,
    type: AtomicAlertDialog.TextColorPreset = AtomicAlertDialog.TextColorPreset.GREY,
    isBold: Boolean = false,
    onClick: ((Dialog) -> Unit)? = null,
) {
    val config = AtomicAlertDialog.ButtonConfig(text, type, onClick, isBold)
    itemList.add(config)
}

fun AtomicAlertDialog.DialogConfig.items(
    items: List<Pair<String, AtomicAlertDialog.TextColorPreset>>,
    isBold: Boolean = false,
    onClick: (Dialog, Int, String) -> Unit,
) {
    items.forEachIndexed { index, (text, type) ->
        addItem(text, type, isBold) { dialog -> onClick(dialog, index, text) }
    }
}

fun AtomicAlertDialog.DialogConfig.confirmButton(
    text: String,
    type: AtomicAlertDialog.TextColorPreset = AtomicAlertDialog.TextColorPreset.BLUE,
    isBold: Boolean = false,
    onClick: ((Dialog) -> Unit)? = null,
) {
    this.confirmConfig = AtomicAlertDialog.ButtonConfig(text, type, onClick, isBold)
}

fun AtomicAlertDialog.DialogConfig.cancelButton(
    text: String,
    type: AtomicAlertDialog.TextColorPreset = AtomicAlertDialog.TextColorPreset.GREY,
    isBold: Boolean = false,
    onClick: ((Dialog) -> Unit)? = null,
) {
    this.cancelConfig = AtomicAlertDialog.ButtonConfig(text, type, onClick, isBold)
}