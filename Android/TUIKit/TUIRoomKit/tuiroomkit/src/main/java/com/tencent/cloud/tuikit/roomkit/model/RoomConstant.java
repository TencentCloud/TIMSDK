package com.tencent.cloud.tuikit.roomkit.model;

import com.tencent.trtc.TRTCCloudDef;

public class RoomConstant {
    // 默认音频值
    public static final int     DEFAULT_AUDIO_CAPTURE_VOLUME    = 100;
    public static final int     DEFAULT_AUDIO_PLAY_VOLUME       = 100;
    public static final boolean DEFAULT_AUDIO_VOLUME_EVALUATION = true;

    // 默认视频值
    public static final int     DEFAULT_VIDEO_FPS          = 15;
    public static final int     DEFAULT_VIDEO_BITRATE      = 900;
    public static final int     DEFAULT_VIDEO_RESOLUTION   = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
    public static final boolean DEFAULT_VIDEO_LOCAL_MIRROR = true;

    // 默认 Camera 值
    public static final boolean DEFAULT_CAMERA_FRONT = true;

    public static final String KEY_ERROR = "KEY_ERROR";

    public static final int USER_NOT_FOUND = -1;
}
