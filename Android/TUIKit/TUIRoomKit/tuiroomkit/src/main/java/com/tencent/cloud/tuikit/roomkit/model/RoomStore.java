package com.tencent.cloud.tuikit.roomkit.model;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.model.entity.AudioModel;
import com.tencent.cloud.tuikit.roomkit.model.entity.LoginInfo;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.entity.VideoModel;

public class RoomStore {
    public LoginInfo            loginInfo;
    public RoomInfo             roomInfo;
    public UserModel            userModel;
    public AudioModel           audioModel;
    public VideoModel           videoModel;
    public TUIRoomKit.RoomScene roomScene;

    public RoomStore() {
        loginInfo = new LoginInfo();
        roomInfo = new RoomInfo();
        userModel = new UserModel();
        audioModel = new AudioModel();
        videoModel = new VideoModel();
        roomScene = TUIRoomKit.RoomScene.MEETING;
    }

    public void initialCurrentUser() {
        TUIRoomDefine.LoginUserInfo userInfo = TUIRoomEngine.getSelfInfo();
        userModel.userId = userInfo.userId;
        userModel.userName = userInfo.userName;
        userModel.userAvatar = userInfo.avatarUrl;
    }
}
