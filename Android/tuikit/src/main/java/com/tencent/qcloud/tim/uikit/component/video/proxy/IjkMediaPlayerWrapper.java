package com.tencent.qcloud.tim.uikit.component.video.proxy;

import android.content.Context;
import android.media.MediaPlayer;
import android.net.Uri;
import android.util.AttributeSet;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.widget.VideoView;

import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.io.IOException;

import tv.danmaku.ijk.media.player.IMediaPlayer;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;

public class IjkMediaPlayerWrapper implements IPlayer {

    private static final String TAG = IjkMediaPlayerWrapper.class.getSimpleName();

    private IjkMediaPlayer mMediaPlayer;

    public IjkMediaPlayerWrapper() {
        mMediaPlayer = new IjkMediaPlayer();
    }

    @Override
    public void setOnPreparedListener(final OnPreparedListener l) {
        mMediaPlayer.setOnPreparedListener(new IMediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(IMediaPlayer mp) {
                l.onPrepared(IjkMediaPlayerWrapper.this);
            }
        });
    }

    @Override
    public void setOnErrorListener(final OnErrorListener l) {
        mMediaPlayer.setOnErrorListener(new IMediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(IMediaPlayer mp, int what, int extra) {
                return l.onError(IjkMediaPlayerWrapper.this, what, extra);
            }
        });
    }

    @Override
    public void setOnCompletionListener(final OnCompletionListener l) {
        mMediaPlayer.setOnCompletionListener(new IMediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(IMediaPlayer mp) {
                l.onCompletion(IjkMediaPlayerWrapper.this);
            }
        });
    }

    @Override
    public void setOnVideoSizeChangedListener(final OnVideoSizeChangedListener l) {
        mMediaPlayer.setOnVideoSizeChangedListener(new IMediaPlayer.OnVideoSizeChangedListener() {
            @Override
            public void onVideoSizeChanged(IMediaPlayer mp, int width, int height,
                                           int sarNum, int sarDen) {
                TUIKitLog.i(TAG, "width: " + width + " height: " + height
                        + " sarNum: " + sarNum + " sarDen: " + sarDen);
                l.onVideoSizeChanged(IjkMediaPlayerWrapper.this, width, height);
            }
        });
    }

    @Override
    public void setOnInfoListener(final OnInfoListener l) {
        mMediaPlayer.setOnInfoListener(new IMediaPlayer.OnInfoListener() {
            @Override
            public boolean onInfo(IMediaPlayer mp, int what, int extra) {
                l.onInfo(IjkMediaPlayerWrapper.this, what, extra);
                if (what == IMediaPlayer.MEDIA_INFO_VIDEO_ROTATION_CHANGED) {

                }
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
