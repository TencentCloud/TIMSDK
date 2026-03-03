package io.trtc.tuikit.atomicx.widget.basicwidget.toast

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.DrawableRes
import com.tencent.imsdk.v2.V2TIMManager
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.theme.ThemeStore
import io.trtc.tuikit.atomicx.theme.tokens.DesignTokenSet
import org.json.JSONObject
import java.lang.ref.WeakReference

private const val ATOMIC_EVENT_ID = 100011
private const val FRAMEWORK_NAME = "AtomicXCore"

object AtomicToast {

    enum class Style {
        TEXT,
        INFO,
        HELP,
        LOADING,
        SUCCESS,
        WARNING,
        ERROR
    }

    enum class Position {
        TOP,
        CENTER,
        BOTTOM
    }

    enum class Duration(val value: Int) {
        SHORT(Toast.LENGTH_SHORT),
        LONG(Toast.LENGTH_LONG)
    }

    private var toastRef: WeakReference<Toast>? = null
    private var layoutRef: WeakReference<View>? = null

    private val mainHandler = Handler(Looper.getMainLooper())
    private var pendingTask: Runnable? = null

    fun show(
        context: Context,
        text: String,
        style: Style = Style.TEXT,
        position: Position = Position.CENTER,
        @DrawableRes customIcon: Int? = null,
        duration: Duration = Duration.SHORT,
        code: Int? = null,
        extensionInfo: Map<String, Any>? = null
    ) {
        if (text.isBlank()) return

        pendingTask?.let {
            mainHandler.removeCallbacks(it)
            pendingTask = null
        }

        val appContext = context.applicationContext

        val task = object : Runnable {
            override fun run() {
                executeRealShow(appContext, text, style, position, customIcon, duration)
                if (code != null) {
                    reportAtomicEvent(code, text, extensionInfo)
                }
                if (pendingTask === this) {
                    pendingTask = null
                }
            }
        }
        pendingTask = task
        mainHandler.postDelayed(task, 50)
    }

    private fun executeRealShow(
        appContext: Context,
        text: String,
        style: Style,
        position: Position,
        @DrawableRes customIcon: Int?,
        duration: Duration,
    ) {
        val themeStore = ThemeStore.shared(appContext)
        val tokens = themeStore.themeState.value.currentTheme.tokens

        var toast = toastRef?.get()
        var layout = layoutRef?.get()

        if (toast == null || layout == null) {
            layout = LayoutInflater.from(appContext).inflate(R.layout.layout_atomic_toast, null)
            toast = Toast(appContext)

            @Suppress("DEPRECATION")
            toast.view = layout

            layoutRef = WeakReference(layout)
            toastRef = WeakReference(toast)
        }

        applyDesignTokens(appContext, layout!!, text, style, customIcon, tokens)

        toast.apply {
            this.duration = duration.value
            val gravity = when (position) {
                Position.TOP -> Gravity.TOP or Gravity.CENTER_HORIZONTAL
                Position.CENTER -> Gravity.CENTER
                Position.BOTTOM -> Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            }
            val yOffset = appContext.resources.getDimension(R.dimen.spacing_20).toInt()
            setGravity(gravity, 0, if (position == Position.CENTER) 0 else yOffset)
            show()
        }
    }

    @SuppressLint("SetTextI18n")
    private fun applyDesignTokens(
        context: Context,
        container: View,
        text: String,
        style: Style,
        @DrawableRes customIcon: Int?,
        tokens: DesignTokenSet
    ) {
        val iconView = container.findViewById<ImageView>(R.id.image_icon)
        val textView = container.findViewById<TextView>(R.id.text_toast)

        val backgroundDrawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = context.resources.getDimension(R.dimen.radius_6)
            setColor(tokens.color.bgColorOperate)
        }

        container.background = backgroundDrawable

        textView.text = text
        textView.setTextColor(tokens.color.textColorPrimary)
        textView.textSize = tokens.font.regular14.size

        iconView.visibility = View.GONE
        val iconRes = customIcon ?: resolveIconRes(style)
        if (iconRes != null) {
            iconView.visibility = View.VISIBLE
            iconView.setImageResource(iconRes)
        }
    }

    @DrawableRes
    private fun resolveIconRes(style: Style): Int? {
        return when (style) {
            Style.INFO -> R.drawable.ic_atomic_toast_info
            Style.HELP -> R.drawable.ic_atomic_toast_help
            Style.SUCCESS -> R.drawable.ic_atomic_toast_success
            Style.WARNING -> R.drawable.ic_atomic_toast_warning
            Style.ERROR -> R.drawable.ic_atomic_toast_error
            Style.LOADING -> R.drawable.ic_atomic_toast_loading
            else -> null
        }
    }

    private fun reportAtomicEvent(code: Int, message: String?, extensionInfo: Map<String, Any>?) {
        val params = JSONObject().apply {
            put("event_id", ATOMIC_EVENT_ID)
            put("event_code", code)
            put("event_message", message)
            put("more_message", FRAMEWORK_NAME)
            put("extension_message", extensionInfo)
        }.toString()
        V2TIMManager.getInstance().callExperimentalAPI("reportRoomEngineEvent", params, null)
    }
}