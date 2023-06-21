package com.tencent.cloud.tuikit.roomkit.model.entity;

public class AudioModel {
    public int     captureVolume;
    public int     playVolume;
    public boolean enableVolumePrompt;
    public boolean isRecording;

    public AudioModel() {
        captureVolume = 100;
        playVolume = 100;
        enableVolumePrompt = true;
        isRecording = false;
    }
}
