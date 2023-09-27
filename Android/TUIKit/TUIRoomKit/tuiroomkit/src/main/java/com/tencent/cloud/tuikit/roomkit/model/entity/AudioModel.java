package com.tencent.cloud.tuikit.roomkit.model.entity;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_AUDIO_ROUTE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_MICROPHONE_STATE_CHANGED;

import com.tencent.cloud.tuikit.roomkit.model.RoomConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;

public class AudioModel {
    public int     captureVolume          = RoomConstant.DEFAULT_AUDIO_CAPTURE_VOLUME;
    public int     playVolume             = RoomConstant.DEFAULT_AUDIO_PLAY_VOLUME;
    public boolean enableVolumeEvaluation = RoomConstant.DEFAULT_AUDIO_VOLUME_EVALUATION;

    private boolean isMicOpened            = false;
    private boolean isSoundOnSpeaker       = false;

    public boolean isMicOpened() {
        return isMicOpened;
    }

    public void setMicOpened(boolean micOpened) {
        isMicOpened = micOpened;
        RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_MICROPHONE_STATE_CHANGED, null);
    }

    public boolean isSoundOnSpeaker() {
        return isSoundOnSpeaker;
    }

    public void setSoundOnSpeaker(boolean soundOnSpeaker) {
        isSoundOnSpeaker = soundOnSpeaker;
        RoomEventCenter.getInstance().notifyEngineEvent(LOCAL_AUDIO_ROUTE_CHANGED, null);
    }
}
