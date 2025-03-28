package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm;

public interface BGMEditListener {
    void onAddBGM(String bgmPath);

    void onCutBGM(long startTime, long endTime);

    void onMuteSourceAudio(boolean isMute);

    void onMuteBGM(boolean isMute);
}
