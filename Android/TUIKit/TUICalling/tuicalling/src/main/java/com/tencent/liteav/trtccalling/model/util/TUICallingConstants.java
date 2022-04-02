package com.tencent.liteav.trtccalling.model.util;

public class TUICallingConstants {

    public static final String METHOD_NAME_CALL              = "call";
    public static final String METHOD_NAME_RECEIVEAPNSCALLED = "receiveAPNSCalled";

    public static final String PARAM_NAME_TYPE        = "type";
    public static final String PARAM_NAME_ROLE        = "role";
    public static final String PARAM_NAME_USERIDS     = "userIDs";
    public static final String PARAM_NAME_GROUPID     = "groupId";
    public static final String PARAM_NAME_SPONSORID   = "sponsorID";
    public static final String PARAM_NAME_ISFROMGROUP = "isFromGroup";
    public static final String PARAM_NAME_FLOATWINDOW = "enableFloatWindow";

    public static final String KEY_CALL_TYPE    = "call_type";
    public static final String KEY_GROUP_ID     = "group_id";
    public static final String KEY_INVITED_LIST = "invited_list";
    public static final String KEY_CALL_ID      = "call_id";
    public static final String KEY_ROOM_ID      = "room_id";

    public static final String TYPE_AUDIO = "audio";
    public static final String TYPE_VIDEO = "video";

    public static final String EVENT_KEY_CALLING   = "calling";
    public static final String EVENT_KEY_NAME      = "event_name";
    public static final String EVENT_ACTIVE_HANGUP = "active_hangup";

    //onCallEvent常用类型定义
    public static final String EVENT_CALL_HANG_UP         = "Hangup";
    public static final String EVENT_CALL_LINE_BUSY       = "LineBusy";
    public static final String EVENT_CALL_CNACEL          = "Cancel";
    public static final String EVENT_CALL_TIMEOUT         = "Timeout";
    public static final String EVENT_CALL_NO_RESP         = "NoResp";
    public static final String EVENT_CALL_SWITCH_TO_AUDIO = "SwitchToAudio";

    public static final int TC_TUICALLING_COMPONENT = 3;
    public static final int TC_TIMCALLING_COMPONENT = 10;
    public static final int TC_TRTC_FRAMEWORK       = 1;

    public static int component = TC_TUICALLING_COMPONENT;
}
