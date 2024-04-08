package com.tencent.qcloud.tuikit.timcommon.util;

import com.tencent.imsdk.common.IMLog;

public class TIMCommonLog extends IMLog {
    private static final String PRE = "TIMCommon-";

    private static String mixTag(String tag) {
        return PRE + tag;
    }

    /**
     *
     * print INFO level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void v(String strTag, String strInfo) {
        IMLog.v(mixTag(strTag), strInfo);
    }

    /**
     *
     * print DEBUG level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void d(String strTag, String strInfo) {
        IMLog.d(mixTag(strTag), strInfo);
    }

    /**
     *
     * print INFO level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void i(String strTag, String strInfo) {
        IMLog.i(mixTag(strTag), strInfo);
    }

    /**
     *
     * print WARN level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void w(String strTag, String strInfo) {
        IMLog.w(mixTag(strTag), strInfo);
    }

    /**
     *
     * print WARN level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void w(String strTag, String strInfo, Throwable e) {
        IMLog.w(mixTag(strTag), strInfo + e.getMessage());
    }

    /**
     *
     * print ERROR level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void e(String strTag, String strInfo) {
        IMLog.e(mixTag(strTag), strInfo);
    }
}
