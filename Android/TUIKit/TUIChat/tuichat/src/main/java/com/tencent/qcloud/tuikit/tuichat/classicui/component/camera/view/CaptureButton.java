package com.tencent.qcloud.tuikit.tuichat.classicui.component.camera.view;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.os.CountDownTimer;
import android.view.MotionEvent;
import android.view.View;

import com.tencent.qcloud.tuikit.tuichat.classicui.component.camera.listener.CaptureListener;
import com.tencent.qcloud.tuikit.tuichat.util.CheckPermission;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class CaptureButton extends View {

    public static final int STATE_IDLE = 0x001;        //空闲状态 idle state
    public static final int STATE_PRESS = 0x002;       //按下状态 pressed state
    public static final int STATE_LONG_PRESS = 0x003;  //长按状态 long press state
    public static final int STATE_RECORDERING = 0x004; //录制状态 recording status
    public static final int STATE_BAN = 0x005;         //禁止状态 forbidden state
    private static final String TAG = CaptureButton.class.getSimpleName();
    private int state;              //当前按钮状态 current button state
    private int button_state;       //按钮可执行的功能状态（拍照,录制,两者）The state of the function that the button can perform (photograph, record, both)
    private int progress_color = 0xEE16AE16;            //进度条颜色 progress bar color
    private int outside_color = 0xEEDCDCDC;             //外圆背景色 Outer circle background color
    private int inside_color = 0xFFFFFFFF;              //内圆背景色 Inner circle background color


    private float event_Y;  //Touch_Event_Down时候记录的Y值 Y value recorded when Touch_Event_Down


    private Paint mPaint;

    private float strokeWidth;          //进度条宽度 progress bar width
    private int outside_add_size;       //长按外圆半径变大的Size Long press the Size whose outer circle radius becomes larger
    private int inside_reduce_size;     //长安内圆缩小的Size The size of the inner circle of Chang'an reduced

    //中心坐标 Center coordinates
    private float center_X;
    private float center_Y;

    private float button_radius;            //按钮半径 button radius
    private float button_outside_radius;    //外圆半径 Outer circle radius
    private float button_inside_radius;     //内圆半径 Inner circle radius
    private int button_size;                //按钮大小 button size

    private float progress;         //录制视频的进度 Progress of recording video
    private int duration;           //录制视频最大时间长度 Maximum length of time to record video
    private int min_duration;       //最短录制时间限制 Minimum recording time limit
    private int recorded_time;      //记录当前录制的时间 Record the current recording time

    private RectF rectF;

    private LongPressRunnable longPressRunnable;    //长按后处理的逻辑Runnable Logic of post-processing after long press
    private CaptureListener captureLisenter;        //按钮回调接口 button callback interface
    private RecordCountDownTimer timer;             //计时器 timer

    public CaptureButton(Context context) {
        super(context);
    }

    public CaptureButton(Context context, int size) {
        super(context);
        this.button_size = size;
        button_radius = size / 2.0f;

        button_outside_radius = button_radius;
        button_inside_radius = button_radius * 0.75f;

        strokeWidth = size / 15;
        outside_add_size = size / 5;
        inside_reduce_size = size / 8;

        mPaint = new Paint();
        mPaint.setAntiAlias(true);

        progress = 0;
        longPressRunnable = new LongPressRunnable();

        state = STATE_IDLE;
        button_state = JCameraView.BUTTON_STATE_BOTH;
        TUIChatLog.i(TAG, "CaptureButtom start");
        duration = 10 * 1000;
        TUIChatLog.i(TAG, "CaptureButtom end");
        min_duration = 1500;

        center_X = (button_size + outside_add_size * 2) / 2;
        center_Y = (button_size + outside_add_size * 2) / 2;

        rectF = new RectF(
                center_X - (button_radius + outside_add_size - strokeWidth / 2),
                center_Y - (button_radius + outside_add_size - strokeWidth / 2),
                center_X + (button_radius + outside_add_size - strokeWidth / 2),
                center_Y + (button_radius + outside_add_size - strokeWidth / 2));

        timer = new RecordCountDownTimer(duration, duration / 360);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        setMeasuredDimension(button_size + outside_add_size * 2, button_size + outside_add_size * 2);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        mPaint.setStyle(Paint.Style.FILL);

        mPaint.setColor(outside_color);
        canvas.drawCircle(center_X, center_Y, button_outside_radius, mPaint);

        mPaint.setColor(inside_color);
        canvas.drawCircle(center_X, center_Y, button_inside_radius, mPaint);

        // 如果状态为录制状态，则绘制录制进度条
        // If the state is recording, draw a recording progress bar
        if (state == STATE_RECORDERING) {
            mPaint.setColor(progress_color);
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
                if (event.getPointerCount() > 1 || state != STATE_IDLE)
                    break;
                event_Y = event.getY();
                state = STATE_PRESS;

                if ((button_state == JCameraView.BUTTON_STATE_ONLY_RECORDER || button_state == JCameraView.BUTTON_STATE_BOTH))
                    postDelayed(longPressRunnable, 500);
                break;
            case MotionEvent.ACTION_MOVE:
                if (captureLisenter != null
                        && state == STATE_RECORDERING
                        && (button_state == JCameraView.BUTTON_STATE_ONLY_RECORDER || button_state == JCameraView.BUTTON_STATE_BOTH)) {
                    // 记录当前Y值与按下时候Y值的差值，调用缩放回调接口
                    // Record the difference between the current Y value and the Y value when pressed, and call the zoom callback interface
                    captureLisenter.recordZoom(event_Y - event.getY());
                }
                break;
            case MotionEvent.ACTION_UP:
                // 根据当前按钮的状态进行相应的处理
                // Perform corresponding processing according to the current state of the button
                handlerUnpressByState();
                break;
        }
        return true;
    }

    private void handlerUnpressByState() {
        removeCallbacks(longPressRunnable);
        switch (state) {
            case STATE_PRESS:
                if (captureLisenter != null && (button_state == JCameraView.BUTTON_STATE_ONLY_CAPTURE || button_state ==
                        JCameraView.BUTTON_STATE_BOTH)) {
                    startCaptureAnimation(button_inside_radius);
                } else {
                    state = STATE_IDLE;
                }
                break;
            case STATE_RECORDERING:
                timer.cancel();
                recordEnd();
                break;
        }
    }

    private void recordEnd() {
        if (captureLisenter != null) {
            if (recorded_time < min_duration)
                captureLisenter.recordShort(recorded_time);
            else
                captureLisenter.recordEnd(recorded_time);
        }
        resetRecordAnim();
    }

    private void resetRecordAnim() {
        state = STATE_BAN;
        progress = 0;
        invalidate();
        startRecordAnimation(
                button_outside_radius,
                button_radius,
                button_inside_radius,
                button_radius * 0.75f
        );
    }

    private void startCaptureAnimation(float inside_start) {
        ValueAnimator inside_anim = ValueAnimator.ofFloat(inside_start, inside_start * 0.75f, inside_start);
        inside_anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                button_inside_radius = (float) animation.getAnimatedValue();
                invalidate();
            }
        });
        inside_anim.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                captureLisenter.takePictures();
                state = STATE_BAN;
            }
        });
        inside_anim.setDuration(100);
        inside_anim.start();
    }

    private void startRecordAnimation(float outside_start, float outside_end, float inside_start, float inside_end) {
        ValueAnimator outside_anim = ValueAnimator.ofFloat(outside_start, outside_end);
        ValueAnimator inside_anim = ValueAnimator.ofFloat(inside_start, inside_end);
        outside_anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                button_outside_radius = (float) animation.getAnimatedValue();
                invalidate();
            }
        });
        inside_anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                button_inside_radius = (float) animation.getAnimatedValue();
                invalidate();
            }
        });
        AnimatorSet set = new AnimatorSet();
        set.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                if (state == STATE_LONG_PRESS) {
                    if (captureLisenter != null)
                        captureLisenter.recordStart();
                    state = STATE_RECORDERING;
                    timer.start();
                }
            }
        });
        set.playTogether(outside_anim, inside_anim);
        set.setDuration(100);
        set.start();
    }

    private void updateProgress(long millisUntilFinished) {
        recorded_time = (int) (duration - millisUntilFinished);
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
        timer = new RecordCountDownTimer(duration, duration / 360);    //录制定时器
    }

    // 设置最短录制时间
    // Set the minimum recording time
    public void setMinDuration(int duration) {
        this.min_duration = duration;
    }

    // 设置回调接口
    // Set callback interface
    public void setCaptureLisenter(CaptureListener captureLisenter) {
        this.captureLisenter = captureLisenter;
    }

    // 设置按钮功能（拍照和录像）
    // Set button functions (photo and video)
    public void setButtonFeatures(int state) {
        this.button_state = state;
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
            if (CheckPermission.getRecordState() != CheckPermission.STATE_SUCCESS) {
                state = STATE_IDLE;
                if (captureLisenter != null) {
                    captureLisenter.recordError();
                    return;
                }
            }
            startRecordAnimation(
                    button_outside_radius,
                    button_outside_radius + outside_add_size,
                    button_inside_radius,
                    button_inside_radius - inside_reduce_size
            );
        }
    }
}
