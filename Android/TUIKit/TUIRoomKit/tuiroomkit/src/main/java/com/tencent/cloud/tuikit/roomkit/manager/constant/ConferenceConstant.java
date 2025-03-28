package com.tencent.cloud.tuikit.roomkit.manager.constant;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoQuality.Q_720P;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;

public class ConferenceConstant {
    public static final int     DEFAULT_AUDIO_CAPTURE_VOLUME    = 100;
    public static final int     DEFAULT_AUDIO_PLAY_VOLUME       = 100;
    public static final boolean DEFAULT_AUDIO_VOLUME_EVALUATION = true;

    public static final int                        DEFAULT_VIDEO_FPS          = 15;
    public static final int                        DEFAULT_VIDEO_BITRATE      = 1200;
    public static final TUIRoomDefine.VideoQuality DEFAULT_VIDEO_RESOLUTION   = Q_720P;
    public static final boolean                    DEFAULT_VIDEO_LOCAL_MIRROR = true;

    public static final boolean DEFAULT_CAMERA_FRONT = true;

    public static final int DURATION_FOREVER = 0;


    public static final int USER_NOT_FOUND = -1;

    public static final int VOLUME_CAN_HEARD_MIN_LIMIT    = 10;
    public static final int VOLUME_INDICATOR_SHOW_TIME_MS = 500;


    public static final String KEY_ERROR                      = "KEY_ERROR";
    public static final String KEY_ROOM_RAISE_HAND_TIP_SHOWED = "KEY_ROOM_RAISE_HAND_TIP_SHOWED";
    public static final String KEY_CONFERENCE_ID              = "KEY_CONFERENCE_ID";
}
