package com.tencent.qcloud.uikit.common.component.video.util;

import android.util.Log;

import static com.tencent.qcloud.uikit.BuildConfig.DEBUG;

/**
 * =====================================
 * 作    者: 陈嘉桐
 * 版    本：1.1.4
 * 创建日期：2017/9/7
 * 描    述：
 * =====================================
 */
public class LogUtil {

    private static final String DEFAULT_TAG = "CJT";

    public static void i(String tag, String msg) {
//        if (DEBUG)
        Log.i(tag, msg);
    }

    public static void v(String tag, String msg) {
        if (DEBUG)
            Log.v(tag, msg);
    }

    public static void d(String tag, String msg) {
        if (DEBUG)
            Log.d(tag, msg);
    }

    public static void e(String tag, String msg) {
        if (DEBUG)
            Log.e(tag, msg);
    }

    public static void i(String msg) {
        i(DEFAULT_TAG, msg);
    }

    public static void v(String msg) {
        v(DEFAULT_TAG, msg);
    }

    public static void d(String msg) {
        d(DEFAULT_TAG, msg);
    }

    public static void e(String msg) {
        e(DEFAULT_TAG, msg);
    }
}
