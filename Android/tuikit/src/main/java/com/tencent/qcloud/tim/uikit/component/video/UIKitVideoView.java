package com.tencent.qcloud.tim.uikit.component.video;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.net.Uri;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.Surface;
import android.view.TextureView;

import com.tencent.qcloud.tim.uikit.component.video.proxy.IPlayer;
import com.tencent.qcloud.tim.uikit.component.video.proxy.MediaPlayerProxy;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

public class UIKitVideoView extends TextureView {

    private static final String TAG = UIKitVideoView.class.getSimpleName();

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
    private int mVideoWidth;
    private int mVideoHeight;
    private int mVideoRotationDegree;

    private IPlayer.OnPreparedListener mOutOnPreparedListener;
    private IPlayer.OnErrorListener mOutOnErrorListener;
    private IPlayer.OnCompletionListener mOutOnCompletionListener;

    public UIKitVideoView(Context context) {
        super(context);
        initVideoView(context);
    }

    public UIKitVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initVideoView(context);
    }

    public UIKitVideoView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initVideoView(context);
    }

    private void initVideoView(Context context) {
        TUIKitLog.i(TAG, "initVideoView");
        mContext = context;
        setSurfaceTextureListener(mSurfaceTextureListener);
        mCurrentState = STATE_IDLE;
    }

    private IPlayer.OnPreparedListener mOnPreparedListener = new IPlayer.OnPreparedListener() {
        public void onPrepared(IPlayer mp) {
            mCurrentState = STATE_PREPARED;
            mVideoHeight = mp.getVideoHeight();
            mVideoWidth = mp.getVideoWidth();
            TUIKitLog.i(TAG, "onPrepared mVideoWidth: " + mVideoWidth
                    + " mVideoHeight: " + mVideoHeight
                    + " mVideoRotationDegree: " + mVideoRotationDegree);
            if (mOutOnPreparedListener != null) {
                mOutOnPreparedListener.onPrepared(mp);
            }
        }
    };

    private IPlayer.OnErrorListener mOnErrorListener = new IPlayer.OnErrorListener() {
        public boolean onError(IPlayer mp, int what, int extra) {
            TUIKitLog.w(TAG, "onError: what/extra: " + what + "/" + extra);
            mCurrentState = STATE_ERROR;
            stop_l();
            if (mOutOnErrorListener != null) {
                mOutOnErrorListener.onError(mp, what, extra);
            }
            return true;
        }
    };

    private IPlayer.OnInfoListener mOnInfoListener = new IPlayer.OnInfoListener() {
        public void onInfo(IPlayer mp, int what, int extra) {
            TUIKitLog.w(TAG, "onInfo: what/extra: " + what + "/" + extra);
            if (what == 10001) { // IJK: MEDIA_INFO_VIDEO_ROTATION_CHANGED
                // 有些视频拍摄的时候有角度，需要做旋转，默认ijk是不会做的，这里自己实现
                mVideoRotationDegree = extra;
                setRotation(mVideoRotationDegree);
                requestLayout();
            }
        }
    };

    private IPlayer.OnCompletionListener mOnCompletionListener = new IPlayer.OnCompletionListener() {
        public void onCompletion(IPlayer mp) {
            TUIKitLog.i(TAG, "onCompletion");
            mCurrentState = STATE_PLAYBACK_COMPLETED;
            if (mOutOnCompletionListener != null) {
                mOutOnCompletionListener.onCompletion(mp);
            }
        }
    };

    private IPlayer.OnVideoSizeChangedListener mOnVideoSizeChangedListener = new IPlayer.OnVideoSizeChangedListener() {
        @Override
        public void onVideoSizeChanged(IPlayer mp, int width, int height) {
            // TUIKitLog.i(TAG, "onVideoSizeChanged width: " + width + " height: " + height);
        }
    };

    public void setOnPreparedListener(IPlayer.OnPreparedListener l) {
        mOutOnPreparedListener = l;
    }

    public void setOnErrorListener(IPlayer.OnErrorListener l) {
        mOutOnErrorListener = l;
    }

    public void setOnCompletionListener(IPlayer.OnCompletionListener l) {
        mOutOnCompletionListener = l;
    }

    private TextureView.SurfaceTextureListener mSurfaceTextureListener = new TextureView.SurfaceTextureListener() {

        @Override
        public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
             TUIKitLog.i(TAG,"onSurfaceTextureAvailable");
            mSurface = new Surface(surface);
            openVideo();
        }

        @Override
        public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
             TUIKitLog.i(TAG,"onSurfaceTextureSizeChanged");
        }

        @Override
        public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
            TUIKitLog.i(TAG,"onSurfaceTextureDestroyed");
            return true;
        }

        @Override
        public void onSurfaceTextureUpdated(SurfaceTexture surface) {
            // TUIKitLog.i(TAG,"onSurfaceTextureUpdated");
        }
    };

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        //  TUIKitLog.i(TAG, "onMeasure(" + MeasureSpec.toString(widthMeasureSpec) + ", "
        //        + MeasureSpec.toString(heightMeasureSpec) + ")"
        //        + " mVideoWidth: " + mVideoWidth
        //        + " mVideoHeight: " + mVideoHeight);

        int width = getDefaultSize(mVideoWidth, widthMeasureSpec);
        int height = getDefaultSize(mVideoHeight, heightMeasureSpec);
        int widthSpecMode = MeasureSpec.getMode(widthMeasureSpec);
        int widthSpecSize = MeasureSpec.getSize(widthMeasureSpec);
        int heightSpecMode = MeasureSpec.getMode(heightMeasureSpec);
        int heightSpecSize = MeasureSpec.getSize(heightMeasureSpec);
        if (mVideoWidth > 0 && mVideoHeight > 0) {
            if (widthSpecMode == MeasureSpec.EXACTLY && heightSpecMode == MeasureSpec.EXACTLY) {
                // the size is fixed
                width = widthSpecSize;
                height = heightSpecSize;

                // for compatibility, we adjust size based on aspect ratio
                if ( mVideoWidth * height  < width * mVideoHeight ) {
                    //Log.i("@@@", "image too wide, correcting");
                    width = height * mVideoWidth / mVideoHeight;
                } else if ( mVideoWidth * height  > width * mVideoHeight ) {
                    //Log.i("@@@", "image too tall, correcting");
                    height = width * mVideoHeight / mVideoWidth;
                }
            } else if (widthSpecMode == MeasureSpec.EXACTLY) {
                // only the width is fixed, adjust the height to match aspect ratio if possible
                width = widthSpecSize;
                height = width * mVideoHeight / mVideoWidth;
                if (heightSpecMode == MeasureSpec.AT_MOST && height > heightSpecSize) {
                    // couldn't match aspect ratio within the constraints
                    height = heightSpecSize;
                }
            } else if (heightSpecMode == MeasureSpec.EXACTLY) {
                // only the height is fixed, adjust the width to match aspect ratio if possible
                height = heightSpecSize;
                width = height * mVideoWidth / mVideoHeight;
                if (widthSpecMode == MeasureSpec.AT_MOST && width > widthSpecSize) {
                    // couldn't match aspect ratio within the constraints
                    width = widthSpecSize;
                }
            } else {
                // neither the width nor the height are fixed, try to use actual video size
                width = mVideoWidth;
                height = mVideoHeight;
                if (heightSpecMode == MeasureSpec.AT_MOST && height > heightSpecSize) {
                    // too tall, decrease both width and height
                    height = heightSpecSize;
                    width = height * mVideoWidth / mVideoHeight;
                }
                if (widthSpecMode == MeasureSpec.AT_MOST && width > widthSpecSize) {
                    // too wide, decrease both width and height
                    width = widthSpecSize;
                    height = width * mVideoHeight / mVideoWidth;
                }
            }
        } else {
            // no size yet, just adopt the given spec sizes
        }
        TUIKitLog.i(TAG, "onMeasure width: " + width + " height: " + height + " rotation degree: " + mVideoRotationDegree);
        setMeasuredDimension(width, height);
        if ((mVideoRotationDegree + 180) % 180 != 0) {
            // 画面旋转之后需要缩放，而且旋转之后宽高的计算都要换为高宽。
            int[] size = ScreenUtil.scaledSize(widthSpecSize, heightSpecSize, height, width);
            TUIKitLog.i(TAG, "onMeasure scaled width: " + size[0] + " height: " + size[1]);
            setScaleX(size[0] / ((float)height));
            setScaleY(size[1] / ((float)width));
        }
    }

    public void setVideoURI(Uri uri) {
        mUri = uri;
        openVideo();
    }

    private void openVideo() {
        TUIKitLog.i(TAG, "openVideo: mUri: " + mUri.getPath() + " mSurface: " + mSurface);
        if (mSurface == null) {
            return;
        }

        stop_l();
        try {
            mMediaPlayer = new MediaPlayerProxy();
            mMediaPlayer.setOnPreparedListener(mOnPreparedListener);
            mMediaPlayer.setOnCompletionListener(mOnCompletionListener);
            mMediaPlayer.setOnErrorListener(mOnErrorListener);
            mMediaPlayer.setOnInfoListener(mOnInfoListener);
            mMediaPlayer.setOnVideoSizeChangedListener(mOnVideoSizeChangedListener);
            mMediaPlayer.setSurface(mSurface);
            mMediaPlayer.setDataSource(getContext(), mUri);
            mMediaPlayer.prepareAsync();
            mCurrentState = STATE_PREPARING;
        } catch (Exception ex) {
            TUIKitLog.w(TAG, ex.getMessage());
            mCurrentState = STATE_ERROR;
        }

    }

    public boolean start() {
        TUIKitLog.i(TAG, "start mCurrentState:" + mCurrentState);
        if (mMediaPlayer != null) {
            mMediaPlayer.start();
            mCurrentState = STATE_PLAYING;
        }
        return true;
    }

    public boolean stop() {
        TUIKitLog.i(TAG, "stop mCurrentState:" + mCurrentState);
        stop_l();
        return true;
    }

    public boolean pause() {
        TUIKitLog.i(TAG, "pause mCurrentState:" + mCurrentState);
        if (mMediaPlayer != null) {
            mMediaPlayer.pause();
            mCurrentState = STATE_PAUSED;
        }
        return true;
    }

    public void stop_l() {
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

    @Override
    public void setOnClickListener(@Nullable OnClickListener l) {
        super.setOnClickListener(l);
    }
}
