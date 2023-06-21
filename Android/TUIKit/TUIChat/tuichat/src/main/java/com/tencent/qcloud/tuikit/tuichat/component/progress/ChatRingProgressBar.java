package com.tencent.qcloud.tuikit.tuichat.component.progress;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;

public class ChatRingProgressBar extends View {
    private float progress;
    private int progressColor = Color.WHITE;
    private int secondProgressColor = 0x66FFFFFF;
    private final Paint paint = new Paint();
    private final RectF rectF = new RectF();
    
    public ChatRingProgressBar(Context context) {
        super(context);
    }

    public ChatRingProgressBar(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public ChatRingProgressBar(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        canvas.drawColor(Color.TRANSPARENT);
        paint.setAntiAlias(true);
        int stokeWidth = ScreenUtil.dip2px(3);
        paint.setStrokeWidth(stokeWidth);
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeCap(Paint.Cap.ROUND);
        paint.setColor(secondProgressColor);
        rectF.set(stokeWidth, stokeWidth, getWidth() - stokeWidth, getHeight() - stokeWidth);
        canvas.drawArc(rectF, 270, 360, false, paint);
        paint.setColor(progressColor);
        canvas.drawArc(rectF, 270, (360f / 100) * progress, false, paint);
    }

    public void setProgress(float progress) {
        if (progress < 0) {
            return;
        }
        if (progress > 100) {
            progress = 100;
        }
        this.progress = progress;
        postInvalidate();
    }
}
