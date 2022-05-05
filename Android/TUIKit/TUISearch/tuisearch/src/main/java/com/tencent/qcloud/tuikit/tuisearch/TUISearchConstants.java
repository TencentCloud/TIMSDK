package com.tencent.qcloud.tuikit.tuisearch;

import com.tencent.imsdk.BaseConstants;

public class TUISearchConstants {
    public static final String SEARCH_LIST_TYPE = "search_list_type";
    public static final String SEARCH_KEY_WORDS = "search_key_words";
    public static final String SEARCH_DATA_BEAN = "search_data_bean";

    public static final String CHAT_INFO = "chatInfo";
    public static final int JSON_VERSION_4       = 4;
    public static int version = JSON_VERSION_4;
    public static String covert2HTMLString(String original) {
        return "\"<font color=\"#5B6B92\">" + original + "</font>\"";
    }

    public static final int ERR_SDK_INTERFACE_NOT_SUPPORT = BaseConstants.ERR_SDK_INTERFACE_NOT_SUPPORT;
    public static final String BUYING_GUIDELINES_EN = "https://intl.cloud.tencent.com/document/product/1047/36021?lang=en&pg=#changing-configuration";
    public static final String BUYING_GUIDELINES = "https://cloud.tencent.com/document/product/269/32458";
}
