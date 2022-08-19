package com.tencent.qcloud.tuikit.tuichat.util;

import com.tencent.imsdk.common.IMLog;

public class TUIChatLog extends IMLog {

    private static final String PRE = "TUIChat-";

    private static String mixTag(String tag) {
        return PRE + tag;
    }

    /**
     * 打印INFO级别日志
     * 
     * print INFO level log
     *
     * @param strTag  TAG
     * @param strInfo 消息
     */
    public static void v(String strTag, String strInfo) {
        IMLog.v(mixTag(strTag), strInfo);
    }

    /**
     * 打印DEBUG级别日志
     * 
     * print DEBUG level log
     *
     * @param strTag  TAG
     * @param strInfo 消息
     */
    public static void d(String strTag, String strInfo) {
        IMLog.d(mixTag(strTag), strInfo);
    }

    /**
     * 打印INFO级别日志
     * 
     * print INFO level log
     *
     * @param strTag  TAG
     * @param strInfo 消息
     */
    public static void i(String strTag, String strInfo) {
        IMLog.i(mixTag(strTag), strInfo);
    }

    /**
     * 打印WARN级别日志
     * 
     * print WARN level log
     *
     * @param strTag  TAG
     * @param strInfo 消息
     */
    public static void w(String strTag, String strInfo) {
        IMLog.w(mixTag(strTag), strInfo);
    }

    /**
     * 打印WARN级别日志
     * 
     * print WARN level log
     *
     * @param strTag  TAG
     * @param strInfo 消息
     */
    public static void w(String strTag, String strInfo, Throwable e) {
        IMLog.w(mixTag(strTag), strInfo + e.getMessage());
    }

    /**
     * 打印ERROR级别日志
     * 
     * print ERROR level log
     *
     * @param strTag  TAG
     * @param strInfo 消息
     */
    public static void e(String strTag, String strInfo) {
        IMLog.e(mixTag(strTag), strInfo);
    }

}
