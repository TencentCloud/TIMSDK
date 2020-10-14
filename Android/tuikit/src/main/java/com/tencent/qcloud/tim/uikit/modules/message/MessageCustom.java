package com.tencent.qcloud.tim.uikit.modules.message;

public class MessageCustom {
    public static final String BUSINESS_ID_GROUP_CREATE = "group_create";
    public static final String BUSINESS_ID_AV_CALL = "av_call";
    public static final String BUSINESS_ID_LIVE_GROUP = "group_live";

    public int version = 0;
    public String businessID;
    public String opUser;
    public String content;
    public String data;
}
