package com.tencent.qcloud.tuikit.tuichat.component.camera.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;

public class FocusView extends View {
    private int size;
    private int centerX;
    private int centerY;
    private int length;
    private Paint mPaint;

    public FocusView(Context context) {
        this(context, null);
    }

    public FocusView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FocusView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.size = ScreenUtil.getScreenWidth(context) / 3;
        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setDither(true);
        mPaint.setColor(0xEE16AE16);
        mPaint.setStrokeWidth(4);
        mPaint.setStyle(Paint.Style.STROKE);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        centerX = (int) (size / 2.0);
        centerY = (int) (size / 2.0);
        length = (int) (size / 2.0) - 2;
        setMeasuredDimension(size, size);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        canvas.drawRect(centerX - length, centerY - length, centerX + length, centerY + length, mPaint);
        canvas.drawLine(2, getHeight() / 2, size / 10, getHeight() / 2, mPaint);
        canvas.drawLine(getWidth() - 2, getHeight() / 2, getWidth() - size / 10, getHeight() / 2, mPaint);
        canvas.drawLine(getWidth() / 2, 2, getWidth() / 2, size / 10, mPaint);
        canvas.drawLine(getWidth() / 2, getHeight() - 2, getWidth() / 2, getHeight() - size / 10, mPaint);
    }
}
