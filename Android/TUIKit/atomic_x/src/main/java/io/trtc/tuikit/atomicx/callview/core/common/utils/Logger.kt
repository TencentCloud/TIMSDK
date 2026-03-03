package io.trtc.tuikit.atomicx.callview.core.common.utils

import android.util.Log
import com.tencent.liteav.base.ContextUtils
import com.tencent.trtc.TRTCCloud
import org.json.JSONException
import org.json.JSONObject

class Logger {
    companion object {
        private const val API = "TuikitLog"
        private const val LOG_KEY_API = "api"
        private const val LOG_KEY_PARAMS = "params"
        private const val LOG_KEY_PARAMS_LEVEL = "level"
        private const val LOG_KEY_PARAMS_MESSAGE = "message"
        private const val LOG_KEY_PARAMS_FILE = "file"
        private const val LOG_KEY_PARAMS_LINE = "line"
        private const val LOG_KEY_PARAMS_MODULE = "module"
        private const val LOG_VALUE_PARAMS_MODULE = "call_view"
        private const val LOG_LEVEL_INFO = 0
        private const val LOG_LEVEL_WARNING = 1
        private const val LOG_LEVEL_ERROR = 2
        private const val LOG_FUNCTION_CALLER_INDEX = 5

        fun i(message: String) {
            log(LOG_LEVEL_INFO, message)
        }

        fun w(message: String) {
            log(LOG_LEVEL_WARNING, message)
        }

        fun e(message: String) {
            log(LOG_LEVEL_ERROR, message)
        }

        private fun log(level: Int, message: String) {
            var context = ContextUtils.getApplicationContext()
            if (context == null) {
                ContextUtils.initContextFromNative("liteav")
                context = ContextUtils.getApplicationContext()
            }
            if (context == null) {
                return
            }
            try {
                val paramsJson = JSONObject()
                paramsJson.put(LOG_KEY_PARAMS_LEVEL, level)
                paramsJson.put(LOG_KEY_PARAMS_MESSAGE, message)
                paramsJson.put(LOG_KEY_PARAMS_MODULE, LOG_VALUE_PARAMS_MODULE)
                paramsJson.put(LOG_KEY_PARAMS_FILE, getCallerFileName())
                paramsJson.put(LOG_KEY_PARAMS_LINE, getCallerLineNumber())

                val loggerJson = JSONObject()
                loggerJson.put(LOG_KEY_API, API)
                loggerJson.put(LOG_KEY_PARAMS, paramsJson)

                TRTCCloud.sharedInstance(context)
                    .callExperimentalAPI(loggerJson.toString())
            } catch (e: JSONException) {
                Log.e("Logger", e.toString())
            }
        }

        private fun getCallerFileName(): String {
            val stackTrace = Thread.currentThread().stackTrace
            if (stackTrace.size < LOG_FUNCTION_CALLER_INDEX + 1) return ""
            return stackTrace[LOG_FUNCTION_CALLER_INDEX].fileName ?: ""
        }

        private fun getCallerLineNumber(): Int {
            val stackTrace = Thread.currentThread().stackTrace
            if (stackTrace.size < LOG_FUNCTION_CALLER_INDEX + 1) return 0
            return stackTrace[LOG_FUNCTION_CALLER_INDEX].lineNumber
        }
    }
}