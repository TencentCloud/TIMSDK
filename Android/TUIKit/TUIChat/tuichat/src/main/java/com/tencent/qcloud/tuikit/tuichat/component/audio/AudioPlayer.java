package com.tencent.qcloud.tuikit.tuichat.component.audio;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class AudioPlayer {
    private static final String TAG = AudioPlayer.class.getSimpleName();
    private static AudioPlayer sInstance = new AudioPlayer();
    private Callback mPlayCallback;

    private String mAudioPath;
    private MediaPlayer mPlayer;

    private AudioPlayer() {}

    public static AudioPlayer getInstance() {
        return sInstance;
    }

    public void startPlay(String filePath, Callback callback) {
        mAudioPath = filePath;
        mPlayCallback = callback;
        setSpeakerMode();
        try {
            mPlayer = new MediaPlayer();
            boolean isEnableSoundMessageSpeakerMode = TUIChatConfigs.getGeneralConfig().isEnableSoundMessageSpeakerMode();
            if (isEnableSoundMessageSpeakerMode) {
                mPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            } else {
                mPlayer.setAudioStreamType(AudioManager.STREAM_VOICE_CALL);
            }
            mPlayer.setDataSource(filePath);
            mPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mp) {
                    stopInternalPlay();
                    onPlayCompleted(true);
                }
            });
            mPlayer.prepare();
            mPlayer.start();
        } catch (Exception e) {
            TUIChatLog.w(TAG, "startPlay failed", e);
            ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.play_error_tip));
            stopInternalPlay();
            onPlayCompleted(false);
        }
    }

    public void setSpeakerMode() {
        boolean isEnableSoundMessageSpeakerMode = TUIChatConfigs.getGeneralConfig().isEnableSoundMessageSpeakerMode();
        AudioManager audioManager = (AudioManager) TUIChatService.getAppContext().getSystemService(Context.AUDIO_SERVICE);
        if (isEnableSoundMessageSpeakerMode) {
            audioManager.setMode(AudioManager.MODE_NORMAL);
            audioManager.setSpeakerphoneOn(true);
        } else {
            audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
            audioManager.setSpeakerphoneOn(false);
        }
    }

    public void resetSpeakerMode() {
        AudioManager audioManager = (AudioManager) TUIChatService.getAppContext().getSystemService(Context.AUDIO_SERVICE);
        audioManager.setMode(AudioManager.MODE_NORMAL);
    }

    public void stopPlay() {
        stopInternalPlay();
        onPlayCompleted(false);
        mPlayCallback = null;
    }

    private void stopInternalPlay() {
        if (mPlayer == null) {
            return;
        }
        mPlayer.release();
        mPlayer = null;
    }

    public boolean isPlaying() {
        if (mPlayer != null && mPlayer.isPlaying()) {
            return true;
        }
        return false;
    }

    private void onPlayCompleted(boolean success) {
        if (mPlayCallback != null) {
            mPlayCallback.onCompletion(success);
        }
        resetSpeakerMode();
        mPlayer = null;
    }

    public String getPath() {
        return mAudioPath;
    }

    public interface Callback {
        void onCompletion(Boolean success);
    }
}
