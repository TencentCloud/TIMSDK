package com.tencent.qcloud.tim.uikit.component.video.proxy;

import android.content.Context;
import android.net.Uri;
import android.view.Surface;
import android.view.SurfaceHolder;

import java.io.IOException;

public interface IPlayer {

    void setOnPreparedListener(final OnPreparedListener l);

    void setOnErrorListener(final OnErrorListener l);

    void setOnCompletionListener(final OnCompletionListener l);

    void setOnVideoSizeChangedListener(final OnVideoSizeChangedListener l);

    void setOnInfoListener(final OnInfoListener l);

    void setDisplay(SurfaceHolder sh);

    void setSurface(Surface sh);

    void setDataSource(Context context, Uri uri) throws IOException, IllegalArgumentException, SecurityException, IllegalStateException;

    void prepareAsync();

    void release();

    void start();

    void stop();

    void pause();

    boolean isPlaying();

    int getVideoWidth();

    int getVideoHeight();

    interface OnPreparedListener {
        void onPrepared(IPlayer mp);
    }

    interface OnErrorListener {
        boolean onError(IPlayer mp, int what, int extra);
    }

    interface OnCompletionListener {
        void onCompletion(IPlayer mp);
    }

    interface OnVideoSizeChangedListener {
        void onVideoSizeChanged(IPlayer mp, int width, int height);
    }

    interface OnInfoListener {
        void onInfo(IPlayer mp, int what, int extra);
    }
}
