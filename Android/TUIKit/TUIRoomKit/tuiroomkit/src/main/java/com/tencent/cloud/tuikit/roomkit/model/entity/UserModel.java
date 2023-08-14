package com.tencent.cloud.tuikit.roomkit.model.entity;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.qcloud.tuicore.TUILogin;

public class UserModel {
    public String             userId;
    public String             userName;
    public String             userAvatar;
    public TUIRoomDefine.Role role;
    public boolean            isVideoAvailable;
    public boolean            isAudioAvailable;
    public boolean            isOnSeat;
    public boolean            isMute;

    public UserModel() {
        userId = TUILogin.getUserId();
        userName = TUILogin.getNickName();
        userAvatar = TUILogin.getFaceUrl();
    }
}
