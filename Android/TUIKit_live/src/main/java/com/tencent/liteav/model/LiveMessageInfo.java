package com.tencent.liteav.model;

import com.tencent.qcloud.tim.uikit.modules.message.MessageCustom;

public class LiveMessageInfo {
    public static final String BUSINESS_ID_LIVE_GROUP = "group_live";
    public int version;
    public int roomId;
    /**
     * 0：stop
     * 1：start
     */
    public int roomStatus;
    public String roomName;
    /**
     * 封面图
     */
    public String roomCover;
    public String roomType;

    public String anchorId;
    public String anchorName;

    public String businessID = BUSINESS_ID_LIVE_GROUP;

    public static LiveMessageInfo createLiveMessageInfo() {
        LiveMessageInfo liveMessageInfo = new LiveMessageInfo();
        liveMessageInfo.version = 1;
        liveMessageInfo.roomId = 12345;
        liveMessageInfo.roomName = "borry的直播";
        liveMessageInfo.roomType = "liveRoom";
        liveMessageInfo.roomCover = "";
        liveMessageInfo.roomStatus = 1;
        liveMessageInfo.anchorId = "123456";
        liveMessageInfo.anchorName = "borry8842";
        return liveMessageInfo;
    }

    @Override
    public String toString() {
        return "LiveMessageInfo{" +
                "version=" + version +
                ", roomId=" + roomId +
                ", roomStatus=" + roomStatus +
                ", roomName='" + roomName + '\'' +
                ", roomCover='" + roomCover + '\'' +
                ", roomType='" + roomType + '\'' +
                ", anchorId='" + anchorId + '\'' +
                ", anchorName='" + anchorName + '\'' +
                ", businessID='" + businessID + '\'' +
                '}';
    }
}
