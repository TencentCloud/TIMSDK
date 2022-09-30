package com.tencent.qcloud.tuikit.tuicontact;

import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;

public class TUIContactConstants {

    public static final String FORWARD_SELECT_CONVERSATION_KEY = "forward_select_conversation_key";
    public static final int FORWARD_SELECT_MEMBERS_CODE = 102;
    public static final int FORWARD_CREATE_GROUP_CODE = 103;

    public static final String FORWARD_CREATE_NEW_CHAT = "forward_create_new_chat";
    public static final String IM_PRODUCT_DOC_URL = "https://cloud.tencent.com/product/im";
    public static final String IM_PRODUCT_DOC_URL_EN = "https://www.tencentcloud.com/products/im?lang=en&pg=";
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

    public static final class Group {

        public static final String GROUP_ID = "group_id";
    }

    public static class Selection {
        public static final String SELECT_ALL = V2TIMGroupAtInfo.AT_ALL_TAG;
        public static final String SELECT_FRIENDS = "select_friends";
        public static final String SELECT_FOR_CALL = "isSelectForCall";
        public static final String CONTENT = "content";
        public static final String TYPE = "type";
        public static final String TITLE = "title";
        public static final String INIT_CONTENT = "init_content";
        public static final String DEFAULT_SELECT_ITEM_INDEX = "default_select_item_index";
        public static final String LIST = "list";
        public static final String LIMIT = "limit";
        public static final String SELECTED_LIST = "selectedList";

        public static final int TYPE_TEXT = 1;
        public static final int TYPE_LIST = 2;

        public static final String USER_ID_SELECT = "user_id_select";
        public static final String USER_NAMECARD_SELECT = "user_namecard_select";
    }

    public static class ProfileType {
        public static final String CONTENT = "content";
    }

    public static class GroupType {
        public static final String TYPE = "type";
        public static final String GROUP = "isGroup";
        public static final int PRIVATE = 0;
        public static final int PUBLIC = 1;
        public static final int CHAT_ROOM = 2;
        public static final int COMMUNITY = 3;

        public static final String TYPE_PUBLIC = "Public";
    }

}
