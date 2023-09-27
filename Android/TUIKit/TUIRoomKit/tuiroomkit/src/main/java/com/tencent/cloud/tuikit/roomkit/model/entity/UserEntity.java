package com.tencent.cloud.tuikit.roomkit.model.entity;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;

public class UserEntity {
    private String userId;
    private String userName;
    private String avatarUrl;

    private int     userVoiceVolume = 0;
    private boolean hasAudioStream  = false;

    private boolean                       hasVideoStream  = false;
    private TUIRoomDefine.VideoStreamType videoStreamType = TUIRoomDefine.VideoStreamType.CAMERA_STREAM;

    private boolean isOnSeat = false;

    private boolean disableSendingMessage = false;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public int getUserVoiceVolume() {
        return userVoiceVolume;
    }

    public void setUserVoiceVolume(int userVoiceVolume) {
        this.userVoiceVolume = userVoiceVolume;
    }

    public boolean isHasAudioStream() {
        return hasAudioStream;
    }

    public void setHasAudioStream(boolean hasAudioStream) {
        this.hasAudioStream = hasAudioStream;
    }

    public boolean isHasVideoStream() {
        return hasVideoStream;
    }

    public void setHasVideoStream(boolean hasVideoStream) {
        this.hasVideoStream = hasVideoStream;
    }

    public TUIRoomDefine.VideoStreamType getVideoStreamType() {
        return videoStreamType;
    }

    public void setVideoStreamType(TUIRoomDefine.VideoStreamType videoStreamType) {
        this.videoStreamType = videoStreamType;
    }

    public boolean isOnSeat() {
        return isOnSeat;
    }

    public void setOnSeat(boolean onSeat) {
        isOnSeat = onSeat;
    }

    public boolean isDisableSendingMessage() {
        return disableSendingMessage;
    }

    public void setDisableSendingMessage(boolean disableSendingMessage) {
        this.disableSendingMessage = disableSendingMessage;
    }

    public UserEntity copy() {
        UserEntity userEntity = new UserEntity();
        userEntity.setUserId(userId);
        userEntity.setUserName(userName);
        userEntity.setAvatarUrl(avatarUrl);
        userEntity.setUserVoiceVolume(userVoiceVolume);
        userEntity.setHasAudioStream(hasAudioStream);
        userEntity.setHasVideoStream(hasVideoStream);
        userEntity.setVideoStreamType(videoStreamType);
        userEntity.setOnSeat(isOnSeat);
        userEntity.setDisableSendingMessage(disableSendingMessage);
        return userEntity;
    }

    public static UserEntity toUserEntityForCameraStream(TUIRoomDefine.UserInfo userInfo) {
        UserEntity userEntity = new UserEntity();
        userEntity.userId = userInfo.userId;
        userEntity.userName = userInfo.userName;
        userEntity.avatarUrl = userInfo.avatarUrl;
        userEntity.hasAudioStream  = userInfo.hasAudioStream;
        userEntity.hasVideoStream = userInfo.hasVideoStream;
        userEntity.videoStreamType = TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
        return userEntity;
    }

    public static UserEntity toUserEntityForScreenStream(TUIRoomDefine.UserInfo userInfo) {
        UserEntity userEntity = new UserEntity();
        userEntity.userId = userInfo.userId;
        userEntity.userName = userInfo.userName;
        userEntity.avatarUrl = userInfo.avatarUrl;
        userEntity.hasAudioStream  = userInfo.hasAudioStream;
        userEntity.hasVideoStream = userInfo.hasScreenStream;
        userEntity.videoStreamType = TUIRoomDefine.VideoStreamType.SCREEN_STREAM;
        return userEntity;
    }
}
