package com.tencent.cloud.tuikit.roomkit.model.entity;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.LOCAL_SCREEN_SHARE_STATE_CHANGED;

import com.tencent.cloud.tuikit.roomkit.model.RoomConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;

public class VideoModel {
    public int     fps;
    public int     bitrate;
    public int     resolution;
    public boolean isLocalMirror;
    public boolean isFrontCamera;
    public boolean isScreenSharing = false;

    public VideoModel() {
        fps = RoomConstant.DEFAULT_VIDEO_FPS;
        bitrate = RoomConstant.DEFAULT_VIDEO_BITRATE;
        isLocalMirror = RoomConstant.DEFAULT_VIDEO_LOCAL_MIRROR;
        resolution = RoomConstant.DEFAULT_VIDEO_RESOLUTION;
        isFrontCamera = RoomConstant.DEFAULT_CAMERA_FRONT;
    }

    public boolean isScreenSharing() {
        return isScreenSharing;
    }

    public void setScreenSharing(boolean screenSharing) {
        isScreenSharing = screenSharing;
        RoomEventCenter.getInstance().notifyUIEvent(LOCAL_SCREEN_SHARE_STATE_CHANGED, null);
    }
}
