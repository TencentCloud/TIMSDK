package com.tencent.cloud.tuikit.roomkit.view.basic;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Region;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

import androidx.annotation.Nullable;


public class RoundRelativeLayout extends RelativeLayout {
    private static final int RADIUS = 48;

    private int   mRadius;
    private RectF mRect;
    private Path  mPath;

    public RoundRelativeLayout(Context context) {
        this(context, null);
    }

    public RoundRelativeLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setWillNotDraw(false);
        mRadius = RADIUS;
        mPath = new Path();
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        mRect = new RectF(0, 0, getWidth(), getHeight());
    }

    @Override
    public void draw(Canvas canvas) {
        mPath.reset();
        mPath.addRoundRect(mRect, mRadius, mRadius, Path.Direction.CW);
        int saveCount = canvas.save();
        canvas.clipPath(mPath, Region.Op.INTERSECT);
        super.draw(canvas);
        canvas.restoreToCount(saveCount);
    }
}

