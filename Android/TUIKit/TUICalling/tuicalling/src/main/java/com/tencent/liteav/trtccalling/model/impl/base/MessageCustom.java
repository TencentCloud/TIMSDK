package com.tencent.liteav.trtccalling.model.impl.base;

public class MessageCustom {
    public static final String BUSINESS_ID_GROUP_CREATE = "group_create";
    public static final String BUSINESS_ID_AV_CALL = "av_call";

    public int version = 0;
    public String businessID;
    public String opUser;
    public String content;
}
