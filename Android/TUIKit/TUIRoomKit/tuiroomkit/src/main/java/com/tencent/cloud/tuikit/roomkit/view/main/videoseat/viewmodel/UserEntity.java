package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.viewmodel;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view.ConferenceVideoView;

public class UserEntity {
    private int     audioVolume;
    private String  userId;
    private String  userName;
    private String  userAvatar;
    private boolean isSelf;
    private boolean isTalk;
    private boolean isVideoAvailable;
    private boolean isAudioAvailable;
    private boolean isCameraAvailable;
    private boolean isScreenShareAvailable;
    private boolean isVideoPlaying;
    private boolean isSelected;

    private TUIRoomDefine.VideoStreamType videoStreamType = TUIRoomDefine.VideoStreamType.CAMERA_STREAM;

    private ConferenceVideoView mRoomVideoView;
    private TUIRoomDefine.Role  role;

    public boolean isSelf() {
        return isSelf;
    }

    public void setSelf(boolean self) {
        isSelf = self;
    }

    public TUIRoomDefine.Role getRole() {
        return role;
    }

    public void setRole(TUIRoomDefine.Role role) {
        this.role = role;
    }

    public int getAudioVolume() {
        return audioVolume;
    }

    public void setAudioVolume(int audioVolume) {
        this.audioVolume = audioVolume;
    }

    public ConferenceVideoView getRoomVideoView() {
        return mRoomVideoView;
    }

    public void setRoomVideoView(ConferenceVideoView roomVideoView) {
        mRoomVideoView = roomVideoView;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return TextUtils.isEmpty(userName) ? userId : userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserAvatar() {
        return userAvatar;
    }

    public void setUserAvatar(String userAvatar) {
        this.userAvatar = userAvatar;
    }

    public boolean isVideoAvailable() {
        return isVideoAvailable;
    }

    public void setVideoAvailable(boolean videoAvailable) {
        isVideoAvailable = videoAvailable;
    }

    public boolean isAudioAvailable() {
        return isAudioAvailable;
    }

    public void setAudioAvailable(boolean audioAvailable) {
        isAudioAvailable = audioAvailable;
    }

    public void setTalk(boolean talk) {
        isTalk = talk;
    }

    public boolean isTalk() {
        return isTalk;
    }

    public boolean isScreenShareAvailable() {
        return isScreenShareAvailable;
    }

    public void setScreenShareAvailable(boolean available) {
        this.isScreenShareAvailable = available;
    }

    public boolean isCameraAvailable() {
        return isCameraAvailable;
    }

    public void setCameraAvailable(boolean cameraAvailable) {
        isCameraAvailable = cameraAvailable;
    }

    public boolean isVideoPlaying() {
        return isVideoPlaying;
    }

    public void setVideoPlaying(boolean videoPlaying) {
        isVideoPlaying = videoPlaying;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
    }

    public TUIRoomDefine.VideoStreamType getVideoStreamType() {
        return videoStreamType;
    }

    public void setVideoStreamType(TUIRoomDefine.VideoStreamType videoStreamType) {
        this.videoStreamType = videoStreamType;
    }

    public boolean equals(UserEntity userEntity) {
        if (userEntity == null) {
            return false;
        }
        return userEntity.getUserId().equals(userId) && userEntity.getUserName().equals(userName)
                && userEntity.isVideoAvailable() == isVideoAvailable;
    }

    public UserEntity copy() {
        UserEntity copyEntity = new UserEntity();
        copyEntity.setAudioVolume(audioVolume);
        copyEntity.setUserId(userId);
        copyEntity.setUserName(userName);
        copyEntity.setUserAvatar(userAvatar);
        copyEntity.setSelf(isSelf);
        copyEntity.setTalk(isTalk);
        copyEntity.setVideoAvailable(isVideoAvailable);
        copyEntity.setAudioAvailable(isAudioAvailable);
        copyEntity.setCameraAvailable(isCameraAvailable);
        copyEntity.setScreenShareAvailable(isScreenShareAvailable);
        copyEntity.setVideoStreamType(videoStreamType);
        copyEntity.role = role;
        return copyEntity;
    }
}
