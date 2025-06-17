package com.tencent.qcloud.tuikit.tuicallkit.view.component.aisubtitle

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatTextView
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.UserManager
import com.tencent.trtc.TRTCCloudListener
import org.json.JSONObject
import java.util.Timer
import java.util.TimerTask

class AISubtitle(context: Context, attrs: AttributeSet?) : AppCompatTextView(context, attrs) {
    private val messages = mutableListOf<Message>()
    private var hideTimer: Timer? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    data class Message(
        val sender: String,
        val text: String
    )

    private val trtcCloudListener = object : TRTCCloudListener() {
        override fun onRecvCustomCmdMsg(
            userId: String?, cmdID: Int, seq: Int, message: ByteArray?
        ) {
            super.onRecvCustomCmdMsg(userId, cmdID, seq, message)

            if (userId == null || message == null) return

            try {
                val messageString = String(message)

                val jsonObject = JSONObject(messageString)
                val type = jsonObject.optInt("type")

                if (type == AI_MESSAGE_TYPE) {
                    val sender = jsonObject.optString("sender")
                    val payload = jsonObject.optJSONObject("payload")
                    val translationText = payload?.optString("translation_text")

                    if (sender.isNotEmpty() && !translationText.isNullOrEmpty()) {
                        updateSubtitle(sender, translationText)
                    }
                }
            } catch (e: Exception) {
                Logger.e(TAG, "Parse custom message failed: ${e.message}")
            }
        }
    }

    private fun updateSubtitle(sender: String, text: String) {
        messages.add(Message(sender, text))
        if (messages.size > 2) {
            messages.removeAt(0)
        }

        UserManager.instance.getUserDisplayName(
            sender,
            object : TUICommonDefine.ValueCallback<String> {
                override fun onSuccess(data: String?) {
                    val formattedText = messages.joinToString("\n") {
                        "${data}: ${it.text}"
                    }

                    mainHandler.post {
                        setText(formattedText)
                        visibility = VISIBLE

                        hideTimer?.cancel()
                        hideTimer = Timer().apply {
                            schedule(object : TimerTask() {
                                override fun run() {
                                    mainHandler.post {
                                        visibility = GONE
                                    }
                                }
                            }, 2000)
                        }
                    }
                }

                override fun onError(errCode: Int, errMsg: String?) {
                    Logger.e(TAG, "Parse custom message failed: $errMsg")
                }
            })
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

    companion object {
        private const val TAG = "AISubtitle"
        private const val AI_MESSAGE_TYPE = 10000
    }
}