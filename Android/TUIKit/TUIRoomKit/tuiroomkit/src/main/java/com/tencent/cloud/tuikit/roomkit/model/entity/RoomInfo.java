package com.tencent.cloud.tuikit.roomkit.model.entity;


import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;

public class RoomInfo {
    public String                   name;
    public String                   owner;
    public String                   roomId;
    public boolean                  isOpenCamera;
    public boolean                  isUseSpeaker;
    public boolean                  isOpenMicrophone;
    public boolean                  isCameraDisableForAllUser     = false;
    public boolean                  isMicrophoneDisableForAllUser = false;
    public boolean                  isMessageDisableForAllUser    = false;
    public TUIRoomDefine.SpeechMode speechMode                    = TUIRoomDefine.SpeechMode.FREE_TO_SPEAK;

    @Override
    public String toString() {
        return "RoomInfo{"
                + "name='" + name + '\''
                + ", owner='" + owner + '\''
                + ", roomId='" + roomId + '\''
                + ", isOpenCamera=" + isOpenCamera
                + ", isUseSpeaker=" + isUseSpeaker
                + ", isOpenMicrophone=" + isOpenMicrophone
                + ", isCameraDisableForAllUser=" + isCameraDisableForAllUser
                + ", isMicrophoneDisableForAllUser=" + isMicrophoneDisableForAllUser
                + ", isMessageDisableForAllUser=" + isMessageDisableForAllUser
                + ", speechMode=" + speechMode
                + '}';
    }
}
