package com.tencent.qcloud.tuikit.tuichat.component.camera.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.view.View;

public class ReturnButton extends View {
    Path path;
    private int size;
    private int centerX;
    private int centerY;
    private float strokeWidth;
    private Paint paint;

    public ReturnButton(Context context, int size) {
        this(context);
        this.size = size;
        centerX = size / 2;
        centerY = size / 2;

        strokeWidth = size / 15f;

        paint = new Paint();
        paint.setAntiAlias(true);
        paint.setColor(Color.WHITE);
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeWidth(strokeWidth);

        path = new Path();
    }

    public ReturnButton(Context context) {
        super(context);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        setMeasuredDimension(size, size / 2);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        path.moveTo(strokeWidth, strokeWidth / 2);
        path.lineTo(centerX, centerY - strokeWidth / 2);
        path.lineTo(size - strokeWidth, strokeWidth / 2);
        canvas.drawPath(path, paint);
    }
}
