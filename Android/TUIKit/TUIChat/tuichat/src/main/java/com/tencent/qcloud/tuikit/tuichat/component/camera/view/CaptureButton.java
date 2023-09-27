package com.tencent.qcloud.tuikit.tuichat.component.camera.view;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.os.CountDownTimer;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import com.tencent.qcloud.tuikit.tuichat.component.camera.CameraActivity;
import com.tencent.qcloud.tuikit.tuichat.component.camera.CameraUtil;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.CaptureListener;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class CaptureButton extends View {
    public static final int MIN_RECORD_TIME = 1500; // 最短录制时间  Minimum length of time to record video

    public static final int STATE_IDLE = 0x001; // 空闲状态 idle state
    public static final int STATE_PRESS = 0x002; // 按下状态 pressed state
    public static final int STATE_LONG_PRESS = 0x003; // 长按状态 long press state
    public static final int STATE_RECORDING = 0x004; // 录制状态 recording status
    public static final int STATE_BAN = 0x005; // 禁止状态 forbidden state
    private static final String TAG = CaptureButton.class.getSimpleName();
    private int state; // 当前按钮状态 current button state
    private int buttonState; // 按钮可执行的功能状态（拍照,录制,两者）The state of the function that the button can perform (photograph, record, both)
    private int progressColor = 0xEE16AE16; // 进度条颜色 progress bar color
    private int outsideColor = 0xEEDCDCDC; // 外圆背景色 Outer circle background color
    private int insideColor = 0xFFFFFFFF; // 内圆背景色 Inner circle background color

    private float eventY; // Touch_Event_Down时候记录的Y值 Y value recorded when Touch_Event_Down

    private Paint mPaint;

    private float strokeWidth; // 进度条宽度 progress bar width
    private int outsideAddSize; // 长按外圆半径变大的Size Long press the Size whose outer circle radius becomes larger
    private int insideReduceSize; // 长安内圆缩小的Size The size of the inner circle of Chang'an reduced

    // 中心坐标 Center coordinates
    private float centerX;
    private float centerY;

    private float buttonRadius; // 按钮半径 button radius
    private float buttonOutsideRadius; // 外圆半径 Outer circle radius
    private float buttonInsideRadius; // 内圆半径 Inner circle radius
    private int buttonSize; // 按钮大小 button size

    private float progress; // 录制视频的进度 Progress of recording video
    private int duration; // 录制视频最大时间长度 Maximum length of time to record video
    private int minDuration; // 最短录制时间限制 Minimum recording time limit
    private int recordedTime; // 记录当前录制的时间 Record the current recording time

    private RectF rectF;

    private LongPressRunnable longPressRunnable; // 长按后处理的逻辑Runnable Logic of post-processing after long press
    private CaptureListener captureListener; // 按钮回调接口 button callback interface
    private RecordCountDownTimer timer; // 计时器 timer

    public CaptureButton(Context context) {
        super(context);
    }

    public CaptureButton(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
    }

    public CaptureButton(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setView(int size) {
        this.buttonSize = size;
        buttonRadius = size / 2.0f;

        buttonOutsideRadius = buttonRadius;
        buttonInsideRadius = buttonRadius * 0.75f;

        strokeWidth = size / 15;
        outsideAddSize = size / 5;
        insideReduceSize = size / 8;

        mPaint = new Paint();
        mPaint.setAntiAlias(true);

        progress = 0;
        longPressRunnable = new LongPressRunnable();

        state = STATE_IDLE;
        buttonState = CameraActivity.BUTTON_STATE_BOTH;
        TUIChatLog.i(TAG, "CaptureButtom start");
        duration = 10 * 1000;
        TUIChatLog.i(TAG, "CaptureButtom end");
        minDuration = 1500;

        centerX = (buttonSize + outsideAddSize * 2) / 2;
        centerY = (buttonSize + outsideAddSize * 2) / 2;

        rectF = new RectF(centerX - (buttonRadius + outsideAddSize - strokeWidth / 2), centerY - (buttonRadius + outsideAddSize - strokeWidth / 2),
                centerX + (buttonRadius + outsideAddSize - strokeWidth / 2), centerY + (buttonRadius + outsideAddSize - strokeWidth / 2));

        timer = new RecordCountDownTimer(duration, duration / 360);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        setMeasuredDimension(buttonSize + outsideAddSize * 2, buttonSize + outsideAddSize * 2);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        mPaint.setStyle(Paint.Style.FILL);

        mPaint.setColor(outsideColor);
        canvas.drawCircle(centerX, centerY, buttonOutsideRadius, mPaint);

        mPaint.setColor(insideColor);
        canvas.drawCircle(centerX, centerY, buttonInsideRadius, mPaint);

        // 如果状态为录制状态，则绘制录制进度条
        // If the state is recording, draw a recording progress bar
        if (state == STATE_RECORDING) {
            mPaint.setColor(progressColor);
            mPaint.setStyle(Paint.Style.STROKE);
            mPaint.setStrokeWidth(strokeWidth);
            canvas.drawArc(rectF, -90, progress, false, mPaint);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                TUIChatLog.i(TAG, "state = " + state);
                if (event.getPointerCount() > 1 || state != STATE_IDLE) {
                    break;
                }
                eventY = event.getY();
                state = STATE_PRESS;

                if ((buttonState == CameraActivity.BUTTON_STATE_ONLY_RECORDER || buttonState == CameraActivity.BUTTON_STATE_BOTH)) {
                    postDelayed(longPressRunnable, 500);
                }
                break;
            case MotionEvent.ACTION_MOVE:
                if (captureListener != null && state == STATE_RECORDING
                    && (buttonState == CameraActivity.BUTTON_STATE_ONLY_RECORDER || buttonState == CameraActivity.BUTTON_STATE_BOTH)) {
                    // 记录当前Y值与按下时候Y值的差值，调用缩放回调接口
                    // Record the difference between the current Y value and the Y value when pressed, and call the zoom callback interface
                    captureListener.recordZoom(eventY - event.getY());
                }
                break;
            case MotionEvent.ACTION_UP:
                // 根据当前按钮的状态进行相应的处理
                // Perform corresponding processing according to the current state of the button
                handlerUnpressByState();
                break;
            default:
                break;
        }
        return true;
    }

    private void handlerUnpressByState() {
        removeCallbacks(longPressRunnable);
        switch (state) {
            case STATE_PRESS:
                if (captureListener != null && (buttonState == CameraActivity.BUTTON_STATE_ONLY_CAPTURE || buttonState == CameraActivity.BUTTON_STATE_BOTH)) {
                    startCaptureAnimation(buttonInsideRadius);
                } else {
                    state = STATE_IDLE;
                }
                break;
            case STATE_RECORDING:
                timer.cancel();
                recordEnd();
                break;
            default:
                break;
        }
    }

    private void recordEnd() {
        if (captureListener != null) {
            if (recordedTime < minDuration) {
                captureListener.recordShort(recordedTime);
            } else {
                captureListener.recordEnd(recordedTime);
            }
        }
        resetRecordAnim();
    }

    private void resetRecordAnim() {
        state = STATE_BAN;
        progress = 0;
        invalidate();
        startRecordAnimation(buttonOutsideRadius, buttonRadius, buttonInsideRadius, buttonRadius * 0.75f);
    }

    private void startCaptureAnimation(float insideStart) {
        ValueAnimator insideAnim = ValueAnimator.ofFloat(insideStart, insideStart * 0.75f, insideStart);
        insideAnim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                buttonInsideRadius = (float) animation.getAnimatedValue();
                invalidate();
            }
        });
        insideAnim.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                captureListener.takePictures();
                state = STATE_BAN;
            }
        });
        insideAnim.setDuration(100);
        insideAnim.start();
    }

    private void startRecordAnimation(float outsideStart, float outsideEnd, float insideStart, float insideEnd) {
        ValueAnimator outsideAnim = ValueAnimator.ofFloat(outsideStart, outsideEnd);
        ValueAnimator insideAnim = ValueAnimator.ofFloat(insideStart, insideEnd);
        outsideAnim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                buttonOutsideRadius = (float) animation.getAnimatedValue();
                invalidate();
            }
        });
        insideAnim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                buttonInsideRadius = (float) animation.getAnimatedValue();
                invalidate();
            }
        });
        AnimatorSet set = new AnimatorSet();
        set.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                if (state == STATE_LONG_PRESS) {
                    if (captureListener != null) {
                        captureListener.recordStart();
                    }
                    state = STATE_RECORDING;
                    timer.start();
                }
            }
        });
        set.playTogether(outsideAnim, insideAnim);
        set.setDuration(100);
        set.start();
    }

    private void updateProgress(long millisUntilFinished) {
        recordedTime = (int) (duration - millisUntilFinished);
        progress = 360f - millisUntilFinished / (float) duration * 360f;
        invalidate();
    }

    /**************************************************
     * Call API                     *
     **************************************************/

    // 设置最长录制时间
    // Set the maximum recording time
    public void setDuration(int duration) {
        this.duration = duration;
        timer = new RecordCountDownTimer(duration, duration / 360); // 录制定时器
    }

    // 设置最短录制时间
    // Set the minimum recording time
    public void setMinDuration(int duration) {
        this.minDuration = duration;
    }

    // 设置回调接口
    // Set callback interface
    public void setCaptureListener(CaptureListener captureListener) {
        this.captureListener = captureListener;
    }

    // 设置按钮功能（拍照和录像）
    // Set button functions (photo and video)
    public void setButtonFeature(int state) {
        this.buttonState = state;
    }

    // 是否空闲状态
    // Is it idle
    public boolean isIdle() {
        return state == STATE_IDLE;
    }

    // 设置状态
    // set state
    public void resetState() {
        state = STATE_IDLE;
    }

    // 录制视频计时器
    // record video timer
    private class RecordCountDownTimer extends CountDownTimer {
        RecordCountDownTimer(long millisInFuture, long countDownInterval) {
            super(millisInFuture, countDownInterval);
        }

        @Override
        public void onTick(long millisUntilFinished) {
            updateProgress(millisUntilFinished);
        }

        @Override
        public void onFinish() {
            updateProgress(0);
            recordEnd();
        }
    }

    // 长按线程
    // long press thread
    private class LongPressRunnable implements Runnable {
        @Override
        public void run() {
            state = STATE_LONG_PRESS;
            int recordState = CameraUtil.getRecordState();
            if (recordState != CameraUtil.STATE_SUCCESS) {
                state = STATE_IDLE;
                if (captureListener != null) {
                    captureListener.recordError();
                    return;
                }
            }
            startRecordAnimation(
                    buttonOutsideRadius,
                    buttonOutsideRadius + outsideAddSize,
                    buttonInsideRadius,
                    buttonInsideRadius - insideReduceSize
            );
        }
    }
}
