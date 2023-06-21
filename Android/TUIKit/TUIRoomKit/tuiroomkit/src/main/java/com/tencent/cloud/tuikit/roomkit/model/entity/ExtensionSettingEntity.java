package com.tencent.cloud.tuikit.roomkit.model.entity;

import com.tencent.trtc.TRTCCloudDef;

public class ExtensionSettingEntity {
    public int     videoResolution       = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
    public int     videoFps              = 15;
    public int     videoBitrate          = 700;
    public int     micVolume             = 100;
    public int     playVolume            = 100;
    public boolean isMirror              = true;
    public boolean audioVolumeEvaluation = true;

    public transient boolean recording = false;
}
