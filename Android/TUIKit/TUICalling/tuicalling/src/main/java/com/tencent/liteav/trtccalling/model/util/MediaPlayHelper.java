package com.tencent.liteav.trtccalling.model.util;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import java.io.IOException;

public class MediaPlayHelper {

    private static final String TAG = "MediaPlayHelper";

    private       Context     mContext;
    private final MediaPlayer mMediaPlayer;
    private       Handler     mHandler;
    private       int         mResId;

    public MediaPlayHelper(Context context) {
        mContext = context;
        mMediaPlayer = new MediaPlayer();
        mResId = -1;
    }

    public void start(int resId) {
        start(resId, 0);
    }

    public void start(int resId, long duration) {
        preHandler();
        if (mResId == resId) {
            return;
        }
        mResId = resId;
        AssetFileDescriptor afd = mContext.getResources().openRawResourceFd(resId);
        if (afd == null) return;
        try {
            if (mMediaPlayer.isPlaying()) {
                mMediaPlayer.stop();
            }
            mMediaPlayer.setOnCompletionListener(null);
            mMediaPlayer.reset();
            mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            mMediaPlayer.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
        } catch (IOException e) {
            Log.e(TAG, Log.getStackTraceString(e));
        }
        mMediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                stop();
            }
        });
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                try {
                    mMediaPlayer.prepare();
                } catch (IOException e) {
                    Log.e(TAG, Log.getStackTraceString(e));
                }
                mMediaPlayer.start();
            }
        });
        if (duration > 0) {
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    stop();
                }
            }, duration);
        }
    }

    private void preHandler() {
        if (null != mHandler) {
            return;
        }
        HandlerThread thread = new HandlerThread("Handler-MediaPlayer");
        thread.start();
        mHandler = new Handler(thread.getLooper());
    }

    public int getResId() {
        return mResId;
    }

    public void stop() {
        if (null == mHandler || -1 == getResId()) {
            return;
        }
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mMediaPlayer.isPlaying()) {
                    mMediaPlayer.stop();
                    mResId = -1;
                }
            }
        });
    }
}
