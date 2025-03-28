package com.tencent.cloud.tuikit.roomkit.view.main.localaudioindicator;

public interface LocalAudioToggleViewResponder {
    void onLocalAudioEnabled();

    void onLocalAudioDisabled();

    void onLocalAudioVolumedChanged(int volume);

    void onLocalAudioVisibilityChanged(boolean visible);
}
