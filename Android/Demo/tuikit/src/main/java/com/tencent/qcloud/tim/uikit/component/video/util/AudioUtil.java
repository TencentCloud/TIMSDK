package com.tencent.qcloud.tim.uikit.component.video.util;

import android.content.Context;
import android.media.AudioManager;

public class AudioUtil {

    public static void setAudioManage(Context context) {
        AudioManager audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        audioManager.setStreamMute(AudioManager.STREAM_SYSTEM, true);
        audioManager.setStreamMute(AudioManager.STREAM_MUSIC, true);
        audioManager.setStreamVolume(AudioManager.STREAM_ALARM, 0, 0);
        audioManager.setStreamVolume(AudioManager.STREAM_DTMF, 0, 0);
        audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, 0, 0);
        audioManager.setStreamVolume(AudioManager.STREAM_RING, 0, 0);
    }
}
