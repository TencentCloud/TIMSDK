package com.tencent.qcloud.tuikit.tuiconversation;

public class TUIConversationConstants {
    public static final String FORWARD_SELECT_CONVERSATION_KEY = "forward_select_conversation_key";
    public static final int FORWARD_SELECT_ACTIVTY_CODE = 101;
    public static final int FORWARD_SELECT_MEMBERS_CODE = 102;
    public static final int FORWARD_CREATE_GROUP_CODE = 103;
    public static final String FORWARD_CREATE_NEW_CHAT = "forward_create_new_chat";

    public static String covert2HTMLString(String original) {
        return "\"<font color=\"#5B6B92\">" + original + "</font>\"";
    }

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
    public static final int JSON_VERSION_1       = 1;
    public static final int JSON_VERSION_4       = 4;
    public static int version = JSON_VERSION_4;

    public static class GroupType {
        public static final String TYPE = "type";
        public static final String GROUP = "isGroup";
        public static final int PRIVATE = 0;
        public static final int PUBLIC = 1;
        public static final int CHAT_ROOM = 2;
        public static final int COMMUNITY = 3;
    }

    public static final String CONVERSATION_SETTINGS_SP_NAME = "conversation_settings_sp";
    public static final String HIDE_FOLD_ITEM_SP_KEY_PREFIX = "hide_fold_item_";
    public static final String FOLD_ITEM_IS_UNREAD_SP_KEY_PREFIX = "fold_item_is_unread_";

}
