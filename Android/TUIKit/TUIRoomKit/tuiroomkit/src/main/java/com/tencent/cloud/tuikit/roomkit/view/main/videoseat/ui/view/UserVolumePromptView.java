package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.constant.Constants;

public class UserVolumePromptView extends View {
    private static final int VOLUME_STEP         = 1;
    private static final int VOLUME_TOTAL_STEP   = 100 / VOLUME_STEP;
    private static final int VOLUME_SHOW_TIME_MS = 500;

    private Paint mPaint;

    private int mVolume;
    private int mVolumeAreaLeft;
    private int mVolumeAreaTop;
    private int mVolumeAreaRight;
    private int mVolumeAreaBottom;
    private int mVolumeAreaRadius;
    private int mLineWidth;

    private Drawable mDrawableOpen;
    private Drawable mDrawableClose;

    private Handler mMainHandler;

    public UserVolumePromptView(Context context) {
        this(context, null);
    }

    public UserVolumePromptView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setWillNotDraw(false);

        mPaint = new Paint();
        mPaint.setColor(0xFFA5FE33);

        mVolume = Constants.VOLUME_NO_SOUND;

        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.UserVolumePromptView);
        mDrawableOpen = typedArray.getDrawable(R.styleable.UserVolumePromptView_backgroundStateOpen);
        if (mDrawableOpen == null) {
            mDrawableOpen = context.getResources().getDrawable(R.drawable.tuiroomkit_video_seat_mic_open);
        }
        mDrawableClose = typedArray.getDrawable(R.styleable.UserVolumePromptView_backgroundStateClose);
        if (mDrawableClose == null) {
            mDrawableClose = context.getResources().getDrawable(R.drawable.tuiroomkit_video_seat_mic_close);
        }
        mLineWidth = typedArray.getDimensionPixelOffset(R.styleable.UserVolumePromptView_boardLineWidth, 0);
        typedArray.recycle();
    }

    /**
     * Updated volume ui effect.
     *
     * @param volume The volume of the current mic, range [0 ~ 100]
     */
    public void updateVolumeEffect(int volume) {
        if (!isAttachedToWindow()) {
            return;
        }
        volume = volume < 0 ? 0 : volume;
        volume = volume > 100 ? 100 : volume;

        int greenVolume = volume / VOLUME_STEP;
        greenVolume += volume % VOLUME_STEP == 0 ? 0 : 1;
        if (mVolume == greenVolume) {
            return;
        }
        mVolume = greenVolume;
        invalidate();

        if (mMainHandler != null && mVolume != Constants.VOLUME_NO_SOUND) {
            mMainHandler.removeCallbacksAndMessages(null);
            mMainHandler.postDelayed(mClearGreenVolume, VOLUME_SHOW_TIME_MS);
        }
    }

    public void enableVolumeEffect(boolean enable) {
        setBackground(enable ? mDrawableOpen : mDrawableClose);
        if (!enable && mVolume != Constants.VOLUME_NO_SOUND) {
            updateVolumeEffect(Constants.VOLUME_NO_SOUND);
        }
    }

    Runnable mClearGreenVolume = new Runnable() {
        @Override
        public void run() {
            mVolume = Constants.VOLUME_NO_SOUND;
            invalidate();
        }
    };

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mMainHandler = new Handler(Looper.getMainLooper());
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (mMainHandler != null) {
            mMainHandler.removeCallbacksAndMessages(null);
            mMainHandler = null;
        }
        mVolume = Constants.VOLUME_NO_SOUND;
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        int width = right - left;
        int height = bottom - top;
        mVolumeAreaLeft = (width << 1) / 7 + mLineWidth;
        mVolumeAreaTop = (int) (height * 0.050) + mLineWidth;
        mVolumeAreaRight = width - mVolumeAreaLeft;
        mVolumeAreaBottom = (int) (height * 0.76) - mLineWidth;
        mVolumeAreaRadius = Math.min(mVolumeAreaRight - mVolumeAreaLeft, mVolumeAreaBottom - mVolumeAreaTop) >> 1;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        RectF rect = new RectF(mVolumeAreaLeft, mVolumeAreaTop, mVolumeAreaRight, mVolumeAreaBottom);
        int greenHeight = (mVolumeAreaBottom - mVolumeAreaTop) * mVolume / VOLUME_TOTAL_STEP;
        canvas.clipRect(mVolumeAreaLeft, mVolumeAreaBottom - greenHeight, mVolumeAreaRight, mVolumeAreaBottom);
        canvas.drawRoundRect(rect, mVolumeAreaRadius, mVolumeAreaRadius, mPaint);
    }
}
