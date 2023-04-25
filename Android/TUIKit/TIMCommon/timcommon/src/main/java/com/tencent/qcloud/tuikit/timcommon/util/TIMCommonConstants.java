package com.tencent.qcloud.tuikit.timcommon.util;

public class TIMCommonConstants {
    public static final String MESSAGE_REPLY_KEY = "messageReply";
    public static final String MESSAGE_REPLIES_KEY = "messageReplies";
    public static final String MESSAGE_REACT_KEY = "messageReact";
    public static final String MESSAGE_FEATURE_KEY = "messageFeature";
    public static final String CHAT_SETTINGS_SP_NAME = "chat_settings_sp";
    public static final String CHAT_REPLY_GUIDE_SHOW_SP_KEY = "chat_reply_guide_show";

    public static String covert2HTMLString(String original) {
        return "\"<font color=\"#5B6B92\">" + original + "</font>\"";
    }
}
