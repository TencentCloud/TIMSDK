package com.tencent.qcloud.tuikit.tuicallkit.view.component.aisubtitle

import android.content.Context
import android.graphics.Typeface
import android.os.Handler
import android.os.Looper
import android.text.SpannableString
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.text.style.StyleSpan
import android.util.AttributeSet
import android.widget.ScrollView
import androidx.appcompat.widget.AppCompatTextView
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants.AI_TRANSLATION_ROBOT
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.UserManager
import com.tencent.trtc.TRTCCloudListener
import org.json.JSONObject
import java.util.Timer
import java.util.TimerTask

class AISubtitle(context: Context, attrs: AttributeSet?) : ScrollView(context, attrs) {
    private var hideTimer: Timer? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val translationInfo = mutableListOf<TranslationInfo>()
    private lateinit var textView: AppCompatTextView

    init {
        initView()
    }

    private fun initView() {
        isVerticalScrollBarEnabled = true
        isScrollbarFadingEnabled = false
        textView = AppCompatTextView(context).apply {
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
            setPadding(16, 16, 16, 16)
            textSize = 14f
            setTextColor(0xFFFFFFFF.toInt())
        }
        addView(textView)
    }

    private val trtcCloudListener = object : TRTCCloudListener() {
        override fun onRecvCustomCmdMsg(userId: String?, cmdID: Int, seq: Int, message: ByteArray?) {
            super.onRecvCustomCmdMsg(userId, cmdID, seq, message)
            if (userId == null || message == null) return

            try {
                val messageString = String(message)
                val jsonObject = JSONObject(messageString)
                val type = jsonObject.optInt("type")

                if (type == AI_MESSAGE_TYPE) {
                    val sender = jsonObject.optString("sender")
                    val payload = jsonObject.optJSONObject("payload")
                    val text = payload?.optString("text") ?: ""
                    val translationText = payload?.optString("translation_text") ?: ""
                    val roundId = payload?.optString("roundid") ?: ""
                    val translationLanguage = payload?.optString("translation_language") ?: ""
                    if (roundId.isNotEmpty()) {
                        val index = translationInfo.indexOfFirst { it.roundId == roundId }
                        if (index != -1) {
                            translationInfo[index].sender =
                                if (sender.contains(AI_TRANSLATION_ROBOT)) translationInfo[index].sender else sender
                            translationInfo[index].text = text.ifEmpty {
                                translationInfo[index].text
                            }
                            translationInfo[index].translation[translationLanguage] =
                                (translationText.ifEmpty { translationInfo[index].translation[translationLanguage] }) as String
                        } else {
                            val translationInfoItem = TranslationInfo()
                            translationInfoItem.roundId = roundId
                            translationInfoItem.sender =
                                if (sender.contains(AI_TRANSLATION_ROBOT)) "" else sender
                            translationInfoItem.text = text
                            if (translationLanguage.isNotEmpty()) {
                                translationInfoItem.translation[translationLanguage] = translationText
                            }
                            translationInfo.add(translationInfoItem)
                        }
                        updateView()
                    }
                }
            } catch (e: Exception) {
                Logger.e(TAG, "Parse custom message failed: ${e.message}")
            }
        }
    }

    private fun updateView() {
        val spannableBuilder = SpannableStringBuilder()
        for ((index, message) in translationInfo.withIndex()) {
            val translationText = sortLanguageType(message)
            val displayName = UserManager.instance.getUserDisplayName(message.sender)
            val fullText = "$displayName:\n${message.text}\n$translationText"
            formatAISubtitleText(spannableBuilder, displayName, fullText)
            if (index < translationInfo.size - 1) {
                spannableBuilder.append("\n")
            }
        }
        hideAISubtitleAfterDelay(spannableBuilder)
    }

    private fun sortLanguageType(message: TranslationInfo): StringBuilder {
        val translationText = StringBuilder()
        val languageOrder =
            listOf("zh", "en", "es", "pt", "fr", "de", "ru", "ar", "ja", "ko", "vi", "ms", "id", "it", "th")
        for (language in languageOrder) {
            message.translation[language]?.let { translation ->
                translationText.append("[$language]: $translation\n")
            }
        }
        return translationText
    }

    private fun formatAISubtitleText(
        spannableBuilder: SpannableStringBuilder,
        displayName: String,
        fullText: String
    ) {
        val spannableString = SpannableString(fullText)
        val nameStart = 0
        val nameEnd = displayName.length + 1
        spannableString.setSpan(ForegroundColorSpan(0xFFD9CC66.toInt()),
            nameStart,
            nameEnd,
            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
        )
        spannableString.setSpan(
            StyleSpan(Typeface.BOLD),
            nameStart,
            nameEnd,
            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
        )
        spannableBuilder.append(spannableString)
    }

    private fun hideAISubtitleAfterDelay(textBuilder: SpannableStringBuilder) {
        mainHandler.post {
            textView.text = textBuilder
            visibility = VISIBLE
            post {
                fullScroll(ScrollView.FOCUS_DOWN)
            }
            hideTimer?.cancel()
            hideTimer = Timer().apply {
                schedule(object : TimerTask() {
                    override fun run() {
                        mainHandler.post {
                            visibility = GONE
                        }
                    }
                }, SHOW_DURATION * 1000)
            }
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        CallManager.instance.getTRTCCloudInstance().addListener(trtcCloudListener)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        CallManager.instance.getTRTCCloudInstance().removeListener(trtcCloudListener)
        hideTimer?.cancel()
    }

    private class TranslationInfo {
        var roundId: String = ""
        var sender: String = ""
        var text: String = ""
        var translation: MutableMap<String, String> = mutableMapOf()
    }

    companion object {
        private const val TAG = "AISubtitle"
        private const val AI_MESSAGE_TYPE = 10000
        private const val SHOW_DURATION: Long = 8
    }
}