package com.tencent.qcloud.tuikit.tuicallkit.extensions;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.TextUtils;

import androidx.core.content.ContextCompat;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingStatusManager;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class CallingBellFeature {
    public static final String PROFILE_TUICALLKIT = "per_profile_tuicallkit";
    public static final String PROFILE_CALL_BELL  = "per_call_bell";
    public static final String PROFILE_MUTE_MODE  = "per_mute_mode";

    private static final int    AUDIO_DIAL_ID = 48;
    private              String mDialPath;

    private       Context     mContext;
    private final MediaPlayer mMediaPlayer;
    private       Handler     mHandler;
    private       int         mCallingBellResourceId = -1;
    private       String      mCallingBellResourcePath;

    public CallingBellFeature(Context context) {
        mContext = context.getApplicationContext();
        mMediaPlayer = new MediaPlayer();
        preHandler();
        if (mHandler != null) {
            mHandler.post(() -> mDialPath = getBellPath(mContext, R.raw.phone_dialing, "phone_dialing.mp3"));
        }
    }

    public void playMusic() {
        if (TUICallDefine.Role.Caller.equals(TUICallingStatusManager.sharedInstance(mContext).getCallRole())) {
            startDialingMusic();
        } else {
            startRing();
        }
    }

    public void stopMusic() {
        if (TUICallDefine.Role.Caller.equals(TUICallingStatusManager.sharedInstance(mContext).getCallRole())) {
            TUICallEngine.createInstance(mContext).getTRTCCloudInstance().getAudioEffectManager()
                    .stopPlayMusic(AUDIO_DIAL_ID);
            return;
        }

        if (mHandler != null) {
            mHandler.post(() -> {
                if (mMediaPlayer.isPlaying()) {
                    mMediaPlayer.stop();
                }
                mCallingBellResourceId = -1;
                mCallingBellResourcePath = "";
            });
        }
    }

    private void startDialingMusic() {
        if (TextUtils.isEmpty(mDialPath)) {
            mDialPath = getBellPath(mContext, R.raw.phone_dialing, "phone_dialing.mp3");
        }
        TUICallEngine.createInstance(mContext).getTRTCCloudInstance().getAudioEffectManager()
                .setMusicPlayoutVolume(AUDIO_DIAL_ID, 100);
        TXAudioEffectManager.AudioMusicParam param = new TXAudioEffectManager.AudioMusicParam(AUDIO_DIAL_ID, mDialPath);
        param.isShortFile = true;
        TUICallEngine.createInstance(mContext).getTRTCCloudInstance().getAudioEffectManager().startPlayMusic(param);
    }

    private void startRing() {
        if (SPUtils.getInstance(PROFILE_TUICALLKIT).getBoolean(PROFILE_MUTE_MODE, false)) {
            return;
        }
        String path = SPUtils.getInstance(PROFILE_TUICALLKIT).getString(PROFILE_CALL_BELL, "");
        if (TextUtils.isEmpty(path)) {
            start("", R.raw.phone_ringing);
        } else {
            start(path, -1);
        }
    }

    private void start(String resPath, int resId) {
        preHandler();
        if (TextUtils.isEmpty(resPath) && (-1 == resId)) {
            return;
        }
        if ((-1 != resId && (mCallingBellResourceId == resId))
                || (!TextUtils.isEmpty(resPath) && TextUtils.equals(mCallingBellResourcePath, resPath))) {
            return;
        }

        if (!TextUtils.isEmpty(resPath) && isUrl(resPath)) {
            return;
        }

        AssetFileDescriptor afd0 = null;
        if (!TextUtils.isEmpty(resPath) && new File(resPath).exists()) {
            mCallingBellResourcePath = resPath;
        } else if (-1 != resId) {
            mCallingBellResourceId = resId;
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

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    AudioAttributes attrs = new AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                            .build();
                    mMediaPlayer.setAudioAttributes(attrs);
                }
                AudioManager audioManager = (AudioManager) mContext.getSystemService(Context.AUDIO_SERVICE);
                if (audioManager != null) {
                    audioManager.setMode(AudioManager.MODE_RINGTONE);
                }
                mMediaPlayer.setAudioStreamType(AudioManager.STREAM_VOICE_CALL);

                try {
                    if (null != afd) {
                        mMediaPlayer.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
                    } else if (!TextUtils.isEmpty(mCallingBellResourcePath)) {
                        mMediaPlayer.setDataSource(mCallingBellResourcePath);
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
        HandlerThread thread = new HandlerThread("CallingBell");
        thread.start();
        mHandler = new Handler(thread.getLooper());
    }

    private String getBellPath(Context context, int resId, String name) {
        String savePath = ContextCompat.getExternalFilesDirs(context, null)[0].getAbsolutePath();
        File dir = new File(savePath);
        if (!dir.exists()) {
            dir.mkdir();
        }

        try {
            File file = new File(savePath + "/" + name);
            if (file.exists()) {
                return file.getAbsolutePath();
            }

            InputStream inputStream = context.getResources().openRawResource(resId);
            FileOutputStream outputStream = new FileOutputStream(file);
            byte[] buffer = new byte[2048];
            int length;
            while ((length = inputStream.read(buffer)) > 0) {
                outputStream.write(buffer, 0, length);
            }
            outputStream.flush();
            outputStream.close();
            inputStream.close();

            return file.getAbsolutePath();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }
}
