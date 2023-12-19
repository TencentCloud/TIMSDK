package com.tencent.cloud.tuikit.roomkit.view.page.widget.LocalAudioIndicator;

public interface LocalAudioToggleViewResponder {
    void onLocalAudioEnabled();

    void onLocalAudioDisabled();

    void onLocalAudioVolumedChanged(int volume);
}
