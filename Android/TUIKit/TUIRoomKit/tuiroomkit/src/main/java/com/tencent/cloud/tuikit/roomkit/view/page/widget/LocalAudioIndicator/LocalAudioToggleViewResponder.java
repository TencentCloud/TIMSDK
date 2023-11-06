package com.tencent.cloud.tuikit.roomkit.view.page.widget.localaudioindicator;

public interface LocalAudioToggleViewResponder {
    void onLocalAudioEnabled();

    void onLocalAudioDisabled();

    void onLocalAudioVolumedChanged(int volume);
}
