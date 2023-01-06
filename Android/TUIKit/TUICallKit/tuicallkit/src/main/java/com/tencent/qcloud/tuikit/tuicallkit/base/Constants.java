package com.tencent.qcloud.tuikit.tuicallkit.base;

public class Constants {
    public static final String TUICALLKIT = "TUICallKit";

    public static final int ROOM_ID_MIN = 1;
    public static final int ROOM_ID_MAX = Integer.MAX_VALUE;

    //信令超时时长，默认 30s
    public static int SIGNALING_MAX_TIME = 30;

    public static final int MIN_AUDIO_VOLUME              = 10;
    public static final int MAX_USER                      = 9;
    public static final int MIN_DURATION_SHOW_LOW_QUALITY = 5000; //Minimum interval for displaying poor network

    public static final String EVENT_TUICALLING_CHANGED = "eventTUICallingChanged";

    public static final String EVENT_SUB_CALL_STATUS_CHANGED     = "eventSubCallStatusChanged";
    public static final String EVENT_SUB_CALL_TYPE_CHANGED       = "eventSubMediaTypeChanged";
    public static final String EVENT_SUB_CAMERA_OPEN             = "eventSubCameraOpen";
    public static final String EVENT_SUB_CAMERA_FRONT            = "eventSubCameraFront";
    public static final String EVENT_SUB_MIC_STATUS_CHANGED      = "eventSubMicStatusChanged";
    public static final String EVENT_SUB_AUDIOPLAYDEVICE_CHANGED = "eventSubAudioPlayDeviceChanged";

    public static final String OPEN_CAMERA     = "openCamera";
    public static final String SWITCH_CAMERA   = "switchCamera";
    public static final String MUTE_MIC        = "muteMic";
    public static final String HANDS_FREE      = "handsFree";
    public static final String CALL_STATUS     = "callStatus";
    public static final String CALL_MEDIA_TYPE = "callMediaType";
}
