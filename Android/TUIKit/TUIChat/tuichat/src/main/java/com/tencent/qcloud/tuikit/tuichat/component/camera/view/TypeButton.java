package com.tencent.qcloud.tuikit.tuichat.component.camera.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.view.View;

/**
 *
 * Confirm and return buttons that pop up after taking a photo or recording
 */
public class TypeButton extends View {
    public static final int TYPE_CANCEL = 0x001;
    public static final int TYPE_CONFIRM = 0x002;
    private int buttonType;
    private int buttonSize;

    private float centerX;
    private float centerY;
    private float buttonRadius;

    private Paint mPaint;
    private Path path;
    private float strokeWidth;

    private float index;
    private RectF rectF;

    public TypeButton(Context context) {
        super(context);
    }

    public TypeButton(Context context, int type, int size) {
        super(context);
        this.buttonType = type;
        buttonSize = size;
        buttonRadius = size / 2.0f;
        centerX = size / 2.0f;
        centerY = size / 2.0f;

        mPaint = new Paint();
        path = new Path();
        strokeWidth = size / 50f;
        index = buttonSize / 12f;
        rectF = new RectF(centerX, centerY - index, centerX + index * 2, centerY + index);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        setMeasuredDimension(buttonSize, buttonSize);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        // If the type is cancel, draw the return arrow inside
        if (buttonType == TYPE_CANCEL) {
            mPaint.setAntiAlias(true);
            mPaint.setColor(0xEEDCDCDC);
            mPaint.setStyle(Paint.Style.FILL);
            canvas.drawCircle(centerX, centerY, buttonRadius, mPaint);

            mPaint.setColor(Color.BLACK);
            mPaint.setStyle(Paint.Style.STROKE);
            mPaint.setStrokeWidth(strokeWidth);

            path.moveTo(centerX - index / 7, centerY + index);
            path.lineTo(centerX + index, centerY + index);

            path.arcTo(rectF, 90, -180);
            path.lineTo(centerX - index, centerY - index);
            canvas.drawPath(path, mPaint);
            mPaint.setStyle(Paint.Style.FILL);
            path.reset();
            path.moveTo(centerX - index, (float) (centerY - index * 1.5));
            path.lineTo(centerX - index, (float) (centerY - index / 2.3));
            path.lineTo((float) (centerX - index * 1.6), centerY - index);
            path.close();
            canvas.drawPath(path, mPaint);
        }
        
        // If the type is confirmation, draw a green tick
        if (buttonType == TYPE_CONFIRM) {
            mPaint.setAntiAlias(true);
            mPaint.setColor(0xFFFFFFFF);
            mPaint.setStyle(Paint.Style.FILL);
            canvas.drawCircle(centerX, centerY, buttonRadius, mPaint);
            mPaint.setAntiAlias(true);
            mPaint.setStyle(Paint.Style.STROKE);
            mPaint.setColor(0xFF00CC00);
            mPaint.setStrokeWidth(strokeWidth);

            path.moveTo(centerX - buttonSize / 6f, centerY);
            path.lineTo(centerX - buttonSize / 21.2f, centerY + buttonSize / 7.7f);
            path.lineTo(centerX + buttonSize / 4.0f, centerY - buttonSize / 8.5f);
            path.lineTo(centerX - buttonSize / 21.2f, centerY + buttonSize / 9.4f);
            path.close();
            canvas.drawPath(path, mPaint);
        }
    }
}
