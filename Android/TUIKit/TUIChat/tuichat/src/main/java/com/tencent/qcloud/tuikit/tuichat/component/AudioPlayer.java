package com.tencent.qcloud.tuikit.tuichat.component;

import android.media.MediaPlayer;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class AudioPlayer {

    private static final String TAG = AudioPlayer.class.getSimpleName();
    private static AudioPlayer sInstance = new AudioPlayer();
    private Callback mPlayCallback;

    private String mAudioRecordPath;
    private MediaPlayer mPlayer;

    private AudioPlayer() {
    }

    public static AudioPlayer getInstance() {
        return sInstance;
    }

    public void startPlay(String filePath, Callback callback) {
        mAudioRecordPath = filePath;
        mPlayCallback = callback;
        try {
            mPlayer = new MediaPlayer();
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
        mPlayer = null;
    }

    public String getPath() {
        return mAudioRecordPath;
    }

    public interface Callback {
        void onCompletion(Boolean success);
    }

}
