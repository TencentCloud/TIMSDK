package com.tencent.qcloud.tuikit.tuicallkit.base;

import java.util.Objects;

public class CallingUserModel {
    public String  userId;
    public String  userAvatar;
    public String  userName;
    public boolean isEnter;
    public boolean isAudioAvailable;
    public boolean isVideoAvailable;
    public int     volume;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        CallingUserModel model = (CallingUserModel) o;
        return Objects.equals(userId, model.userId);
    }

    @Override
    public String toString() {
        return "CallingUserModel{"
                + "userId='" + userId
                + ", userAvatar='" + userAvatar
                + ", userName='" + userName
                + ", isEnter=" + isEnter
                + ", isAudioAvailable=" + isAudioAvailable
                + ", isVideoAvailable=" + isVideoAvailable
                + ", volume=" + volume
                + '}';
    }
}
