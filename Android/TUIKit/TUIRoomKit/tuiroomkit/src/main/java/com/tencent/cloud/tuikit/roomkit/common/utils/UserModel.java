package com.tencent.cloud.tuikit.roomkit.common.utils;

import java.io.Serializable;

public class UserModel implements Serializable {
    public String   phone;
    public String   email;
    public String   userId;
    public int      appId;
    public String   userSig;
    public String   userName;
    public String   userAvatar;
    public UserType userType = UserType.NONE;

    public enum UserType {
        NONE,
        ROOM,
        CALLING,
        CHAT_SALON,
        VOICE_ROOM,
        LIVE_ROOM,
        CHORUS,
        KARAOKE
    }
}
