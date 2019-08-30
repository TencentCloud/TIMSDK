package com.tencent.qcloud.tim.uikit.component.video.proxy;

import android.content.Context;
import android.net.Uri;
import android.view.Surface;
import android.view.SurfaceHolder;

import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.io.IOException;

public class MediaPlayerProxy implements IPlayer{

    private static final String TAG = MediaPlayerProxy.class.getSimpleName();

    private IPlayer mMediaPlayer;

    public MediaPlayerProxy() {
        try {
            Class.forName("tv.danmaku.ijk.media.player.IjkMediaPlayer").newInstance();
            mMediaPlayer = new IjkMediaPlayerWrapper();
        } catch (Exception e) {
            mMediaPlayer = new SystemMediaPlayerWrapper();
        }
        TUIKitLog.i(TAG, "use mMediaPlayer: " + mMediaPlayer);
    }

    @Override
    public void setOnPreparedListener(final OnPreparedListener l) {
        mMediaPlayer.setOnPreparedListener(l);
    }

    @Override
    public void setOnErrorListener(final OnErrorListener l) {
        mMediaPlayer.setOnErrorListener(l);
    }

    @Override
    public void setOnCompletionListener(final OnCompletionListener l) {
        mMediaPlayer.setOnCompletionListener(l);
    }

    @Override
    public void setOnVideoSizeChangedListener(final OnVideoSizeChangedListener l) {
        mMediaPlayer.setOnVideoSizeChangedListener(l);
    }

    @Override
    public void setOnInfoListener(final OnInfoListener l) {
        mMediaPlayer.setOnInfoListener(l);
    }

    @Override
    public void setDisplay(SurfaceHolder sh) {
        mMediaPlayer.setDisplay(sh);
    }

    @Override
    public void setSurface(Surface sh) {
        mMediaPlayer.setSurface(sh);
    }

    @Override
    public void setDataSource(Context context, Uri uri) throws IOException, IllegalArgumentException, SecurityException, IllegalStateException {
        mMediaPlayer.setDataSource(context, uri);
    }

    @Override
    public void prepareAsync() {
        mMediaPlayer.prepareAsync();
    }

    @Override
    public void release() {
        mMediaPlayer.release();
    }

    @Override
    public void start() {
        mMediaPlayer.start();
    }

    @Override
    public void stop() {
        mMediaPlayer.stop();
    }

    @Override
    public void pause() {
        mMediaPlayer.pause();
    }

    @Override
    public boolean isPlaying() {
        return mMediaPlayer.isPlaying();
    }

    @Override
    public int getVideoWidth() {
        return mMediaPlayer.getVideoWidth();
    }

    @Override
    public int getVideoHeight() {
        return mMediaPlayer.getVideoHeight();
    }
}
