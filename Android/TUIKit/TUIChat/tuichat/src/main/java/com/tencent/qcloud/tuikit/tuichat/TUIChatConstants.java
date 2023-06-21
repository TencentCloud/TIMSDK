package com.tencent.qcloud.tuikit.tuichat;

import com.tencent.imsdk.BaseConstants;

public class TUIChatConstants {
    public static final String CAMERA_IMAGE_PATH = "camera_image_path";
    public static final String IMAGE_WIDTH = "image_width";
    public static final String IMAGE_HEIGHT = "image_height";
    public static final String VIDEO_TIME = "video_time";
    public static final String CAMERA_VIDEO_PATH = "camera_video_path";
    public static final String IMAGE_PREVIEW_PATH = "image_preview_path";
    public static final String IS_ORIGIN_IMAGE = "is_origin_image";
    public static final String CAMERA_TYPE = "camera_type";

    public static final String BUSINESS_ID_CUSTOM_HELLO = "text_link";
    public static final String BUSINESS_ID_CUSTOM_EVALUATION = "evaluation";
    public static final String BUSINESS_ID_CUSTOM_ORDER = "order";
    public static final String BUSINESS_ID_CUSTOM_TYPING = "user_typing_status";
    public static final String BUSINESS_ID_QUICK_TAP = "quick_tap";

    public static final int PLUGIN_NORMAL_MESSAGE = 1;
    public static final int PLUGIN_TIPS_MESSAGE = 2;

    public static final String FORWARD_SELECT_CONVERSATION_KEY = "forward_select_conversation_key";
    public static final int FORWARD_SELECT_ACTIVTY_CODE = 101;
    public static final String FORWARD_MERGE_MESSAGE_KEY = "forward_merge_message_key";

    public static final int GET_MESSAGE_FORWARD = 0;
    public static final int GET_MESSAGE_BACKWARD = 1;
    public static final int GET_MESSAGE_TWO_WAY = 2;
    public static final int GET_MESSAGE_LOCATE = 3;

    public static final String CHAT_INFO = "chatInfo";

    public static final String MESSAGE_BEAN = "messageBean";
    public static final String DATA_CHANGE_TYPE = "dataChangeType";

    public static final String OPEN_MESSAGE_SCAN = "open_message_scan";
    public static final String OPEN_MESSAGES_SCAN_FORWARD = "open_messages_scan_forward";

    public static final String FORWARD_MODE = "forward_mode"; // 0,onebyone;  1,merge;
    public static final int FORWARD_MODE_ONE_BY_ONE = 0;
    public static final int FORWARD_MODE_MERGE = 1;

    public static final String SELECT_FRIENDS = "select_friends";
    public static final String GROUP_ID = "group_id";
    public static final String SELECT_FOR_CALL = "isSelectForCall";

    public static final int TYPING_SEND_MESSAGE_INTERVAL = 4;
    public static final int TYPING_PARSE_MESSAGE_INTERVAL = 5;
    public static final int TYPING_TRIGGER_CHAT_TIME = 30; // second

    public static final String EVENT_KEY_MESSAGE_STATUS_CHANGED = "eventKeyMessageStatusChanged";
    public static final String EVENT_SUB_KEY_MESSAGE_SEND = "eventSubKeyMessageSend";

    public static final String EVENT_KEY_OFFLINE_MESSAGE_PRIVATE_RING = "eventKeyOfflineMessagePrivteRing";
    public static final String EVENT_SUB_KEY_OFFLINE_MESSAGE_PRIVATE_RING = "eventSubKeyOfflineMessagePrivteRing";
    public static final String OFFLINE_MESSAGE_PRIVATE_RING = "offlineMessagePrivateRing";

    public static final int ERR_SDK_INTERFACE_NOT_SUPPORT = BaseConstants.ERR_SDK_INTERFACE_NOT_SUPPORT;
    public static final String BUYING_GUIDELINES_EN = "https://intl.cloud.tencent.com/document/product/1047/36021?lang=en&pg=#changing-configuration";
    public static final String BUYING_GUIDELINES = "https://cloud.tencent.com/document/product/269/32458";

    /**
     * 1: 仅仅是一个带链接的文本消息
     * 2: iOS支持的视频通话版本，后续已经不兼容
     * 3: 未发布版本
     * 4: Android/iOS/Web互通的视频通话版本
     *
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

    public static String covert2HTMLString(String original) {
        return "\"<font color=\"#5B6B92\">" + original + "</font>\"";
    }

    public static final class Group {
        public static final String GROUP_ID = "group_id";
        public static final String GROUP_INFO = "groupInfo";
        public static final String MEMBER_APPLY = "apply";
    }

    public static class Selection {
        public static final String SELECT_ALL = "select_all";
        public static final String LIMIT = "limit";
        public static final String TITLE = "title";

        public static final String USER_ID_SELECT = "user_id_select";
        public static final String USER_NAMECARD_SELECT = "user_namecard_select";
    }

    public static class DataStore {
        public static final String DATA_STORE_NAME = "tuichat_datastore";
    }
}
