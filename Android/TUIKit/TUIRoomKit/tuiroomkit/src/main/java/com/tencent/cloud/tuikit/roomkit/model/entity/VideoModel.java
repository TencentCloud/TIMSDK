package com.tencent.cloud.tuikit.roomkit.model.entity;

import com.tencent.trtc.TRTCCloudDef;

public class VideoModel {
    public int     fps;
    public int     bitrate;
    public int     resolution;
    public boolean isMirror;
    public boolean isFrontCamera;

    public VideoModel() {
        fps = 15;
        bitrate = 900;
        isMirror = true;
        resolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
        isFrontCamera = true;
    }

}
