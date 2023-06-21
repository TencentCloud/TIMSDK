package com.tencent.qcloud.tuikit.tuigroup;

public class TUIGroupConstants {
    public static final class ActivityRequest {
        public static final int CODE_1 = 1;
    }

    public static final class Group {
        public static final int MODIFY_GROUP_NAME = 0X01;
        public static final int MODIFY_GROUP_NOTICE = 0X02;
        public static final int MODIFY_GROUP_JOIN_TYPE = 0X03;
        public static final int MODIFY_GROUP_INVITE_TYPE = 0X04;
        public static final int MODIFY_MEMBER_NAME = 0X11;

        public static final String GROUP_ID = "group_id";
        public static final String GROUP_INFO = "groupInfo";
        public static final String MEMBER_APPLY = "apply";
    }

    public static class Selection {
        public static final String SELECT_FRIENDS = "select_friends";
        public static final String SELECT_FOR_CALL = "isSelectForCall";
        public static final String IS_SELECT_MODE = "isSelectMode";

        public static final String CONTENT = "content";
        public static final String TYPE = "type";
        public static final String TITLE = "title";
        public static final String LIST = "list";
        public static final String LIMIT = "limit";
        public static final String EXCLUDE_LIST = "excludeList";
        public static final String SELECTED_LIST = "selectedList";
        public static final String FILTER = "filter";
    }

    public static final String GROUP_FACE_URL = "https://im.sdk.qcloud.com/download/tuikit-resource/group-avatar/group_avatar_%s.png";
    public static final int GROUP_FACE_COUNT = 24;
}
