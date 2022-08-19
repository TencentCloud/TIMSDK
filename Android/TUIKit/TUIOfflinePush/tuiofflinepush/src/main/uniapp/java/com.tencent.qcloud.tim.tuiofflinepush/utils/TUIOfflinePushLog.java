package com.tencent.qcloud.tim.tuiofflinepush.utils;

import android.util.Log;

public class TUIOfflinePushLog{

    private static final String PRE = "TUIOfflinePush-";

    private static String mixTag(String tag) {
        return PRE + tag;
    }

    /**
     * 打印INFO级别日志
     *  @param strTag  TAG
     * @param strInfo 消息
     * @return
     */
    public static int v(String strTag, String strInfo) {
        Log.v(mixTag(strTag), strInfo);
        return 0;
    }

    /**
     * 打印DEBUG级别日志
     *  @param strTag  TAG
     * @param strInfo 消息
     * @return
     */
    public static int d(String strTag, String strInfo) {
        Log.d(mixTag(strTag), strInfo);
        return 0;
    }

    /**
     * 打印INFO级别日志
     *  @param strTag  TAG
     * @param strInfo 消息
     * @return
     */
    public static int i(String strTag, String strInfo) {
        Log.i(mixTag(strTag), strInfo);
        return 0;
    }

    /**
     * 打印WARN级别日志
     *  @param strTag  TAG
     * @param strInfo 消息
     * @return
     */
    public static int w(String strTag, String strInfo) {
        Log.w(mixTag(strTag), strInfo);
        return 0;
    }

    /**
     * 打印ERROR级别日志
     *  @param strTag  TAG
     * @param strInfo 消息
     * @return
     */
    public static int e(String strTag, String strInfo) {
        Log.e(mixTag(strTag), strInfo);
        return 0;
    }

}
