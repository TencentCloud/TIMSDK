package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.util

import com.tencent.imsdk.common.IMLog

object TUIOfficialAccountLog {
    private const val PRE = "TUIOfficialAccountLog-"

    private fun mixTag(tag: String): String {
        return PRE + tag
    }

    fun v(strTag: String, strInfo: String) {
        IMLog.v(mixTag(strTag), strInfo)
    }

    fun d(strTag: String, strInfo: String) {
        IMLog.d(mixTag(strTag), strInfo)
    }

    fun i(strTag: String, strInfo: String) {
        IMLog.i(mixTag(strTag), strInfo)
    }

    fun w(strTag: String, strInfo: String) {
        IMLog.w(mixTag(strTag), strInfo)
    }

    fun w(strTag: String, strInfo: String, e: Throwable) {
        IMLog.w(mixTag(strTag), strInfo + e.message)
    }

    fun e(strTag: String, strInfo: String) {
        IMLog.e(mixTag(strTag), strInfo)
    }
}