package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;
import androidx.annotation.ColorInt;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import org.jetbrains.annotations.Nullable;

public class ProgressRingView extends View {

    private static final int PAINT_WIDTH = 10;
    private static final int ZERO_PROGRESS_PAINT_WIDTH = 4;
    private static final int TOTAL_RING_ANGEL = 360;
    private static final int RING_START_ANGEL = -90;

    private float mProgress = 0;
    private RectF mRectF;
    private Paint mProgressPaint;
    private Paint mBackgroundPaint;
    private int mProgressColor = Color.BLUE;

    public ProgressRingView(Context context) {
        super(context);
        init();
    }

    public ProgressRingView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        mProgressPaint = new Paint();
        mProgressPaint.setStrokeWidth(ZERO_PROGRESS_PAINT_WIDTH);
        mProgressPaint.setStyle(Paint.Style.STROKE);
        mProgressPaint.setAntiAlias(true);
        mProgressPaint.setColor(TUIMultimediaIConfig.getInstance().getThemeColor());

        mBackgroundPaint = new Paint();
        mBackgroundPaint.setStrokeWidth(ZERO_PROGRESS_PAINT_WIDTH);
        mBackgroundPaint.setStyle(Paint.Style.STROKE);
        mBackgroundPaint.setAntiAlias(true);

        mRectF = new RectF();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        if (mProgress > 0) {
            mProgressPaint.setStrokeWidth(PAINT_WIDTH);
            mBackgroundPaint.setStrokeWidth(PAINT_WIDTH);
            mBackgroundPaint.setColor(Color.GRAY);
        } else {
            mProgressPaint.setStrokeWidth(ZERO_PROGRESS_PAINT_WIDTH);
            mBackgroundPaint.setStrokeWidth(ZERO_PROGRESS_PAINT_WIDTH);
            mBackgroundPaint.setColor(Color.WHITE);
        }

        int centerX = getWidth() / 2;
        int centerY = getHeight() / 2;
        int radius = Math.min(centerX, centerY) - PAINT_WIDTH / 2;
        mRectF.set(centerX - radius, centerY - radius, centerX + radius, centerY + radius);
        canvas.drawOval(mRectF, mBackgroundPaint);
        canvas.drawArc(mRectF, RING_START_ANGEL, mProgress * TOTAL_RING_ANGEL, false, mProgressPaint);
    }

    public void setProgress(float progress) {
        mProgress = progress;
        postInvalidate();
    }
}