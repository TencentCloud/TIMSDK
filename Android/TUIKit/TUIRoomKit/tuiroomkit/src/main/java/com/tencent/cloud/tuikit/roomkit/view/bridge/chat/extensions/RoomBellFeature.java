package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.extensions;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.qcloud.tuicore.util.SPUtils;


import java.io.File;

public class RoomBellFeature {
    private static final String PROFILE_TUIROOMKIT = "per_profile_tuiroomkit";
    private static final String PROFILE_ROOM_BELL  = "per_room_bell";
    private static final String PROFILE_MUTE_MODE  = "per_mute_mode";

    private       Context     mContext;
    private final MediaPlayer mMediaPlayer;
    private       Handler     mHandler;
    private       int         mRoomBellResourceId = -1;
    private       String      mRoomBellResourcePath;

    public RoomBellFeature(Context context) {
        mContext = context.getApplicationContext();
        mMediaPlayer = new MediaPlayer();
    }

    public void startDialingMusic() {
        start("", R.raw.phone_ringing);
    }

    public void startRing() {
        if (SPUtils.getInstance(PROFILE_TUIROOMKIT).getBoolean(PROFILE_MUTE_MODE, false)) {
            return;
        }
        String path = SPUtils.getInstance(PROFILE_TUIROOMKIT).getString(PROFILE_ROOM_BELL, "");
        if (TextUtils.isEmpty(path)) {
            start("", R.raw.phone_ringing);
        } else {
            start(path, -1);
        }
    }

    public void stopMusic() {
        stop();
    }

    private void start(String resPath, int resId) {
        preHandler();
        if (TextUtils.isEmpty(resPath) && (-1 == resId)) {
            return;
        }
        if ((-1 != resId && (mRoomBellResourceId == resId))
                || (!TextUtils.isEmpty(resPath) && TextUtils.equals(mRoomBellResourcePath, resPath))) {
            return;
        }

        if (!TextUtils.isEmpty(resPath) && isUrl(resPath)) {
            return;
        }

        AssetFileDescriptor afd0 = null;
        if (!TextUtils.isEmpty(resPath) && new File(resPath).exists()) {
            mRoomBellResourcePath = resPath;
        } else if (-1 != resId) {
            mRoomBellResourceId = resId;
            afd0 = mContext.getResources().openRawResourceFd(resId);
        }

        final AssetFileDescriptor afd = afd0;
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mMediaPlayer.isPlaying()) {
                    mMediaPlayer.stop();
                }
                mMediaPlayer.reset();
                mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);

                try {
                    if (null != afd) {
                        mMediaPlayer.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
                    } else if (!TextUtils.isEmpty(mRoomBellResourcePath)) {
                        mMediaPlayer.setDataSource(mRoomBellResourcePath);
                    } else {
                        return;
                    }

                    mMediaPlayer.setLooping(true);
                    mMediaPlayer.prepare();
                    mMediaPlayer.start();

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

    private boolean isUrl(String url) {
        return url.startsWith("http://") || url.startsWith("https://");
    }

    private void preHandler() {
        if (null != mHandler) {
            return;
        }
        HandlerThread thread = new HandlerThread("RoomBell");
        thread.start();
        mHandler = new Handler(thread.getLooper());
    }

    private void stop() {
        if (null == mHandler) {
            return;
        }

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mMediaPlayer.isPlaying()) {
                    mMediaPlayer.stop();
                }
                mRoomBellResourceId = -1;
                mRoomBellResourcePath = "";
                mHandler.getLooper().quit();
            }
        });
    }
}
