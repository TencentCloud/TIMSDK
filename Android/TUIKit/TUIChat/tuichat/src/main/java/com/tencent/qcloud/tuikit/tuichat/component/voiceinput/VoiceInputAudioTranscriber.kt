package com.tencent.qcloud.tuikit.tuichat.component.voiceinput

import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMValueCallback
import org.json.JSONObject

class VoiceInputAudioTranscriber {
    fun convert(
        filePath: String,
        language: String = "",
        onFailure: ((Int, String) -> Unit)? = null,
        onCompleted: (String?) -> Unit,
    ) {
        uploadFile(
            filePath = filePath,
            onSuccess = { url ->
                if (url.isBlank()) {
                    completeFailure(onFailure, onCompleted, ERROR_UNKNOWN, "upload url is empty")
                    return@uploadFile
                }
                convertVoiceToText(
                    url = url,
                    language = language,
                    onSuccess = onCompleted,
                    onFailure = { code, desc -> completeFailure(onFailure, onCompleted, code, desc) },
                )
            },
            onFailure = { code, desc -> completeFailure(onFailure, onCompleted, code, desc) },
        )
    }

    private fun uploadFile(
        filePath: String,
        onSuccess: (String) -> Unit,
        onFailure: (Int, String) -> Unit,
    ) {
        callExperimentalApi(API_UPLOAD_FILE, buildUploadFileParams(filePath), onSuccess, onFailure)
    }

    private fun convertVoiceToText(
        url: String,
        language: String,
        onSuccess: (String?) -> Unit,
        onFailure: (Int, String) -> Unit,
    ) {
        callExperimentalApi(API_CONVERT_VOICE_TO_TEXT, buildConvertVoiceToTextParams(url, language), onSuccess, onFailure)
    }

    private fun callExperimentalApi(
        api: String,
        params: String,
        onSuccess: (String) -> Unit,
        onFailure: (Int, String) -> Unit,
    ) {
        try {
            V2TIMManager.getInstance().callExperimentalAPI(
                api,
                params,
                object : V2TIMValueCallback<Any> {
                    override fun onSuccess(result: Any?) {
                        onSuccess(result?.toString().orEmpty())
                    }

                    override fun onError(code: Int, desc: String?) {
                        onFailure(code, desc.orEmpty())
                    }
                },
            )
        } catch (exception: Exception) {
            onFailure(ERROR_UNKNOWN, exception.message.orEmpty())
        }
    }

    private fun completeFailure(
        onFailure: ((Int, String) -> Unit)?,
        onCompleted: (String?) -> Unit,
        code: Int,
        desc: String,
    ) {
        onFailure?.invoke(code, desc)
        onCompleted(null)
    }

    companion object {
        const val API_UPLOAD_FILE = "uploadFile"
        const val API_CONVERT_VOICE_TO_TEXT = "convertVoiceToText"
        private const val KEY_FILE_PATH = "filePath"
        private const val KEY_FILE_TYPE = "fileType"
        private const val KEY_URL = "url"
        private const val KEY_LANGUAGE = "language"
        private const val FILE_TYPE_AUDIO = 3
        private const val ERROR_UNKNOWN = -1

        @JvmStatic
        fun buildUploadFileParams(filePath: String): String {
            return JSONObject()
                .put(KEY_FILE_PATH, filePath)
                .put(KEY_FILE_TYPE, FILE_TYPE_AUDIO)
                .toString()
        }

        @JvmStatic
        fun buildConvertVoiceToTextParams(url: String, language: String): String {
            return JSONObject()
                .put(KEY_URL, url)
                .put(KEY_LANGUAGE, language)
                .toString()
        }
    }
}
