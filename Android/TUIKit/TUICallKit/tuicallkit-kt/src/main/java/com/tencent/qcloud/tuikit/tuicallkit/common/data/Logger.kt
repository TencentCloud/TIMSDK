package com.tencent.qcloud.tuikit.tuicallkit.common.data

import com.tencent.trtc.TRTCCloud
import com.trtc.tuikit.common.system.ContextProvider
import org.json.JSONException
import org.json.JSONObject

object Logger {
    private const val API = "TuikitLog"
    private const val LOG_KEY_API = "api"
    private const val LOG_KEY_PARAMS = "params"
    private const val LOG_KEY_PARAMS_LEVEL = "level"
    private const val LOG_KEY_PARAMS_MESSAGE = "message"
    private const val LOG_KEY_PARAMS_FILE = "file"
    private const val LOG_KEY_PARAMS_MODULE = "module"
    private const val LOG_KEY_PARAMS_LINE = "line"
    private const val LOG_KEY_PARAMS_FILE_VALUE = "Logger"
    private const val LOG_KEY_PARAMS_MODULE_VALUE = "TUICallKit"
    private const val LOG_KEY_PARAMS_LINE_VALUE = 0
    private const val LOG_LEVEL_INFO = 0
    private const val LOG_LEVEL_WARNING = 1
    private const val LOG_LEVEL_ERROR = 2

    fun e(tag: String, message: String) {
        error(tag, message, LOG_KEY_PARAMS_MODULE_VALUE, LOG_KEY_PARAMS_FILE_VALUE, LOG_KEY_PARAMS_LINE_VALUE)
    }

    fun w(tag: String, message: String) {
        warn(tag, message, LOG_KEY_PARAMS_MODULE_VALUE, LOG_KEY_PARAMS_FILE_VALUE, LOG_KEY_PARAMS_LINE_VALUE)
    }

    fun i(tag: String, message: String) {
        info(tag, message, LOG_KEY_PARAMS_MODULE_VALUE, LOG_KEY_PARAMS_FILE_VALUE, LOG_KEY_PARAMS_LINE_VALUE)
    }

    private fun error(tag: String, message: String, module: String, file: String, line: Int) {
        log(tag, message, LOG_LEVEL_ERROR, module, file, line)
    }

    private fun warn(tag: String, message: String, module: String, file: String, line: Int) {
        log(tag, message, LOG_LEVEL_WARNING, module, file, line)
    }

    private fun info(tag: String, message: String, module: String, file: String, line: Int) {
        log(tag, message, LOG_LEVEL_INFO, module, file, line)
    }

    private fun log(tag: String, message: String, level: Int, module: String, file: String, line: Int) {
        val builder = StringBuilder().apply { append(tag).append(", ").append(message) }
        try {
            val paramsJson = JSONObject()
            paramsJson.put(LOG_KEY_PARAMS_LEVEL, level)
            paramsJson.put(LOG_KEY_PARAMS_MESSAGE, builder.toString())
            paramsJson.put(LOG_KEY_PARAMS_MODULE, module)
            paramsJson.put(LOG_KEY_PARAMS_FILE, file)
            paramsJson.put(LOG_KEY_PARAMS_LINE, line)

            val loggerJson = JSONObject()
            loggerJson.put(LOG_KEY_API, API)
            loggerJson.put(LOG_KEY_PARAMS, paramsJson)

            TRTCCloud.sharedInstance(ContextProvider.getApplicationContext())
                .callExperimentalAPI(loggerJson.toString())
        } catch (e: JSONException) {
            throw RuntimeException(e)
        }
    }
}
