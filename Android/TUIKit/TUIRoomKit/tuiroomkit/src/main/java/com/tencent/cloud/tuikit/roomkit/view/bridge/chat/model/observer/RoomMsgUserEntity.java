package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer;

public class RoomMsgUserEntity {
    private String userId;
    private String nickName;
    private String faceUrl;

    public RoomMsgUserEntity(String userId, String nickName, String faceUrl) {
        setUserId(userId);
        setNickName(nickName);
        setFaceUrl(faceUrl);
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getFaceUrl() {
        return faceUrl;
    }

    public void setFaceUrl(String faceUrl) {
        this.faceUrl = faceUrl;
    }
}
