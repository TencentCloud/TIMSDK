package com.tencent.qcloud.tuikit.tuisearch;

import com.tencent.imsdk.BaseConstants;

public class TUISearchConstants {
    public static final String SEARCH_LIST_TYPE = "search_list_type";
    public static final String SEARCH_KEY_WORDS = "search_key_words";
    public static final String SEARCH_DATA_BEAN = "search_data_bean";

    public static final int CONVERSATION_TYPE = 1;
    public static final int CONTACT_TYPE = 2;
    public static final int GROUP_TYPE = 3;

    public static final String CHAT_INFO = "chatInfo";
    public static final int JSON_VERSION_4       = 4;
    public static int version = JSON_VERSION_4;
    public static String covert2HTMLString(String original) {
        return "\"<font color=\"#5B6B92\">" + original + "</font>\"";
    }
}
