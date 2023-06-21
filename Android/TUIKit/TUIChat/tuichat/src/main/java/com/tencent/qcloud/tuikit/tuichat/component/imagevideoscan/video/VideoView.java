package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.video;

import android.content.Context;
import android.graphics.Matrix;
import android.graphics.SurfaceTexture;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Surface;
import android.view.TextureView;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.video.proxy.IPlayer;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.video.proxy.MediaPlayerProxy;

public class VideoView extends TextureView {
    private static final String TAG = VideoView.class.getSimpleName();

    private static int STATE_ERROR = -1;
    private static int STATE_IDLE = 0;
    private static int STATE_PREPARING = 1;
    private static int STATE_PREPARED = 2;
    private static int STATE_PLAYING = 3;
    private static int STATE_PAUSED = 4;
    private static int STATE_PLAYBACK_COMPLETED = 5;
    private static int STATE_STOPPED = 6;

    private int mCurrentState = STATE_IDLE;

    private Context mContext;
    private Surface mSurface;
    private MediaPlayerProxy mMediaPlayer;

    private Uri mUri;
    private int mVideoRotationDegree;
    private Matrix baseMatrix = new Matrix();
    private IPlayer.OnPreparedListener mOutOnPreparedListener;
    private IPlayer.OnErrorListener mOutOnErrorListener;
    private IPlayer.OnCompletionListener mOutOnCompletionListener;
    private IPlayer.OnSeekCompleteListener mOnSeekCompleteListener;
    private IPlayer.OnPreparedListener mOnPreparedListener = new IPlayer.OnPreparedListener() {
        public void onPrepared(IPlayer mp) {
            mCurrentState = STATE_PREPARED;
            // Video fit center
            float videoHeight = mp.getVideoHeight();
            float videoWidth = mp.getVideoWidth();
            float viewHeight = getHeight() - getPaddingBottom() - getPaddingTop();
            float viewWidth = getWidth() - getPaddingLeft() - getPaddingRight();

            float finalVideoHeight = viewHeight;
            float finalVideoWidth = viewHeight * videoWidth / videoHeight;

            if (finalVideoWidth > viewWidth) {
                finalVideoWidth = viewWidth;
                finalVideoHeight = viewWidth * videoHeight / videoWidth;
            }

            float scaleX = finalVideoWidth / viewWidth;
            float scaleY = finalVideoHeight / viewHeight;
            float dx = (viewWidth - finalVideoWidth) / 2;
            float dy = (viewHeight - finalVideoHeight) / 2;
            Matrix matrix = new Matrix();
            matrix.postScale(scaleX, scaleY);
            matrix.postTranslate(dx, dy);
            baseMatrix.set(matrix);
            setTransform(matrix);
            invalidate();

            Log.i(TAG, "onPrepared mVideoWidth: " + videoWidth + " mVideoHeight: " + videoHeight + " mVideoRotationDegree: " + mVideoRotationDegree);
            if (mOutOnPreparedListener != null) {
                mOutOnPreparedListener.onPrepared(mp);
            }
        }
    };

    private IPlayer.OnErrorListener mOnErrorListener = new IPlayer.OnErrorListener() {
        public boolean onError(IPlayer mp, int what, int extra) {
            Log.w(TAG, "onError: what/extra: " + what + "/" + extra);
            mCurrentState = STATE_ERROR;
            stopMedia();
            if (mOutOnErrorListener != null) {
                mOutOnErrorListener.onError(mp, what, extra);
            }
            return true;
        }
    };
    private IPlayer.OnInfoListener mOnInfoListener = new IPlayer.OnInfoListener() {
        public void onInfo(IPlayer mp, int what, int extra) {
            Log.w(TAG, "onInfo: what/extra: " + what + "/" + extra);
            if (what == 10001) { // IJK: MEDIA_INFO_VIDEO_ROTATION_CHANGED
                mVideoRotationDegree = extra;
                setRotation(mVideoRotationDegree);
                requestLayout();
            }
        }
    };
    private IPlayer.OnCompletionListener mOnCompletionListener = new IPlayer.OnCompletionListener() {
        public void onCompletion(IPlayer mp) {
            Log.i(TAG, "onCompletion");
            mCurrentState = STATE_PLAYBACK_COMPLETED;
            if (mOutOnCompletionListener != null) {
                mOutOnCompletionListener.onCompletion(mp);
            }
        }
    };
    private IPlayer.OnVideoSizeChangedListener mOnVideoSizeChangedListener = new IPlayer.OnVideoSizeChangedListener() {
        @Override
        public void onVideoSizeChanged(IPlayer mp, int width, int height) {
            // TUIChatLog.i(TAG, "onVideoSizeChanged width: " + width + " height: " + height);
        }
    };

    private IPlayer.OnSeekCompleteListener onSeekCompleteListener = new IPlayer.OnSeekCompleteListener() {
        @Override
        public void onSeekComplete(IPlayer mp) {
            if (mOnSeekCompleteListener != null) {
                mOnSeekCompleteListener.onSeekComplete(mp);
            }
        }
    };
    private SurfaceTextureListener mSurfaceTextureListener = new SurfaceTextureListener() {
        @Override
        public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
            Log.i(TAG, "onSurfaceTextureAvailable");
            mSurface = new Surface(surface);
            openVideo();
        }

        @Override
        public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
            Log.i(TAG, "onSurfaceTextureSizeChanged");
        }

        @Override
        public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
            Log.i(TAG, "onSurfaceTextureDestroyed");
            return true;
        }

        @Override
        public void onSurfaceTextureUpdated(SurfaceTexture surface) {
            // TUIChatLog.i(TAG,"onSurfaceTextureUpdated");
        }
    };

    public VideoView(Context context) {
        super(context);
        initVideoView(context);
    }

    public VideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initVideoView(context);
    }

    public VideoView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initVideoView(context);
    }

    private void initVideoView(Context context) {
        Log.i(TAG, "initVideoView");
        mContext = context;
        setSurfaceTextureListener(mSurfaceTextureListener);
        mCurrentState = STATE_IDLE;

        VideoGestureScaleAttacher.attach(this);
    }

    public Matrix getBaseMatrix() {
        return baseMatrix;
    }

    public void setOnPreparedListener(IPlayer.OnPreparedListener l) {
        mOutOnPreparedListener = l;
    }

    public void setOnSeekCompleteListener(IPlayer.OnSeekCompleteListener l) {
        mOnSeekCompleteListener = l;
    }

    public void setOnErrorListener(IPlayer.OnErrorListener l) {
        mOutOnErrorListener = l;
    }

    public void setOnCompletionListener(IPlayer.OnCompletionListener l) {
        mOutOnCompletionListener = l;
    }

    public void setVideoURI(Uri uri) {
        mUri = uri;
        openVideo();
    }

    public void resetVideo() {
        openVideo();
    }

    private void openVideo() {
        if (mUri == null) {
            Log.e(TAG, "openVideo: mUri is null ");
            return;
        }
        Log.i(TAG, "openVideo: mUri: " + mUri.getPath() + " mSurface: " + mSurface);
        if (mSurface == null) {
            Log.e(TAG, "openVideo: mSurface is null ");
            return;
        }

        stopMedia();
        try {
            mMediaPlayer = new MediaPlayerProxy();
            mMediaPlayer.setOnPreparedListener(mOnPreparedListener);
            mMediaPlayer.setOnCompletionListener(mOnCompletionListener);
            mMediaPlayer.setOnErrorListener(mOnErrorListener);
            mMediaPlayer.setOnInfoListener(mOnInfoListener);
            mMediaPlayer.setOnVideoSizeChangedListener(mOnVideoSizeChangedListener);
            mMediaPlayer.setOnSeekCompleteListener(mOnSeekCompleteListener);
            mMediaPlayer.setSurface(mSurface);
            mMediaPlayer.setDataSource(getContext(), mUri);
            mMediaPlayer.prepareAsync();
            mCurrentState = STATE_PREPARING;
        } catch (Exception ex) {
            Log.w(TAG, "ex = " + ex.getMessage());
            mCurrentState = STATE_ERROR;
        }
    }

    public boolean start() {
        Log.i(TAG, "start mCurrentState:" + mCurrentState);
        if (mMediaPlayer != null) {
            mMediaPlayer.start();
            mCurrentState = STATE_PLAYING;
        }
        return true;
    }

    public boolean stop() {
        Log.i(TAG, "stop mCurrentState:" + mCurrentState);
        stopMedia();
        return true;
    }

    public boolean pause() {
        Log.i(TAG, "pause mCurrentState:" + mCurrentState);
        if (mMediaPlayer != null) {
            mMediaPlayer.pause();
            mCurrentState = STATE_PAUSED;
        }
        return true;
    }

    public void stopMedia() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
            mMediaPlayer = null;
            mCurrentState = STATE_IDLE;
        }
    }

    public boolean isPlaying() {
        if (mMediaPlayer != null) {
            return mMediaPlayer.isPlaying();
        }
        return false;
    }

    public void seekTo(int progress) {
        if (mMediaPlayer != null) {
            mMediaPlayer.seekTo(progress);
        }
    }

    public boolean isPrepared() {
        if (mUri == null) {
            Log.e(TAG, "isPrepared: mUri is null ");
            return false;
        }
        Log.i(TAG, "isPrepared: mUri: " + mUri.getPath() + " mSurface: " + mSurface);
        if (mSurface == null) {
            Log.e(TAG, "isPrepared: mSurface is null ");
            return false;
        }

        return true;
    }

    public int getCurrentPosition() {
        if (mMediaPlayer != null) {
            return mMediaPlayer.getCurrentPosition();
        }
        return 0;
    }

    public int getDuration() {
        if (mMediaPlayer != null) {
            return mMediaPlayer.getDuration();
        }
        return 0;
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stopMedia();
    }

    @Override
    public void setBackgroundDrawable(Drawable background) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N && background != null) {
            super.setBackgroundDrawable(background);
        }
    }

    @Override
    public void setOnClickListener(@Nullable OnClickListener l) {
        super.setOnClickListener(l);
    }
}
