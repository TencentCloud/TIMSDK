package com.tencent.cloud.tuikit.roomkit.model.entity;

import com.tencent.cloud.tuikit.roomkit.model.RoomConstant;

public class AudioModel {
    public int     captureVolume;
    public int     playVolume;
    public boolean enableVolumeEvaluation;

    public AudioModel() {
        captureVolume = RoomConstant.DEFAULT_AUDIO_CAPTURE_VOLUME;
        playVolume = RoomConstant.DEFAULT_AUDIO_PLAY_VOLUME;
        enableVolumeEvaluation = RoomConstant.DEFAULT_AUDIO_VOLUME_EVALUATION;
    }
}
