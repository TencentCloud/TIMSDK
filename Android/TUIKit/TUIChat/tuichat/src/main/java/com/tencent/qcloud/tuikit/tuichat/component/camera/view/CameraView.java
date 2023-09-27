package com.tencent.qcloud.tuikit.tuichat.component.camera.view;

import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.hardware.Camera;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.VideoView;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.CameraListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.CaptureListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.ClickListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.ErrorListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.TypeListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.state.CameraMachine;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.io.IOException;

public class CameraView extends FrameLayout implements SurfaceHolder.Callback, ICameraView {
    private static final String TAG = CameraView.class.getSimpleName();

    // 拍照浏览时候的类型
    // camera mode
    public static final int TYPE_PICTURE = 0x001;
    public static final int TYPE_VIDEO = 0x002;
    public static final int TYPE_SHORT = 0x003;
    public static final int TYPE_DEFAULT = 0x004;
    // 录制视频比特率
    // Recording video bit rate
    public static final int MEDIA_QUALITY_HIGH = 20 * 100000;
    public static final int MEDIA_QUALITY_MIDDLE = 16 * 100000;
    public static final int MEDIA_QUALITY_LOW = 12 * 100000;
    public static final int MEDIA_QUALITY_POOR = 8 * 100000;
    public static final int MEDIA_QUALITY_FUNNY = 4 * 100000;
    public static final int MEDIA_QUALITY_DESPAIR = 2 * 100000;
    public static final int MEDIA_QUALITY_SORRY = 1 * 80000;

    // 闪关灯状态
    // Flash status
    private static final int FLASH_TYPE_AUTO = 0x021;
    private static final int FLASH_TYPE_ON = 0x022;
    private static final int FLASH_TYPE_OFF = 0x023;
    // Camera 状态机
    // Camera state machine
    private CameraMachine machine;
    private int flashType = FLASH_TYPE_OFF;
    private CameraListener cameraListener;
    private ClickListener leftClickListener;
    private ClickListener rightClickListener;

    private Context mContext;
    private VideoView mVideoView;
    private ImageView mPictureShowView;
    private ImageView mSwitchCamera;
    private CaptureLayout mCaptureLayout;
    private FocusView mFocusView;
    private MediaPlayer mMediaPlayer;

    private int layoutWidth;
    private float screenProp = 0f;

    // 视频URL Video URL
    private String videoUrl;

    // 切换摄像头按钮的参数
    // Switch camera button parameters
    private int iconSize = 0;
    private int iconMargin = 0;
    private int iconSrc = 0;
    private int iconLeft = 0;
    private int iconRight = 0;
    private int duration = 0;

    // 缩放梯度
    // scale gradient
    private int zoomGradient = 0;

    private boolean firstTouch = true;
    private float firstTouchLength = 0;
    private ErrorListener errorListener;

    public CameraView(Context context) {
        this(context, null);
    }

    public CameraView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CameraView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mContext = context;
        // get AttributeSet
        TypedArray a = context.getTheme().obtainStyledAttributes(attrs, R.styleable.CameraView, defStyleAttr, 0);
        iconSize = a.getDimensionPixelSize(
            R.styleable.CameraView_iconSize, (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, 35, getResources().getDisplayMetrics()));
        iconMargin = a.getDimensionPixelSize(
            R.styleable.CameraView_iconMargin, (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, 15, getResources().getDisplayMetrics()));
        iconSrc = a.getResourceId(R.styleable.CameraView_iconSrc, R.drawable.chat_camera_switchcamera);
        iconLeft = a.getResourceId(R.styleable.CameraView_iconLeft, 0);
        iconRight = a.getResourceId(R.styleable.CameraView_iconRight, 0);
        duration = TUIChatConfigs.getConfigs().getGeneralConfig().getVideoRecordMaxTime() * 1000;
        a.recycle();
        initData();
        initView();
    }

    private void initData() {
        layoutWidth = ScreenUtil.getScreenWidth(mContext);
        zoomGradient = (int) (layoutWidth / 16f);
        TUIChatLog.i(TAG, "zoom = " + zoomGradient);
        machine = new CameraMachine(getContext(), this);
    }

    private void initView() {
        setWillNotDraw(false);
        View view = LayoutInflater.from(mContext).inflate(R.layout.chat_input_camera_view, this);
        mVideoView = view.findViewById(R.id.video_preview);
        mPictureShowView = view.findViewById(R.id.image_photo);
        mSwitchCamera = view.findViewById(R.id.image_switch);
        mSwitchCamera.setImageResource(iconSrc);
        setFlashMode();
        mCaptureLayout = view.findViewById(R.id.capture_layout);
        mCaptureLayout.setDuration(duration);
        mFocusView = view.findViewById(R.id.focus_view);
        mVideoView.getHolder().addCallback(this);

        mSwitchCamera.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                machine.switchCamera(mVideoView.getHolder(), screenProp);
            }
        });

        mCaptureLayout.setCaptureListener(new CaptureListener() {
            @Override
            public void takePictures() {
                mSwitchCamera.setVisibility(INVISIBLE);
                machine.capture();
            }

            @Override
            public void recordStart() {
                mSwitchCamera.setVisibility(INVISIBLE);
                machine.startRecord(mVideoView.getHolder().getSurface(), screenProp);
            }

            @Override
            public void recordShort(final long time) {
                mCaptureLayout.setTextWithAnimation(TUIChatService.getAppContext().getString(R.string.record_time_tip));
                mSwitchCamera.setVisibility(VISIBLE);
                postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        machine.stopRecord(true, time);
                    }
                }, 1500 - time);
            }

            @Override
            public void recordEnd(long time) {
                machine.stopRecord(false, time);
            }

            @Override
            public void recordZoom(float zoom) {
                TUIChatLog.i(TAG, "recordZoom");
                machine.zoom(zoom, CameraInterface.TYPE_RECORDER);
            }

            @Override
            public void recordError() {
                if (errorListener != null) {
                    errorListener.onError("record error");
                }
            }
        });

        mCaptureLayout.setTypeListener(new TypeListener() {
            @Override
            public void cancel() {
                machine.cancel(mVideoView.getHolder(), screenProp);
            }

            @Override
            public void confirm() {
                machine.confirm();
            }
        });

        mCaptureLayout.setLeftClickListener(new ClickListener() {
            @Override
            public void onClick() {
                if (leftClickListener != null) {
                    leftClickListener.onClick();
                }
            }
        });
        mCaptureLayout.setRightClickListener(new ClickListener() {
            @Override
            public void onClick() {
                if (rightClickListener != null) {
                    rightClickListener.onClick();
                }
            }
        });
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        float widthSize = mVideoView.getMeasuredWidth();
        float heightSize = mVideoView.getMeasuredHeight();
        if (screenProp == 0) {
            screenProp = heightSize / widthSize;
        }
    }

    private int rotation = 0;

    public void onResume() {
        TUIChatLog.i(TAG, "ICameraView onResume");
        resetState(TYPE_DEFAULT);
        CameraInterface.getInstance().registerSensorManager(mContext);
        CameraInterface.getInstance().setOnRotateListener(new CameraInterface.OnRotateListener() {
            @Override
            public void onRotateChanged(int angle) {
                changeRotation(angle);
            }
        });
    }

    private void changeRotation(int angle) {
        if (rotation != angle) {
            int startRotaion = 0;
            int endRotation = 0;
            switch (rotation) {
                case 0:
                    startRotaion = 0;
                    switch (angle) {
                        case 90:
                            endRotation = -90;
                            break;
                        case 270:
                            endRotation = 90;
                            break;
                        default:
                            break;
                    }
                    break;
                case 90:
                    startRotaion = -90;
                    switch (angle) {
                        case 0:
                            endRotation = 0;
                            break;
                        case 180:
                            endRotation = -180;
                            break;
                        default:
                            break;
                    }
                    break;
                case 180:
                    startRotaion = 180;
                    switch (angle) {
                        case 90:
                            endRotation = 270;
                            break;
                        case 270:
                            endRotation = 90;
                            break;
                        default:
                            break;
                    }
                    break;
                case 270:
                    startRotaion = 90;
                    switch (angle) {
                        case 0:
                            endRotation = 0;
                            break;
                        case 180:
                            endRotation = 180;
                            break;
                        default:
                            break;
                    }
                    break;
                default:
                    break;
            }
            ObjectAnimator animC = ObjectAnimator.ofFloat(mSwitchCamera, "rotation", startRotaion, endRotation);
            AnimatorSet set = new AnimatorSet();
            set.play(animC);
            set.setDuration(500);
            set.start();
            rotation = angle;
        }
    }

    public void onPause() {
        TUIChatLog.i(TAG, "ICameraView onPause");
        machine.stop();
        CameraInterface.getInstance().unregisterSensorManager(mContext);
    }

    public void onDestroy() {
        stopPlayVideo();
        resetState(TYPE_PICTURE);
        CameraInterface.getInstance().setPreview(false);
        CameraInterface.getInstance().unregisterSensorManager(mContext);
        CameraInterface.destroyCameraInterface();
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        TUIChatLog.i(TAG, "ICameraView SurfaceCreated");
        ThreadUtils.runOnUiThread(() -> {
            CameraInterface.getInstance().doOpenCamera();
            CameraInterface.getInstance().doStartPreview(mVideoView.getHolder(), screenProp);
        });
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {}

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        TUIChatLog.i(TAG, "ICameraView SurfaceDestroyed");
        CameraInterface.getInstance().doDestroyCamera();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                if (event.getPointerCount() == 1) {
                    setFocusViewWidthAnimation(event.getX(), event.getY());
                }
                if (event.getPointerCount() == 2) {
                    TUIChatLog.i(TAG, "ACTION_DOWN = " + 2);
                }
                break;
            case MotionEvent.ACTION_MOVE:
                if (event.getPointerCount() == 1) {
                    firstTouch = true;
                }
                if (event.getPointerCount() == 2) {
                    float point1X = event.getX(0);
                    float point1Y = event.getY(0);
                    float point2X = event.getX(1);
                    float point2Y = event.getY(1);

                    float result = (float) Math.sqrt(Math.pow(point1X - point2X, 2) + Math.pow(point1Y - point2Y, 2));

                    if (firstTouch) {
                        firstTouchLength = result;
                        firstTouch = false;
                    }
                    if ((int) (result - firstTouchLength) / zoomGradient != 0) {
                        firstTouch = true;
                        machine.zoom(result - firstTouchLength, CameraInterface.TYPE_CAPTURE);
                    }
                }
                break;
            case MotionEvent.ACTION_UP:
                firstTouch = true;
                break;
            default:
                break;
        }
        return true;
    }

    private void setFocusViewWidthAnimation(float x, float y) {
        machine.focus(x, y, new CameraInterface.FocusCallback() {
            @Override
            public void focusSuccess() {
                mFocusView.setVisibility(INVISIBLE);
            }
        });
    }

    private void updateVideoViewSize(float videoWidth, float videoHeight) {
        if (videoWidth > videoHeight) {
            LayoutParams videoViewParam;
            int height = (int) ((videoHeight / videoWidth) * getWidth());
            videoViewParam = new LayoutParams(LayoutParams.MATCH_PARENT, height);
            videoViewParam.gravity = Gravity.CENTER;
            mVideoView.setLayoutParams(videoViewParam);
        }
    }

    public void setCameraListener(CameraListener cameraListener) {
        this.cameraListener = cameraListener;
    }

    public void setErrorListener(ErrorListener errorListener) {
        this.errorListener = errorListener;
        CameraInterface.getInstance().setErrorListener(errorListener);
    }

    public void setFeature(int feature) {
        this.mCaptureLayout.setButtonFeature(feature);
    }

    public void setMediaQuality(int quality) {
        CameraInterface.getInstance().setMediaQuality(quality);
    }

    @Override
    public void resetState(int type) {
        switch (type) {
            case TYPE_VIDEO:
                mVideoView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
                break;
            case TYPE_PICTURE:
                mPictureShowView.setVisibility(INVISIBLE);
                break;
            case TYPE_SHORT:
                break;
            case TYPE_DEFAULT:
                mVideoView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
                break;
            default:
                break;
        }
        mSwitchCamera.setVisibility(VISIBLE);
        mCaptureLayout.resetCaptureLayout();
    }

    @Override
    public void confirmState(int type) {
        switch (type) {
            case TYPE_VIDEO:
                stopPlayVideo();
                mVideoView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
                if (cameraListener != null) {
                    cameraListener.onRecordSuccess(machine.getState().getDataPath());
                }
                break;
            case TYPE_PICTURE:
                mPictureShowView.setVisibility(INVISIBLE);
                if (cameraListener != null) {
                    cameraListener.onCaptureSuccess(machine.getState().getDataPath());
                }
                break;
            default:
                break;
        }
    }

    @Override
    public void showPicture(Bitmap bitmap, boolean isVertical) {
        if (isVertical) {
            mPictureShowView.setScaleType(ImageView.ScaleType.FIT_XY);
        } else {
            mPictureShowView.setScaleType(ImageView.ScaleType.FIT_CENTER);
        }
        // 捕获的图片 captured picture
        mPictureShowView.setImageBitmap(bitmap);
        mPictureShowView.setVisibility(VISIBLE);
        mCaptureLayout.startAlphaAnimation();
        mCaptureLayout.startTypeBtnAnimator();
    }

    @Override
    public void playVideo(final String url) {
        videoUrl = url;
        try {
            if (mMediaPlayer == null) {
                mMediaPlayer = new MediaPlayer();
            } else {
                mMediaPlayer.reset();
            }
            mMediaPlayer.setDataSource(url);
            mMediaPlayer.setSurface(mVideoView.getHolder().getSurface());
            mMediaPlayer.setVideoScalingMode(MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT);
            mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            mMediaPlayer.setOnVideoSizeChangedListener(new MediaPlayer.OnVideoSizeChangedListener() {
                @Override
                public void onVideoSizeChanged(MediaPlayer mp, int width, int height) {
                    updateVideoViewSize(mMediaPlayer.getVideoWidth(), mMediaPlayer.getVideoHeight());
                }
            });
            mMediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mp) {
                    mMediaPlayer.start();
                }
            });
            mMediaPlayer.setLooping(true);
            mMediaPlayer.prepareAsync();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void stopPlayVideo() {
        if (mMediaPlayer != null && mMediaPlayer.isPlaying()) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
            mMediaPlayer = null;
        }
    }

    @Override
    public void setTip(String tip) {
        mCaptureLayout.setTip(tip);
    }

    @Override
    public void startPreviewCallback() {
        TUIChatLog.i(TAG, "startPreviewCallback");
        handlerFocus(mFocusView.getWidth() / 2, mFocusView.getHeight() / 2);
    }

    @Override
    public boolean handlerFocus(float x, float y) {
        if (y > mCaptureLayout.getTop()) {
            return false;
        }
        mFocusView.setVisibility(VISIBLE);
        if (x < mFocusView.getWidth() / 2) {
            x = mFocusView.getWidth() / 2;
        }
        if (x > layoutWidth - mFocusView.getWidth() / 2) {
            x = layoutWidth - mFocusView.getWidth() / 2;
        }
        if (y < mFocusView.getWidth() / 2) {
            y = mFocusView.getWidth() / 2;
        }
        if (y > mCaptureLayout.getTop() - mFocusView.getWidth() / 2) {
            y = mCaptureLayout.getTop() - mFocusView.getWidth() / 2;
        }
        mFocusView.setX(x - mFocusView.getWidth() / 2);
        mFocusView.setY(y - mFocusView.getHeight() / 2);
        ObjectAnimator scaleX = ObjectAnimator.ofFloat(mFocusView, "scaleX", 1, 0.6f);
        ObjectAnimator scaleY = ObjectAnimator.ofFloat(mFocusView, "scaleY", 1, 0.6f);
        ObjectAnimator alpha = ObjectAnimator.ofFloat(mFocusView, "alpha", 1f, 0.4f, 1f, 0.4f, 1f, 0.4f, 1f);
        AnimatorSet animSet = new AnimatorSet();
        animSet.play(scaleX).with(scaleY).before(alpha);
        animSet.setDuration(400);
        animSet.start();
        return true;
    }

    public void setLeftClickListener(ClickListener clickListener) {
        this.leftClickListener = clickListener;
    }

    public void setRightClickListener(ClickListener clickListener) {
        this.rightClickListener = clickListener;
    }

    private void setFlashMode() {
        switch (flashType) {
            case FLASH_TYPE_AUTO:
                machine.setFlashMode(Camera.Parameters.FLASH_MODE_AUTO);
                break;
            case FLASH_TYPE_ON:
                machine.setFlashMode(Camera.Parameters.FLASH_MODE_ON);
                break;
            case FLASH_TYPE_OFF:
                machine.setFlashMode(Camera.Parameters.FLASH_MODE_OFF);
                break;
            default:
                break;
        }
    }
}
