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
    public static final int MIN_RECORD_TIME = 1500; 

    public static final int STATE_IDLE = 0x001; 
    public static final int STATE_PRESS = 0x002; 
    public static final int STATE_LONG_PRESS = 0x003; 
    public static final int STATE_RECORDING = 0x004; 
    public static final int STATE_BAN = 0x005; 
    private static final String TAG = CaptureButton.class.getSimpleName();
    private int state; 
    private int buttonState; 
    private int progressColor = 0xEE16AE16; 
    private int outsideColor = 0xEEDCDCDC; 
    private int insideColor = 0xFFFFFFFF; 

    private float eventY; 

    private Paint mPaint;

    private float strokeWidth; 
    private int outsideAddSize; 
    private int insideReduceSize; 

    
    private float centerX;
    private float centerY;

    private float buttonRadius; 
    private float buttonOutsideRadius; 
    private float buttonInsideRadius; 
    private int buttonSize; 

    private float progress; 
    private int duration; 
    private int minDuration; 
    private int recordedTime; 

    private RectF rectF;

    private LongPressRunnable longPressRunnable; 
    private CaptureListener captureListener; 
    private RecordCountDownTimer timer; 

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
                    
                    // Record the difference between the current Y value and the Y value when pressed, and call the zoom callback interface
                    captureListener.recordZoom(eventY - event.getY());
                }
                break;
            case MotionEvent.ACTION_UP:
                
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

    
    // Set the maximum recording time
    public void setDuration(int duration) {
        this.duration = duration;
        timer = new RecordCountDownTimer(duration, duration / 360); 
    }

    
    // Set the minimum recording time
    public void setMinDuration(int duration) {
        this.minDuration = duration;
    }

    
    // Set callback interface
    public void setCaptureListener(CaptureListener captureListener) {
        this.captureListener = captureListener;
    }

    
    // Set button functions (photo and video)
    public void setButtonFeature(int state) {
        this.buttonState = state;
    }

    
    // Is it idle
    public boolean isIdle() {
        return state == STATE_IDLE;
    }

    
    // set state
    public void resetState() {
        state = STATE_IDLE;
    }

    
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
