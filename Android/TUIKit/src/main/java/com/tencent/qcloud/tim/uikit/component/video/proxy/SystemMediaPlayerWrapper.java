package com.tencent.qcloud.tim.uikit.component.video.proxy;

import android.content.Context;
import android.media.MediaPlayer;
import android.net.Uri;
import android.view.Surface;
import android.view.SurfaceHolder;

import java.io.IOException;

public class SystemMediaPlayerWrapper implements IPlayer {

    private MediaPlayer mMediaPlayer;

    public SystemMediaPlayerWrapper() {
        mMediaPlayer = new MediaPlayer();
    }

    @Override
    public void setOnPreparedListener(final OnPreparedListener l) {
        mMediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                l.onPrepared(SystemMediaPlayerWrapper.this);
            }
        });
    }

    @Override
    public void setOnErrorListener(final OnErrorListener l) {
        mMediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mp, int what, int extra) {
                return l.onError(SystemMediaPlayerWrapper.this, what, extra);
            }
        });
    }

    @Override
    public void setOnCompletionListener(final OnCompletionListener l) {
        mMediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                l.onCompletion(SystemMediaPlayerWrapper.this);
            }
        });
    }

    @Override
    public void setOnVideoSizeChangedListener(final OnVideoSizeChangedListener l) {
        mMediaPlayer.setOnVideoSizeChangedListener(new MediaPlayer.OnVideoSizeChangedListener() {
            @Override
            public void onVideoSizeChanged(MediaPlayer mp, int width, int height) {
                l.onVideoSizeChanged(SystemMediaPlayerWrapper.this, width, height);
            }
        });
    }

    @Override
    public void setOnInfoListener(final OnInfoListener l) {
        mMediaPlayer.setOnInfoListener(new MediaPlayer.OnInfoListener() {
            @Override
            public boolean onInfo(MediaPlayer mp, int what, int extra) {
                l.onInfo(SystemMediaPlayerWrapper.this, what, extra);
                return false;
            }
        });
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
