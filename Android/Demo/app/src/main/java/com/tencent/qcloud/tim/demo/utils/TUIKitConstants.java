package com.tencent.qcloud.tim.demo.utils;
public class TUIKitConstants {
    public static final String LOGOUT = "logout";
    public static final String USERINFO = "userInfo";

    /**
     * 1: 仅仅是一个带链接的文本消息
     * 2: iOS支持的视频通话版本，后续已经不兼容
     * 3: 未发布版本
     * 4: Android/iOS/Web互通的视频通话版本
     *
     * 1: Just a text message with a link
     * 2: The video calling version supported by iOS is no longer compatible
     * 3: unreleased version
     * 4: Android/iOS/Web interoperable version for video call
     */
    public static final int JSON_VERSION_UNKNOWN = 0;
    public static final int JSON_VERSION_1 = 1;
    public static final int JSON_VERSION_4 = 4;
    public static int version = JSON_VERSION_4;

    public static final String BUSINESS_ID_CUSTOM_HELLO = "text_link";

    public static class Selection {
        public static final String SELECT_ALL = "select_all";
        public static final String SELECT_FRIENDS = "select_friends";
        public static final String CONTENT = "content";
        public static final String TYPE = "type";
        public static final String TITLE = "title";
        public static final String INIT_CONTENT = "init_content";
        public static final String DEFAULT_SELECT_ITEM_INDEX = "default_select_item_index";
        public static final String LIST = "list";
        public static final String LIMIT = "limit";
        public static final int TYPE_TEXT = 1;
        public static final int TYPE_LIST = 2;
    }

    public static final String RECENT_CALLS_ENABLE_ACTION = "recent_calls_enable_action";
    public static final String RECENT_CALLS_ENABLE = "recent_calls_enable";
    public static final String MINIMALIST_RECENT_CALLS_ENABLE = "minimalist_recent_calls_enable";
}
