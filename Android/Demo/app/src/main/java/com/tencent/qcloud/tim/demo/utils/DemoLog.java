package com.tencent.qcloud.tim.demo.utils;

import com.tencent.imsdk.common.IMLog;

public class DemoLog extends IMLog {
    private static final String PRE = "TUIKitDemo-";

    private static String mixTag(String tag) {
        return PRE + tag;
    }

    /**
     * INFO LEVEL
     *
     * @param strTag  TAG
     * @param strInfo content
     */
    public static void v(String strTag, String strInfo) {
        IMLog.v(mixTag(strTag), strInfo);
    }

    /**
     * DEBUG LEVEL
     *
     * @param strTag  TAG
     * @param strInfo content
     */
    public static void d(String strTag, String strInfo) {
        IMLog.d(mixTag(strTag), strInfo);
    }

    /**
     * INFO LEVEL
     *
     * @param strTag  TAG
     * @param strInfo content
     */
    public static void i(String strTag, String strInfo) {
        IMLog.i(mixTag(strTag), strInfo);
    }

    /**
     * WARN LEVEL
     *
     * @param strTag  TAG
     * @param strInfo content
     */
    public static void w(String strTag, String strInfo) {
        IMLog.w(mixTag(strTag), strInfo);
    }

    /**
     * ERROR LEVEL
     *
     * @param strTag  TAG
     * @param strInfo content
     */
    public static void e(String strTag, String strInfo) {
        IMLog.e(mixTag(strTag), strInfo);
    }
}
