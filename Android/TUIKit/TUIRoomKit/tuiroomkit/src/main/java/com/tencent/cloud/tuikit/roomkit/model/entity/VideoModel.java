package com.tencent.cloud.tuikit.roomkit.model.entity;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_CAMERA_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_SCREEN_STATE_CHANGED;

import com.tencent.cloud.tuikit.roomkit.model.RoomConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;

public class VideoModel {
    public int     fps             = RoomConstant.DEFAULT_VIDEO_FPS;
    public int     bitrate         = RoomConstant.DEFAULT_VIDEO_BITRATE;
    public int     resolution      = RoomConstant.DEFAULT_VIDEO_RESOLUTION;
    public boolean isLocalMirror   = RoomConstant.DEFAULT_VIDEO_LOCAL_MIRROR;
    public boolean isFrontCamera   = RoomConstant.DEFAULT_CAMERA_FRONT;

    private boolean isScreenSharing = false;
    private boolean isCameraOpened  = false;

    public boolean isScreenSharing() {
        return isScreenSharing;
    }

    public void setScreenSharing(boolean screenSharing) {
        isScreenSharing = screenSharing;
        RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_SCREEN_STATE_CHANGED, null);
    }

    public boolean isCameraOpened() {
        return isCameraOpened;
    }

    public void setCameraOpened(boolean cameraOpened) {
        isCameraOpened = cameraOpened;
        RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_CAMERA_STATE_CHANGED, null);
    }
}
