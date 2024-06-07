package com.tencent.cloud.tuikit.roomkit.model.entity;

import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_CAPTURE_VOLUME_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_PLAY_VOLUME_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_ROUTE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_VOLUME_EVALUATION_CHANGED;

import com.tencent.cloud.tuikit.roomkit.model.ConferenceConstant;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;

public class AudioModel {
    private int     captureVolume          = ConferenceConstant.DEFAULT_AUDIO_CAPTURE_VOLUME;
    private int     playVolume             = ConferenceConstant.DEFAULT_AUDIO_PLAY_VOLUME;
    private boolean enableVolumeEvaluation = ConferenceConstant.DEFAULT_AUDIO_VOLUME_EVALUATION;

    private boolean hasAudioStream   = false;
    private boolean isMicOpen        = false;
    private boolean isSoundOnSpeaker = false;

    public int getCaptureVolume() {
        return captureVolume;
    }

    public void setCaptureVolume(int captureVolume) {
        this.captureVolume = captureVolume;
        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_AUDIO_CAPTURE_VOLUME_CHANGED, null);
    }

    public int getPlayVolume() {
        return playVolume;
    }

    public void setPlayVolume(int playVolume) {
        this.playVolume = playVolume;
        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_AUDIO_PLAY_VOLUME_CHANGED, null);
    }

    public boolean isEnableVolumeEvaluation() {
        return enableVolumeEvaluation;
    }

    public void setEnableVolumeEvaluation(boolean enableVolumeEvaluation) {
        this.enableVolumeEvaluation = enableVolumeEvaluation;
        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_AUDIO_VOLUME_EVALUATION_CHANGED, null);
    }

    public boolean isHasAudioStream() {
        return hasAudioStream;
    }

    public void setHasAudioStream(boolean hasAudioStream) {
        this.hasAudioStream = hasAudioStream;
        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_AUDIO_STATE_CHANGED, null);
    }

    public boolean isMicOpen() {
        return isMicOpen;
    }

    public void setMicOpen(boolean micOpened) {
        isMicOpen = micOpened;
    }

    public boolean isSoundOnSpeaker() {
        return isSoundOnSpeaker;
    }

    public void setSoundOnSpeaker(boolean soundOnSpeaker) {
        isSoundOnSpeaker = soundOnSpeaker;
        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_AUDIO_ROUTE_CHANGED, null);
    }
}
