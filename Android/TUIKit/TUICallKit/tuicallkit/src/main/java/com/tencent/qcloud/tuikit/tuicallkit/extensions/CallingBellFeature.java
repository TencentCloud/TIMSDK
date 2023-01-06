package com.tencent.qcloud.tuikit.tuicallkit.extensions;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.TextUtils;

import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuicallkit.R;

import java.io.File;
import java.io.IOException;

public class CallingBellFeature {
    public static final String PROFILE_TUICALLING = "per_profile_tuicalling";
    public static final String PROFILE_CALL_BELL  = "per_call_bell";
    public static final String PROFILE_MUTE_MODE  = "per_mute_mode";

    private       Context     mContext;
    private final MediaPlayer mMediaPlayer;
    private       Handler     mHandler;
    private       int         mCallingBellResourceId;
    private       String      mCallingBellResourcePath;

    public CallingBellFeature(Context context) {
        mContext = context.getApplicationContext();
        mMediaPlayer = new MediaPlayer();
        mCallingBellResourceId = -1;
        mCallingBellResourcePath = "";
    }

    public void startDialingMusic() {
        start("", R.raw.phone_dialing, 0);
    }

    public void startRing() {
        String path = SPUtils.getInstance(PROFILE_TUICALLING).getString(PROFILE_CALL_BELL, "");
        if (TextUtils.isEmpty(path)) {
            start("", R.raw.phone_ringing, 0);
        } else {
            start(path, -1, 0);
        }
    }

    public void stopMusic() {
        stop();
    }

    private void start(String resPath, final int resId, long duration) {
        preHandler();
        if (TextUtils.isEmpty(resPath) && (-1 == resId)) {
            return;
        }
        if ((-1 != resId && (mCallingBellResourceId == resId))
                || (!TextUtils.isEmpty(resPath) && TextUtils.equals(mCallingBellResourcePath, resPath))) {
            return;
        }
        AssetFileDescriptor afd0 = null;
        if (!TextUtils.isEmpty(resPath) && isUrl(resPath)) {
            return;
        } else if (!TextUtils.isEmpty(resPath) && new File(resPath).exists()) {
            mCallingBellResourcePath = resPath;
        } else if (-1 != resId) {
            mCallingBellResourceId = resId;
            afd0 = mContext.getResources().openRawResourceFd(resId);
            if (afd0 == null) {
                return;
            }
        }

        final AssetFileDescriptor afd = afd0;
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mMediaPlayer.isPlaying()) {
                    mMediaPlayer.stop();
                }
                mMediaPlayer.setOnCompletionListener(null);
                mMediaPlayer.reset();
                mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
                try {
                    if (null != afd) {
                        mMediaPlayer.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
                    } else if (!TextUtils.isEmpty(mCallingBellResourcePath)) {
                        mMediaPlayer.setDataSource(mCallingBellResourcePath);
                    } else {
                        return;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                mMediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                    @Override
                    public void onCompletion(MediaPlayer mp) {
                        stop();
                    }
                });
                try {
                    mMediaPlayer.prepare();
                } catch (IOException e) {
                    e.printStackTrace();
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

    private boolean isUrl(String url) {
        return url.startsWith("http://") || url.startsWith("https://");
    }

    private void preHandler() {
        if (null != mHandler) {
            return;
        }
        HandlerThread thread = new HandlerThread("Handler-MediaPlayer");
        thread.start();
        mHandler = new Handler(thread.getLooper());
    }

    private int getResId() {
        return mCallingBellResourceId;
    }

    private void stop() {
        if (null == mHandler) {
            return;
        }
        if ((-1 == getResId()) && TextUtils.isEmpty(mCallingBellResourcePath)) {
            return;
        }
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mMediaPlayer.isPlaying()) {
                    mMediaPlayer.stop();
                }
                mCallingBellResourceId = -1;
                mCallingBellResourcePath = "";
            }
        });
    }
}
