package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base;

public class TXRoomInfo {
    public String roomId;
    public String roomName;
    public String ownerId;
    public String ownerName;
    public String streamUrl;
    public String coverUrl;
    public int    memberCount;
    public String ownerAvatar;
    public int    roomStatus;

    @Override
    public String toString() {
        return "TXRoomInfo{" +
                "roomId='" + roomId + '\'' +
                ", roomName='" + roomName + '\'' +
                ", ownerId='" + ownerId + '\'' +
                ", ownerName='" + ownerName + '\'' +
                ", streamUrl='" + streamUrl + '\'' +
                ", coverUrl='" + coverUrl + '\'' +
                ", memberCount=" + memberCount +
                ", ownerAvatar='" + ownerAvatar + '\'' +
                ", roomStatus=" + roomStatus +
                '}';
    }
}
