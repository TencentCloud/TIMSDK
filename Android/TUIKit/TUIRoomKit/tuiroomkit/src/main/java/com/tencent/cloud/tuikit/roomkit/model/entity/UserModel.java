package com.tencent.cloud.tuikit.roomkit.model.entity;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;

public class UserModel {
    public String             userId;
    public String             userName;
    public String             userAvatar;
    public TUIRoomDefine.Role role;
    public boolean            isOpenCamera;
    public boolean            isOpenSpeaker;
    public boolean            isOpenMicrophone;
    public boolean            isVideoAvailable;
    public boolean            isAudioAvailable;
    public boolean            isOnSeat;
    public boolean            isMute;

}
