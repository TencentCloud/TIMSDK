package com.tencent.qcloud.tuikit.tuicontact.util;

import com.tencent.imsdk.common.IMLog;

public class TUIContactLog extends IMLog {
    private static final String PRE = "TUIContact-";

    private static String mixTag(String tag) {
        return PRE + tag;
    }

    /**
     * Print INFO level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void v(String strTag, String strInfo) {
        IMLog.v(mixTag(strTag), strInfo);
    }

    /**
     * Print DEBUG level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void d(String strTag, String strInfo) {
        IMLog.d(mixTag(strTag), strInfo);
    }

    /**
     * Print INFO level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void i(String strTag, String strInfo) {
        IMLog.i(mixTag(strTag), strInfo);
    }

    /**
     * Print WARN level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void w(String strTag, String strInfo) {
        IMLog.w(mixTag(strTag), strInfo);
    }

    /**
     * Print WARN level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void w(String strTag, String strInfo, Throwable e) {
        IMLog.w(mixTag(strTag), strInfo + e.getMessage());
    }

    /**
     * Print ERROR level log
     *
     * @param strTag  TAG
     * @param strInfo 
     */
    public static void e(String strTag, String strInfo) {
        IMLog.e(mixTag(strTag), strInfo);
    }
}
