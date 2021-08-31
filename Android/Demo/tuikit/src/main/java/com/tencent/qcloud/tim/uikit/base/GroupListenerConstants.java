package com.tencent.qcloud.tim.uikit.base;

public class GroupListenerConstants {
    public static final String ACTION = "V2TIMGroupNotify";

    public static final String METHOD_ON_MEMBER_ENTER       = "V2TIMGroupNotify_onMemberEnter";
    public static final String METHOD_ON_MEMBER_LEAVE       = "V2TIMGroupNotify_onMemberLeave";
    public static final String METHOD_ON_GROUP_DISMISSED    = "V2TIMGroupNotify_onGroupDismissed";
    public static final String METHOD_ON_GROUP_RECYCLED     = "V2TIMGroupNotify_onGroupRecycled";
    public static final String METHOD_ON_GROUP_INFO_CHANGED = "V2TIMGroupNotify_onGroupInfoChanged";
    public static final String METHOD_ON_REV_CUSTOM_DATA    = "V2TIMGroupNotify_onReceiveRESTCustomData";
    public static final String METHOD_ON_GROUP_ATTRS_CHANGED = "V2TIMGroupNotify_onGroupAttributeChanged";

    public static final String KEY_GROUP_ID    = "groupId";
    public static final String KEY_METHOD      = "method";
    public static final String KEY_OP_USER     = "opUser";
    public static final String KEY_MEMBER      = "member";
    public static final String KEY_CUSTOM_DATA = "customData";
    public static final String KEY_GROUP_ATTR  = "groupAttributeMap";
    public static final String KEY_GROUP_INFO  = "changeInfos";
}
